// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure()';
}


}

/// @nodoc
class $AuthFailureCopyWith<$Res>  {
$AuthFailureCopyWith(AuthFailure _, $Res Function(AuthFailure) __);
}


/// Adds pattern-matching-related methods to [AuthFailure].
extension AuthFailurePatterns on AuthFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthFailureCancelled value)?  cancelled,TResult Function( AuthFailureInvalidCredentials value)?  invalidCredentials,TResult Function( AuthFailureUserNotFound value)?  userNotFound,TResult Function( AuthFailureEmailAlreadyExists value)?  emailAlreadyExists,TResult Function( AuthFailureWeakPassword value)?  weakPassword,TResult Function( AuthFailureNetwork value)?  network,TResult Function( AuthFailureSessionExpired value)?  sessionExpired,TResult Function( AuthFailureEmailNotConfirmed value)?  emailNotConfirmed,TResult Function( AuthFailureRateLimited value)?  rateLimited,TResult Function( AuthFailureUnknown value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthFailureCancelled() when cancelled != null:
return cancelled(_that);case AuthFailureInvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case AuthFailureUserNotFound() when userNotFound != null:
return userNotFound(_that);case AuthFailureEmailAlreadyExists() when emailAlreadyExists != null:
return emailAlreadyExists(_that);case AuthFailureWeakPassword() when weakPassword != null:
return weakPassword(_that);case AuthFailureNetwork() when network != null:
return network(_that);case AuthFailureSessionExpired() when sessionExpired != null:
return sessionExpired(_that);case AuthFailureEmailNotConfirmed() when emailNotConfirmed != null:
return emailNotConfirmed(_that);case AuthFailureRateLimited() when rateLimited != null:
return rateLimited(_that);case AuthFailureUnknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthFailureCancelled value)  cancelled,required TResult Function( AuthFailureInvalidCredentials value)  invalidCredentials,required TResult Function( AuthFailureUserNotFound value)  userNotFound,required TResult Function( AuthFailureEmailAlreadyExists value)  emailAlreadyExists,required TResult Function( AuthFailureWeakPassword value)  weakPassword,required TResult Function( AuthFailureNetwork value)  network,required TResult Function( AuthFailureSessionExpired value)  sessionExpired,required TResult Function( AuthFailureEmailNotConfirmed value)  emailNotConfirmed,required TResult Function( AuthFailureRateLimited value)  rateLimited,required TResult Function( AuthFailureUnknown value)  unknown,}){
final _that = this;
switch (_that) {
case AuthFailureCancelled():
return cancelled(_that);case AuthFailureInvalidCredentials():
return invalidCredentials(_that);case AuthFailureUserNotFound():
return userNotFound(_that);case AuthFailureEmailAlreadyExists():
return emailAlreadyExists(_that);case AuthFailureWeakPassword():
return weakPassword(_that);case AuthFailureNetwork():
return network(_that);case AuthFailureSessionExpired():
return sessionExpired(_that);case AuthFailureEmailNotConfirmed():
return emailNotConfirmed(_that);case AuthFailureRateLimited():
return rateLimited(_that);case AuthFailureUnknown():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthFailureCancelled value)?  cancelled,TResult? Function( AuthFailureInvalidCredentials value)?  invalidCredentials,TResult? Function( AuthFailureUserNotFound value)?  userNotFound,TResult? Function( AuthFailureEmailAlreadyExists value)?  emailAlreadyExists,TResult? Function( AuthFailureWeakPassword value)?  weakPassword,TResult? Function( AuthFailureNetwork value)?  network,TResult? Function( AuthFailureSessionExpired value)?  sessionExpired,TResult? Function( AuthFailureEmailNotConfirmed value)?  emailNotConfirmed,TResult? Function( AuthFailureRateLimited value)?  rateLimited,TResult? Function( AuthFailureUnknown value)?  unknown,}){
final _that = this;
switch (_that) {
case AuthFailureCancelled() when cancelled != null:
return cancelled(_that);case AuthFailureInvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case AuthFailureUserNotFound() when userNotFound != null:
return userNotFound(_that);case AuthFailureEmailAlreadyExists() when emailAlreadyExists != null:
return emailAlreadyExists(_that);case AuthFailureWeakPassword() when weakPassword != null:
return weakPassword(_that);case AuthFailureNetwork() when network != null:
return network(_that);case AuthFailureSessionExpired() when sessionExpired != null:
return sessionExpired(_that);case AuthFailureEmailNotConfirmed() when emailNotConfirmed != null:
return emailNotConfirmed(_that);case AuthFailureRateLimited() when rateLimited != null:
return rateLimited(_that);case AuthFailureUnknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  cancelled,TResult Function()?  invalidCredentials,TResult Function()?  userNotFound,TResult Function()?  emailAlreadyExists,TResult Function()?  weakPassword,TResult Function()?  network,TResult Function()?  sessionExpired,TResult Function()?  emailNotConfirmed,TResult Function()?  rateLimited,TResult Function( String message)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthFailureCancelled() when cancelled != null:
return cancelled();case AuthFailureInvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case AuthFailureUserNotFound() when userNotFound != null:
return userNotFound();case AuthFailureEmailAlreadyExists() when emailAlreadyExists != null:
return emailAlreadyExists();case AuthFailureWeakPassword() when weakPassword != null:
return weakPassword();case AuthFailureNetwork() when network != null:
return network();case AuthFailureSessionExpired() when sessionExpired != null:
return sessionExpired();case AuthFailureEmailNotConfirmed() when emailNotConfirmed != null:
return emailNotConfirmed();case AuthFailureRateLimited() when rateLimited != null:
return rateLimited();case AuthFailureUnknown() when unknown != null:
return unknown(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  cancelled,required TResult Function()  invalidCredentials,required TResult Function()  userNotFound,required TResult Function()  emailAlreadyExists,required TResult Function()  weakPassword,required TResult Function()  network,required TResult Function()  sessionExpired,required TResult Function()  emailNotConfirmed,required TResult Function()  rateLimited,required TResult Function( String message)  unknown,}) {final _that = this;
switch (_that) {
case AuthFailureCancelled():
return cancelled();case AuthFailureInvalidCredentials():
return invalidCredentials();case AuthFailureUserNotFound():
return userNotFound();case AuthFailureEmailAlreadyExists():
return emailAlreadyExists();case AuthFailureWeakPassword():
return weakPassword();case AuthFailureNetwork():
return network();case AuthFailureSessionExpired():
return sessionExpired();case AuthFailureEmailNotConfirmed():
return emailNotConfirmed();case AuthFailureRateLimited():
return rateLimited();case AuthFailureUnknown():
return unknown(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  cancelled,TResult? Function()?  invalidCredentials,TResult? Function()?  userNotFound,TResult? Function()?  emailAlreadyExists,TResult? Function()?  weakPassword,TResult? Function()?  network,TResult? Function()?  sessionExpired,TResult? Function()?  emailNotConfirmed,TResult? Function()?  rateLimited,TResult? Function( String message)?  unknown,}) {final _that = this;
switch (_that) {
case AuthFailureCancelled() when cancelled != null:
return cancelled();case AuthFailureInvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case AuthFailureUserNotFound() when userNotFound != null:
return userNotFound();case AuthFailureEmailAlreadyExists() when emailAlreadyExists != null:
return emailAlreadyExists();case AuthFailureWeakPassword() when weakPassword != null:
return weakPassword();case AuthFailureNetwork() when network != null:
return network();case AuthFailureSessionExpired() when sessionExpired != null:
return sessionExpired();case AuthFailureEmailNotConfirmed() when emailNotConfirmed != null:
return emailNotConfirmed();case AuthFailureRateLimited() when rateLimited != null:
return rateLimited();case AuthFailureUnknown() when unknown != null:
return unknown(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AuthFailureCancelled implements AuthFailure {
  const AuthFailureCancelled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.cancelled()';
}


}




/// @nodoc


class AuthFailureInvalidCredentials implements AuthFailure {
  const AuthFailureInvalidCredentials();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureInvalidCredentials);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.invalidCredentials()';
}


}




/// @nodoc


class AuthFailureUserNotFound implements AuthFailure {
  const AuthFailureUserNotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureUserNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.userNotFound()';
}


}




/// @nodoc


class AuthFailureEmailAlreadyExists implements AuthFailure {
  const AuthFailureEmailAlreadyExists();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureEmailAlreadyExists);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.emailAlreadyExists()';
}


}




/// @nodoc


class AuthFailureWeakPassword implements AuthFailure {
  const AuthFailureWeakPassword();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureWeakPassword);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.weakPassword()';
}


}




/// @nodoc


class AuthFailureNetwork implements AuthFailure {
  const AuthFailureNetwork();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureNetwork);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.network()';
}


}




/// @nodoc


class AuthFailureSessionExpired implements AuthFailure {
  const AuthFailureSessionExpired();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureSessionExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.sessionExpired()';
}


}




/// @nodoc


class AuthFailureEmailNotConfirmed implements AuthFailure {
  const AuthFailureEmailNotConfirmed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureEmailNotConfirmed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.emailNotConfirmed()';
}


}




/// @nodoc


class AuthFailureRateLimited implements AuthFailure {
  const AuthFailureRateLimited();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureRateLimited);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.rateLimited()';
}


}




/// @nodoc


class AuthFailureUnknown implements AuthFailure {
  const AuthFailureUnknown(this.message);
  

 final  String message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFailureUnknownCopyWith<AuthFailureUnknown> get copyWith => _$AuthFailureUnknownCopyWithImpl<AuthFailureUnknown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureUnknown&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.unknown(message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthFailureUnknownCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory $AuthFailureUnknownCopyWith(AuthFailureUnknown value, $Res Function(AuthFailureUnknown) _then) = _$AuthFailureUnknownCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AuthFailureUnknownCopyWithImpl<$Res>
    implements $AuthFailureUnknownCopyWith<$Res> {
  _$AuthFailureUnknownCopyWithImpl(this._self, this._then);

  final AuthFailureUnknown _self;
  final $Res Function(AuthFailureUnknown) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AuthFailureUnknown(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
