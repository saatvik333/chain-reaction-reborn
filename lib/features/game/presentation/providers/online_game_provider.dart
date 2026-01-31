import 'dart:async';

import 'package:chain_reaction/features/game/data/services/online_game_service.dart';

import 'package:chain_reaction/features/game/domain/entities/online/online_game_state.dart';
import 'package:chain_reaction/core/services/supabase/supabase_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_game_provider.g.dart';

@riverpod
OnlineGameService onlineGameService(Ref ref) {
  return OnlineGameService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
class OnlineGame extends _$OnlineGame {
  StreamSubscription<OnlineGameState>? _subscription;

  @override
  FutureOr<OnlineGameState?> build() {
    // Capture service reference before onDispose (cannot use ref.read inside lifecycle callbacks)
    final service = ref.watch(onlineGameServiceProvider);
    ref.onDispose(() {
      _subscription?.cancel();
      service.unsubscribe();
    });
    return null;
  }

  Future<void> createGame({required int rows, required int cols}) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(onlineGameServiceProvider);
      final game = await service.createGame(rows: rows, cols: cols);
      _connect(game.id, game);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> joinGame(String roomCode) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(onlineGameServiceProvider);
      final game = await service.joinGame(roomCode);
      _connect(game.id, game);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> leaveGame() async {
    _subscription?.cancel();
    _subscription = null;
    await ref.read(onlineGameServiceProvider).unsubscribe();
    state = const AsyncData(null);
  }

  Future<void> makeMove(int x, int y) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      await ref
          .read(onlineGameServiceProvider)
          .submitMove(
            gameId: currentState.id,
            x: x, // column index
            y: y, // row index
          );
      // We don't manually update state here; we wait for the Realtime stream to fire.
    } catch (e, st) {
      // Logic error or connectivity issue
      state = AsyncError(e, st);
    }
  }

  void _connect(String gameId, OnlineGameState initialState) {
    final service = ref.read(onlineGameServiceProvider);

    // Cancel existing subscription if any
    _subscription?.cancel();

    // Set initial state
    state = AsyncData(initialState);

    // Start listening to the stream
    service.subscribeToGame(gameId);
    _subscription = service.gameStateStream.listen(
      (newState) {
        state = AsyncData(newState);
      },
      onError: (e, st) {
        state = AsyncError(e, st);
      },
    );
  }
}
