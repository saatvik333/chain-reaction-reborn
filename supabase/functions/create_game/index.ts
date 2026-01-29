import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { initializeGrid } from "../_shared/game_engine.ts";

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
        const body = await req.json().catch(() => ({}));
        const gridRows = body.gridRows ?? 8;
        const gridCols = body.gridCols ?? 6;

        // Get user profile
        const { data: profile, error: profileError } = await supabase
            .from("profiles")
            .select("username, display_name")
            .eq("id", user.id)
            .single();

        if (profileError) {
            return new Response(
                JSON.stringify({ error: "Profile not found. Please complete signup." }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Initialize game state
        const initialGrid = initializeGrid(gridRows, gridCols);
        const gameState = {
            grid: initialGrid,
            currentPlayerIndex: 0,
            turnNumber: 0,
            isGameOver: false,
            winnerId: null,
            players: [
                {
                    id: user.id,
                    name: profile.display_name ?? profile.username,
                    colorIndex: 0,
                },
            ],
        };

        // Create game record
        const { data: game, error: gameError } = await supabase
            .from("games")
            .insert({
                player1_id: user.id,
                game_state: gameState,
                grid_rows: gridRows,
                grid_cols: gridCols,
                status: "waiting",
            })
            .select("id, room_code, expires_at")
            .single();

        if (gameError) {
            console.error("Game creation error:", gameError);
            return new Response(
                JSON.stringify({ error: "Failed to create game" }),
                { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                gameId: game.id,
                roomCode: game.room_code,
                expiresAt: game.expires_at,
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
