import 'package:flutter/material.dart';

import 'slot_state.dart';

/// A time range within a single day, defined by a [startTime] and [endTime].
///
/// Used as the row descriptor in the [SlotSelectionGrid] grid. Two [TimeSlot]s are
/// equal when both [startTime] and [endTime] match.
///
/// ```dart
/// // 30-minute slot starting at 09:00 (default duration)
/// final slot = TimeSlot.fromTime(9, 0);
///
/// // 60-minute slot
/// final hour = TimeSlot.fromTime(9, 0, durationMinutes: 60);
/// ```
class TimeSlot {
  /// Creates a [TimeSlot] with explicit [startTime] and [endTime].
  TimeSlot({required this.startTime, required this.endTime});

  /// Start of the time range.
  final TimeOfDay startTime;

  /// End of the time range.
  final TimeOfDay endTime;

  /// Creates a slot from a start [hour] and [minute] with an optional
  /// [durationMinutes] (default `30`).
  ///
  /// End time wraps past midnight when the duration crosses 24:00.
  factory TimeSlot.fromTime(int hour, int minute, {int durationMinutes = 30}) {
    final start = TimeOfDay(hour: hour, minute: minute);
    final totalStartMinutes = hour * 60 + minute;
    final totalEndMinutes = totalStartMinutes + durationMinutes;
    final endHour = totalEndMinutes ~/ 60;
    final endMinute = totalEndMinutes % 60;
    final end = TimeOfDay(hour: endHour % 24, minute: endMinute);
    return TimeSlot(startTime: start, endTime: end);
  }

  /// Returns the start time formatted via [MaterialLocalizations] (locale-aware).
  String formatStartTime(BuildContext context) => startTime.format(context);

  /// Returns the end time formatted via [MaterialLocalizations] (locale-aware).
  String formatEndTime(BuildContext context) => endTime.format(context);

  /// Non-localized 12-hour start time string (e.g. `"9:00 AM"`).
  ///
  /// Prefer [formatStartTime] when a [BuildContext] is available so the output
  /// respects the device locale.
  String get formattedStartTime {
    final hour = startTime.hour;
    final minute = startTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Returns the localized time range string, e.g. `"9:00 AM–9:30 AM"`.
  String formatTimeRange(BuildContext context) =>
      '${formatStartTime(context)}–${formatEndTime(context)}';

  /// Computed length of the slot.
  ///
  /// When [endTime] is earlier than [startTime] (i.e. the slot wraps past
  /// midnight), the duration is calculated as if [endTime] is on the next day.
  Duration get duration {
    final startM = startTime.hour * 60 + startTime.minute;
    var endM = endTime.hour * 60 + endTime.minute;
    if (endM <= startM) {
      endM += 24 * 60;
    }
    return Duration(minutes: endM - startM);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => Object.hash(startTime, endTime);
}

/// A resolved grid cell: a calendar [date], a [timeSlot] row, and the current
/// [SlotState].
///
/// Primarily used internally by [SlotSelectionGrid]; consumers typically interact with
/// [DateAndTimeSlot] (the map key) and [SlotState] (the map value) instead.
class SlotData {
  /// Creates a [SlotData] with the given [date], [timeSlot], and [state].
  SlotData({required this.date, required this.timeSlot, required this.state});

  /// The calendar day this cell belongs to.
  final DateTime date;

  /// The time range row this cell occupies.
  final TimeSlot timeSlot;

  /// Current selection state of this cell.
  final SlotState state;

  /// Returns a copy of this [SlotData] with an optional new [state].
  SlotData copyWith({SlotState? state}) {
    return SlotData(date: date, timeSlot: timeSlot, state: state ?? this.state);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotData &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          timeSlot.startTime == other.timeSlot.startTime &&
          timeSlot.startTime.minute == other.timeSlot.startTime.minute;

  @override
  int get hashCode => Object.hash(
        date.year,
        date.month,
        date.day,
        timeSlot.startTime.hour,
        timeSlot.startTime.minute,
      );
}
