import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import 'route_args.dart';

// Screen imports
import '../features/home/presentation/screens/home_screen.dart';
import '../features/game/presentation/screens/game_screen.dart';
import '../features/game/presentation/screens/winner_screen.dart';
import '../features/game/presentation/screens/online_waiting_screen.dart';

import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/shop/presentation/screens/purchase_screen.dart';
import '../features/shop/presentation/screens/palette_screen.dart';
import '../features/home/presentation/screens/info_screen.dart';
import '../features/auth/presentation/screens/auth_screen.dart';

/// Provider for the GoRouter instance.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: AppRouteNames.home,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const HomeScreen()),
      ),
      GoRoute(
        path: '/${AppRoutes.game}',
        name: AppRouteNames.game,
        pageBuilder: (context, state) {
          final args = state.extra as GameRouteArgs?;
          final playerCount = args?.playerCount;
          final gridSize = args?.gridSize;
          final aiDifficulty = args?.aiDifficulty;
          final isResuming = args?.isResuming ?? false;

          return _fadeTransition(
            context,
            state,
            GameScreen(
              playerCount: playerCount,
              gridSize: gridSize,
              aiDifficulty: aiDifficulty,
              isResuming: isResuming,
            ),
          );
        },
      ),
      GoRoute(
        path: '/${AppRoutes.winner}',
        name: AppRouteNames.winner,
        pageBuilder: (context, state) {
          final args = state.extra as WinnerRouteArgs?;
          final winnerPlayerIndex = args?.winnerPlayerIndex ?? 1;
          final totalMoves = args?.totalMoves ?? 0;
          final gameDuration = args?.gameDuration ?? '00:00';
          final territoryPercentage = args?.territoryPercentage ?? 100;
          final playerCount = args?.playerCount ?? 2;
          final gridSize = args?.gridSize ?? 'medium';
          final aiDifficulty = args?.aiDifficulty;

          return _fadeTransition(
            context,
            state,
            WinnerScreen(
              winnerPlayerIndex: winnerPlayerIndex,
              totalMoves: totalMoves,
              gameDuration: gameDuration,
              territoryPercentage: territoryPercentage,
              playerCount: playerCount,
              gridSize: gridSize,
              aiDifficulty: aiDifficulty,
            ),
          );
        },
      ),
      GoRoute(
        path: '/${AppRoutes.settings}',
        name: AppRouteNames.settings,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/${AppRoutes.shop}',
        name: AppRouteNames.shop,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const PurchaseScreen()),
      ),
      GoRoute(
        path: '/${AppRoutes.palette}',
        name: AppRouteNames.palette,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const PaletteScreen()),
      ),
      GoRoute(
        path: '/${AppRoutes.info}',
        name: AppRouteNames.info,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const InfoScreen()),
      ),
      GoRoute(
        path: '/${AppRoutes.auth}',
        name: AppRouteNames.auth,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const AuthScreen()),
      ),
      GoRoute(
        path: '/${AppRoutes.onlineWaiting}',
        name: AppRouteNames.onlineWaiting,
        pageBuilder: (context, state) =>
            _fadeTransition(context, state, const OnlineWaitingScreen()),
      ),
    ],

    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});

CustomTransitionPage _fadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeOut).animate(animation),
        child: child,
      );
    },
  );
}
