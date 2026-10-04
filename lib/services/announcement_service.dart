import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/announcement_comment_model.dart';
import '../models/announcement_model.dart';

class AnnouncementServiceException implements Exception {
  final String message;
  AnnouncementServiceException(this.message);
  @override
  String toString() => message;
}

class AnnouncementService {
  final _client = SupabaseService.client;

  Stream<List<AnnouncementModel>> watchAnnouncements() {
    return _client
        .from(AppConstants.tableAnnouncements)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(AnnouncementModel.fromJson).toList());
  }

  Future<List<AnnouncementModel>> fetchAnnouncementsWithMeta({
    String? branchId,
    String? currentUserId,
  }) async {
    try {
      var query = _client.from(AppConstants.tableAnnouncements).select();
      if (branchId != null) {
        query =
            query.or('branch_id.eq.$branchId,is_global.eq.true');
      }
      final List<Map<String, dynamic>> rows =
      await query.order('created_at', ascending: false);

      final List<AnnouncementModel> result = [];
      for (final row in rows) {
        final String id = row['id'] as String;

        // Reactions tally
        final reactions = await _client
            .from('announcement_reactions')
            .select()
            .eq('announcement_id', id);

        int likes = 0, loves = 0, insightful = 0;
        String? userReaction;
        for (final r in reactions) {
          switch (r['reaction'] as String) {
            case 'like':
              likes++;
              break;
            case 'love':
              loves++;
              break;
            case 'insightful':
              insightful++;
              break;
          }
          if (currentUserId != null && r['user_id'] == currentUserId) {
            userReaction = r['reaction'] as String;
          }
        }

        // Comment count
        final comments = await _client
            .from('announcement_comments')
            .select('id')
            .eq('announcement_id', id);

        result.add(AnnouncementModel.fromJson(row).copyWith(
          likeCount: likes,
          loveCount: loves,
          insightfulCount: insightful,
          userReaction: userReaction,
          commentCount: comments.length,
        ));
      }
      return result;
    } catch (e) {
      throw AnnouncementServiceException('Unable to load posts: $e');
    }
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    String? imageUrl,
    required String createdBy,
    String? branchId,
    bool isGlobal = false,
    String priority = 'normal',
    DateTime? scheduledDeleteAt,
  }) async {
    try {
      await _client.from(AppConstants.tableAnnouncements).insert({
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'created_by': createdBy,
        'branch_id': branchId,
        'is_global': isGlobal,
        'priority': priority,
        'scheduled_delete_at': scheduledDeleteAt?.toIso8601String(),
      });
    } catch (e) {
      throw AnnouncementServiceException('Unable to create post: $e');
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _client
          .from(AppConstants.tableAnnouncements)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw AnnouncementServiceException('Unable to delete post: $e');
    }
  }

  Future<void> scheduleDelete({
    required String id,
    required DateTime deleteAt,
  }) async {
    try {
      await _client
          .from(AppConstants.tableAnnouncements)
          .update({'scheduled_delete_at': deleteAt.toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw AnnouncementServiceException('Unable to schedule deletion: $e');
    }
  }

  Future<void> reactToPost({
    required String announcementId,
    required String userId,
    required String reaction,
  }) async {
    try {
      final existing = await _client
          .from('announcement_reactions')
          .select()
          .eq('announcement_id', announcementId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        if (existing['reaction'] == reaction) {
          // Same reaction — remove it (toggle off)
          await _client
              .from('announcement_reactions')
              .delete()
              .eq('id', existing['id'] as String);
        } else {
          // Different reaction — update it
          await _client
              .from('announcement_reactions')
              .update({'reaction': reaction})
              .eq('id', existing['id'] as String);
        }
      } else {
        await _client.from('announcement_reactions').insert({
          'announcement_id': announcementId,
          'user_id': userId,
          'reaction': reaction,
        });
      }
    } catch (e) {
      throw AnnouncementServiceException('Unable to react: $e');
    }
  }

  Future<List<AnnouncementCommentModel>> fetchComments(
      String announcementId) async {
    try {
      final data = await _client
          .from('announcement_comments')
          .select('*, profiles(full_name)')
          .eq('announcement_id', announcementId)
          .order('created_at', ascending: true);
      return data.map(AnnouncementCommentModel.fromJson).toList();
    } catch (e) {
      throw AnnouncementServiceException('Unable to load comments: $e');
    }
  }

  Future<void> addComment({
    required String announcementId,
    required String userId,
    required String content,
  }) async {
    try {
      await _client.from('announcement_comments').insert({
        'announcement_id': announcementId,
        'user_id': userId,
        'content': content,
      });
    } catch (e) {
      throw AnnouncementServiceException('Unable to post comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _client
          .from('announcement_comments')
          .delete()
          .eq('id', commentId);
    } catch (e) {
      throw AnnouncementServiceException('Unable to delete comment: $e');
    }
  }

  /// Auto-delete posts where scheduled_delete_at has passed
  Future<void> purgeExpiredPosts() async {
    try {
      await _client
          .from(AppConstants.tableAnnouncements)
          .delete()
          .not('scheduled_delete_at', 'is', null)
          .lt('scheduled_delete_at', DateTime.now().toIso8601String());
    } catch (_) {}
  }
}