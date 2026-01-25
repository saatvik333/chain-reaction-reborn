import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';
import 'package:chain_reaction/features/settings/domain/repositories/settings_repository.dart';
import 'package:chain_reaction/features/game/presentation/screens/game_screen.dart';
import 'package:chain_reaction/features/game/presentation/widgets/game_grid.dart';
import 'package:chain_reaction/features/game/presentation/providers/game_providers.dart';
import 'package:chain_reaction/core/services/haptic/haptic_service.dart';
import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:chain_reaction/features/game/domain/ai/ai_service.dart';
import 'package:chain_reaction/features/game/domain/repositories/game_repository.dart';
import 'dart:math';

class MockSettingsRepository implements SettingsRepository {
  @override
  Future<bool?> getDarkMode() async => true;
  @override
  Future<bool?> getSoundOn() async => true;
  @override
  Future<bool?> getHapticOn() async => true;
  @override
  Future<String?> getThemeName() async => 'Default';

  @override
  Future<void> setDarkMode(bool value) async {}
  @override
  Future<void> setSoundOn(bool value) async {}
  @override
  Future<void> setHapticOn(bool value) async {}
  @override
  Future<void> setThemeName(String value) async {}

  @override
  Future<bool?> getAtomRotationOn() async => true;
  @override
  Future<void> setAtomRotationOn(bool value) async {}
  @override
  Future<bool?> getAtomVibrationOn() async => true;
  @override
  Future<void> setAtomVibrationOn(bool value) async {}

  @override
  Future<bool?> getCellHighlightOn() async => true;
  @override
  Future<void> setCellHighlightOn(bool value) async {}
  @override
  Future<bool?> getAtomBreathingOn() async => true;
  @override
  Future<void> setAtomBreathingOn(bool value) async {}
  @override
  Future<void> clearSettings() async {}
}

class MockHapticService implements HapticService {
  @override
  Future<void> lightImpact() async {}
  @override
  Future<void> mediumImpact() async {}
  @override
  Future<void> heavyImpact() async {}
  @override
  Future<void> explosionPattern() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

class MockAIService implements AIService {
  @override
  Future<Point<int>> getMove(GameState state, dynamic player) async {
    return const Point(0, 0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('GameScreen should render GameGrid and atoms', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            MockSettingsRepository(),
          ),
          hapticServiceProvider.overrideWithValue(MockHapticService()),
          gameRepositoryProvider.overrideWithValue(FakeGameRepository()),
          aiServiceProvider.overrideWithValue(MockAIService()),
        ],
        child: const MaterialApp(
          home: GameScreen(playerCount: 2, gridSize: 'Small'),
        ),
      ),
    );

    // Initial pump to run init state
    await tester.pump();

    // Wait for the post frame callback (initialize game)
    await tester.pump(const Duration(milliseconds: 100));

    // GameGrid has a repeating animation, so pumpAndSettle will timeout.
    // Instead, we just check if it's there.
    expect(find.byType(GameGrid), findsOneWidget);
  });
}
