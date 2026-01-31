import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chain_reaction/routing/routes.dart';
import 'package:chain_reaction/routing/route_args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/features/game/domain/entities/player.dart';
import 'package:chain_reaction/features/game/domain/entities/game_state.dart';
import 'package:chain_reaction/features/game/presentation/providers/providers.dart';
import 'package:chain_reaction/features/game/presentation/providers/online_game_provider.dart';
import 'package:chain_reaction/features/auth/presentation/providers/auth_provider.dart';
import 'package:chain_reaction/features/auth/domain/entities/app_auth_state.dart';
import 'package:chain_reaction/features/game/presentation/widgets/widgets.dart';

import 'package:chain_reaction/core/presentation/widgets/game_menu_dialog.dart';
import 'package:chain_reaction/core/utils/fluid_dialog.dart';
import 'package:chain_reaction/core/presentation/widgets/responsive_container.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int? playerCount;
  final String? gridSize;
  final AIDifficulty? aiDifficulty;
  final bool isResuming;
  final String?
  mode; // 'online', 'local', 'computer' or use Enum if possible. String for now as passed from router.

  const GameScreen({
    super.key,
    this.playerCount,
    this.gridSize,
    this.aiDifficulty,
    this.isResuming = false,
    this.mode,
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
      if (!widget.isResuming && widget.mode != 'online') {
        _initializeGame();
      } else if (widget.mode == 'online') {
        _initializeOnlineGame();
      }
    });
  }

  void _initializeOnlineGame() {
    final onlineState = ref.read(onlineGameProvider).value;
    if (onlineState != null && onlineState.gameState != null) {
      final initialGameState = GameState.fromJson(onlineState.gameState!);
      ref.read(gameProvider.notifier).setExternalState(initialGameState);
    }
  }

  void _initializeGame() {
    if (widget.playerCount == null) return;

    final playerNames = ref.read(playerNamesProvider);
    final themeState = ref.read(themeProvider);
    final playerColors = themeState.playerColors;

    final players = List.generate(widget.playerCount!, (index) {
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
        .read(gameProvider.notifier)
        .initGame(players, gridSize: widget.gridSize);
  }

  void _handleCellTap(int x, int y) {
    if (widget.mode == 'online') {
      _handleOnlineTap(x, y);
      return;
    }

    final gameState = ref.read(gameProvider);
    // Block input if game is processing (AI is thinking or chain reaction happening)
    if (gameState == null ||
        gameState.isProcessing ||
        gameState.currentPlayer.isAI) {
      return;
    }

    if (!ref.read(gameProvider.notifier).isValidMove(x, y)) {
      return;
    }

    // Sound/Haptics now handled by Notifier
    ref.read(gameProvider.notifier).placeAtom(x, y);
  }

  void _handleOnlineTap(int x, int y) {
    // In online mode, we submit the move to the server.
    // The server validates and applies the move, then broadcasts via Realtime.
    final gameState = ref.read(gameProvider);
    final authState = ref.read(authProvider);

    if (gameState == null || gameState.isProcessing) {
      return; // Wait for animations
    }

    // Validate it's current user's turn
    if (authState is AppAuthStateAuthenticated) {
      final currentPlayerId = gameState.currentPlayer.id;
      if (currentPlayerId != authState.userId) {
        // Optional: Show "Not your turn" feedback
        return;
      }
    }

    ref.read(onlineGameProvider.notifier).makeMove(x, y);
  }

  @override
  Widget build(BuildContext context) {
    _listenForGameEnd();
    _listenForOnlineUpdates();

    final gameState = ref.watch(gameProvider);
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
        _showMenuDialog(context, gameState);
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
                onPressed: () => _showMenuDialog(context, gameState),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppDimensions.playerIndicatorSize,
                    height: AppDimensions.playerIndicatorSize,
                    decoration: BoxDecoration(
                      color: currentPlayer.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text(
                    currentPlayer.isAI
                        ? AppLocalizations.of(context)!.computerThinking
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
                  const SizedBox(
                    width: AppDimensions.actionButtonSize,
                    height: AppDimensions.actionButtonSize,
                    child: Center(
                      child: SizedBox(
                        width: AppDimensions.iconM,
                        height: AppDimensions.iconM,
                        child: CircularProgressIndicator(
                          strokeWidth: AppDimensions.loaderStrokeWidth,
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.undo),
                    color: themeState.fg,
                    onPressed: ref.read(gameProvider.notifier).canUndo
                        ? () => ref.read(gameProvider.notifier).undo()
                        : null,
                  ),
                const SizedBox(width: AppDimensions.paddingS),
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
    ref.listen(gameProvider, (previous, next) {
      if (next != null && next.isGameOver && next.winner != null) {
        final winnerIndex = next.players.indexOf(next.winner!) + 1;

        // Use addPostFrameCallback to avoid navigation during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Determine difficulty from state if resuming
            final aiPlayer = next.players.any((p) => p.isAI)
                ? next.players.firstWhere((p) => p.isAI)
                : null;

            context.pushReplacementNamed(
              AppRouteNames.winner,
              extra: WinnerRouteArgs(
                winnerPlayerIndex: winnerIndex,
                totalMoves: next.totalMoves,
                gameDuration: next.formattedDuration,
                territoryPercentage: next.territoryPercentage,
                playerCount: next.players.length,
                gridSize:
                    widget.gridSize ??
                    AppLocalizations.of(context)!.unknownGrid,
                aiDifficulty: widget.aiDifficulty ?? aiPlayer?.difficulty,
              ),
            );
          }
        });
      }
    });
  }

  void _listenForOnlineUpdates() {
    if (widget.mode != 'online') return;

    ref.listen(onlineGameProvider, (prev, next) {
      next.whenData((onlineState) {
        if (onlineState != null && onlineState.gameState != null) {
          // Sync state from server.
          // Optimization: Future work could diff the state to avoid unnecessary rebuilds.

          final newGameState = GameState.fromJson(onlineState.gameState!);
          ref.read(gameProvider.notifier).setExternalState(newGameState);
        }
      });
    });
  }

  void _showMenuDialog(BuildContext context, GameState gameState) {
    // Determine difficulty from state if resuming
    final aiPlayer = gameState.players.any((p) => p.isAI)
        ? gameState.players.firstWhere((p) => p.isAI)
        : null;

    showFluidDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => GameMenuDialog(
        playerCount: gameState.players.length,
        gridSize: widget.gridSize ?? 'medium',
        aiDifficulty: widget.aiDifficulty ?? aiPlayer?.difficulty,
      ),
    );
  }
}
