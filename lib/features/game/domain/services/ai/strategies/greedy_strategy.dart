import 'dart:math';
import '../ai_strategy.dart';
import '../../../entities/game_state.dart';
import '../../../entities/player.dart';

class GreedyStrategy extends AIStrategy {
  final Random _random = Random();

  @override
  Future<Point<int>> getMove(GameState state, Player player) async {
    // Variable thinking time to feel more natural
    final thinkingTime = 300 + _random.nextInt(401); // 300 to 700ms
    await Future.delayed(Duration(milliseconds: thinkingTime));
    final validMoves = getValidMoves(state, player);
    if (validMoves.isEmpty) throw Exception('No valid moves');

    // 1. Critical Attack: If a move causes an explosion, do it.
    // Bonus: If it explodes AND captures neighbors, that's even better, but pure Greedy just loves explosions.
    final explodingMoves = validMoves.where((move) {
      final cell = state.grid[move.y][move.x];
      return cell.atomCount == cell.capacity - 1;
    }).toList();

    if (explodingMoves.isNotEmpty) {
      return explodingMoves[_random.nextInt(explodingMoves.length)];
    }

    // 2. Safe Moves: Filter out moves that are adjacent to critical ENEMY cells.
    // We don't want to place an atom next to an enemy that is about to explode,
    // because they will likely just steal our atom on their turn.
    final safeMoves = validMoves.where((move) {
      return !_isNextToCriticalEnemy(state, move, player);
    }).toList();

    // If all moves are dangerous, we just have to pick one from all valid moves.
    final candidateMoves = safeMoves.isNotEmpty ? safeMoves : validMoves;

    // 3. Reinforcement: Prefer adding to our own existing cells to reach critical mass faster.
    final reinforcementMoves = candidateMoves.where((m) {
      return state.grid[m.y][m.x].ownerId == player.id;
    }).toList();

    if (reinforcementMoves.isNotEmpty) {
      return reinforcementMoves[_random.nextInt(reinforcementMoves.length)];
    }

    // 4. Fallback: Random safe move (or random unsafemove if no choice)
    return candidateMoves[_random.nextInt(candidateMoves.length)];
  }

  bool _isNextToCriticalEnemy(GameState state, Point<int> move, Player player) {
    // Check neighbors
    // Note: We need neighbor logic here. Simple check.
    final neighbors = <Point<int>>[];
    if (move.x > 0) neighbors.add(Point(move.x - 1, move.y));
    if (move.x < state.cols - 1) neighbors.add(Point(move.x + 1, move.y));
    if (move.y > 0) neighbors.add(Point(move.x, move.y - 1));
    if (move.y < state.rows - 1) neighbors.add(Point(move.x, move.y + 1));

    for (final n in neighbors) {
      final cell = state.grid[n.y][n.x];
      if (cell.ownerId != null &&
          cell.ownerId != player.id &&
          cell.atomCount == cell.capacity) {
        return true;
      }
    }
    return false;
  }
}
