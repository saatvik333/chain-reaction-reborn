-- Migration: 002_create_games
-- Creates the games table for online multiplayer rooms

-- Helper function to generate unique room codes
CREATE OR REPLACE FUNCTION public.generate_room_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code TEXT := '';
  i INT;
BEGIN
  LOOP
    code := '';
    FOR i IN 1..4 LOOP
      code := code || substr(chars, floor(random() * length(chars) + 1)::int, 1);
    END LOOP;
    -- Check for uniqueness among active games
    IF NOT EXISTS (SELECT 1 FROM public.games WHERE room_code = code AND status != 'completed') THEN
      RETURN code;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Games table
CREATE TABLE public.games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_code TEXT UNIQUE NOT NULL DEFAULT public.generate_room_code(),
  game_state JSONB NOT NULL,
  status TEXT CHECK (status IN ('waiting', 'active', 'completed')) DEFAULT 'waiting',
  player1_id UUID REFERENCES public.profiles(id),
  player2_id UUID REFERENCES public.profiles(id),
  winner_id UUID REFERENCES public.profiles(id),
  current_player_index INT DEFAULT 0,
  turn_number INT DEFAULT 0,
  grid_rows INT DEFAULT 8,
  grid_cols INT DEFAULT 6,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '2 hours'
);

-- Indexes
CREATE INDEX idx_games_room_code ON public.games(room_code) WHERE status != 'completed';
CREATE INDEX idx_games_active ON public.games(player1_id, player2_id) WHERE status = 'active';
CREATE INDEX idx_games_waiting ON public.games(status) WHERE status = 'waiting';

-- Enable RLS
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Games are viewable by players or if waiting"
  ON public.games FOR SELECT
  USING (
    status = 'waiting' 
    OR auth.uid() = player1_id 
    OR auth.uid() = player2_id
  );

CREATE POLICY "Authenticated users can create games"
  ON public.games FOR INSERT
  WITH CHECK (auth.uid() = player1_id);

CREATE POLICY "Players can update their games"
  ON public.games FOR UPDATE
  USING (auth.uid() = player1_id OR auth.uid() = player2_id);

-- Auto-update timestamp trigger
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER games_updated_at
  BEFORE UPDATE ON public.games
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.games;
