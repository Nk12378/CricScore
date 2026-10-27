# Supabase integration notes

Project URL: `https://nkuvapxhnarohyjrrtzs.supabase.co`

The app expects a publishable/legacy anon key supplied at build time with `--dart-define=SUPABASE_ANON_KEY=...`. Never put the service-role key in a client app.

The existing schema has tables for profiles, teams, players, tournaments, tournament_teams, matches, match_members, innings, deliveries, scoring_events, notifications and user_backups. This starter does not apply SQL migrations or overwrite the existing schema.

Before release, verify:
- RLS policies permit only signed-in owners to create/edit their teams and tournaments.
- Only the host or authorized scorer can insert deliveries or update innings.
- Public viewers can read public match score data without being able to write.
- Realtime publication includes the required tables.
- Scoring is atomic and consistent under multiple clients.
