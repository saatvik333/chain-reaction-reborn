import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../features/game/presentation/providers/providers.dart';
import '../../../../widgets/responsive_container.dart';
import '../providers/home_provider.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_configuration.dart';
import '../widgets/home_mode_selection.dart';
import '../widgets/home_orb.dart';

// Re-export enums if needed by other files, though ideally they should import from provider or domain.
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
                    top: 0,
                    left: 4,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.fg),
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
