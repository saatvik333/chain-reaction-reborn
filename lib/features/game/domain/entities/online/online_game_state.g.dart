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
      currentPlayerIndex: (json['current_player_index'] as num?)?.toInt() ?? 0,
      turnNumber: (json['turn_number'] as num?)?.toInt() ?? 0,
      winnerId: json['winner_id'] as String?,
      gameState: json['game_state'] as Map<String, dynamic>?,
      gridRows: (json['grid_rows'] as num?)?.toInt() ?? 8,
      gridCols: (json['grid_cols'] as num?)?.toInt() ?? 6,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$OnlineGameStateToJson(_OnlineGameState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_code': instance.roomCode,
      'player1_id': instance.player1Id,
      'player2_id': instance.player2Id,
      'status': instance.status,
      'current_player_index': instance.currentPlayerIndex,
      'turn_number': instance.turnNumber,
      'winner_id': instance.winnerId,
      'game_state': instance.gameState,
      'grid_rows': instance.gridRows,
      'grid_cols': instance.gridCols,
      'created_at': instance.createdAt.toIso8601String(),
    };
