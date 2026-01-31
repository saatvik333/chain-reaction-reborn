import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/domain/entities/online/online_game_state.dart';

/// Arguments required to navigate to the Game screen.
class GameRouteArgs {
  final int? playerCount;
  final String? gridSize;
  final AIDifficulty? aiDifficulty;
  final bool isResuming;
  final String? mode;
  final OnlineGameState? onlineGameState;

  const GameRouteArgs({
    this.playerCount,
    this.gridSize,
    this.aiDifficulty,
    this.isResuming = false,
    this.mode,
    this.onlineGameState,
  });
}

/// Arguments required to navigate to the Winner screen.
class WinnerRouteArgs {
  final int winnerPlayerIndex;
  final int totalMoves;
  final String gameDuration;
  final int territoryPercentage;
  final int playerCount;
  final String gridSize;
  final AIDifficulty? aiDifficulty;

  const WinnerRouteArgs({
    required this.winnerPlayerIndex,
    required this.totalMoves,
    required this.gameDuration,
    required this.territoryPercentage,
    required this.playerCount,
    required this.gridSize,
    this.aiDifficulty,
  });
}
