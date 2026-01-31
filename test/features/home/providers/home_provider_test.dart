import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/features/home/presentation/providers/home_provider.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('HomeNotifier', () {
    group('Initial State', () {
      test('starts with modeSelection step', () {
        final state = container.read(homeProvider);
        expect(state.currentStep, HomeStep.modeSelection);
      });

      test('starts with localMultiplayer mode', () {
        final state = container.read(homeProvider);
        expect(state.selectedMode, GameMode.localMultiplayer);
      });

      test('starts with 2 players', () {
        final state = container.read(homeProvider);
        expect(state.playerCount, 2);
      });

      test('starts with medium difficulty', () {
        final state = container.read(homeProvider);
        expect(state.aiDifficulty, AIDifficulty.medium);
      });

      test('starts with medium grid size', () {
        final state = container.read(homeProvider);
        expect(state.currentGridSize, 'medium');
      });

      test('starts with create online mode', () {
        final state = container.read(homeProvider);
        expect(state.onlineMode, OnlineMode.create);
      });

      test('starts with empty room code', () {
        final state = container.read(homeProvider);
        expect(state.roomCode, '');
      });
    });

    group('Step Navigation', () {
      test('setStep changes current step', () {
        final notifier = container.read(homeProvider.notifier);

        notifier.setStep(HomeStep.configuration);
        expect(
          container.read(homeProvider).currentStep,
          HomeStep.configuration,
        );

        notifier.setStep(HomeStep.modeSelection);
        expect(
          container.read(homeProvider).currentStep,
          HomeStep.modeSelection,
        );
      });
    });

    group('Mode Cycling', () {
      test('cycleMode cycles through all modes in order', () {
        final notifier = container.read(homeProvider.notifier);

        // Start: localMultiplayer
        expect(
          container.read(homeProvider).selectedMode,
          GameMode.localMultiplayer,
        );

        notifier.cycleMode();
        expect(container.read(homeProvider).selectedMode, GameMode.vsComputer);

        notifier.cycleMode();
        expect(container.read(homeProvider).selectedMode, GameMode.online);

        notifier.cycleMode();
        expect(
          container.read(homeProvider).selectedMode,
          GameMode.localMultiplayer,
        );
      });

      test('toggleMode is an alias for cycleMode', () {
        final notifier = container.read(homeProvider.notifier);

        notifier.toggleMode();
        expect(container.read(homeProvider).selectedMode, GameMode.vsComputer);
      });
    });

    group('Player Count', () {
      test('setPlayerCount sets exact value', () {
        final notifier = container.read(homeProvider.notifier);
        notifier.setPlayerCount(5);
        expect(container.read(homeProvider).playerCount, 5);
      });

      test('incrementPlayers increases by 1', () {
        final notifier = container.read(homeProvider.notifier);
        notifier.incrementPlayers();
        expect(container.read(homeProvider).playerCount, 3);
      });

      test('decrementPlayers decreases by 1', () {
        final notifier = container.read(homeProvider.notifier);
        notifier.setPlayerCount(4);
        notifier.decrementPlayers();
        expect(container.read(homeProvider).playerCount, 3);
      });

      test('incrementPlayers caps at 8', () {
        final notifier = container.read(homeProvider.notifier);
        notifier.setPlayerCount(8);
        notifier.incrementPlayers();
        expect(container.read(homeProvider).playerCount, 8);
      });

      test('decrementPlayers floors at 2', () {
        final notifier = container.read(homeProvider.notifier);
        notifier.decrementPlayers();
        expect(container.read(homeProvider).playerCount, 2);
      });
    });

    group('AI Difficulty', () {
      test('cycleDifficulty forward cycles through all difficulties', () {
        final notifier = container.read(homeProvider.notifier);

        // Start: medium
        expect(container.read(homeProvider).aiDifficulty, AIDifficulty.medium);

        notifier.cycleDifficulty(true);
        expect(container.read(homeProvider).aiDifficulty, AIDifficulty.hard);

        notifier.cycleDifficulty(true);
        expect(container.read(homeProvider).aiDifficulty, AIDifficulty.extreme);

        notifier.cycleDifficulty(true);
        expect(container.read(homeProvider).aiDifficulty, AIDifficulty.easy);

        notifier.cycleDifficulty(true);
        expect(container.read(homeProvider).aiDifficulty, AIDifficulty.medium);
      });

      test('cycleDifficulty backward cycles in reverse', () {
        final notifier = container.read(homeProvider.notifier);

        notifier.cycleDifficulty(false);
        expect(container.read(homeProvider).aiDifficulty, AIDifficulty.easy);

        notifier.cycleDifficulty(false);
        expect(container.read(homeProvider).aiDifficulty, AIDifficulty.extreme);
      });
    });

    group('Grid Size', () {
      test('cycleGridSize forward cycles through all sizes', () {
        final notifier = container.read(homeProvider.notifier);

        // Start: medium (index 2)
        expect(container.read(homeProvider).currentGridSize, 'medium');

        notifier.cycleGridSize(true);
        expect(container.read(homeProvider).currentGridSize, 'large');

        notifier.cycleGridSize(true);
        expect(container.read(homeProvider).currentGridSize, 'x_large');

        notifier.cycleGridSize(true);
        expect(container.read(homeProvider).currentGridSize, 'x_small');
      });

      test('cycleGridSize backward cycles in reverse', () {
        final notifier = container.read(homeProvider.notifier);

        notifier.cycleGridSize(false);
        expect(container.read(homeProvider).currentGridSize, 'small');

        notifier.cycleGridSize(false);
        expect(container.read(homeProvider).currentGridSize, 'x_small');
      });
    });

    group('Online Mode', () {
      test('cycleOnlineMode toggles between create and join', () {
        final notifier = container.read(homeProvider.notifier);

        expect(container.read(homeProvider).onlineMode, OnlineMode.create);

        notifier.cycleOnlineMode();
        expect(container.read(homeProvider).onlineMode, OnlineMode.join);

        notifier.cycleOnlineMode();
        expect(container.read(homeProvider).onlineMode, OnlineMode.create);
      });

      test('setRoomCode updates room code', () {
        final notifier = container.read(homeProvider.notifier);
        notifier.setRoomCode('ABCD');
        expect(container.read(homeProvider).roomCode, 'ABCD');
      });
    });

    group('validateOnlineConfig', () {
      test('returns true for create mode regardless of room code', () {
        final notifier = container.read(homeProvider.notifier);
        // Default is create mode
        expect(notifier.validateOnlineConfig(), isTrue);

        notifier.setRoomCode('');
        expect(notifier.validateOnlineConfig(), isTrue);
      });

      test('returns false for join mode with invalid room code', () {
        final notifier = container.read(homeProvider.notifier);
        notifier.cycleOnlineMode(); // Switch to join

        notifier.setRoomCode('');
        expect(notifier.validateOnlineConfig(), isFalse);

        notifier.setRoomCode('ABC');
        expect(notifier.validateOnlineConfig(), isFalse);

        notifier.setRoomCode('ABCDE');
        expect(notifier.validateOnlineConfig(), isFalse);
      });

      test('returns true for join mode with valid 4-char room code', () {
        final notifier = container.read(homeProvider.notifier);
        notifier.cycleOnlineMode(); // Switch to join
        notifier.setRoomCode('ABCD');
        expect(notifier.validateOnlineConfig(), isTrue);
      });
    });

    group('getGridDimensions', () {
      test('returns correct dimensions for each grid size', () {
        final notifier = container.read(homeProvider.notifier);

        // Start at medium (index 2)
        expect(notifier.getGridDimensions(), (8, 6));

        // Go to large
        notifier.cycleGridSize(true);
        expect(notifier.getGridDimensions(), (10, 7));

        // Go to x_large
        notifier.cycleGridSize(true);
        expect(notifier.getGridDimensions(), (12, 8));

        // Go to x_small
        notifier.cycleGridSize(true);
        expect(notifier.getGridDimensions(), (4, 4));

        // Go to small
        notifier.cycleGridSize(true);
        expect(notifier.getGridDimensions(), (6, 5));
      });
    });

    group('difficultyLabel', () {
      test('returns correct label for each difficulty', () {
        final notifier = container.read(homeProvider.notifier);

        expect(container.read(homeProvider).difficultyLabel, 'Medium');

        notifier.cycleDifficulty(true);
        expect(container.read(homeProvider).difficultyLabel, 'Hard');

        notifier.cycleDifficulty(true);
        expect(container.read(homeProvider).difficultyLabel, 'Extreme');

        notifier.cycleDifficulty(true);
        expect(container.read(homeProvider).difficultyLabel, 'Easy');
      });
    });
  });
}
