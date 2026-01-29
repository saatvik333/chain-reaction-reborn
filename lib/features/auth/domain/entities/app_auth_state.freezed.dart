// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppAuthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppAuthState()';
}


}

/// @nodoc
class $AppAuthStateCopyWith<$Res>  {
$AppAuthStateCopyWith(AppAuthState _, $Res Function(AppAuthState) __);
}


/// Adds pattern-matching-related methods to [AppAuthState].
extension AppAuthStatePatterns on AppAuthState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AppAuthStateInitial value)?  initial,TResult Function( AppAuthStateLoading value)?  loading,TResult Function( AppAuthStateAuthenticated value)?  authenticated,TResult Function( AppAuthStateUnauthenticated value)?  unauthenticated,TResult Function( AppAuthStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AppAuthStateInitial() when initial != null:
return initial(_that);case AppAuthStateLoading() when loading != null:
return loading(_that);case AppAuthStateAuthenticated() when authenticated != null:
return authenticated(_that);case AppAuthStateUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case AppAuthStateError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AppAuthStateInitial value)  initial,required TResult Function( AppAuthStateLoading value)  loading,required TResult Function( AppAuthStateAuthenticated value)  authenticated,required TResult Function( AppAuthStateUnauthenticated value)  unauthenticated,required TResult Function( AppAuthStateError value)  error,}){
final _that = this;
switch (_that) {
case AppAuthStateInitial():
return initial(_that);case AppAuthStateLoading():
return loading(_that);case AppAuthStateAuthenticated():
return authenticated(_that);case AppAuthStateUnauthenticated():
return unauthenticated(_that);case AppAuthStateError():
return error(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AppAuthStateInitial value)?  initial,TResult? Function( AppAuthStateLoading value)?  loading,TResult? Function( AppAuthStateAuthenticated value)?  authenticated,TResult? Function( AppAuthStateUnauthenticated value)?  unauthenticated,TResult? Function( AppAuthStateError value)?  error,}){
final _that = this;
switch (_that) {
case AppAuthStateInitial() when initial != null:
return initial(_that);case AppAuthStateLoading() when loading != null:
return loading(_that);case AppAuthStateAuthenticated() when authenticated != null:
return authenticated(_that);case AppAuthStateUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case AppAuthStateError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String userId,  String email,  String? displayName,  String? avatarUrl,  UserProfile? profile)?  authenticated,TResult Function()?  unauthenticated,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AppAuthStateInitial() when initial != null:
return initial();case AppAuthStateLoading() when loading != null:
return loading();case AppAuthStateAuthenticated() when authenticated != null:
return authenticated(_that.userId,_that.email,_that.displayName,_that.avatarUrl,_that.profile);case AppAuthStateUnauthenticated() when unauthenticated != null:
return unauthenticated();case AppAuthStateError() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String userId,  String email,  String? displayName,  String? avatarUrl,  UserProfile? profile)  authenticated,required TResult Function()  unauthenticated,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case AppAuthStateInitial():
return initial();case AppAuthStateLoading():
return loading();case AppAuthStateAuthenticated():
return authenticated(_that.userId,_that.email,_that.displayName,_that.avatarUrl,_that.profile);case AppAuthStateUnauthenticated():
return unauthenticated();case AppAuthStateError():
return error(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String userId,  String email,  String? displayName,  String? avatarUrl,  UserProfile? profile)?  authenticated,TResult? Function()?  unauthenticated,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case AppAuthStateInitial() when initial != null:
return initial();case AppAuthStateLoading() when loading != null:
return loading();case AppAuthStateAuthenticated() when authenticated != null:
return authenticated(_that.userId,_that.email,_that.displayName,_that.avatarUrl,_that.profile);case AppAuthStateUnauthenticated() when unauthenticated != null:
return unauthenticated();case AppAuthStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AppAuthStateInitial implements AppAuthState {
  const AppAuthStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAuthStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppAuthState.initial()';
}


}




/// @nodoc


class AppAuthStateLoading implements AppAuthState {
  const AppAuthStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAuthStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppAuthState.loading()';
}


}




/// @nodoc


class AppAuthStateAuthenticated implements AppAuthState {
  const AppAuthStateAuthenticated({required this.userId, required this.email, this.displayName, this.avatarUrl, this.profile});
  

 final  String userId;
 final  String email;
 final  String? displayName;
 final  String? avatarUrl;
 final  UserProfile? profile;

/// Create a copy of AppAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppAuthStateAuthenticatedCopyWith<AppAuthStateAuthenticated> get copyWith => _$AppAuthStateAuthenticatedCopyWithImpl<AppAuthStateAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAuthStateAuthenticated&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.profile, profile) || other.profile == profile));
}


@override
int get hashCode => Object.hash(runtimeType,userId,email,displayName,avatarUrl,profile);

@override
String toString() {
  return 'AppAuthState.authenticated(userId: $userId, email: $email, displayName: $displayName, avatarUrl: $avatarUrl, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $AppAuthStateAuthenticatedCopyWith<$Res> implements $AppAuthStateCopyWith<$Res> {
  factory $AppAuthStateAuthenticatedCopyWith(AppAuthStateAuthenticated value, $Res Function(AppAuthStateAuthenticated) _then) = _$AppAuthStateAuthenticatedCopyWithImpl;
@useResult
$Res call({
 String userId, String email, String? displayName, String? avatarUrl, UserProfile? profile
});


$UserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$AppAuthStateAuthenticatedCopyWithImpl<$Res>
    implements $AppAuthStateAuthenticatedCopyWith<$Res> {
  _$AppAuthStateAuthenticatedCopyWithImpl(this._self, this._then);

  final AppAuthStateAuthenticated _self;
  final $Res Function(AppAuthStateAuthenticated) _then;

/// Create a copy of AppAuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? profile = freezed,}) {
  return _then(AppAuthStateAuthenticated(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}

/// Create a copy of AppAuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

/// @nodoc


class AppAuthStateUnauthenticated implements AppAuthState {
  const AppAuthStateUnauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAuthStateUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppAuthState.unauthenticated()';
}


}




/// @nodoc


class AppAuthStateError implements AppAuthState {
  const AppAuthStateError(this.message);
  

 final  String message;

/// Create a copy of AppAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppAuthStateErrorCopyWith<AppAuthStateError> get copyWith => _$AppAuthStateErrorCopyWithImpl<AppAuthStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAuthStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppAuthState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $AppAuthStateErrorCopyWith<$Res> implements $AppAuthStateCopyWith<$Res> {
  factory $AppAuthStateErrorCopyWith(AppAuthStateError value, $Res Function(AppAuthStateError) _then) = _$AppAuthStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AppAuthStateErrorCopyWithImpl<$Res>
    implements $AppAuthStateErrorCopyWith<$Res> {
  _$AppAuthStateErrorCopyWithImpl(this._self, this._then);

  final AppAuthStateError _self;
  final $Res Function(AppAuthStateError) _then;

/// Create a copy of AppAuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AppAuthStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
