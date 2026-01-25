import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import '../../domain/services/ai_service.dart';

/// Notifier for managing game state.
///
/// Handles game initialization, atom placement, and turn progression.
class GameNotifier extends Notifier<GameState?> {
  late final InitializeGameUseCase _initializeGame;
  late final PlaceAtomUseCase _placeAtom;
  late final NextTurnUseCase _nextTurn;
  late final CheckWinnerUseCase _checkWinner;
  late final AIService _aiService;

  StreamSubscription<GameState>? _explosionSubscription;

  @override
  GameState? build() {
    _initializeGame = const InitializeGameUseCase();
    _placeAtom = const PlaceAtomUseCase();
    _nextTurn = const NextTurnUseCase();
    _checkWinner = const CheckWinnerUseCase();
    _aiService = AIService();

    // Cleanup on dispose
    ref.onDispose(_cancelExplosions);

    return null;
  }

  /// Initializes a new game with the given players and grid size.
  void initGame(List<Player> players, {String? gridSize}) {
    _cancelExplosions();
    state = _initializeGame(players, gridSize: gridSize);
  }

  /// Places an atom at the given coordinates.
  ///
  /// Handles the stream of explosion states automatically.
  void placeAtom(int x, int y) {
    final currentState = state;
    if (currentState == null) return;

    // Cancel any existing explosion subscription
    _cancelExplosions();

    GameState? lastState;
    bool hasEmitted = false; // Track if we received any state

    _explosionSubscription = _placeAtom(currentState, x, y).listen(
      (newState) {
        lastState = newState;
        state = newState;
        hasEmitted = true;
      },
      onDone: () {
        // After explosions complete, advance turn if game is not over
        if (lastState != null && !lastState!.isGameOver) {
          _advanceTurn();
        } else if (!hasEmitted) {
          // Stream completed without emitting anything (e.g. invalid move)
          // For AI, this causes a stuck state, so we force skip the turn.
          if (currentState.currentPlayer.isAI) {
            _advanceTurn();
          } else {
            // For humans, just unblock UI so they can try again
            state = currentState.copyWith(isProcessing: false);
          }
        }
      },
      onError: (error) {
        // On error, revert to original state with processing disabled
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
    } else {
      // If no winner, check if next player is AI
      if (state!.currentPlayer.isAI) {
        _processAIMove();
      }
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
