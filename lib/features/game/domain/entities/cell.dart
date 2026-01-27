import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'cell.freezed.dart';
part 'cell.g.dart';

/// Represents a single cell on the game grid.
///
/// Cells are immutable and contain position, capacity, atom count, and owner.
@freezed
abstract class Cell with _$Cell {
  const Cell._(); // Added for custom getters

  const factory Cell({
    required int x,
    required int y,

    /// Maximum atoms before explosion (1=corner, 2=edge, 3=center).
    required int capacity,

    /// Current number of atoms in this cell.
    @Default(0) int atomCount,

    /// ID of the player who owns this cell, or null if empty.
    String? ownerId,
  }) = _Cell;

  /// Whether the cell is empty (no atoms).
  bool get isEmpty => atomCount == 0;

  /// Whether the cell is about to explode.
  bool get isAtCriticalMass => atomCount > capacity;

  factory Cell.fromJson(Map<String, dynamic> json) => _$CellFromJson(json);
}
