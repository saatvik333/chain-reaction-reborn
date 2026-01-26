import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/repositories/shop_repository.dart';
import '../../data/repositories/shop_repository_impl.dart';
import '../../data/services/iap_service.dart';

import '../../../settings/presentation/providers/settings_providers.dart';

// Define your product IDs here.
// In a real app, these should match the IDs in Google Play Console / App Store Connect.
const String kCoffeeId = 'support_coffee';
const Set<String> kThemeIds = {
  // Add your theme IDs here corresponding to your themes
  // e.g. 'theme_neon', 'theme_dark', etc.
  // For now we will assume we have these IDs:
  'theme_neon',
  'theme_dark',
  'theme_retro',
  // Make sure these match the IDs in your Theme collection/enum if you have one
};

/// Provider for [ShopRepository].
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ShopRepositoryImpl(prefs);
});

/// State of the shop (list of owned theme IDs and available products).
class ShopState {
  final List<String> ownedThemeIds;
  final List<ProductDetails> products;
  final bool isLoading;
  final String? errorMessage;

  ShopState({
    this.ownedThemeIds = const [],
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  bool isOwned(String themeId) => ownedThemeIds.contains(themeId);

  ProductDetails? getProduct(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  ShopState copyWith({
    List<String>? ownedThemeIds,
    List<ProductDetails>? products,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ShopState(
      ownedThemeIds: ownedThemeIds ?? this.ownedThemeIds,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Reset error message if not provided
    );
  }
}

/// Notifier for managing shop state.
class ShopNotifier extends Notifier<ShopState> {
  late final ShopRepository _repository;
  late final IAPService _iapService;

  @override
  ShopState build() {
    _repository = ref.watch(shopRepositoryProvider);
    _iapService = IAPService(
      onPurchaseCompleted: _onPurchaseCompleted,
      onError: _onPurchaseError,
      onValidationComplete: _onValidationComplete,
    );

    // Initialize IAP and load data
    _initialize();

    return ShopState(isLoading: true);
  }

  Future<void> _initialize() async {
    _iapService.initialize();
    await _loadPurchases();
    await _loadProducts();
  }

  // Dispose is not directly available in Notifier like this,
  // but ref.onDispose can be used in build if needed.
  // However, IAPService uses a stream subscription which we might want to close.
  // Since Notifier is auto-disposed or kept alive, we'll rely on Ref lifecycle.
  // For now, simple implementation.

  Future<void> _loadPurchases() async {
    final ids = await _repository.getPurchasedThemeIds();
    state = state.copyWith(ownedThemeIds: ids);
  }

  Future<void> _loadProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final allIds = {...kThemeIds, kCoffeeId};
      final products = await _iapService.loadProducts(allIds);
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load products',
      );
    }
  }

  Future<void> purchaseTheme(ProductDetails product) async {
    state = state.copyWith(isLoading: true);
    await _iapService.buyNonConsumable(product);
    // State update happens in _onPurchaseCompleted
  }

  Future<void> buyCoffee(ProductDetails product) async {
    state = state.copyWith(isLoading: true);
    await _iapService.buyConsumable(product);
    // State update happens in _onPurchaseCompleted
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    await _iapService.restorePurchases();
    state = state.copyWith(isLoading: false);
  }

  void _onPurchaseCompleted(String productId) async {
    if (productId == kCoffeeId) {
      // "Coffee" purchased. Just show a thank you?
      // We might want to expose a "showThankYou" state or event.
      // For now, just stop loading.
      state = state.copyWith(isLoading: false);
    } else {
      // It's a theme - only mark as purchased after validation
      // The actual purchase marking happens in the validation service
      // Just reload purchases to get the updated state
      await _loadPurchases();
      state = state.copyWith(isLoading: false);
    }
  }

  void _onPurchaseError(String error) {
    state = state.copyWith(isLoading: false, errorMessage: error);
  }

  void _onValidationComplete(String productId, bool isValid) {
    if (!isValid) {
      // Handle invalid purchase - could remove from owned items
      final updatedOwnedThemeIds = List<String>.from(state.ownedThemeIds)
        ..remove(productId);
      state = state.copyWith(ownedThemeIds: updatedOwnedThemeIds);
    }
  }
}

/// Main shop provider.
final shopProvider = NotifierProvider<ShopNotifier, ShopState>(
  ShopNotifier.new,
);
