-- Migration: 003_create_game_moves
-- Creates the game_moves audit log table

CREATE TABLE public.game_moves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES public.profiles(id),
  move_number INT NOT NULL,
  x INT NOT NULL,
  y INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_game_moves_game ON public.game_moves(game_id, move_number);

-- Enable RLS
ALTER TABLE public.game_moves ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Game moves are viewable by players"
  ON public.game_moves FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.games g 
      WHERE g.id = game_id 
      AND (auth.uid() = g.player1_id OR auth.uid() = g.player2_id)
    )
  );

CREATE POLICY "Players can insert moves for their games"
  ON public.game_moves FOR INSERT
  WITH CHECK (
    auth.uid() = player_id
    AND EXISTS (
      SELECT 1 FROM public.games g 
      WHERE g.id = game_id 
      AND g.status = 'active'
      AND (auth.uid() = g.player1_id OR auth.uid() = g.player2_id)
    )
  );

-- No UPDATE or DELETE allowed on moves (immutable audit log)
