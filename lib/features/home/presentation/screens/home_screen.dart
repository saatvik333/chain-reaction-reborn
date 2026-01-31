import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../providers/home_provider.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_configuration.dart';
import '../widgets/home_mode_selection.dart';
import '../widgets/home_orb.dart';

export '../providers/home_provider.dart' show GameMode, HomeStep;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final currentStep = ref.watch(homeProvider.select((s) => s.currentStep));
    final notifier = ref.read(homeProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Keyboard handling
        final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
        final isKeyboardOpen = keyboardHeight > 0;

        return PopScope(
          canPop: currentStep == HomeStep.modeSelection,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (didPop) return;
            notifier.setStep(HomeStep.modeSelection);
          },
          child: Scaffold(
            backgroundColor: theme.bg,
            body: SafeArea(
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: Column(
                            children: [
                              const Spacer(),

                              const SizedBox(
                                height: 200,
                                child: Center(child: HomeOrb()),
                              ),

                              const SizedBox(height: AppDimensions.paddingXXL),

                              // Dynamic Content Area
                              Expanded(
                                flex: 4,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (
                                    Widget child,
                                    Animation<double> animation,
                                  ) {
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

                              // Bottom space to avoid overlap with HomeBottomBar
                              if (!isKeyboardOpen) const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Fixed Bottom Bar Layer
                  if (!isKeyboardOpen)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: HomeBottomBar(),
                    ),

                  // Back Button Overlay
                  if (currentStep == HomeStep.configuration)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.fg,
                          size: AppDimensions.iconM,
                        ),
                        onPressed: () =>
                            notifier.setStep(HomeStep.modeSelection),
                        tooltip: 'Back to Mode Selection',
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}