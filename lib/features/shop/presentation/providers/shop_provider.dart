import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/shop_repository.dart';
import '../../data/repositories/shop_repository_impl.dart';

import '../../../settings/domain/providers/settings_providers.dart';

/// Provider for [ShopRepository].
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ShopRepositoryImpl(prefs);
});

/// State of the shop (list of owned theme IDs).
class ShopState {
  final List<String> ownedThemeIds;

  ShopState({this.ownedThemeIds = const []});

  bool isOwned(String themeId) => ownedThemeIds.contains(themeId);
}

/// Notifier for managing shop state.
class ShopNotifier extends Notifier<ShopState> {
  late final ShopRepository _repository;

  @override
  ShopState build() {
    _repository = ref.watch(shopRepositoryProvider);
    _loadPurchases();
    return ShopState();
  }

  Future<void> _loadPurchases() async {
    final ids = await _repository.getPurchasedThemeIds();
    state = ShopState(ownedThemeIds: ids);
  }

  Future<void> purchaseTheme(String themeId) async {
    await _repository.purchaseTheme(themeId);
    await _loadPurchases(); // Refresh state
  }

  Future<void> restorePurchases() async {
    // In a real app, this would query the store backend.
    // For now, it just reloads local storage.
    await _loadPurchases();
  }
}

/// Main shop provider.
final shopProvider = NotifierProvider<ShopNotifier, ShopState>(
  ShopNotifier.new,
);
