import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:chain_reaction/features/game/domain/entities/online/online_game_state.dart';
import 'package:chain_reaction/features/game/domain/failures/game_failure.dart';
import 'package:chain_reaction/features/game/presentation/providers/online_game_provider.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';
import 'package:chain_reaction/routing/routes.dart';
import '../../../../routing/route_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/presentation/widgets/pill_button.dart';
import '../../../../core/presentation/widgets/responsive_container.dart';

/// Waiting room screen for online games.
/// Shows room code for host, and handles navigation when game becomes active.
class OnlineWaitingScreen extends ConsumerWidget {
  const OnlineWaitingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;
    final gameStateAsync = ref.watch(onlineGameProvider);

    // Listen for game state changes
    ref.listen(onlineGameProvider, (prev, next) {
      next.whenOrNull(
        data: (gameState) {
          if (gameState != null && gameState.status == 'active') {
            // Both players present - navigate to game
            context.goNamed(
              AppRouteNames.game,
              extra: GameRouteArgs(
                mode: 'online',
                onlineGameState: gameState,
                playerCount: 2,
                gridSize: _inferGridSize(
                  gameState.gridRows,
                  gameState.gridCols,
                ),
              ),
            );
          }
        },
        error: (e, st) {
          final message = e is GameFailure ? e.message : e.toString();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: ResponsiveContainer(
          child: Stack(
            children: [
              // Main content
              Center(
                child: gameStateAsync.when(
                  data: (gameState) {
                    if (gameState == null) {
                      return const SizedBox.shrink();
                    }
                    return _buildWaitingContent(
                      context,
                      ref,
                      theme,
                      l10n,
                      gameState,
                    );
                  },
                  loading: () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: theme.fg),
                      const SizedBox(height: AppDimensions.paddingL),
                      Text(
                        'Setting up...',
                        style: TextStyle(color: theme.subtitle),
                      ),
                    ],
                  ),
                  error: (e, st) => Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade400,
                          size: 48,
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
                        Text(
                          e is GameFailure ? e.message : 'Something went wrong',
                          style: TextStyle(color: theme.fg),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.paddingXL),
                        PillButton(
                          text: 'Go Back',
                          type: PillButtonType.secondary,
                          onTap: () {
                            ref.read(onlineGameProvider.notifier).leaveGame();
                            context.pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Back button
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.fg,
                    size: AppDimensions.iconM,
                  ),
                  onPressed: () {
                    ref.read(onlineGameProvider.notifier).leaveGame();
                    context.pop();
                  },
                  tooltip: 'Leave Room',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingContent(
    BuildContext context,
    WidgetRef ref,
    ThemeState theme,
    AppLocalizations l10n,
    OnlineGameState gameState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Room Code Label
          Text(
            l10n.roomCode.toUpperCase(),
            style: TextStyle(
              color: theme.subtitle,
              fontSize: AppDimensions.fontS,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          // Room Code Display
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: gameState.roomCode));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gameState.roomCode,
                    style: TextStyle(
                      color: theme.fg,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.copy, color: theme.subtitle, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Share message
          Text(
            l10n.shareCodeMessage,
            style: TextStyle(
              color: theme.subtitle,
              fontSize: AppDimensions.fontM,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 1),

          // Waiting indicator
          CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.playerColors.first,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            l10n.waitingForOpponent,
            style: TextStyle(
              color: theme.fg,
              fontSize: AppDimensions.fontL,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(flex: 2),

          // Cancel button
          PillButton(
            text: 'Cancel',
            type: PillButtonType.secondary,
            onTap: () {
              ref.read(onlineGameProvider.notifier).leaveGame();
              context.pop();
            },
          ),

          const SizedBox(height: AppDimensions.paddingXL),
        ],
      ),
    );
  }

  String _inferGridSize(int rows, int cols) {
    final total = rows * cols;
    if (total <= 20) return 'x_small';
    if (total <= 35) return 'small';
    if (total <= 60) return 'medium';
    if (total <= 100) return 'large';
    return 'x_large';
  }
}
