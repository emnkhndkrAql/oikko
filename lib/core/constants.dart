
class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'https://mtcxmsdjkvbtfpgeasuv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10Y3htc2Rqa3ZidGZwZ2Vhc3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyNjI1OTQsImV4cCI6MjA5NzgzODU5NH0.Yb0rbzZdTpxIpMS6dv6dPmXSLAUZmGjJQlHlrs15wPo';


  static const String tableProfiles = 'profiles';
  static const String tableAnnouncements = 'announcements';
  static const String tablePolls = 'polls';
  static const String tablePollOptions = 'poll_options';
  static const String tablePollVotes = 'poll_votes';
  static const String tableEvents = 'events';
  static const String tableEventResponses = 'event_responses';


  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';


  static const String statusGoing = 'going';
  static const String statusNotGoing = 'not_going';
  static const String statusInterested = 'interested';
}