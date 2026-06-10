import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_selection_grid/slot_selection_grid.dart';

void main() {
  // ---------------------------------------------------------------------------
  // SlotKey
  // ---------------------------------------------------------------------------
  group('SlotKey', () {
    test('map lookup uses calendar day, not time-of-day on DateTime', () {
      final t = TimeSlot.fromTime(9, 0);
      final key = SlotKey(
        date: DateTime(2026, 3, 30, 15, 30),
        timeSlot: t,
      );
      final map = <SlotKey, SlotState>{
        SlotKey(
          date: DateTime(2026, 3, 30),
          timeSlot: t,
        ): SlotState.selected(),
      };
      expect(map[key], isA<SelectedSlotState>());
    });

    test('different days are not equal', () {
      final t = TimeSlot.fromTime(9, 0);
      final a = SlotKey(date: DateTime(2026, 3, 30), timeSlot: t);
      final b = SlotKey(date: DateTime(2026, 3, 31), timeSlot: t);
      expect(a == b, isFalse);
    });

    test('different time slots on same day are not equal', () {
      final day = DateTime(2026, 3, 30);
      final a = SlotKey(date: day, timeSlot: TimeSlot.fromTime(9, 0));
      final b = SlotKey(date: day, timeSlot: TimeSlot.fromTime(9, 30));
      expect(a == b, isFalse);
    });

    test('fromDateTime factory equals default constructor', () {
      final t = TimeSlot.fromTime(10, 0);
      final a = SlotKey(date: DateTime(2026, 1, 1), timeSlot: t);
      final b = SlotKey.fromDateTime(DateTime(2026, 1, 1), t);
      expect(a, equals(b));
    });
  });

  // ---------------------------------------------------------------------------
  // TimeSlot
  // ---------------------------------------------------------------------------
  group('TimeSlot', () {
    test('duration wraps when end is before start on the clock', () {
      final slot = TimeSlot(
        startTime: const TimeOfDay(hour: 22, minute: 0),
        endTime: const TimeOfDay(hour: 6, minute: 0),
      );
      expect(slot.duration, const Duration(hours: 8));
    });

    test('fromTime creates correct 30-minute slot', () {
      final slot = TimeSlot.fromTime(9, 0);
      expect(slot.startTime, const TimeOfDay(hour: 9, minute: 0));
      expect(slot.endTime, const TimeOfDay(hour: 9, minute: 30));
      expect(slot.duration, const Duration(minutes: 30));
    });

    test('fromTime with custom durationMinutes', () {
      final slot = TimeSlot.fromTime(9, 0, durationMinutes: 60);
      expect(slot.endTime, const TimeOfDay(hour: 10, minute: 0));
      expect(slot.duration, const Duration(hours: 1));
    });

    test('equality matches on startTime and endTime', () {
      final a = TimeSlot.fromTime(9, 0);
      final b = TimeSlot.fromTime(9, 0);
      expect(a, equals(b));
    });

    test('formattedStartTime returns non-empty string', () {
      final slot = TimeSlot.fromTime(9, 0);
      expect(slot.formattedStartTime, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // SlotState
  // ---------------------------------------------------------------------------
  group('SlotState', () {
    test('unselected() returns UnselectedSlotState', () {
      expect(SlotState.unselected(), isA<UnselectedSlotState>());
    });

    test('selected() returns SelectedSlotState', () {
      expect(SlotState.selected(), isA<SelectedSlotState>());
    });

    test('unavailable() returns UnavailableSlotState with correct reason', () {
      const reason = 'Maintenance window';
      final state = SlotState.unavailable(reason: reason);
      expect(state, isA<UnavailableSlotState>());
      expect((state as UnavailableSlotState).reason, reason);
    });
  });

  // ---------------------------------------------------------------------------
  // SlotSelectionGrid widget
  // ---------------------------------------------------------------------------
  group('SlotSelectionGrid', () {
    testWidgets('renders without error with minimal required params',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              width: 400,
              child: SlotSelectionGrid(
                dates: [DateTime(2026, 3, 30)],
                timeSlots: [TimeSlot.fromTime(9, 0)],
                slotStates: const {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SlotSelectionGrid), findsOneWidget);
    });

    testWidgets('loading skeleton renders when dates and timeSlots are empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              width: 400,
              child: SlotSelectionGrid(
                dates: [],
                timeSlots: [],
                slotStates: {},
                loading: true,
                loadingSkeletonDayCount: 3,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SlotSelectionGrid), findsOneWidget);
      // Skeleton renders SlotCell widgets (unavailable state)
      expect(find.byType(SlotCell), findsWidgets);
    });

    testWidgets('tap toggles selection via onSlotTapped', (tester) async {
      final day = DateTime(2026, 3, 30);
      final slot = TimeSlot.fromTime(9, 0);
      final key = SlotKey(date: day, timeSlot: slot);
      final states = <SlotKey, SlotState>{
        key: SlotState.unselected(),
      };

      SlotKey? lastSlot;
      SlotState? lastState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              width: 400,
              child: SlotSelectionGrid(
                dates: [day],
                timeSlots: [slot],
                slotStates: states,
                onSlotTapped: (s, ns) {
                  lastSlot = s;
                  lastState = ns;
                  states[s] = ns;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SlotCell));
      await tester.pumpAndSettle();

      expect(lastSlot, key);
      expect(lastState, isA<SelectedSlotState>());
    });

    testWidgets('custom theme colors apply to SlotCell', (tester) async {
      final day = DateTime(2026, 3, 30);
      final slot = TimeSlot.fromTime(9, 0);
      final key = SlotKey(date: day, timeSlot: slot);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              width: 400,
              child: SlotSelectionGrid(
                dates: [day],
                timeSlots: [slot],
                slotStates: {key: SlotState.selected()},
                theme: const SlotSelectionGridThemeData(
                  cellStyle: SlotCellStyle(
                    selectedBackgroundColor: Color(0xFFFF0000),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SlotCell),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, const Color(0xFFFF0000));
    });

    testWidgets('unavailable cell does not fire onSlotTapped', (tester) async {
      final day = DateTime(2026, 3, 30);
      final slot = TimeSlot.fromTime(9, 0);
      final key = SlotKey(date: day, timeSlot: slot);
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              width: 400,
              child: SlotSelectionGrid(
                dates: [day],
                timeSlots: [slot],
                slotStates: {key: SlotState.unavailable(reason: 'Booked')},
                onSlotTapped: (_, __) => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SlotCell));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });
  });
}
