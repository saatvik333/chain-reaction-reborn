import 'dart:math';
import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';

/// Service responsible for calculating AI moves
class AIEngine {
  final Random _random = Random();

  /// Calculates the best move based on the AI's difficulty level
  Future<Point<int>> getMove(GameState state, Player aiPlayer) async {
    // Artificial delay to make it feel like "thinking"
    await Future.delayed(const Duration(milliseconds: 600));

    final validMoves = _getValidMoves(state, aiPlayer);
    if (validMoves.isEmpty) {
      // Should not happen if game is not over
      return const Point(0, 0);
    }

    switch (aiPlayer.difficulty) {
      case AIDifficulty.easy:
        return _getRandomMove(validMoves);
      case AIDifficulty.medium:
        return _getGreedyMove(state, validMoves, aiPlayer);
      case AIDifficulty.hard:
        return _getSmartMove(state, validMoves, aiPlayer);
      default:
        return _getRandomMove(validMoves);
    }
  }

  List<Point<int>> _getValidMoves(GameState state, Player player) {
    final validMoves = <Point<int>>[];
    for (int x = 0; x < state.rows; x++) {
      for (int y = 0; y < state.cols; y++) {
        final cell = state.grid[x][y];
        if (cell.ownerId == null || cell.ownerId == player.id) {
          validMoves.add(Point(x, y));
        }
      }
    }
    return validMoves;
  }

  Point<int> _getRandomMove(List<Point<int>> validMoves) {
    return validMoves[_random.nextInt(validMoves.length)];
  }

  /// Greedy: Choose the move that adds an atom to the most promising spot
  /// Prioritizes cells that are about to explode (critical mass - 1)
  Point<int> _getGreedyMove(
    GameState state,
    List<Point<int>> validMoves,
    Player player,
  ) {
    // 1. Try to find a cell that will explode
    for (final move in validMoves) {
      final cell = state.grid[move.x][move.y];
      if (cell.atomCount == cell.capacity - 1) {
        return move;
      }
    }

    // 2. Otherwise pick randomly among valid moves, favoring owned cells
    final ownedMoves = validMoves.where((m) {
      return state.grid[m.x][m.y].ownerId == player.id;
    }).toList();

    if (ownedMoves.isNotEmpty && _random.nextBool()) {
      return ownedMoves[_random.nextInt(ownedMoves.length)];
    }

    return validMoves[_random.nextInt(validMoves.length)];
  }

  /// Smart: Prioritizes corners and edges, avoids putting atoms next to critical enemy cells
  Point<int> _getSmartMove(
    GameState state,
    List<Point<int>> validMoves,
    Player player,
  ) {
    // 1. Corner Strategy: Always take a corner if available and safe
    final corners = [
      const Point(0, 0),
      Point(0, state.cols - 1),
      Point(state.rows - 1, 0),
      Point(state.rows - 1, state.cols - 1),
    ];

    for (final corner in corners) {
      if (validMoves.contains(corner)) {
        // Simple safety check: don't take if neighbor is enemy critical
        if (_isSafe(state, corner, player)) {
          return corner;
        }
      }
    }

    // 2. Explosion Strategy: If we can explode, do it
    for (final move in validMoves) {
      final cell = state.grid[move.x][move.y];
      if (cell.atomCount == cell.capacity - 1) {
        return move;
      }
    }

    // 3. Fallback: Score based evaluation
    // Just a simple heuristic for now
    return _getGreedyMove(state, validMoves, player);
  }

  bool _isSafe(GameState state, Point<int> point, Player me) {
    final neighbors = _getNeighbors(state, point);
    for (final n in neighbors) {
      final cell = state.grid[n.x][n.y];
      if (cell.ownerId != null &&
          cell.ownerId != me.id &&
          cell.atomCount == cell.capacity - 1) {
        return false; // Neighbor is about to blow up on us
      }
    }
    return true;
  }

  List<Point<int>> _getNeighbors(GameState state, Point<int> p) {
    final neighbors = <Point<int>>[];
    if (p.x > 0) neighbors.add(Point(p.x - 1, p.y));
    if (p.x < state.rows - 1) neighbors.add(Point(p.x + 1, p.y));
    if (p.y > 0) neighbors.add(Point(p.x, p.y - 1));
    if (p.y < state.cols - 1) neighbors.add(Point(p.x, p.y + 1));
    return neighbors;
  }
}
