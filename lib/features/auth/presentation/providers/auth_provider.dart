import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chain_reaction/core/services/supabase/supabase_provider.dart';
import '../../data/auth_repository.dart';
import '../../domain/entities/app_auth_state.dart';
import '../../domain/failures/auth_failure.dart';

part 'auth_provider.g.dart';

/// Google Sign-In provider
@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) {
  // For Supabase, serverClientId MUST be the Web Client ID on Android.
  // This is because the backend (Supabase) needs to verify the token using the Web ID's audience.
  final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

  // Providing the Android client ID is also good practice for some platform-specific flows.
  final androidClientId = dotenv.env['GOOGLE_ANDROID_CLIENT_ID'];

  return GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: webClientId,
    clientId: androidClientId,
  );
}

/// Auth repository provider
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(googleSignInProvider),
  );
}

/// Auth mode provider (true = login, false = signup)
@riverpod
class AuthMode extends _$AuthMode {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

/// Auth state notifier
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AppAuthState build() {
    _listenToAuthChanges();
    return _getInitialState();
  }

  AppAuthState _getInitialState() {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user != null) {
      return AppAuthState.authenticated(
        userId: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );
    }
    return const AppAuthState.unauthenticated();
  }

  void _listenToAuthChanges() {
    final supabase = ref.read(supabaseClientProvider);
    supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        state = AppAuthState.authenticated(
          userId: user.id,
          email: user.email ?? '',
          displayName: user.userMetadata?['full_name'] as String?,
          avatarUrl: user.userMetadata?['avatar_url'] as String?,
        );
      } else {
        state = const AppAuthState.unauthenticated();
      }
    });
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    state = const AppAuthState.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );

      if (response.session == null && response.user != null) {
        state = const AppAuthState.error(
          'Confirmation email sent. Please check your inbox.',
        );
      }
      // Otherwise, the Auth state listener will update state if session is valid
    } on AuthFailure catch (e) {
      state = AppAuthState.error(e.message);
    } catch (e) {
      state = AppAuthState.error(e.toString());
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AppAuthState.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithEmail(email: email, password: password);
      // Auth state listener will update state
    } on AuthFailure catch (e) {
      state = AppAuthState.error(e.message);
    } catch (e) {
      state = AppAuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AppAuthState.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle();
      // Auth state listener will update state
    } on AuthFailure catch (e) {
      // Cancelled sign-in should just return to unauthenticated, not show error
      if (e is AuthFailureCancelled) {
        state = const AppAuthState.unauthenticated();
      } else {
        state = AppAuthState.error(e.message);
      }
    } catch (e) {
      state = AppAuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      state = const AppAuthState.unauthenticated();
    } on AuthFailure catch (e) {
      state = AppAuthState.error(e.message);
    } catch (e) {
      state = AppAuthState.error(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AppAuthState.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(email);
      state = const AppAuthState.unauthenticated();
    } on AuthFailure catch (e) {
      state = AppAuthState.error(e.message);
    } catch (e) {
      state = AppAuthState.error(e.toString());
    }
  }

  void clearError() {
    if (state is AppAuthStateError) {
      state = const AppAuthState.unauthenticated();
    }
  }
}
