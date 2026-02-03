import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/features/game/presentation/widgets/atom_painter.dart';
import 'package:flutter/material.dart';

/// Renders the atoms within a cell using CustomPainter for performance.
///
/// This widget is purely stateless and driven by the [animation] passed from above.
/// All drawing logic is handled by [AtomPainter].
class AtomWidget extends StatelessWidget {
  const AtomWidget({
    required this.color,
    required this.count,
    required this.animation,
    super.key,
    this.angleOffset = 0.0,
    this.isUnstable = false,
    this.isCritical = false,
    this.isAtomRotationOn = true,
    this.isAtomVibrationOn = true,
    this.isAtomBreathingOn = true,
  });
  final Color color;
  final int count;
  final bool isUnstable;
  final bool isCritical;
  final bool isAtomRotationOn;
  final bool isAtomVibrationOn;
  final bool isAtomBreathingOn;
  final Animation<double> animation;
  final double angleOffset;

  @override
  Widget build(BuildContext context) {
    if (color == Colors.transparent || count == 0) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return RepaintBoundary(
          child: CustomPaint(
            size: const Size(
              AppDimensions.orbSizeSmall * 3,
              AppDimensions.orbSizeSmall * 3,
            ),
            painter: AtomPainter(
              color: color,
              count: count,
              isUnstable: isUnstable,
              isCritical: isCritical,
              isRotationOn: isAtomRotationOn,
              isVibrationOn: isAtomVibrationOn,
              isBreathingOn: isAtomBreathingOn,
              animationValue: animation.value,
              angleOffset: angleOffset,
            ),
          ),
        );
      },
    );
  }
}
