
class EventResponseModel {
  final String id;
  final String eventId;
  final String userId;
  final String status; // 'going' | 'not_going' | 'interested'

  const EventResponseModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
  });

  factory EventResponseModel.fromJson(Map<String, dynamic> json) {
    return EventResponseModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String? ?? 'interested',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': status,
    };
  }
}