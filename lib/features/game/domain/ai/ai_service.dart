import 'dart:math';

import 'package:chain_reaction/features/game/domain/ai/ai_strategy.dart';
import 'package:chain_reaction/features/game/domain/ai/strategies/extreme_strategy.dart';
import 'package:chain_reaction/features/game/domain/ai/strategies/greedy_strategy.dart';
import 'package:chain_reaction/features/game/domain/ai/strategies/random_strategy.dart';
import 'package:chain_reaction/features/game/domain/ai/strategies/strategic_strategy.dart';
import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/domain/logic/game_rules.dart';
import 'package:flutter/foundation.dart';

class AIComputeParams {
  AIComputeParams(this.state, this.player, this.rules);
  final GameState state;
  final Player player;
  final GameRules rules;
}

Future<Point<int>> _computeMove(AIComputeParams params) async {
  AIStrategy strategy;
  switch (params.player.difficulty) {
    case AIDifficulty.easy:
      strategy = RandomStrategy();
    case AIDifficulty.medium:
      strategy = GreedyStrategy();
    case AIDifficulty.hard:
      strategy = StrategicStrategy();
    case AIDifficulty.extreme:
      strategy = ExtremeStrategy(params.rules);
    default:
      strategy = GreedyStrategy();
  }

  try {
    return await strategy.getMove(params.state, params.player);
  } on Object {
    return RandomStrategy().getMove(params.state, params.player);
  }
}

class AIService {
  AIService(this._rules);
  final GameRules _rules;

  Future<Point<int>> getMove(GameState state, Player player) async {
    // Safety check: verify game is not over
    if (state.isGameOver) return const Point(0, 0);

    // Offload calculation to a background isolate
    return compute(_computeMove, AIComputeParams(state, player, _rules));
  }
}
