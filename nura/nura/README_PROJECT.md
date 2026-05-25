# Nura — Project Summary & Quick Start

This repository is a Flutter app that provides daily Doa and prayer times. Below is a concise architecture summary, important files, and quick steps to run and verify local DB seeding.

## Architecture Overview
- UI: `lib/pages/`, `lib/widgets/` contain pages and reusable UI components.
- State: `lib/providers/prayer_provider.dart` — holds prayer times and Doa list state.
- Models: `lib/models/` — `doa_model.dart` describes Doa entries and mapping for SQLite.
- Services:
  - `lib/services/database_helper.dart` — SQLite wrapper using `sqflite`.
  - `lib/services/doa_service.dart` — loads `assets/doa.json` and seeds the DB on first run.
  - `lib/services/api_service.dart` — fetches prayer times from remote API.
- Assets: `assets/doa.json` — canonical source of Doa data.

## Key Files
- `lib/main.dart` — app entrypoint, sets up providers.
- `lib/pages/doa_page.dart` — Doa list UI and search.
- `lib/services/database_helper.dart` — DB initialization and queries.
- `lib/models/doa_model.dart` — Data model and JSON/Map converters.

## How DB seeding works
1. On app startup `PrayerProvider` calls `DoaService.seedDatabaseIfNeeded()`.
2. `DoaService` loads `assets/doa.json` via `rootBundle`.
3. If the `doa` table is empty, `DatabaseHelper.insertDoaList()` performs a batch insert.

## Run locally (emulator)
1. Ensure Flutter & emulator are available.
2. From project root:

```bash
flutter pub get
dart format .
flutter analyze
flutter run
```

## Verify seeding
- On first app launch the provider shows a loading indicator until seeding completes.
- `DoaPage` will display the number of stored Doa (`provider.allDoa.length`).

## Next recommended steps
- Add concise comments to remaining UI files under `lib/widgets/` and `lib/pages/` for consistency.
- Optionally add unit tests for `DatabaseHelper` (integration tests recommended for DB operations).

If you want, I can now:
- Add README as `README_PROJECT.md` (done), or move/rename it to `README.md`.
- Add comments to the rest of UI files now.
- Run the app via attached emulator (you need to start it locally).