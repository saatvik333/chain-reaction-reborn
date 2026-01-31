import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

/// Typed authentication failures for domain-level error handling.
@freezed
sealed class AuthFailure with _$AuthFailure {
  /// User cancelled the sign-in process (e.g., closed Google popup).
  const factory AuthFailure.cancelled() = AuthFailureCancelled;

  /// Invalid email or password during sign-in.
  const factory AuthFailure.invalidCredentials() =
      AuthFailureInvalidCredentials;

  /// User account not found.
  const factory AuthFailure.userNotFound() = AuthFailureUserNotFound;

  /// Email already registered.
  const factory AuthFailure.emailAlreadyExists() =
      AuthFailureEmailAlreadyExists;

  /// Weak password (doesn't meet requirements).
  const factory AuthFailure.weakPassword() = AuthFailureWeakPassword;

  /// Network error (no internet, timeout, etc.).
  const factory AuthFailure.network() = AuthFailureNetwork;

  /// Session expired, requires re-authentication.
  const factory AuthFailure.sessionExpired() = AuthFailureSessionExpired;

  /// Email confirmation required before sign-in.
  const factory AuthFailure.emailNotConfirmed() = AuthFailureEmailNotConfirmed;

  /// Rate limited by the server.
  const factory AuthFailure.rateLimited() = AuthFailureRateLimited;

  /// Unknown/unexpected error.
  const factory AuthFailure.unknown(String message) = AuthFailureUnknown;
}

/// Extension to get user-friendly messages from failures.
extension AuthFailureMessage on AuthFailure {
  String get message => switch (this) {
    AuthFailureCancelled() => 'Sign-in was cancelled.',
    AuthFailureInvalidCredentials() =>
      'Invalid email or password. Please try again.',
    AuthFailureUserNotFound() => 'No account found with this email.',
    AuthFailureEmailAlreadyExists() =>
      'This email is already registered. Try signing in instead.',
    AuthFailureWeakPassword() =>
      'Password is too weak. Use at least 6 characters.',
    AuthFailureNetwork() =>
      'Network error. Check your connection and try again.',
    AuthFailureSessionExpired() =>
      'Your session has expired. Please sign in again.',
    AuthFailureEmailNotConfirmed() =>
      'Please check your email and confirm your account.',
    AuthFailureRateLimited() => 'Too many attempts. Please wait and try again.',
    AuthFailureUnknown(:final message) => message,
  };
}
