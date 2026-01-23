import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../game/presentation/providers/theme_provider.dart';
import '../providers/shop_provider.dart';
import '../../../../widgets/pill_button.dart';

class ThemePreviewDialog extends ConsumerWidget {
  final AppTheme themeToPreview;

  const ThemePreviewDialog({super.key, required this.themeToPreview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the preview theme for the dialog content, but current theme for the container
    // Or we can style the dialog strictly with the preview theme?
    // Let's style the preview container with the preview theme.

    final isDark =
        true; // Preview in dark mode usually looks better or use current setting?
    // Let's default to dark for consistency in preview.

    return Dialog(
      backgroundColor: themeToPreview.bg(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: BorderSide(color: themeToPreview.border(isDark), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${themeToPreview.name} Theme',
              style: TextStyle(
                color: themeToPreview.fg(isDark),
                fontSize: AppDimensions.fontL,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),

            // Preview Color Grid
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: themeToPreview.surface(isDark),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: themeToPreview
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
              'Unlock this theme for ${themeToPreview.price}',
              style: TextStyle(
                color: themeToPreview.subtitle(isDark),
                fontSize: AppDimensions.fontS,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.paddingL),

            Row(
              children: [
                Expanded(
                  child: PillButton(
                    text: 'Cancel',
                    onTap: () => Navigator.of(context).pop(),
                    // Style manually to look "secondary" in this theme
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: PillButton(
                    text: 'Buy',
                    onTap: () async {
                      // 1. Purchase
                      await ref
                          .read(shopProvider.notifier)
                          .purchaseTheme(themeToPreview.name);
                      // 2. Equip
                      ref.read(themeProvider.notifier).setTheme(themeToPreview);
                      // 3. Close
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    // We can add a "primary" style to PillButton later,
                    // for now it uses the global theme provider which might be weird
                    // if we are inside a dialog styled with PREVIEW theme.
                    // But PillButton uses ref.watch(themeProvider), which is the CURRENT theme.
                    // This is acceptable.
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
