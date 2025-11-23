class VetCaseModel {
  final String id;
  final String diagnosisId;
  final String farmerId;
  final String? vetId;
  final String? notes;
  final String? treatmentPlan;
  final String status; // 'pending', 'in_progress', 'resolved', 'closed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  VetCaseModel({
    required this.id,
    required this.diagnosisId,
    required this.farmerId,
    this.vetId,
    this.notes,
    this.treatmentPlan,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  factory VetCaseModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle both camelCase (from code) and snake_case (from database)
    final diagnosisId = map['diagnosis_id'] ?? map['diagnosisId'] ?? '';
    final farmerId = map['farmer_id'] ?? map['farmerId'] ?? '';
    final vetId = map['vet_id'] ?? map['vetId'];
    final notes = map['notes'];
    final treatmentPlan = map['treatment_plan'] ?? map['treatmentPlan'];
    final status = map['status'] ?? 'pending';
    final createdAt = map['created_at'] ?? map['createdAt'];
    final updatedAt = map['updated_at'] ?? map['updatedAt'];
    
    return VetCaseModel(
      id: id,
      diagnosisId: diagnosisId.toString(),
      farmerId: farmerId.toString(),
      vetId: vetId?.toString(),
      notes: notes?.toString(),
      treatmentPlan: treatmentPlan?.toString(),
      status: status.toString(),
      createdAt: createdAt != null
          ? (createdAt is DateTime ? createdAt : DateTime.parse(createdAt.toString()))
          : DateTime.now(),
      updatedAt: updatedAt != null
          ? (updatedAt is DateTime ? updatedAt : DateTime.parse(updatedAt.toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diagnosis_id': diagnosisId,
      'farmer_id': farmerId,
      'vet_id': vetId,
      'notes': notes,
      'treatment_plan': treatmentPlan,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

