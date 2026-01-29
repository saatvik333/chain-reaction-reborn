import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'cell_widget.dart';
import 'flying_atom_widget.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/player.dart';

/// Renders the game grid with cells and flying atoms.
class GameGrid extends ConsumerStatefulWidget {
  final Function(int x, int y) onCellTap;

  const GameGrid({super.key, required this.onCellTap});

  @override
  ConsumerState<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends ConsumerState<GameGrid>
    with SingleTickerProviderStateMixin {
  /// Continuous animation for atom rotation/breathing effects.
  late final AnimationController _masterController;

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: AppDimensions.masterAnimationDurationSec,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grid = ref.watch(gridProvider);
    final themeState = ref.watch(themeProvider);
    final theme = themeState.currentTheme;
    final isDark = ref.watch(isDarkModeProvider);
    final borderColor = theme.border(isDark);
    final players = ref.watch(playersProvider);
    final flyingAtoms = ref.watch(flyingAtomsProvider);

    if (grid == null || players == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final rows = grid.length;
    final cols = grid[0].length;

    // Precompute phase constants outside render loop
    const int phasePrime1 = 13;
    const int phasePrime2 = 23;
    const int phaseMod = 100;

    return Center(
      child: AspectRatio(
        aspectRatio: cols / rows,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: borderColor)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / cols;
              final cellHeight = constraints.maxHeight / rows;
              final cellSize = Size(cellWidth, cellHeight);

              return Stack(
                children: [
                  // Layer 1: The Grid
                  Column(
                    children: [
                      for (int row = 0; row < rows; row++)
                        Expanded(
                          child: Row(
                            children: [
                              for (int col = 0; col < cols; col++)
                                _buildCell(
                                  grid[row][col],
                                  row,
                                  col,
                                  players,
                                  borderColor,
                                  themeState,
                                  phasePrime1,
                                  phasePrime2,
                                  phaseMod,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Layer 2: Flying Atoms (Projectiles)
                  for (final atom in flyingAtoms)
                    FlyingAtomWidget(
                      key: ValueKey(atom.id),
                      atom: atom,
                      cellSize: cellSize,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds a single cell widget with pre-computed parameters.
  Widget _buildCell(
    Cell cell,
    int row,
    int col,
    List<Player> players,
    Color borderColor,
    ThemeState themeState,
    int phasePrime1,
    int phasePrime2,
    int phaseMod,
  ) {
    Color cellColor = Colors.transparent;

    if (cell.ownerId != null) {
      final owner = players.firstWhere(
        (p) => p.id == cell.ownerId,
        orElse: () => players.first,
      );
      cellColor = owner.color;
    }

    final double angleOffset =
        ((col * phasePrime1 + row * phasePrime2) % phaseMod) /
        phaseMod.toDouble();

    return CellWidget(
      key: ValueKey('cell_${col}_$row'),
      cell: cell,
      borderColor: borderColor,
      cellColor: cellColor,
      onTap: () => widget.onCellTap(col, row),
      isAtomRotationOn: themeState.isAtomRotationOn,
      isAtomVibrationOn: themeState.isAtomVibrationOn,
      isAtomBreathingOn: themeState.isAtomBreathingOn,
      isCellHighlightOn: themeState.isCellHighlightOn,
      animation: _masterController,
      angleOffset: angleOffset,
    );
  }
}
