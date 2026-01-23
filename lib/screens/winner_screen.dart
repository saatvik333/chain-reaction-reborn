import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/pill_button.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class WinnerScreen extends StatelessWidget {
  final int winnerPlayerIndex;
  final int totalMoves;
  final String gameDuration;
  final int territoryPercentage;

  const WinnerScreen({
    super.key,
    this.winnerPlayerIndex = 1,
    this.totalMoves = 0,
    this.gameDuration = '00:00',
    this.territoryPercentage = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final winnerColor = theme.currentTheme.getPlayerColor(
      winnerPlayerIndex,
      theme.isDarkMode,
    );

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                AppStrings.winner,
                style: TextStyle(
                  color: theme.fg,
                  fontSize: AppDimensions.fontGiant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(
                height: 48,
              ), // Intentionally keeping larger spacing as per design

              Container(
                width: 120, // Specific for winner circle
                height: 120,
                decoration: BoxDecoration(
                  color: winnerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                PlayerScope.of(context).getName(winnerPlayerIndex),
                style: TextStyle(
                  color: theme.fg,
                  fontSize: AppDimensions.fontXXL,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXXXL),

              _buildStatRow(
                AppStrings.totalMoves,
                totalMoves.toString(),
                theme,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              _buildStatRow(AppStrings.duration, gameDuration, theme),
              const SizedBox(height: AppDimensions.paddingL),
              _buildStatRow(
                AppStrings.territory,
                '$territoryPercentage%',
                theme,
              ),

              const Spacer(flex: 3),

              PillButton(
                text: AppStrings.playAgain,
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              PillButton(
                text: AppStrings.mainMenu,
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                width: double.infinity,
                borderColor: theme.border,
                textColor: theme.subtitle,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, ThemeProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.subtitle,
            fontSize: AppDimensions.fontL,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.fg,
            fontSize: AppDimensions.fontXL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
