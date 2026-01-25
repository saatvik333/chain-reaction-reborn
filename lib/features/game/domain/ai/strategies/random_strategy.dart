import 'dart:math';
import '../ai_strategy.dart';
import '../../entities/game_state.dart';
import '../../entities/player.dart';

class RandomStrategy extends AIStrategy {
  final Random _random = Random();

  @override
  Future<Point<int>> getMove(GameState state, Player player) async {
    // Variable thinking time to feel more natural
    final thinkingTime = 300 + _random.nextInt(401); // 300 to 700ms
    await Future.delayed(Duration(milliseconds: thinkingTime));

    final validMoves = getValidMoves(state, player);
    if (validMoves.isEmpty) {
      // This should practically never happen if the game is checking game-over correctly.
      throw Exception('No valid moves available for AI');
    }
    return validMoves[_random.nextInt(validMoves.length)];
  }
}
