import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'cell_widget.dart';

/// Renders the game grid with cells.
class GameGrid extends ConsumerWidget {
  final Function(int x, int y) onCellTap;

  const GameGrid({super.key, required this.onCellTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch precise parts of the state to optimize rebuilds
    final grid = ref.watch(gridProvider);
    final theme = ref.watch(themeProvider).currentTheme;
    final isDark = ref.watch(isDarkModeProvider);
    final borderColor = theme.border(isDark);
    final players = ref.watch(gameStateProvider.select((s) => s?.players));

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
          child: Column(
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

                    // We could wrap CellWidget in a ProviderScope or pass simple values
                    // Passing values is fine here as CellWidget is simple
                    return CellWidget(
                      cell: cell,
                      borderColor: borderColor,
                      cellColor: cellColor,
                      onTap: () => onCellTap(col, row),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
