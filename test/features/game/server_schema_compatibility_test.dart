import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Server Schema Compatibility Tests', () {
    test('Client should correctly parse Server GameState JSON', () {
      // This JSON mimics EXACTLY what the new `game_engine.ts` sends
      final serverJson = {
        'grid': [
          [
            {'x': 0, 'y': 0, 'atomCount': 1, 'ownerId': 'p1', 'capacity': 2},
            {'x': 1, 'y': 0, 'atomCount': 0, 'ownerId': null, 'capacity': 3},
          ],
        ],
        'players': [
          {
            'id': 'p1',
            'name': 'Player 1',
            'color': 4294198070, // 0xFFE57373
            'type': 'human',
            'difficulty': null,
          },
        ],
        'flyingAtoms': [],
        'currentPlayerIndex': 0,
        'isGameOver': false,
        'winner': null,
        'isProcessing': false,
        'turnCount': 5,
        'totalMoves': 10,
        'startTime': '2023-10-27T10:00:00.000Z',
        'endTime': null,
      };

      // Attempt to parse
      final gameState = GameState.fromJson(serverJson);

      // Verify fields
      expect(gameState.turnCount, 5);
      expect(gameState.totalMoves, 10);
      expect(gameState.players.first.color, const Color(0xFFF44336));
      expect(gameState.startTime.year, 2023);
      expect(gameState.grid.length, 1);
      expect(gameState.grid[0][0].atomCount, 1);
    });

    test('Client should correctly parse Server GameState JSON with Winner', () {
      // This JSON mimics EXACTLY what the new `game_engine.ts` sends
      final serverJson = {
        'grid': [],
        'players': [
          {
            'id': 'p1',
            'name': 'Player 1',
            'color': 4294198070, // 0xFFE57373
            'type': 'human',
            'difficulty': null,
          },
        ],
        'flyingAtoms': [],
        'currentPlayerIndex': 0,
        'isGameOver': true,
        'winner': {
          'id': 'p1',
          'name': 'Player 1',
          'color': 4294198070,
          'type': 'human',
          'difficulty': null,
        },
        'isProcessing': false,
        'turnCount': 5,
        'totalMoves': 10,
        'startTime': '2023-10-27T10:00:00.000Z',
        'endTime': '2023-10-27T10:05:00.000Z',
      };

      // Attempt to parse
      final gameState = GameState.fromJson(serverJson);

      // Verify fields
      expect(gameState.isGameOver, true);
      expect(gameState.winner, isNotNull);
      expect(gameState.winner!.id, 'p1');
    });
  });
}
