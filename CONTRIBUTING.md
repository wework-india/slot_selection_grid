# Contributing to slot_selection_grid

Thanks for your interest in contributing. This package is maintained by
WeWork India and released under the [MIT License](LICENSE).

## Getting started

```bash
git clone https://github.com/wework-india/slot_selection_grid.git
cd slot_selection_grid
flutter pub get

# Run the example app
cd example && flutter run
```

**Requirements:** Flutter `>=3.22.0`, Dart SDK `>=3.5.0 <4.0.0`.

## Before you open a pull request

Run all three locally — CI runs the same checks:

```bash
flutter analyze            # must report zero issues
flutter test               # all tests must pass
dart format --set-exit-if-changed .
```

If your change affects the published package surface, also run:

```bash
flutter pub publish --dry-run
```

## What makes a good pull request

- **One concern per PR.** Separate refactors from behavior changes.
- **Tests for behavior changes.** Widget tests live in `test/`; the example
  app has integration tests under `example/integration_test/`.
- **Dartdoc on new public API.** Every public class, constructor, field, and
  method needs a `///` comment. Current coverage is near 100% — please keep it
  there.
- **CHANGELOG entry.** Add your change under an `## Unreleased` heading at the
  top of [CHANGELOG.md](CHANGELOG.md), following
  [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) sections
  (`Added` / `Changed` / `Deprecated` / `Removed` / `Fixed` / `Security`).

## Design principles

These are deliberate and a PR that changes them needs discussion in an issue
first:

- **The widget is fully controlled.** `SlotSelectionGrid` never mutates
  `slotStates`. Callers own slot state and update it from the tap callbacks.
- **`SlotState` is a sealed hierarchy.** Adding a variant is a breaking change
  for every consumer with an exhaustive `switch`. Open an issue before doing it.
- **`SlotKey` equality is calendar-date-only.** Time-of-day on `date` is
  ignored by design.
- **Customization goes through builders and theme, not new boolean flags.**
  Prefer extending `SlotSelectionGridThemeData` / `SlotCellStyle` or a
  `build*Cell` builder over adding another constructor parameter.

## Commit and branch conventions

- Branch from `main`.
- Use [Conventional Commits](https://www.conventionalcommits.org/) prefixes:
  `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Mark breaking changes with `!` (e.g. `feat!: ...`) and explain the migration
  in the PR description.

## Versioning

This package follows [Semantic Versioning](https://semver.org/). Maintainers
handle version bumps and publishing — please don't change `version:` in
`pubspec.yaml` in your PR.

## Reporting bugs

Open an issue at
[github.com/wework-india/slot_selection_grid/issues](https://github.com/wework-india/slot_selection_grid/issues)
with your Flutter version (`flutter --version`), the platform, a minimal
reproduction, and what you expected instead.

For security issues, do **not** open a public issue — see
[SECURITY.md](SECURITY.md).
