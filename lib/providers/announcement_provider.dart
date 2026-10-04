import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../services/notification_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  final AnnouncementService _service = AnnouncementService();

  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<AnnouncementModel>>? _subscription;
  String? _currentBranchId;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AnnouncementProvider() {
    _subscribeToFeed();
  }

  void filterByBranch(String? branchId) {
    _currentBranchId = branchId;
    _subscription?.cancel();
    _subscribeToFeed();
  }

  void _subscribeToFeed() {
    _isLoading = true;
    notifyListeners();

    _subscription = _service.watchAnnouncements().listen(
          (updated) {
        final bool isNewPost = updated.isNotEmpty &&
            (_announcements.isEmpty ||
                updated.first.id != _announcements.first.id);

        // DDBMS: filter by branch locally after fetching
        if (_currentBranchId != null) {
          _announcements = updated
              .where((a) =>
          a.branchId == _currentBranchId ||
              a.isGlobal ||
              a.isEmergency)
              .toList();
        } else {
          _announcements = updated;
        }

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();

        if (isNewPost && _announcements.isNotEmpty) {
          NotificationService.instance
              .notifyNewAnnouncement(_announcements.first.title);
        }
      },
      onError: (e) {
        _errorMessage = 'Unable to load announcements: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
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
      await _service.createAnnouncement(
        title: title,
        content: content,
        imageUrl: imageUrl,
        createdBy: createdBy,
        branchId: branchId,
        isGlobal: isGlobal,
        priority: priority,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _service.deleteAnnouncement(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}