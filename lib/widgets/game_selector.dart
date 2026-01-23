import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/game/presentation/providers/providers.dart';
import '../core/constants/app_dimensions.dart';

class GameSelector extends ConsumerWidget {
  final String label;
  final String value;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const GameSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: theme.subtitle,
            fontSize: AppDimensions.fontXS,
            fontWeight: FontWeight.bold,
            letterSpacing: AppDimensions.letterSpacingTitle,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(
              icon: Icons.chevron_left,
              onTap: onPrevious,
              color: theme.fg,
            ),
            Expanded(
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: theme.fg,
                    fontSize: AppDimensions.fontXXL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _ArrowButton(
              icon: Icons.chevron_right,
              onTap: onNext,
              color: theme.fg,
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color.withValues(alpha: 0.6), size: 28),
      splashRadius: 24,
    );
  }
}
