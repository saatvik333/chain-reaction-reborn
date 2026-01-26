import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../providers/shop_provider.dart';
import '../../../../widgets/pill_button.dart';

class ThemePreviewDialog extends ConsumerWidget {
  final AppTheme themeToPreview;

  const ThemePreviewDialog({super.key, required this.themeToPreview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = themeToPreview;
    final shopState = ref.watch(shopProvider);
    final product = shopState.getProduct(theme.name);

    // Determine price to show: Product price, or theme placeholder, or error
    final price = product?.price ?? theme.price ?? 'N/A';
    final canBuy = product != null;

    final isDark = true; // Preview in default dark mode

    return Dialog(
      backgroundColor: theme.bg(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: BorderSide(color: theme.border(isDark), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${theme.name} Theme',
              style: TextStyle(
                color: theme.fg(isDark),
                fontSize: AppDimensions.fontL,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),

            // Preview Color Grid
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: theme.surface(isDark),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: theme
                    .playerColors(isDark)
                    .map(
                      (c) => Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: c.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            Text(
              'Unlock this theme for $price',
              style: TextStyle(
                color: theme.subtitle(isDark),
                fontSize: AppDimensions.fontS,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.paddingL),

            if (shopState.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.paddingM),
                child: CircularProgressIndicator(),
              ),

            Row(
              children: [
                Expanded(
                  child: PillButton(
                    text: 'Cancel',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: PillButton(
                    text: 'Buy',
                    // Disable if loading or product not found
                    onTap: (shopState.isLoading || !canBuy)
                        ? null
                        : () {
                            ref
                                .read(shopProvider.notifier)
                                .purchaseTheme(product);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
