import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:chain_reaction/features/game/presentation/screens/game_screen.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';
import '../../constants/app_dimensions.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'custom_popup.dart';
import 'pill_button.dart';

class GameMenuDialog extends ConsumerWidget {
  final int playerCount;
  final String gridSize;
  final AIDifficulty? aiDifficulty;

  const GameMenuDialog({
    super.key,
    required this.playerCount,
    required this.gridSize,
    this.aiDifficulty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;

    return CustomPopup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.paused,
            style: TextStyle(
              color: theme.fg,
              fontSize: AppDimensions.fontXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),

          PillButton(
            text: l10n.resume,
            onTap: () => Navigator.of(context).pop(),
            height: 48,
          ),
          const SizedBox(height: AppDimensions.paddingM),

          PillButton(
            text: l10n.newGame,
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    playerCount: playerCount,
                    gridSize: gridSize,
                    aiDifficulty: aiDifficulty,
                  ),
                ),
              );
            },
            height: 48,
          ),
          const SizedBox(height: AppDimensions.paddingM),

          PillButton(
            text: l10n.exitGame,
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            height: 48,
            borderColor: theme.currentTheme.red.withValues(alpha: 0.5),
            textColor: theme.currentTheme.red,
          ),
        ],
      ),
    );
  }
}
