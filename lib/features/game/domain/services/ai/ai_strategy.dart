import 'dart:math';
import '../../entities/game_state.dart';
import '../../entities/player.dart';

abstract class AIStrategy {
  Future<Point<int>> getMove(GameState state, Player player);

  /// Helper to get all valid moves for a player
  List<Point<int>> getValidMoves(GameState state, Player player) {
    final moves = <Point<int>>[];
    for (int y = 0; y < state.rows; y++) {
      for (int x = 0; x < state.cols; x++) {
        final cell = state.grid[y][x];
        if (cell.ownerId == null || cell.ownerId == player.id) {
          moves.add(Point(x, y));
        }
      }
    }
    return moves;
  }
}
