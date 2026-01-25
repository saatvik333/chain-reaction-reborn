import 'dart:collection';
import 'package:uuid/uuid.dart';
import '../entities/entities.dart';
import '../logic/game_rules.dart';

/// Use case for placing an atom on the grid.
///
/// Returns a Stream of GameState updates to animate chain reactions.
class PlaceAtomUseCase {
  final GameRules _rules;

  const PlaceAtomUseCase(this._rules);

  /// Places an atom at the given coordinates.
  ///
  /// Returns a stream of intermediate states for animating chain reactions.
  /// The stream will be empty if the move is invalid.
  Stream<GameState> call(GameState state, int x, int y) async* {
    if (!_rules.isValidMove(state, x, y)) return;

    final currentPlayer = state.currentPlayer;
    var grid = _copyGrid(state.grid);

    // Add atom to the cell
    grid[y][x] = grid[y][x].copyWith(
      atomCount: grid[y][x].atomCount + 1,
      ownerId: currentPlayer.id,
    );

    final needsExplosion = grid[y][x].isAtCriticalMass;

    var workingState = state.copyWith(
      grid: grid,
      isProcessing: true,
      totalMoves: state.totalMoves + 1,
    );

    yield workingState;

    if (needsExplosion) {
      yield* _propagateExplosions(workingState, Queue<Cell>.from([grid[y][x]]));
    }
  }

  /// Handles chain explosions using a queue-based approach with flight animation phases.
  Stream<GameState> _propagateExplosions(
    GameState state,
    Queue<Cell> explosionQueue,
  ) async* {
    var grid = _copyGrid(state.grid);
    final rows = grid.length;
    final cols = grid[0].length;
    final currentOwnerId = state.currentPlayer.id;
    final currentPlayer = state.currentPlayer; // Used for color

    const uuid = Uuid();

    while (explosionQueue.isNotEmpty) {
      // 1. Check Win Condition
      if (_checkWinnerDuringExplosion(grid, state.players)) {
        final owners = _getUniqueOwners(grid);
        if (owners.length == 1) {
          final winner = state.players.firstWhere((p) => p.id == owners.first);
          yield state.copyWith(
            grid: _copyGrid(grid),
            isGameOver: true,
            winner: winner,
            isProcessing: false,
            endTime: DateTime.now(),
          );
          return;
        }
      }

      // 2. Identify Cells Exploding in this Wave
      final explodingCell = explosionQueue.removeFirst();
      final cx = explodingCell.x;
      final cy = explodingCell.y;

      if (!grid[cy][cx].isAtCriticalMass) continue;

      // 3. Prepare Explosion Data
      final neighbors = _rules.getNeighbors(cx, cy, rows, cols);
      final atomsToRemove = neighbors.length; // 2, 3, or 4

      final newAtomCount = grid[cy][cx].atomCount - atomsToRemove;

      // 4. Phase 1: Remove atoms from source, Spawn Flying Atoms
      grid[cy][cx] = grid[cy][cx].copyWith(
        atomCount: newAtomCount,
        clearOwner: newAtomCount <= 0,
      );

      final flyingAtoms = <FlyingAtom>[];
      for (final n in neighbors) {
        flyingAtoms.add(
          FlyingAtom(
            id: uuid.v4(),
            fromX: cx,
            fromY: cy,
            toX: n.x,
            toY: n.y,
            color: currentPlayer.color,
          ),
        );
      }

      // Yield State: Source empty, atoms flying
      yield state.copyWith(grid: _copyGrid(grid), flyingAtoms: flyingAtoms);

      // Wait for flight
      await Future.delayed(
        const Duration(milliseconds: 250),
      ); // Flight duration

      // 5. Phase 2: Land Atoms
      for (final n in neighbors) {
        final neighbor = grid[n.y][n.x];
        grid[n.y][n.x] = neighbor.copyWith(
          atomCount: neighbor.atomCount + 1,
          ownerId: currentOwnerId, // Conquered!
        );

        if (grid[n.y][n.x].isAtCriticalMass) {
          explosionQueue.add(grid[n.y][n.x]);
        }
      }

      // Yield State: Atoms landed (flying cleared)
      yield state.copyWith(
        grid: _copyGrid(grid),
        flyingAtoms: [], // Clear flying atoms
      );
    }
  }

  /// Creates a deep copy of the grid.
  List<List<Cell>> _copyGrid(List<List<Cell>> grid) {
    return grid.map((row) => List<Cell>.from(row)).toList();
  }

  /// Checks if there's a winner during explosions.
  bool _checkWinnerDuringExplosion(
    List<List<Cell>> grid,
    List<Player> players,
  ) {
    final owners = _getUniqueOwners(grid);
    int totalAtoms = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.ownerId != null) {
          totalAtoms += cell.atomCount;
        }
      }
    }
    return owners.length == 1 && totalAtoms > 1;
  }

  /// Gets unique owner IDs from the grid.
  Set<String> _getUniqueOwners(List<List<Cell>> grid) {
    final owners = <String>{};
    for (var row in grid) {
      for (var cell in row) {
        if (cell.ownerId != null) {
          owners.add(cell.ownerId!);
        }
      }
    }
    return owners;
  }
}

/// Static helper for checking valid moves without instantiating the use case.
class MoveValidator {
  const MoveValidator._();

  /// Checks if a move is valid for the current player.
  static bool isValidMove(
    GameState state,
    int x,
    int y, {
    bool checkProcessing = true,
  }) {
    if (state.isGameOver) return false;
    if (checkProcessing && state.isProcessing) return false;
    if (y < 0 || y >= state.rows || x < 0 || x >= state.cols) return false;
    final cell = state.grid[y][x];
    return cell.ownerId == null || cell.ownerId == state.currentPlayer.id;
  }
}
