import 'package:flutter/foundation.dart';

/// Represents a single cell on the game grid.
///
/// Cells are immutable and contain position, capacity, atom count, and owner.
@immutable
class Cell {
  final int x;
  final int y;

  /// Maximum atoms before explosion (1=corner, 2=edge, 3=center).
  final int capacity;

  /// Current number of atoms in this cell.
  final int atomCount;

  /// ID of the player who owns this cell, or null if empty.
  final String? ownerId;

  const Cell({
    required this.x,
    required this.y,
    required this.capacity,
    this.atomCount = 0,
    this.ownerId,
  });

  /// Creates a copy of this cell with optional modifications.
  Cell copyWith({int? atomCount, String? ownerId, bool clearOwner = false}) {
    return Cell(
      x: x,
      y: y,
      capacity: capacity,
      atomCount: atomCount ?? this.atomCount,
      ownerId: clearOwner ? null : (ownerId ?? this.ownerId),
    );
  }

  /// Whether the cell is empty (no atoms).
  bool get isEmpty => atomCount == 0;

  /// Whether the cell is about to explode.
  bool get isAtCriticalMass => atomCount > capacity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          capacity == other.capacity &&
          atomCount == other.atomCount &&
          ownerId == other.ownerId;

  @override
  int get hashCode =>
      x.hashCode ^
      y.hashCode ^
      capacity.hashCode ^
      atomCount.hashCode ^
      ownerId.hashCode;

  @override
  String toString() => 'Cell(x: $x, y: $y, atoms: $atomCount, owner: $ownerId)';
}
