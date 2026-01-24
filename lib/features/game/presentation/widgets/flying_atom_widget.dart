import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/flying_atom.dart';

class FlyingAtomWidget extends StatefulWidget {
  final FlyingAtom atom;
  final Size cellSize;
  final Duration duration;

  const FlyingAtomWidget({
    super.key,
    required this.atom,
    required this.cellSize,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<FlyingAtomWidget> createState() => _FlyingAtomWidgetState();
}

class _FlyingAtomWidgetState extends State<FlyingAtomWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Convert grid coordinates to relative offsets
    // This assumes the widget is placed in a Stack covering the grid
    final startOffset = Offset(
      widget.atom.fromX * widget.cellSize.width,
      widget.atom.fromY * widget.cellSize.height,
    );

    final endOffset = Offset(
      widget.atom.toX * widget.cellSize.width,
      widget.atom.toY * widget.cellSize.height,
    );

    _positionAnimation = Tween<Offset>(
      begin: startOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          width: widget.cellSize.width,
          height: widget.cellSize.height,
          child: Center(child: child),
        );
      },
      child: Container(
        width: AppDimensions.orbSizeSmall,
        height: AppDimensions.orbSizeSmall,
        decoration: BoxDecoration(
          color: widget.atom.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.atom.color.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
