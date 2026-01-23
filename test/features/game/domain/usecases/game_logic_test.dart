import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chain_reaction/features/game/domain/entities/cell.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:chain_reaction/features/game/domain/usecases/check_winner.dart';
import 'package:chain_reaction/features/game/domain/usecases/next_turn.dart';

void main() {
  final players = [
    const Player(id: 'p1', name: 'Player 1', color: Colors.blue),
    const Player(id: 'p2', name: 'Player 2', color: Colors.red),
  ];

  group('NextTurnUseCase', () {
    test('should rotate through players correctly', () {
      final nextTurn = const NextTurnUseCase();
      // Mock state: p1 active
      var state = GameState(
        grid: [],
        players: players,
        currentPlayerIndex: 0,
        turnCount: 0,
      );

      // p1 -> p2
      state = nextTurn(state);
      expect(state.currentPlayer.id, 'p2');
      expect(state.turnCount, 1);

      // p2 -> p1
      state = nextTurn(state);
      expect(state.currentPlayer.id, 'p1');
      expect(state.turnCount, 2);
    });

    test('should skip eliminated players', () {
      final nextTurn = const NextTurnUseCase();
      final p3 = const Player(id: 'p3', name: 'P3', color: Colors.green);
      final activePlayers = [...players, p3]; // p1, p2, p3

      // Create grid where p1 and p2 have cells, but p3 does not
      final grid = [
        [
          const Cell(x: 0, y: 0, capacity: 1, atomCount: 1, ownerId: 'p1'),
          const Cell(x: 1, y: 0, capacity: 1, atomCount: 1, ownerId: 'p2'),
        ],
      ];

      var state = GameState(
        grid: grid,
        players: activePlayers,
        currentPlayerIndex: 1, // Currently p2's turn
        turnCount: 10, // Late game (> player count)
      );

      // p2 -> p3 (no cells, eliminated) -> p1 (has cells)
      state = nextTurn(state);
      expect(state.currentPlayer.id, 'p1');
    });
  });

  group('CheckWinnerUseCase', () {
    test('should return null if multiple players have atoms', () {
      final checkWinner = const CheckWinnerUseCase();

      final grid = [
        [
          const Cell(x: 0, y: 0, capacity: 1, atomCount: 1, ownerId: 'p1'),
          const Cell(x: 1, y: 0, capacity: 1, atomCount: 1, ownerId: 'p2'),
        ],
      ];

      var state = GameState(
        grid: grid,
        players: players,
        currentPlayerIndex: 0,
        turnCount: 10,
      );

      expect(checkWinner(state), null);
    });
  });
}
