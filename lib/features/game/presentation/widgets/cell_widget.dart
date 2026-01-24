import 'package:flutter/material.dart';
import '../../domain/entities/cell.dart';
import 'atom_widget.dart';

/// Renders a single cell in the game grid.
class CellWidget extends StatelessWidget {
  final Cell cell;
  final Color borderColor;
  final Color cellColor;
  final VoidCallback onTap;
  final bool isAtomRotationOn;
  final bool isAtomVibrationOn;
  final bool isAtomBreathingOn;
  final bool isCellHighlightOn;
  final Animation<double> animation;
  final double angleOffset;

  const CellWidget({
    super.key,
    required this.cell,
    required this.borderColor,
    required this.cellColor,
    required this.onTap,
    required this.animation,
    this.angleOffset = 0.0,
    this.isAtomRotationOn = true,
    this.isAtomVibrationOn = true,
    this.isAtomBreathingOn = true,
    this.isCellHighlightOn = true,
  });

  @override
  Widget build(BuildContext context) {
    // A cell is unstable (wobbling/spinning fast) only if it's overflowing (exploding)
    // This keeps full cells (Critical Mass) running at the stable speed
    final isUnstable = cell.atomCount > cell.capacity;
    final isCritical = cell.atomCount == cell.capacity;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: (isCellHighlightOn && cell.ownerId != null)
                ? cellColor.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: borderColor.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Center(
            child: AtomWidget(
              color: cellColor,
              // Visually cap the atoms to capacity to prevent "overloaded" shapes
              // (e.g. 4 atoms in a 3-capacity cell) from appearing briefly before explosion.
              count: cell.atomCount > cell.capacity
                  ? cell.capacity
                  : cell.atomCount,
              isUnstable: isUnstable,
              isCritical: isCritical,
              isAtomRotationOn: isAtomRotationOn,
              isAtomVibrationOn: isAtomVibrationOn,
              isAtomBreathingOn: isAtomBreathingOn,
              animation: animation,
              angleOffset: angleOffset,
            ),
          ),
        ),
      ),
    );
  }
}
