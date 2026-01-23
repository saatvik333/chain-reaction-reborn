import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Renders the atoms within a cell.
class AtomWidget extends StatelessWidget {
  final Color color;
  final int count;

  const AtomWidget({super.key, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    if (color == Colors.transparent || count == 0) return const SizedBox();

    if (count == 1) {
      return _buildAtomCircle(color);
    } else if (count == 2) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: const Offset(-6, -6),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(6, 6),
            child: _buildAtomCircle(color),
          ),
        ],
      );
    } else if (count == 3) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: const Offset(0, -8),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(-7, 5),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(7, 5),
            child: _buildAtomCircle(color),
          ),
        ],
      );
    } else {
      // 4+ atoms: show 4 in a diamond pattern
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: const Offset(0, -8),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(8, 0),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(0, 8),
            child: _buildAtomCircle(color),
          ),
        ],
      );
    }
  }

  Widget _buildAtomCircle(Color color) {
    return Container(
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
