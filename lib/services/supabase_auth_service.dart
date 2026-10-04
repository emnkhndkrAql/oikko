import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/profile_model.dart';

class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => message;
}

class SupabaseAuthService {
  final SupabaseClient _client = SupabaseService.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<ProfileModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = response.user;
      if (user == null) {
        throw AuthServiceException('Sign in failed. Please try again.');
      }

      return await fetchProfile(user.id);
    } on AuthException catch (e) {
      throw AuthServiceException(e.message);
    } catch (e) {
      throw AuthServiceException('Unable to sign in: $e');
    }
  }

  Future<ProfileModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String role = AppConstants.roleMember,
  }) async {
    try {

      final AuthResponse response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName, 'role': role},
      );

      final User? user = response.user;
      if (user == null) {
        throw AuthServiceException('Sign up failed. Please try again.');
      }

      return ProfileModel(
        id: user.id,
        email: email.trim(),
        fullName: fullName,
        role: role,
        isVerified: false,
      );
    } on AuthException catch (e) {
      throw AuthServiceException(e.message);
    } catch (e) {
      throw AuthServiceException('Unable to sign up: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthServiceException(e.message);
    } catch (e) {
      throw AuthServiceException('Unable to sign out: $e');
    }
  }

  Future<ProfileModel> fetchProfile(String userId) async {
    try {
      final Map<String, dynamic> data = await _client
          .from(AppConstants.tableProfiles)
          .select()
          .eq('id', userId)
          .single();
      return ProfileModel.fromJson(data);
    } catch (e) {
      throw AuthServiceException('Unable to load profile: $e');
    }
  }
}