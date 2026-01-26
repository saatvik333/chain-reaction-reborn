import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

/// Purchase validation result
enum ValidationResult {
  valid,
  invalid,
  pending,
  expired,
  refunded,
  cancelled,
  error,
  revoked,
}

/// Validated purchase information
class ValidatedPurchase {
  final String productId;
  final String transactionId;
  final ValidationResult result;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String? errorMessage;

  ValidatedPurchase({
    required this.productId,
    required this.transactionId,
    required this.result,
    this.purchaseDate,
    this.expiryDate,
    this.errorMessage,
  });
}

/// Service for validating purchase receipts with app stores
class PurchaseValidationService {
  // In production, these should be stored securely (environment variables, key management)
  final String? _androidApiKey;
  final String? _iosSharedSecret;

  PurchaseValidationService({String? androidApiKey, String? iosSharedSecret})
    : _androidApiKey = androidApiKey,
      _iosSharedSecret = iosSharedSecret;

  /// Validate a purchase receipt
  Future<ValidatedPurchase> validatePurchase(PurchaseDetails purchase) async {
    try {
      if (Platform.isAndroid) {
        return await _validateAndroidPurchase(purchase);
      } else if (Platform.isIOS) {
        return await _validateIOSPurchase(purchase);
      } else {
        return ValidatedPurchase(
          productId: purchase.productID,
          transactionId: purchase.purchaseID ?? '',
          result: ValidationResult.error,
          errorMessage: 'Unsupported platform',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Purchase validation error: $e');
      }
      return ValidatedPurchase(
        productId: purchase.productID,
        transactionId: purchase.purchaseID ?? '',
        result: ValidationResult.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Validate Android purchase
  Future<ValidatedPurchase> _validateAndroidPurchase(
    PurchaseDetails purchase,
  ) async {
    // Basic local data integrity check
    if (purchase.verificationData.localVerificationData.isEmpty) {
      return ValidatedPurchase(
        productId: purchase.productID,
        transactionId: purchase.purchaseID ?? '',
        result: ValidationResult.invalid,
        errorMessage: 'Missing local verification data',
      );
    }

    // In a real implementation with backend, we would verify the signature here
    // checking verificationData.serverVerificationData with public key.

    // For now, checks are consistent with local store status
    return ValidatedPurchase(
      productId: purchase.productID,
      transactionId: purchase.purchaseID ?? '',
      result: ValidationResult.valid,
      purchaseDate: DateTime.now(),
    );
  }

  /// Validate iOS purchase
  Future<ValidatedPurchase> _validateIOSPurchase(
    PurchaseDetails purchase,
  ) async {
    // Basic local data integrity check
    if (purchase.verificationData.localVerificationData.isEmpty) {
      return ValidatedPurchase(
        productId: purchase.productID,
        transactionId: purchase.purchaseID ?? '',
        result: ValidationResult.invalid,
        errorMessage: 'Missing receipt data',
      );
    }

    // In a real implementation with backend, we would send this receipt
    // to Apple servers via our backend.

    return ValidatedPurchase(
      productId: purchase.productID,
      transactionId: purchase.purchaseID ?? '',
      result: ValidationResult.valid,
      purchaseDate: DateTime.now(),
    );
  }

  /// Check if validation service is properly configured
  bool get isConfigured {
    if (Platform.isAndroid) {
      return _androidApiKey != null;
    } else if (Platform.isIOS) {
      return _iosSharedSecret != null;
    }
    return false;
  }
}
