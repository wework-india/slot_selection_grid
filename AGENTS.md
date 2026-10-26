# AGENTS.md

Guidance for AI coding agents working in this repository. Human contributors
should read [CONTRIBUTING.md](CONTRIBUTING.md) — this file covers the same
ground plus the context an agent can't infer from the tree.

## What this is

`slot_selection_grid` is a **pure Dart/Flutter widget package** published to
pub.dev. No platform channels, no native code, no network, no persistence, no
runtime dependencies beyond the Flutter SDK. If a change introduces any of
those, it is out of scope — stop and ask.

- Flutter `>=3.22.0`, Dart `>=3.5.0 <4.0.0`
- Lints: `flutter_lints: ^6.0.0` via `analysis_options.yaml`
- License: MIT, © WeWork India Management Limited

## Commands

```bash
flutter pub get
flutter analyze                      # must be zero issues
flutter test                         # widget tests in test/
dart format --set-exit-if-changed .
flutter pub publish --dry-run        # verify published file list

cd example && flutter run            # demo app
cd example && flutter test integration_test/
```

There is no build step. Do not run code generation — this package uses none.

## Layout

```
lib/
  slot_selection_grid.dart           # the ONLY public export barrel
  src/
    models/
      slot_key.dart                  # SlotKey — grid cell identity
      slot_state.dart                # sealed SlotState hierarchy
      time_slot.dart                 # TimeSlot, SlotData
      minimap_configuration.dart     # MinimapConfiguration
    theme/
      slot_selection_grid_theme.dart # SlotSelectionGridThemeData, SlotCellStyle
    widgets/
      slot_cell.dart                 # SlotCell — single cell, usable standalone
      slot_selection_grid.dart       # SlotSelectionGrid — main widget
example/                             # demo app, not published
screenshots/                         # README media; GIFs excluded via .pubignore
```

Everything under `lib/src/` is implementation. Anything intended for consumers
must be exported from `lib/slot_selection_grid.dart` — adding a file there
without an export means it isn't actually public.

## Invariants — do not break these without an explicit instruction

1. **`SlotSelectionGrid` is fully controlled.** It never mutates `slotStates`.
   Callers own state and update it from `onSlotTapped` /
   `onUnavailableSlotTapped`. Do not add internal selection state.
2. **`SlotState` is `sealed`.** Consumers write exhaustive `switch` statements
   over it. Adding a variant is a breaking change requiring a major/minor bump
   and a CHANGELOG `Changed` entry flagged as breaking.
3. **`SlotKey` equality compares calendar date only** (year/month/day), ignoring
   time-of-day on `DateTime`. This is intentional. `hashCode` must stay
   consistent with it.
4. **`SlotCell.onTap` fires for every state**, including `UnavailableSlotState`.
   Callers pass `onTap: null` to disable. Do not reintroduce state-based tap
   suppression inside the widget.
5. **Time formatting is locale-aware.** Use
   `TimeSlot.formatStartTime(context)` / `formatEndTime(context)` /
   `formatTimeRange(context)`. Never format `TimeOfDay` by string-concatenating
   hour and minute.
6. **`TimeSlot.duration` wraps past midnight** when `endTime` precedes
   `startTime`. Preserve that.
7. **Scroll synchronization** between the date header, time column, and canvas
   is hand-wired with `ScrollController` listeners in
   `lib/src/widgets/slot_selection_grid.dart`. It is re-entrant-sensitive —
   changes there need a manual scroll test in the example app, not just unit
   tests.

## Conventions

- **Every public API member needs a `///` dartdoc comment.** Coverage is near
  100%; keep it there. Reference other symbols with square brackets
  (`[SlotSelectionGrid.slotStates]`).
- **Prefer builders and theme over new parameters.** New customization should
  extend `SlotSelectionGridThemeData` / `SlotCellStyle` or go through an
  existing `build*Cell` callback before adding another constructor flag.
- **Const constructors** wherever possible; this widget rebuilds on scroll.
- Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`,
  `chore:`), with `!` for breaking changes.

## Do not touch

- `build/`, `.dart_tool/`, `example/build/` — untracked artifacts
- `pubspec.lock` — gitignored; this is a library, not an app
- `version:` in `pubspec.yaml` — maintainers handle version bumps
- `.pubignore` — it **replaces** the root `.gitignore` at publish time, so it
  must repeat every root gitignore rule. Edit only if you understand that; verify
  with `flutter pub publish --dry-run` and read the printed file list.
- `LICENSE` — legal text, changes need sign-off

## Changing published behavior

Any change to the public API or observable behavior requires:

1. A `## Unreleased` entry in [CHANGELOG.md](CHANGELOG.md) under the right
   Keep a Changelog section
2. Dartdoc updated on affected members
3. README updated if the change touches a documented example or the API table
4. A test covering the new behavior

## Scope boundaries

Stop and ask a human before:

- Adding any runtime dependency
- Adding platform-specific code or plugin scaffolding
- Changing the `SlotState` hierarchy
- Changing scroll synchronization architecture
- Editing `LICENSE`, `SECURITY.md`, or publishing configuration
