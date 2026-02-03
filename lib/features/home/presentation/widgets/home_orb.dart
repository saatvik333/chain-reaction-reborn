import 'dart:async';

import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeOrb extends ConsumerStatefulWidget {
  const HomeOrb({super.key});

  @override
  ConsumerState<HomeOrb> createState() => _HomeOrbState();
}

class _HomeOrbState extends ConsumerState<HomeOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbController;
  late Animation<double> _orbScaleAnimation;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    unawaited(_orbController.repeat(reverse: true));

    _orbScaleAnimation =
        Tween<double>(
          begin: 0.95,
          end: 1.05,
        ).animate(
          CurvedAnimation(
            parent: _orbController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return AnimatedBuilder(
      animation: _orbScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _orbScaleAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.currentTheme.red.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: theme.currentTheme.red.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.bg,
                  border: Border.all(
                    color: theme.currentTheme.red,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.currentTheme.red.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.gesture, // Placeholder icon or game logo
                  size: 64,
                  color: theme.currentTheme.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
