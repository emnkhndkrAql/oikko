import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/app_theme.dart';
import '../../models/announcement_model.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/announcement_service.dart';
import '../../models/announcement_comment_model.dart';
import '../../core/supabase_client.dart';

class AnnouncementFeedScreen extends StatefulWidget {
  const AnnouncementFeedScreen({super.key});

  @override
  State<AnnouncementFeedScreen> createState() =>
      _AnnouncementFeedScreenState();
}

class _AnnouncementFeedScreenState extends State<AnnouncementFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.announcements.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.announcements.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.campaign_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'No posts yet',
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          color: AppTheme.primary,
          child: ListView.separated(
            itemCount: provider.announcements.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 8, color: AppTheme.background),
            itemBuilder: (context, index) {
              return _PostCard(announcement: provider.announcements[index]);
            },
          ),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final AnnouncementModel announcement;

  const _PostCard({required this.announcement});

  Color _priorityColor() {
    switch (announcement.priority) {
      case 'emergency':
        return AppTheme.emergency;
      case 'high':
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;
    final isAdmin = authProvider.isAdmin;

    return Container(
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency/High banner
          if (announcement.priority != 'normal')
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: _priorityColor().withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    announcement.isEmergency
                        ? Icons.warning_rounded
                        : Icons.priority_high_rounded,
                    size: 16,
                    color: _priorityColor(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    announcement.isEmergency ? 'EMERGENCY' : 'HIGH PRIORITY',
                    style: TextStyle(
                      color: _priorityColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Header: avatar + name + time + menu
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primaryLight,
                  child: const Icon(Icons.groups_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Oikko Club',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        timeago.format(announcement.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (announcement.isGlobal)
                        const Text(
                          '🌐 Global',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (isAdmin)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz,
                        color: AppTheme.textSecondary),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text(
                                'Are you sure you want to delete this post?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          context
                              .read<AnnouncementProvider>()
                              .deleteAnnouncement(announcement.id);
                        }
                      } else if (value == 'schedule_delete') {
                        _showScheduleDeleteDialog(context);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'schedule_delete',
                        child: Row(children: [
                          Icon(Icons.timer_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Schedule Delete'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Now',
                              style: TextStyle(color: Colors.red)),
                        ]),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              announcement.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          // Image
          if (announcement.imageUrl != null &&
              announcement.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.network(
                announcement.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          // Deletion timer
          if (announcement.isDeletionScheduled &&
              announcement.timeUntilDeletion != null &&
              announcement.timeUntilDeletion! > Duration.zero)
            _DeletionTimerBanner(announcement: announcement),

          // Reaction counts
          if (announcement.likeCount > 0 ||
              announcement.loveCount > 0 ||
              announcement.insightfulCount > 0)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (announcement.likeCount > 0)
                    _ReactionCount('👍', announcement.likeCount),
                  if (announcement.loveCount > 0)
                    _ReactionCount('❤️', announcement.loveCount),
                  if (announcement.insightfulCount > 0)
                    _ReactionCount('💡', announcement.insightfulCount),
                  const Spacer(),
                  if (announcement.commentCount > 0)
                    Text(
                      '${announcement.commentCount} comment${announcement.commentCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                ],
              ),
            ),

          const Divider(),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _ReactionButton(
                  announcement: announcement,
                  userId: profile?.id ?? '',
                ),
                const SizedBox(width: 4),
                _CommentButton(announcement: announcement),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _showScheduleDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ScheduleDeleteDialog(
          announcementId: announcement.id),
    );
  }
}

class _ReactionCount extends StatelessWidget {
  final String emoji;
  final int count;

  const _ReactionCount(this.emoji, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 2),
          Text('$count',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final AnnouncementModel announcement;
  final String userId;

  const _ReactionButton(
      {required this.announcement, required this.userId});

  String get _label {
    switch (announcement.userReaction) {
      case 'like':
        return '👍 Like';
      case 'love':
        return '❤️ Love';
      case 'insightful':
        return '💡 Insightful';
      default:
        return '👍 Like';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReacted = announcement.userReaction != null;

    return Expanded(
      child: GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => _ReactionPicker(
              announcementId: announcement.id,
              userId: userId,
            ),
          );
        },
        child: TextButton.icon(
          onPressed: () {
            context.read<AnnouncementProvider>().react(
              announcementId: announcement.id,
              reaction: announcement.userReaction ?? 'like',
            );
          },
          icon: Text(
            hasReacted
                ? (announcement.userReaction == 'like'
                ? '👍'
                : announcement.userReaction == 'love'
                ? '❤️'
                : '💡')
                : '👍',
            style: const TextStyle(fontSize: 16),
          ),
          label: Text(
            _label,
            style: TextStyle(
              color: hasReacted ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight:
              hasReacted ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionPicker extends StatelessWidget {
  final String announcementId;
  final String userId;

  const _ReactionPicker(
      {required this.announcementId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('React to this post',
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _reactionOption(context, '👍', 'like', 'Like'),
                _reactionOption(context, '❤️', 'love', 'Love'),
                _reactionOption(context, '💡', 'insightful', 'Insightful'),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _reactionOption(
      BuildContext context, String emoji, String type, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context
            .read<AnnouncementProvider>()
            .react(announcementId: announcementId, reaction: type);
      },
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _CommentButton extends StatelessWidget {
  final AnnouncementModel announcement;

  const _CommentButton({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) =>
                _CommentSheet(announcement: announcement),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline,
            size: 18, color: AppTheme.textSecondary),
        label: const Text(
          'Comment',
          style:
          TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final AnnouncementModel announcement;

  const _CommentSheet({required this.announcement});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _controller = TextEditingController();
  final _service = AnnouncementService();
  List<AnnouncementCommentModel> _comments = [];
  bool _loading = true;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      _comments =
      await _service.fetchComments(widget.announcement.id);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _postComment() async {
    if (_controller.text.trim().isEmpty) return;
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    setState(() => _posting = true);
    try {
      await _service.addComment(
        announcementId: widget.announcement.id,
        userId: userId,
        content: _controller.text.trim(),
      );
      _controller.clear();
      await _loadComments();
      if (context.mounted) {
        context.read<AnnouncementProvider>().refresh();
      }
    } catch (_) {}
    setState(() => _posting = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Comments (${_comments.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                  ? const Center(
                child: Text('No comments yet. Be the first!',
                    style: TextStyle(
                        color: AppTheme.textSecondary)),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return _CommentTile(
                    comment: _comments[index],
                    onDelete: () async {
                      await _service.deleteComment(
                          _comments[index].id);
                      await _loadComments();
                      if (context.mounted) {
                        context
                            .read<AnnouncementProvider>()
                            .refresh();
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(Icons.person,
                        size: 18, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: const TextStyle(
                            color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                          const BorderSide(color: AppTheme.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                          const BorderSide(color: AppTheme.divider),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: AppTheme.background,
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _posting
                      ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: AppTheme.primary),
                    onPressed: _postComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final AnnouncementCommentModel comment;
  final VoidCallback onDelete;

  const _CommentTile(
      {required this.comment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.currentUserId;
    final isAdmin =
        context.read<AuthProvider>().isAdmin;
    final canDelete =
        currentUserId == comment.userId || isAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryLight,
            child: Text(
              (comment.authorName?.isNotEmpty == true)
                  ? comment.authorName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName ?? 'Member',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(comment.content,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(comment.createdAt),
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 16, color: Colors.redAccent),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _DeletionTimerBanner extends StatefulWidget {
  final AnnouncementModel announcement;

  const _DeletionTimerBanner({required this.announcement});

  @override
  State<_DeletionTimerBanner> createState() =>
      _DeletionTimerBannerState();
}

class _DeletionTimerBannerState extends State<_DeletionTimerBanner> {
  late Duration _remaining;
  late final _ticker =
  Stream.periodic(const Duration(seconds: 1)).listen((_) {
    if (!mounted) return;
    setState(() {
      final diff = widget.announcement.scheduledDeleteAt!
          .difference(DateTime.now());
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  });

  @override
  void initState() {
    super.initState();
    _remaining = widget.announcement.timeUntilDeletion ?? Duration.zero;
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined,
              size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            'Deletes in ${_format(_remaining)}',
            style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ScheduleDeleteDialog extends StatefulWidget {
  final String announcementId;

  const _ScheduleDeleteDialog({required this.announcementId});

  @override
  State<_ScheduleDeleteDialog> createState() =>
      _ScheduleDeleteDialogState();
}

class _ScheduleDeleteDialogState extends State<_ScheduleDeleteDialog> {
  int _hours = 24;
  bool _submitting = false;
  final _service = AnnouncementService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Delete this post after:'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () =>
                    setState(() => _hours = (_hours - 1).clamp(1, 168)),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_hours hours',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () =>
                    setState(() => _hours = (_hours + 1).clamp(1, 168)),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Text(
            'Deletes at: ${DateFormat('MMM d, h:mm a').format(DateTime.now().add(Duration(hours: _hours)))}',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting
              ? null
              : () async {
            setState(() => _submitting = true);
            try {
              await _service.scheduleDelete(
                id: widget.announcementId,
                deleteAt: DateTime.now()
                    .add(Duration(hours: _hours)),
              );
              if (context.mounted) {
                Navigator.pop(context);
                context
                    .read<AnnouncementProvider>()
                    .refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                    Text('Post will be deleted in $_hours hours'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } catch (_) {}
            setState(() => _submitting = false);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}