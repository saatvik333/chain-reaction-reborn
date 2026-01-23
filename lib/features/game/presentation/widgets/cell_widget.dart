import 'package:flutter/material.dart';
import '../../domain/entities/cell.dart';
import 'atom_widget.dart';

/// Renders a single cell in the game grid.
class CellWidget extends StatelessWidget {
  final Cell cell;
  final Color borderColor;
  final Color cellColor;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.borderColor,
    required this.cellColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Center(
            child: AtomWidget(color: cellColor, count: cell.atomCount),
          ),
        ),
      ),
    );
  }
}
