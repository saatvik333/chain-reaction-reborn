import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'purchase_validation_service.dart';
import 'purchase_state_manager.dart';

/// Service to handle In-App Purchases (IAP).
class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late final PurchaseValidationService _validationService;
  late final PurchaseStateManager _stateManager;

  // Callback to notify listeners (e.g., ShopNotifier) about successful purchases
  final Function(String productID) onPurchaseCompleted;

  // Callback for purchase errors
  final Function(String error)? onError;

  // Callback for purchase validation updates
  final Function(String productId, bool isValid)? onValidationComplete;

  IAPService({
    required this.onPurchaseCompleted,
    this.onError,
    this.onValidationComplete,
    String? androidApiKey,
    String? iosSharedSecret,
  }) {
    _initializeServices(androidApiKey, iosSharedSecret);
  }

  Future<void> _initializeServices(
    String? androidApiKey,
    String? iosSharedSecret,
  ) async {
    _validationService = PurchaseValidationService(
      androidApiKey: androidApiKey,
      iosSharedSecret: iosSharedSecret,
    );
    _stateManager = PurchaseStateManager();
  }

  /// Initialize the service and start listening to purchase updates.
  Future<void> initialize() async {
    await _initializeServices(null, null);

    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        if (kDebugMode) {
          print('IAP Error: $error');
        }
        onError?.call(error.toString());
      },
    );

    // Check for pending validations on startup
    await _checkPendingValidations();
  }

  void dispose() {
    _subscription.cancel();
  }

  /// Load products from the store.
  Future<List<ProductDetails>> loadProducts(Set<String> ids) async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      if (kDebugMode) {
        print('IAP Store not available');
      }
      return [];
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      if (kDebugMode) {
        print('IAP Products not found: ${response.notFoundIDs}');
      }
    }

    // Sort products by price if needed, or return as is
    return response.productDetails;
  }

  /// Purchase a non-consumable product (e.g., Theme).
  Future<void> buyNonConsumable(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Purchase a consumable product (e.g., "Buy me a coffee").
  Future<void> buyConsumable(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  /// Restore purchases (for non-consumables).
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Check for purchases that need validation
  Future<void> _checkPendingValidations() async {
    if (!await _stateManager.needsValidationCheck()) {
      return;
    }

    final allPurchases = await _stateManager.getAllPurchases();
    final now = DateTime.now();

    for (final purchase in allPurchases.values) {
      if (purchase.needsValidation) {
        await _validatePurchase(purchase.transactionId, purchase.productId);
      }
    }

    await _stateManager.setLastValidationCheck(now);
  }

  /// Validate a purchase and update its state
  Future<void> _validatePurchase(String transactionId, String productId) async {
    try {
      // Get the current purchase details
      final purchaseInfo = await _stateManager.getPurchase(transactionId);
      if (purchaseInfo == null) return;

      // Simulate validation - in real implementation, you'd validate with app stores
      final validation = await _validationService.validatePurchase(
        PurchaseDetails(
          purchaseID: transactionId,
          productID: productId,
          status: PurchaseStatus.purchased,
          transactionDate: purchaseInfo.purchaseDate.toIso8601String(),
          verificationData: PurchaseVerificationData(
            source: 'app_store',
            localVerificationData: '',
            serverVerificationData: '',
          ),
        ),
      );

      // Update purchase state based on validation
      switch (validation.result) {
        case ValidationResult.valid:
          await _stateManager.updatePurchaseState(
            transactionId,
            PurchaseState.validated,
            validationDate: validation.purchaseDate,
            expiryDate: validation.expiryDate,
          );
          onValidationComplete?.call(productId, true);
          break;
        case ValidationResult.invalid:
        case ValidationResult.expired:
        case ValidationResult.refunded:
        case ValidationResult.revoked:
        case ValidationResult.cancelled:
          await _stateManager.updatePurchaseState(
            transactionId,
            _mapValidationResultToPurchaseState(validation.result),
            errorMessage: validation.errorMessage,
          );
          onValidationComplete?.call(productId, false);
          break;
        case ValidationResult.pending:
          // Keep as pending
          break;
        case ValidationResult.error:
          await _stateManager.updatePurchaseState(
            transactionId,
            PurchaseState.failed,
            errorMessage: validation.errorMessage,
          );
          onValidationComplete?.call(productId, false);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error validating purchase $transactionId: $e');
      }
    }
  }

  /// Map validation result to purchase state
  PurchaseState _mapValidationResultToPurchaseState(ValidationResult result) {
    switch (result) {
      case ValidationResult.valid:
        return PurchaseState.validated;
      case ValidationResult.pending:
        return PurchaseState.pending;
      case ValidationResult.expired:
        return PurchaseState.expired;
      case ValidationResult.refunded:
        return PurchaseState.refunded;
      case ValidationResult.revoked:
        return PurchaseState.revoked;
      case ValidationResult.cancelled:
        return PurchaseState.failed;
      case ValidationResult.invalid:
      case ValidationResult.error:
        return PurchaseState.failed;
    }
  }

  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      final transactionId = purchaseDetails.purchaseID ?? '';
      final productId = purchaseDetails.productID;

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Create pending purchase state
        final purchaseInfo = PurchaseInfo(
          productId: productId,
          transactionId: transactionId,
          state: PurchaseState.pending,
          purchaseDate: DateTime.now(),
        );
        await _stateManager.savePurchase(purchaseInfo);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Save failed purchase
          final purchaseInfo = PurchaseInfo(
            productId: productId,
            transactionId: transactionId,
            state: PurchaseState.failed,
            purchaseDate: DateTime.now(),
            errorMessage: purchaseDetails.error?.message ?? 'Unknown error',
          );
          await _stateManager.savePurchase(purchaseInfo);
          onError?.call(purchaseDetails.error?.message ?? 'Unknown error');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Create purchased state
          final purchaseInfo = PurchaseInfo(
            productId: productId,
            transactionId: transactionId,
            state: PurchaseState.purchased,
            purchaseDate: DateTime.now(),
          );
          await _stateManager.savePurchase(purchaseInfo);

          // Validate the purchase
          await _validatePurchase(transactionId, productId);

          // Check if purchase is still valid after validation
          final updatedPurchase = await _stateManager.getPurchase(
            transactionId,
          );
          if (updatedPurchase != null && updatedPurchase.isValid) {
            onPurchaseCompleted(productId);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }
}
