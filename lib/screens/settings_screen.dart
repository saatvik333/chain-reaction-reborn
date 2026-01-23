import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/edit_player_dialog.dart';
import '../widgets/pill_button.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeScope.of(context);

    return Scaffold(
      backgroundColor: themeProvider.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: themeProvider.fg,
            size: AppDimensions.iconM,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.settingsTitle,
          style: TextStyle(
            color: themeProvider.fg,
            fontSize: AppDimensions.fontXL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  AppStrings.preferencesHeader,
                  themeProvider,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                _buildToggleRow(
                  AppStrings.soundEffects,
                  AppStrings.soundEffectsSubtitle,
                  themeProvider.isSoundOn,
                  (val) => themeProvider.toggleSound(val),
                  themeProvider,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                _buildToggleRow(
                  AppStrings.hapticFeedback,
                  AppStrings.hapticFeedbackSubtitle,
                  themeProvider.isHapticOn,
                  (val) => themeProvider.toggleHaptic(val),
                  themeProvider,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                _buildToggleRow(
                  AppStrings.darkMode,
                  AppStrings.darkModeSubtitle,
                  themeProvider.isDarkMode,
                  (val) => themeProvider.setDarkMode(val),
                  themeProvider,
                ),

                const SizedBox(height: AppDimensions.paddingXL),
                Divider(color: themeProvider.border, thickness: 1),
                const SizedBox(height: AppDimensions.paddingXL),

                _buildSectionHeader(
                  AppStrings.playerSettingsHeader,
                  themeProvider,
                ),
                const SizedBox(height: AppDimensions.paddingL),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.paddingM,
                    mainAxisSpacing: AppDimensions.paddingM,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: themeProvider.playerColors.length,
                  itemBuilder: (context, index) {
                    final playerIndex = index + 1;
                    return _buildPlayerSettingItem(
                      playerIndex,
                      themeProvider.playerColors[index],
                      themeProvider,
                      context,
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.paddingXL),
                PillButton(
                  text: AppStrings.resetSettings,
                  onTap: () {
                    PlayerScope.of(context).resetNames();
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: AppDimensions.paddingL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeProvider theme) {
    return Text(
      title,
      style: TextStyle(
        color: theme.subtitle,
        fontSize: AppDimensions.fontXS,
        fontWeight: FontWeight.bold,
        letterSpacing: AppDimensions.letterSpacingHeader,
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    ThemeProvider theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.fg,
                fontSize: AppDimensions.fontM,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.subtitle,
                fontSize: AppDimensions.fontS,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => onChanged(!value),
          style: TextButton.styleFrom(foregroundColor: theme.fg),
          child: Text(
            value ? AppStrings.on : AppStrings.off,
            style: const TextStyle(
              fontSize: AppDimensions.fontM,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSettingItem(
    int playerIndex,
    Color color,
    ThemeProvider theme,
    BuildContext context,
  ) {
    final playerProvider = PlayerScope.of(context);
    final playerName = playerProvider.getName(playerIndex);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.8),
          builder: (context) => EditPlayerDialog(playerIndex: playerIndex),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                playerName,
                style: TextStyle(
                  color: theme.fg,
                  fontSize: AppDimensions.fontM,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
