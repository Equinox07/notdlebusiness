class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? companyId;
  final String? avatarUrl;
  final String role;
  final bool hasCompany;
  final String authProvider;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.companyId,
    this.avatarUrl,
    this.role = 'ROLE_USER',
    this.hasCompany = false,
    this.authProvider = 'local',
    this.deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      companyId: json['companyId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'ROLE_USER',
      hasCompany: json['hasCompany'] as bool? ?? false,
      authProvider: json['authProvider'] as String? ?? 'local',
      deviceId: json['deviceId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (companyId != null) 'companyId': companyId,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'role': role,
      'hasCompany': hasCompany,
      'authProvider': authProvider,
      if (deviceId != null) 'deviceId': deviceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to create a copy with some fields updated
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? companyId,
    String? avatarUrl,
    String? role,
    bool? hasCompany,
    String? authProvider,
    String? deviceId,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyId: companyId ?? this.companyId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      hasCompany: hasCompany ?? this.hasCompany,
      authProvider: authProvider ?? this.authProvider,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
