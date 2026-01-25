/// Repository for managing app settings.
abstract interface class SettingsRepository {
  /// Loads the saved dark mode preference.
  Future<bool?> getDarkMode();

  /// Saves the dark mode preference.
  Future<void> setDarkMode(bool value);

  /// Loads the saved haptic feedback preference.
  Future<bool?> getHapticOn();

  /// Saves the haptic feedback preference.
  Future<void> setHapticOn(bool value);

  /// Loads the saved theme name.
  Future<String?> getThemeName();

  /// Saves the theme name.
  Future<void> setThemeName(String value);

  /// Loads the saved atom rotation preference.
  Future<bool?> getAtomRotationOn();

  /// Saves the atom rotation preference.
  Future<void> setAtomRotationOn(bool value);

  /// Loads the saved atom vibration preference.
  Future<bool?> getAtomVibrationOn();

  /// Saves the atom vibration preference.
  Future<void> setAtomVibrationOn(bool value);

  /// Loads the saved cell highlight preference.
  Future<bool?> getCellHighlightOn();

  /// Saves the cell highlight preference.
  Future<void> setCellHighlightOn(bool value);

  /// Loads the saved atom breathing preference.
  Future<bool?> getAtomBreathingOn();

  /// Saves the atom breathing preference.
  Future<void> setAtomBreathingOn(bool value);

  /// Clears all saved settings, restoring defaults.
  Future<void> clearSettings();
}
