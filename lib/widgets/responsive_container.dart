import 'package:flutter/material.dart';

/// A wrapper widget that centers content and limits its width on larger screens.
///
/// Use this as the root of your Screen's body to prevent UI elements
/// from stretching uncomfortably wide on Desktop/Tablets.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 600.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
