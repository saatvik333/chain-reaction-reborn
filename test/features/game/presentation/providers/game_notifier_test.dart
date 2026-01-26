import 'package:flutter/painting.dart'; // For Color
import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/presentation/providers/game_providers.dart';
import 'package:chain_reaction/features/game/presentation/providers/game_state_provider.dart';
import 'package:chain_reaction/features/game/domain/repositories/game_repository.dart';
import 'package:chain_reaction/features/settings/domain/repositories/settings_repository.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';
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

void main() {
  group('GameNotifier Integration Test', () {
    late ProviderContainer container;
    late FakeGameRepository fakeRepository;
    late FakeSettingsRepository fakeSettingsRepository;

    setUp(() {
      fakeRepository = FakeGameRepository();
      fakeSettingsRepository = FakeSettingsRepository();
      container = ProviderContainer(
        overrides: [
          gameRepositoryProvider.overrideWithValue(fakeRepository),
          settingsRepositoryProvider.overrideWithValue(fakeSettingsRepository),
        ],
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

      notifier.initGame(players, gridSize: 'small');

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
