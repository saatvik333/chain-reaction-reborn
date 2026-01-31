// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onlineGameService)
const onlineGameServiceProvider = OnlineGameServiceProvider._();

final class OnlineGameServiceProvider
    extends
        $FunctionalProvider<
          OnlineGameService,
          OnlineGameService,
          OnlineGameService
        >
    with $Provider<OnlineGameService> {
  const OnlineGameServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineGameServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineGameServiceHash();

  @$internal
  @override
  $ProviderElement<OnlineGameService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnlineGameService create(Ref ref) {
    return onlineGameService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnlineGameService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnlineGameService>(value),
    );
  }
}

String _$onlineGameServiceHash() => r'07ab964be1ec5a82aa2c3104fd031fe1e05453e4';

@ProviderFor(OnlineGame)
const onlineGameProvider = OnlineGameProvider._();

final class OnlineGameProvider
    extends $AsyncNotifierProvider<OnlineGame, OnlineGameState?> {
  const OnlineGameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineGameProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineGameHash();

  @$internal
  @override
  OnlineGame create() => OnlineGame();
}

String _$onlineGameHash() => r'd198b6ba8e74e039942caed0d2310dfdac57d49e';

abstract class _$OnlineGame extends $AsyncNotifier<OnlineGameState?> {
  FutureOr<OnlineGameState?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<OnlineGameState?>, OnlineGameState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OnlineGameState?>, OnlineGameState?>,
              AsyncValue<OnlineGameState?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
