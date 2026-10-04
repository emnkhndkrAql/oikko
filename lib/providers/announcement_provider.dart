import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/supabase_client.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../services/notification_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  final AnnouncementService _service = AnnouncementService();

  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentBranchId;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AnnouncementProvider() {
    _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    await _fetchWithMeta();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchWithMeta() async {
    try {
      final userId = SupabaseService.currentUserId;
      final results = await _service.fetchAnnouncementsWithMeta(
        branchId: _currentBranchId,
        currentUserId: userId,
      );
      // Auto-purge expired scheduled deletions
      await _service.purgeExpiredPosts();
      _announcements = results
          .where((a) =>
      a.scheduledDeleteAt == null ||
          a.scheduledDeleteAt!.isAfter(DateTime.now()))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await _fetchWithMeta();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> react({
    required String announcementId,
    required String reaction,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    try {
      await _service.reactToPost(
        announcementId: announcementId,
        userId: userId,
        reaction: reaction,
      );
      await _fetchWithMeta();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
      await _service.createAnnouncement(
        title: title,
        content: content,
        imageUrl: imageUrl,
        createdBy: createdBy,
        branchId: branchId,
        isGlobal: isGlobal,
        priority: priority,
        scheduledDeleteAt: scheduledDeleteAt,
      );
      NotificationService.instance.notifyNewAnnouncement(title);
      await refresh();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _service.deleteAnnouncement(id);
      await refresh();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}