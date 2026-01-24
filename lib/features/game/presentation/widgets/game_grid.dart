import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'cell_widget.dart';
import 'flying_atom_widget.dart';

/// Renders the game grid with cells and flying atoms.
class GameGrid extends ConsumerWidget {
  final Function(int x, int y) onCellTap;

  const GameGrid({super.key, required this.onCellTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch precise parts of the state to optimize rebuilds
    final grid = ref.watch(gridProvider);
    final themeState = ref.watch(themeProvider);
    final theme = themeState.currentTheme;
    final isDark = ref.watch(isDarkModeProvider);
    final borderColor = theme.border(isDark);
    final players = ref.watch(gameStateProvider.select((s) => s?.players));
    final flyingAtoms = ref.watch(
      gameStateProvider.select((s) => s?.flyingAtoms ?? []),
    );

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

                            return CellWidget(
                              cell: cell,
                              borderColor: borderColor,
                              cellColor: cellColor,
                              onTap: () => onCellTap(col, row),
                              isAtomRotationOn: themeState.isAtomRotationOn,
                              isAtomVibrationOn: themeState.isAtomVibrationOn,
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
