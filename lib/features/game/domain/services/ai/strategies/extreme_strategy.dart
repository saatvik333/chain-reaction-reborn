import 'dart:math';
import '../ai_strategy.dart';
import '../../../entities/game_state.dart';
import '../../../entities/player.dart';
import '../../../entities/cell.dart';

/// An "Extreme" AI that uses Minimax (Depth 2) to look ahead.
/// It simulates its own move, and then anticipates the opponent's best counter-move.
class ExtremeStrategy extends AIStrategy {
  final Random _random = Random();

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

    // Pruning/Optimization:
    // If there are too many moves, full Minimax might be slow.
    // However, for Chain Reaction grid sizes (usually small) and endgame (fewer moves), it's okay.
    // In early game, moves are many, but simulation is fast (no chains).
    // In late game, moves are few, but chains are long.

    for (final move in validMoves) {
      // 1. Simulate AI Move
      final stateAfterAi = _simulateMove(state, move, player);

      // Check for immediate win
      if (_isWin(stateAfterAi, player)) {
        return move; // Instant win, take it!
      }

      // 2. Minimax Step: Anticipate Opponent's Best Response
      // The opponent wants to MINIMIZE my score.
      double minOpponentScore = double.infinity;

      // Determine next player (opponent)
      // Note: _simulateMove returns a state but doesn't fully advance turn logic
      // (like cycling indices). We need to infer the opponent.
      // For 2-player, it's just the other player. For N-player, it's the next valid player.
      // Simplifying expectation: Assume next active player is the threat.
      final opponent = _getNextPlayer(stateAfterAi, player);

      if (opponent != null) {
        final opponentMoves = getValidMoves(stateAfterAi, opponent);

        if (opponentMoves.isEmpty) {
          // Opponent has no moves? I probably won or they are eliminated.
          // If I didn't detect win above, check elimination.
          minOpponentScore = 1000.0; // Good for me
        } else {
          // Heuristic: If too many opponent moves, sample or filter?
          // For Extreme, we try to be thorough.
          for (final oppMove in opponentMoves) {
            final stateAfterOpp = _simulateMove(
              stateAfterAi,
              oppMove,
              opponent,
            );

            // If opponent wins here, this is a distinct possibility.
            // We want to avoid paths where opponent CAN win.
            if (_isWin(stateAfterOpp, opponent)) {
              minOpponentScore = double.negativeInfinity; // Terrible for me
              break; // Theory: Opponent will find this win, so this AI move is bad.
            }

            // Evaluate board state from MY perspective
            final score = _evaluateState(stateAfterOpp, player);
            if (score < minOpponentScore) {
              minOpponentScore = score;
            }
          }
        }
      } else {
        // No opponent? I won.
        minOpponentScore = 10000.0;
      }

      // 3. Select Max of Min
      // Add small jitter to break ties
      final jitter = _random.nextDouble();
      final totalScore = minOpponentScore + jitter;

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
    // Find the next active player in the cyclic turn order
    final startIdx = state.players.indexWhere((p) => p.id == current.id);
    if (startIdx == -1) return null; // Should not happen

    final count = state.players.length;
    for (int i = 1; i < count; i++) {
      final nextIdx = (startIdx + i) % count;
      final p = state.players[nextIdx];
      // A player is active if they have cells or if it's the very start (everyone has 0)
      if (state.cellCountForPlayer(p.id) > 0) {
        return p;
      }
    }
    return null;
  }

  double _evaluateState(GameState state, Player player) {
    if (_isWin(state, player)) return 10000.0;

    // Check if I lost (am eliminated)
    final myCount = state.cellCountForPlayer(player.id);
    if (myCount == 0) return double.negativeInfinity;

    double score = 0;
    int myAtoms = 0;
    int enemyAtoms = 0;
    int myCells = 0;
    int enemyCells = 0;
    int myThreats = 0; // My cells ready to explode

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
    score += (myCells - enemyCells) * 5.0; // Cells are safer than atoms
    score += myThreats * 1.0;

    return score;
  }

  GameState _simulateMove(GameState state, Point<int> move, Player player) {
    // Uses the same simulation logic as StrategicStrategy
    // Code duplicated for independence (or we could extract a shared Simulator)

    var grid = state.grid.map((row) => List<Cell>.from(row)).toList();
    final queue = <Point<int>>[];

    var cell = grid[move.y][move.x];
    grid[move.y][move.x] = cell.copyWith(
      atomCount: cell.atomCount + 1,
      ownerId: player.id,
    );

    if (grid[move.y][move.x].isAtCriticalMass) {
      queue.add(move);
    }

    int safetyCounter = 0;
    while (queue.isNotEmpty && safetyCounter < 2000) {
      safetyCounter++;
      final p = queue.removeAt(0);
      final cx = p.x;
      final cy = p.y;

      if (!grid[cy][cx].isAtCriticalMass) continue;

      final neighbors = _getNeighbors(
        grid,
        state.rows,
        state.cols,
        Point(cx, cy),
      );

      final currentCell = grid[cy][cx];
      grid[cy][cx] = currentCell.copyWith(
        atomCount: currentCell.atomCount - neighbors.length,
        clearOwner: (currentCell.atomCount - neighbors.length) <= 0,
      );

      for (final n in neighbors) {
        final neighbor = grid[n.y][n.x];
        final nextAtomCount = neighbor.atomCount + 1;
        grid[n.y][n.x] = neighbor.copyWith(
          atomCount: nextAtomCount,
          ownerId: player.id,
        );

        if (grid[n.y][n.x].isAtCriticalMass) {
          queue.add(n);
        }
      }
    }

    // Return partial state with updated grid
    return state.copyWith(grid: grid);
  }

  List<Point<int>> _getNeighbors(
    List<List<Cell>> grid,
    int rows,
    int cols,
    Point<int> p,
  ) {
    final neighbors = <Point<int>>[];
    if (p.x > 0) neighbors.add(Point(p.x - 1, p.y));
    if (p.x < cols - 1) neighbors.add(Point(p.x + 1, p.y));
    if (p.y > 0) neighbors.add(Point(p.x, p.y - 1));
    if (p.y < rows - 1) neighbors.add(Point(p.x, p.y + 1));
    return neighbors;
  }
}
