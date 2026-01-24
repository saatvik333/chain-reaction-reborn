import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/game/presentation/providers/providers.dart';
import '../core/constants/app_dimensions.dart';

class PillButton extends ConsumerStatefulWidget {
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
  ConsumerState<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends ConsumerState<PillButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final effectiveBorderColor = widget.borderColor ?? theme.border;
    final effectiveTextColor = widget.textColor ?? theme.fg;

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
                color: theme.surface.withValues(alpha: 0.3),
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