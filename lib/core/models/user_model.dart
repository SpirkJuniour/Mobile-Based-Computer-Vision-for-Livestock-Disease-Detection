enum UserRole {
  farmer,
  veterinarian,
  administrator;

  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.veterinarian:
        return 'Veterinarian';
      case UserRole.administrator:
        return 'Administrator';
    }
  }

  String get description {
    switch (this) {
      case UserRole.farmer:
        return 'Manage livestock and diagnose diseases';
      case UserRole.veterinarian:
        return 'Professional diagnosis and treatment';
      case UserRole.administrator:
        return 'System administration and management';
    }
  }
}

class UserModel {
  final String userId;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? licenseNumber; // For veterinarians
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? authToken; // For offline authentication
  final DateTime? tokenExpiry;
  final bool isVerified;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    this.licenseNumber,
    required this.createdAt,
    this.lastLogin,
    this.authToken,
    this.tokenExpiry,
    this.isVerified = false,
  });

  /// Check if offline token is valid
  bool get isTokenValid {
    if (authToken == null || tokenExpiry == null) return false;
    return DateTime.now().isBefore(tokenExpiry!);
  }

  /// Copy with method for updates
  UserModel copyWith({
    String? userId,
    String? email,
    String? fullName,
    UserRole? role,
    String? phoneNumber,
    String? profileImageUrl,
    String? licenseNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? authToken,
    DateTime? tokenExpiry,
    bool? isVerified,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      authToken: authToken ?? this.authToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// Convert to Supabase map (for database insert/update)
  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'license_number': licenseNumber,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'auth_token': authToken,
      'token_expiry': tokenExpiry?.toIso8601String(),
      'is_verified': isVerified,
    };
  }

  /// Create from Supabase map
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      userId: data['user_id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String,
      role: UserRole.values.firstWhere((e) => e.name == data['role']),
      phoneNumber: data['phone_number'] as String?,
      profileImageUrl: data['profile_image_url'] as String?,
      licenseNumber: data['license_number'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      lastLogin: data['last_login'] != null
          ? DateTime.parse(data['last_login'] as String)
          : null,
      authToken: data['auth_token'] as String?,
      tokenExpiry: data['token_expiry'] != null
          ? DateTime.parse(data['token_expiry'] as String)
          : null,
      isVerified: data['is_verified'] as bool? ?? false,
    );
  }

  /// Convert to JSON for local database
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'licenseNumber': licenseNumber,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'authToken': authToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  /// Create from JSON (local database)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      authToken: json['authToken'] as String?,
      tokenExpiry: json['tokenExpiry'] != null
          ? DateTime.parse(json['tokenExpiry'] as String)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}
