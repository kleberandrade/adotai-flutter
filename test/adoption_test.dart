import 'package:flutter_test/flutter_test.dart';
import 'package:adotai/modules/pets/pets_model.dart';
import 'package:adotai/modules/pets/pets_repository.dart';

class MemoryStore implements StateStore {
  String? value;
  bool fail = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('disk full');
    this.value = value;
  }
}

void main() {
  test('filters combine species, size and case-insensitive search', () {
    expect(filterPets(seedPets, species: 'cat').length, 3);
    expect(
      filterPets(seedPets, species: 'dog', size: 'small').single.name,
      'Pipoca',
    );
    expect(filterPets(seedPets, query: 'LUNA').single.id, 'luna');
    expect(filterPets(seedPets, query: 'absent'), isEmpty);
  });
  test(
    'favorites, language and requests survive a repository reload',
    () async {
      final store = MemoryStore();
      final repo = LocalPetsRepository(store);
      await repo.load();
      await repo.toggleFavorite('luna');
      await repo.setLanguage('en');
      await repo.apply(
        'luna',
        'Ana',
        'ana@example.test',
        'A quiet and safe home.',
      );
      final restored = LocalPetsRepository(store);
      await restored.load();
      expect(restored.state.favorites, {'luna'});
      expect(restored.state.language, 'en');
      expect(restored.state.requests.single.status, AdoptionStatus.submitted);
      await expectLater(
        restored.apply(
          'luna',
          'Ana',
          'ana@example.test',
          'A safe home for Luna.',
        ),
        throwsStateError,
      );
      await restored.transition('luna', AdoptionStatus.meeting);
      await restored.transition('luna', AdoptionStatus.completed);
      await expectLater(
        restored.transition('luna', AdoptionStatus.submitted),
        throwsStateError,
      );
    },
  );
  test('validation rejects incomplete or malformed applications', () async {
    final repo = LocalPetsRepository(MemoryStore());
    for (final values in [
      ['', 'ana@example.test', 'A safe home for Luna.'],
      ['Ana', 'invalid', 'A safe home for Luna.'],
      ['Ana', 'ana@example.test', 'short'],
    ]) {
      await expectLater(
        repo.apply('luna', values[0], values[1], values[2]),
        throwsArgumentError,
      );
    }
    expect(repo.state.requests, isEmpty);
  });
  test('failed persistence leaves the last committed state intact', () async {
    final store = MemoryStore()..fail = true;
    final repo = LocalPetsRepository(store);
    await expectLater(repo.toggleFavorite('luna'), throwsStateError);
    expect(repo.state.favorites, isEmpty);
  });
  test(
    'cancel permits a fresh request and corrupt storage is surfaced',
    () async {
      final store = MemoryStore();
      final repo = LocalPetsRepository(store);
      await repo.apply(
        'luna',
        'Ana',
        'ana@example.test',
        'A safe home for Luna.',
      );
      await repo.transition('luna', AdoptionStatus.cancelled);
      await repo.apply(
        'luna',
        'Ana',
        'ana@example.test',
        'A safe home for Luna.',
      );
      expect(repo.state.requests.length, 1);
      store.value = 'broken json';
      await expectLater(repo.load(), throwsFormatException);
    },
  );
  test('unknown saved pet IDs are rejected before rendering', () {
    final saved = AdoptionState(favorites: {'removed-pet'}).encode();
    expect(() => AdoptionState.decode(saved), throwsFormatException);
  });
}
