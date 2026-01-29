import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_profile.dart';

part 'app_auth_state.freezed.dart';

/// Authentication state for the app.
@freezed
sealed class AppAuthState with _$AppAuthState {
  const factory AppAuthState.initial() = AppAuthStateInitial;
  const factory AppAuthState.loading() = AppAuthStateLoading;
  const factory AppAuthState.authenticated({
    required String userId,
    required String email,
    String? displayName,
    String? avatarUrl,
    UserProfile? profile,
  }) = AppAuthStateAuthenticated;
  const factory AppAuthState.unauthenticated() = AppAuthStateUnauthenticated;
  const factory AppAuthState.error(String message) = AppAuthStateError;
}
