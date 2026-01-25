import 'package:flutter/foundation.dart';
import 'dart:ui';

/// Represents an atom currently traveling between cells during an explosion.
@immutable
class FlyingAtom {
  final String id; // Unique ID for keying widgets
  final int fromX;
  final int fromY;
  final int toX;
  final int toY;
  final Color color;

  const FlyingAtom({
    required this.id,
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromX': fromX,
      'fromY': fromY,
      'toX': toX,
      'toY': toY,
      'color': color.toARGB32(),
    };
  }

  factory FlyingAtom.fromMap(Map<String, dynamic> map) {
    return FlyingAtom(
      id: map['id'] as String,
      fromX: map['fromX'] as int,
      fromY: map['fromY'] as int,
      toX: map['toX'] as int,
      toY: map['toY'] as int,
      color: Color(map['color'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlyingAtom &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
