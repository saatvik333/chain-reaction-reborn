import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import '../../domain/services/ai_service.dart';
import '../../domain/providers/game_domain_providers.dart';
import '../../domain/providers/service_providers.dart';
import '../../domain/providers/persistence_provider.dart';
import '../../domain/repositories/game_repository.dart';

import '../../domain/services/haptic_service.dart';
import 'theme_provider.dart'; // For sound/haptic settings

/// Notifier for managing game state.
class GameNotifier extends Notifier<GameState?> {
  late final InitializeGameUseCase _initializeGame;
  late final PlaceAtomUseCase _placeAtom;
  late final NextTurnUseCase _nextTurn;
  late final CheckWinnerUseCase _checkWinner;
  late final AIService _aiService;
  late final GameRepository _gameRepository;
  late final HapticService _hapticService;

  StreamSubscription<GameState>? _explosionSubscription;

  @override
  GameState? build() {
    _initializeGame = ref.watch(initializeGameUseCaseProvider);
    _placeAtom = ref.watch(placeAtomUseCaseProvider);
    _nextTurn = ref.watch(nextTurnUseCaseProvider);
    _checkWinner = ref.watch(checkWinnerUseCaseProvider);
    _aiService = ref.watch(aiServiceProvider);
    _gameRepository = ref.watch(gameRepositoryProvider);
    _hapticService = ref.watch(hapticServiceProvider);

    ref.onDispose(_cancelExplosions);

    return null;
  }

  /// Loads a saved game from persistence.
  Future<void> loadSavedGame() async {
    final savedState = await _gameRepository.loadGame();
    if (savedState != null) {
      state = savedState;
    }
  }

  /// Initializes a new game with the given players and grid size.
  void initGame(List<Player> players, {String? gridSize}) {
    _cancelExplosions();
    state = _initializeGame(players, gridSize: gridSize);
    _saveGame();
  }

  /// Places an atom at the given coordinates.
  void placeAtom(int x, int y) {
    final currentState = state;
    if (currentState == null) return;

    _cancelExplosions();

    // Play tap feedback
    if (ref.read(isHapticOnProvider)) _hapticService.lightImpact();

    GameState? lastState;
    bool hasEmitted = false;

    _explosionSubscription = _placeAtom(currentState, x, y).listen(
      (newState) {
        // Detect explosion start (atoms flying)
        if (newState.flyingAtoms.isNotEmpty && 
            (lastState?.flyingAtoms.isEmpty ?? true)) {
           if (ref.read(isHapticOnProvider)) _hapticService.explosionPattern();
        }

        lastState = newState;
        state = newState;
        hasEmitted = true;
      },
      onDone: () {
        if (lastState != null && !lastState!.isGameOver) {
          _advanceTurn();
        } else if (!hasEmitted) {
          if (currentState.currentPlayer.isAI) {
            _advanceTurn();
          } else {
            state = currentState.copyWith(isProcessing: false);
          }
        } else if (lastState != null && lastState!.isGameOver) {
           _gameRepository.clearGame();
           if (ref.read(isHapticOnProvider)) _hapticService.heavyImpact();
        }
      },
      onError: (error) {
        state = currentState.copyWith(isProcessing: false);
      },
    );
  }

  /// Trigger AI move if it's AI turn
  Future<void> _processAIMove() async {
    final currentState = state;
    if (currentState == null || currentState.isGameOver) return;

    final currentPlayer = currentState.currentPlayer;
    if (!currentPlayer.isAI) return;

    // Set processing to true to block UI
    state = currentState.copyWith(isProcessing: true);

    try {
      final move = await _aiService.getMove(currentState, currentPlayer);

      // Validation check to prevent stuck state
      // We pass checkProcessing: false because isProcessing is currently true (we set it above)
      if (isValidMove(move.x, move.y, checkProcessing: false)) {
        placeAtom(move.x, move.y);
      } else {
        // Fallback: This implies AI returned invalid move.
        // Force turn change to prevent stuck state
        _advanceTurn();
      }
    } catch (e) {
      // On error, skip AI turn to prevent stuck state
      _advanceTurn();
    }
  }

  /// Advances to the next player's turn.
  void _advanceTurn() {
    final currentState = state;
    if (currentState == null || currentState.isGameOver) return;

    state = _nextTurn(currentState);

    // Double-check for winner after turn advancement
    final winner = _checkWinner(state!);
    if (winner != null && !state!.isGameOver) {
      state = state!.copyWith(
        isGameOver: true,
        winner: winner,
        isProcessing: false,
        endTime: DateTime.now(),
      );
      _gameRepository.clearGame();
    } else {
      _saveGame(); // Save state at start of new turn
      // If no winner, check if next player is AI
      if (state!.currentPlayer.isAI) {
        _processAIMove();
      }
    }
  }

  Future<void> _saveGame() async {
    if (state != null && !state!.isGameOver) {
       await _gameRepository.saveGame(state!);
    }
  }

  /// Checks if a move is valid.
  bool isValidMove(int x, int y, {bool checkProcessing = true}) {
    return MoveValidator.isValidMove(
      state!,
      x,
      y,
      checkProcessing: checkProcessing,
    );
  }

  /// Resets the game to null state.
  void resetGame() {
    _cancelExplosions();
    state = null;
    _gameRepository.clearGame();
  }

  void _cancelExplosions() {
    _explosionSubscription?.cancel();
    _explosionSubscription = null;
  }
}

/// Main game state provider.
final gameStateProvider = NotifierProvider<GameNotifier, GameState?>(
  GameNotifier.new,
);

// Derived providers for selective rebuilds

/// Current player from game state.
final currentPlayerProvider = Provider<Player?>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState?.currentPlayer;
});

/// Processing flag from game state.
final isProcessingProvider = Provider<bool>((ref) {
  return ref.watch(gameStateProvider.select((s) => s?.isProcessing ?? false));
});

/// Game over flag from game state.
final isGameOverProvider = Provider<bool>((ref) {
  return ref.watch(gameStateProvider.select((s) => s?.isGameOver ?? false));
});

/// Winner from game state.
final winnerProvider = Provider<Player?>((ref) {
  return ref.watch(gameStateProvider.select((s) => s?.winner));
});

/// Grid from game state.
final gridProvider = Provider<List<List<Cell>>?>((ref) {
  return ref.watch(gameStateProvider.select((s) => s?.grid));
});

/// Turn count from game state.
final turnCountProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider.select((s) => s?.turnCount ?? 0));
});

/// Total moves from game state.
final totalMovesProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider.select((s) => s?.totalMoves ?? 0));
});
