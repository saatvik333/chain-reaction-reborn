import 'dart:math';
import '../entities/game_state.dart';
import '../entities/player.dart';
import 'ai/ai_strategy.dart';
import 'ai/strategies/random_strategy.dart';
import 'ai/strategies/greedy_strategy.dart';
import 'ai/strategies/strategic_strategy.dart';
import 'ai/strategies/extreme_strategy.dart';

class AIService {
  final AIStrategy _randomStrategy = RandomStrategy();
  final AIStrategy _greedyStrategy = GreedyStrategy();
  final AIStrategy _strategicStrategy = StrategicStrategy();
  final AIStrategy _extremeStrategy = ExtremeStrategy();

  Future<Point<int>> getMove(GameState state, Player player) async {
    // Safety check: verify game is not over
    if (state.isGameOver) return const Point(0, 0);

    AIStrategy strategy;
    switch (player.difficulty) {
      case AIDifficulty.easy:
        strategy = _randomStrategy;
        break;
      case AIDifficulty.medium:
        strategy = _greedyStrategy;
        break;
      case AIDifficulty.hard:
        strategy = _strategicStrategy;
        break;
      case AIDifficulty.extreme:
        strategy = _extremeStrategy;
        break;
      default:
        strategy = _greedyStrategy;
    }

    try {
      return await strategy.getMove(state, player);
    } catch (e) {
      // Fallback to random move if strategy fails
      return await _randomStrategy.getMove(state, player);
    }
  }
}
