import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:flutter/material.dart';

class AuthTabSelector extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onModeChanged;
  final ThemeState theme;

  const AuthTabSelector({
    super.key,
    required this.isLogin,
    required this.onModeChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300, // Fixed optimal width for the toggle
        height: 50,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: theme.border),
        ),
        child: Stack(
          children: [
            // Sliding Indicator
            AnimatedAlign(
              alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1.0,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.fg,
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
              ),
            ),
            // Text Labels
            Row(
              children: [
                _TabButton(
                  title: 'Sign In',
                  isSelected: isLogin,
                  onTap: () => onModeChanged(true),
                  theme: theme,
                ),
                _TabButton(
                  title: 'Sign Up',
                  isSelected: !isLogin,
                  onTap: () => onModeChanged(false),
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeState theme;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: isSelected ? theme.bg : theme.subtitle,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.5,
              fontFamily: 'Outfit', // Ensure consistent font
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}
