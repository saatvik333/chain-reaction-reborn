import 'dart:collection';
import '../../models/cell.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../constants/app_constants.dart';

class GameEngine {
  static GameState initializeGame(
    List<Player> players, {
    int? rows,
    int? cols,
  }) {
    final r = rows ?? AppConstants.defaultRows;
    final c = cols ?? AppConstants.defaultCols;

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

    // Provide an initial state with turnCount 0
    return GameState(
      grid: grid,
      players: players,
      currentPlayerIndex: 0,
      turnCount: 0,
    );
  }

  static bool isValidMove(GameState state, int x, int y) {
    if (state.isGameOver || state.isProcessing) return false;
    final cell = state.grid[y][x];
    return cell.ownerId == null || cell.ownerId == state.currentPlayer.id;
  }

  static Stream<GameState> placeAtom(
    GameState currentState,
    int x,
    int y,
  ) async* {
    if (!isValidMove(currentState, x, y)) return;

    final currentPlayer = currentState.currentPlayer;
    List<List<Cell>> grid = _copyGrid(currentState.grid);

    grid[y][x] = grid[y][x].copyWith(
      atomCount: grid[y][x].atomCount + 1,
      ownerId: currentPlayer.id,
    );

    bool needsExplosion = grid[y][x].atomCount > grid[y][x].capacity;

    GameState workingState = currentState.copyWith(
      grid: grid,
      isProcessing: true,
    );

    yield workingState;

    if (needsExplosion) {
      yield* _propagateExplosions(workingState, Queue<Cell>.from([grid[y][x]]));
    }
  }

  static Stream<GameState> _propagateExplosions(
    GameState state,
    Queue<Cell> explosionQueue,
  ) async* {
    List<List<Cell>> grid = _copyGrid(state.grid);
    int rows = grid.length;
    int cols = grid[0].length;
    String currentOwnerId = state.currentPlayer.id;

    while (explosionQueue.isNotEmpty) {
      // 1. Check Win Condition immediately to prevent infinite loops on saturated boards
      if (_isWinnerDetermined(grid, state.players)) {
        // Find winner
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
          );
          return; // Stop explosions immediately
        }
      }

      Cell explodingCell = explosionQueue.removeFirst();
      int cx = explodingCell.x;
      int cy = explodingCell.y;

      // Re-check capacity in case it changed
      if (grid[cy][cx].atomCount <= grid[cy][cx].capacity) continue;

      int criticalMass = grid[cy][cx].capacity + 1;
      grid[cy][cx] = grid[cy][cx].copyWith(
        atomCount: grid[cy][cx].atomCount - criticalMass,
        ownerId: (grid[cy][cx].atomCount - criticalMass) > 0
            ? grid[cy][cx].ownerId
            : null,
        clearOwner: (grid[cy][cx].atomCount - criticalMass) <= 0,
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
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

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

  static List<List<Cell>> _copyGrid(List<List<Cell>> grid) {
    return grid.map((row) => List<Cell>.from(row)).toList();
  }

  static GameState nextTurn(GameState state) {
    int nextTurnCount = state.turnCount + 1;

    // 1. Identify active owners
    Set<String> ownersOnBoard = {};
    for (var row in state.grid) {
      for (var cell in row) {
        if (cell.ownerId != null) {
          ownersOnBoard.add(cell.ownerId!);
        }
      }
    }

    // 2. Winner Check
    // If only one owner remains, AND it's not the start of the game
    // "Start of game" heuristic: If turnCount is less than players count,
    // it's impossible to eliminate everyone else properly unless they placed and lost immediately?
    // Safe check: activeOwners == 1 AND nextTurnCount > state.players.length

    if (ownersOnBoard.length == 1 && nextTurnCount > state.players.length) {
      return state.copyWith(
        winner: state.players.firstWhere((p) => p.id == ownersOnBoard.first),
        isGameOver: true,
        isProcessing: false,
        turnCount: nextTurnCount,
      );
    }

    // 3. Find next valid player
    int playersCount = state.players.length;
    int nextIndex = (state.currentPlayerIndex + 1) % playersCount;
    int loops = 0;

    while (loops < playersCount) {
      Player candidate = state.players[nextIndex];
      // Player is alive if they have atoms OR it's early game.
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

    // If everyone else is dead (should be caught by winner check above unless logic gap),
    // default to current player again or game over.
    return state.copyWith(
      isGameOver: true,
      winner: state.players[state.currentPlayerIndex],
      isProcessing: false,
    );
  }

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
    // If we are exploding (which we are if calling this), and only 1 owner left, they win.
    // Exception: Early game stacking? If P1 places 2 on corner (Turn 1 & 3, P2 pass/dead?).
    // Assuming standard flow, if 1 owner left during explosion, it's a win.
    return owners.length == 1 && atoms > 1;
  }
}
