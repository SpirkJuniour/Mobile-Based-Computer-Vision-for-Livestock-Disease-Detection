class Livestock {
  final int? livestockId;
  final String tagNumber;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final DateTime dateOfBirth;
  final String? color;
  final String? weight;
  final String? healthStatus;
  final String? vaccinationHistory;
  final String? notes;
  final String? imagePath;
  final DateTime dateAdded;
  final DateTime lastUpdated;

  const Livestock({
    this.livestockId,
    required this.tagNumber,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.dateOfBirth,
    this.color,
    this.weight,
    this.healthStatus,
    this.vaccinationHistory,
    this.notes,
    this.imagePath,
    required this.dateAdded,
    required this.lastUpdated,
  });

  factory Livestock.create({
    required String tagNumber,
    required String name,
    required String species,
    required String breed,
    required String gender,
    required DateTime dateOfBirth,
  }) {
    final now = DateTime.now();
    return Livestock(
      tagNumber: tagNumber,
      name: name,
      species: species,
      breed: breed,
      gender: gender,
      dateOfBirth: dateOfBirth,
      healthStatus: 'Healthy',
      dateAdded: now,
      lastUpdated: now,
    );
  }

  Livestock copyWith({
    int? livestockId,
    String? tagNumber,
    String? name,
    String? species,
    String? breed,
    String? gender,
    DateTime? dateOfBirth,
    String? color,
    String? weight,
    String? healthStatus,
    String? vaccinationHistory,
    String? notes,
    String? imagePath,
    DateTime? dateAdded,
    DateTime? lastUpdated,
  }) {
    return Livestock(
      livestockId: livestockId ?? this.livestockId,
      tagNumber: tagNumber ?? this.tagNumber,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      healthStatus: healthStatus ?? this.healthStatus,
      vaccinationHistory: vaccinationHistory ?? this.vaccinationHistory,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'livestockId': livestockId,
      'tagNumber': tagNumber,
      'name': name,
      'species': species,
      'breed': breed,
      'gender': gender,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'color': color,
      'weight': weight,
      'healthStatus': healthStatus,
      'vaccinationHistory': vaccinationHistory,
      'notes': notes,
      'imagePath': imagePath,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory Livestock.fromMap(Map<String, dynamic> map) {
    return Livestock(
      livestockId: map['livestockId'],
      tagNumber: map['tagNumber'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      breed: map['breed'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth']),
      color: map['color'],
      weight: map['weight'],
      healthStatus: map['healthStatus'],
      vaccinationHistory: map['vaccinationHistory'],
      notes: map['notes'],
      imagePath: map['imagePath'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  @override
  String toString() {
    return 'Livestock(livestockId: $livestockId, tagNumber: $tagNumber, name: $name, species: $species, breed: $breed, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Livestock &&
        other.livestockId == livestockId &&
        other.tagNumber == tagNumber &&
        other.name == name &&
        other.species == species;
  }

  @override
  int get hashCode {
    return livestockId.hashCode ^
        tagNumber.hashCode ^
        name.hashCode ^
        species.hashCode;
  }
}
