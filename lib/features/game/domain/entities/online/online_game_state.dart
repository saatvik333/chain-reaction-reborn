// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

// ignore: unused_import
// import 'package:flutter/foundation.dart';

part 'online_game_state.freezed.dart';
part 'online_game_state.g.dart';

@freezed
abstract class OnlineGameState with _$OnlineGameState {
  const factory OnlineGameState({
    required String id,
    @JsonKey(name: 'room_code') required String roomCode,
    @JsonKey(name: 'player1_id') required String player1Id,
    @JsonKey(name: 'player2_id') String? player2Id,
    required String status,
    @JsonKey(name: 'current_turn') required int currentTurn,
    @JsonKey(name: 'winner_id') String? winnerId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Add other fields as needed based on your DB schema
  }) = _OnlineGameState;

  factory OnlineGameState.fromJson(Map<String, dynamic> json) =>
      _$OnlineGameStateFromJson(json);
}
