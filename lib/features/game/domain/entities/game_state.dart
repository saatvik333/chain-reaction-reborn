import 'package:flutter/foundation.dart';
import 'cell.dart';
import 'player.dart';
import 'flying_atom.dart';

/// Represents the complete state of a game session.
///
/// GameState is immutable; use [copyWith] to derive new states.
@immutable
class GameState {
  final List<List<Cell>> grid;
  final List<Player> players;
  final List<FlyingAtom> flyingAtoms;
  final int currentPlayerIndex;
  final bool isGameOver;
  final Player? winner;

  /// Flag to block input during chain explosions.
  final bool isProcessing;

  /// Number of turns elapsed.
  final int turnCount;

  /// Total number of moves made by all players.
  final int totalMoves;

  /// When the game started (for duration calculation).
  final DateTime startTime;

  /// When the game ended (for duration calculation).
  final DateTime? endTime;

  GameState({
    required this.grid,
    required this.players,
    this.flyingAtoms = const [],
    this.currentPlayerIndex = 0,
    this.isGameOver = false,
    this.winner,
    this.isProcessing = false,
    this.turnCount = 0,
    this.totalMoves = 0,
    DateTime? startTime,
    this.endTime,
  }) : startTime = startTime ?? DateTime.now();

  /// The player whose turn it currently is.
  Player get currentPlayer => players[currentPlayerIndex];

  /// Number of rows in the grid.
  int get rows => grid.length;

  /// Number of columns in the grid.
  int get cols => grid.isNotEmpty ? grid[0].length : 0;

  /// Total cells in the grid.
  int get totalCells => rows * cols;

  /// Get the number of cells owned by a specific player.
  int cellCountForPlayer(String playerId) {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.ownerId == playerId) count++;
      }
    }
    return count;
  }

  /// Get cells owned by the winner.
  int get winnerCellCount {
    if (winner == null) return 0;
    return cellCountForPlayer(winner!.id);
  }

  /// Territory percentage for the winner.
  int get territoryPercentage {
    if (totalCells == 0) return 0;
    return ((winnerCellCount / totalCells) * 100).round();
  }

  /// Get all unique owner IDs currently on the board.
  Set<String> get activeOwnerIds {
    final owners = <String>{};
    for (var row in grid) {
      for (var cell in row) {
        if (cell.ownerId != null) {
          owners.add(cell.ownerId!);
        }
      }
    }
    return owners;
  }

  /// Game duration.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Formatted duration string (MM:SS).
  String get formattedDuration {
    final d = duration;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Creates a copy of this state with optional modifications.
  GameState copyWith({
    List<List<Cell>>? grid,
    List<Player>? players,
    List<FlyingAtom>? flyingAtoms,
    int? currentPlayerIndex,
    bool? isGameOver,
    Player? winner,
    bool? isProcessing,
    int? turnCount,
    int? totalMoves,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      players: players ?? this.players,
      flyingAtoms: flyingAtoms ?? this.flyingAtoms,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner ?? this.winner,
      isProcessing: isProcessing ?? this.isProcessing,
      turnCount: turnCount ?? this.turnCount,
      totalMoves: totalMoves ?? this.totalMoves,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() =>
      'GameState(turn: $turnCount, player: ${currentPlayer.name}, gameOver: $isGameOver, flying: ${flyingAtoms.length})';
}
