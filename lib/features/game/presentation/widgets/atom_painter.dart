import 'dart:math' as math;

import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Efficiently draws atoms on a canvas with dynamic sizing.
class AtomPainter extends CustomPainter {
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
    required this.cellSize,
  }) : super(repaint: null);

  final Color color;
  final int count;
  final bool isUnstable; // Exploding
  final bool isCritical; // Full
  final bool isRotationOn;
  final bool isVibrationOn;
  final bool isBreathingOn;
  final double animationValue; // 0.0 to 1.0 from master controller
  final double angleOffset; // 0.0 to 1.0 phase shift
  final double cellSize;

  /// Base reference cell size for scaling calculations.
  static const double _referenceCellSize = 60;

  /// Calculate scale factor relative to reference cell size.
  double get _scaleFactor => (cellSize / _referenceCellSize).clamp(0.5, 2.0);

  /// Scaled orb radius.
  double get _orbRadius => (AppDimensions.orbSizeSmall / 2) * _scaleFactor;

  @override
  void paint(Canvas canvas, Size size) {
    if (color == Colors.transparent || count == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = color;

    // 1. Calculate Rotation
    double rotationAngle = 0;
    if (isRotationOn && count > 1) {
      rotationAngle = (animationValue + angleOffset) * 2 * math.pi;
    }

    // 2. Calculate Vibration (scaled)
    double vibrateX = 0;
    double vibrateY = 0;
    if (isVibrationOn && (isCritical || isUnstable)) {
      final vVal = math.sin(
        animationValue * AppDimensions.atomVibrationFrequency * math.pi,
      );
      final amplitude = AppDimensions.atomVibrationAmplitude * _scaleFactor;
      vibrateX = vVal * amplitude;
      vibrateY = (1 - vVal.abs()) * amplitude * (vVal > 0 ? 1 : -1);
    }

    // Apply transformations
    canvas
      ..save()
      ..translate(center.dx + vibrateX, center.dy + vibrateY)
      ..rotate(rotationAngle);

    // Draw Shadows (scaled blur)
    final shadowPaint = Paint()
      ..color = color.withAlpha(
        ((color.a * 255.0).round().clamp(0, 255) *
                AppDimensions.atomShadowOpacity)
            .toInt(),
      )
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        AppDimensions.atomShadowBlur * _scaleFactor,
      );

    // 3. Organic Breathing (Simulated Physics)
    final breatheVal = math.sin(
      (animationValue + angleOffset) * 4 * math.pi,
    );
    final breathingFactor =
        1.0 + (breatheVal * AppDimensions.atomBreathingScaleBy);

    // Scaled spacing values
    final spacing2 = AppDimensions.atomSpacing2 * _scaleFactor;
    final spacing4 = AppDimensions.atomSpacing4 * _scaleFactor;
    final triangleTopY = AppDimensions.atomTriangleTopY * _scaleFactor;
    final triangleBottomX = AppDimensions.atomTriangleBottomX * _scaleFactor;
    final triangleBottomY = AppDimensions.atomTriangleBottomY * _scaleFactor;

    // Draw based on count (Applying breathingFactor to spacing)
    switch (count) {
      case 1:
        _drawAtom(canvas, Offset.zero, paint, shadowPaint);
      case 2:
        final d = spacing2 * breathingFactor;
        _drawAtom(canvas, Offset(-d, -d), paint, shadowPaint);
        _drawAtom(canvas, Offset(d, d), paint, shadowPaint);
      case 3:
        final s = breathingFactor;
        _drawAtom(
          canvas,
          Offset(0, -triangleTopY * s),
          paint,
          shadowPaint,
        );
        _drawAtom(
          canvas,
          Offset(-triangleBottomX * s, triangleBottomY * s),
          paint,
          shadowPaint,
        );
        _drawAtom(
          canvas,
          Offset(triangleBottomX * s, triangleBottomY * s),
          paint,
          shadowPaint,
        );
      case 4:
        final d4 = spacing4 * breathingFactor;
        _drawAtom(canvas, Offset(0, -d4), paint, shadowPaint);
        _drawAtom(canvas, Offset(-d4, 0), paint, shadowPaint);
        _drawAtom(canvas, Offset(d4, 0), paint, shadowPaint);
        _drawAtom(canvas, Offset(0, d4), paint, shadowPaint);
      default:
        if (count > 4) {
          final d4 = spacing4 * breathingFactor;
          _drawAtom(canvas, Offset(0, -d4), paint, shadowPaint);
          _drawAtom(canvas, Offset(-d4, 0), paint, shadowPaint);
          _drawAtom(canvas, Offset(d4, 0), paint, shadowPaint);
          _drawAtom(canvas, Offset(0, d4), paint, shadowPaint);
        }
    }

    canvas.restore();
  }

  void _drawAtom(Canvas canvas, Offset offset, Paint paint, Paint shadowPaint) {
    canvas
      ..drawCircle(offset, _orbRadius, shadowPaint)
      ..drawCircle(offset, _orbRadius, paint);
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
        oldDelegate.angleOffset != angleOffset ||
        oldDelegate.cellSize != cellSize;
  }
}
