// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Google Sign-In provider

@ProviderFor(googleSignIn)
const googleSignInProvider = GoogleSignInProvider._();

/// Google Sign-In provider

final class GoogleSignInProvider
    extends $FunctionalProvider<GoogleSignIn, GoogleSignIn, GoogleSignIn>
    with $Provider<GoogleSignIn> {
  /// Google Sign-In provider
  const GoogleSignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleSignInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleSignInHash();

  @$internal
  @override
  $ProviderElement<GoogleSignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoogleSignIn create(Ref ref) {
    return googleSignIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleSignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleSignIn>(value),
    );
  }
}

String _$googleSignInHash() => r'b1c381c93fa98ec01719c08c4c165dbc439ae3e1';

/// Auth repository provider

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// Auth repository provider

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Auth repository provider
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'904b7e379edbb3970fdeeaae8ad0072287f1f5ec';

/// Auth mode provider (true = login, false = signup)

@ProviderFor(AuthMode)
const authModeProvider = AuthModeProvider._();

/// Auth mode provider (true = login, false = signup)
final class AuthModeProvider extends $NotifierProvider<AuthMode, bool> {
  /// Auth mode provider (true = login, false = signup)
  const AuthModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authModeHash();

  @$internal
  @override
  AuthMode create() => AuthMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authModeHash() => r'07cc367305bad11a170e54d5fe9e3cb7bf377e49';

/// Auth mode provider (true = login, false = signup)

abstract class _$AuthMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Auth state notifier

@ProviderFor(AuthNotifier)
const authProvider = AuthNotifierProvider._();

/// Auth state notifier
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AppAuthState> {
  /// Auth state notifier
  const AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppAuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppAuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'de332883dd8bfa75428b624b28e41d5938ce3c13';

/// Auth state notifier

abstract class _$AuthNotifier extends $Notifier<AppAuthState> {
  AppAuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppAuthState, AppAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppAuthState, AppAuthState>,
              AppAuthState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
