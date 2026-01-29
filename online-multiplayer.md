## Phase 1: Shared Package Extraction

**Objective**: Extract game logic to pure Dart package for client/server reuse.

**Structure**:
```
packages/chain_reaction_shared/
├── lib/
│   ├── src/
│   │   ├── models/
│   │   │   ├── cell.dart (copy from domain/entities)
│   │   │   ├── game_state.dart (copy + modify)
│   │   │   ├── player.dart (copy from domain/entities)
│   │   │   └── models.dart
│   │   ├── logic/
│   │   │   ├── game_engine.dart
│   │   │   └── move_validator.dart
│   │   └── shared.dart
│   └── chain_reaction_shared.dart
├── test/
│   └── game_engine_test.dart
└── pubspec.yaml
```

**GameState Additions**:
```dart
@freezed
class GameState with _$GameState {
  factory GameState({
    required List<List<Cell>> grid,
    required List<Player> players,
    required int currentPlayerIndex,
    @Default(0) int turnNumber,
    String? winnerId,
    @Default(GameMode.local) GameMode mode,  // NEW
    String? roomCode,  // NEW
    @Default(GameStatus.active) GameStatus status,  // NEW
    String? id,  // NEW
    DateTime? createdAt,  // NEW
    DateTime? updatedAt,  // NEW
  }) = _GameState;
}

enum GameMode { local, online, ai }
enum GameStatus { waiting, active, completed }
```

**GameEngine** (static methods):
```dart
class GameEngine {
  static GameState placeAtom(GameState state, int x, int y, String playerId);
  static GameState processExplosions(GameState state);
  static String? checkWinner(GameState state);
  static GameState nextTurn(GameState state);
}
```

**MoveValidator**:
```dart
class MoveValidator {
  static ValidationResult canPlaceAtom(GameState state, int x, int y, String playerId) {
    // Check bounds, game status, turn, cell ownership
    // Return ValidationResult(isValid: bool, errorMessage: String?)
  }
}
```

**Tests Required**:
- Basic placement, corner/edge/center explosions
- Chain reactions (5+ cells)
- Win detection, invalid moves (bounds, wrong turn, opponent cell)
- Serialization roundtrip

**Main App Updates**:
- Import from `package:chain_reaction_shared`
- Update usecases to call `GameEngine.placeAtom(state, x, y, playerId)`

---

## Phase 2: Supabase Setup

**Database Schema**:

```sql
-- profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  games_played INT DEFAULT 0,
  games_won INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- games table
CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_code TEXT UNIQUE NOT NULL CHECK (length(room_code) = 4),
  game_state JSONB NOT NULL,
  status TEXT CHECK (status IN ('waiting', 'active', 'completed')),
  player1_id UUID REFERENCES profiles(id),
  player2_id UUID REFERENCES profiles(id),
  winner_id UUID REFERENCES profiles(id),
  current_player_index INT DEFAULT 0,
  turn_number INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '2 hours'
);

CREATE INDEX idx_room_code ON games(room_code) WHERE status != 'completed';
CREATE INDEX idx_active_games ON games(player1_id, player2_id) WHERE status = 'active';

-- game_moves table (audit log)
CREATE TABLE game_moves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id UUID REFERENCES games(id) ON DELETE CASCADE,
  player_id UUID REFERENCES profiles(id),
  move_number INT NOT NULL,
  x INT NOT NULL,
  y INT NOT NULL,
  resulting_state JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_game_moves ON game_moves(game_id, move_number);
```

**Functions**:
```sql
CREATE FUNCTION generate_room_code() RETURNS TEXT AS $$
  -- Generate random 4-char uppercase alphanumeric
  -- Retry on collision
$$ LANGUAGE plpgsql;

CREATE FUNCTION cleanup_expired_games() RETURNS INT AS $$
  DELETE FROM games WHERE expires_at < NOW() AND status != 'completed';
$$ LANGUAGE sql;
```

**Triggers**:
```sql
CREATE TRIGGER update_games_timestamp
  BEFORE UPDATE ON games
  FOR EACH ROW EXECUTE FUNCTION update_timestamp();
```

**RLS Policies**:
- **profiles**: SELECT public, INSERT/UPDATE own only
- **games**: SELECT if player or waiting, INSERT authenticated, UPDATE players only
- **game_moves**: SELECT players only, INSERT current player only, no UPDATE/DELETE

**Realtime**:
- Enable on `games` and `game_moves` tables

**Auth**:
- Enable Email + Password
- JWT expiry: 7 days
- Email confirmation: disabled for dev

---

## Phase 3: Edge Functions

**If using dart2js**:
```bash
dart compile js lib/chain_reaction_shared.dart -o dist/game_engine.js
```

**If rewriting in TypeScript**: Port `GameEngine` and `MoveValidator` to `supabase/functions/_shared/game_engine.ts`

### Function: submit_move

**Path**: `supabase/functions/submit_move/index.ts`

**Request**:
```json
{ "gameId": "uuid", "x": 0, "y": 0 }
```

**Logic**:
1. Verify JWT, extract `userId`
2. Fetch game: `SELECT * FROM games WHERE id = $1 AND status = 'active'`
3. Verify turn: `game.current_player_index == 0 ? player1_id : player2_id` must match `userId`
4. Validate: `GameEngine.validateMove(gameState, x, y, userId)`
5. Apply: `newState = GameEngine.applyMove(gameState, x, y)`
6. Transaction:
   ```sql
   UPDATE games SET 
     game_state = $1,
     current_player_index = $2,
     turn_number = $3,
     winner_id = $4,
     status = $5,
     updated_at = NOW()
   WHERE id = $6 AND updated_at = $7;  -- Optimistic lock
   
   INSERT INTO game_moves (...) VALUES (...);
   ```
7. Return `{ success: true, newState }`

**Errors**: 401 (no JWT), 403 (wrong turn), 404 (not found), 409 (concurrent update), 422 (invalid move)

### Function: create_game

**Path**: `supabase/functions/create_game/index.ts`

**Request**:
```json
{ "playerName": "string" }
```

**Logic**:
1. Verify JWT
2. Generate room code: call `generate_room_code()`
3. Initialize `GameState`: empty grid, player1 = user, player2 = null, status = waiting
4. Insert into `games`
5. Return `{ gameId, roomCode, expiresAt }`

### Function: join_game

**Path**: `supabase/functions/join_game/index.ts`

**Request**:
```json
{ "roomCode": "ABC1", "playerName": "string" }
```

**Logic**:
1. Verify JWT
2. Find game: `WHERE room_code = $1 AND status = 'waiting' AND player2_id IS NULL AND expires_at > NOW()`
3. Verify `userId != player1_id`
4. Update: set `player2_id = userId`, update `game_state` with player2 info, set `status = 'active'`
5. Return full `GameState`

**Errors**: 404 (not found/expired), 409 (room full), 422 (cannot join own game)

**Deploy**:
```bash
supabase functions deploy submit_move
supabase functions deploy create_game
supabase functions deploy join_game
```

---

## Phase 4: Flutter Integration

**Dependencies**:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
  chain_reaction_shared:
    path: ../packages/chain_reaction_shared
```

**Initialize** (`main.dart`):
```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

### Auth Structure

**Provider** (`lib/features/auth/presentation/providers/auth_provider.dart`):
```dart
@riverpod
class Auth extends _$Auth {
  @override
  User? build() => Supabase.instance.client.auth.currentSession?.user;
  
  Future<void> signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email, password: password,
    );
    state = response.user;
  }
  
  Future<void> signUp(String email, String password, String username) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email, password: password, data: {'username': username},
    );
    if (response.user != null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': response.user!.id, 'username': username,
      });
    }
    state = response.user;
  }
  
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = null;
  }
}
```

**Screens**:
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/signup_screen.dart`

### Online Game Service

**File**: `lib/features/game/data/services/online_game_service.dart`

```dart
class OnlineGameService {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  
  Future<CreateGameResult> createGame() async {
    final response = await _supabase.functions.invoke('create_game');
    return CreateGameResult.fromJson(response.data);
  }
  
  Future<GameState> joinGame(String roomCode) async {
    final response = await _supabase.functions.invoke(
      'join_game', body: {'roomCode': roomCode},
    );
    return GameState.fromJson(response.data);
  }
  
  Future<void> submitMove(String gameId, int x, int y) async {
    await _supabase.functions.invoke(
      'submit_move', body: {'gameId': gameId, 'x': x, 'y': y},
    );
  }
  
  Stream<GameState> subscribeToGame(String gameId) {
    final controller = StreamController<GameState>();
    
    _channel = _supabase.channel('game:$gameId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'games',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: gameId,
        ),
        callback: (payload) {
          final newState = GameState.fromJson(payload.newRecord['game_state']);
          controller.add(newState);
        },
      )
      .subscribe();
    
    return controller.stream;
  }
  
  void dispose() => _channel?.unsubscribe();
}
```

### Online Game Provider

**File**: `lib/features/game/presentation/providers/online_game_provider.dart`

```dart
@riverpod
class OnlineGame extends _$OnlineGame {
  OnlineGameService? _service;
  
  @override
  GameState? build() => null;
  
  Future<String> createGame() async {
    final result = await OnlineGameService().createGame();
    return result.roomCode;  // Navigate to lobby with this
  }
  
  Future<void> joinGame(String roomCode) async {
    _service = OnlineGameService();
    final gameState = await _service!.joinGame(roomCode);
    state = gameState;
    
    _service!.subscribeToGame(gameState.id!).listen((newState) {
      state = newState;
    });
  }
  
  Future<void> placeAtom(int x, int y) async {
    if (state == null) return;
    
    // Optimistic update
    final playerId = state!.players[state!.currentPlayerIndex].id;
    final optimisticState = GameEngine.placeAtom(state!, x, y, playerId);
    state = optimisticState;
    
    try {
      await _service!.submitMove(state!.id!, x, y);
    } catch (e) {
      // Rollback happens via Realtime update
    }
  }
  
  void dispose() => _service?.dispose();
}
```

### UI Updates

**Home Screen** (`lib/features/home/presentation/widgets/home_mode_selection.dart`):
- Add "Play Online" button
- Check auth: if null → navigate to `LoginScreen`, else → show `OnlineMenuDialog`

**Online Menu Dialog** (`lib/features/game/presentation/widgets/online_menu_dialog.dart`):
- "Create Private Room" → calls `createGame()`, navigate to lobby
- "Join Room" → shows text field, calls `joinGame(code)`

**Lobby Screen** (`lib/features/game/presentation/screens/online_lobby_screen.dart`):
- Display room code prominently
- "Waiting for opponent..." message
- Share button (copy code)
- Cancel button
- Listen for `player2_id` update → navigate to `GameScreen`

**Game Screen Modifications** (`lib/features/game/presentation/screens/game_screen.dart`):
```dart
void _onCellTap(int x, int y) {
  if (widget.mode == GameMode.online) {
    ref.read(onlineGameProvider.notifier).placeAtom(x, y);
  } else {
    ref.read(gameStateProvider.notifier).placeAtom(x, y);
  }
}
```

**Online UI Elements**:
- Connection status indicator
- Turn indicator: "Your Turn" / "Opponent's Turn"
- Waiting overlay if opponent disconnects

### Routing

**Add routes** (`lib/routing/app_router.dart`):
```dart
GoRoute(
  path: '/login',
  builder: (context, state) => const LoginScreen(),
),
GoRoute(
  path: '/signup',
  builder: (context, state) => const SignupScreen(),
),
GoRoute(
  path: '/online-lobby',
  builder: (context, state) => OnlineLobbyScreen(
    roomCode: state.extra as String,
  ),
),
```

### Reconnection

**In OnlineGameService**:
```dart
Future<GameState?> checkActiveGame() async {
  final response = await _supabase
    .from('games')
    .select()
    .or('player1_id.eq.${_supabase.auth.currentUser!.id},player2_id.eq.${_supabase.auth.currentUser!.id}')
    .eq('status', 'active')
    .order('updated_at', ascending: false)
    .limit(1)
    .maybeSingle();
  
  if (response != null) {
    return GameState.fromJson(response['game_state']);
  }
  return null;
}
```

**On app resume**: Check for active game, show "Resume Game" dialog

---

## Phase 5: Production Features

**Match History Screen** (`lib/features/game/presentation/screens/match_history_screen.dart`):
```dart
final games = await _supabase
  .from('games')
  .select('*, profiles!games_player1_id_fkey(username), profiles!games_player2_id_fkey(username)')
  .or('player1_id.eq.${userId},player2_id.eq.${userId}')
  .eq('status', 'completed')
  .order('updated_at', ascending: false)
  .limit(20);
```

**Profile Screen** (`lib/features/auth/presentation/screens/profile_screen.dart`):
- Display username, `games_played`, `games_won` from `profiles`
- Edit username, logout, delete account buttons

**Rematch Feature**:
- "Play Again" button on winner screen (online only)
- Creates new game, swaps turn order
- Sends notification via Realtime presence

**Presence System**:
```dart
_channel.on(RealtimeListenTypes.presence, PresencePayload(), (payload) {
  // Show "Opponent is thinking..." indicator
});
```

**Rate Limiting** (Edge Function middleware):
```typescript
const rateLimitKey = `ratelimit:${userId}:${functionName}`;
const count = await redis.incr(rateLimitKey);
if (count === 1) await redis.expire(rateLimitKey, 60);
if (count > 100) return new Response('Rate limit exceeded', { status: 429 });
```

**Analytics Events**:
- `online_game_created`
- `online_game_joined`
- `online_game_completed`
- `average_moves_per_game`

**Security Audit Checklist**:
- [ ] RLS policies tested with Postman
- [ ] Edge Functions validate JWT
- [ ] Move validation server-side
- [ ] No sensitive data in logs
- [ ] Rate limiting active

**Performance**:
- Add loading states to all async ops
- Cache user profile locally
- Lazy load match history (pagination)
- Unsubscribe from Realtime when not in game

**Documentation**:
- `ONLINE_MODE.md`: Architecture overview
- `API.md`: Edge Functions documentation
- `DEPLOYMENT.md`: Supabase setup steps

**Beta Testing**:
1. Deploy to Supabase staging
2. TestFlight with 20 users
3. Monitor error logs (Sentry)
4. Fix critical bugs
5. Iterate 2 weeks

**Deployment**:
```bash
# Database migrations
supabase db push

# Edge Functions
supabase functions deploy submit_move
supabase functions deploy create_game
supabase functions deploy join_game

# Flutter
flutter build apk --release
flutter build ios --release
flutter build web --release
```

---

## Quick Reference

**Tech Stack**: Supabase (Postgres, Realtime, Edge Functions, Auth), Shared Dart package, Riverpod  
**Database**: `profiles`, `games`, `game_moves`  
**Edge Functions**: `create_game`, `join_game`, `submit_move`  
**Flutter**: Auth screens, OnlineGameService, OnlineGameProvider, modified GameScreen  
**Game Modes**: Local (existing), AI (existing), Online (new)