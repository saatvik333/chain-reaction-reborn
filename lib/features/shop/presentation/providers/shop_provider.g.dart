// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [ShopRepository].

@ProviderFor(shopRepository)
const shopRepositoryProvider = ShopRepositoryProvider._();

/// Provider for [ShopRepository].

final class ShopRepositoryProvider
    extends $FunctionalProvider<ShopRepository, ShopRepository, ShopRepository>
    with $Provider<ShopRepository> {
  /// Provider for [ShopRepository].
  const ShopRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShopRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShopRepository create(Ref ref) {
    return shopRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShopRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShopRepository>(value),
    );
  }
}

String _$shopRepositoryHash() => r'f4650e6bdb86852a4e9b9fa144c5d5444d2026e3';

@ProviderFor(ShopNotifier)
const shopProvider = ShopNotifierProvider._();

final class ShopNotifierProvider
    extends $AsyncNotifierProvider<ShopNotifier, ShopState> {
  const ShopNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopNotifierHash();

  @$internal
  @override
  ShopNotifier create() => ShopNotifier();
}

String _$shopNotifierHash() => r'2f59a7511b40346a2097ab8d851e31f4f4f43cd8';

abstract class _$ShopNotifier extends $AsyncNotifier<ShopState> {
  FutureOr<ShopState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ShopState>, ShopState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ShopState>, ShopState>,
              AsyncValue<ShopState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
