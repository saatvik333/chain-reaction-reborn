// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnlineGameState {

 String get id;@JsonKey(name: 'room_code') String get roomCode;@JsonKey(name: 'player1_id') String get player1Id;@JsonKey(name: 'player2_id') String? get player2Id; String get status;@JsonKey(name: 'current_turn') int get currentTurn;@JsonKey(name: 'winner_id') String? get winnerId;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of OnlineGameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlineGameStateCopyWith<OnlineGameState> get copyWith => _$OnlineGameStateCopyWithImpl<OnlineGameState>(this as OnlineGameState, _$identity);

  /// Serializes this OnlineGameState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlineGameState&&(identical(other.id, id) || other.id == id)&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.player1Id, player1Id) || other.player1Id == player1Id)&&(identical(other.player2Id, player2Id) || other.player2Id == player2Id)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentTurn, currentTurn) || other.currentTurn == currentTurn)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomCode,player1Id,player2Id,status,currentTurn,winnerId,createdAt);

@override
String toString() {
  return 'OnlineGameState(id: $id, roomCode: $roomCode, player1Id: $player1Id, player2Id: $player2Id, status: $status, currentTurn: $currentTurn, winnerId: $winnerId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OnlineGameStateCopyWith<$Res>  {
  factory $OnlineGameStateCopyWith(OnlineGameState value, $Res Function(OnlineGameState) _then) = _$OnlineGameStateCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'room_code') String roomCode,@JsonKey(name: 'player1_id') String player1Id,@JsonKey(name: 'player2_id') String? player2Id, String status,@JsonKey(name: 'current_turn') int currentTurn,@JsonKey(name: 'winner_id') String? winnerId,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$OnlineGameStateCopyWithImpl<$Res>
    implements $OnlineGameStateCopyWith<$Res> {
  _$OnlineGameStateCopyWithImpl(this._self, this._then);

  final OnlineGameState _self;
  final $Res Function(OnlineGameState) _then;

/// Create a copy of OnlineGameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roomCode = null,Object? player1Id = null,Object? player2Id = freezed,Object? status = null,Object? currentTurn = null,Object? winnerId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String,player1Id: null == player1Id ? _self.player1Id : player1Id // ignore: cast_nullable_to_non_nullable
as String,player2Id: freezed == player2Id ? _self.player2Id : player2Id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentTurn: null == currentTurn ? _self.currentTurn : currentTurn // ignore: cast_nullable_to_non_nullable
as int,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OnlineGameState].
extension OnlineGameStatePatterns on OnlineGameState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnlineGameState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnlineGameState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnlineGameState value)  $default,){
final _that = this;
switch (_that) {
case _OnlineGameState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnlineGameState value)?  $default,){
final _that = this;
switch (_that) {
case _OnlineGameState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_code')  String roomCode, @JsonKey(name: 'player1_id')  String player1Id, @JsonKey(name: 'player2_id')  String? player2Id,  String status, @JsonKey(name: 'current_turn')  int currentTurn, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnlineGameState() when $default != null:
return $default(_that.id,_that.roomCode,_that.player1Id,_that.player2Id,_that.status,_that.currentTurn,_that.winnerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_code')  String roomCode, @JsonKey(name: 'player1_id')  String player1Id, @JsonKey(name: 'player2_id')  String? player2Id,  String status, @JsonKey(name: 'current_turn')  int currentTurn, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _OnlineGameState():
return $default(_that.id,_that.roomCode,_that.player1Id,_that.player2Id,_that.status,_that.currentTurn,_that.winnerId,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'room_code')  String roomCode, @JsonKey(name: 'player1_id')  String player1Id, @JsonKey(name: 'player2_id')  String? player2Id,  String status, @JsonKey(name: 'current_turn')  int currentTurn, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OnlineGameState() when $default != null:
return $default(_that.id,_that.roomCode,_that.player1Id,_that.player2Id,_that.status,_that.currentTurn,_that.winnerId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnlineGameState implements OnlineGameState {
  const _OnlineGameState({required this.id, @JsonKey(name: 'room_code') required this.roomCode, @JsonKey(name: 'player1_id') required this.player1Id, @JsonKey(name: 'player2_id') this.player2Id, required this.status, @JsonKey(name: 'current_turn') required this.currentTurn, @JsonKey(name: 'winner_id') this.winnerId, @JsonKey(name: 'created_at') required this.createdAt});
  factory _OnlineGameState.fromJson(Map<String, dynamic> json) => _$OnlineGameStateFromJson(json);

@override final  String id;
@override@JsonKey(name: 'room_code') final  String roomCode;
@override@JsonKey(name: 'player1_id') final  String player1Id;
@override@JsonKey(name: 'player2_id') final  String? player2Id;
@override final  String status;
@override@JsonKey(name: 'current_turn') final  int currentTurn;
@override@JsonKey(name: 'winner_id') final  String? winnerId;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of OnlineGameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnlineGameStateCopyWith<_OnlineGameState> get copyWith => __$OnlineGameStateCopyWithImpl<_OnlineGameState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnlineGameStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnlineGameState&&(identical(other.id, id) || other.id == id)&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.player1Id, player1Id) || other.player1Id == player1Id)&&(identical(other.player2Id, player2Id) || other.player2Id == player2Id)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentTurn, currentTurn) || other.currentTurn == currentTurn)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomCode,player1Id,player2Id,status,currentTurn,winnerId,createdAt);

@override
String toString() {
  return 'OnlineGameState(id: $id, roomCode: $roomCode, player1Id: $player1Id, player2Id: $player2Id, status: $status, currentTurn: $currentTurn, winnerId: $winnerId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OnlineGameStateCopyWith<$Res> implements $OnlineGameStateCopyWith<$Res> {
  factory _$OnlineGameStateCopyWith(_OnlineGameState value, $Res Function(_OnlineGameState) _then) = __$OnlineGameStateCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'room_code') String roomCode,@JsonKey(name: 'player1_id') String player1Id,@JsonKey(name: 'player2_id') String? player2Id, String status,@JsonKey(name: 'current_turn') int currentTurn,@JsonKey(name: 'winner_id') String? winnerId,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$OnlineGameStateCopyWithImpl<$Res>
    implements _$OnlineGameStateCopyWith<$Res> {
  __$OnlineGameStateCopyWithImpl(this._self, this._then);

  final _OnlineGameState _self;
  final $Res Function(_OnlineGameState) _then;

/// Create a copy of OnlineGameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? roomCode = null,Object? player1Id = null,Object? player2Id = freezed,Object? status = null,Object? currentTurn = null,Object? winnerId = freezed,Object? createdAt = null,}) {
  return _then(_OnlineGameState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String,player1Id: null == player1Id ? _self.player1Id : player1Id // ignore: cast_nullable_to_non_nullable
as String,player2Id: freezed == player2Id ? _self.player2Id : player2Id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentTurn: null == currentTurn ? _self.currentTurn : currentTurn // ignore: cast_nullable_to_non_nullable
as int,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
