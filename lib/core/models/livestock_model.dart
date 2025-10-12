enum LivestockType {
  cattle,
  goat,
  sheep,
  poultry,
  other;
  
  String get displayName {
    switch (this) {
      case LivestockType.cattle:
        return 'Cattle';
      case LivestockType.goat:
        return 'Goat';
      case LivestockType.sheep:
        return 'Sheep';
      case LivestockType.poultry:
        return 'Poultry';
      case LivestockType.other:
        return 'Other';
    }
  }
}

class LivestockModel {
  final String id;
  final String userId;
  final String name;
  final LivestockType type;
  final String? breed;
  final String? tagNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weight;
  final String? color;
  final String? imageUrl;
  final DateTime registeredDate;
  final String? notes;
  final List<String> diagnosisHistory; // IDs of diagnoses
  final bool isSynced;
  
  LivestockModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.breed,
    this.tagNumber,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.color,
    this.imageUrl,
    required this.registeredDate,
    this.notes,
    this.diagnosisHistory = const [],
    this.isSynced = false,
  });
  
  /// Get age in months
  int? get ageInMonths {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    return (now.difference(dateOfBirth!).inDays / 30).floor();
  }
  
  /// Get age string
  String get ageString {
    final months = ageInMonths;
    if (months == null) return 'Unknown';
    if (months < 12) return '$months months';
    final years = (months / 12).floor();
    final remainingMonths = months % 12;
    if (remainingMonths == 0) return '$years ${years == 1 ? 'year' : 'years'}';
    return '$years ${years == 1 ? 'year' : 'years'} $remainingMonths months';
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.name,
      'breed': breed,
      'tagNumber': tagNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'color': color,
      'imageUrl': imageUrl,
      'registeredDate': registeredDate.toIso8601String(),
      'notes': notes,
      'diagnosisHistory': diagnosisHistory,
      'isSynced': isSynced,
    };
  }
  
  /// Create from JSON
  factory LivestockModel.fromJson(Map<String, dynamic> json) {
    return LivestockModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: LivestockType.values.firstWhere((e) => e.name == json['type']),
      breed: json['breed'] as String?,
      tagNumber: json['tagNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String) 
          : null,
      gender: json['gender'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      color: json['color'] as String?,
      imageUrl: json['imageUrl'] as String?,
      registeredDate: DateTime.parse(json['registeredDate'] as String),
      notes: json['notes'] as String?,
      diagnosisHistory: json['diagnosisHistory'] != null 
          ? List<String>.from(json['diagnosisHistory'] as List) 
          : [],
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
  
  /// Copy with method
  LivestockModel copyWith({
    String? id,
    String? userId,
    String? name,
    LivestockType? type,
    String? breed,
    String? tagNumber,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    String? color,
    String? imageUrl,
    DateTime? registeredDate,
    String? notes,
    List<String>? diagnosisHistory,
    bool? isSynced,
  }) {
    return LivestockModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      tagNumber: tagNumber ?? this.tagNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      registeredDate: registeredDate ?? this.registeredDate,
      notes: notes ?? this.notes,
      diagnosisHistory: diagnosisHistory ?? this.diagnosisHistory,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

