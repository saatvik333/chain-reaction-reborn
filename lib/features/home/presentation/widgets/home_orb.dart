import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';

class HomeOrb extends ConsumerStatefulWidget {
  const HomeOrb({super.key});

  @override
  ConsumerState<HomeOrb> createState() => _HomeOrbState();
}

class _HomeOrbState extends ConsumerState<HomeOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbController;
  late final Animation<double> _orbScaleAnimation;
  late final Animation<double> _orbOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orbScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));

    _orbOpacityAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    // Check for desktop/web
    final isDesktop =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;

    Widget orbContent = Container(
      width: AppDimensions.orbSizeLarge,
      height: AppDimensions.orbSizeLarge,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.fg.withValues(alpha: 0.1),
          width: AppDimensions.orbBorderWidth,
        ),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.fg.withValues(alpha: 0.1),
                    width: 4,
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.fg.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: theme.fg.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.subtitle.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isDesktop) {
      return orbContent;
    }

    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, child) {
        return Transform.scale(
          scale: _orbScaleAnimation.value,
          child: Opacity(opacity: _orbOpacityAnimation.value, child: child),
        );
      },
      child: orbContent,
    );
  }
}
