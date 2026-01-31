import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../game/domain/entities/player.dart';

part 'home_provider.freezed.dart';
part 'home_provider.g.dart';

enum HomeStep { modeSelection, configuration }

enum GameMode { localMultiplayer, vsComputer, online }

enum OnlineMode { create, join }

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    required HomeStep currentStep,
    required GameMode selectedMode,
    required int playerCount,
    required AIDifficulty aiDifficulty,
    required int gridSizeIndex,
    required List<String> gridSizes,
    required OnlineMode onlineMode,
    required String roomCode,
  }) = _HomeState;

  factory HomeState.initial() {
    return const HomeState(
      currentStep: HomeStep.modeSelection,
      selectedMode: GameMode.localMultiplayer,
      playerCount: 2,
      aiDifficulty: AIDifficulty.medium,
      gridSizeIndex: 2,
      gridSizes: ['x_small', 'small', 'medium', 'large', 'x_large'],
      onlineMode: OnlineMode.create,
      roomCode: '',
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

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  HomeState build() {
    return HomeState.initial();
  }

  void setStep(HomeStep step) {
    state = state.copyWith(currentStep: step);
  }

  void setMode(GameMode mode) {
    state = state.copyWith(selectedMode: mode);
  }

  void enterOnlineMode() {
    state = state.copyWith(
      selectedMode: GameMode.online,
      currentStep: HomeStep.configuration,
      roomCode: '',
    );
  }

  void reset() {
    state = HomeState.initial();
  }

  void cycleMode() {
    final nextMode = switch (state.selectedMode) {
      GameMode.localMultiplayer => GameMode.vsComputer,
      GameMode.vsComputer => GameMode.online,
      GameMode.online => GameMode.localMultiplayer,
    };
    state = state.copyWith(selectedMode: nextMode);
  }

  void toggleMode() => cycleMode();

  void setPlayerCount(int count) {
    state = state.copyWith(playerCount: count);
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

  void cycleOnlineMode() {
    state = state.copyWith(
      onlineMode: state.onlineMode == OnlineMode.create
          ? OnlineMode.join
          : OnlineMode.create,
    );
  }

  void setRoomCode(String code) {
    state = state.copyWith(roomCode: code);
  }

  /// Validates the current online game configuration.
  ///
  /// Returns `true` if valid, `false` if the room code is invalid (for join mode).
  /// This method does NOT perform the actual network call; that's still done by
  /// the OnlineGameProvider. This just pre-validates before making the call.
  bool validateOnlineConfig() {
    if (state.onlineMode == OnlineMode.join) {
      return state.roomCode.length == 4;
    }
    return true;
  }

  /// Gets the grid dimensions for creating an online game.
  (int rows, int cols) getGridDimensions() {
    const gridSizes = {
      'x_small': (4, 4),
      'small': (6, 5),
      'medium': (8, 6),
      'large': (10, 7),
      'x_large': (12, 8),
    };
    return gridSizes[state.currentGridSize] ?? (8, 6);
  }
}
