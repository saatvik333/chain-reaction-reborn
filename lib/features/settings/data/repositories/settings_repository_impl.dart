import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

/// Implementation of [SettingsRepository] using [SharedPreferences].
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  static const String _keyDarkMode = 'isDarkMode';
  static const String _keySoundOn = 'isSoundOn';
  static const String _keyHapticOn = 'isHapticOn';
  static const String _keyThemeName = 'themeName';

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<bool?> getDarkMode() async {
    return _prefs.getBool(_keyDarkMode);
  }

  @override
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }

  @override
  Future<bool?> getSoundOn() async {
    return _prefs.getBool(_keySoundOn);
  }

  @override
  Future<void> setSoundOn(bool value) async {
    await _prefs.setBool(_keySoundOn, value);
  }

  @override
  Future<bool?> getHapticOn() async {
    return _prefs.getBool(_keyHapticOn);
  }

  @override
  Future<void> setHapticOn(bool value) async {
    await _prefs.setBool(_keyHapticOn, value);
  }

  @override
  Future<String?> getThemeName() async {
    return _prefs.getString(_keyThemeName);
  }

  @override
  Future<void> setThemeName(String value) async {
    await _prefs.setString(_keyThemeName, value);
  }

  static const String _keyAtomRotationOn = 'isAtomRotationOn';
  static const String _keyAtomVibrationOn = 'isAtomVibrationOn';

  @override
  Future<bool?> getAtomRotationOn() async {
    return _prefs.getBool(_keyAtomRotationOn);
  }

  @override
  Future<void> setAtomRotationOn(bool value) async {
    await _prefs.setBool(_keyAtomRotationOn, value);
  }

  @override
  Future<bool?> getAtomVibrationOn() async {
    return _prefs.getBool(_keyAtomVibrationOn);
  }

  @override
  Future<void> setAtomVibrationOn(bool value) async {
    await _prefs.setBool(_keyAtomVibrationOn, value);
  }

  static const String _keyCellHighlightOn = 'isCellHighlightOn';

  @override
  Future<bool?> getCellHighlightOn() async {
    return _prefs.getBool(_keyCellHighlightOn);
  }

  @override
  Future<void> setCellHighlightOn(bool value) async {
    await _prefs.setBool(_keyCellHighlightOn, value);
  }

  static const String _keyAtomBreathingOn = 'isAtomBreathingOn';

  @override
  Future<bool?> getAtomBreathingOn() async {
    return _prefs.getBool(_keyAtomBreathingOn);
  }

  @override
  Future<void> setAtomBreathingOn(bool value) async {
    await _prefs.setBool(_keyAtomBreathingOn, value);
  }

  @override
  Future<void> clearSettings() async {
    await Future.wait([
      _prefs.remove(_keyDarkMode),
      _prefs.remove(_keySoundOn),
      _prefs.remove(_keyHapticOn),
      _prefs.remove(_keyThemeName),
      _prefs.remove(_keyAtomRotationOn),
      _prefs.remove(_keyAtomVibrationOn),
      _prefs.remove(_keyCellHighlightOn),
      _prefs.remove(_keyAtomBreathingOn),
    ]);
  }
}
