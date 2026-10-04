import 'package:flutter/foundation.dart';

import '../core/supabase_client.dart';
import '../models/poll_model.dart';
import '../services/poll_service.dart';


class PollProvider extends ChangeNotifier {
  final PollService _service = PollService();

  List<PollModel> _polls = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, dynamic> _voteSubscriptions = {};

  List<PollModel> get polls => _polls;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  Future<void> loadPolls() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _polls = await _service.fetchPolls();
      _subscribeToVotes();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _subscribeToVotes() {
    for (final poll in _polls) {
      if (_voteSubscriptions.containsKey(poll.id)) continue;

      final subscription = _service.watchPollVotes(poll.id).listen((_) async {
        await _refreshPoll(poll.id);
      });
      _voteSubscriptions[poll.id] = subscription;
    }
  }

  Future<void> _refreshPoll(String pollId) async {
    try {
      final refreshedPolls = await _service.fetchPolls();
      _polls = refreshedPolls;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> vote({required String pollId, required String optionId}) async {
    final String? userId = SupabaseService.currentUserId;
    if (userId == null) {
      _errorMessage = 'You must be signed in to vote.';
      notifyListeners();
      return;
    }

    try {
      await _service.castVote(
        pollId: pollId,
        optionId: optionId,
        userId: userId,
      );
      await _refreshPoll(pollId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createPoll({
    required String question,
    required List<String> options,
    DateTime? expiresAt,
  }) async {
    try {
      await _service.createPollWithOptions(
        question: question,
        optionTexts: options,
        expiresAt: expiresAt,
      );
      await loadPolls();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    for (final subscription in _voteSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}