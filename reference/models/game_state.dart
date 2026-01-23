import 'cell.dart';
import 'player.dart';

class GameState {
  final List<List<Cell>> grid;
  final List<Player> players;
  final int currentPlayerIndex;
  final bool isGameOver;
  final Player? winner;

  // Track if we are currently processing explosions to block input
  final bool isProcessing;
  final int turnCount;

  const GameState({
    required this.grid,
    required this.players,
    this.currentPlayerIndex = 0,
    this.isGameOver = false,
    this.winner,
    this.isProcessing = false,
    this.turnCount = 0,
  });

  Player get currentPlayer => players[currentPlayerIndex];

  GameState copyWith({
    List<List<Cell>>? grid,
    List<Player>? players,
    int? currentPlayerIndex,
    bool? isGameOver,
    Player? winner,
    bool? isProcessing,
    int? turnCount,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner ?? this.winner,
      isProcessing: isProcessing ?? this.isProcessing,
      turnCount: turnCount ?? this.turnCount,
    );
  }
}
