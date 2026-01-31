import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/user_profile.dart';
import '../domain/failures/auth_failure.dart';

/// Repository for authentication operations with typed failures.
class AuthRepository {
  AuthRepository(this._supabase, this._googleSignIn);

  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

  /// Current user ID (null if not authenticated).
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Check if user is authenticated.
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Get the current session.
  Session? get currentSession => _supabase.auth.currentSession;

  /// Sign up with email and password.
  ///
  /// Throws [AuthFailure] on error.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
      return response;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  /// Sign in with email and password.
  ///
  /// Throws [AuthFailure] on error.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  /// Sign in with Google.
  ///
  /// Throws [AuthFailure] on error.
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure.cancelled();
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthFailure.unknown(
          'No ID token from Google. Check serverClientId configuration.',
        );
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  /// Sign out.
  ///
  /// Throws [AuthFailure] on error.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  /// Get user profile from database.
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      // Profile fetch failures are non-critical, return null
      return null;
    }
  }

  /// Update user profile.
  ///
  /// Throws [AuthFailure] on error.
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            if (displayName != null) 'display_name': displayName,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          })
          .eq('id', userId);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  /// Reset password.
  ///
  /// Throws [AuthFailure] on error.
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  // --- Private helper methods ---

  AuthFailure _mapAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    final code = e.code?.toLowerCase() ?? '';

    // Check for common error patterns
    if (message.contains('invalid login credentials') ||
        message.contains('invalid password') ||
        code == 'invalid_credentials') {
      return const AuthFailure.invalidCredentials();
    }

    if (message.contains('user not found') || code == 'user_not_found') {
      return const AuthFailure.userNotFound();
    }

    if (message.contains('email already registered') ||
        message.contains('user already registered') ||
        code == 'email_exists' ||
        code == 'user_already_exists') {
      return const AuthFailure.emailAlreadyExists();
    }

    if (message.contains('password') && message.contains('weak') ||
        code == 'weak_password') {
      return const AuthFailure.weakPassword();
    }

    if (message.contains('email not confirmed') ||
        code == 'email_not_confirmed') {
      return const AuthFailure.emailNotConfirmed();
    }

    if (message.contains('rate limit') || code == 'over_request_limit') {
      return const AuthFailure.rateLimited();
    }

    if (message.contains('session') && message.contains('expired') ||
        code == 'session_expired') {
      return const AuthFailure.sessionExpired();
    }

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return const AuthFailure.network();
    }

    // Fallback to unknown with the original message
    return AuthFailure.unknown(e.message);
  }
}
