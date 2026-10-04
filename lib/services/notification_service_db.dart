import 'dart:async';
import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/notification_model.dart';

class NotificationDbException implements Exception {
  final String message;
  NotificationDbException(this.message);
  @override
  String toString() => message;
}

class NotificationDbService {
  final _client = SupabaseService.client;

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _client
        .from(AppConstants.tableNotifications)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(NotificationModel.fromJson).toList());
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableNotifications)
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);
      return data.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from(AppConstants.tableNotifications)
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      throw NotificationDbException('Unable to mark as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from(AppConstants.tableNotifications)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw NotificationDbException('Unable to mark all as read: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? branchId,
    String? relatedId,
  }) async {
    try {
      await _client.from(AppConstants.tableNotifications).insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'branch_id': branchId,
        'related_id': relatedId,
        'is_read': false,
      });
    } catch (e) {
      throw NotificationDbException('Unable to create notification: $e');
    }
  }
}