import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chain_reaction/core/utils/json_converters.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Determines if a player is human or AI
enum PlayerType { human, ai }

/// Difficulty levels for AI players
enum AIDifficulty { easy, medium, hard, extreme }

/// Represents a player in the game.
///
/// Players are immutable and identified by a unique ID.
@freezed
abstract class Player with _$Player {
  const Player._();

  const factory Player({
    required String id,
    required String name,
    @ColorConverter() required Color color,
    @Default(PlayerType.human) PlayerType type,
    AIDifficulty? difficulty,
  }) = _Player;

  bool get isAI => type == PlayerType.ai;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
