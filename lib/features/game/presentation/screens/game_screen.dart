import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/presentation/providers/providers.dart';
import 'package:chain_reaction/features/game/presentation/widgets/widgets.dart';
import 'winner_screen.dart';
import 'package:chain_reaction/widgets/game_menu_dialog.dart';
import 'package:chain_reaction/core/utils/fluid_dialog.dart';
import 'package:chain_reaction/widgets/responsive_container.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int playerCount;
  final String gridSize;
  final AIDifficulty? aiDifficulty;

  const GameScreen({
    super.key,
    required this.playerCount,
    required this.gridSize,
    this.aiDifficulty,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize game after first frame to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeGame() {
    final playerNames = ref.read(playerNamesProvider);
    final themeState = ref.read(themeProvider);
    final playerColors = themeState.playerColors;

    final players = List.generate(widget.playerCount, (index) {
      final playerIndex = index + 1;
      // If AI mode is active (difficulty != null), Player 2 is AI
      final isAI = widget.aiDifficulty != null && index == 1;

      return Player(
        id: 'player_$playerIndex',
        name: isAI ? 'Computer' : playerNames.getName(playerIndex),
        color: playerColors[index % playerColors.length],
        type: isAI ? PlayerType.ai : PlayerType.human,
        difficulty: isAI ? widget.aiDifficulty : null,
      );
    });

    ref
        .read(gameStateProvider.notifier)
        .initGame(players, gridSize: widget.gridSize);
  }

  void _handleCellTap(int x, int y) {
    final gameState = ref.read(gameStateProvider);
    // Block input if game is processing (AI is thinking or chain reaction happening)
    if (gameState == null ||
        gameState.isProcessing ||
        gameState.currentPlayer.isAI) {
      return;
    }

    if (!ref.read(gameStateProvider.notifier).isValidMove(x, y)) return;

    final themeState = ref.read(themeProvider);

    // Trigger feedback
    if (themeState.isHapticOn) {
      HapticFeedback.lightImpact();
    }
    if (themeState.isSoundOn) {
      SystemSound.play(SystemSoundType.click);
    }

    ref.read(gameStateProvider.notifier).placeAtom(x, y);
  }

  @override
  Widget build(BuildContext context) {
    _listenForGameEnd();

    final gameState = ref.watch(gameStateProvider);
    final themeState = ref.watch(themeProvider);

    // Show loading if game not initialized yet
    if (gameState == null) {
      return Scaffold(
        backgroundColor: themeState.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentPlayer = gameState.currentPlayer;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _showMenuDialog(context);
      },
      child: Container(
        color: themeState.bg,
        child: ResponsiveContainer(
          child: Scaffold(
            backgroundColor: themeState.bg,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, color: themeState.fg),
                onPressed: () => _showMenuDialog(context),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentPlayer.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentPlayer.isAI
                        ? 'Computer Thinking...'
                        : currentPlayer.name,
                    style: TextStyle(
                      color: currentPlayer.color,
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
                child: RepaintBoundary(
                  child: GameGrid(onCellTap: _handleCellTap),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listenForGameEnd() {
    ref.listen(gameStateProvider, (previous, next) {
      if (next != null && next.isGameOver && next.winner != null) {
        final winnerIndex = next.players.indexOf(next.winner!) + 1;

        // Navigate to winner screen
        // Use addPostFrameCallback to avoid navigation during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => WinnerScreen(
                  winnerPlayerIndex: winnerIndex,
                  totalMoves: next.totalMoves,
                  gameDuration: next.formattedDuration,
                  territoryPercentage: next.territoryPercentage,
                  playerCount: widget.playerCount,
                  gridSize: widget.gridSize,
                  aiDifficulty: widget.aiDifficulty,
                ),
              ),
            );
          }
        });
      }
    });
  }

  void _showMenuDialog(BuildContext context) {
    showFluidDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => GameMenuDialog(
        playerCount: widget.playerCount,
        gridSize: widget.gridSize,
        aiDifficulty: widget.aiDifficulty,
      ),
    );
  }
}
