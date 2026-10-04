import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/announcement_model.dart';

class AnnouncementServiceException implements Exception {
  final String message;
  AnnouncementServiceException(this.message);
  @override
  String toString() => message;
}

class AnnouncementService {
  final _client = SupabaseService.client;

  Stream<List<AnnouncementModel>> watchAnnouncements({String? branchId}) {
    var query = _client
        .from(AppConstants.tableAnnouncements)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
    return query.map((rows) => rows.map(AnnouncementModel.fromJson).toList());
  }

  Future<List<AnnouncementModel>> fetchAnnouncements({
    String? branchId,
  }) async {
    try {
      var query = _client
          .from(AppConstants.tableAnnouncements)
          .select();

      if (branchId != null) {
        // DDBMS: fetch local branch + global announcements (partial replication)
        query = query.or('branch_id.eq.$branchId,is_global.eq.true');
      }

      final List<Map<String, dynamic>> data =
      await query.order('created_at', ascending: false);
      return data.map(AnnouncementModel.fromJson).toList();
    } catch (e) {
      throw AnnouncementServiceException('Unable to load announcements: $e');
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
}