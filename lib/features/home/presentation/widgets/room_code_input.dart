import 'package:flutter/material.dart';
import '../../../../core/theme/providers/theme_provider.dart';

class RoomCodeInput extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final ThemeState theme;

  const RoomCodeInput({
    super.key,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: TextField(
        onChanged: (value) => onChanged(value.toUpperCase()),
        style: TextStyle(
          color: theme.fg,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 4.0,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'ENTER CODE',
          hintStyle: TextStyle(
            color: theme.subtitle.withValues(alpha: 0.4),
            letterSpacing: 1.5,
            fontSize: 16,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        textCapitalization: TextCapitalization.characters,
        maxLength: 4,
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
      ),
    );
  }
}
