import '../entities/entities.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../logic/game_rules.dart';

/// Use case for initializing a new game.
///
/// This is a pure function that creates a fresh game state with an empty grid
/// configured for the specified number of players and grid size.
class InitializeGameUseCase {
  final GameRules _rules;

  const InitializeGameUseCase(this._rules);

  /// Creates a new game state with an initialized grid.
  ///
  /// [players] - List of players in the game (minimum 2).
  /// [gridSize] - Named size from AppDimensions.gridSizes (e.g., "Medium").
  /// [rows] - Optional explicit row count (overrides gridSize).
  /// [cols] - Optional explicit column count (overrides gridSize).
  GameState call(
    List<Player> players, {
    String? gridSize,
    int? rows,
    int? cols,
  }) {
    int r = rows ?? 10;
    int c = cols ?? 6;

    // If gridSize string is provided, use the mapping from AppDimensions
    if (gridSize != null && AppDimensions.gridSizes.containsKey(gridSize)) {
      final size = AppDimensions.gridSizes[gridSize]!;
      r = size.$1;
      c = size.$2;
    }

    final grid = _createGrid(r, c);

    return GameState(
      grid: grid,
      players: players,
      currentPlayerIndex: 0,
      turnCount: 0,
      totalMoves: 0,
    );
  }

  /// Creates an empty grid with correct cell capacities.
  List<List<Cell>> _createGrid(int rows, int cols) {
    return List.generate(rows, (y) {
      return List.generate(cols, (x) {
        final capacity = _rules.calculateCapacity(x, y, rows, cols);
        return Cell(x: x, y: y, capacity: capacity);
      });
    });
  }
}
