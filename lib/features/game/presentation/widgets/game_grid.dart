import 'dart:async';

import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:chain_reaction/features/game/presentation/providers/providers.dart';

import 'package:chain_reaction/features/game/presentation/widgets/flying_atom_widget.dart';
import 'package:chain_reaction/features/game/presentation/widgets/scoped_cell_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders the game grid with cells and flying atoms.
/// Renders the game grid with cells and flying atoms.
class GameGrid extends ConsumerStatefulWidget {
  const GameGrid({required this.onCellTap, super.key});
  final void Function(int x, int y) onCellTap;

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
    // AtomPainter scales this for speed (e.g. 4x for unstable).
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: AppDimensions.masterAnimationDurationSec,
      ),
    );
    unawaited(_masterController.repeat());
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch precise parts of the state to optimize rebuilds
    // Watch only dimensions to avoid rebuilds on cell content changes
    final rows = ref.watch(gridProvider.select((g) => g?.length ?? 0));
    final cols = ref.watch(
      gridProvider.select((g) => (g?.isNotEmpty ?? false) ? g![0].length : 0),
    );

    final themeState = ref.watch(themeProvider);
    final theme = themeState.currentTheme;
    final isDark = ref.watch(isDarkModeProvider);
    final borderColor = theme.border(isDark: isDark);
    final players = ref.watch(playersProvider);
    final flyingAtoms = ref.watch(flyingAtomsProvider);

    if (rows == 0 || cols == 0 || players == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ColoredBox(
      color: theme.bg(isDark: isDark),
      child: Center(
        child: AspectRatio(
          aspectRatio: cols / rows,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / cols;
              final cellHeight = constraints.maxHeight / rows;
              final cellSize = Size(cellWidth, cellHeight);

              return Stack(
                children: [
                  // Layer 1: The Grid
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor.withValues(
                          alpha: AppDimensions.gridBorderOpacity,
                        ),
                        width: AppDimensions.gridBorderWidth,
                      ),
                    ),
                    child: Column(
                      children: List.generate(rows, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(cols, (col) {
                              const phasePrime1 = 13;
                              const phasePrime2 = 23;
                              const phaseMod = 100;
                              final angleOffset =
                                  ((col * phasePrime1 + row * phasePrime2) %
                                      phaseMod) /
                                  phaseMod.toDouble();

                              return ScopedCellWidget(
                                row: row,
                                col: col,
                                borderColor: borderColor,
                                onTap: () => widget.onCellTap(col, row),
                                animation: _masterController,
                                angleOffset: angleOffset,
                              );
                            }),
                          ),
                        );
                      }),
                    ),
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
