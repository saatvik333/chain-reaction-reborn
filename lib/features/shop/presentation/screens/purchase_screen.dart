import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/providers/theme_provider.dart';
import 'package:chain_reaction/core/presentation/widgets/pill_button.dart';
import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/core/theme/app_theme.dart';
import 'package:chain_reaction/features/shop/presentation/providers/shop_provider.dart';
import 'package:chain_reaction/core/presentation/widgets/responsive_container.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final shopAsync = ref.watch(shopProvider);
    final l10n = AppLocalizations.of(context)!;

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
              l10n.shopTitle,
              style: TextStyle(
                color: theme.fg,
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: shopAsync.when(
              loading: () =>
                  Center(child: CircularProgressIndicator(color: theme.fg)),
              error: (e, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Text(
                    'Error: $e',
                    style: TextStyle(color: theme.fg),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (state) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.paddingM),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: _buildSectionHeader(l10n.themePacksHeader, theme),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    ...paidThemes.map((targetTheme) {
                      final isOwned = state.isOwned(targetTheme.name);
                      final product = state.getProduct(targetTheme.name);
                      final price = isOwned
                          ? 'OWNED'
                          : (product?.price ?? (targetTheme.price ?? 'N/A'));

                      final canBuy = !isOwned && product != null;

                      return _buildShopItem(
                        title: '${targetTheme.name} Theme',
                        subtitle: isOwned
                            ? 'Currently owned'
                            : 'Unlock this theme',
                        price: price,
                        onTap: canBuy
                            ? () {
                                ref
                                    .read(shopProvider.notifier)
                                    .purchaseTheme(product);
                              }
                            : null,
                        theme: theme,
                      );
                    }),
                    const SizedBox(height: AppDimensions.paddingS),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Divider(color: theme.border, thickness: 1),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: _buildSectionHeader(
                        l10n.supportDevelopmentHeader,
                        theme,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    _buildShopItem(
                      title: "Buy me a coffee",
                      subtitle: "Support the developer",
                      price: "OPEN",
                      theme: theme,
                      onTap: () async {
                        final url = Uri.parse(
                          'https://buymeacoffee.com/saatvik333',
                        );
                        try {
                          await launchUrl(url);
                        } catch (e) {
                          // Fail silently
                        }
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Divider(color: theme.border, thickness: 1),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(l10n.purchasesHeader, theme),
                          const SizedBox(height: AppDimensions.paddingM),
                          Text(
                            l10n.restorePurchasesText,
                            style: TextStyle(
                              color: theme.subtitle,
                              fontSize: AppDimensions.fontS,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingXL),
                          PillButton(
                            text: l10n.restorePurchasesButton,
                            onTap: () async {
                              await ref
                                  .read(shopProvider.notifier)
                                  .restorePurchases();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Restoring purchases...',
                                    style: TextStyle(color: theme.bg),
                                  ),
                                  backgroundColor: theme.fg,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            width: double.infinity,
                          ),
                        ],
                      ),
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
    final isUnavailable = price == 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
      ), // Add horizontal padding for touch target spacing
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal:
                AppDimensions.paddingL -
                AppDimensions
                    .paddingS, // Adjust padding to align with core layout
            vertical: AppDimensions.paddingM,
          ),
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
                      color: isUnavailable ? theme.subtitle : theme.fg,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: onTap == null ? theme.surface : theme.fg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
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
      ),
    );
  }
}
