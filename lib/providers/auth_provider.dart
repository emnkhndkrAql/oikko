import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';
import '../services/supabase_auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();

  AuthStatus _status = AuthStatus.unknown;
  ProfileModel? _profile;
  String? _errorMessage;

  AuthProvider() {
    _bootstrap();
  }

  AuthStatus get status => _status;
  ProfileModel? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _profile?.isAdmin ?? false;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> _bootstrap() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _loadProfile(currentUser.id);
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }

    _authService.authStateChanges.listen((state) async {
      final session = state.session;
      if (session == null) {
        _status = AuthStatus.unauthenticated;
        _profile = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadProfile(String userId) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();
      _profile = await _authService.fetchProfile(userId);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // নতুন আপডেট করা signUp মেথড (role প্যারামিটারসহ)
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'member',
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _profile = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}