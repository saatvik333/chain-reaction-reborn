import 'package:freezed_annotation/freezed_annotation.dart';

part 'start_game_result.freezed.dart';

/// Result type for game start operations.
///
/// Uses sealed class pattern for exhaustive pattern matching.
@freezed
sealed class StartGameResult with _$StartGameResult {
  /// Game started successfully, navigate to lobby/game.
  const factory StartGameResult.success() = StartGameResultSuccess;

  /// User is not authenticated, navigate to auth screen.
  const factory StartGameResult.requiresAuth() = StartGameResultRequiresAuth;

  /// Room code is invalid (for join operations).
  const factory StartGameResult.invalidCode() = StartGameResultInvalidCode;
}
