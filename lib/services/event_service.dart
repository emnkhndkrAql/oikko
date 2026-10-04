import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/event_model.dart';

class EventServiceException implements Exception {
  final String message;
  EventServiceException(this.message);

  @override
  String toString() => message;
}

class EventService {
  final _client = SupabaseService.client;

  /// Creates a new event. Used by the admin dashboard.
  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime eventDate,
    required String location,
  }) async {
    try {
      await _client.from(AppConstants.tableEvents).insert({
        'title': title,
        'description': description,
        'event_date': eventDate.toIso8601String(),
        'location': location,
      });
    } catch (e) {
      throw EventServiceException('Unable to create event: $e');
    }
  }

  /// Fetches all events along with their user responses in a single query.
  Future<List<EventModel>> fetchEvents() async {
    try {
      // 1. Fetch events and join their responses in a single network request
      final List<Map<String, dynamic>> eventRows = await _client
          .from(AppConstants.tableEvents)
          .select('*, ${AppConstants.tableEventResponses}(*)')
          .order('event_date', ascending: true);

      final String? currentUserId = SupabaseService.currentUserId;

      // 2. Map the results synchronously in memory
      return eventRows.map((eventRow) {
        // Extract the nested responses array safely
        final List<dynamic> responseRows = eventRow[AppConstants.tableEventResponses] as List<dynamic>? ?? [];

        int going = 0;
        int notGoing = 0;
        int interested = 0;
        String? userStatus;

        for (final response in responseRows) {
          final status = response['status'] as String;
          final userId = response['user_id'] as String;

          switch (status) {
            case AppConstants.statusGoing:
              going++;
              break;
            case AppConstants.statusNotGoing:
              notGoing++;
              break;
            case AppConstants.statusInterested:
              interested++;
              break;
          }

          if (currentUserId != null && userId == currentUserId) {
            userStatus = status;
          }
        }

        return EventModel.fromJson(
          eventRow,
          userStatus: userStatus,
          goingCount: going,
          notGoingCount: notGoing,
          interestedCount: interested,
        );
      }).toList();

    } catch (e) {
      throw EventServiceException('Unable to load events: $e');
    }
  }

  /// Updates or inserts a user response for a specific event.
  Future<void> setEventResponse({
    required String eventId,
    required String userId,
    required String status,
  }) async {
    try {
      await _client.from(AppConstants.tableEventResponses).upsert(
        {
          'event_id': eventId,
          'user_id': userId,
          'status': status,
        },
        onConflict: 'event_id,user_id',
      );
    } catch (e) {
      throw EventServiceException('Unable to update your response: $e');
    }
  }
}