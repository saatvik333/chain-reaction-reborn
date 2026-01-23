import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../constants/app_dimensions.dart';

class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;

  const PillButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.height = AppDimensions.pillButtonHeight,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final effectiveBorderColor = borderColor ?? theme.border;
    final effectiveTextColor = textColor ?? theme.fg;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: effectiveBorderColor,
                width: AppDimensions.pillButtonBorderWidth,
              ),
              color: theme.surface.withValues(alpha: 0.3),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: effectiveTextColor,
                fontSize: AppDimensions.fontL,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
