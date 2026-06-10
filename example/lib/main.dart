import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slot_selection_grid/slot_selection_grid.dart';

void main() {
  runApp(const SlotPickerExampleApp());
}

const _kMonthAbbr = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _weekdayShort(DateTime d) {
  const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return w[d.weekday - 1];
}

// ---------------------------------------------------------------------------
// Params model
// ---------------------------------------------------------------------------

class _SlotPickerParams {
  const _SlotPickerParams({
    this.cellSize = 64.0,
    this.timeColumnWidth = 72.0,
    this.showTimeLabels = true,
    this.loading = false,
    this.dayCount = 14,
    this.startHour = 8,
    this.endHour = 20,
    this.slotMinutes = 30,
  });

  final double cellSize;
  final double timeColumnWidth;
  final bool showTimeLabels;
  final bool loading;
  final int dayCount;
  final int startHour;
  final int endHour;
  final int slotMinutes;

  _SlotPickerParams copyWith({
    double? cellSize,
    double? timeColumnWidth,
    bool? showTimeLabels,
    bool? loading,
    int? dayCount,
    int? startHour,
    int? endHour,
    int? slotMinutes,
  }) {
    return _SlotPickerParams(
      cellSize: cellSize ?? this.cellSize,
      timeColumnWidth: timeColumnWidth ?? this.timeColumnWidth,
      showTimeLabels: showTimeLabels ?? this.showTimeLabels,
      loading: loading ?? this.loading,
      dayCount: dayCount ?? this.dayCount,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      slotMinutes: slotMinutes ?? this.slotMinutes,
    );
  }
}

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

class SlotPickerExampleApp extends StatelessWidget {
  const SlotPickerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF2D6A6A);
    return MaterialApp(
      title: 'slot_selection_grid example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          surface: const Color(0xFFF8F9F9),
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const SlotPickerDemoPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Demo page
// ---------------------------------------------------------------------------

class SlotPickerDemoPage extends StatefulWidget {
  const SlotPickerDemoPage({super.key});

  @override
  State<SlotPickerDemoPage> createState() => _SlotPickerDemoPageState();
}

class _SlotPickerDemoPageState extends State<SlotPickerDemoPage> {
  _SlotPickerParams _params = const _SlotPickerParams();

  late List<DateTime> _dates;
  late List<TimeSlot> _timeSlots;
  Map<DateAndTimeSlot, SlotState> _slotStates = {};

  @override
  void initState() {
    super.initState();
    _rebuildGrid(_params);
  }

  // Rebuilds dates, timeSlots, and slotStates from params.
  // Preserves existing selection state where slots still exist.
  void _rebuildGrid(_SlotPickerParams p) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);

    final newDates =
        List.generate(p.dayCount, (i) => start.add(Duration(days: i)));

    final newTimeSlots = <TimeSlot>[];
    for (var hour = p.startHour; hour < p.endHour; hour++) {
      newTimeSlots.add(TimeSlot.fromTime(hour, 0));
      if (p.slotMinutes == 30) {
        newTimeSlots.add(TimeSlot.fromTime(hour, 30));
      }
    }

    final newStates = <DateAndTimeSlot, SlotState>{};
    for (var i = 0; i < newDates.length; i++) {
      final d = newDates[i];
      for (final t in newTimeSlots) {
        final key = DateAndTimeSlot(date: d, timeSlot: t);
        // Preserve prior selection if the slot existed before.
        if (_slotStates.containsKey(key)) {
          newStates[key] = _slotStates[key]!;
        } else if (i == 0 &&
            t.startTime.hour == 10 &&
            t.startTime.minute == 0) {
          newStates[key] = SlotState.unavailable(reason: 'Booked');
        } else if (i == 3 && t.startTime.hour == 9 && t.startTime.minute == 0) {
          newStates[key] = SlotState.unavailable(reason: 'Booked');
        } else {
          newStates[key] = SlotState.unselected();
        }
      }
    }

    _dates = newDates;
    _timeSlots = newTimeSlots;
    _slotStates = newStates;
    _params = p;
  }

  void _onSlotTapped(DateAndTimeSlot slot, SlotState newState) {
    setState(() => _slotStates[slot] = newState);
  }

  void _onUnavailableTapped(DateAndTimeSlot slot, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(reason),
      ),
    );
  }

  void _openFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _FiltersSheet(
        current: _params,
        onConfirm: (newParams) {
          setState(() => _rebuildGrid(newParams));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a slot'),
        // backgroundColor: scheme.surface,
        // foregroundColor: scheme.onSurface,
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // surfaceTintColor: Colors.red,
        // backgroundColor: Colors.red,
        actions: [
          IconButton(
            tooltip: 'Configure picker',
            icon: const Icon(Icons.tune_rounded),
            onPressed: _openFiltersSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: NotificationListener<ScrollNotification>(
                  // Absorb scroll notifications so SlotPicker's internal
                  // scroll views don't trigger the AppBar's M3 tint.
                  onNotification: (_) => true,
                  child: SlotPicker(
                    dates: _dates,
                    timeSlots: _timeSlots,
                    slotStates: _slotStates,
                    cellSize: _params.cellSize,
                    timeColumnWidth: _params.timeColumnWidth,
                    showTimeLabels: _params.showTimeLabels,
                    loading: _params.loading,
                    buildSelectedSlotCell: (dateAndTimeslot, isLoading) {
                      if (isLoading) return const _ShimmerCell();
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade200,
                          border: Border.all(color: const Color(0xff50C167)),
                        ),
                        child: const Center(
                          child: Icon(Icons.check_circle, color: Colors.green),
                        ),
                      );
                    },
                    buildOriginSlotCell: (context) => Icon(
                      Icons.date_range_sharp,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                    buildUnselectedSlotCell: (dateAndTimeslot, isLoading) {
                      if (isLoading) return const _ShimmerCell();
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Colors.grey.shade500,
                            size: 22,
                          ),
                        ),
                      );
                    },
                    buildUnavailableSlotCell: (dateAndTimeslot, isLoading) {
                      if (isLoading) return const _ShimmerCell();
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.grey.shade500.withAlpha(64),
                              BlendMode.srcIn,
                            ),
                            child:
                                Image.asset('assets/unavailable_texture.png'),
                          ),
                        ),
                      );
                    },
                    onSlotTapped: _onSlotTapped,
                    onUnavailableSlotTapped: _onUnavailableTapped,
                    headerColor: null,
                    innerShadowColor: scheme.shadow.withValues(alpha: 0.18),
                    // theme / SlotCellStyle is omitted here because all three
                    // build*SlotCell builders are provided above, which fully
                    // replace the default SlotCell rendering for every state.
                    // Set theme only when omitting one or more builders.
                    titleBuilder: (context) => Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_view_week_rounded,
                            size: 20,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Availability',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    dateHeaderBuilder: (context, date, loading) {
                      if (loading) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ShimmerBox(width: 28, height: 10, radius: 4),
                              const SizedBox(height: 4),
                              _ShimmerBox(width: 36, height: 13, radius: 4),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _weekdayShort(date),
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_kMonthAbbr[date.month - 1]} ${date.day}',
                              textAlign: TextAlign.center,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    slotTitleBuilder: (context, slot, loading) {
                      if (loading) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 6, right: 10),
                          child: _ShimmerBox(width: 40, height: 12, radius: 4),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 6, right: 10),
                        child: Text(
                          slot.formatStartTime(context),
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.05,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: scheme.inversePrimary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_outlined, color: scheme.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Tap open slots to select. Striped slots are unavailable.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer helpers
// ---------------------------------------------------------------------------

class _ShimmerCell extends StatelessWidget {
  const _ShimmerCell();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Icon(Icons.add_circle_outline,
              size: 20, color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filters bottom sheet
// ---------------------------------------------------------------------------

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.current, required this.onConfirm});

  final _SlotPickerParams current;
  final void Function(_SlotPickerParams) onConfirm;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late _SlotPickerParams _pending;

  @override
  void initState() {
    super.initState();
    _pending = widget.current;
  }

  void _confirm() {
    widget.onConfirm(_pending);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, color: scheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Configure Picker',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Divider(color: scheme.outlineVariant),
                ],
              ),
            ),

            // Scrollable params
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _SectionLabel('Grid'),
                  _SliderRow(
                    label: 'Cell size',
                    value: _pending.cellSize,
                    min: 32,
                    max: 96,
                    divisions: 16,
                    format: (v) => '${v.round()} px',
                    onChanged: (v) => setState(
                        () => _pending = _pending.copyWith(cellSize: v)),
                  ),
                  _SliderRow(
                    label: 'Time column width',
                    value: _pending.timeColumnWidth,
                    min: 32,
                    max: 120,
                    divisions: 22,
                    format: (v) => '${v.round()} px',
                    onChanged: (v) => setState(
                        () => _pending = _pending.copyWith(timeColumnWidth: v)),
                  ),
                  _SwitchRow(
                    label: 'Show time labels',
                    value: _pending.showTimeLabels,
                    onChanged: (v) => setState(
                        () => _pending = _pending.copyWith(showTimeLabels: v)),
                  ),
                  const SizedBox(height: 12),
                  _SectionLabel('Date range'),
                  _SliderRow(
                    label: 'Number of days',
                    value: _pending.dayCount.toDouble(),
                    min: 1,
                    max: 64,
                    divisions: 13,
                    format: (v) => '${v.round()} days',
                    onChanged: (v) => setState(() =>
                        _pending = _pending.copyWith(dayCount: v.round())),
                  ),
                  const SizedBox(height: 12),
                  _SectionLabel('Time range'),
                  _SliderRow(
                    label: 'Start hour',
                    value: _pending.startHour.toDouble(),
                    min: 0,
                    max: 18,
                    divisions: 18,
                    format: (v) => '${v.round()}:00',
                    onChanged: (v) {
                      final newStart = v.round();
                      final newEnd = _pending.endHour <= newStart
                          ? newStart + 1
                          : _pending.endHour;
                      setState(() => _pending = _pending.copyWith(
                            startHour: newStart,
                            endHour: newEnd,
                          ));
                    },
                  ),
                  _SliderRow(
                    label: 'End hour',
                    value: _pending.endHour.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    format: (v) => '${v.round()}:00',
                    onChanged: (v) {
                      final newEnd = v.round();
                      final newStart = _pending.startHour >= newEnd
                          ? newEnd - 1
                          : _pending.startHour;
                      setState(() => _pending = _pending.copyWith(
                            endHour: newEnd,
                            startHour: newStart,
                          ));
                    },
                  ),
                  _SegmentedRow(
                    label: 'Slot duration',
                    options: const {30: '30 min', 60: '60 min'},
                    selected: _pending.slotMinutes,
                    onChanged: (v) => setState(
                        () => _pending = _pending.copyWith(slotMinutes: v)),
                  ),
                  const SizedBox(height: 12),
                  _SectionLabel('State'),
                  _SwitchRow(
                    label: 'Loading skeleton',
                    value: _pending.loading,
                    onChanged: (v) => setState(
                        () => _pending = _pending.copyWith(loading: v)),
                  ),
                ],
              ),
            ),

            // Confirm button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Confirm'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable sheet row widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: textTheme.bodyMedium),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  format(value),
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  const _SegmentedRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final Map<int, String> options;
  final int selected;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          SegmentedButton<int>(
            segments: options.entries
                .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
                .toList(),
            selected: {selected},
            onSelectionChanged: (s) => onChanged(s.first),
            style: SegmentedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }
}
