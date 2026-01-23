import 'package:flutter/material.dart';
import '../models/app_theme.dart';

/// Provides theme state management across the application.
/// Supports both theme selection and dark/light mode toggling.
class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme;
  bool _isDarkMode;
  bool _isSoundOn;
  bool _isHapticOn;

  ThemeProvider({
    AppTheme? initialTheme,
    bool isDarkMode = true,
    bool isSoundOn = true,
    bool isHapticOn = true,
  }) : _currentTheme = initialTheme ?? AppThemes.defaultTheme,
       _isDarkMode = isDarkMode,
       _isSoundOn = isSoundOn,
       _isHapticOn = isHapticOn;

  /// The currently active theme.
  AppTheme get currentTheme => _currentTheme;

  /// Whether dark mode is enabled.
  bool get isDarkMode => _isDarkMode;

  /// Whether sound effects are enabled.
  bool get isSoundOn => _isSoundOn;

  /// Whether haptic feedback is enabled.
  bool get isHapticOn => _isHapticOn;

  // Convenience getters for resolved colors
  Color get bg => _currentTheme.bg(_isDarkMode);
  Color get fg => _currentTheme.fg(_isDarkMode);
  Color get surface => _currentTheme.surface(_isDarkMode);
  Color get subtitle => _currentTheme.subtitle(_isDarkMode);
  Color get border => _currentTheme.border(_isDarkMode);
  List<Color> get playerColors => _currentTheme.playerColors(_isDarkMode);

  /// Updates the current theme and notifies listeners.
  void setTheme(AppTheme theme) {
    if (_currentTheme.name != theme.name) {
      _currentTheme = theme;
      notifyListeners();
    }
  }

  /// Toggles dark mode on/off.
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Sets dark mode explicitly.
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }

  void toggleSound(bool value) {
    if (_isSoundOn != value) {
      _isSoundOn = value;
      notifyListeners();
    }
  }

  void toggleHaptic(bool value) {
    if (_isHapticOn != value) {
      _isHapticOn = value;
      notifyListeners();
    }
  }

  /// Sets theme by name. Returns true if theme was found and set.
  bool setThemeByName(String name) {
    final theme = AppThemes.all.firstWhere(
      (t) => t.name == name,
      orElse: () => _currentTheme,
    );
    if (theme.name != _currentTheme.name) {
      setTheme(theme);
      return true;
    }
    return false;
  }
}

/// InheritedNotifier that provides ThemeProvider to the widget tree.
class ThemeScope extends InheritedNotifier<ThemeProvider> {
  const ThemeScope({
    super.key,
    required ThemeProvider themeProvider,
    required super.child,
  }) : super(notifier: themeProvider);

  /// Access the ThemeProvider from anywhere in the widget tree.
  static ThemeProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }
}
