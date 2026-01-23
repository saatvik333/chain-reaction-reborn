import '../entities/entities.dart';

/// Use case for checking game win conditions.
class CheckWinnerUseCase {
  const CheckWinnerUseCase();

  /// Checks if there's a winner in the current game state.
  ///
  /// Returns the winning player, or null if no winner yet.
  Player? call(GameState state) {
    if (state.isGameOver) return state.winner;

    final ownersOnBoard = state.activeOwnerIds;

    // No winner during early game (first round of moves)
    if (state.turnCount <= state.players.length) return null;

    // Single owner remaining = winner
    if (ownersOnBoard.length == 1) {
      final winnerId = ownersOnBoard.first;
      return state.players.firstWhere((p) => p.id == winnerId);
    }

    return null;
  }

  /// Checks if the game should end.
  bool isGameOver(GameState state) {
    return call(state) != null;
  }
}
