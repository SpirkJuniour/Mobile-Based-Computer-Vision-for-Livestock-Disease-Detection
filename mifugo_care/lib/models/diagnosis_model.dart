class DiagnosisModel {
  final String id;
  final String livestockId;
  final String farmerId;
  final String? imageUrl;
  final String? diseaseLabel;
  final double? confidenceScore;
  final String? recommendedAction;
  final String status; // 'pending', 'reviewed', 'treated'
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy; // vet id

  DiagnosisModel({
    required this.id,
    required this.livestockId,
    required this.farmerId,
    this.imageUrl,
    this.diseaseLabel,
    this.confidenceScore,
    this.recommendedAction,
    this.status = 'pending',
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory DiagnosisModel.fromMap(Map<String, dynamic> map, String id) {
    return DiagnosisModel(
      id: id,
      livestockId: map['livestockId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      imageUrl: map['imageUrl'],
      diseaseLabel: map['diseaseLabel'],
      confidenceScore: map['confidenceScore']?.toDouble(),
      recommendedAction: map['recommendedAction'],
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      reviewedAt: map['reviewedAt']?.toDate(),
      reviewedBy: map['reviewedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'livestockId': livestockId,
      'farmerId': farmerId,
      'imageUrl': imageUrl,
      'diseaseLabel': diseaseLabel,
      'confidenceScore': confidenceScore,
      'recommendedAction': recommendedAction,
      'status': status,
      'createdAt': createdAt,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy,
    };
  }
}

