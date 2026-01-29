// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnlineGameState _$OnlineGameStateFromJson(Map<String, dynamic> json) =>
    _OnlineGameState(
      id: json['id'] as String,
      roomCode: json['room_code'] as String,
      player1Id: json['player1_id'] as String,
      player2Id: json['player2_id'] as String?,
      status: json['status'] as String,
      currentTurn: (json['current_turn'] as num).toInt(),
      winnerId: json['winner_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$OnlineGameStateToJson(_OnlineGameState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_code': instance.roomCode,
      'player1_id': instance.player1Id,
      'player2_id': instance.player2Id,
      'status': instance.status,
      'current_turn': instance.currentTurn,
      'winner_id': instance.winnerId,
      'created_at': instance.createdAt.toIso8601String(),
    };
