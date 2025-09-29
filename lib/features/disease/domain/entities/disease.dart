class Disease {

  const Disease({
    this.diseaseId,
    required this.diseaseName,
    required this.scientificName,
    required this.species,
    required this.symptoms,
    required this.causes,
    required this.prevention,
    required this.treatment,
    required this.severity,
    required this.contagious,
    required this.mortalityRate,
    required this.affectedBodyParts,
    required this.seasonality,
    this.imageUrl,
    required this.modelConfidence,
    required this.dateAdded,
    required this.lastUpdated,
  });

  factory Disease.create({
    required String diseaseName,
    required String species,
    required String symptoms,
    required String treatment,
    required String severity,
  }) {
    final now = DateTime.now();
    return Disease(
      diseaseName: diseaseName,
      scientificName: '',
      species: species,
      symptoms: symptoms,
      causes: '',
      prevention: '',
      treatment: treatment,
      severity: severity,
      contagious: 'Unknown',
      mortalityRate: '',
      affectedBodyParts: '',
      seasonality: '',
      modelConfidence: '0.7',
      dateAdded: now,
      lastUpdated: now,
    );
  }

  factory Disease.fromMap(Map<String, dynamic> map) {
    return Disease(
      diseaseId: map['diseaseId'],
      diseaseName: map['diseaseName'] ?? '',
      scientificName: map['scientificName'] ?? '',
      species: map['species'] ?? '',
      symptoms: map['symptoms'] ?? '',
      causes: map['causes'] ?? '',
      prevention: map['prevention'] ?? '',
      treatment: map['treatment'] ?? '',
      severity: map['severity'] ?? '',
      contagious: map['contagious'] ?? '',
      mortalityRate: map['mortalityRate'] ?? '',
      affectedBodyParts: map['affectedBodyParts'] ?? '',
      seasonality: map['seasonality'] ?? '',
      imageUrl: map['imageUrl'],
      modelConfidence: map['modelConfidence'] ?? '0.7',
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }
  final int? diseaseId;
  final String diseaseName;
  final String scientificName;
  final String species;
  final String symptoms;
  final String causes;
  final String prevention;
  final String treatment;
  final String severity;
  final String contagious;
  final String mortalityRate;
  final String affectedBodyParts;
  final String seasonality;
  final String? imageUrl;
  final String modelConfidence;
  final DateTime dateAdded;
  final DateTime lastUpdated;

  Disease copyWith({
    int? diseaseId,
    String? diseaseName,
    String? scientificName,
    String? species,
    String? symptoms,
    String? causes,
    String? prevention,
    String? treatment,
    String? severity,
    String? contagious,
    String? mortalityRate,
    String? affectedBodyParts,
    String? seasonality,
    String? imageUrl,
    String? modelConfidence,
    DateTime? dateAdded,
    DateTime? lastUpdated,
  }) {
    return Disease(
      diseaseId: diseaseId ?? this.diseaseId,
      diseaseName: diseaseName ?? this.diseaseName,
      scientificName: scientificName ?? this.scientificName,
      species: species ?? this.species,
      symptoms: symptoms ?? this.symptoms,
      causes: causes ?? this.causes,
      prevention: prevention ?? this.prevention,
      treatment: treatment ?? this.treatment,
      severity: severity ?? this.severity,
      contagious: contagious ?? this.contagious,
      mortalityRate: mortalityRate ?? this.mortalityRate,
      affectedBodyParts: affectedBodyParts ?? this.affectedBodyParts,
      seasonality: seasonality ?? this.seasonality,
      imageUrl: imageUrl ?? this.imageUrl,
      modelConfidence: modelConfidence ?? this.modelConfidence,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diseaseId': diseaseId,
      'diseaseName': diseaseName,
      'scientificName': scientificName,
      'species': species,
      'symptoms': symptoms,
      'causes': causes,
      'prevention': prevention,
      'treatment': treatment,
      'severity': severity,
      'contagious': contagious,
      'mortalityRate': mortalityRate,
      'affectedBodyParts': affectedBodyParts,
      'seasonality': seasonality,
      'imageUrl': imageUrl,
      'modelConfidence': modelConfidence,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'Disease(diseaseId: $diseaseId, diseaseName: $diseaseName, scientificName: $scientificName, species: $species, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Disease &&
        other.diseaseId == diseaseId &&
        other.diseaseName == diseaseName &&
        other.scientificName == scientificName &&
        other.species == species;
  }

  @override
  int get hashCode {
    return diseaseId.hashCode ^
        diseaseName.hashCode ^
        scientificName.hashCode ^
        species.hashCode;
  }
}
