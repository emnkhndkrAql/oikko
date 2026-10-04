class AnnouncementCommentModel {
  final String id;
  final String announcementId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? authorName;

  const AnnouncementCommentModel({
    required this.id,
    required this.announcementId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.authorName,
  });

  factory AnnouncementCommentModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementCommentModel(
      id: json['id'] as String,
      announcementId: json['announcement_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: json['profiles'] != null
          ? json['profiles']['full_name'] as String?
          : null,
    );
  }
}