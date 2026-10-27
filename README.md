# CricScore — Android Flutter starter

**Welcome to CricScore · Made by NK**

This is a starting Flutter project created for the existing Supabase project `CricScore-NK`.

## Features in this starter
- Email/password sign-in and sign-up through Supabase Auth
- Create teams and tournaments
- Host a public match
- Basic ball/run/wicket buttons and delivery history
- Supabase realtime streams for public matches and innings

## Important status note
This is an **MVP scaffold, not a production-ready scoring system**. It has not yet been built or tested on a physical Android device in this environment. Before real use, scoring should be moved into a transactional Postgres function to avoid inconsistent totals, access policies must be tested, and player selection, strike rotation, innings changes, score correction, tournament fixtures/standings, synchronized viewer celebrations, tests, and release signing still need work.

## Run
Install Flutter and Android SDK, then run from this folder. This source archive does not include generated Android platform files, so generate them once first:

```bash
flutter create --platforms=android .
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://nkuvapxhnarohyjrrtzs.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Use the Supabase **publishable** key only. Never put a `service_role` or secret key in the app.

## Existing database
The app targets existing `public` tables such as `profiles`, `teams`, `players`, `tournaments`, `matches`, `innings`, `deliveries`, and `scoring_events`. It does not create or replace the schema. If any request is denied, inspect that table's Row Level Security (RLS) policies in Supabase before changing permissions. Do not disable RLS to make the app work.

## Build APK
```bash
flutter create --platforms=android .  # only if the android/ folder is missing
flutter pub get
flutter build apk --release --dart-define=SUPABASE_URL=https://nkuvapxhnarohyjrrtzs.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`
