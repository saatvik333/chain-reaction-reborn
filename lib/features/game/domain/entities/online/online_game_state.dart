// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'online_game_state.freezed.dart';
part 'online_game_state.g.dart';

@freezed
abstract class OnlineGameState with _$OnlineGameState {
  const OnlineGameState._();

  const factory OnlineGameState({
    required String id,
    @JsonKey(name: 'room_code') required String roomCode,
    @JsonKey(name: 'player1_id') required String player1Id,
    @JsonKey(name: 'player2_id') String? player2Id,
    required String status,
    @JsonKey(name: 'current_player_index') @Default(0) int currentPlayerIndex,
    @JsonKey(name: 'turn_number') @Default(0) int turnNumber,
    @JsonKey(name: 'winner_id') String? winnerId,
    @JsonKey(name: 'game_state') Map<String, dynamic>? gameState,
    @JsonKey(name: 'grid_rows') @Default(8) int gridRows,
    @JsonKey(name: 'grid_cols') @Default(6) int gridCols,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _OnlineGameState;

  factory OnlineGameState.fromJson(Map<String, dynamic> json) =>
      _$OnlineGameStateFromJson(json);

  /// Get grid rows from the actual grid data if available
  int get actualGridRows {
    if (gameState == null || gameState!['grid'] == null) return gridRows;
    return (gameState!['grid'] as List).length;
  }

  /// Get grid cols from the actual grid data if available
  int get actualGridCols {
    if (gameState == null ||
        gameState!['grid'] == null ||
        (gameState!['grid'] as List).isEmpty) {
      return gridCols;
    }
    return ((gameState!['grid'] as List)[0] as List).length;
  }
}
