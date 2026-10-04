class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isVerified;
  final String? branchId;
  final String? branchName;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isVerified,
    this.branchId,
    this.branchName,
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isModerator =>
      role == 'moderator' || role == 'admin' || role == 'super_admin';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      isVerified: json['is_verified'] as bool? ?? false,
      branchId: json['branch_id'] as String?,
      branchName: json['branch_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_verified': isVerified,
      'branch_id': branchId,
    };
  }

  ProfileModel copyWith({
    String? role,
    String? branchId,
    String? branchName,
    bool? isVerified,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      fullName: fullName,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
    );
  }
}