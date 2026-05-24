# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run                        # Run on connected device/emulator
flutter run -d chrome              # Run as web app
flutter build apk                  # Build Android APK
flutter test                       # Run all tests
flutter test test/path/to/test.dart  # Run a single test file
flutter analyze                    # Lint (uses flutter_lints)
flutter pub get                    # Install dependencies
```

## Architecture

**Last Word** is a Persian word-chain timer game. Players must type a word beginning with the last letter of the previous word, against a shrinking countdown.

### State Management: flutter_bloc (Cubit pattern)

Each screen owns its Cubit, instantiated in `BlocProvider` at the screen root:

- `HomeCubit` — loads high score from `IStorageService` on mount.
- `GameCubit` — central game logic: starts a random seed word, validates submissions against `IDictionaryService`, drives a `Timer.periodic` countdown, and emits `gameOver` when time expires. On game over it persists the score via `IStorageService` and sets `isNewRecord`.
- `ResultCubit` — loads high score for display after a game.

Screens use `BlocSelector` (not `BlocBuilder`) to rebuild only on specific field changes — keep this pattern to avoid unnecessary rebuilds.

### Navigation: go_router

Routes are defined in `lib/app/router/app_router.dart`:
- `/` → `HomeScreen`
- `/game` → `GameScreen`
- `/result` → `ResultScreen` (receives `score`, `words`, `isNewRecord` via `state.extra`)

Navigate with `context.go(AppRouter.game)` — never use `Navigator` directly.

### Core Services (interface + implementation)

| Interface | Implementation | Purpose |
|---|---|---|
| `IDictionaryService` | `PersianDictionaryService` | Loads `assets/words_fa.txt` into a `Set<String>` at startup; `isValidWord` is O(1) |
| `IStorageService` | `StorageService` | Persists high score via `shared_preferences` |

The dictionary is initialized once in `main()` and passed into `LastWordApp` — do not reload it per-screen.

### Game Mechanics (AppConstants)

- Initial timer: **15 s**; shrinks by **0.2 s** per accepted word; floor at **1.5 s**
- Timer ticks every **100 ms**; progress bar uses `timeLeft / maxTime`
- Persian ZWNJ (`U+200C`) is stripped before extracting the last letter of a word
- Seed words are hardcoded in `AppConstants.seedWords` (all lowercase Persian)

### Folder Structure

```
lib/
  main.dart                  # Bootstrap: init dictionary, run app
  app/
    app.dart                 # MaterialApp.router, theme config
    router/app_router.dart   # GoRouter route table
  core/
    constants/app_constants.dart
    services/dictionary_service.dart
    services/storage_service.dart
    theme/app_theme.dart     # Material 3, seed color 0xFF534AB7, light+dark
  features/
    home/   cubit/ + presentation/
    game/   cubit/ + presentation/widgets/
    result/ cubit/ + presentation/
assets/
  words_fa.txt               # Persian word list (one word per line)
```

### Theme

`AppTheme` uses Material 3 with `ColorScheme.fromSeed(seedColor: Color(0xFF534AB7))`. Always use `theme.colorScheme` tokens — no hardcoded colors except the amber used in the new-record badge.
