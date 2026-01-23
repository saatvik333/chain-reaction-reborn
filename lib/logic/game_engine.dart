import 'dart:collection';
import '../models/cell.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../constants/app_dimensions.dart';

/// Core game logic for Chain Reaction.
/// All methods are static and operate on immutable GameState.
class GameEngine {
  /// Creates a new game state with an initialized grid.
  static GameState initializeGame(
    List<Player> players, {
    int? rows,
    int? cols,
    String? gridSize,
  }) {
    int r = rows ?? 9;
    int c = cols ?? 6;

    // If gridSize string is provided, use the mapping from AppDimensions
    if (gridSize != null && AppDimensions.gridSizes.containsKey(gridSize)) {
      final size = AppDimensions.gridSizes[gridSize]!;
      r = size.$1;
      c = size.$2;
    }

    final grid = List.generate(r, (y) {
      return List.generate(c, (x) {
        int capacity = 0;
        bool isCorner = (x == 0 || x == c - 1) && (y == 0 || y == r - 1);
        bool isEdge = (x == 0 || x == c - 1 || y == 0 || y == r - 1);

        if (isCorner) {
          capacity = 1;
        } else if (isEdge) {
          capacity = 2;
        } else {
          capacity = 3;
        }

        return Cell(x: x, y: y, capacity: capacity);
      });
    });

    return GameState(
      grid: grid,
      players: players,
      currentPlayerIndex: 0,
      turnCount: 0,
    );
  }

  /// Checks if a move is valid for the current player.
  static bool isValidMove(GameState state, int x, int y) {
    if (state.isGameOver || state.isProcessing) return false;
    if (y < 0 || y >= state.rows || x < 0 || x >= state.cols) return false;
    final cell = state.grid[y][x];
    return cell.ownerId == null || cell.ownerId == state.currentPlayer.id;
  }

  /// Places an atom and returns a stream of states for animation.
  /// Each yield represents an intermediate state during chain explosions.
  static Stream<GameState> placeAtom(
    GameState currentState,
    int x,
    int y,
  ) async* {
    if (!isValidMove(currentState, x, y)) return;

    final currentPlayer = currentState.currentPlayer;
    List<List<Cell>> grid = _copyGrid(currentState.grid);

    // Add atom to the cell
    grid[y][x] = grid[y][x].copyWith(
      atomCount: grid[y][x].atomCount + 1,
      ownerId: currentPlayer.id,
    );

    bool needsExplosion = grid[y][x].atomCount > grid[y][x].capacity;

    GameState workingState = currentState.copyWith(
      grid: grid,
      isProcessing: true,
      totalMoves: currentState.totalMoves + 1,
    );

    yield workingState;

    if (needsExplosion) {
      yield* _propagateExplosions(workingState, Queue<Cell>.from([grid[y][x]]));
    }
  }

  /// Handles chain explosions recursively.
  static Stream<GameState> _propagateExplosions(
    GameState state,
    Queue<Cell> explosionQueue,
  ) async* {
    List<List<Cell>> grid = _copyGrid(state.grid);
    int rows = grid.length;
    int cols = grid[0].length;
    String currentOwnerId = state.currentPlayer.id;

    while (explosionQueue.isNotEmpty) {
      // Check win condition during explosions
      if (_isWinnerDetermined(grid, state.players)) {
        Set<String> owners = {};
        for (var r in grid) {
          for (var c in r) {
            if (c.ownerId != null) owners.add(c.ownerId!);
          }
        }
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

      Cell explodingCell = explosionQueue.removeFirst();
      int cx = explodingCell.x;
      int cy = explodingCell.y;

      // Re-check capacity in case it changed
      if (grid[cy][cx].atomCount <= grid[cy][cx].capacity) continue;

      int criticalMass = grid[cy][cx].capacity + 1;
      int newAtomCount = grid[cy][cx].atomCount - criticalMass;

      grid[cy][cx] = grid[cy][cx].copyWith(
        atomCount: newAtomCount,
        clearOwner: newAtomCount <= 0,
      );

      final neighbors = _getNeighbors(cx, cy, rows, cols);
      for (var n in neighbors) {
        Cell neighbor = grid[n.y][n.x];

        grid[n.y][n.x] = neighbor.copyWith(
          atomCount: neighbor.atomCount + 1,
          ownerId: currentOwnerId,
        );

        if (grid[n.y][n.x].atomCount > grid[n.y][n.x].capacity) {
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
  static List<({int x, int y})> _getNeighbors(
    int x,
    int y,
    int rows,
    int cols,
  ) {
    List<({int x, int y})> neighbors = [];
    if (x > 0) neighbors.add((x: x - 1, y: y));
    if (x < cols - 1) neighbors.add((x: x + 1, y: y));
    if (y > 0) neighbors.add((x: x, y: y - 1));
    if (y < rows - 1) neighbors.add((x: x, y: y + 1));
    return neighbors;
  }

  /// Creates a deep copy of the grid.
  static List<List<Cell>> _copyGrid(List<List<Cell>> grid) {
    return grid.map((row) => List<Cell>.from(row)).toList();
  }

  /// Advances to the next player's turn.
  static GameState nextTurn(GameState state) {
    int nextTurnCount = state.turnCount + 1;

    // Identify active owners on the board
    Set<String> ownersOnBoard = {};
    for (var row in state.grid) {
      for (var cell in row) {
        if (cell.ownerId != null) {
          ownersOnBoard.add(cell.ownerId!);
        }
      }
    }

    // Winner check: If only one owner remains after initial turns
    if (ownersOnBoard.length == 1 && nextTurnCount > state.players.length) {
      return state.copyWith(
        winner: state.players.firstWhere((p) => p.id == ownersOnBoard.first),
        isGameOver: true,
        isProcessing: false,
        turnCount: nextTurnCount,
        endTime: DateTime.now(),
      );
    }

    // Find next valid player
    int playersCount = state.players.length;
    int nextIndex = (state.currentPlayerIndex + 1) % playersCount;
    int loops = 0;

    while (loops < playersCount) {
      Player candidate = state.players[nextIndex];
      // Player is alive if they have atoms OR it's early game
      bool isAlive =
          ownersOnBoard.contains(candidate.id) ||
          (nextTurnCount <= playersCount);

      if (isAlive) {
        return state.copyWith(
          currentPlayerIndex: nextIndex,
          turnCount: nextTurnCount,
          isProcessing: false,
        );
      }

      nextIndex = (nextIndex + 1) % playersCount;
      loops++;
    }

    // Fallback: game over
    return state.copyWith(
      isGameOver: true,
      winner: state.players[state.currentPlayerIndex],
      isProcessing: false,
      endTime: DateTime.now(),
    );
  }

  /// Determines if there's a winner during explosions.
  static bool _isWinnerDetermined(List<List<Cell>> grid, List<Player> players) {
    Set<String> owners = {};
    int atoms = 0;
    for (var r in grid) {
      for (var c in r) {
        if (c.ownerId != null) {
          owners.add(c.ownerId!);
          atoms += c.atomCount;
        }
      }
    }
    return owners.length == 1 && atoms > 1;
  }
}
