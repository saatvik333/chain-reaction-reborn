import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';

import 'package:chain_reaction/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MainApp(),
      ),
    );

    // Verify that our app builds.
    // Verify that our app builds and shows Home Screen elements.
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('PLAYERS'), findsOneWidget);
    expect(find.text('GRID SIZE'), findsOneWidget);
  });
}
