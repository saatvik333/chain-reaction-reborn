# Supabase Setup Guide

This guide explains how to set up the Supabase backend for Chain Reaction online multiplayer.

## Prerequisites

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Supabase CLI is available via: `bunx supabase --help`

## Database Setup

Run the migrations in order from the Supabase SQL Editor:

1. `supabase/migrations/001_create_profiles.sql`
2. `supabase/migrations/002_create_games.sql`
3. `supabase/migrations/003_create_game_moves.sql`
4. `supabase/migrations/004_realtime_rls.sql`

Or use the CLI:
```bash
supabase db push
```

## Auth Configuration

### Email/Password
1. Go to **Authentication > Providers**
2. Enable **Email** provider
3. Disable **Confirm email** for development (enable in production)

### Google OAuth
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth 2.0 credentials (Web application)
3. Add redirect URI: `https://<project-ref>.supabase.co/auth/v1/callback`
4. In Supabase: **Authentication > Providers > Google**
5. Add Client ID and Client Secret

## Edge Functions Deployment

> **Note**: IDE may show TypeScript errors for Deno imports (`Cannot find name 'Deno'`).
> These are expected - Edge Functions run in Deno runtime, not Node.js.
> They will work correctly when deployed to Supabase.

```bash
cd supabase

# Login to Supabase
bunx supabase login

# Link to your project
bunx supabase link --project-ref <your-project-ref>

# Deploy functions
bunx supabase functions deploy create_game
bunx supabase functions deploy join_game
bunx supabase functions deploy submit_move
```

## Environment Variables

Add these to your Flutter app (via `--dart-define` or `.env`):

```
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
```

Find these values in **Settings > API**.

## Realtime Configuration

1. Go to **Database > Replication**
2. Ensure `games` table has Realtime enabled (should be automatic from migration)

## Testing

Test the Edge Functions via curl:

```bash
# Create game (requires valid JWT)
curl -X POST https://<project-ref>.supabase.co/functions/v1/create_game \
  -H "Authorization: Bearer <jwt>" \
  -H "Content-Type: application/json"

# Join game
curl -X POST https://<project-ref>.supabase.co/functions/v1/join_game \
  -H "Authorization: Bearer <jwt>" \
  -H "Content-Type: application/json" \
  -d '{"roomCode": "ABC1"}'
```
