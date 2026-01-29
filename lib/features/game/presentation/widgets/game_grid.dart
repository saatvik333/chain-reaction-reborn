import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'cell_widget.dart';
import 'flying_atom_widget.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Renders the game grid with cells and flying atoms.
/// Renders the game grid with cells and flying atoms.
class GameGrid extends ConsumerStatefulWidget {
  final Function(int x, int y) onCellTap;

  const GameGrid({super.key, required this.onCellTap});

  @override
  ConsumerState<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends ConsumerState<GameGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _masterController;

  @override
  void initState() {
    super.initState();
    // Master loop: 4 seconds.
    // 0.0 -> 1.0 continuously.
    // AtomPainter scales this for speed (e.g. 4x for unstable).
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
    // Watch precise parts of the state to optimize rebuilds
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
                    children: List.generate(rows, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(cols, (col) {
                            final cell = grid[row][col];
                            Color cellColor = Colors.transparent;

                            if (cell.ownerId != null) {
                              final owner = players.firstWhere(
                                (p) => p.id == cell.ownerId,
                                orElse: () => players.first,
                              );
                              cellColor = owner.color;
                            }

                            // Calculate a deterministic phase offset (0.0 to 1.0)
                            // This ensures atoms don't rotate in perfect unison.
                            // We use prime number multipliers to avoid noticeable patterns.
                            const int phasePrime1 = 13;
                            const int phasePrime2 = 23;
                            const int phaseMod = 100;
                            final double angleOffset =
                                ((col * phasePrime1 + row * phasePrime2) %
                                    phaseMod) /
                                phaseMod.toDouble();

                            return CellWidget(
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
                          }),
                        ),
                      );
                    }),
                  ),

                  // Layer 2: Flying Atoms (Projectiles)
                  ...flyingAtoms.map(
                    (atom) => FlyingAtomWidget(
                      key: ValueKey(atom.id),
                      atom: atom,
                      cellSize: cellSize,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
