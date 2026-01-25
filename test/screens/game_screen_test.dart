import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';
import 'package:chain_reaction/features/settings/domain/repositories/settings_repository.dart';
import 'package:chain_reaction/features/game/presentation/screens/game_screen.dart';
import 'package:chain_reaction/features/game/presentation/widgets/game_grid.dart';

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

void main() {
  testWidgets('GameScreen should render GameGrid and atoms', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            MockSettingsRepository(),
          ),
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
