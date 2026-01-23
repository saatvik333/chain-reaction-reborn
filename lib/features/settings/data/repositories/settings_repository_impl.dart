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
}
