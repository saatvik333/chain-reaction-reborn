import 'dart:math';
import 'package:flutter/foundation.dart';
import '../entities/game_state.dart';
import '../entities/player.dart';
import '../logic/game_rules.dart';
import 'ai/ai_strategy.dart';
import 'ai/strategies/random_strategy.dart';
import 'ai/strategies/greedy_strategy.dart';
import 'ai/strategies/strategic_strategy.dart';
import 'ai/strategies/extreme_strategy.dart';

class AIComputeParams {
  final GameState state;
  final Player player;
  final GameRules rules;

  AIComputeParams(this.state, this.player, this.rules);
}

Future<Point<int>> _computeMove(AIComputeParams params) async {
  AIStrategy strategy;
  switch (params.player.difficulty) {
    case AIDifficulty.easy:
      strategy = RandomStrategy();
      break;
    case AIDifficulty.medium:
      strategy = GreedyStrategy();
      break;
    case AIDifficulty.hard:
      strategy = StrategicStrategy();
      break;
    case AIDifficulty.extreme:
      strategy = ExtremeStrategy(params.rules);
      break;
    default:
      strategy = GreedyStrategy();
  }

  try {
    return await strategy.getMove(params.state, params.player);
  } catch (e) {
    return await RandomStrategy().getMove(params.state, params.player);
  }
}

class AIService {
  final GameRules _rules;

  AIService(this._rules);

  Future<Point<int>> getMove(GameState state, Player player) async {
    // Safety check: verify game is not over
    if (state.isGameOver) return const Point(0, 0);

    // Offload calculation to a background isolate
    return await compute(
      _computeMove,
      AIComputeParams(state, player, _rules),
    );
  }
}
