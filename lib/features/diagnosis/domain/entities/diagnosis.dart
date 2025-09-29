class Diagnosis {
  final int? diagnosisId;
  final int livestockId;
  final int diseaseId;
  final String imagePath;
  final String diagnosisResult;
  final double confidence;
  final String status;
  final String? notes;
  final String? veterinarianNotes;
  final String? treatmentPrescribed;
  final String? followUpDate;
  final bool isTreated;
  final String? location;
  final String? weatherConditions;
  final DateTime diagnosisDate;
  final DateTime lastUpdated;

  const Diagnosis({
    this.diagnosisId,
    required this.livestockId,
    required this.diseaseId,
    required this.imagePath,
    required this.diagnosisResult,
    required this.confidence,
    required this.status,
    this.notes,
    this.veterinarianNotes,
    this.treatmentPrescribed,
    this.followUpDate,
    this.isTreated = false,
    this.location,
    this.weatherConditions,
    required this.diagnosisDate,
    required this.lastUpdated,
  });

  factory Diagnosis.create({
    required int livestockId,
    required String imagePath,
    required String diagnosisResult,
    required double confidence,
    required String status,
  }) {
    final now = DateTime.now();
    return Diagnosis(
      livestockId: livestockId,
      diseaseId: 0, // Will be set based on diagnosis result
      imagePath: imagePath,
      diagnosisResult: diagnosisResult,
      confidence: confidence,
      status: status,
      diagnosisDate: now,
      lastUpdated: now,
    );
  }

  Diagnosis copyWith({
    int? diagnosisId,
    int? livestockId,
    int? diseaseId,
    String? imagePath,
    String? diagnosisResult,
    double? confidence,
    String? status,
    String? notes,
    String? veterinarianNotes,
    String? treatmentPrescribed,
    String? followUpDate,
    bool? isTreated,
    String? location,
    String? weatherConditions,
    DateTime? diagnosisDate,
    DateTime? lastUpdated,
  }) {
    return Diagnosis(
      diagnosisId: diagnosisId ?? this.diagnosisId,
      livestockId: livestockId ?? this.livestockId,
      diseaseId: diseaseId ?? this.diseaseId,
      imagePath: imagePath ?? this.imagePath,
      diagnosisResult: diagnosisResult ?? this.diagnosisResult,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      veterinarianNotes: veterinarianNotes ?? this.veterinarianNotes,
      treatmentPrescribed: treatmentPrescribed ?? this.treatmentPrescribed,
      followUpDate: followUpDate ?? this.followUpDate,
      isTreated: isTreated ?? this.isTreated,
      location: location ?? this.location,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      diagnosisDate: diagnosisDate ?? this.diagnosisDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diagnosisId': diagnosisId,
      'livestockId': livestockId,
      'diseaseId': diseaseId,
      'imagePath': imagePath,
      'diagnosisResult': diagnosisResult,
      'confidence': confidence,
      'status': status,
      'notes': notes,
      'veterinarianNotes': veterinarianNotes,
      'treatmentPrescribed': treatmentPrescribed,
      'followUpDate': followUpDate,
      'isTreated': isTreated ? 1 : 0,
      'location': location,
      'weatherConditions': weatherConditions,
      'diagnosisDate': diagnosisDate.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory Diagnosis.fromMap(Map<String, dynamic> map) {
    return Diagnosis(
      diagnosisId: map['diagnosisId'],
      livestockId: map['livestockId'],
      diseaseId: map['diseaseId'],
      imagePath: map['imagePath'],
      diagnosisResult: map['diagnosisResult'],
      confidence: map['confidence']?.toDouble() ?? 0.0,
      status: map['status'],
      notes: map['notes'],
      veterinarianNotes: map['veterinarianNotes'],
      treatmentPrescribed: map['treatmentPrescribed'],
      followUpDate: map['followUpDate'],
      isTreated: map['isTreated'] == 1,
      location: map['location'],
      weatherConditions: map['weatherConditions'],
      diagnosisDate: DateTime.fromMillisecondsSinceEpoch(map['diagnosisDate']),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  @override
  String toString() {
    return 'Diagnosis(diagnosisId: $diagnosisId, livestockId: $livestockId, diseaseId: $diseaseId, imagePath: $imagePath, diagnosisResult: $diagnosisResult, confidence: $confidence, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Diagnosis &&
        other.diagnosisId == diagnosisId &&
        other.livestockId == livestockId &&
        other.diseaseId == diseaseId &&
        other.imagePath == imagePath &&
        other.diagnosisResult == diagnosisResult &&
        other.confidence == confidence &&
        other.status == status;
  }

  @override
  int get hashCode {
    return diagnosisId.hashCode ^
        livestockId.hashCode ^
        diseaseId.hashCode ^
        imagePath.hashCode ^
        diagnosisResult.hashCode ^
        confidence.hashCode ^
        status.hashCode;
  }
}
