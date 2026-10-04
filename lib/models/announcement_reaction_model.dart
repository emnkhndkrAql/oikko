class AnnouncementReactionModel {
  final String id;
  final String announcementId;
  final String userId;
  final String reaction;
  final DateTime createdAt;

  const AnnouncementReactionModel({
    required this.id,
    required this.announcementId,
    required this.userId,
    required this.reaction,
    required this.createdAt,
  });

  factory AnnouncementReactionModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementReactionModel(
      id: json['id'] as String,
      announcementId: json['announcement_id'] as String,
      userId: json['user_id'] as String,
      reaction: json['reaction'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}