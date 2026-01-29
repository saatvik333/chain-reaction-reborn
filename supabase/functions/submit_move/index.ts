import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { validateMove, applyMove, type GameState, type Player } from "../_shared/game_engine.ts";

Deno.serve(async (req: Request) => {
    // Handle CORS preflight
    const corsResponse = handleCors(req);
    if (corsResponse) return corsResponse;

    try {
        // Get auth token
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: "Missing authorization header" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Create Supabase client with user context
        const supabase = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: authHeader } } }
        );

        // Get current user
        const token = authHeader.replace("Bearer ", "");
        const { data: { user }, error: userError } = await supabase.auth.getUser(token);

        if (userError || !user) {
            return new Response(
                JSON.stringify({ error: "Invalid token" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Parse request body
        const body = await req.json();
        const { gameId, x, y } = body;

        if (!gameId || typeof x !== "number" || typeof y !== "number") {
            return new Response(
                JSON.stringify({ error: "Missing gameId, x, or y" }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Fetch game with optimistic lock
        const { data: game, error: gameError } = await supabase
            .from("games")
            .select("*")
            .eq("id", gameId)
            .eq("status", "active")
            .single();

        if (gameError || !game) {
            return new Response(
                JSON.stringify({ error: "Game not found or not active" }),
                { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Verify player is part of game
        if (game.player1_id !== user.id && game.player2_id !== user.id) {
            return new Response(
                JSON.stringify({ error: "You are not a player in this game" }),
                { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const gameState = game.game_state as GameState & { players: Player[] };
        const players = gameState.players;

        // Validate move
        const validation = validateMove(gameState, x, y, user.id, players);
        if (!validation.valid) {
            return new Response(
                JSON.stringify({ error: validation.error }),
                { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Apply move
        const newState = applyMove(gameState, x, y, user.id, players.length);

        // Preserve players array (not part of core GameState)
        const fullNewState = { ...newState, players };

        // Determine new status
        const newStatus = newState.isGameOver ? "completed" : "active";
        const newTurnNumber = newState.turnNumber;

        // Update game with optimistic locking
        const { data: updatedGame, error: updateError } = await supabase
            .from("games")
            .update({
                game_state: fullNewState,
                current_player_index: newState.currentPlayerIndex,
                turn_number: newTurnNumber,
                winner_id: newState.winnerId,
                status: newStatus,
            })
            .eq("id", gameId)
            .eq("turn_number", game.turn_number) // Optimistic lock
            .select("id, game_state, status, winner_id")
            .single();

        if (updateError || !updatedGame) {
            return new Response(
                JSON.stringify({ error: "Concurrent update detected. Please retry." }),
                { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Record move in audit log
        await supabase.from("game_moves").insert({
            game_id: gameId,
            player_id: user.id,
            move_number: newTurnNumber,
            x,
            y,
        });

        // Update player stats if game is over
        if (newState.isGameOver && newState.winnerId) {
            // Increment games_played for both
            await supabase.rpc("increment_games_played", {
                p1_id: game.player1_id,
                p2_id: game.player2_id
            }).catch(() => { }); // Non-critical

            // Increment games_won for winner
            await supabase
                .from("profiles")
                .update({ games_won: supabase.rpc("increment", { x: 1 }) })
                .eq("id", newState.winnerId)
                .catch(() => { }); // Non-critical
        }

        return new Response(
            JSON.stringify({
                success: true,
                gameState: updatedGame.game_state,
                isGameOver: newState.isGameOver,
                winnerId: newState.winnerId,
            }),
            { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    } catch (error) {
        console.error("Unexpected error:", error);
        return new Response(
            JSON.stringify({ error: "Internal server error" }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
