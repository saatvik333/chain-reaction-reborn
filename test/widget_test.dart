import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';
import 'package:chain_reaction/features/home/presentation/screens/home_screen.dart';
import 'package:chain_reaction/features/auth/presentation/providers/auth_provider.dart';
import 'package:chain_reaction/features/auth/domain/entities/app_auth_state.dart';

import 'package:chain_reaction/main.dart';

/// Mock AuthNotifier that returns unauthenticated state (no Supabase needed)
class MockAuthNotifier extends AuthNotifier {
  @override
  AppAuthState build() => const AppAuthState.unauthenticated();
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Mock the auth provider to avoid Supabase initialization
          authProvider.overrideWith(() => MockAuthNotifier()),
        ],
        child: const MainApp(),
      ),
    );

    // Wait for Splash Screen to finish (2 seconds delay)
    await tester.pump(const Duration(seconds: 2, milliseconds: 100));

    // Allow the navigation to process (microtasks)
    await tester.pump();

    // Wait for the navigation transition (600ms) to complete
    await tester.pump(const Duration(seconds: 1));

    // Verify that our app builds and shows Home Screen elements.
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
