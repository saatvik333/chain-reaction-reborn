import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final SharedPreferences _prefs;
  static const String _keyGameState = 'active_game_state';

  GameRepositoryImpl(this._prefs);

  @override
  Future<void> saveGame(GameState state) async {
    try {
      final jsonString = jsonEncode(state.toJson());
      await _prefs.setString(_keyGameState, jsonString);
    } catch (e) {
      // Handle serialization errors silently or log them
    }
  }

  @override
  Future<GameState?> loadGame() async {
    final jsonString = _prefs.getString(_keyGameState);
    if (jsonString == null) return null;

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(map);
    } catch (e) {
      // Handle deserialization errors (e.g., schema changes)
      return null;
    }
  }

  @override
  Future<bool> hasSavedGame() async {
    return _prefs.containsKey(_keyGameState);
  }

  @override
  Future<void> clearGame() async {
    await _prefs.remove(_keyGameState);
  }
}
