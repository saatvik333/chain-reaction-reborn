import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/game_selector.dart';
import '../../../../widgets/pill_button.dart';
import '../providers/home_provider.dart';

class HomeModeSelection extends ConsumerWidget {
  const HomeModeSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);

    return Column(
      key: const ValueKey('ModeSelection'),
      children: [
        GameSelector(
          label: 'GAME MODE',
          value: state.selectedMode == GameMode.localMultiplayer
              ? 'Local Multiplayer'
              : 'Vs Computer',
          onPrevious: () => notifier.toggleMode(),
          onNext: () => notifier.toggleMode(),
        ),
        const Spacer(),
        PillButton(
          text: 'Next',
          onTap: () => notifier.setStep(HomeStep.configuration),
          width: double.infinity,
        ),
      ],
    );
  }
}
