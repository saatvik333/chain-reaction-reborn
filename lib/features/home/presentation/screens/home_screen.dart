import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/core/presentation/widgets/responsive_container.dart';
import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:chain_reaction/features/home/presentation/providers/home_provider.dart';
import 'package:chain_reaction/features/home/presentation/widgets/home_bottom_bar.dart';
import 'package:chain_reaction/features/home/presentation/widgets/home_configuration.dart';
import 'package:chain_reaction/features/home/presentation/widgets/home_mode_selection.dart';
import 'package:chain_reaction/features/home/presentation/widgets/home_orb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export '../providers/home_provider.dart' show GameMode, HomeStep;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final currentStep = ref.watch(homeProvider.select((s) => s.currentStep));
    final notifier = ref.read(homeProvider.notifier);

    return PopScope(
      canPop: currentStep == HomeStep.modeSelection,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        notifier.setStep(HomeStep.modeSelection);
      },
      child: Scaffold(
        backgroundColor: theme.bg,
        body: SafeArea(
          child: ResponsiveContainer(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                  ),
                  child: Column(
                    children: [
                      const Spacer(),
                      // Central Orb Graphic
                      const Expanded(flex: 3, child: Center(child: HomeOrb())),

                      const SizedBox(height: AppDimensions.paddingXXL),

                      // Dynamic Content Area with Animation
                      Expanded(
                        flex: 4,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          child: currentStep == HomeStep.modeSelection
                              ? const HomeModeSelection()
                              : const HomeConfiguration(),
                        ),
                      ),

                      const Spacer(),

                      const HomeBottomBar(),
                    ],
                  ),
                ),
                // Back Button Overlay
                if (currentStep == HomeStep.configuration)
                  Positioned(
                    top: 4, // Aligns with centered AppBar leading (56 - 48) / 2
                    left: 4, // Aligns with centered AppBar leading
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.fg,
                        size: AppDimensions.iconM,
                      ),
                      onPressed: () => notifier.setStep(HomeStep.modeSelection),
                      tooltip: 'Back to Mode Selection',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
