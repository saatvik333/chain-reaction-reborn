import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:chain_reaction/features/game/presentation/providers/player_names_provider.dart';
import 'package:chain_reaction/core/presentation/widgets/edit_player_dialog.dart';
import 'package:chain_reaction/core/presentation/widgets/pill_button.dart';

import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/core/utils/fluid_dialog.dart';
import 'package:chain_reaction/core/presentation/widgets/responsive_container.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final playerNamesState = ref.watch(playerNamesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: themeState.bg,
      child: ResponsiveContainer(
        child: Scaffold(
          backgroundColor: themeState.bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: themeState.fg,
                size: AppDimensions.iconM,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              l10n.settingsTitle,
              style: TextStyle(
                color: themeState.fg,
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
                    _buildSectionHeader('GENERAL', themeState),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildToggleRow(
                      l10n.darkMode,
                      l10n.darkModeSubtitle,
                      themeState.isDarkMode,
                      (val) => themeNotifier.setDarkMode(val),
                      themeState,
                      l10n,
                    ),

                    const SizedBox(height: AppDimensions.paddingL),
                    _buildToggleRow(
                      l10n.hapticFeedback,
                      l10n.hapticFeedbackSubtitle,
                      themeState.isHapticOn,
                      (val) => themeNotifier.setHapticOn(val),
                      themeState,
                      l10n,
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                    Divider(color: themeState.border, thickness: 1),
                    const SizedBox(height: AppDimensions.paddingXL),

                    _buildSectionHeader('VISUALS & ANIMATION', themeState),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildToggleRow(
                      l10n.atomRotation,
                      l10n.atomRotationSubtitle,
                      themeState.isAtomRotationOn,
                      (val) => themeNotifier.setAtomRotationOn(val),
                      themeState,
                      l10n,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildToggleRow(
                      l10n.atomVibration,
                      l10n.atomVibrationSubtitle,
                      themeState.isAtomVibrationOn,
                      (val) => themeNotifier.setAtomVibrationOn(val),
                      themeState,
                      l10n,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildToggleRow(
                      l10n.atomBreathing,
                      l10n.atomBreathingSubtitle,
                      themeState.isAtomBreathingOn,
                      (val) => themeNotifier.setAtomBreathingOn(val),
                      themeState,
                      l10n,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildToggleRow(
                      l10n.cellHighlight,
                      l10n.cellHighlightSubtitle,
                      themeState.isCellHighlightOn,
                      (val) => themeNotifier.setCellHighlightOn(val),
                      themeState,
                      l10n,
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                    Divider(color: themeState.border, thickness: 1),
                    const SizedBox(height: AppDimensions.paddingXL),

                    _buildSectionHeader(l10n.playerSettingsHeader, themeState),
                    const SizedBox(height: AppDimensions.paddingL),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppDimensions.paddingM,
                            mainAxisSpacing: AppDimensions.paddingM,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: themeState.playerColors.length,
                      itemBuilder: (context, index) {
                        final playerIndex = index + 1;
                        return _buildPlayerSettingItem(
                          playerIndex,
                          themeState.playerColors[index],
                          themeState,
                          playerNamesState.getName(playerIndex),
                          context,
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),
                    PillButton(
                      text: l10n.resetSettings,
                      onTap: () async {
                        // Reset player names
                        ref.read(playerNamesProvider.notifier).resetNames();
                        // Reset all app settings (theme, visuals)
                        await ref.read(themeProvider.notifier).resetSettings();
                      },
                      width: double.infinity,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeState theme) {
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
    ThemeState theme,
    AppLocalizations l10n,
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
            const SizedBox(height: AppDimensions.paddingXS),
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
            value ? l10n.on : l10n.off,
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
    ThemeState theme,
    String playerName,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        showFluidDialog(
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
              width: AppDimensions.colorCircleSize,
              height: AppDimensions.colorCircleSize,
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
