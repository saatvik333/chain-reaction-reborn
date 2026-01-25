import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../widgets/game_selector.dart';
import '../../../../widgets/pill_button.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../providers/home_provider.dart';

class HomeConfiguration extends ConsumerWidget {
  const HomeConfiguration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final isVsComputer = state.selectedMode == GameMode.vsComputer;

    return Column(
      key: const ValueKey('Configuration'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isVsComputer)
          GameSelector(
            label: 'DIFFICULTY',
            value: state.difficultyLabel,
            onPrevious: () => notifier.cycleDifficulty(false),
            onNext: () => notifier.cycleDifficulty(true),
          )
        else
          GameSelector(
            label: AppStrings.playersLabel,
            value: state.playerCount.toString(),
            onPrevious: () => notifier.decrementPlayers(),
            onNext: () => notifier.incrementPlayers(),
          ),
        const SizedBox(height: AppDimensions.paddingXL),
        GameSelector(
          label: AppStrings.gridSizeLabel,
          value: state.currentGridSize,
          onPrevious: () => notifier.cycleGridSize(false),
          onNext: () => notifier.cycleGridSize(true),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        const Spacer(),
        PillButton(
          text: AppStrings.startGame,
          onTap: () {
            final int players = isVsComputer ? 2 : state.playerCount;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GameScreen(
                  playerCount: players,
                  gridSize: state.currentGridSize,
                  aiDifficulty: isVsComputer ? state.aiDifficulty : null,
                ),
              ),
            );
          },
          width: double.infinity,
        ),
      ],
    );
  }
}
