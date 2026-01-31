# Shared Edge Function Logic

> ⚠️ **CRITICAL SYNC WARNING**
>
> The `game_engine.ts` file is a **manual TypeScript port** of the Dart game logic.

## Source of Truth

The canonical game logic is implemented in Dart at:

```
lib/features/game/domain/logic/game_rules.dart
```

This TypeScript file (`game_engine.ts`) contains a ported version of that logic for server-side move validation in Supabase Edge Functions.

## Maintenance Requirements

**Any changes to game rules MUST be applied to BOTH files:**

1. `lib/features/game/domain/logic/game_rules.dart` (Dart - Client/AI)
2. `supabase/functions/_shared/game_engine.ts` (TypeScript - Server)

## Critical Logic That Must Stay In Sync

| Function | Dart Location | TypeScript Location |
| :--- | :--- | :--- |
| Cell capacity calculation | `GameRules.calculateCapacity` | `getCapacity` |
| Move validation | `GameRules.isValidMove` | `validateMove` |
| Explosion processing | `GameRules.processExplosion` | `processExplosions` |
| Winner detection | `CheckWinnerUseCase` | `checkWinner` |

## Known Limitations

1. **Chain Reaction Limit**: The TypeScript implementation has a safety limit of 1000 iterations to prevent infinite loops. On extremely large grids with complex chain reactions, this could theoretically cause desync.

2. **Flying Atoms**: The client-side Dart logic tracks "flying atoms" for animations. The server-side logic does not track these, as it only cares about the final state.

## Future Work

Consider these approaches to eliminate the sync risk:

- **Code Generation**: Generate TypeScript from Dart using a tool like `dart2ts` or custom codegen.
- **WASM Module**: Compile the Dart logic to WebAssembly and run it in Deno.
- **Single Source of Truth**: Move all game logic to the server and have the client replay moves.
