import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/online/online_game_state.dart';

class OnlineGameService {
  final SupabaseClient _supabase;
  RealtimeChannel? _gameChannel;

  OnlineGameService(this._supabase);

  // Stream controller for game state updates
  final _gameStateController = StreamController<OnlineGameState>.broadcast();
  Stream<OnlineGameState> get gameStateStream => _gameStateController.stream;

  /// Create a new online game
  Future<Map<String, dynamic>> createGame({
    required int rows,
    required int cols,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create_game',
        body: {'rows': rows, 'cols': cols},
      );

      if (response.status != 200) {
        throw Exception('Failed to create game: ${response.data}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error creating game: $e');
    }
  }

  /// Join an existing game
  Future<void> joinGame(String roomCode) async {
    try {
      final response = await _supabase.functions.invoke(
        'join_game',
        body: {'roomCode': roomCode},
      );

      if (response.status != 200) {
        throw Exception('Failed to join game: ${response.data}');
      }

      // Initial state is returned by the function? Or we fetch it?
      // The join_game function returns the updated game object.
      // We should parse it and emit it.
      // But let's subscribe first to ensure we don't miss updates.
    } catch (e) {
      throw Exception('Error joining game: $e');
    }
  }

  /// Submit a move to the server
  Future<void> submitMove({
    required String gameId,
    required int rowIndex,
    required int colIndex,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'submit_move',
        body: {'gameId': gameId, 'rowIndex': rowIndex, 'colIndex': colIndex},
      );

      if (response.status != 200) {
        throw Exception('Failed to submit move: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error submitting move: $e');
    }
  }

  /// Subscribe to game updates via Realtime
  Future<void> subscribeToGame(String gameId) async {
    await unsubscribe(); // Ensure clean state

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
            final newState = OnlineGameState.fromJson(payload.newRecord);
            _gameStateController.add(newState);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from current game
  Future<void> unsubscribe() async {
    if (_gameChannel != null) {
      await _supabase.removeChannel(_gameChannel!);
      _gameChannel = null;
    }
  }

  /// Fetch initial game state
  Future<OnlineGameState> fetchGameState(String gameId) async {
    final response = await _supabase
        .from('games')
        .select()
        .eq('id', gameId)
        .single();
    return OnlineGameState.fromJson(response);
  }
}
