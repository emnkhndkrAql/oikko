import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service_db.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationDbService _service = NotificationDbService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription<List<NotificationModel>>? _subscription;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void startListening(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription = _service.watchNotifications(userId).listen(
          (updated) {
        _notifications = updated;
        _unreadCount = updated.where((n) => !n.isRead).length;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
    } catch (_) {}
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _service.markAllAsRead(userId);
    } catch (_) {}
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}