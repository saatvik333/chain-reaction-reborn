import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'dart:math' as math;

/// Renders the atoms within a cell with spinning animations.
class AtomWidget extends StatefulWidget {
  final Color color;
  final int count;
  final bool isUnstable;

  const AtomWidget({
    super.key,
    required this.color,
    required this.count,
    this.isUnstable = false,
  });

  @override
  State<AtomWidget> createState() => _AtomWidgetState();
}

class _AtomWidgetState extends State<AtomWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Constants for rotation speeds
  static const Duration _stableDuration = Duration(milliseconds: 4000);
  static const Duration _unstableDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _checkAnimation();
  }

  @override
  void didUpdateWidget(AtomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count ||
        widget.isUnstable != oldWidget.isUnstable) {
      _checkAnimation();
    }
  }

  void _checkAnimation() {
    if (widget.count > 1) {
      // Logic reworked:
      // Instead of complex scaling which causes mismatches, we use two distinct
      // energy states: Stable (Idle) and Unstable (Critical).
      // This ensures a 2-atom edge cluster (Critical) and a 3-atom center cluster (Critical)
      // spin with the exact same angular velocity, providing visual consistency.

      final targetDuration =
          widget.isUnstable ? _unstableDuration : _stableDuration;

      _controller.duration = targetDuration;

      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      // Single atoms don't spin
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.color == Colors.transparent || widget.count == 0) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.elasticOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
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
