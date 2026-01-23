import 'package:flutter_test/flutter_test.dart';

import 'package:chain_reaction/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that our app builds.
    // Verify that our app builds and shows Home Screen elements.
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('PLAYERS'), findsOneWidget);
    expect(find.text('GRID SIZE'), findsOneWidget);
  });
}
