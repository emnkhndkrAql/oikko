
class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isVerified;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isVerified,
  });

  bool get isAdmin => role == 'admin';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_verified': isVerified,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    bool? isVerified,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}