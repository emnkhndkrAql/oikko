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


  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    try {
      final List<Map<String, dynamic>> data = await _client
          .from(AppConstants.tableAnnouncements)
          .select()
          .order('created_at', ascending: false);

      return data.map(AnnouncementModel.fromJson).toList();
    } catch (e) {
      throw AnnouncementServiceException('Unable to load announcements: $e');
    }
  }

  Stream<List<AnnouncementModel>> watchAnnouncements() {
    return _client
        .from(AppConstants.tableAnnouncements)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(AnnouncementModel.fromJson).toList());
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    String? imageUrl,
    required String createdBy,
  }) async {
    try {
      await _client.from(AppConstants.tableAnnouncements).insert({
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'created_by': createdBy,
      });
    } catch (e) {
      throw AnnouncementServiceException('Unable to create post: $e');
    }
  }


  Future<void> deleteAnnouncement(String id) async {
    try {
      await _client.from(AppConstants.tableAnnouncements).delete().eq('id', id);
    } catch (e) {
      throw AnnouncementServiceException('Unable to delete post: $e');
    }
  }
}