import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth_repository.dart';
import '../../domain/entities/app_auth_state.dart';

part 'auth_provider.g.dart';

/// Supabase client provider
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Google Sign-In provider
@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) {
  return GoogleSignIn(scopes: ['email', 'profile']);
}

/// Auth repository provider
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(googleSignInProvider),
  );
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
      await repo.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
      // Auth state listener will update state
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
    } catch (e) {
      state = AppAuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      state = const AppAuthState.unauthenticated();
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
