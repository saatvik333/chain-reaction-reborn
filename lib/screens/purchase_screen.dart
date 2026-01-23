import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/game/presentation/providers/providers.dart';
import '../features/game/presentation/providers/theme_provider.dart';
import '../widgets/pill_button.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_dimensions.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.fg,
            size: AppDimensions.iconM,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.shopTitle,
          style: TextStyle(
            color: theme.fg,
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
                _buildSectionHeader(AppStrings.removeAdsHeader, theme),
                const SizedBox(height: AppDimensions.paddingL),
                _buildShopItem(
                  title: AppStrings.adFreeTitle,
                  subtitle: AppStrings.adFreeSubtitle,
                  price:
                      '\$2.99', // Price usually backend dynamic, but keeping string for now
                  theme: theme,
                ),

                const SizedBox(height: AppDimensions.paddingXL),
                Divider(color: theme.border, thickness: 1),
                const SizedBox(height: AppDimensions.paddingXL),

                _buildSectionHeader(AppStrings.themePacksHeader, theme),
                const SizedBox(height: AppDimensions.paddingL),
                _buildShopItem(
                  title: AppStrings.retroThemeTitle,
                  subtitle: AppStrings.retroThemeSubtitle,
                  price: '\$0.99',
                  theme: theme,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                _buildShopItem(
                  title: AppStrings.neonThemeTitle,
                  subtitle: AppStrings.neonThemeSubtitle,
                  price: '\$0.99',
                  theme: theme,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                _buildShopItem(
                  title: AppStrings.pastelThemeTitle,
                  subtitle: AppStrings.pastelThemeSubtitle,
                  price: '\$0.99',
                  theme: theme,
                ),

                const SizedBox(height: AppDimensions.paddingXL),
                Divider(color: theme.border, thickness: 1),
                const SizedBox(height: AppDimensions.paddingXL),

                _buildSectionHeader(AppStrings.purchasesHeader, theme),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  AppStrings.restorePurchasesText,
                  style: TextStyle(
                    color: theme.subtitle,
                    fontSize: AppDimensions.fontS,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                PillButton(
                  text: AppStrings.restorePurchasesButton,
                  onTap: () {},
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

  Widget _buildShopItem({
    required String title,
    required String subtitle,
    required String price,
    required ThemeState theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
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
        Text(
          price,
          style: TextStyle(
            color: theme.fg,
            fontSize: AppDimensions.fontM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
