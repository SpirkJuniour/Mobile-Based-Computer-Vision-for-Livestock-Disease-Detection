class DiseaseModel {
  final String id;
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatments;
  final List<String> preventionMethods;
  final int severityLevel; // 0-100
  final String? imageUrl;
  final bool isContagious;
  final List<String> affectedSpecies; // cattle, goat, sheep, etc.
  
  DiseaseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatments,
    required this.preventionMethods,
    required this.severityLevel,
    this.imageUrl,
    required this.isContagious,
    required this.affectedSpecies,
  });
  
  /// Get severity description
  String get severityDescription {
    if (severityLevel < 25) return 'Low';
    if (severityLevel < 50) return 'Medium';
    if (severityLevel < 75) return 'High';
    return 'Critical';
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'causes': causes,
      'treatments': treatments,
      'preventionMethods': preventionMethods,
      'severityLevel': severityLevel,
      'imageUrl': imageUrl,
      'isContagious': isContagious,
      'affectedSpecies': affectedSpecies,
    };
  }
  
  /// Create from JSON
  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      causes: List<String>.from(json['causes'] as List),
      treatments: List<String>.from(json['treatments'] as List),
      preventionMethods: List<String>.from(json['preventionMethods'] as List),
      severityLevel: json['severityLevel'] as int,
      imageUrl: json['imageUrl'] as String?,
      isContagious: json['isContagious'] as bool,
      affectedSpecies: List<String>.from(json['affectedSpecies'] as List),
    );
  }
  
  /// Copy with method
  DiseaseModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? symptoms,
    List<String>? causes,
    List<String>? treatments,
    List<String>? preventionMethods,
    int? severityLevel,
    String? imageUrl,
    bool? isContagious,
    List<String>? affectedSpecies,
  }) {
    return DiseaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      causes: causes ?? this.causes,
      treatments: treatments ?? this.treatments,
      preventionMethods: preventionMethods ?? this.preventionMethods,
      severityLevel: severityLevel ?? this.severityLevel,
      imageUrl: imageUrl ?? this.imageUrl,
      isContagious: isContagious ?? this.isContagious,
      affectedSpecies: affectedSpecies ?? this.affectedSpecies,
    );
  }
}

