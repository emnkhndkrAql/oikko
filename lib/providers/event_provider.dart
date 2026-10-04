import 'package:flutter/foundation.dart';
import '../core/supabase_client.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _service = EventService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches the latest events from the service layer.
  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _service.fetchEvents();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new event and updates the local list.
  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime eventDate,
    required String location,
  }) async {
    _errorMessage = null;
    // Don't set full _isLoading = true here unless you want a full screen spinner,
    // as it would wipe out the existing list view state temporarily.

    try {
      await _service.createEvent(
        title: title,
        description: description,
        eventDate: eventDate,
        location: location,
      );
      // Fetch fresh data to ensure accurate ordering and IDs from DB
      await loadEvents();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Updates a user's RSVP status with instant Optimistic UI feedback.
  Future<void> respondToEvent({
    required String eventId,
    required String status,
  }) async {
    final String? userId = SupabaseService.currentUserId;
    if (userId == null) {
      _errorMessage = 'You must be signed in to respond.';
      notifyListeners();
      return;
    }

    _errorMessage = null;

    // --- OPTIMISTIC UPDATE BEGIN ---
    // Save a backup of the current state in case the network fails
    final List<EventModel> previousEvents = List.from(_events);

    // Locally modify the targeted event instantly
    _events = _events.map((event) {
      if (event.id != eventId) return event;

      // Adjust counts based on moving from previous status to new status
      int goingDiff = 0;
      int interestedDiff = 0;
      int notGoingDiff = 0;

      // Decrement old status count if it existed
      if (event.userStatus != null) {
        if (event.userStatus == 'going') goingDiff--;
        if (event.userStatus == 'interested') interestedDiff--;
        if (event.userStatus == 'not_going') notGoingDiff--;
      }

      // Increment new status count
      if (status == 'going') goingDiff++;
      if (status == 'interested') interestedDiff++;
      if (status == 'not_going') notGoingDiff++;

      // Return a copy of the event with updated metrics
      return event.copyWith(
        userStatus: status,
        goingCount: event.goingCount + goingDiff,
        interestedCount: event.interestedCount + interestedDiff,
        notGoingCount: event.notGoingCount + notGoingDiff,
      );
    }).toList();

    // Trigger instant UI re-render
    notifyListeners();
    // --- OPTIMISTIC UPDATE END ---

    try {
      // Make network call quietly in the background
      await _service.setEventResponse(
        eventId: eventId,
        userId: userId,
        status: status,
      );
    } catch (e) {
      // Revert back to original state if backend call fails
      _events = previousEvents;
      _errorMessage = 'Failed to update response: $e';
      notifyListeners();
    }
  }
}