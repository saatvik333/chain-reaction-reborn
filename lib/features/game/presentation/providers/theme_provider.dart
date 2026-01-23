import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/settings/domain/repositories/settings_repository.dart';
import '../../../../features/settings/presentation/providers/settings_providers.dart';

/// Immutable state for theme settings.
@immutable
class ThemeState {
  final AppTheme currentTheme;
  final bool isDarkMode;
  final bool isSoundOn;
  final bool isHapticOn;

  const ThemeState({
    required this.currentTheme,
    this.isDarkMode = true,
    this.isSoundOn = true,
    this.isHapticOn = true,
  });

  // Resolved colors for convenience
  Color get bg => currentTheme.bg(isDarkMode);
  Color get fg => currentTheme.fg(isDarkMode);
  Color get surface => currentTheme.surface(isDarkMode);
  Color get subtitle => currentTheme.subtitle(isDarkMode);
  Color get border => currentTheme.border(isDarkMode);
  List<Color> get playerColors => currentTheme.playerColors(isDarkMode);

  /// Get a player color by index (1-indexed).
  Color getPlayerColor(int playerIndex) {
    if (playerIndex <= 0 || playerColors.isEmpty) return Colors.transparent;
    return playerColors[(playerIndex - 1) % playerColors.length];
  }

  ThemeState copyWith({
    AppTheme? currentTheme,
    bool? isDarkMode,
    bool? isSoundOn,
    bool? isHapticOn,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSoundOn: isSoundOn ?? this.isSoundOn,
      isHapticOn: isHapticOn ?? this.isHapticOn,
    );
  }
}

/// Notifier for managing theme state.
class ThemeNotifier extends StateNotifier<ThemeState> {
  final SettingsRepository _settingsRepository;

  ThemeNotifier(this._settingsRepository)
    : super(const ThemeState(currentTheme: AppThemes.defaultTheme)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final platformBrightness = PlatformDispatcher.instance.platformBrightness;
    final defaultDarkMode = platformBrightness == Brightness.dark;

    final isDarkMode =
        await _settingsRepository.getDarkMode() ?? defaultDarkMode;
    final isSoundOn = await _settingsRepository.getSoundOn() ?? true;
    final isHapticOn = await _settingsRepository.getHapticOn() ?? true;
    final themeName = await _settingsRepository.getThemeName();

    final theme = AppThemes.all.firstWhere(
      (t) => t.name == themeName,
      orElse: () => AppThemes.defaultTheme,
    );

    state = ThemeState(
      currentTheme: theme,
      isDarkMode: isDarkMode,
      isSoundOn: isSoundOn,
      isHapticOn: isHapticOn,
    );
  }

  /// Sets the current theme.
  void setTheme(AppTheme theme) {
    if (state.currentTheme.name != theme.name) {
      state = state.copyWith(currentTheme: theme);
      _settingsRepository.setThemeName(theme.name);
    }
  }

  /// Sets theme by name. Returns true if found and set.
  bool setThemeByName(String name) {
    final theme = AppThemes.all.firstWhere(
      (t) => t.name == name,
      orElse: () => state.currentTheme,
    );
    if (theme.name != state.currentTheme.name) {
      setTheme(theme);
      return true;
    }
    return false;
  }

  /// Toggles dark mode.
  void toggleDarkMode() {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);
    _settingsRepository.setDarkMode(newValue);
  }

  /// Sets dark mode explicitly.
  void setDarkMode(bool value) {
    if (state.isDarkMode != value) {
      state = state.copyWith(isDarkMode: value);
      _settingsRepository.setDarkMode(value);
    }
  }

  /// Sets sound on/off.
  void setSoundOn(bool value) {
    if (state.isSoundOn != value) {
      state = state.copyWith(isSoundOn: value);
      _settingsRepository.setSoundOn(value);
    }
  }

  /// Sets haptic feedback on/off.
  void setHapticOn(bool value) {
    if (state.isHapticOn != value) {
      state = state.copyWith(isHapticOn: value);
      _settingsRepository.setHapticOn(value);
    }
  }
}

/// Main theme provider.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return ThemeNotifier(settingsRepo);
});

// Derived providers for selective rebuilds

/// Current theme only.
final currentThemeProvider = Provider<AppTheme>((ref) {
  return ref.watch(themeProvider.select((s) => s.currentTheme));
});

/// Dark mode state.
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider.select((s) => s.isDarkMode));
});

/// Sound on state.
final isSoundOnProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider.select((s) => s.isSoundOn));
});

/// Haptic feedback state.
final isHapticOnProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider.select((s) => s.isHapticOn));
});

/// Background color.
final bgColorProvider = Provider<Color>((ref) {
  return ref.watch(themeProvider.select((s) => s.bg));
});

/// Foreground color.
final fgColorProvider = Provider<Color>((ref) {
  return ref.watch(themeProvider.select((s) => s.fg));
});

/// Surface color.
final surfaceColorProvider = Provider<Color>((ref) {
  return ref.watch(themeProvider.select((s) => s.surface));
});

/// Player colors list.
final playerColorsProvider = Provider<List<Color>>((ref) {
  return ref.watch(themeProvider.select((s) => s.playerColors));
});
