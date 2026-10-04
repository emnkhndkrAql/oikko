import 'package:flutter/foundation.dart';
import '../core/supabase_client.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _service = EventService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentBranchId;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEvents({String? branchId}) async {
    _currentBranchId = branchId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _service.fetchEvents(branchId: branchId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> respondToEvent({
    required String eventId,
    required String status,
  }) async {
    final String? userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      await _service.setEventResponse(
        eventId: eventId,
        userId: userId,
        status: status,
      );
      await loadEvents(branchId: _currentBranchId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
      await _service.createEvent(
        title: title,
        description: description,
        eventDate: eventDate,
        location: location,
        branchId: branchId,
        isGlobal: isGlobal,
      );
      await loadEvents(branchId: _currentBranchId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}