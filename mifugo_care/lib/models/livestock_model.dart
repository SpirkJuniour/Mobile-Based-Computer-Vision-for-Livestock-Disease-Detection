class LivestockModel {
  final String id;
  final String farmerId;
  final String type; // 'cattle' or 'goat'
  final int? age;
  final String? gender;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LivestockModel({
    required this.id,
    required this.farmerId,
    required this.type,
    this.age,
    this.gender,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory LivestockModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle both camelCase (from code) and snake_case (from database)
    final farmerId = map['farmer_id'] ?? map['farmerId'] ?? '';
    final createdAt = map['created_at'] ?? map['createdAt'];
    final updatedAt = map['updated_at'] ?? map['updatedAt'];
    
    return LivestockModel(
      id: id,
      farmerId: farmerId.toString(),
      type: map['type'] ?? 'cattle',
      age: map['age'],
      gender: map['gender'],
      notes: map['notes'],
      createdAt: createdAt != null 
          ? (createdAt is DateTime ? createdAt : DateTime.parse(createdAt.toString()))
          : DateTime.now(),
      updatedAt: updatedAt != null 
          ? (updatedAt is DateTime ? updatedAt : DateTime.parse(updatedAt.toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    // Minimal schema - only essential fields
    final map = <String, dynamic>{
      'farmer_id': farmerId, // Use snake_case for database
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };

    // Only include type if database supports it (optional)
    // If not, we'll handle it gracefully in database service
    // Don't include age, gender, notes - not needed for photo analysis
    return map;
  }
}

