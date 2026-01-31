-- Enable RLS on all tables
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  games_played INT DEFAULT 0,
  games_won INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- 2. Games Table
CREATE TABLE IF NOT EXISTS public.games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_code TEXT UNIQUE NOT NULL,
  game_state JSONB, -- Stores the full grid and player state (NULL until player2 joins)
  status TEXT CHECK (status IN ('waiting', 'active', 'completed', 'abandoned')) DEFAULT 'waiting',
  player1_id UUID REFERENCES public.profiles(id) NOT NULL,
  player2_id UUID REFERENCES public.profiles(id),
  winner_id UUID REFERENCES public.profiles(id),
  -- Grid dimensions (set at game creation)
  grid_rows INT NOT NULL DEFAULT 8,
  grid_cols INT NOT NULL DEFAULT 6,
  -- Turn tracking for optimistic locking
  current_player_index INT NOT NULL DEFAULT 0,
  turn_number INT NOT NULL DEFAULT 0,
  -- Auto-expiration for abandoned waiting rooms
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 minutes'),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;

-- Games Policies
CREATE POLICY "Games are viewable by everyone (needed for joining)"
  ON public.games FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create games"
  ON public.games FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = player1_id);

CREATE POLICY "Players can update their own games"
  ON public.games FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = player1_id OR 
    auth.uid() = player2_id
  );

-- 3. Game Moves (Audit Log)
CREATE TABLE IF NOT EXISTS public.game_moves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id UUID REFERENCES public.games(id) ON DELETE CASCADE NOT NULL,
  player_id UUID REFERENCES public.profiles(id) NOT NULL,
  -- Move coordinates
  x INT NOT NULL,
  y INT NOT NULL,
  move_number INT NOT NULL,
  -- Legacy field for backwards compatibility
  move_details JSONB, -- Coordinates {x, y}
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.game_moves ENABLE ROW LEVEL SECURITY;

-- Game Moves Policies
CREATE POLICY "Players can view moves in their games"
  ON public.game_moves FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.games
      WHERE games.id = game_moves.game_id
      AND (games.player1_id = auth.uid() OR games.player2_id = auth.uid())
    )
  );

-- ONLY server-side code (Edge Functions) should insert moves to ensure validity
-- However, if we allow client-side inserts for speed (optimistic), we need strictly:
CREATE POLICY "Players can insert moves in their active games"
  ON public.game_moves FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.games
      WHERE games.id = game_moves.game_id
      AND (games.player1_id = auth.uid() OR games.player2_id = auth.uid())
      AND games.status = 'active'
    )
  );

-- 4. Realtime Security
-- Allow listening to game changes
DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime FOR TABLE public.games;
