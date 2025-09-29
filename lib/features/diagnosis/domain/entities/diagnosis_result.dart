class DiagnosisResult {
  final String diseaseName;
  final double confidence;
  final String severity;
  final String symptoms;
  final String treatment;
  final String prevention;
  final bool contagious;
  final String affectedBodyParts;
  final String mortalityRate;
  final String seasonality;

  const DiagnosisResult({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.contagious,
    required this.affectedBodyParts,
    required this.mortalityRate,
    required this.seasonality,
  });

  factory DiagnosisResult.empty() {
    return const DiagnosisResult(
      diseaseName: 'Unknown',
      confidence: 0.0,
      severity: 'Unknown',
      symptoms: '',
      treatment: '',
      prevention: '',
      contagious: false,
      affectedBodyParts: '',
      mortalityRate: '',
      seasonality: '',
    );
  }

  DiagnosisResult copyWith({
    String? diseaseName,
    double? confidence,
    String? severity,
    String? symptoms,
    String? treatment,
    String? prevention,
    bool? contagious,
    String? affectedBodyParts,
    String? mortalityRate,
    String? seasonality,
  }) {
    return DiagnosisResult(
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      severity: severity ?? this.severity,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      prevention: prevention ?? this.prevention,
      contagious: contagious ?? this.contagious,
      affectedBodyParts: affectedBodyParts ?? this.affectedBodyParts,
      mortalityRate: mortalityRate ?? this.mortalityRate,
      seasonality: seasonality ?? this.seasonality,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diseaseName': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
      'contagious': contagious,
      'affectedBodyParts': affectedBodyParts,
      'mortalityRate': mortalityRate,
      'seasonality': seasonality,
    };
  }

  factory DiagnosisResult.fromMap(Map<String, dynamic> map) {
    return DiagnosisResult(
      diseaseName: map['diseaseName'] ?? 'Unknown',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      severity: map['severity'] ?? 'Unknown',
      symptoms: map['symptoms'] ?? '',
      treatment: map['treatment'] ?? '',
      prevention: map['prevention'] ?? '',
      contagious: map['contagious'] ?? false,
      affectedBodyParts: map['affectedBodyParts'] ?? '',
      mortalityRate: map['mortalityRate'] ?? '',
      seasonality: map['seasonality'] ?? '',
    );
  }

  @override
  String toString() {
    return 'DiagnosisResult(diseaseName: $diseaseName, confidence: $confidence, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosisResult &&
        other.diseaseName == diseaseName &&
        other.confidence == confidence &&
        other.severity == severity;
  }

  @override
  int get hashCode {
    return diseaseName.hashCode ^
        confidence.hashCode ^
        severity.hashCode;
  }
}
