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

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AnnouncementProvider() {
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

        _announcements = updated;
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
  }) async {
    try {
      await _service.createAnnouncement(
        title: title,
        content: content,
        imageUrl: imageUrl,
        createdBy: createdBy,
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