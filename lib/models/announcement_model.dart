class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final String createdBy;
  final String? branchId;
  final bool isGlobal;
  final String priority;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.createdBy,
    this.branchId,
    this.isGlobal = false,
    this.priority = 'normal',
  });

  bool get isEmergency => priority == 'emergency';
  bool get isHigh => priority == 'high';

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String? ?? '',
      branchId: json['branch_id'] as String?,
      isGlobal: json['is_global'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'branch_id': branchId,
      'is_global': isGlobal,
      'priority': priority,
    };
  }
}