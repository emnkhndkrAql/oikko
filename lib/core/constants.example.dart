/// Copy this file to constants.dart and fill in your values.
/// Never commit constants.dart to Git.
class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

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

  // Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleModerator = 'moderator';
  static const String roleMember = 'member';

  // Event response statuses
  static const String statusGoing = 'going';
  static const String statusNotGoing = 'not_going';
  static const String statusInterested = 'interested';
}