-- Migration: 004_realtime_rls
-- Required RLS policy for Realtime subscriptions

-- Note: This policy allows authenticated users to receive realtime updates
-- The actual data filtering is done by the games table RLS policies
CREATE POLICY "Authenticated users can listen to game updates"
  ON "realtime"."messages"
  FOR SELECT
  TO authenticated
  USING (true);
