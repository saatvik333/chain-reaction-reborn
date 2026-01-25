import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../game/domain/entities/player.dart';

// Re-using the enums from HomeScreen or moving them here is better.
// For now I will import them to avoid breaking changes, but better to redefine or move.
// Actually, I'll move them here to avoid circular dependencies if widgets import this.
// But HomeScreen already has them. I should verify if I can move them.
// Providing I move them to a common place or keep them in logic.
// Let's redefine them in a clean way or assuming they are in HomeScreen.
// To make it clean, I will move logic enums to a state file or keep them here.

enum HomeStep { modeSelection, configuration }

enum GameMode { localMultiplayer, vsComputer }

class HomeState {
  final HomeStep currentStep;
  final GameMode selectedMode;
  final int playerCount;
  final AIDifficulty aiDifficulty;
  final int gridSizeIndex;
  final List<String> gridSizes;

  const HomeState({
    required this.currentStep,
    required this.selectedMode,
    required this.playerCount,
    required this.aiDifficulty,
    required this.gridSizeIndex,
    required this.gridSizes,
  });

  factory HomeState.initial() {
    return const HomeState(
      currentStep: HomeStep.modeSelection,
      selectedMode: GameMode.localMultiplayer,
      playerCount: 2,
      aiDifficulty: AIDifficulty.medium,
      gridSizeIndex: 2,
      gridSizes: ['x_small', 'small', 'medium', 'large', 'x_large'],
    );
  }

  HomeState copyWith({
    HomeStep? currentStep,
    GameMode? selectedMode,
    int? playerCount,
    AIDifficulty? aiDifficulty,
    int? gridSizeIndex,
    List<String>? gridSizes,
  }) {
    return HomeState(
      currentStep: currentStep ?? this.currentStep,
      selectedMode: selectedMode ?? this.selectedMode,
      playerCount: playerCount ?? this.playerCount,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      gridSizeIndex: gridSizeIndex ?? this.gridSizeIndex,
      gridSizes: gridSizes ?? this.gridSizes,
    );
  }

  String get currentGridSize => gridSizes[gridSizeIndex];

  String get difficultyLabel {
    switch (aiDifficulty) {
      case AIDifficulty.easy:
        return 'Easy';
      case AIDifficulty.medium:
        return 'Medium';
      case AIDifficulty.hard:
        return 'Hard';
      case AIDifficulty.extreme:
        return 'Extreme';
    }
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState.initial();
  }

  void setStep(HomeStep step) {
    state = state.copyWith(currentStep: step);
  }

  void toggleMode() {
    final newMode = state.selectedMode == GameMode.localMultiplayer
        ? GameMode.vsComputer
        : GameMode.localMultiplayer;
    state = state.copyWith(selectedMode: newMode);
  }

  void incrementPlayers() {
    if (state.playerCount < 8) {
      state = state.copyWith(playerCount: state.playerCount + 1);
    }
  }

  void decrementPlayers() {
    if (state.playerCount > 2) {
      state = state.copyWith(playerCount: state.playerCount - 1);
    }
  }

  void checkPlayerCountForMode() {
    // Ensure player count is valid for mode if needed, e.g. vsComputer implies specific setup
  }

  void cycleDifficulty(bool forward) {
    final values = AIDifficulty.values;
    final currentIndex = values.indexOf(state.aiDifficulty);
    final nextIndex = forward
        ? (currentIndex + 1) % values.length
        : (currentIndex - 1 + values.length) % values.length;
    state = state.copyWith(aiDifficulty: values[nextIndex]);
  }

  void cycleGridSize(bool forward) {
    final nextIndex = forward
        ? (state.gridSizeIndex + 1) % state.gridSizes.length
        : (state.gridSizeIndex - 1 + state.gridSizes.length) %
              state.gridSizes.length;
    state = state.copyWith(gridSizeIndex: nextIndex);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
