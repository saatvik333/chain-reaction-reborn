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
  final bool isAtomRotationOn;
  final bool isAtomVibrationOn;
  final bool isAtomBreathingOn;
  final bool isCellHighlightOn;

  const ThemeState({
    required this.currentTheme,
    this.isDarkMode = true,
    this.isSoundOn = true,
    this.isHapticOn = true,
    this.isAtomRotationOn = true,
    this.isAtomVibrationOn = true,
    this.isAtomBreathingOn = true,
    this.isCellHighlightOn = true,
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
    bool? isAtomRotationOn,
    bool? isAtomVibrationOn,
    bool? isAtomBreathingOn,
    bool? isCellHighlightOn,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSoundOn: isSoundOn ?? this.isSoundOn,
      isHapticOn: isHapticOn ?? this.isHapticOn,
      isAtomRotationOn: isAtomRotationOn ?? this.isAtomRotationOn,
      isAtomVibrationOn: isAtomVibrationOn ?? this.isAtomVibrationOn,
      isAtomBreathingOn: isAtomBreathingOn ?? this.isAtomBreathingOn,
      isCellHighlightOn: isCellHighlightOn ?? this.isCellHighlightOn,
    );
  }
}

/// Notifier for managing theme state.
class ThemeNotifier extends Notifier<ThemeState> {
  late final SettingsRepository _settingsRepository;

  @override
  ThemeState build() {
    _settingsRepository = ref.watch(settingsRepositoryProvider);
    _loadSettings();
    return const ThemeState(currentTheme: AppThemes.defaultTheme);
  }

  Future<void> _loadSettings() async {
    final platformBrightness = PlatformDispatcher.instance.platformBrightness;
    final defaultDarkMode = platformBrightness == Brightness.dark;

    final isDarkMode =
        await _settingsRepository.getDarkMode() ?? defaultDarkMode;
    final isSoundOn = await _settingsRepository.getSoundOn() ?? true;
    final isHapticOn = await _settingsRepository.getHapticOn() ?? true;
    final isAtomRotationOn =
        await _settingsRepository.getAtomRotationOn() ?? true;
    final isAtomVibrationOn =
        await _settingsRepository.getAtomVibrationOn() ?? true;
    final isAtomBreathingOn =
        await _settingsRepository.getAtomBreathingOn() ?? true;
    final isCellHighlightOn =
        await _settingsRepository.getCellHighlightOn() ?? true;
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
      isAtomRotationOn: isAtomRotationOn,
      isAtomVibrationOn: isAtomVibrationOn,
      isAtomBreathingOn: isAtomBreathingOn,
      isCellHighlightOn: isCellHighlightOn,
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

  /// Sets atom rotation on/off.
  void setAtomRotationOn(bool value) {
    if (state.isAtomRotationOn != value) {
      state = state.copyWith(isAtomRotationOn: value);
      _settingsRepository.setAtomRotationOn(value);
    }
  }

  /// Sets atom vibration on/off.
  void setAtomVibrationOn(bool value) {
    if (state.isAtomVibrationOn != value) {
      state = state.copyWith(isAtomVibrationOn: value);
      _settingsRepository.setAtomVibrationOn(value);
    }
  }

  /// Sets atom breathing on/off.
  void setAtomBreathingOn(bool value) {
    if (state.isAtomBreathingOn != value) {
      state = state.copyWith(isAtomBreathingOn: value);
      _settingsRepository.setAtomBreathingOn(value);
    }
  }

  /// Sets cell highlight on/off.
  void setCellHighlightOn(bool value) {
    if (state.isCellHighlightOn != value) {
      state = state.copyWith(isCellHighlightOn: value);
      _settingsRepository.setCellHighlightOn(value);
    }
  }

  /// Resets all settings to defaults.
  Future<void> resetSettings() async {
    await _settingsRepository.clearSettings();
    await _loadSettings();
  }
}

/// Main theme provider.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

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
