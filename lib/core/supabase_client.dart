import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';


class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;


  static Future<void> initialize() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _initialized = true;
  }


  static SupabaseClient get client => Supabase.instance.client;


  static User? get currentUser => client.auth.currentUser;

  static String? get currentUserId => client.auth.currentUser?.id;
}