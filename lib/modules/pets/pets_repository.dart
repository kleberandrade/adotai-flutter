import 'dart:convert';

import 'pets_model.dart';

abstract interface class StateStore {
  Future<String?> read();
  Future<void> write(String value);
}

class AdoptionState {
  final Set<String> favorites;
  final List<AdoptionRequest> requests;
  final String language;
  AdoptionState({
    Set<String> favorites = const {},
    List<AdoptionRequest> requests = const [],
    this.language = 'pt',
  }) : favorites = Set.unmodifiable(favorites),
       requests = List.unmodifiable(requests);
  AdoptionState copyWith({
    Set<String>? favorites,
    List<AdoptionRequest>? requests,
    String? language,
  }) => AdoptionState(
    favorites: favorites ?? this.favorites,
    requests: requests ?? this.requests,
    language: language ?? this.language,
  );
  String encode() => jsonEncode({
    'version': 1,
    'favorites': favorites.toList(),
    'requests': requests.map((r) => r.toJson()).toList(),
    'language': language,
  });
  factory AdoptionState.decode(String source) {
    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      if (json['version'] != 1 || !['pt', 'en'].contains(json['language'])) {
        throw const FormatException('Unsupported saved data');
      }
      final parsed = AdoptionState(
        favorites: (json['favorites'] as List).cast<String>().toSet(),
        requests: (json['requests'] as List)
            .map((r) => AdoptionRequest.fromJson(r as Map<String, dynamic>))
            .toList(),
        language: json['language'] as String,
      );
      final knownIds = seedPets.map((pet) => pet.id).toSet();
      final requestIds = parsed.requests
          .map((request) => request.petId)
          .toSet();
      if (!knownIds.containsAll(parsed.favorites) ||
          !knownIds.containsAll(requestIds) ||
          requestIds.length != parsed.requests.length ||
          parsed.requests.any(
            (request) =>
                validateApplication(
                  request.name,
                  request.email,
                  request.home,
                ) !=
                null,
          )) {
        throw const FormatException('Invalid saved pet data');
      }
      return parsed;
    } catch (_) {
      throw const FormatException('Saved data could not be read');
    }
  }
}

abstract interface class PetsRepository {
  AdoptionState get state;
  Future<void> load();
  Future<void> toggleFavorite(String id);
  Future<void> setLanguage(String language);
  Future<void> apply(String petId, String name, String email, String home);
  Future<void> transition(String petId, AdoptionStatus next);
}

class LocalPetsRepository implements PetsRepository {
  final StateStore store;
  @override
  AdoptionState state = AdoptionState();
  LocalPetsRepository(this.store);
  @override
  Future<void> load() async {
    final source = await store.read();
    state = source == null ? AdoptionState() : AdoptionState.decode(source);
  }

  Future<void> _commit(AdoptionState next) async {
    await store.write(next.encode());
    state = next;
  }

  void _known(String id) {
    if (!seedPets.any((p) => p.id == id)) throw ArgumentError('Unknown pet');
  }

  @override
  Future<void> toggleFavorite(String id) async {
    _known(id);
    final ids = {...state.favorites};
    if (!ids.add(id)) ids.remove(id);
    await _commit(state.copyWith(favorites: ids));
  }

  @override
  Future<void> setLanguage(String language) async {
    if (!['pt', 'en'].contains(language)) {
      throw ArgumentError('Unknown language');
    }
    await _commit(state.copyWith(language: language));
  }

  @override
  Future<void> apply(
    String petId,
    String name,
    String email,
    String home,
  ) async {
    _known(petId);
    if (validateApplication(name, email, home) != null) {
      throw ArgumentError('Invalid application');
    }
    if (state.requests.any(
      (r) => r.petId == petId && r.status != AdoptionStatus.cancelled,
    )) {
      throw StateError('An active request already exists');
    }
    await _commit(
      state.copyWith(
        requests: [
          ...state.requests.where((r) => r.petId != petId),
          AdoptionRequest(
            petId,
            name.trim(),
            email.trim(),
            home.trim(),
            AdoptionStatus.submitted,
            DateTime.now().toUtc(),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> transition(String petId, AdoptionStatus next) async {
    final request = state.requests.firstWhere((r) => r.petId == petId);
    final allowed = switch (request.status) {
      AdoptionStatus.submitted => {
        AdoptionStatus.meeting,
        AdoptionStatus.cancelled,
      },
      AdoptionStatus.meeting => {
        AdoptionStatus.completed,
        AdoptionStatus.cancelled,
      },
      _ => <AdoptionStatus>{},
    };
    if (!allowed.contains(next)) throw StateError('Invalid transition');
    await _commit(
      state.copyWith(
        requests: state.requests
            .map((r) => r.petId == petId ? r.withStatus(next) : r)
            .toList(),
      ),
    );
  }
}
