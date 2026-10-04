class BranchModel {
  final String id;
  final String name;
  final String location;
  final String code;
  final bool isActive;
  final DateTime createdAt;

  const BranchModel({
    required this.id,
    required this.name,
    required this.location,
    required this.code,
    required this.isActive,
    required this.createdAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      code: json['code'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'code': code,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}