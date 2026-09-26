# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

This repo contains **two independent implementations of the same app** ("إيمان" / eman — a personal life/home assistant: tasks, health, kitchen/pantry, finance, and a Gemini-powered AI assistant). They are not related by build tooling and must be edited separately:

1. **Flutter app** (`lib/`, `pubspec.yaml`) — the primary app, targets Android/iOS/Web/Windows/Linux/macOS.
2. **Vanilla JS PWA** (`app.js`, `index.html`, `styles.css` at repo root) — a static, no-build, single-file-per-type web app served directly (e.g. via GitHub Pages). `web_app/app.js`, `web_app/index.html`, `web_app/styles.css` are byte-identical duplicates of the root versions; keep both copies in sync when editing one.

There is also `agent_engine/` — only compiled `__pycache__/*.pyc` artifacts are present, no source `.py` files exist in the repo currently.

## Commands

Flutter app:
```
flutter pub get              # install dependencies
flutter run                  # run on a connected device/emulator
flutter run -d chrome        # run the web build
flutter run -d windows       # run the Windows desktop build
flutter build apk            # build Android APK
flutter build web            # build web (outputs to build/web)
flutter analyze              # static analysis (flutter_lints)
flutter test                 # run all tests
flutter test test/widget_test.dart   # run a single test file
```

Vanilla JS PWA: no build step. Open `index.html` directly or serve the repo root with any static file server.

## Architecture

### Flutter app (`lib/`)

- `main.dart` — app entry point. `MainNavigationScreen` is a single `StatefulWidget` holding all five feature screens in an `IndexedStack`, switched via `BottomNavigationBar`. There is no router and no external state-management package (no Provider/Riverpod/Bloc) — each feature screen manages its own local state.
- `core/config/ai_config.dart` — holds the Gemini model name and a **hardcoded fallback API key**. See "Known security issue" below before touching this file.
- `core/services/gemini_service.dart` — all Gemini calls go through `GeminiService`. Each AI-powered feature (exercise-image analysis, recipe suggestions, voice-note-to-tasks parsing, medication-label analysis, budget advice) is implemented as one method on this class that builds an Arabic prompt and calls `askAssistant()` or `analyzeImage()`. New AI features should follow this same one-method-per-capability pattern rather than introducing a new service.
  - `GeminiService.create()` is the preferred async constructor: it checks `DatabaseService` for a user-supplied API key and falls back to `AIConfig.apiKey` only if none is set. The plain `GeminiService()` sync constructor always uses the hardcoded fallback key — most feature screens still use this sync form (see `financial_screen.dart`, `goals_tasks_screen.dart`, `health_fitness_screen.dart`, `kitchen_home_screen.dart`); only `ai_assistant_screen.dart` uses the async `create()` path with a fully user-controlled key.
  - `resetModel(newKey)` persists a user-entered key via `DatabaseService` and re-initializes the model — this is the only way to let a user override the fallback key at runtime; preserve this capability when refactoring.
- `core/services/database_service.dart` — thin wrapper around `SharedPreferences`, used as a simple key/value store (not a real database). Each domain (`daily_tasks`, `medications`, `pantry`, `gemini_api_key`) is a single JSON-encoded string under its own key, with hardcoded Arabic default seed data returned when the key is absent. Follow this same get/save-as-JSON-string pattern for new persisted domains.
- `core/services/notification_service.dart` — static wrapper around `flutter_local_notifications`; all calls are wrapped in try/catch that silently swallow errors by design (fire-and-forget reminders).
- `features/<feature>/` — one screen per bottom-nav tab (`goals_and_tasks`, `health_and_fitness`, `kitchen_and_home`, `financial`, `ai_assistant`). Screens talk directly to `GeminiService`/`DatabaseService`; there is no repository/domain layer in between.
- All user-facing strings and prompts sent to Gemini are in Arabic; identifiers (files, classes, variables) are in English using standard Dart naming (snake_case files, camelCase members). Keep this split when adding code.

### Vanilla JS PWA (root `app.js` / `web_app/app.js`)

- Single `app.js` file, no modules/bundler. All app state lives in one in-memory `appData` object, persisted as a single JSON blob to `localStorage` (`STORAGE_KEY`) via `loadAppData()` / `saveAppData()`.
- `switchTab()` / `setSubTab()` / `renderCurrentView()` drive a manual view-router that re-renders a section into `#view-container` — there is no virtual DOM or templating library, views are built via string concatenation / direct DOM manipulation.
- Each domain (goals, weekly tasks, categorized tasks, workouts, medications, beauty, recipes, pantry) follows the same CRUD shape: `openAdd*Modal()` → `save*()` → `toggle*()/delete*()`, each ending in `saveAppData()` then a re-render. Follow this shape for new domains instead of introducing new state patterns.
- `sanitize()` is used to escape user input before it's injected into the DOM — always route untrusted strings through it when adding new render code, since this file does not use a templating engine that escapes by default.

## Known security issue (high priority)

`lib/core/config/ai_config.dart` contains a **live Gemini API key hardcoded in source** (`AIConfig.apiKey`), used as the fallback key by both the sync `GeminiService()` constructor and `GeminiService.create()`. This key is present in git history. Do not add new hardcoded secrets anywhere in this repo, and prefer routing new AI calls through the user-key path (`GeminiService.create()` / `resetModel()`) rather than the static fallback.

## Files not to modify without explicit confirmation

- `pubspec.lock` — regenerate via `flutter pub get`, don't hand-edit.
- Any `.env` file, if/when one is introduced — never print its contents in a response or commit.
- `resetModel()` in `gemini_service.dart` — this is the user's only path to override the hardcoded API key with their own; preserve it as public API when refactoring `GeminiService`.

## Business context

- Single-app target audience: one user/family wanting an all-in-one life assistant (finance + health + tasks + kitchen).
- Launch plan is Google Play only for now (no Mac available for an iOS build, so iOS is deferred). Play Store registration would be as an individual developer, no registered company.
