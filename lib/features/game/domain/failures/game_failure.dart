import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_failure.freezed.dart';

/// Typed game failures for domain-level error handling.
@freezed
sealed class GameFailure with _$GameFailure {
  // --- Online game creation/joining failures ---

  /// Room not found with the given code.
  const factory GameFailure.roomNotFound() = GameFailureRoomNotFound;

  /// Room is full (already has 2 players).
  const factory GameFailure.roomFull() = GameFailureRoomFull;

  /// Room has expired.
  const factory GameFailure.roomExpired() = GameFailureRoomExpired;

  /// Cannot join your own room.
  const factory GameFailure.cannotJoinOwnRoom() = GameFailureCannotJoinOwnRoom;

  // --- Authentication failures ---

  /// Authentication required to perform this action.
  const factory GameFailure.authRequired() = GameFailureAuthRequired;

  /// User is not a participant in this game.
  const factory GameFailure.notParticipant() = GameFailureNotParticipant;

  // --- Move validation failures ---

  /// It's not your turn.
  const factory GameFailure.notYourTurn() = GameFailureNotYourTurn;

  /// Invalid move (cell occupied by opponent, out of bounds, etc.).
  const factory GameFailure.invalidMove(String reason) = GameFailureInvalidMove;

  /// Game is not active (waiting, completed, or abandoned).
  const factory GameFailure.gameNotActive() = GameFailureGameNotActive;

  // --- Connection failures ---

  /// Network error.
  const factory GameFailure.network() = GameFailureNetwork;

  /// Realtime connection lost.
  const factory GameFailure.connectionLost() = GameFailureConnectionLost;

  /// Server error.
  const factory GameFailure.serverError(String message) =
      GameFailureServerError;

  /// Unknown error.
  const factory GameFailure.unknown(String message) = GameFailureUnknown;
}

/// Extension to get user-friendly messages from failures.
extension GameFailureMessage on GameFailure {
  String get message => switch (this) {
    GameFailureRoomNotFound() =>
      'Room not found. Check the code and try again.',
    GameFailureRoomFull() => 'This room is already full.',
    GameFailureRoomExpired() => 'This room has expired. Create a new game.',
    GameFailureCannotJoinOwnRoom() => 'You cannot join your own room.',
    GameFailureAuthRequired() => 'Please sign in to play online.',
    GameFailureNotParticipant() => 'You are not a participant in this game.',
    GameFailureNotYourTurn() => "It's not your turn.",
    GameFailureInvalidMove(:final reason) => 'Invalid move: $reason',
    GameFailureGameNotActive() => 'This game is no longer active.',
    GameFailureNetwork() => 'Network error. Check your connection.',
    GameFailureConnectionLost() => 'Connection lost. Reconnecting...',
    GameFailureServerError(:final message) => 'Server error: $message',
    GameFailureUnknown(:final message) => message,
  };
}
