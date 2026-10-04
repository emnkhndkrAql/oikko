import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'announcement':
        return Icons.campaign_outlined;
      case 'poll':
        return Icons.poll_outlined;
      case 'event':
        return Icons.event_outlined;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type, BuildContext context) {
    switch (type) {
      case 'announcement':
        return Theme.of(context).colorScheme.primary;
      case 'poll':
        return Colors.orange;
      case 'event':
        return Colors.green;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.notifications.isEmpty) {
          return const Center(
            child: Text(
              'No notifications yet.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            if (provider.unreadCount > 0)
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.unreadCount} unread',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        if (profile != null) {
                          provider.markAllAsRead(profile.id);
                        }
                      },
                      child: const Text('Mark all as read'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notif = provider.notifications[index];
                  return _NotificationCard(
                    notification: notif,
                    iconData: _iconForType(notif.type),
                    color: _colorForType(notif.type, context),
                    onTap: () => provider.markAsRead(notif.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final IconData iconData;
  final Color color;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.iconData,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d · h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.grey[100] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: color.withOpacity(0.4), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(iconData, color: color, size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
            notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(notification.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : CircleAvatar(
          radius: 5,
          backgroundColor: color,
        ),
      ),
    );
  }
}