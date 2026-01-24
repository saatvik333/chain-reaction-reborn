import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';

/// efficiently draws atoms on a canvas
class AtomPainter extends CustomPainter {
  final Color color;
  final int count;
  final bool isUnstable; // Exploding
  final bool isCritical; // Full
  final bool isRotationOn;
  final bool isVibrationOn;
  final bool isBreathingOn;
  final double animationValue; // 0.0 to 1.0 from master controller
  final double angleOffset; // 0.0 to 1.0 phase shift

  static const double _orbSize = AppDimensions.orbSizeSmall;
  static const double _orbRadius = _orbSize / 2;

  // Pre-calculated spacing offsets for different layouts
  static const double _spacing4 = 12.0; // Distance for 4-atom cluster

  AtomPainter({
    required this.color,
    required this.count,
    required this.isUnstable,
    required this.isCritical,
    required this.isRotationOn,
    required this.isVibrationOn,
    required this.isBreathingOn,
    required this.animationValue,
    required this.angleOffset,
  }) : super(
         repaint: null,
       ); // Repaint is handled by the parent widget passing a Listenable

  @override
  void paint(Canvas canvas, Size size) {
    if (color == Colors.transparent || count == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = color;

    // 1. Calculate Rotation
    double rotationAngle = 0;
    if (isRotationOn && count > 1) {
      // Standardize rotation speed:
      // Both Stable and Unstable atoms rotate at the same "Slow" speed (2 * pi).
      // The "Fast Spin" (8x) was triggering too early during chain reactions,
      // creating visual noise. We rely on Vibration to signal instability.
      rotationAngle = (animationValue + angleOffset) * 2 * math.pi;
    }

    // 2. Calculate Vibration
    double vibrateX = 0;
    double vibrateY = 0;
    if (isVibrationOn && (isCritical || isUnstable)) {
      // High frequency vibration using sine waves on the main animation value
      // 100 * 2pi = 100 cycles per Animation Loop
      final vVal = math.sin(animationValue * 100 * math.pi);
      vibrateX = vVal * 0.8;
      vibrateY = (1 - vVal.abs()) * 0.8 * (vVal > 0 ? 1 : -1);
    }

    // Apply transformations
    canvas.save();
    canvas.translate(center.dx + vibrateX, center.dy + vibrateY);
    canvas.rotate(rotationAngle);

    // Draw Shadows (Using MaskFilter.blur as requested)
    final shadowPaint = Paint()
      ..color = color.withAlpha(
        ((color.a * 255.0).round().clamp(0, 255) * 0.4).toInt(),
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        8,
      ); // Same as blurRadius 8

    // 3. Organic Breathing (Simulated Physics)
    // Instead of fixed offsets, we modulate the distance from center using sine waves.
    // This makes the cluster look like it's "breathing" or magnetically bound.
    // We use the angleOffset to make every cell breathe at a slightly different rhythm.

    // Base breathing cycle (0.0 to 1.0)
    final breatheVal = math.sin(
      (animationValue + angleOffset) * 4 * math.pi,
    ); // 2 breaths per rotation cycle
    final breathingFactor = 1.0 + (breatheVal * 0.15); // +/- 15% scale

    // Draw based on count (Applying breathingFactor to spacing)
    switch (count) {
      case 1:
        // Single atom stays center but breathes in size slightly? No, looks weird.
        // Just keeping it centered.
        _drawAtom(canvas, Offset.zero, paint, shadowPaint);
        break;
      case 2:
        // spacing 6.0 becomes dynamic
        final d = 6.0 * breathingFactor;
        _drawAtom(canvas, Offset(-d, -d), paint, shadowPaint);
        _drawAtom(canvas, Offset(d, d), paint, shadowPaint);
        break;
      case 3:
        // Triangle layout
        //  0, -8
        // -7,  5
        //  7,  5
        // We scale these vectors from center
        final s = breathingFactor;
        _drawAtom(canvas, Offset(0, -8 * s), paint, shadowPaint);
        _drawAtom(canvas, Offset(-7 * s, 5 * s), paint, shadowPaint);
        _drawAtom(canvas, Offset(7 * s, 5 * s), paint, shadowPaint);
        break;
      case 4:
        // Square layout (12.0)
        final d4 = _spacing4 * breathingFactor;
        _drawAtom(canvas, Offset(0, -d4), paint, shadowPaint);
        _drawAtom(canvas, Offset(-d4, 0), paint, shadowPaint);
        _drawAtom(canvas, Offset(d4, 0), paint, shadowPaint);
        _drawAtom(canvas, Offset(0, d4), paint, shadowPaint);
        break;
      default:
        if (count > 4) {
          final d4 = _spacing4 * breathingFactor;
          _drawAtom(canvas, Offset(0, -d4), paint, shadowPaint);
          _drawAtom(canvas, Offset(-d4, 0), paint, shadowPaint);
          _drawAtom(canvas, Offset(d4, 0), paint, shadowPaint);
          _drawAtom(canvas, Offset(0, d4), paint, shadowPaint);
        }
    }

    canvas.restore();
  }

  void _drawAtom(Canvas canvas, Offset offset, Paint paint, Paint shadowPaint) {
    // Draw shadow first
    canvas.drawCircle(offset, _orbRadius, shadowPaint);
    // Draw orb
    canvas.drawCircle(offset, _orbRadius, paint);
  }

  @override
  bool shouldRepaint(covariant AtomPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.count != count ||
        oldDelegate.isUnstable != isUnstable ||
        oldDelegate.isCritical != isCritical ||
        oldDelegate.isRotationOn != isRotationOn ||
        oldDelegate.isVibrationOn != isVibrationOn ||
        oldDelegate.isBreathingOn != isBreathingOn ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.angleOffset != angleOffset;
  }
}
