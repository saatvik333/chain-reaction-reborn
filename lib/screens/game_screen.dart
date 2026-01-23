import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/theme_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/game_menu_dialog.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../logic/game_engine.dart';
import '../constants/app_dimensions.dart';
import 'winner_screen.dart';

class GameScreen extends StatefulWidget {
  final int playerCount;
  final String gridSize;

  const GameScreen({
    super.key,
    required this.playerCount,
    required this.gridSize,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState? _gameState;
  StreamSubscription<GameState>? _explosionSubscription;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Don't call _initializeGame here - context is not available yet
  }

  @override
  void dispose() {
    _explosionSubscription?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    if (_initialized) return;
    _initialized = true;

    // Build players list using theme colors
    final themeProvider = ThemeScope.of(context);
    final playerProvider = PlayerScope.of(context);
    final playerColors = themeProvider.playerColors;

    final players = List.generate(widget.playerCount, (index) {
      final playerIndex = index + 1;
      return Player(
        id: 'player_$playerIndex',
        name: playerProvider.getName(playerIndex),
        color: playerColors[index % playerColors.length],
      );
    });

    _gameState = GameEngine.initializeGame(players, gridSize: widget.gridSize);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize game here since we need context for ThemeScope
    if (!_initialized) {
      _initializeGame();
    }
  }

  void _handleCellTap(int x, int y) {
    final gameState = _gameState;
    if (gameState == null) return;
    if (gameState.isGameOver || gameState.isProcessing) return;
    if (!GameEngine.isValidMove(gameState, x, y)) return;

    final theme = ThemeScope.of(context);

    // Trigger feedback
    if (theme.isHapticOn) {
      HapticFeedback.lightImpact();
    }
    if (theme.isSoundOn) {
      SystemSound.play(SystemSoundType.click);
    }

    // Listen to the stream of game states during explosions
    _explosionSubscription?.cancel();
    _explosionSubscription = GameEngine.placeAtom(gameState, x, y).listen(
      (newState) {
        setState(() {
          _gameState = newState;
        });
      },
      onDone: () {
        final currentState = _gameState;
        if (currentState == null) return;

        // After explosions complete, check for win or advance turn
        if (!currentState.isGameOver) {
          setState(() {
            _gameState = GameEngine.nextTurn(currentState);
          });
        }

        // Navigate to winner screen if game over
        final finalState = _gameState;
        if (finalState != null &&
            finalState.isGameOver &&
            finalState.winner != null) {
          final winnerIndex =
              finalState.players.indexOf(finalState.winner!) + 1;
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => WinnerScreen(
                  winnerPlayerIndex: winnerIndex,
                  totalMoves: finalState.totalMoves,
                  gameDuration: finalState.formattedDuration,
                  territoryPercentage: finalState.territoryPercentage,
                ),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final gameState = _gameState;

    // Show loading if game not initialized yet
    if (gameState == null) {
      return Scaffold(
        backgroundColor: theme.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentPlayer = gameState.currentPlayer;
    final playerColor = currentPlayer.color;
    final rows = gameState.rows;
    final cols = gameState.cols;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.8),
          builder: (context) => GameMenuDialog(
            playerCount: widget.playerCount,
            gridSize: widget.gridSize,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: theme.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: theme.fg),
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.8),
                builder: (context) => GameMenuDialog(
                  playerCount: widget.playerCount,
                  gridSize: widget.gridSize,
                ),
              );
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: playerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currentPlayer.name,
                style: TextStyle(
                  color: playerColor,
                  fontSize: AppDimensions.fontL,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            if (gameState.isProcessing)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.gridPadding),
            child: Center(
              child: AspectRatio(
                aspectRatio: cols / rows,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    children: List.generate(rows, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(cols, (col) {
                            final cell = gameState.grid[row][col];
                            Color cellColor = Colors.transparent;

                            if (cell.ownerId != null) {
                              final owner = gameState.players.firstWhere(
                                (p) => p.id == cell.ownerId,
                                orElse: () => gameState.players.first,
                              );
                              cellColor = owner.color;
                            }

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _handleCellTap(col, row),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.border.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: _buildAtoms(
                                      cellColor,
                                      cell.atomCount,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAtoms(Color color, int count) {
    if (color == Colors.transparent || count == 0) return const SizedBox();

    if (count == 1) {
      return _buildAtomCircle(color);
    } else if (count == 2) {
      return Stack(
        children: [
          Transform.translate(
            offset: const Offset(-6, -6),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(6, 6),
            child: _buildAtomCircle(color),
          ),
        ],
      );
    } else if (count == 3) {
      return Stack(
        children: [
          Transform.translate(
            offset: const Offset(0, -8),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(-7, 5),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(7, 5),
            child: _buildAtomCircle(color),
          ),
        ],
      );
    } else {
      // 4+ atoms: show 4 in a diamond pattern
      return Stack(
        children: [
          Transform.translate(
            offset: const Offset(0, -8),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(8, 0),
            child: _buildAtomCircle(color),
          ),
          Transform.translate(
            offset: const Offset(0, 8),
            child: _buildAtomCircle(color),
          ),
        ],
      );
    }
  }

  Widget _buildAtomCircle(Color color) {
    return Container(
      width: AppDimensions.orbSizeSmall,
      height: AppDimensions.orbSizeSmall,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
