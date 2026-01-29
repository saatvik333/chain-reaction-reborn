import 'dart:math';
import '../ai_strategy.dart';
import '../../logic/game_rules.dart';
import '../../entities/game_state.dart';
import '../../entities/player.dart';
import '../../entities/cell.dart';

/// An "Extreme" AI that uses Minimax (Depth 2) to look ahead.
/// It simulates its own move, and then anticipates the opponent's best counter-move.
class ExtremeStrategy extends AIStrategy {
  final Random _random = Random();
  final GameRules _rules;

  ExtremeStrategy(this._rules);

  @override
  Future<Point<int>> getMove(GameState state, Player player) async {
    // Variable thinking time to feel more natural
    final thinkingTime = 300 + _random.nextInt(401); // 300 to 700ms
    await Future.delayed(Duration(milliseconds: thinkingTime));

    final validMoves = getValidMoves(state, player);
    if (validMoves.isEmpty) throw Exception('No valid moves');

    // If only one move, just take it (early exit)
    if (validMoves.length == 1) return validMoves.first;

    Point<int>? bestMove;
    double maxScore = double.negativeInfinity;

    // 22% chance to have a "lapse" and fail to look ahead (Depth 1 only)
    // This simulates human error and allows players to win more often
    final bool isLapse = _random.nextDouble() < 0.22;

    for (final move in validMoves) {
      // 1. Simulate AI Move
      final stateAfterAi = _simulateMove(state, move, player);

      // Check for immediate win (Always take these, even if lapsing)
      if (_isWin(stateAfterAi, player)) {
        return move; // Instant win, take it!
      }

      double moveScore;

      if (isLapse) {
        // Short-sighted: Just evaluate the board after my move (Depth 1)
        moveScore = _evaluateState(stateAfterAi, player);
      } else {
        // 2. Minimax Step: Anticipate Opponent's Best Response
        double minOpponentScore = double.infinity;
        final opponent = _getNextPlayer(stateAfterAi, player);

        if (opponent != null) {
          final opponentMoves = getValidMoves(stateAfterAi, opponent);

          if (opponentMoves.isEmpty) {
            minOpponentScore = 1000.0; // Good for me
          } else {
            for (final oppMove in opponentMoves) {
              final stateAfterOpp = _simulateMove(
                stateAfterAi,
                oppMove,
                opponent,
              );

              if (_isWin(stateAfterOpp, opponent)) {
                minOpponentScore = double.negativeInfinity;
                break;
              }

              final score = _evaluateState(stateAfterOpp, player);
              if (score < minOpponentScore) {
                minOpponentScore = score;
              }
            }
          }
        } else {
          minOpponentScore = 10000.0;
        }
        moveScore = minOpponentScore;
      }

      final jitter = _random.nextDouble();
      final totalScore = moveScore + jitter;

      if (totalScore > maxScore) {
        maxScore = totalScore;
        bestMove = move;
      }
    }

    return bestMove ?? validMoves[_random.nextInt(validMoves.length)];
  }

  // --- Helpers ---

  bool _isWin(GameState state, Player player) {
    return state.activeOwnerIds.length == 1 &&
        state.activeOwnerIds.first == player.id;
  }

  Player? _getNextPlayer(GameState state, Player current) {
    final startIdx = state.players.indexWhere((p) => p.id == current.id);
    if (startIdx == -1) return null;

    final count = state.players.length;
    for (int i = 1; i < count; i++) {
      final nextIdx = (startIdx + i) % count;
      final p = state.players[nextIdx];
      if (state.cellCountForPlayer(p.id) > 0) {
        return p;
      }
    }
    return null;
  }

  double _evaluateState(GameState state, Player player) {
    if (_isWin(state, player)) return 10000.0;

    final myCount = state.cellCountForPlayer(player.id);
    if (myCount == 0) return double.negativeInfinity;

    double score = 0;
    int myAtoms = 0;
    int enemyAtoms = 0;
    int myCells = 0;
    int enemyCells = 0;
    int myThreats = 0;

    for (var row in state.grid) {
      for (var cell in row) {
        if (cell.ownerId == player.id) {
          myAtoms += cell.atomCount;
          myCells++;
          if (cell.atomCount == cell.capacity) myThreats++;
        } else if (cell.ownerId != null) {
          enemyAtoms += cell.atomCount;
          enemyCells++;
        }
      }
    }

    score += (myAtoms - enemyAtoms) * 2.0;
    score += (myCells - enemyCells) * 5.0;
    score += myThreats * 1.0;

    return score;
  }

  /// Simulates a move using GameRules.
  /// This logic is now consistent with the UI game engine.
  GameState _simulateMove(GameState state, Point<int> move, Player player) {
    var grid = state.grid.map((row) => List<Cell>.from(row)).toList();
    final queue = <Cell>[];

    // Apply initial move
    var cell = grid[move.y][move.x];
    grid[move.y][move.x] = cell.copyWith(
      atomCount: cell.atomCount + 1,
      ownerId: player.id,
    );

    if (grid[move.y][move.x].isAtCriticalMass) {
      queue.add(grid[move.y][move.x]);
    }

    int safetyCounter = 0;
    // Process entire chain reaction synchronously
    while (queue.isNotEmpty && safetyCounter < 2000) {
      safetyCounter++;
      final explodingCell = queue.removeAt(0);

      // Re-fetch because it might have changed in a previous step (though in queue logic usually we process specific snapshot)
      // Actually, we must fetch from grid to get current state
      final currentCell = grid[explodingCell.y][explodingCell.x];
      if (!currentCell.isAtCriticalMass) continue;

      final result = _rules.processExplosion(
        grid: grid,
        explodingCell: currentCell,
        playerId: player.id,
      );

      // queue.addAll(result.newlyCriticalCells);
      // We need to be careful not to add duplicates if using a simple List
      // But standard BFS/queue is fine.
      for (final newCrit in result.newlyCriticalCells) {
        queue.add(newCrit);
      }
    }

    return state.copyWith(grid: grid);
  }
}
