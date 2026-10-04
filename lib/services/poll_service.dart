import 'dart:async';

import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/poll_model.dart';
import '../models/poll_option_model.dart';


class PollServiceException implements Exception {
  final String message;
  PollServiceException(this.message);

  @override
  String toString() => message;
}


class PollService {
  final _client = SupabaseService.client;

  /// Fetches all polls, each enriched with its options, current vote
  /// tallies, and whether the current user has already voted.
  Future<List<PollModel>> fetchPolls() async {
    try {
      final List<Map<String, dynamic>> pollRows = await _client
          .from(AppConstants.tablePolls)
          .select()
          .order('created_at', ascending: false);

      final List<PollModel> polls = [];
      for (final pollRow in pollRows) {
        final poll = await _hydratePoll(pollRow);
        polls.add(poll);
      }
      return polls;
    } catch (e) {
      throw PollServiceException('Unable to load polls: $e');
    }
  }

  Future<PollModel> _hydratePoll(Map<String, dynamic> pollRow) async {
    final String pollId = pollRow['id'] as String;
    final String? currentUserId = SupabaseService.currentUserId;

    final List<Map<String, dynamic>> optionRows = await _client
        .from(AppConstants.tablePollOptions)
        .select()
        .eq('poll_id', pollId);

    final List<Map<String, dynamic>> voteRows = await _client
        .from(AppConstants.tablePollVotes)
        .select()
        .eq('poll_id', pollId);

    final Map<String, int> tally = {};
    String? userVotedOptionId;
    for (final voteRow in voteRows) {
      final optionId = voteRow['option_id'] as String;
      tally[optionId] = (tally[optionId] ?? 0) + 1;
      if (currentUserId != null && voteRow['user_id'] == currentUserId) {
        userVotedOptionId = optionId;
      }
    }

    final List<PollOptionModel> options = optionRows.map((row) {
      final option = PollOptionModel.fromJson(row);
      return option.copyWith(voteCount: tally[option.id] ?? 0);
    }).toList();

    return PollModel.fromJson(
      pollRow,
      options: options,
      userVotedOptionId: userVotedOptionId,
    );
  }


  Stream<List<Map<String, dynamic>>> watchPollVotes(String pollId) {
    return _client
        .from(AppConstants.tablePollVotes)
        .stream(primaryKey: ['id'])
        .eq('poll_id', pollId);
  }


  Future<void> castVote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    try {
      final List<Map<String, dynamic>> existing = await _client
          .from(AppConstants.tablePollVotes)
          .select('id')
          .eq('poll_id', pollId)
          .eq('user_id', userId)
          .limit(1);

      if (existing.isNotEmpty) {
        throw PollServiceException('You have already voted on this poll.');
      }

      await _client.from(AppConstants.tablePollVotes).insert({
        'poll_id': pollId,
        'option_id': optionId,
        'user_id': userId,
      });
    } on PollServiceException {
      rethrow;
    } catch (e) {
      throw PollServiceException('Unable to cast vote: $e');
    }
  }


  Future<void> createPollWithOptions({
    required String question,
    required List<String> optionTexts,
    DateTime? expiresAt,
  }) async {
    final cleanedOptions =
    optionTexts.map((o) => o.trim()).where((o) => o.isNotEmpty).toList();

    if (cleanedOptions.length < 2) {
      throw PollServiceException('A poll needs at least two options.');
    }

    String? insertedPollId;
    try {
      final Map<String, dynamic> pollRow = await _client
          .from(AppConstants.tablePolls)
          .insert({
        'question': question.trim(),
        'expires_at': expiresAt?.toIso8601String(),
      })
          .select()
          .single();

      insertedPollId = pollRow['id'] as String;

      final List<Map<String, dynamic>> optionPayload = cleanedOptions
          .map((text) => {
        'poll_id': insertedPollId,
        'option_text': text,
      })
          .toList();

      await _client.from(AppConstants.tablePollOptions).insert(optionPayload);
    } catch (e) {

      if (insertedPollId != null) {
        await _client
            .from(AppConstants.tablePolls)
            .delete()
            .eq('id', insertedPollId);
      }
      throw PollServiceException('Unable to create poll: $e');
    }
  }
}