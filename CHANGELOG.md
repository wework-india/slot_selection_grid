## 0.1.0

- Added optional **`timeColumnWidth`** so the time-label column can be wider than grid **`cellSize`** (fixes cramped range text).
- Initial pub-oriented release: `SlotPicker`, models, and `SlotCell` as a **plain Flutter package** (removed unused plugin / method-channel scaffold).
- Added `SlotPickerThemeData` / `SlotCellStyle` for default cell colors and icons.
- **Breaking:** `TimeSlot.formattedStartTime` / `formattedEndTime` / `formattedTimeRange` replaced with `formatStartTime(context)`, `formatEndTime(context)`, and `formatTimeRange(context)` for proper localization.
- **Breaking:** Removed `SlotSelectionGrid` and platform channel APIs.
- `DateAndTimeSlot` equality now uses calendar date only (ignores time on `DateTime`).
- Fixed slot state map lookup to use key equality instead of `hashCode`.
- Fixed loading skeleton using the wrong custom cell builder for unselected cells.
- Configurable loading skeleton: `loadingSkeletonDayCount`, `loadingPlaceholderTimeSlots`, `loadingUnavailableReason`.
- `TimeSlot.duration` handles end time before start time (wrap past midnight).

## 0.0.1

- Pre-release internal version (plugin template).
