/// Copy this file to constants.dart and fill in your Supabase values.
/// Never commit constants.dart to Git — it contains secrets.
class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'https://mtcxmsdjkvbtfpgeasuv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10Y3htc2Rqa3ZidGZwZ2Vhc3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyNjI1OTQsImV4cCI6MjA5NzgzODU5NH0.Yb0rbzZdTpxIpMS6dv6dPmXSLAUZmGjJQlHlrs15wPo';

  // Table names
  static const String tableProfiles = 'profiles';
  static const String tableAnnouncements = 'announcements';
  static const String tablePolls = 'polls';
  static const String tablePollOptions = 'poll_options';
  static const String tablePollVotes = 'poll_votes';
  static const String tableEvents = 'events';
  static const String tableEventResponses = 'event_responses';
  static const String tableBranches = 'branches';
  static const String tableNotifications = 'notifications';
  static const String tableProfilePrivate = 'profile_private';
  static const String tableAnalytics = 'branch_analytics_cache';

  // Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleModerator = 'moderator';
  static const String roleMember = 'member';

  // Event response statuses
  static const String statusGoing = 'going';
  static const String statusNotGoing = 'not_going';
  static const String statusInterested = 'interested';

  // Announcement priorities
  static const String priorityNormal = 'normal';
  static const String priorityHigh = 'high';
  static const String priorityEmergency = 'emergency';

  // Notification types
  static const String notifAnnouncement = 'announcement';
  static const String notifPoll = 'poll';
  static const String notifEvent = 'event';
  static const String notifGeneral = 'general';
  static const String notifSystem = 'system';
}