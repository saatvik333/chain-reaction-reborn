import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createPlayer, type GameState } from "../_shared/game_engine.ts";

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
        const roomCode = body.roomCode?.toUpperCase();

        if (!roomCode || roomCode.length !== 4) {
            return new Response(
                JSON.stringify({ error: "Room code must be 4 characters" }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Find waiting game
        const { data: game, error: findError } = await supabase
            .from("games")
            .select("*")
            .eq("room_code", roomCode)
            .eq("status", "waiting")
            .is("player2_id", null)
            .gt("expires_at", new Date().toISOString())
            .single();

        if (findError || !game) {
            return new Response(
                JSON.stringify({ error: "Room not found or expired" }),
                { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Prevent joining own game
        if (game.player1_id === user.id) {
            return new Response(
                JSON.stringify({ error: "Cannot join your own game" }),
                { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Get user profile
        const { data: profile, error: profileError } = await supabase
            .from("profiles")
            .select("username, display_name")
            .eq("id", user.id)
            .single();

        if (profileError) {
            return new Response(
                JSON.stringify({ error: "Profile not found" }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Create player 2 with proper schema
        const player2 = createPlayer(
            user.id,
            profile.display_name ?? profile.username,
            1  // Color index 1 for player 2
        );

        // Update game state with player 2
        const gameState = game.game_state as GameState;
        gameState.players.push(player2);

        // Update game record
        const { data: updatedGame, error: updateError } = await supabase
            .from("games")
            .update({
                player2_id: user.id,
                game_state: gameState,
                status: "active",
            })
            .eq("id", game.id)
            .eq("status", "waiting") // Optimistic lock
            .is("player2_id", null) // Prevent race condition
            .select("id, room_code, game_state, status")
            .single();

        if (updateError || !updatedGame) {
            return new Response(
                JSON.stringify({ error: "Room is no longer available" }),
                { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                gameId: updatedGame.id,
                roomCode: updatedGame.room_code,
                gameState: updatedGame.game_state,
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
