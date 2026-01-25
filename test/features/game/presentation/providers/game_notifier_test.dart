import 'package:flutter/painting.dart'; // For Color
import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/presentation/providers/game_providers.dart';
import 'package:chain_reaction/features/game/presentation/providers/game_state_provider.dart';
import 'package:chain_reaction/features/game/domain/repositories/game_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGameRepository implements GameRepository {
  GameState? savedState;

  @override
  Future<void> saveGame(GameState state) async {
    savedState = state;
  }

  @override
  Future<GameState?> loadGame() async {
    return savedState;
  }

  @override
  Future<bool> hasSavedGame() async {
    return savedState != null;
  }

  @override
  Future<void> clearGame() async {
    savedState = null;
  }
}

void main() {
  group('GameNotifier Integration Test', () {
    late ProviderContainer container;
    late FakeGameRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeGameRepository();
      container = ProviderContainer(
        overrides: [gameRepositoryProvider.overrideWithValue(fakeRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is null', () {
      final state = container.read(gameStateProvider);
      expect(state, isNull);
    });

    test('initGame creates a valid GameState', () {
      final notifier = container.read(gameStateProvider.notifier);
      final players = [
        const Player(id: '1', name: 'P1', color: Color(0xFF000000)),
        const Player(id: '2', name: 'P2', color: Color(0xFFFFFFFF)),
      ];

      notifier.initGame(players, gridSize: 'Small');

      final state = container.read(gameStateProvider);
      expect(state, isNotNull);
      expect(state!.players.length, 2);
      expect(state.grid.length, 8); // Rows
      expect(state.grid[0].length, 5); // Cols
      expect(state.currentPlayer.id, '1');

      // Verify persistence
      expect(fakeRepository.savedState, isNotNull);
    });

    test('placeAtom updates state', () async {
      final notifier = container.read(gameStateProvider.notifier);
      final players = [
        const Player(id: '1', name: 'P1', color: Color(0xFF000000)),
        const Player(id: '2', name: 'P2', color: Color(0xFFFFFFFF)),
      ];

      notifier.initGame(players);

      // Initial move
      notifier.placeAtom(0, 0);

      // Wait for stream processing (microtasks)
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(gameStateProvider);
      expect(state!.grid[0][0].atomCount, 1);
      expect(state.grid[0][0].ownerId, '1');
    });
  });
}
