import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'dart:math' as math;

/// Renders the atoms within a cell with spinning animations.
class AtomWidget extends StatefulWidget {
  final Color color;
  final int count;
  final bool isUnstable;
  final bool isCritical;
  final bool isAtomRotationOn;
  final bool isAtomVibrationOn;

  const AtomWidget({
    super.key,
    required this.color,
    required this.count,
    this.isUnstable = false,
    this.isCritical = false,
    this.isAtomRotationOn = true,
    this.isAtomVibrationOn = true,
  });

  @override
  State<AtomWidget> createState() => _AtomWidgetState();
}

class _AtomWidgetState extends State<AtomWidget> with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _vibrationController;
  late final Animation<double> _vibrationAnimation;

  // Constants for rotation speeds
  static const Duration _stableDuration = Duration(milliseconds: 4000);
  static const Duration _unstableDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this);

    // Setup vibration: fast, short repeating animation
    _vibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    // Create a predictable shake pattern (e.g., -1 to 1)
    _vibrationAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _vibrationController, curve: Curves.linear),
    );

    _checkAnimation();
  }

  @override
  void didUpdateWidget(AtomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count ||
        widget.isUnstable != oldWidget.isUnstable ||
        widget.isCritical != oldWidget.isCritical ||
        widget.isAtomRotationOn != oldWidget.isAtomRotationOn ||
        widget.isAtomVibrationOn != oldWidget.isAtomVibrationOn) {
      _checkAnimation();
    }
  }

  void _checkAnimation() {
    // 1. Handle Rotation
    // Only rotate if setting is ON AND (count > 1).
    if (widget.isAtomRotationOn && widget.count > 1) {
      final targetDuration = widget.isUnstable
          ? _unstableDuration
          : _stableDuration;

      _rotationController.duration = targetDuration;

      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      _rotationController.stop();
    }

    // 2. Handle Vibration (Only if Critical and NOT yet Unstable/Exploding)
    // If it's exploding (Unstable), the fast spin is enough.
    // Only vibrate if setting is ON.
    if (widget.isAtomVibrationOn && widget.isCritical && !widget.isUnstable) {
      if (!_vibrationController.isAnimating) {
        _vibrationController.repeat(reverse: true);
      }
    } else {
      _vibrationController.stop();
      _vibrationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _vibrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.color == Colors.transparent || widget.count == 0) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _vibrationController]),
      builder: (context, child) {
        // Calculate vibration offset
        double offsetX = 0;
        double offsetY = 0;

        if (_vibrationController.isAnimating) {
          // Simple pseudo-random shake based on controller value
          // using sine/cosine to make it feel organic but fast
          final val = _vibrationAnimation.value;
          offsetX = val * 0.8; // Max 0.8 pixel vibration
          offsetY = (1 - val.abs()) * 0.8 * (val > 0 ? 1 : -1);
        }

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Transform.rotate(
            angle: _rotationController.value * 2 * math.pi,
            child: child,
          ),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.elasticOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _buildAtomLayout(widget.count),
      ),
    );
  }

  Widget _buildAtomLayout(int count) {
    final key = ValueKey<int>(count);

    if (count == 1) {
      return Container(key: key, child: _buildAtomCircle(widget.color));
    } else if (count == 2) {
      return Stack(
        key: key,
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: const Offset(-6, -6),
            child: _buildAtomCircle(widget.color),
          ),
          Transform.translate(
            offset: const Offset(6, 6),
            child: _buildAtomCircle(widget.color),
          ),
        ],
      );
    } else if (count == 3) {
      return Stack(
        key: key,
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: const Offset(0, -8),
            child: _buildAtomCircle(widget.color),
          ),
          Transform.translate(
            offset: const Offset(-7, 5),
            child: _buildAtomCircle(widget.color),
          ),
          Transform.translate(
            offset: const Offset(7, 5),
            child: _buildAtomCircle(widget.color),
          ),
        ],
      );
    } else {
      // 4+ atoms
      return Stack(
        key: key,
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: const Offset(0, -8),
            child: _buildAtomCircle(widget.color),
          ),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: _buildAtomCircle(widget.color),
          ),
          Transform.translate(
            offset: const Offset(8, 0),
            child: _buildAtomCircle(widget.color),
          ),
          Transform.translate(
            offset: const Offset(0, 8),
            child: _buildAtomCircle(widget.color),
          ),
        ],
      );
    }
  }

  Widget _buildAtomCircle(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: AppDimensions.orbSizeSmall,
      height: AppDimensions.orbSizeSmall,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
