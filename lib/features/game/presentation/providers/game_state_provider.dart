import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

/// Notifier for managing game state.
///
/// Handles game initialization, atom placement, and turn progression.
class GameNotifier extends StateNotifier<GameState?> {
  final InitializeGameUseCase _initializeGame;
  final PlaceAtomUseCase _placeAtom;
  final NextTurnUseCase _nextTurn;
  final CheckWinnerUseCase _checkWinner;

  StreamSubscription<GameState>? _explosionSubscription;

  GameNotifier({
    InitializeGameUseCase? initializeGame,
    PlaceAtomUseCase? placeAtom,
    NextTurnUseCase? nextTurn,
    CheckWinnerUseCase? checkWinner,
  }) : _initializeGame = initializeGame ?? const InitializeGameUseCase(),
       _placeAtom = placeAtom ?? const PlaceAtomUseCase(),
       _nextTurn = nextTurn ?? const NextTurnUseCase(),
       _checkWinner = checkWinner ?? const CheckWinnerUseCase(),
       super(null);

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

    _explosionSubscription = _placeAtom(currentState, x, y).listen(
      (newState) {
        lastState = newState;
        state = newState;
      },
      onDone: () {
        // After explosions complete, advance turn if game is not over
        if (lastState != null && !lastState!.isGameOver) {
          _advanceTurn();
        }
      },
      onError: (error) {
        // On error, revert to original state with processing disabled
        state = currentState.copyWith(isProcessing: false);
      },
    );
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
    }
  }

  /// Checks if a move is valid.
  bool isValidMove(int x, int y) {
    return MoveValidator.isValidMove(state!, x, y);
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

  @override
  void dispose() {
    _cancelExplosions();
    super.dispose();
  }
}

/// Main game state provider.
final gameStateProvider = StateNotifierProvider<GameNotifier, GameState?>((
  ref,
) {
  return GameNotifier();
});

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
