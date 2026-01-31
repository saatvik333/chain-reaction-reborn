import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/online/online_game_state.dart';
import '../../domain/failures/game_failure.dart';

/// Service for online game operations with typed failures and auto-reconnection.
class OnlineGameService {
  final SupabaseClient _supabase;
  RealtimeChannel? _gameChannel;

  /// Maximum reconnection attempts before giving up.
  static const int _maxReconnectAttempts = 5;

  /// Current reconnection attempt count.
  int _reconnectAttempts = 0;

  /// Current game ID for reconnection.
  String? _currentGameId;

  OnlineGameService(this._supabase);

  /// Stream controller for game state updates.
  final _gameStateController = StreamController<OnlineGameState>.broadcast();
  Stream<OnlineGameState> get gameStateStream => _gameStateController.stream;

  /// Stream controller for connection state.
  final _connectionStateController =
      StreamController<RealtimeConnectionState>.broadcast();
  Stream<RealtimeConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Create a new online game.
  ///
  /// Throws [GameFailure] on error.
  Future<OnlineGameState> createGame({
    required int rows,
    required int cols,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create_game',
        body: {'gridRows': rows, 'gridCols': cols},
      );

      if (response.status == 401) {
        throw const GameFailure.authRequired();
      }

      if (response.status != 200) {
        final errorMsg = _extractErrorMessage(response.data);
        throw GameFailure.serverError(errorMsg);
      }

      final data = response.data as Map<String, dynamic>;
      final gameId = data['gameId'] as String;
      final roomCode = data['roomCode'] as String;

      return OnlineGameState(
        id: gameId,
        roomCode: roomCode,
        player1Id: _supabase.auth.currentUser!.id,
        player2Id: null,
        status: 'waiting',
        currentPlayerIndex: 0,
        turnNumber: 0,
        winnerId: null,
        gameState: null,
        gridRows: rows,
        gridCols: cols,
        createdAt: DateTime.now(),
      );
    } on GameFailure {
      rethrow;
    } on FunctionException catch (e) {
      throw _mapFunctionException(e);
    } catch (e) {
      throw GameFailure.unknown(e.toString());
    }
  }

  /// Join an existing game by room code.
  ///
  /// Throws [GameFailure] on error.
  Future<OnlineGameState> joinGame(String roomCode) async {
    try {
      final response = await _supabase.functions.invoke(
        'join_game',
        body: {'roomCode': roomCode},
      );

      if (response.status == 401) {
        throw const GameFailure.authRequired();
      }

      if (response.status != 200) {
        final errorMsg = _extractErrorMessage(response.data);
        throw _mapJoinError(errorMsg);
      }

      final data = response.data as Map<String, dynamic>;
      return OnlineGameState.fromJson(data);
    } on GameFailure {
      rethrow;
    } on FunctionException catch (e) {
      throw _mapFunctionException(e);
    } catch (e) {
      throw GameFailure.unknown(e.toString());
    }
  }

  /// Submit a move to the server.
  ///
  /// Throws [GameFailure] on error.
  Future<void> submitMove({
    required String gameId,
    required int x,
    required int y,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'submit_move',
        body: {'gameId': gameId, 'x': x, 'y': y},
      );

      if (response.status == 401) {
        throw const GameFailure.authRequired();
      }

      if (response.status != 200) {
        final errorMsg = _extractErrorMessage(response.data);
        throw _mapMoveError(errorMsg);
      }
    } on GameFailure {
      rethrow;
    } on FunctionException catch (e) {
      throw _mapFunctionException(e);
    } catch (e) {
      throw GameFailure.unknown(e.toString());
    }
  }

  /// Subscribe to game updates via Realtime with auto-reconnection.
  Future<void> subscribeToGame(String gameId) async {
    await unsubscribe();
    _currentGameId = gameId;
    _reconnectAttempts = 0;
    _connectionStateController.add(RealtimeConnectionState.connecting);

    await _connectToChannel(gameId);
  }

  Future<void> _connectToChannel(String gameId) async {
    _gameChannel = _supabase
        .channel('game:$gameId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'games',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: gameId,
          ),
          callback: (payload) {
            _reconnectAttempts = 0; // Reset on successful message
            final newState = OnlineGameState.fromJson(payload.newRecord);
            _gameStateController.add(newState);
          },
        );

    _gameChannel!.subscribe((status, [error]) {
      switch (status) {
        case RealtimeSubscribeStatus.subscribed:
          _connectionStateController.add(RealtimeConnectionState.connected);
          _reconnectAttempts = 0;
        case RealtimeSubscribeStatus.closed:
          if (_currentGameId != null) {
            _connectionStateController.add(
              RealtimeConnectionState.disconnected,
            );
            _attemptReconnect();
          }
        case RealtimeSubscribeStatus.channelError:
        case RealtimeSubscribeStatus.timedOut:
          _connectionStateController.add(RealtimeConnectionState.error);
          _attemptReconnect();
      }
    });
  }

  /// Attempt to reconnect with exponential backoff.
  Future<void> _attemptReconnect() async {
    if (_currentGameId == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _gameStateController.addError(const GameFailure.connectionLost());
      return;
    }

    _reconnectAttempts++;
    _connectionStateController.add(RealtimeConnectionState.reconnecting);

    // Exponential backoff: 1s, 2s, 4s, 8s, 16s
    final delay = Duration(seconds: 1 << (_reconnectAttempts - 1));
    await Future.delayed(delay);

    if (_currentGameId != null) {
      try {
        await _connectToChannel(_currentGameId!);
      } catch (_) {
        _attemptReconnect();
      }
    }
  }

  /// Unsubscribe from current game.
  Future<void> unsubscribe() async {
    _currentGameId = null;
    if (_gameChannel != null) {
      await _supabase.removeChannel(_gameChannel!);
      _gameChannel = null;
    }
  }

  /// Fetch initial game state.
  Future<OnlineGameState> fetchGameState(String gameId) async {
    try {
      final response = await _supabase
          .from('games')
          .select()
          .eq('id', gameId)
          .single();
      return OnlineGameState.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const GameFailure.roomNotFound();
      }
      throw GameFailure.serverError(e.message);
    } catch (e) {
      throw GameFailure.unknown(e.toString());
    }
  }

  /// Dispose of resources.
  void dispose() {
    _currentGameId = null;
    _gameStateController.close();
    _connectionStateController.close();
  }

  // --- Private helper methods ---

  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['error']?.toString() ?? data.toString();
    }
    return data?.toString() ?? 'Unknown error';
  }

  GameFailure _mapFunctionException(FunctionException e) {
    if (e.status == 401) {
      return const GameFailure.authRequired();
    }
    return GameFailure.serverError(
      e.details?.toString() ?? e.reasonPhrase ?? 'Function error',
    );
  }

  GameFailure _mapJoinError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('not found') || lower.contains('no game')) {
      return const GameFailure.roomNotFound();
    }
    if (lower.contains('full') || lower.contains('already')) {
      return const GameFailure.roomFull();
    }
    if (lower.contains('expired')) {
      return const GameFailure.roomExpired();
    }
    if (lower.contains('own room') || lower.contains('own game')) {
      return const GameFailure.cannotJoinOwnRoom();
    }
    return GameFailure.serverError(message);
  }

  GameFailure _mapMoveError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('not your turn')) {
      return const GameFailure.notYourTurn();
    }
    if (lower.contains('invalid move') || lower.contains('cannot place')) {
      return GameFailure.invalidMove(message);
    }
    if (lower.contains('not active') || lower.contains('game over')) {
      return const GameFailure.gameNotActive();
    }
    if (lower.contains('not a participant') ||
        lower.contains('not authorized')) {
      return const GameFailure.notParticipant();
    }
    return GameFailure.serverError(message);
  }
}

/// Connection state for Realtime subscriptions.
enum RealtimeConnectionState {
  connecting,
  connected,
  disconnected,
  reconnecting,
  error,
}
