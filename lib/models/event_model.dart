class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final String? branchId;
  final bool isGlobal;
  final String? userStatus;
  final int goingCount;
  final int notGoingCount;
  final int interestedCount;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    this.branchId,
    this.isGlobal = false,
    this.userStatus,
    this.goingCount = 0,
    this.notGoingCount = 0,
    this.interestedCount = 0,
  });

  bool get isUpcoming => eventDate.isAfter(DateTime.now());

  factory EventModel.fromJson(
      Map<String, dynamic> json, {
        String? userStatus,
        int goingCount = 0,
        int notGoingCount = 0,
        int interestedCount = 0,
      }) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eventDate: DateTime.parse(json['event_date'] as String),
      location: json['location'] as String? ?? '',
      branchId: json['branch_id'] as String?,
      isGlobal: json['is_global'] as bool? ?? false,
      userStatus: userStatus,
      goingCount: goingCount,
      notGoingCount: notGoingCount,
      interestedCount: interestedCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'branch_id': branchId,
      'is_global': isGlobal,
    };
  }

  EventModel copyWith({
    String? userStatus,
    int? goingCount,
    int? notGoingCount,
    int? interestedCount,
  }) {
    return EventModel(
      id: id,
      title: title,
      description: description,
      eventDate: eventDate,
      location: location,
      branchId: branchId,
      isGlobal: isGlobal,
      userStatus: userStatus ?? this.userStatus,
      goingCount: goingCount ?? this.goingCount,
      notGoingCount: notGoingCount ?? this.notGoingCount,
      interestedCount: interestedCount ?? this.interestedCount,
    );
  }
}