import 'dart:async';

import 'package:chain_reaction/features/auth/domain/entities/app_auth_state.dart';
import 'package:chain_reaction/features/auth/presentation/providers/auth_provider.dart';
import 'package:chain_reaction/features/game/data/services/online_game_service.dart';
import 'package:chain_reaction/features/game/domain/entities/online/online_game_state.dart';
import 'package:chain_reaction/features/game/presentation/providers/online_game_provider.dart';
import 'package:chain_reaction/features/game/presentation/screens/online_waiting_screen.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock Service using 'implements' to avoid processing the real constructor
class MockOnlineGameService implements OnlineGameService {
  final _controller = StreamController<OnlineGameState>.broadcast();
  final _connectionController =
      StreamController<RealtimeConnectionState>.broadcast();

  @override
  Stream<OnlineGameState> get gameStateStream => _controller.stream;

  @override
  Stream<RealtimeConnectionState> get connectionStateStream =>
      _connectionController.stream;

  @override
  Future<OnlineGameState> createGame({
    required int rows,
    required int cols,
  }) async {
    return OnlineGameState(
      id: 'mock_id',
      roomCode: 'MOCK',
      player1Id: 'p1',
      status: 'waiting',
      currentPlayerIndex: 0,
      turnNumber: 0,
      createdAt: DateTime.now(),
      gridRows: rows,
      gridCols: cols,
      gameState: {'grid': List.generate(rows, (_) => List.filled(cols, null))},
    );
  }

  @override
  Future<OnlineGameState> joinGame(String roomCode) async {
    return OnlineGameState(
      id: 'mock_id_join',
      roomCode: roomCode,
      player1Id: 'p1',
      player2Id: 'p2',
      status: 'active',
      currentPlayerIndex: 0,
      turnNumber: 0,
      createdAt: DateTime.now(),
      gameState: {'grid': List.generate(8, (_) => List.filled(6, null))},
    );
  }

  @override
  Future<void> submitMove({
    required String gameId,
    required int x,
    required int y,
  }) async {}

  @override
  Future<void> subscribeToGame(String gameId) async {}

  @override
  Future<void> unsubscribe() async {}

  @override
  Future<OnlineGameState> fetchGameState(String gameId) async {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    _controller.close();
    _connectionController.close();
  }

  void emitGameState(OnlineGameState state) {
    _controller.add(state);
  }
}

/// Mock AuthNotifier that returns authenticated state
class MockAuthNotifier extends AuthNotifier {
  @override
  AppAuthState build() {
    return const AppAuthState.authenticated(
      userId: 'test_user_id',
      email: 'test@example.com',
    );
  }
}

void main() {
  group('Online Game Flow Integration Tests', () {
    testWidgets('OnlineWaitingScreen shows loading state initially', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onlineGameServiceProvider.overrideWith(
              (ref) => MockOnlineGameService(),
            ),
            sharedPreferencesProvider.overrideWithValue(prefs),
            authProvider.overrideWith(() => MockAuthNotifier()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnlineWaitingScreen(),
          ),
        ),
      );

      // Initially shows either loading or empty state
      await tester.pump();

      // Verify back button is present
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('OnlineWaitingScreen shows room code when game is created', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final mockService = MockOnlineGameService();
      final testGameState = OnlineGameState(
        id: 'test_id',
        roomCode: 'ABCD',
        player1Id: 'p1',
        status: 'waiting',
        currentPlayerIndex: 0,
        turnNumber: 0,
        createdAt: DateTime.now(),
        gridRows: 8,
        gridCols: 6,
        gameState: {'grid': List.generate(8, (_) => List.filled(6, null))},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onlineGameServiceProvider.overrideWith((ref) => mockService),
            sharedPreferencesProvider.overrideWithValue(prefs),
            authProvider.overrideWith(() => MockAuthNotifier()),
            // Pre-populate with a game state
            onlineGameProvider.overrideWith(
              () => _PreloadedOnlineGame(testGameState),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnlineWaitingScreen(),
          ),
        ),
      );

      // Use pump with duration instead of pumpAndSettle because of infinite animations
      await tester.pump(const Duration(milliseconds: 100));

      // Verify room code is displayed
      expect(find.text('ABCD'), findsOneWidget);

      // Verify copy icon is present
      expect(find.byIcon(Icons.copy), findsOneWidget);

      // Verify cancel button is present
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('OnlineWaitingScreen shows error state gracefully', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onlineGameServiceProvider.overrideWith(
              (ref) => MockOnlineGameService(),
            ),
            sharedPreferencesProvider.overrideWithValue(prefs),
            authProvider.overrideWith(() => MockAuthNotifier()),
            // Override with error state
            onlineGameProvider.overrideWith(() => _ErrorOnlineGame()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnlineWaitingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error icon is shown
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Verify go back button is present
      expect(find.text('Go Back'), findsOneWidget);
    });
  });
}

/// Helper notifier that pre-loads with a game state
class _PreloadedOnlineGame extends OnlineGame {
  final OnlineGameState _initialState;
  _PreloadedOnlineGame(this._initialState);

  @override
  FutureOr<OnlineGameState?> build() {
    return _initialState;
  }
}

/// Helper notifier that returns an error state
class _ErrorOnlineGame extends OnlineGame {
  @override
  FutureOr<OnlineGameState?> build() {
    throw Exception('Test error');
  }
}
