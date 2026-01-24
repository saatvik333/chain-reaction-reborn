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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlyingAtom &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
