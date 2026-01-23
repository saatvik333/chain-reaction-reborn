import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../widgets/pill_button.dart';
import 'purchase_screen.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class PaletteScreen extends StatelessWidget {
  const PaletteScreen({super.key});

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
          AppStrings.themesTitle,
          style: TextStyle(
            color: themeProvider.fg,
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
                AppStrings.availableThemesHeader,
                style: TextStyle(
                  color: themeProvider.subtitle,
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
                    color: themeProvider.border,
                    height: AppDimensions.paddingXL,
                  ),
                  itemBuilder: (context, index) {
                    final theme = AppThemes.all[index];
                    final isSelected =
                        theme.name == themeProvider.currentTheme.name;
                    return _ThemeRow(
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () => themeProvider.setTheme(theme),
                      textColor: themeProvider.fg,
                      backgroundColor: themeProvider.bg,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              PillButton(
                text: AppStrings.getMoreThemes,
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
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;
  final Color backgroundColor;

  const _ThemeRow({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
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
                    color:
                        theme
                            .playerColors(ThemeScope.of(context).isDarkMode)
                            .isNotEmpty
                        ? theme.playerColors(
                            ThemeScope.of(context).isDarkMode,
                          )[0]
                        : textColor,
                    size: AppDimensions.iconM,
                  ),
                ),
              Text(
                theme.name,
                style: TextStyle(
                  color: textColor,
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
              children: List.generate(
                theme.paletteColors(ThemeScope.of(context).isDarkMode).length,
                (index) {
                  final colors = theme.paletteColors(
                    ThemeScope.of(context).isDarkMode,
                  );
                  final color = colors[colors.length - 1 - index];
                  return Positioned(
                    right: index * 14.0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: backgroundColor, width: 2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
