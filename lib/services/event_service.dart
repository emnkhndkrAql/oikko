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

  Future<List<EventModel>> fetchEvents({String? branchId}) async {
    try {
      var query = _client.from(AppConstants.tableEvents).select();

      if (branchId != null) {
        // DDBMS: local branch events + global events (horizontal fragment union)
        query = query.or('branch_id.eq.$branchId,is_global.eq.true');
      }

      final List<Map<String, dynamic>> eventRows =
      await query.order('event_date', ascending: true);

      final String? currentUserId = SupabaseService.currentUserId;
      final List<EventModel> events = [];

      for (final eventRow in eventRows) {
        final String eventId = eventRow['id'] as String;
        final List<Map<String, dynamic>> responseRows = await _client
            .from(AppConstants.tableEventResponses)
            .select()
            .eq('event_id', eventId);

        int going = 0, notGoing = 0, interested = 0;
        String? userStatus;

        for (final r in responseRows) {
          final status = r['status'] as String;
          if (status == AppConstants.statusGoing) going++;
          if (status == AppConstants.statusNotGoing) notGoing++;
          if (status == AppConstants.statusInterested) interested++;
          if (currentUserId != null && r['user_id'] == currentUserId) {
            userStatus = status;
          }
        }

        events.add(EventModel.fromJson(
          eventRow,
          userStatus: userStatus,
          goingCount: going,
          notGoingCount: notGoing,
          interestedCount: interested,
        ));
      }
      return events;
    } catch (e) {
      throw EventServiceException('Unable to load events: $e');
    }
  }

  Future<void> setEventResponse({
    required String eventId,
    required String userId,
    required String status,
  }) async {
    try {
      await _client.from(AppConstants.tableEventResponses).upsert(
        {'event_id': eventId, 'user_id': userId, 'status': status},
        onConflict: 'event_id,user_id',
      );
    } catch (e) {
      throw EventServiceException('Unable to update response: $e');
    }
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime eventDate,
    required String location,
    String? branchId,
    bool isGlobal = false,
  }) async {
    try {
      await _client.from(AppConstants.tableEvents).insert({
        'title': title,
        'description': description,
        'event_date': eventDate.toIso8601String(),
        'location': location,
        'branch_id': branchId,
        'is_global': isGlobal,
      });
    } catch (e) {
      throw EventServiceException('Unable to create event: $e');
    }
  }
}