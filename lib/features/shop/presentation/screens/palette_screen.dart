import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/features/game/presentation/providers/providers.dart';
import 'package:chain_reaction/core/theme/app_theme.dart';
import 'package:chain_reaction/widgets/pill_button.dart';

import 'package:chain_reaction/features/shop/presentation/screens/purchase_screen.dart';
import 'package:chain_reaction/widgets/fade_entry_widget.dart';
import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/features/shop/presentation/providers/shop_provider.dart';
import 'package:chain_reaction/features/shop/presentation/widgets/theme_preview_dialog.dart';
import 'package:chain_reaction/core/utils/fluid_dialog.dart';
import 'package:chain_reaction/widgets/responsive_container.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';

class PaletteScreen extends ConsumerWidget {
  const PaletteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final shopState = ref.watch(shopProvider);
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
              l10n.themesTitle,
              style: TextStyle(
                color: themeState.fg,
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.availableThemesHeader,
                    style: TextStyle(
                      color: themeState.subtitle,
                      fontSize: AppDimensions.fontXS,
                      fontWeight: FontWeight.bold,
                      letterSpacing: AppDimensions.letterSpacingHeader,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  Expanded(
                    child: ListView.separated(
                      itemCount: AppThemes.all.length,
                      separatorBuilder: (context, index) => Divider(
                        color: themeState.border,
                        height: AppDimensions.paddingXL,
                      ),
                      itemBuilder: (context, index) {
                        final theme = AppThemes.all[index];
                        final isSelected =
                            theme.name == themeState.currentTheme.name;

                        // Logic: Owned if NOT premium OR if in shop purchased list
                        final isOwned =
                            !theme.isPremium || shopState.isOwned(theme.name);

                        return FadeEntryWidget(
                          delay: Duration(milliseconds: index * 50),
                          child: _ThemeRow(
                            theme: theme,
                            isSelected: isSelected,
                            isLocked: !isOwned,
                            isDarkMode: themeState.isDarkMode,
                            onTap: () {
                              if (isOwned) {
                                ref
                                    .read(themeProvider.notifier)
                                    .setTheme(theme);
                              } else {
                                // Show Preview Dialog
                                showFluidDialog(
                                  context: context,
                                  builder: (_) =>
                                      ThemePreviewDialog(themeToPreview: theme),
                                );
                              }
                            },
                            textColor: themeState.fg,
                            backgroundColor: themeState.bg,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  PillButton(
                    text: l10n.getMoreThemes,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PurchaseScreen(),
                        ),
                      );
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
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final bool isLocked;
  final bool isDarkMode;
  final VoidCallback onTap;
  final Color textColor;
  final Color backgroundColor;

  const _ThemeRow({
    required this.theme,
    required this.isSelected,
    required this.isLocked,
    required this.isDarkMode,
    required this.onTap,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final playerColors = theme.playerColors(isDarkMode);
    final paletteColors = theme.paletteColors(isDarkMode);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.check_circle,
                    color: playerColors.isNotEmpty
                        ? playerColors[0]
                        : textColor,
                    size: AppDimensions.iconM,
                  ),
                )
              else if (isLocked)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.lock,
                    color: textColor.withValues(alpha: 0.5),
                    size: AppDimensions.iconM,
                  ),
                ),
              Text(
                theme.name,
                style: TextStyle(
                  color: isLocked
                      ? textColor.withValues(alpha: 0.5)
                      : textColor,
                  fontSize: AppDimensions.fontL,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            width: 180,
            child: Stack(
              alignment: Alignment.centerRight,
              children: List.generate(paletteColors.length, (index) {
                final color = paletteColors[paletteColors.length - 1 - index];
                return Positioned(
                  right: index * 14.0,
                  child: Container(
                    width: AppDimensions.colorCircleSize,
                    height: AppDimensions.colorCircleSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: backgroundColor, width: 2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
