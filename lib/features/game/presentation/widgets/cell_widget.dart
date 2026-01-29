import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/cell.dart';
import 'atom_widget.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Platform check hoisted to top-level constant (computed once at startup).
final bool _isMobilePlatform =
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

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
    final isUnstable = cell.atomCount > cell.capacity;
    final isCritical = cell.atomCount == cell.capacity;

    final childContainer = AnimatedContainer(
      duration: const Duration(
        milliseconds: AppDimensions.cellAnimationDurationMs,
      ),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: (isCellHighlightOn && cell.ownerId != null)
            ? cellColor.withValues(alpha: AppDimensions.cellHighlightOpacity)
            : Colors.transparent,
        border: Border.all(
          color: borderColor.withValues(alpha: AppDimensions.gridBorderOpacity),
          width: AppDimensions.gridBorderWidth,
        ),
      ),
      child: Center(
        child: AtomWidget(
          color: cellColor,
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
    );

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: _isMobilePlatform
            ? GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: childContainer,
              )
            : InkWell(
                onTap: onTap,
                hoverColor: borderColor.withValues(
                  alpha: AppDimensions.cellHoverOpacity,
                ),
                splashColor: borderColor.withValues(
                  alpha: AppDimensions.cellSplashOpacity,
                ),
                child: childContainer,
              ),
      ),
    );
  }
}
