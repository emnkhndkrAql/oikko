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
  final DateTime? scheduledDeleteAt;

  // Populated client-side
  final int likeCount;
  final int loveCount;
  final int insightfulCount;
  final String? userReaction;
  final int commentCount;

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
    this.scheduledDeleteAt,
    this.likeCount = 0,
    this.loveCount = 0,
    this.insightfulCount = 0,
    this.userReaction,
    this.commentCount = 0,
  });

  bool get isEmergency => priority == 'emergency';
  bool get isHigh => priority == 'high';
  bool get isDeletionScheduled => scheduledDeleteAt != null;

  Duration? get timeUntilDeletion {
    if (scheduledDeleteAt == null) return null;
    final diff = scheduledDeleteAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

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
      scheduledDeleteAt: json['scheduled_delete_at'] != null
          ? DateTime.parse(json['scheduled_delete_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
    'created_by': createdBy,
    'branch_id': branchId,
    'is_global': isGlobal,
    'priority': priority,
    'scheduled_delete_at': scheduledDeleteAt?.toIso8601String(),
  };

  AnnouncementModel copyWith({
    int? likeCount,
    int? loveCount,
    int? insightfulCount,
    String? userReaction,
    int? commentCount,
  }) {
    return AnnouncementModel(
      id: id,
      title: title,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt,
      createdBy: createdBy,
      branchId: branchId,
      isGlobal: isGlobal,
      priority: priority,
      scheduledDeleteAt: scheduledDeleteAt,
      likeCount: likeCount ?? this.likeCount,
      loveCount: loveCount ?? this.loveCount,
      insightfulCount: insightfulCount ?? this.insightfulCount,
      userReaction: userReaction ?? this.userReaction,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}