class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'farmer' or 'veterinarian'
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    // Handle both camelCase (from code) and snake_case (from database)
    final email = map['email'] ?? '';
    final displayName = map['display_name'] ?? map['displayName'] ?? '';
    final role = map['role'] ?? 'farmer';
    final phoneNumber = map['phone_number'] ?? map['phoneNumber'];
    final profileImageUrl = map['profile_image_url'] ?? map['profileImageUrl'];
    final createdAt = map['created_at'] ?? map['createdAt'];
    final lastLoginAt = map['last_login_at'] ?? map['lastLoginAt'];
    
    return UserModel(
      uid: uid,
      email: email.toString(),
      displayName: displayName.toString(),
      role: role.toString(),
      phoneNumber: phoneNumber?.toString(),
      profileImageUrl: profileImageUrl?.toString(),
      createdAt: createdAt != null
          ? (createdAt is DateTime ? createdAt : DateTime.parse(createdAt.toString()))
          : DateTime.now(),
      lastLoginAt: lastLoginAt != null
          ? (lastLoginAt is DateTime ? lastLoginAt : DateTime.parse(lastLoginAt.toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

