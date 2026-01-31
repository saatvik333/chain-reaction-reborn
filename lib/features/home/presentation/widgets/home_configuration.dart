import 'package:chain_reaction/features/game/presentation/providers/online_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:go_router/go_router.dart';
import 'package:chain_reaction/routing/routes.dart';
import 'room_code_input.dart';
import '../../../../routing/route_args.dart';

import '../../../../core/presentation/widgets/game_selector.dart';
import '../../../../core/presentation/widgets/pill_button.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';
import 'package:chain_reaction/features/auth/domain/entities/app_auth_state.dart';
import 'package:chain_reaction/features/auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../../core/theme/providers/theme_provider.dart';

class HomeConfiguration extends ConsumerWidget {
  const HomeConfiguration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final theme = ref.watch(themeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final isVsComputer = state.selectedMode == GameMode.vsComputer;
    final isOnline = state.selectedMode == GameMode.online;
    final isJoinRoom = isOnline && state.onlineMode == OnlineMode.join;

    return Column(
      children: [
        if (isOnline)
          GameSelector(
            label: l10n.roomModeLabel,
            value: state.onlineMode == OnlineMode.create
                ? l10n.createRoom
                : l10n.joinRoom,
            onPrevious: () => notifier.cycleOnlineMode(),
            onNext: () => notifier.cycleOnlineMode(),
          )
        else if (isVsComputer)
          GameSelector(
            label: l10n.difficultyLabel,
            value: state.difficultyLabel,
            onPrevious: () => notifier.cycleDifficulty(false),
            onNext: () => notifier.cycleDifficulty(true),
          )
        else
          GameSelector(
            label: l10n.playersLabel,
            value: state.playerCount.toString(),
            onPrevious: () => notifier.decrementPlayers(),
            onNext: () => notifier.incrementPlayers(),
          ),
        const SizedBox(height: AppDimensions.paddingXL),
        if (isOnline) ...[
          if (state.onlineMode == OnlineMode.create)
            GameSelector(
              label: l10n.gridSizeLabel,
              value: _getLocalizedGridSize(
                context,
                state.currentGridSize,
              ),
              onPrevious: () => notifier.cycleGridSize(false),
              onNext: () => notifier.cycleGridSize(true),
            )
          else
            // Join Room - Room Code Input
            RoomCodeInput(
              key: const ValueKey('room_code_input'),
              onChanged: (value) => notifier.setRoomCode(value),
              theme: theme,
            ),
        ] else ...[
          GameSelector(
            label: l10n.gridSizeLabel,
            value: _getLocalizedGridSize(
              context,
              state.currentGridSize,
            ),
            onPrevious: () => notifier.cycleGridSize(false),
            onNext: () => notifier.cycleGridSize(true),
          ),
        ],
        const Spacer(),
        const SizedBox(height: AppDimensions.paddingM),
        // Action Button
        _buildActionButton(
          context,
          ref,
          state,
          l10n,
          isOnline,
          isJoinRoom,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    HomeState state,
    AppLocalizations l10n,
    bool isOnline,
    bool isJoinRoom,
  ) {
    String buttonText;
    if (isOnline) {
      buttonText = isJoinRoom ? l10n.joinRoom : l10n.createRoom;
    } else {
      buttonText = l10n.startGame;
    }

    final onlineGameAsync = ref.watch(onlineGameProvider);
    final isLoading = onlineGameAsync is AsyncLoading;

    return PillButton(
      text: buttonText,
      width: double.infinity,
      type: PillButtonType.primary,
      onTap: isLoading
          ? null
          : () async {
              if (isOnline) {
                final authState = ref.read(authProvider);
                if (authState is! AppAuthStateAuthenticated) {
                  context.pushNamed(AppRouteNames.auth);
                  return;
                }

                final onlineNotifier = ref.read(onlineGameProvider.notifier);

                try {
                  if (isJoinRoom) {
                    if (state.roomCode.length != 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a 4-letter code')),
                      );
                      return;
                    }
                    await onlineNotifier.joinGame(state.roomCode);
                  } else {
                    final (rows, cols) =
                        AppDimensions.gridSizes[state.currentGridSize]!;
                    await onlineNotifier.createGame(rows: rows, cols: cols);
                  }

                  if (context.mounted) {
                    context.pushNamed(AppRouteNames.onlineWaiting);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
                return;
              }

              final isVsComputer = state.selectedMode == GameMode.vsComputer;
              final int players = isVsComputer ? 2 : state.playerCount;
              context.pushNamed(
                AppRouteNames.game,
                extra: GameRouteArgs(
                  playerCount: players,
                  gridSize: state.currentGridSize,
                  aiDifficulty: isVsComputer ? state.aiDifficulty : null,
                ),
              );
            },
    );
  }

  String _getLocalizedGridSize(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'x_small':
        return l10n.gridSizeXSmall;
      case 'small':
        return l10n.gridSizeSmall;
      case 'medium':
        return l10n.gridSizeMedium;
      case 'large':
        return l10n.gridSizeLarge;
      case 'x_large':
        return l10n.gridSizeXLarge;
      default:
        return key;
    }
  }
}
