import 'package:flutter/material.dart';

/// A [PageTransitionsBuilder] that provides a smooth fade and subtle scale transition.
class FluidFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FluidFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _FluidFadeTransition(routeAnimation: animation, child: child);
  }
}

class _FluidFadeTransition extends StatelessWidget {
  final Animation<double> routeAnimation;
  final Widget child;

  const _FluidFadeTransition({
    required this.routeAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Use a curve that feels responsive but smooth
    final curve = CurvedAnimation(
      parent: routeAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curve,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(curve),
        child: child,
      ),
    );
  }
}
