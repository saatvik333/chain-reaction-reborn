import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/shop_repository.dart';
import '../../data/repositories/shop_repository_impl.dart';
import '../../data/services/iap_service.dart';

import '../../../settings/presentation/providers/settings_providers.dart';

part 'shop_provider.freezed.dart';
part 'shop_provider.g.dart';

// Define your product IDs here.
// Note: These must match AppTheme.name exactly because the app uses name as ID.
// In a real app, you might map 'Earthy' -> 'chain_reaction_earthy'.
const String kCoffeeId = 'support_coffee';
const Set<String> kThemeIds = {'Earthy', 'Pastel', 'Amoled'};

/// Provider for [ShopRepository].
@riverpod
ShopRepository shopRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ShopRepositoryImpl(prefs);
}

@freezed
abstract class ShopState with _$ShopState {
  const ShopState._();

  const factory ShopState({
    @Default([]) List<String> ownedThemeIds,
    @Default([]) List<ProductDetails> products,
  }) = _ShopState;

  bool isOwned(String themeId) => ownedThemeIds.contains(themeId);

  ProductDetails? getProduct(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

@riverpod
class ShopNotifier extends _$ShopNotifier {
  late final ShopRepository _repository;
  late final IAPService _iapService;

  @override
  Future<ShopState> build() async {
    _repository = ref.watch(shopRepositoryProvider);
    _iapService = IAPService(
      onPurchaseCompleted: _onPurchaseCompleted,
      onError: _onPurchaseError,
      onValidationComplete: _onValidationComplete,
    );

    // Initialize IAP
    _iapService.initialize();

    // Load initial data
    var ownedIds = await _repository.getPurchasedThemeIds();

    // In debug mode, unlock all themes for testing
    if (kDebugMode) {
      ownedIds = kThemeIds.toList();
    }

    List<ProductDetails> products = [];
    try {
      final allIds = {...kThemeIds, kCoffeeId};
      products = await _iapService.loadProducts(allIds);
    } catch (e) {
      // Products failed to load, but we can still show owned themes
      // We could also throw here to show error state in UI
      // but partial state is often better for UX (can still see owned stuff)
    }

    return ShopState(ownedThemeIds: ownedIds, products: products);
  }

  Future<void> purchaseTheme(ProductDetails product) async {
    state = const AsyncValue.loading();
    try {
      await _iapService.buyNonConsumable(product);
      // State updates via callbacks
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> buyCoffee(ProductDetails product) async {
    state = const AsyncValue.loading();
    try {
      await _iapService.buyConsumable(product);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();
    try {
      await _iapService.restorePurchases();
      // Completion is handled via the purchase updates stream.
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _onPurchaseCompleted(String productId) async {
    // Reload state to reflect changes
    // Reload owned IDs to reflect the new purchase.
    try {
      final currentProducts = state.value?.products ?? [];
      final ids = await _repository.getPurchasedThemeIds();

      state = AsyncValue.data(
        ShopState(ownedThemeIds: ids, products: currentProducts),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _onPurchaseError(String error) {
    state = AsyncValue.error(error, StackTrace.current);
  }

  void _onValidationComplete(String productId, bool isValid) {
    if (!isValid) {
      final currentState = state.asData?.value;
      if (currentState != null) {
        final updatedOwnedThemeIds = List<String>.from(
          currentState.ownedThemeIds,
        )..remove(productId);

        state = AsyncValue.data(
          currentState.copyWith(ownedThemeIds: updatedOwnedThemeIds),
        );
      }
    }
  }
}
