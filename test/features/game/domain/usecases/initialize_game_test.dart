import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/domain/usecases/initialize_game.dart';
import 'package:chain_reaction/features/game/domain/logic/game_rules.dart';

void main() {
  late InitializeGameUseCase initializeGame;
  late GameRules rules;

  setUp(() {
    rules = const GameRules();
    initializeGame = InitializeGameUseCase(rules);
  });

  const players = [
    Player(id: 'p1', name: 'Player 1', color: Colors.blue),
    Player(id: 'p2', name: 'Player 2', color: Colors.red),
  ];

  group('InitializeGameUseCase', () {
    test(
      'should initialize game with correct grid dimensions for Small size',
      () {
        final state = initializeGame(players, gridSize: 'small');

        expect(state.rows, 8);
        expect(state.cols, 5);
        expect(state.players, players);
        expect(state.currentPlayer, players[0]);
        expect(state.turnCount, 0);
        expect(state.isProcessing, false);
        expect(state.isGameOver, false);
      },
    );

    test(
      'should initialize game with correct cell capacities (corners, edges, center)',
      () {
        final state = initializeGame(players, rows: 6, cols: 6);

        // Corner
        expect(state.grid[0][0].capacity, 1);

        // Edge
        expect(state.grid[0][1].capacity, 2);

        // Center
        expect(state.grid[1][1].capacity, 3);
      },
    );

    test('should return all cells empty initially', () {
      final state = initializeGame(players, gridSize: 'small');

      for (var row in state.grid) {
        for (var cell in row) {
          expect(cell.atomCount, 0);
          expect(cell.ownerId, null);
        }
      }
    });

    test('should support custom rows and cols', () {
      final state = initializeGame(players, rows: 10, cols: 10);

      expect(state.rows, 10);
      expect(state.cols, 10);
    });
  });
}
