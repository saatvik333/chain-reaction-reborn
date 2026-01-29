import 'dart:math';
import 'package:flutter/painting.dart'; // For Color
import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/presentation/providers/game_providers.dart';
import 'package:chain_reaction/features/game/presentation/providers/game_state_provider.dart';
import 'package:chain_reaction/features/game/domain/repositories/game_repository.dart';
import 'package:chain_reaction/features/settings/domain/repositories/settings_repository.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';
import 'package:chain_reaction/features/game/domain/ai/ai_service.dart';
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

class FakeSettingsRepository implements SettingsRepository {
  bool? darkMode;
  bool? hapticOn;
  String? themeName;
  bool? atomRotationOn;
  bool? atomVibrationOn;
  bool? cellHighlightOn;
  bool? atomBreathingOn;

  @override
  Future<void> clearSettings() async {
    darkMode = null;
    hapticOn = null;
    themeName = null;
    atomRotationOn = null;
    atomVibrationOn = null;
    cellHighlightOn = null;
    atomBreathingOn = null;
  }

  @override
  Future<bool?> getAtomBreathingOn() async => atomBreathingOn;

  @override
  Future<bool?> getAtomRotationOn() async => atomRotationOn;

  @override
  Future<bool?> getAtomVibrationOn() async => atomVibrationOn;

  @override
  Future<bool?> getCellHighlightOn() async => cellHighlightOn;

  @override
  Future<bool?> getDarkMode() async => darkMode;

  @override
  Future<bool?> getHapticOn() async => hapticOn;

  @override
  Future<String?> getThemeName() async => themeName;

  @override
  Future<void> setAtomBreathingOn(bool value) async => atomBreathingOn = value;

  @override
  Future<void> setAtomRotationOn(bool value) async => atomRotationOn = value;

  @override
  Future<void> setAtomVibrationOn(bool value) async => atomVibrationOn = value;

  @override
  Future<void> setCellHighlightOn(bool value) async => cellHighlightOn = value;

  @override
  Future<void> setDarkMode(bool value) async => darkMode = value;

  @override
  Future<void> setHapticOn(bool value) async => hapticOn = value;

  @override
  Future<void> setThemeName(String value) async => themeName = value;
}

class FakeAIService implements AIService {
  @override
  Future<Point<int>> getMove(GameState state, Player player) async {
    // Return a dummy move (1, 0) -> x=1, y=0 -> grid[0][1]
    return const Point(1, 0);
  }
}

// Test Constants
const logicDelay = Duration(milliseconds: 100);
const aiDelay = Duration(milliseconds: 200);

void main() {
  group('GameNotifier Integration Test', () {
    late ProviderContainer container;
    late FakeGameRepository fakeRepository;
    late FakeSettingsRepository fakeSettingsRepository;
    late FakeAIService fakeAIService;
    late ProviderSubscription subscription;

    setUp(() {
      fakeRepository = FakeGameRepository();
      fakeSettingsRepository = FakeSettingsRepository();
      fakeAIService = FakeAIService();
      container = ProviderContainer(
        overrides: [
          gameRepositoryProvider.overrideWithValue(fakeRepository),
          settingsRepositoryProvider.overrideWithValue(fakeSettingsRepository),
          aiServiceProvider.overrideWithValue(fakeAIService),
        ],
      );
      // Keep provider alive
      subscription = container.listen(gameProvider, (_, _) {});
    });

    tearDown(() {
      subscription.close();
      container.dispose();
    });

    test('Initial state is null', () {
      final state = container.read(gameProvider);
      expect(state, isNull);
    });

    test('initGame creates a valid GameState', () {
      final notifier = container.read(gameProvider.notifier);
      final players = [
        const Player(id: '1', name: 'P1', color: Color(0xFF000000)),
        const Player(id: '2', name: 'P2', color: Color(0xFFFFFFFF)),
      ];

      notifier.initGame(players, gridSize: 'small');

      final state = container.read(gameProvider);
      expect(state, isNotNull);
      expect(state!.players.length, 2);
      expect(state.grid.length, 8); // Rows
      expect(state.grid[0].length, 5); // Cols
      expect(state.currentPlayer.id, '1');

      // Verify persistence
      expect(fakeRepository.savedState, isNotNull);
    });

    test('placeAtom updates state', () async {
      final notifier = container.read(gameProvider.notifier);
      final players = [
        const Player(id: '1', name: 'P1', color: Color(0xFF000000)),
        const Player(id: '2', name: 'P2', color: Color(0xFFFFFFFF)),
      ];

      notifier.initGame(players);

      // Initial move
      notifier.placeAtom(0, 0);

      // Wait for logic
      await Future.delayed(logicDelay);

      final state = container.read(gameProvider);
      expect(state!.grid[0][0].atomCount, 1);
      expect(state.grid[0][0].ownerId, '1');
    });

    test('Undo reverts state in PvP', () async {
      final notifier = container.read(gameProvider.notifier);
      final players = [
        const Player(id: '1', name: 'P1', color: Color(0xFF000000)),
        const Player(id: '2', name: 'P2', color: Color(0xFFFFFFFF)),
      ];

      notifier.initGame(players);

      // Verify initial state
      final state1 = container.read(gameProvider);
      expect(state1!.currentPlayer.id, '1');

      // P1 moves
      notifier.placeAtom(0, 0);
      await Future.delayed(logicDelay); // Wait for P1 logic

      final state2 = container.read(gameProvider);
      // P1 move applied, turn advanced to P2
      expect(state2!.currentPlayer.id, '2');

      // Undo
      expect(notifier.canUndo, isTrue);
      notifier.undo();

      final state3 = container.read(gameProvider);
      // Should revert to P1
      expect(state3!.currentPlayer.id, '1');
      // Board should be clear
      expect(state3.grid[0][0].atomCount, 0);
    });

    test('Undo reverts state in PvAI (reverts 2 turns)', () async {
      final notifier = container.read(gameProvider.notifier);
      final players = [
        const Player(id: '1', name: 'P1', color: Color(0xFF000000)),
        const Player(
          id: '2',
          name: 'Computer',
          color: Color(0xFFFFFFFF),
          type: PlayerType.ai,
          difficulty: AIDifficulty.easy,
        ),
      ];

      notifier.initGame(players);

      // P1 moves
      notifier.placeAtom(0, 0);

      // Wait for P1 move AND FakeAI move
      await Future.delayed(aiDelay);

      final stateAfterAIMove = container.read(gameProvider);

      // P1 moved -> P2 (AI) -> AI moved -> P1.
      // So current turn should be P1 again.
      // And grid should have atoms at (0,0) [P1] and (0,1) [AI].
      expect(stateAfterAIMove, isNotNull);
      expect(
        stateAfterAIMove!.currentPlayer.id,
        '1',
        reason: 'Current player should be P1',
      );
      expect(
        stateAfterAIMove.grid[0][0].atomCount,
        1,
        reason: 'P1 move missing at 0,0',
      ); // P1
      expect(
        stateAfterAIMove.grid[0][1].atomCount,
        1,
        reason: 'AI move missing at 0,1',
      ); // AI

      // Now UNDO.
      notifier.undo();

      final stateAfterUndo = container.read(gameProvider);
      expect(stateAfterUndo!.currentPlayer.id, '1');
      expect(stateAfterUndo.grid[0][0].atomCount, 0);
      expect(stateAfterUndo.grid[0][1].atomCount, 0);

      expect(notifier.canUndo, isFalse);
    });
  });
}
