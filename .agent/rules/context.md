---
trigger: always_on
---

CONTEXT: Chain Reaction Game - Online Multiplayer Integration

GAME DESCRIPTION:
- Turn-based strategy game on configurable grid (default 8x6)
- 2 players alternate placing atoms in cells
- Cells explode when reaching capacity (corners: 2, edges: 3, center: 4)
- Explosions cascade to adjacent cells (chain reactions)
- Winner: last player with atoms on board

CURRENT STATE:
✓ Flutter app with complete local multiplayer
✓ Clean architecture (domain/data/presentation layers)
✓ Existing entities: Cell, GameState, Player, FlyingAtom
✓ Game logic in domain/logic/game_rules.dart
✓ Usecases: PlaceAtom, CheckWinner, InitializeGame, NextTurn
✓ Riverpod state management already implemented
✓ Freezed + json_serializable already configured
✓ AI opponents implemented
✓ Theme system and IAP system

FOLDER STRUCTURE:
- lib/features/game/domain/entities/ (Cell, GameState, Player already exist)
- lib/features/game/domain/logic/game_rules.dart (core logic)
- lib/features/game/domain/usecases/ (PlaceAtom, etc.)
- lib/features/game/presentation/providers/ (Riverpod providers)
- lib/core/services/ (storage, haptic services)

TECH STACK DECISION:
- Backend: Supabase (Postgres + Realtime + Edge Functions + Auth)
- Shared Logic: Extract from existing domain layer
- Client: Extend existing Flutter app (DO NOT recreate)

CRITICAL REQUIREMENTS:
1. PRESERVE existing local multiplayer and AI modes
2. ADD online multiplayer as new mode alongside existing modes
3. Reuse existing entities and game logic (minimal changes)
4. Server authoritative for online mode only
5. Shared Dart code between client/server
6. Move latency <500ms acceptable (turn-based)
7. Room-based matchmaking (4-char codes)

INTEGRATION CONSTRAINTS:
- Must not break existing features (local, AI modes)
- Maintain clean architecture patterns
- Follow existing Riverpod patterns
- Use existing theme system
- Preserve existing routing structure