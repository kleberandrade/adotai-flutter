enum AdoptionStatus { submitted, meeting, completed, cancelled }

class Pet {
  final String id, name, species, size, gender, nature;
  final int age, color;
  const Pet(
    this.id,
    this.name,
    this.species,
    this.size,
    this.gender,
    this.age,
    this.nature,
    this.color,
  );
}

const seedPets = [
  Pet('luna', 'Luna', 'dog', 'medium', 'female', 2, 'gentle', 0xFFE6CBAF),
  Pet('oliver', 'Oliver', 'cat', 'small', 'male', 1, 'curious', 0xFFCFDAD0),
  Pet('pipoca', 'Pipoca', 'dog', 'small', 'female', 3, 'playful', 0xFFF1D3BE),
  Pet('bento', 'Bento', 'dog', 'large', 'male', 5, 'gentle', 0xFFD9D6E8),
  Pet('amora', 'Amora', 'cat', 'small', 'female', 2, 'gentle', 0xFFE9D8B1),
  Pet('nino', 'Nino', 'cat', 'small', 'male', 4, 'curious', 0xFFBCD7D8),
];

List<Pet> filterPets(
  Iterable<Pet> pets, {
  String species = '',
  String size = '',
  String query = '',
}) => pets
    .where(
      (p) =>
          (species.isEmpty || p.species == species) &&
          (size.isEmpty || p.size == size) &&
          p.name.toLowerCase().contains(query.trim().toLowerCase()),
    )
    .toList();

class AdoptionRequest {
  final String petId, name, email, home;
  final AdoptionStatus status;
  final DateTime createdAt;
  const AdoptionRequest(
    this.petId,
    this.name,
    this.email,
    this.home,
    this.status,
    this.createdAt,
  );
  AdoptionRequest withStatus(AdoptionStatus next) =>
      AdoptionRequest(petId, name, email, home, next, createdAt);
  Map<String, Object> toJson() => {
    'petId': petId,
    'name': name,
    'email': email,
    'home': home,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };
  factory AdoptionRequest.fromJson(Map<String, dynamic> json) =>
      AdoptionRequest(
        json['petId'] as String,
        json['name'] as String,
        json['email'] as String,
        json['home'] as String,
        AdoptionStatus.values.byName(json['status'] as String),
        DateTime.parse(json['createdAt'] as String),
      );
}

String? validateApplication(String name, String email, String home) {
  if (name.trim().length < 2) return 'name';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
    return 'email';
  }
  if (home.trim().length < 20) return 'home';
  return null;
}
