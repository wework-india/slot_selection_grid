# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.2.0 - 2026-10-26

First public release.

### Added

- `SlotSelectionGrid` — a scrollable grid for selecting time slots across
  multiple dates, with synchronized horizontal and vertical scrolling between
  the date header, time column, and slot canvas.
- `TimeSlot`, `SlotKey`, `SlotData`, and a sealed `SlotState` hierarchy
  (`UnselectedSlotState`, `SelectedSlotState`, `UnavailableSlotState`) for
  modelling slot availability. `UnavailableSlotState` carries a `reason`
  string for surfacing why a slot can't be booked.
- `SlotCell` as a standalone, independently usable cell widget.
- `SlotSelectionGridThemeData` and `SlotCellStyle` for theming default cell
  colors and icons without supplying custom builders.
- Per-state custom cell builders: `buildSelectedSlotCell`,
  `buildUnselectedSlotCell`, `buildUnavailableSlotCell`, and
  `buildOriginSlotCell`.
- Header and label customization via `dateHeaderBuilder`, `slotTitleBuilder`,
  `titleBuilder`, and `dateFormatter`.
- Loading skeleton state, configurable through `loading`,
  `loadingSkeletonDayCount`, `loadingPlaceholderTimeSlots`, and
  `loadingUnavailableReason`.
- Scroll minimap overlay, configurable through `MinimapConfiguration`
  (position, size, colors, fade timing, or disabled entirely).
- `timeColumnWidth` to widen the time-label column independently of grid
  `cellSize`, so time ranges aren't cramped.
- Localized time formatting via `TimeSlot.formatStartTime(context)`,
  `formatEndTime(context)`, and `formatTimeRange(context)`, which respect the
  ambient locale and 12/24-hour setting.
- Support for Android, iOS, web, macOS, Windows, and Linux.

### Notes

- Slot state is not managed internally. The widget is fully controlled: supply
  `slotStates` and update it in response to `onSlotTapped` and
  `onUnavailableSlotTapped`.
- `SlotCell` invokes `onTap` for every state, including
  `UnavailableSlotState`. Pass `onTap: null` to disable taps on a cell.
- `SlotKey` equality compares the calendar date only, ignoring any time
  component on the `DateTime`.
- `TimeSlot.duration` handles an end time earlier than its start time by
  wrapping past midnight.