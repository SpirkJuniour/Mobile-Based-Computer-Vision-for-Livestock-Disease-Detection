class DiagnosisModel {
  final String id;
  final String userId;
  final String? livestockId;
  final String diseaseName;
  final double confidence; // 0-100
  final String imagePath;
  final DateTime diagnosisDate;
  final List<String> symptoms;
  final List<String> recommendedTreatments;
  final List<String> preventionSteps;
  final int severityLevel; // 0-100
  final String? notes;
  final bool isSynced;
  
  DiagnosisModel({
    required this.id,
    required this.userId,
    this.livestockId,
    required this.diseaseName,
    required this.confidence,
    required this.imagePath,
    required this.diagnosisDate,
    required this.symptoms,
    required this.recommendedTreatments,
    required this.preventionSteps,
    required this.severityLevel,
    this.notes,
    this.isSynced = false,
  });
  
  /// Get confidence description
  String get confidenceDescription {
    if (confidence >= 85) return 'High Confidence';
    if (confidence >= 60) return 'Medium Confidence';
    return 'Low Confidence';
  }
  
  /// Get severity description
  String get severityDescription {
    if (severityLevel < 25) return 'Low Severity';
    if (severityLevel < 50) return 'Medium Severity';
    if (severityLevel < 75) return 'High Severity';
    return 'Critical Severity';
  }
  
  /// Is healthy diagnosis
  bool get isHealthy => diseaseName.toLowerCase().contains('healthy') || 
                       diseaseName.toLowerCase().contains('no disease');
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'livestockId': livestockId,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'imagePath': imagePath,
      'diagnosisDate': diagnosisDate.toIso8601String(),
      'symptoms': symptoms,
      'recommendedTreatments': recommendedTreatments,
      'preventionSteps': preventionSteps,
      'severityLevel': severityLevel,
      'notes': notes,
      'isSynced': isSynced,
    };
  }
  
  /// Create from JSON
  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      livestockId: json['livestockId'] as String?,
      diseaseName: json['diseaseName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imagePath: json['imagePath'] as String,
      diagnosisDate: DateTime.parse(json['diagnosisDate'] as String),
      symptoms: List<String>.from(json['symptoms'] as List),
      recommendedTreatments: List<String>.from(json['recommendedTreatments'] as List),
      preventionSteps: List<String>.from(json['preventionSteps'] as List),
      severityLevel: json['severityLevel'] as int,
      notes: json['notes'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
  
  /// Copy with method
  DiagnosisModel copyWith({
    String? id,
    String? userId,
    String? livestockId,
    String? diseaseName,
    double? confidence,
    String? imagePath,
    DateTime? diagnosisDate,
    List<String>? symptoms,
    List<String>? recommendedTreatments,
    List<String>? preventionSteps,
    int? severityLevel,
    String? notes,
    bool? isSynced,
  }) {
    return DiagnosisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      livestockId: livestockId ?? this.livestockId,
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath ?? this.imagePath,
      diagnosisDate: diagnosisDate ?? this.diagnosisDate,
      symptoms: symptoms ?? this.symptoms,
      recommendedTreatments: recommendedTreatments ?? this.recommendedTreatments,
      preventionSteps: preventionSteps ?? this.preventionSteps,
      severityLevel: severityLevel ?? this.severityLevel,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

