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

- `main.dart` — app entry point; calls `Hive.initFlutter()` before `runApp`. `MainNavigationScreen` is a single `StatefulWidget` holding all five feature screens in an `IndexedStack`, switched via `BottomNavigationBar`, plus two floating buttons (life coach, feedback). There is no router and no external state-management package (no Provider/Riverpod/Bloc) — each feature screen manages its own local state.
- `core/config/ai_config.dart` — holds the Gemini model name only. There is no API key in the app (see "API keys" below).
- `core/services/gemini_service.dart` — Gemini calls for the general features go through `GeminiService`. Each AI-powered feature (exercise-image analysis, recipe suggestions, voice-note-to-tasks parsing, medication-label analysis, budget advice) is implemented as one method on this class that builds an Arabic prompt and calls `askAssistant()` or `analyzeImage()`. New AI features should follow this same one-method-per-capability pattern rather than introducing a new service (the life coach is the one deliberate exception, see below).
  - `GeminiService.create()` is the only constructor. It reads the user's key from `DatabaseService`; if none is saved, no model is created and `hasKey` is false (`askAssistant`/`analyzeImage` then return `missingKeyMessage` instead of calling the API).
  - Screens get a service at the moment of use via `requireGeminiService(context)` in `core/widgets/ai_key_setup_screen.dart`, which shows the key setup screen when there is no key and returns null if the user leaves without saving one.
  - `resetModel(newKey)` persists a user-entered key via `DatabaseService` and re-initializes the model — this is how a user activates AI features; preserve this capability when refactoring.
- `features/coach/` — the life coach ("مدرب يسأل"): a local question bank (`assets/coach_questions.json`), sessions stored in an encrypted Hive box (`coach_sessions`, see `encrypted_boxes.dart` below), and `CoachAiService` for optional AI follow-up questions. `CoachAiService` builds its own `GenerativeModel` instead of using `GeminiService` because it needs a real `systemInstruction` and must see API errors (`askAssistant` returns error text as a normal reply). Safety rules: `containsCrisisSignals()` runs before anything is sent to the model; a model reply containing `CRISIS_DETECTED` routes to the helpline dialog; replies with advice language (`containsAdviceLanguage()`) are replaced by a bank question. The coach's opening domain is a weighted random pick (`CoachSessionService.pickDomain`) boosted by `CoachSignalService`, which reads only on-device data (recent unplanned expenses, a topic repeated in the last two coach answers, more than two hours of social-app use today).
- `core/services/database_service.dart` — thin wrapper around `SharedPreferences` (the coach's session log and the expense log live in Hive instead), used as a simple key/value store (not a real database). Each domain (`daily_tasks`, `medications`, `pantry`, `gemini_api_key`) is a single JSON-encoded string under its own key, with hardcoded Arabic default seed data returned when the key is absent. Follow this same get/save-as-JSON-string pattern for new persisted domains.
- `core/services/encrypted_boxes.dart` — `EncryptedBoxes.open(name)` opens the sensitive Hive boxes (`coach_sessions`, `expenses`) encrypted with AES-256. The random key is generated once and kept in `flutter_secure_storage` (Android Keystore), never next to the data. The encrypted file is `<name>_enc.hive`; a leftover plain `<name>.hive` is copied into it and then deleted. Never open a plain box with a cipher: Hive treats it as corrupt and silently truncates it. Tests that open these boxes need `FlutterSecureStorage.setMockInitialValues({})` and `EncryptedBoxes.resetForTesting()` in `setUp`.
- `features/budget/` — manual expense tracking: `BudgetService` stores entries in an encrypted Hive box (`expenses`); `BudgetSummaryScreen` (opened from the budget tab's app bar) shows the monthly total and a per-category `fl_chart` column chart. **Manual entry only, no exceptions:** never add bank linking, card numbers, Open Banking, or any external financial API.
- `features/awareness/` — "وعي الاستخدام" (Android only): today's minutes in five social apps via the system Usage Access permission (`PACKAGE_USAGE_STATS`, which the user enables manually in Settings), through the `usage_stats` package. Minutes are computed from raw `queryEvents` since local midnight (`foregroundTimeByPackage`), not `queryAndAggregateUsageStats`, whose daily buckets don't start at midnight. Only one number per app is stored (Hive box `app_usage`, today's snapshot only). **Never add** account logins, embedded social browsers, notification/message reading, `QUERY_ALL_PACKAGES`, or any upload of this data; the five package names are listed in both `models/social_app.dart` and the manifest's `<queries>`. `usage_stats` is pinned to 1.x because 2.x needs Flutter ≥ 3.44; 1.3.1's Gradle file uses `jcenter()`, which breaks on Gradle 9.
- `core/services/subscription_service.dart` — Google Play Billing (`in_app_purchase`), one auto-renewing product `eman_coach_monthly`. The **only** paid feature is the coach's AI follow-up ("عمّق أكثر", gated in `CoachScreen` via `CoachPaywallScreen`); everything else stays free. Status is cached in a Hive box (`subscription`) and trusted offline for `offlineGrace` (3 days); Google Play's `restorePurchases()` result is the source of truth, and purchases must be acknowledged (`completePurchase`) or Play refunds them after 3 days. Verification is client-side only (no server). Billing is Android-only; elsewhere `canPurchase` is false.
- `core/services/notification_service.dart` — static wrapper around `flutter_local_notifications`; all calls are wrapped in try/catch that silently swallow errors by design (fire-and-forget reminders).
- `features/<feature>/` — one screen per bottom-nav tab (`goals_and_tasks`, `health_and_fitness`, `kitchen_and_home`, `financial`, `ai_assistant`). Screens talk directly to `GeminiService`/`DatabaseService`; there is no repository/domain layer in between.
- All user-facing strings and prompts sent to Gemini are in Arabic; identifiers (files, classes, variables) are in English using standard Dart naming (snake_case files, camelCase members). Keep this split when adding code.

### Vanilla JS PWA (root `app.js` / `web_app/app.js`)

- Single `app.js` file, no modules/bundler. All app state lives in one in-memory `appData` object, persisted as a single JSON blob to `localStorage` (`STORAGE_KEY`) via `loadAppData()` / `saveAppData()`.
- `switchTab()` / `setSubTab()` / `renderCurrentView()` drive a manual view-router that re-renders a section into `#view-container` — there is no virtual DOM or templating library, views are built via string concatenation / direct DOM manipulation.
- Each domain (goals, weekly tasks, categorized tasks, workouts, medications, beauty, recipes, pantry) follows the same CRUD shape: `openAdd*Modal()` → `save*()` → `toggle*()/delete*()`, each ending in `saveAppData()` then a re-render. Follow this shape for new domains instead of introducing new state patterns.
- `sanitize()` is used to escape user input before it's injected into the DOM — always route untrusted strings through it when adding new render code, since this file does not use a templating engine that escapes by default.

## API keys — no central key, by design

There is no central or fallback API key anywhere in the app. Every user activates AI features with their own free Gemini key, stored only on their device via `DatabaseService`. Do not add a shared key in any form — hardcoded, a bundled `.env` asset, or any other file shipped in the build — because anything bundled in a mobile or web app can be extracted. The old hardcoded key in the initial commit's git history must be treated as compromised.

## Android release

- `applicationId` is `com.lifeapp.eman_life_app` and cannot change after the first Google Play upload. Bump the `+build` number in `version:` (pubspec) for every upload.
- Signing: `android/app/build.gradle.kts` reads `android/key.properties` (gitignored), which points to the upload keystore kept **outside the repo** (`%USERPROFILE%\keystores\eman-release-key.jks`, alias `eman`). Without `key.properties`, release builds fall back to debug signing so `flutter run --release` still works; Google Play rejects debug-signed bundles.
- Permissions: the manifest declares only `INTERNET` (Gemini, billing) and `PACKAGE_USAGE_STATS` (usage awareness); plugins add `POST_NOTIFICATIONS` and `VIBRATE` (flutter_local_notifications) and `com.android.vending.BILLING` (Play Billing). Do not add `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` or `RECORD_AUDIO`: `image_picker` works without them, and `READ_MEDIA_IMAGES` triggers Play's photo/video declaration.
- Backup: `res/xml/backup_rules.xml` (Android 6–11) and `data_extraction_rules.xml` (12+) exclude the encrypted Hive files and flutter_secure_storage's prefs (`FlutterSecureStorage.xml`, `FlutterSecureKeyStorage.xml`) from Auto Backup and device transfer, because the Keystore key can't be restored on a new phone. Add any new encrypted box to both files.
- Launcher icons are generated from `eman_logo.png` by `flutter_launcher_icons` (config in `pubspec.yaml`): run `dart run flutter_launcher_icons` instead of editing the `mipmap-*`/`drawable-*` icons by hand. The app's on-device name is `android:label="إيمان"`, which the usage-awareness steps also reference.

## Files not to modify without explicit confirmation

- `pubspec.lock` — regenerate via `flutter pub get`, don't hand-edit.
- Any `.env` file, if/when one is introduced — never print its contents in a response or commit.
- `android/key.properties` and the upload keystore — never print, commit, move into the repo, or regenerate them (after the first upload, a new upload key needs a reset request in Play Console).
- `resetModel()` in `gemini_service.dart` — this is how a user saves their own API key; preserve it as public API when refactoring `GeminiService`.

## Business context

- Single-app target audience: one user/family wanting an all-in-one life assistant (finance + health + tasks + kitchen).
- Launch plan is Google Play only for now (no Mac available for an iOS build, so iOS is deferred). Play Store registration would be as an individual developer, no registered company.
