import 'package:flutter/foundation.dart';
import 'dart:ui';

/// Determines if a player is human or AI
enum PlayerType { human, ai }

/// Difficulty levels for AI players
enum AIDifficulty { easy, medium, hard, extreme }

/// Represents a player in the game.
///
/// Players are immutable and identified by a unique ID.
@immutable
class Player {
  final String id;
  final String name;
  final Color color;
  final PlayerType type;
  final AIDifficulty? difficulty;

  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.type = PlayerType.human,
    this.difficulty,
  });

  bool get isAI => type == PlayerType.ai;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32(),
      'type': type.index,
      'difficulty': difficulty?.index,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      type: PlayerType.values[map['type'] as int],
      difficulty: map['difficulty'] != null
          ? AIDifficulty.values[map['difficulty'] as int]
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Player(id: $id, name: $name, type: $type, difficulty: $difficulty)';
}
