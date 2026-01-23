import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'custom_popup.dart';
import 'pill_button.dart';
import '../screens/game_screen.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class GameMenuDialog extends StatelessWidget {
  final int playerCount;
  final String gridSize;

  const GameMenuDialog({
    super.key,
    required this.playerCount,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);

    return CustomPopup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.paused,
            style: TextStyle(
              color: theme.fg,
              fontSize: AppDimensions.fontXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),

          PillButton(
            text: AppStrings.resume,
            onTap: () => Navigator.of(context).pop(),
            height: 48,
          ),
          const SizedBox(height: AppDimensions.paddingM),

          PillButton(
            text: AppStrings.newGame,
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      GameScreen(playerCount: playerCount, gridSize: gridSize),
                ),
              );
            },
            height: 48,
          ),
          const SizedBox(height: AppDimensions.paddingM),

          PillButton(
            text: AppStrings.exitGame,
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
