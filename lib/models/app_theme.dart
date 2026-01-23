import 'package:flutter/material.dart';

/// Represents a complete color theme for the application.
/// Supports both light and dark modes with a standardized 10-color palette.
class AppTheme {
  final String name;

  // Mode-specific colors
  final Color bgDark;
  final Color bgLight;
  final Color fgDark;
  final Color fgLight;

  // Accent colors (same for both modes)
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color purple;
  final Color aqua;
  final Color orange;

  const AppTheme({
    required this.name,
    required this.bgDark,
    required this.bgLight,
    required this.fgDark,
    required this.fgLight,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.purple,
    required this.aqua,
    required this.orange,
  });

  /// Get background color based on dark mode
  Color bg(bool isDark) => isDark ? bgDark : bgLight;

  /// Get foreground/text color based on dark mode
  Color fg(bool isDark) => isDark ? fgDark : fgLight;

  /// Get surface color (slightly lighter/darker than bg)
  Color surface(bool isDark) {
    final bgColor = bg(isDark);
    return isDark
        ? Color.lerp(bgColor, Colors.white, 0.05)!
        : Color.lerp(bgColor, Colors.black, 0.03)!;
  }

  /// Get subtitle color (dimmed foreground)
  Color subtitle(bool isDark) => fg(isDark).withValues(alpha: 0.7);

  /// Get border color (very dimmed foreground)
  Color border(bool isDark) => fg(isDark).withValues(alpha: 0.15);

  /// Get player colors list (fg as first player, then accent colors)
  List<Color> playerColors(bool isDark) => [
    fg(isDark),
    red,
    green,
    yellow,
    blue,
    purple,
    aqua,
    orange,
  ];

  /// Get all 10 colors for display in Palette Screen
  List<Color> paletteColors(bool isDark) => [
    bg(isDark),
    surface(isDark),
    fg(isDark),
    red,
    green,
    yellow,
    blue,
    purple,
    aqua,
    orange,
  ];

  /// Returns a player color by index (1-indexed)
  Color getPlayerColor(int playerIndex, bool isDark) {
    final colors = playerColors(isDark);
    if (playerIndex <= 0 || colors.isEmpty) return Colors.transparent;
    return colors[(playerIndex - 1) % colors.length];
  }
}

/// All available themes in the application.
class AppThemes {
  static const AppTheme defaultTheme = AppTheme(
    name: 'Default',
    bgDark: Color(0xFF151515),
    bgLight: Color(0xFFF5F5F5),
    fgDark: Color(0xFFEEEEEE),
    fgLight: Color(0xFF1A1A1A),
    red: Color(0xFFD32F2F),
    green: Color(0xFF388E3C),
    yellow: Color(0xFFFBC02D),
    blue: Color(0xFF1976D2),
    purple: Color(0xFF7B1FA2),
    aqua: Color(0xFF00ACC1),
    orange: Color(0xFFF57C00),
  );

  static const AppTheme gruvbox = AppTheme(
    name: 'Gruvbox',
    bgDark: Color(0xFF282828),
    bgLight: Color(0xFFFBF1C7),
    fgDark: Color(0xFFEBDBB2),
    fgLight: Color(0xFF3C3836),
    red: Color(0xFFCC241D),
    green: Color(0xFF98971A),
    yellow: Color(0xFFD79921),
    blue: Color(0xFF458588),
    purple: Color(0xFFB16286),
    aqua: Color(0xFF689D6A),
    orange: Color(0xFFD65D0E),
  );

  static const AppTheme catppuccin = AppTheme(
    name: 'Catppuccin',
    bgDark: Color(0xFF1E1E2E),
    bgLight: Color(0xFFEFF1F5),
    fgDark: Color(0xFFCDD6F4),
    fgLight: Color(0xFF4C4F69),
    red: Color(0xFFF38BA8),
    green: Color(0xFFA6E3A1),
    yellow: Color(0xFFF9E2AF),
    blue: Color(0xFF89B4FA),
    purple: Color(0xFFCBA6F7),
    aqua: Color(0xFF94E2D5),
    orange: Color(0xFFFAB387),
  );

  static const AppTheme everforest = AppTheme(
    name: 'Everforest',
    bgDark: Color(0xFF2B3339),
    bgLight: Color(0xFFFDF6E3),
    fgDark: Color(0xFFD3C6AA),
    fgLight: Color(0xFF5C6A72),
    red: Color(0xFFE67E80),
    green: Color(0xFFA7C080),
    yellow: Color(0xFFDBBC7F),
    blue: Color(0xFF7FBBB3),
    purple: Color(0xFFD699B6),
    aqua: Color(0xFF83C092),
    orange: Color(0xFFE69875),
  );

  static const AppTheme nord = AppTheme(
    name: 'Nord',
    bgDark: Color(0xFF2E3440),
    bgLight: Color(0xFFECEFF4),
    fgDark: Color(0xFFECEFF4),
    fgLight: Color(0xFF2E3440),
    red: Color(0xFFBF616A),
    green: Color(0xFFA3BE8C),
    yellow: Color(0xFFEBCB8B),
    blue: Color(0xFF81A1C1),
    purple: Color(0xFFB48EAD),
    aqua: Color(0xFF88C0D0),
    orange: Color(0xFFD08770),
  );

  static const AppTheme rosePine = AppTheme(
    name: 'Rose Pine',
    bgDark: Color(0xFF191724),
    bgLight: Color(0xFFFAF4ED),
    fgDark: Color(0xFFE0DEF4),
    fgLight: Color(0xFF575279),
    red: Color(0xFFEB6F92),
    green: Color(0xFF31748F),
    yellow: Color(0xFFF6C177),
    blue: Color(0xFF9CCFD8),
    purple: Color(0xFFC4A7E7),
    aqua: Color(0xFF56949F),
    orange: Color(0xFFEBBCBA),
  );

  /// List of all available themes.
  static const List<AppTheme> all = [
    defaultTheme,
    gruvbox,
    catppuccin,
    everforest,
    nord,
    rosePine,
  ];
}
