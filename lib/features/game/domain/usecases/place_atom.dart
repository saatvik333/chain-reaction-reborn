import 'dart:collection';
import '../entities/entities.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Use case for placing an atom on the grid.
///
/// Returns a Stream of GameState updates to animate chain reactions.
class PlaceAtomUseCase {
  const PlaceAtomUseCase();

  /// Places an atom at the given coordinates.
  ///
  /// Returns a stream of intermediate states for animating chain reactions.
  /// The stream will be empty if the move is invalid.
  Stream<GameState> call(GameState state, int x, int y) async* {
    if (!_isValidMove(state, x, y)) return;

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

  /// Checks if a move is valid for the current player.
  bool _isValidMove(GameState state, int x, int y) {
    if (state.isGameOver || state.isProcessing) return false;
    if (y < 0 || y >= state.rows || x < 0 || x >= state.cols) return false;
    final cell = state.grid[y][x];
    return cell.ownerId == null || cell.ownerId == state.currentPlayer.id;
  }

  /// Handles chain explosions using a queue-based approach.
  Stream<GameState> _propagateExplosions(
    GameState state,
    Queue<Cell> explosionQueue,
  ) async* {
    var grid = _copyGrid(state.grid);
    final rows = grid.length;
    final cols = grid[0].length;
    final currentOwnerId = state.currentPlayer.id;

    while (explosionQueue.isNotEmpty) {
      // Check win condition during explosions
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

      final explodingCell = explosionQueue.removeFirst();
      final cx = explodingCell.x;
      final cy = explodingCell.y;

      // Re-check capacity in case it changed
      if (!grid[cy][cx].isAtCriticalMass) continue;

      final criticalMass = grid[cy][cx].capacity + 1;
      final newAtomCount = grid[cy][cx].atomCount - criticalMass;

      grid[cy][cx] = grid[cy][cx].copyWith(
        atomCount: newAtomCount,
        clearOwner: newAtomCount <= 0,
      );

      final neighbors = _getNeighbors(cx, cy, rows, cols);
      for (final n in neighbors) {
        final neighbor = grid[n.y][n.x];

        grid[n.y][n.x] = neighbor.copyWith(
          atomCount: neighbor.atomCount + 1,
          ownerId: currentOwnerId,
        );

        if (grid[n.y][n.x].isAtCriticalMass) {
          explosionQueue.add(grid[n.y][n.x]);
        }
      }

      yield state.copyWith(grid: _copyGrid(grid));
      await Future.delayed(
        Duration(milliseconds: AppDimensions.explosionDurationMs),
      );
    }
  }

  /// Gets orthogonal neighbors of a cell.
  List<({int x, int y})> _getNeighbors(int x, int y, int rows, int cols) {
    final neighbors = <({int x, int y})>[];
    if (x > 0) neighbors.add((x: x - 1, y: y));
    if (x < cols - 1) neighbors.add((x: x + 1, y: y));
    if (y > 0) neighbors.add((x: x, y: y - 1));
    if (y < rows - 1) neighbors.add((x: x, y: y + 1));
    return neighbors;
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
  static bool isValidMove(GameState state, int x, int y) {
    if (state.isGameOver || state.isProcessing) return false;
    if (y < 0 || y >= state.rows || x < 0 || x >= state.cols) return false;
    final cell = state.grid[y][x];
    return cell.ownerId == null || cell.ownerId == state.currentPlayer.id;
  }
}
