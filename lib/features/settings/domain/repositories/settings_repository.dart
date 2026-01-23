/// Repository for managing app settings.
abstract interface class SettingsRepository {
  /// Loads the saved dark mode preference.
  Future<bool?> getDarkMode();

  /// Saves the dark mode preference.
  Future<void> setDarkMode(bool value);

  /// Loads the saved sound preference.
  Future<bool?> getSoundOn();

  /// Saves the sound preference.
  Future<void> setSoundOn(bool value);

  /// Loads the saved haptic feedback preference.
  Future<bool?> getHapticOn();

  /// Saves the haptic feedback preference.
  Future<void> setHapticOn(bool value);

  /// Loads the saved theme name.
  Future<String?> getThemeName();

  /// Saves the theme name.
  Future<void> setThemeName(String value);
}
