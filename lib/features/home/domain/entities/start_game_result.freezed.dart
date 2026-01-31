// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'start_game_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StartGameResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartGameResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StartGameResult()';
}


}

/// @nodoc
class $StartGameResultCopyWith<$Res>  {
$StartGameResultCopyWith(StartGameResult _, $Res Function(StartGameResult) __);
}


/// Adds pattern-matching-related methods to [StartGameResult].
extension StartGameResultPatterns on StartGameResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( StartGameResultSuccess value)?  success,TResult Function( StartGameResultRequiresAuth value)?  requiresAuth,TResult Function( StartGameResultInvalidCode value)?  invalidCode,required TResult orElse(),}){
final _that = this;
switch (_that) {
case StartGameResultSuccess() when success != null:
return success(_that);case StartGameResultRequiresAuth() when requiresAuth != null:
return requiresAuth(_that);case StartGameResultInvalidCode() when invalidCode != null:
return invalidCode(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( StartGameResultSuccess value)  success,required TResult Function( StartGameResultRequiresAuth value)  requiresAuth,required TResult Function( StartGameResultInvalidCode value)  invalidCode,}){
final _that = this;
switch (_that) {
case StartGameResultSuccess():
return success(_that);case StartGameResultRequiresAuth():
return requiresAuth(_that);case StartGameResultInvalidCode():
return invalidCode(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( StartGameResultSuccess value)?  success,TResult? Function( StartGameResultRequiresAuth value)?  requiresAuth,TResult? Function( StartGameResultInvalidCode value)?  invalidCode,}){
final _that = this;
switch (_that) {
case StartGameResultSuccess() when success != null:
return success(_that);case StartGameResultRequiresAuth() when requiresAuth != null:
return requiresAuth(_that);case StartGameResultInvalidCode() when invalidCode != null:
return invalidCode(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  success,TResult Function()?  requiresAuth,TResult Function()?  invalidCode,required TResult orElse(),}) {final _that = this;
switch (_that) {
case StartGameResultSuccess() when success != null:
return success();case StartGameResultRequiresAuth() when requiresAuth != null:
return requiresAuth();case StartGameResultInvalidCode() when invalidCode != null:
return invalidCode();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  success,required TResult Function()  requiresAuth,required TResult Function()  invalidCode,}) {final _that = this;
switch (_that) {
case StartGameResultSuccess():
return success();case StartGameResultRequiresAuth():
return requiresAuth();case StartGameResultInvalidCode():
return invalidCode();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  success,TResult? Function()?  requiresAuth,TResult? Function()?  invalidCode,}) {final _that = this;
switch (_that) {
case StartGameResultSuccess() when success != null:
return success();case StartGameResultRequiresAuth() when requiresAuth != null:
return requiresAuth();case StartGameResultInvalidCode() when invalidCode != null:
return invalidCode();case _:
  return null;

}
}

}

/// @nodoc


class StartGameResultSuccess implements StartGameResult {
  const StartGameResultSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartGameResultSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StartGameResult.success()';
}


}




/// @nodoc


class StartGameResultRequiresAuth implements StartGameResult {
  const StartGameResultRequiresAuth();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartGameResultRequiresAuth);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StartGameResult.requiresAuth()';
}


}




/// @nodoc


class StartGameResultInvalidCode implements StartGameResult {
  const StartGameResultInvalidCode();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartGameResultInvalidCode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StartGameResult.invalidCode()';
}


}




// dart format on
