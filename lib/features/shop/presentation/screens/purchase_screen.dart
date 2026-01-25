import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/features/game/presentation/providers/providers.dart';
import 'package:chain_reaction/features/game/presentation/providers/theme_provider.dart';
import 'package:chain_reaction/widgets/pill_button.dart';
import 'package:chain_reaction/core/constants/app_strings.dart';
import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/core/theme/app_theme.dart';
import 'package:chain_reaction/features/shop/presentation/providers/shop_provider.dart';
import 'package:chain_reaction/widgets/responsive_container.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final shopState = ref.watch(shopProvider);

    final paidThemes = AppThemes.all.where((t) => t.isPremium).toList();

    return Container(
      color: theme.bg,
      child: ResponsiveContainer(
        child: Scaffold(
          backgroundColor: theme.bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
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
                    _buildSectionHeader(AppStrings.themePacksHeader, theme),
                    const SizedBox(height: AppDimensions.paddingL),

                    ...paidThemes.map((targetTheme) {
                      final isOwned = shopState.isOwned(targetTheme.name);
                      return Column(
                        children: [
                          _buildShopItem(
                            title: '${targetTheme.name} Theme',
                            subtitle: isOwned
                                ? 'Currently owned'
                                : 'Unlock this theme',
                            price: isOwned
                                ? 'OWNED'
                                : (targetTheme.price ?? '\$0.99'),
                            onTap: isOwned
                                ? null
                                : () async {
                                    await ref
                                        .read(shopProvider.notifier)
                                        .purchaseTheme(targetTheme.name);
                                  },
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimensions.paddingL),
                        ],
                      );
                    }),

                    const SizedBox(height: AppDimensions.paddingS),
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
                      onTap: () async {
                        await ref
                            .read(shopProvider.notifier)
                            .restorePurchases();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Purchases restored',
                              style: TextStyle(color: theme.bg),
                            ),
                            backgroundColor: theme.fg,
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
    VoidCallback? onTap,
    required ThemeState theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: onTap == null ? theme.surface : theme.fg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                price,
                style: TextStyle(
                  color: onTap == null ? theme.subtitle : theme.bg,
                  fontSize: AppDimensions.fontS,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
