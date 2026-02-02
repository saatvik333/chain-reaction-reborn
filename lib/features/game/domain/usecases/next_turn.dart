import 'package:chain_reaction/features/game/domain/entities/entities.dart';

/// Use case for advancing to the next player's turn.
class NextTurnUseCase {
  const NextTurnUseCase();

  /// Advances the game to the next player's turn.
  ///
  /// Handles player elimination and win conditions.
  GameState call(GameState state) {
    final nextTurnCount = state.turnCount + 1;

    // Get active owners on the board
    final ownersOnBoard = state.activeOwnerIds;

    // Winner check: Only one owner remains after initial turns
    if (ownersOnBoard.length == 1 && nextTurnCount > state.players.length) {
      final winnerId = ownersOnBoard.first;
      return state.copyWith(
        winner: state.players.firstWhere((p) => p.id == winnerId),
        isGameOver: true,
        isProcessing: false,
        turnCount: nextTurnCount,
        endTime: DateTime.now(),
      );
    }

    // Find next valid player
    final playersCount = state.players.length;
    var nextIndex = (state.currentPlayerIndex + 1) % playersCount;
    var loops = 0;

    while (loops < playersCount) {
      final candidate = state.players[nextIndex];

      // Player is alive if they have atoms OR it's early game
      final isAlive =
          ownersOnBoard.contains(candidate.id) ||
          (nextTurnCount <= playersCount);

      if (isAlive) {
        return state.copyWith(
          currentPlayerIndex: nextIndex,
          turnCount: nextTurnCount,
          isProcessing: false,
        );
      }

      nextIndex = (nextIndex + 1) % playersCount;
      loops++;
    }

    // Fallback: game over
    return state.copyWith(
      isGameOver: true,
      winner: state.players[state.currentPlayerIndex],
      isProcessing: false,
      endTime: DateTime.now(),
    );
  }
}
