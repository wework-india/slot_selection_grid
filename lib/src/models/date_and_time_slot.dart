import 'time_slot.dart';

/// Composite key for the [SlotPicker.slotStates] map — a calendar day plus a
/// [TimeSlot].
///
/// **Equality uses the calendar date only** (year, month, day). The time-of-day
/// portion of [date] is intentionally ignored so that a `DateTime` with an
/// arbitrary time component (e.g. from a server timestamp) matches the same
/// logical day as one constructed with `DateTime(year, month, day)`.
///
/// ```dart
/// final key = DateAndTimeSlot(date: DateTime(2026, 3, 30), timeSlot: slot);
/// final sameDay = DateAndTimeSlot(date: DateTime(2026, 3, 30, 15, 30), timeSlot: slot);
/// assert(key == sameDay); // true — time-of-day is ignored
/// ```
class DateAndTimeSlot {
  /// Creates a [DateAndTimeSlot] from a [date] and a [timeSlot].
  const DateAndTimeSlot({required this.date, required this.timeSlot});

  /// The calendar day. Only year, month, and day are used for equality.
  final DateTime date;

  /// The time range row associated with this key.
  final TimeSlot timeSlot;

  /// Convenience factory equivalent to the default constructor.
  factory DateAndTimeSlot.fromDateTime(DateTime date, TimeSlot timeSlot) {
    return DateAndTimeSlot(date: date, timeSlot: timeSlot);
  }

  /// Calendar date (year/month/day); time-of-day on [date] is ignored for equality.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateAndTimeSlot &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          timeSlot == other.timeSlot;

  @override
  int get hashCode =>
      Object.hash(
        date.year,
        date.month,
        date.day,
        timeSlot.startTime.hour,
        timeSlot.startTime.minute,
        timeSlot.endTime.hour,
        timeSlot.endTime.minute,
      );
}
