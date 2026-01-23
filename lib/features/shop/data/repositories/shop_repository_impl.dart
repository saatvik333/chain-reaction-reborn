import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/shop_repository.dart';

/// Implementation of [ShopRepository] using [SharedPreferences].
class ShopRepositoryImpl implements ShopRepository {
  final SharedPreferences _prefs;
  static const String _keyPurchasedThemes = 'purchased_themes';

  ShopRepositoryImpl(this._prefs);

  @override
  Future<List<String>> getPurchasedThemeIds() async {
    return _prefs.getStringList(_keyPurchasedThemes) ?? [];
  }

  @override
  Future<void> purchaseTheme(String themeId) async {
    final purchased = await getPurchasedThemeIds();
    if (!purchased.contains(themeId)) {
      final updated = [...purchased, themeId];
      await _prefs.setStringList(_keyPurchasedThemes, updated);
    }
  }

  @override
  Future<bool> isThemeOwned(String themeId) async {
    final purchased = await getPurchasedThemeIds();
    return purchased.contains(themeId);
  }

  @override
  Future<void> clearPurchases() async {
    await _prefs.remove(_keyPurchasedThemes);
  }
}
