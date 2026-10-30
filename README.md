# slot_selection_grid

[pub.dev](https://pub.dev/packages/slot_selection_grid)
[Flutter](https://flutter.dev)
[License: MIT](LICENSE)

A Flutter widget for multi-day time-slot selection.

![Slot Selection Grid](https://raw.githubusercontent.com/wework-india/slot_selection_grid/v0.2.0/screenshots/demo.gif)

Perfect for:

- Meeting room booking
- Workspace reservations
- Studio scheduling
- Sports facility booking
- Appointment scheduling

---

## Feature Highlights

### Scroll Minimap

Quickly understand your position in large scheduling grids with the built-in minimap overlay.

![Minimap](https://raw.githubusercontent.com/wework-india/slot_selection_grid/v0.2.0/screenshots/minimap.gif)

### Skeleton Loading

Display realistic placeholders while availability data is loading.

![Skeleton Loading](https://raw.githubusercontent.com/wework-india/slot_selection_grid/v0.2.0/screenshots/skeleton.gif)

### Fully Customizable Cells

Customize the appearance of selected, unselected, and unavailable slots.

![Custom Cells](https://raw.githubusercontent.com/wework-india/slot_selection_grid/v0.2.0/screenshots/customise.gif)

---

## Why slot_selection_grid?

Building booking and scheduling interfaces in Flutter often requires:

- Synchronizing horizontal and vertical scrolling
- Sticky date headers
- Time labels
- Slot state management
- Skeleton loading states

slot_selection_grid provides these out of the box while remaining highly customizable.

---

## Features

- **Multi-day columns** with synchronized horizontal & vertical scroll (header + time-label column stay locked).
- **Three slot states**: `selected`, `unselected`, `unavailable` (with reason string).
- **Skeleton loading** — show a placeholder grid while data is in-flight.
- **Scroll minimap** — a floating dot-grid thumbnail that appears during pan and fades out automatically.
- **Momentum scrolling** — physics-based deceleration on pan release.
- **Edge-scroll shadows** — animated inner shadows hint at overflowing content.
- **Default Material styling** via `SlotSelectionGridThemeData` *or* fully custom cell builders per state.

---

## Platform Support

| Android | iOS | Web | macOS | Windows | Linux |
|----------|-----|-----|--------|---------|--------|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Installation

```yaml
dependencies:
  slot_selection_grid: ^0.2.1
```

```bash
flutter pub get
```

```dart
import 'package:slot_selection_grid/slot_selection_grid.dart';
```

---

## Getting Started

```dart
SlotSelectionGrid(
  dates: myWeek,           // List<DateTime>
  timeSlots: mySlots,      // List<TimeSlot>
  slotStates: stateBySlot, // Map<SlotKey, SlotState>
  onSlotTapped: (slot, newState) {
    setState(() => stateBySlot[slot] = newState);
  },
  onUnavailableSlotTapped: (slot, reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(reason)),
    );
  },
  dateHeaderBuilder: (context, date, isLoading) =>
      Text(MaterialLocalizations.of(context).formatShortDate(date)),
  slotTitleBuilder: (context, slot, isLoading) =>
      Text(slot.formatTimeRange(context)),
);
```

> **Tip:** Set `timeColumnWidth` wider than `cellSize` so time-range labels have room to render.

---

## State Management

SlotSelectionGrid is a controlled widget.

The widget does not manage slot state internally.

Consumers are responsible for updating slotStates in response to callbacks.

This makes it easy to integrate with:

- setState

- Bloc

- Riverpod

- Provider

---

## API Reference

At a minimum, SlotSelectionGrid requires:

- dates

- timeSlots

- slotStates

Everything else is optional and allows customization of layout, rendering, loading states, and minimap behavior.

### `SlotSelectionGrid`

#### Required parameters


| Parameter    | Type                              | Description                                                             |
| ------------ | --------------------------------- | ----------------------------------------------------------------------- |
| `dates`      | `List<DateTime>`                  | Ordered list of calendar days to display as columns.                    |
| `timeSlots`  | `List<TimeSlot>`                  | Ordered list of time ranges to display as rows.                         |
| `slotStates` | `Map<SlotKey, SlotState>` | State for every cell; missing keys default to `SlotState.unselected()`. |


#### Callbacks


| Parameter                 | Signature                                                  | Description                                                                   |
| ------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `onSlotTapped`            | `void Function(SlotKey slot, SlotState newState)?` | Fires when an available slot is tapped; receives the toggled state.           |
| `onUnavailableSlotTapped` | `void Function(SlotKey slot, String reason)?`      | Fires when an unavailable slot is tapped; receives the unavailability reason. |


#### Layout


| Parameter         | Type      | Default    | Description                                                                                  |
| ----------------- | --------- | ---------- | -------------------------------------------------------------------------------------------- |
| `cellSize`        | `double`  | `50.0`     | Width **and** height (in logical pixels) of every grid cell.                                 |
| `timeColumnWidth` | `double?` | `cellSize` | Width of the left time-label column. Set wider than `cellSize` for readable time-range text. |
| `showTimeLabels`  | `bool`    | `true`     | Whether the time-label column is rendered.                                                   |


#### Builders


| Parameter                  | Signature                                                       | Description                                                                               |
| -------------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `dateHeaderBuilder`        | `Widget Function(BuildContext, DateTime date, bool isLoading)?` | Custom widget for each date column header. Omit to hide headers.                          |
| `slotTitleBuilder`         | `Widget Function(BuildContext, TimeSlot slot, bool isLoading)?` | Custom widget for each row in the time-label column.                                      |
| `buildSelectedSlotCell`    | `Widget Function(SlotKey, bool isLoading)?`             | Fully custom cell for selected slots. Falls back to default `SlotCell` when null.         |
| `buildUnselectedSlotCell`  | `Widget Function(SlotKey, bool isLoading)?`             | Fully custom cell for unselected slots.                                                   |
| `buildUnavailableSlotCell` | `Widget Function(SlotKey, bool isLoading)?`             | Fully custom cell for unavailable slots.                                                  |
| `buildOriginSlotCell`      | `Widget Function(BuildContext)?`                                | Widget placed in the top-left origin cell (intersection of time column and header row).   |
| `titleBuilder`             | `Widget Function(BuildContext)?`                                | Widget rendered above the date headers inside the sticky header card.                     |
| `dateFormatter`            | `String Function(DateTime)?`                                    | Converts a `DateTime` to a display string (used when no `dateHeaderBuilder` is provided). |


#### Appearance


| Parameter          | Type                   | Default                 | Description                                                 |
| ------------------ | ---------------------- | ----------------------- | ----------------------------------------------------------- |
| `theme`            | `SlotSelectionGridThemeData?` | `SlotSelectionGridThemeData()` | Colors and icon sizes for the default `SlotCell` rendering. |
| `headerColor`      | `Color?`               | Material card default   | Background color of the sticky date-header card.            |
| `innerShadowColor` | `Color?`               | `Colors.black @ 15%`    | Color of the animated edge-scroll shadows.                  |


#### Loading / skeleton


| Parameter                     | Type              | Default | Description                                                                                      |
| ----------------------------- | ----------------- | ------- | ------------------------------------------------------------------------------------------------ |
| `loading`                     | `bool`            | `false` | When `true` **and** both `dates` and `timeSlots` are empty, renders a skeleton placeholder grid. |
| `loadingSkeletonDayCount`     | `int`             | `12`    | Number of placeholder day columns in the skeleton grid.                                          |
| `loadingPlaceholderTimeSlots` | `List<TimeSlot>?` | `null`  | Custom time rows for the skeleton. Defaults to 08:00–20:00 in 30-minute steps.                   |
| `loadingUnavailableReason`    | `String`          | `''`    | Reason string passed to each placeholder unavailable cell.                                       |


#### Minimap


| Parameter              | Type                   | Default                  | Description                                                                                              |
| ---------------------- | ---------------------- | ------------------------ | -------------------------------------------------------------------------------------------------------- |
| `minimapConfiguration` | `MinimapConfiguration` | `MinimapConfiguration()` | Controls the scroll-position minimap overlay. See `[MinimapConfiguration](#minimapconfiguration)` below. |


---

### `MinimapConfiguration`

A floating scroll-position thumbnail that fades in while the user pans and fades out automatically.

```dart
SlotSelectionGrid(
  minimapConfiguration: const MinimapConfiguration(
    enabled: true,
    maxDimension: 72.0,
    backgroundColor: Color(0x99000000),
  ),
  // ...
)
```


| Parameter          | Type       | Default                    | Description                                                                               |
| ------------------ | ---------- | -------------------------- | ----------------------------------------------------------------------------------------- |
| `enabled`          | `bool`     | `true`                     | Show/hide the minimap entirely.                                                           |
| `maxDimension`     | `double`   | `72.0`                     | Longest side of the minimap in logical pixels; the other dimension scales proportionally. |
| `hideDelay`        | `Duration` | `1000 ms`                  | Time after the last scroll event before the minimap begins to fade out.                   |
| `fadeDuration`     | `Duration` | `200 ms`                   | Duration of the fade-in / fade-out animation.                                             |
| `positionRight`    | `double`   | `8.0`                      | Distance from the right edge of the grid.                                                 |
| `positionBottom`   | `double`   | `8.0`                      | Distance from the bottom edge of the grid.                                                |
| `internalPadding`  | `double`   | `4.0`                      | Padding between the minimap border and the canvas content.                                |
| `backgroundColor`  | `Color`    | `0x73000000` (black @ 45%) | Background fill of the minimap container.                                                 |
| `borderRadius`     | `double`   | `6.0`                      | Corner radius of the minimap container.                                                   |
| `dotColor`         | `Color`    | `0xA6FFFFFF` (white @ 65%) | Color of the dot-grid texture.                                                            |
| `thumbBorderColor` | `Color`    | `0xF2FFFFFF` (white @ 95%) | Border color of the viewport thumb rectangle.                                             |
| `thumbFillColor`   | `Color`    | `0x1AFFFFFF` (white @ 10%) | Fill color of the viewport thumb rectangle.                                               |


---

### `SlotSelectionGridThemeData` & `SlotCellStyle`

Controls the appearance of the default `SlotCell` when no custom cell builders are supplied.

```dart
SlotSelectionGrid(
  theme: const SlotSelectionGridThemeData(
    cellStyle: SlotCellStyle(
      selectedBackgroundColor: Color(0xFF1976D2),
      selectedBorderColor: Color(0xFF1976D2),
      selectedIconColor: Colors.white,
    ),
  ),
  // ...
)
```

`**SlotSelectionGridThemeData**`


| Parameter   | Type            | Default                  |
| ----------- | --------------- | ------------------------ |
| `cellStyle` | `SlotCellStyle` | `SlotCellStyle.defaults` |


`**SlotCellStyle**`


| Parameter                    | Type     | Default             |
| ---------------------------- | -------- | ------------------- |
| `selectedBackgroundColor`    | `Color`  | `Color(0xFF4CAF50)` |
| `selectedBorderColor`        | `Color`  | `Color(0xFF4CAF50)` |
| `unselectedBackgroundColor`  | `Color`  | `Colors.white`      |
| `unselectedBorderColor`      | `Color`  | `Color(0xFFE0E0E0)` |
| `unavailableBackgroundColor` | `Color`  | `Color(0xFFE0E0E0)` |
| `unavailableBorderColor`     | `Color`  | `Color(0xFFBDBDBD)` |
| `selectedIconColor`          | `Color`  | `Colors.white`      |
| `unselectedIconColor`        | `Color`  | `Color(0xFF9E9E9E)` |
| `stripeColor`                | `Color`  | `Color(0xFFBDBDBD)` |
| `iconSize`                   | `double` | `20`                |


---

### `SlotState`

Sealed class representing the three possible states of a cell.

```dart
// Construct via factory constructors:
SlotState.unselected()
SlotState.selected()
SlotState.unavailable(reason: 'Already booked')
```


| Factory                          | Concrete type          | Notes                                                                                        |
| -------------------------------- | ---------------------- | -------------------------------------------------------------------------------------------- |
| `SlotState.unselected()`         | `UnselectedSlotState`  | Default for keys absent from `slotStates`.                                                   |
| `SlotState.selected()`           | `SelectedSlotState`    | Tapping toggles to `unselected`.                                                             |
| `SlotState.unavailable(reason:)` | `UnavailableSlotState` | Tapping fires `onUnavailableSlotTapped`; reason is exposed on `UnavailableSlotState.reason`. |


---

### `TimeSlot`

Represents a start/end time range for a row in the grid.

```dart
// Constructor
TimeSlot(startTime: TimeOfDay(hour: 9, minute: 0), endTime: TimeOfDay(hour: 9, minute: 30))

// Factory — preferred for most use cases
final slot = TimeSlot.fromTime(9, 0);                          // 09:00–09:30 (default 30 min)
final longSlot = TimeSlot.fromTime(9, 0, durationMinutes: 60); // 09:00–10:00
```


| Member                     | Type        | Description                                                    |
| -------------------------- | ----------- | -------------------------------------------------------------- |
| `startTime`                | `TimeOfDay` | Start of the time range.                                       |
| `endTime`                  | `TimeOfDay` | End of the time range.                                         |
| `duration`                 | `Duration`  | Computed length; handles midnight wrap-around.                 |
| `formatStartTime(context)` | `String`    | Localized start time string via `MaterialLocalizations`.       |
| `formatEndTime(context)`   | `String`    | Localized end time string.                                     |
| `formatTimeRange(context)` | `String`    | Localized range, e.g. `"9:00 AM–9:30 AM"`.                     |
| `formattedStartTime`       | `String`    | Non-localized 12-hour start string (no `BuildContext` needed). |


---

### `SlotKey`

Composite key used in `slotStates`. Calendar **day** is used for equality — the time component of the `DateTime` is ignored.

```dart
final key = SlotKey(date: someDate, timeSlot: someSlot);
stateBySlot[key] = SlotState.selected();
```

---

## Recipes

### Skeleton loading

```dart
SlotSelectionGrid(
  dates: const [],
  timeSlots: const [],
  slotStates: const {},
  loading: true,
  loadingSkeletonDayCount: 7,
  dateHeaderBuilder: (context, date, isLoading) => isLoading
      ? Container(width: 32, height: 14, color: Colors.grey.shade300)
      : Text(MaterialLocalizations.of(context).formatShortDate(date)),
)
```

### Custom cell builders per state

```dart
SlotSelectionGrid(
  // ...
  buildSelectedSlotCell: (slot, isLoading) => Container(
    color: Colors.blue,
    child: const Icon(Icons.check, color: Colors.white),
  ),
  buildUnavailableSlotCell: (slot, isLoading) => Container(
    color: Colors.grey.shade200,
    child: const Icon(Icons.lock, color: Colors.grey),
  ),
)
```

### Disable the minimap

```dart
SlotSelectionGrid(
  minimapConfiguration: const MinimapConfiguration(enabled: false),
  // ...
)
```

---

## Example

```bash
cd example && flutter run
```

---

## Repository

Source and issues: [github.com/wework-india/slot_selection_grid](https://github.com/wework-india/slot_selection_grid)

## License

MIT — see [LICENSE](LICENSE).