import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';

// Import screens to reference in routes (Phase 6 will populate these)
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/game/presentation/screens/game_screen.dart';
import '../../features/game/presentation/screens/winner_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shop/presentation/screens/purchase_screen.dart';
import '../../features/shop/presentation/screens/palette_screen.dart';
import '../../features/home/presentation/screens/info_screen.dart';
import '../../features/game/domain/entities/player.dart';

/// Provider for the GoRouter instance.
final goRouterProvider = Provider<GoRouter>((ref) {
  // We can add logic here to watch authentication state if needed later.

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true, // Helpful for debugging
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: AppRouteNames.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Nested routes can go here if needed
        ],
      ),
      GoRoute(
        path: '/${AppRoutes.game}',
        name: AppRouteNames.game,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final playerCount = extras?['playerCount'] as int?;
          final gridSize = extras?['gridSize'] as String?;
          final aiDifficulty = extras?['aiDifficulty'] as AIDifficulty?;
          final isResuming = extras?['isResuming'] as bool? ?? false;

          return GameScreen(
            playerCount: playerCount,
            gridSize: gridSize,
            aiDifficulty: aiDifficulty,
            isResuming: isResuming,
          );
        },
      ),
      GoRoute(
        path: '/${AppRoutes.winner}',
        name: AppRouteNames.winner,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final winnerPlayerIndex = extras?['winnerPlayerIndex'] as int? ?? 1;
          final totalMoves = extras?['totalMoves'] as int? ?? 0;
          final gameDuration = extras?['gameDuration'] as String? ?? '00:00';
          final territoryPercentage =
              extras?['territoryPercentage'] as int? ?? 100;
          final playerCount = extras?['playerCount'] as int? ?? 2;
          final gridSize = extras?['gridSize'] as String? ?? 'medium';
          final aiDifficulty = extras?['aiDifficulty'] as AIDifficulty?;

          return WinnerScreen(
            winnerPlayerIndex: winnerPlayerIndex,
            totalMoves: totalMoves,
            gameDuration: gameDuration,
            territoryPercentage: territoryPercentage,
            playerCount: playerCount,
            gridSize: gridSize,
            aiDifficulty: aiDifficulty,
          );
        },
      ),
      GoRoute(
        path: '/${AppRoutes.settings}',
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.shop}',
        name: AppRouteNames.shop,
        builder: (context, state) => const PurchaseScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.palette}',
        name: AppRouteNames.palette,
        builder: (context, state) => const PaletteScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.info}',
        name: AppRouteNames.info,
        builder: (context, state) => const InfoScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});
