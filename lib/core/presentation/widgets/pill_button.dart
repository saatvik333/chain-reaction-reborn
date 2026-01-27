import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import '../../constants/app_dimensions.dart';

class PillButton extends ConsumerStatefulWidget {
  final String text;
  final VoidCallback? onTap; // Nullable for disabled state
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;

  const PillButton({
    super.key,
    required this.text,
    this.onTap, // Optional now
    this.width,
    this.height = AppDimensions.pillButtonHeight,
    this.borderColor,
    this.textColor,
  });

  @override
  ConsumerState<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends ConsumerState<PillButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    // If disabled, maybe dim the colors?
    final isDisabled = widget.onTap == null;
    final effectiveBorderColor = (widget.borderColor ?? theme.border)
        .withValues(alpha: isDisabled ? 0.3 : 1.0);
    final effectiveTextColor = (widget.textColor ?? theme.fg).withValues(
      alpha: isDisabled ? 0.3 : 1.0,
    );

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutQuad,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius: BorderRadius.circular(widget.height / 2),
            splashColor: theme.fg.withValues(alpha: 0.1),
            highlightColor: theme.fg.withValues(alpha: 0.05),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                border: Border.all(
                  color: effectiveBorderColor,
                  width: AppDimensions.pillButtonBorderWidth,
                ),
                color: theme.surface.withValues(alpha: isDisabled ? 0.1 : 0.3),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.text,
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
      ),
    );
  }
}
