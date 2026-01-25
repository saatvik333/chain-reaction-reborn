import '../entities/game_state.dart';

abstract class GameRepository {
  Future<void> saveGame(GameState state);
  Future<GameState?> loadGame();
  Future<bool> hasSavedGame();
  Future<void> clearGame();
}
