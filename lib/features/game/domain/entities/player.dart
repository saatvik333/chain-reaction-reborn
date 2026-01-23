import 'package:flutter/foundation.dart';
import 'dart:ui';

/// Represents a player in the game.
///
/// Players are immutable and identified by a unique ID.
@immutable
class Player {
  final String id;
  final String name;
  final Color color;

  const Player({required this.id, required this.name, required this.color});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Player(id: $id, name: $name)';
}
