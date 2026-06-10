import 'dart:async';

import 'package:flutter/material.dart';

import '../models/date_and_time_slot.dart';
import '../models/minimap_configuration.dart';
import '../models/slot_state.dart';
import '../models/time_slot.dart';
import '../theme/slot_selection_grid_theme.dart';
import 'slot_cell.dart';

/// A scrollable grid of time slots across multiple dates.
///
/// Renders a 2-D grid where columns represent calendar days ([dates]) and rows
/// represent time ranges ([timeSlots]). Supports:
/// - **Synchronized scrolling** — the date header and time-label column stay
///   fixed while the cell grid pans in both axes.
/// - **Momentum scrolling** — physics-based deceleration after a pan gesture.
/// - **Edge shadows** — animated inner shadows indicate overflowing content.
/// - **Skeleton loading** — shows a placeholder grid while data is in-flight.
/// - **Scroll minimap** — a floating dot-grid thumbnail with a viewport thumb.
/// - **Custom cell builders** per [SlotState] (selected / unselected / unavailable).
///
/// ## Minimal usage
///
/// ```dart
/// SlotSelectionGrid(
///   dates: myWeek,           // List<DateTime>
///   timeSlots: mySlots,      // List<TimeSlot>
///   slotStates: stateBySlot, // Map<DateAndTimeSlot, SlotState>
///   onSlotTapped: (slot, newState) {
///     setState(() => stateBySlot[slot] = newState);
///   },
///   dateHeaderBuilder: (context, date, isLoading) =>
///       Text(MaterialLocalizations.of(context).formatShortDate(date)),
///   slotTitleBuilder: (context, slot, isLoading) =>
///       Text(slot.formatTimeRange(context)),
/// )
/// ```
///
/// > **Tip:** Set [timeColumnWidth] wider than [cellSize] so time-range labels
/// > have room to render without clipping.
class SlotSelectionGrid extends StatefulWidget {
  const SlotSelectionGrid({
    super.key,
    required this.dates,
    required this.timeSlots,
    required this.slotStates,
    this.onSlotTapped,
    this.onUnavailableSlotTapped,
    this.cellSize = 50.0,
    this.timeColumnWidth,
    this.showTimeLabels = true,
    this.dateHeaderBuilder,
    this.slotTitleBuilder,
    this.dateFormatter,
    this.buildSelectedSlotCell,
    this.buildUnselectedSlotCell,
    this.buildUnavailableSlotCell,
    this.buildOriginSlotCell,
    this.titleBuilder,
    this.headerColor,
    this.innerShadowColor,
    this.loading = false,
    this.theme,
    this.loadingSkeletonDayCount = 12,
    this.loadingPlaceholderTimeSlots,
    this.loadingUnavailableReason = '',
    this.minimapConfiguration = const MinimapConfiguration(),
  });

  /// List of dates to display (typically a week)
  final List<DateTime> dates;

  /// List of time slots to display
  final List<TimeSlot> timeSlots;

  /// Map of slot data keyed by date and time slot
  final Map<DateAndTimeSlot, SlotState> slotStates;

  /// Callback when a slot is tapped
  final void Function(DateAndTimeSlot slot, SlotState newState)? onSlotTapped;

  /// Callback fired when an [UnavailableSlotState] cell is tapped; receives the
  /// slot key and the [UnavailableSlotState.reason] string.
  final void Function(DateAndTimeSlot slot, String reason)?
      onUnavailableSlotTapped;

  /// Size of each slot cell (width and height of grid cells).
  final double cellSize;

  /// Width of the left time-label column when [showTimeLabels] is true.
  /// Defaults to [cellSize] when null (often too narrow for a full time range).
  final double? timeColumnWidth;

  /// Whether to show time labels on the left
  final bool showTimeLabels;

  /// Builder for custom date headers. If provided, date headers will be shown.
  /// Each date will be passed to this builder to create the header widget.
  final Widget Function(BuildContext context, DateTime date, bool isLoading)?
      dateHeaderBuilder;

  /// Builder for the time labels column. If null, the column is still laid out
  /// but cells are empty unless you use [showTimeLabels] false.
  final Widget Function(BuildContext context, TimeSlot slot, bool isLoading)?
      slotTitleBuilder;

  /// Custom date formatter
  final String Function(DateTime date)? dateFormatter;

  /// Builder for a fully custom selected-state cell.
  ///
  /// When provided, this widget replaces the default [SlotCell] for every
  /// [SelectedSlotState] slot, so any [SlotCellStyle.selectedBackgroundColor],
  /// [SlotCellStyle.selectedBorderColor], and [SlotCellStyle.selectedIconColor]
  /// values in [theme] have **no effect** for that state. Omit this builder
  /// (leave it `null`) if you want [SlotCellStyle] to control the appearance.
  final Widget Function(DateAndTimeSlot, bool isLoading)? buildSelectedSlotCell;

  /// Builder for a fully custom unselected-state cell.
  ///
  /// When provided, this widget replaces the default [SlotCell] for every
  /// [UnselectedSlotState] slot, so [SlotCellStyle.unselectedBackgroundColor],
  /// [SlotCellStyle.unselectedBorderColor], and [SlotCellStyle.unselectedIconColor]
  /// values in [theme] have **no effect** for that state. Omit this builder
  /// (leave it `null`) if you want [SlotCellStyle] to control the appearance.
  final Widget Function(DateAndTimeSlot, bool isLoading)?
      buildUnselectedSlotCell;

  /// Builder for a fully custom unavailable-state cell.
  ///
  /// When provided, this widget replaces the default [SlotCell] for every
  /// [UnavailableSlotState] slot, so [SlotCellStyle.unavailableBackgroundColor],
  /// [SlotCellStyle.unavailableBorderColor], and [SlotCellStyle.stripeColor]
  /// values in [theme] have **no effect** for that state. Omit this builder
  /// (leave it `null`) if you want [SlotCellStyle] to control the appearance.
  final Widget Function(DateAndTimeSlot, bool isLoading)?
      buildUnavailableSlotCell;

  /// Widget placed in the top-left origin cell — the intersection of the time
  /// column and the date header row. Commonly used for a timezone label or logo.
  final Widget Function(BuildContext context)? buildOriginSlotCell;

  /// Widget rendered above the date headers inside the sticky header card.
  /// Use for a title bar, legend, or toolbar above the grid.
  final Widget Function(BuildContext context)? titleBuilder;

  /// Background color of the sticky date-header card.
  /// Defaults to the ambient [CardTheme] surface color when `null`.
  final Color? headerColor;

  /// Color of the animated inner-edge scroll shadows.
  /// Defaults to `Colors.black` at 15% opacity when `null`.
  final Color? innerShadowColor;

  /// Whether to show the loading layout (placeholders) while data is fetched.
  final bool loading;

  /// Default colors and icon sizes applied to [SlotCell] widgets.
  ///
  /// [SlotCellStyle] only takes effect for states whose custom builder
  /// (`build*SlotCell`) is `null`. When a builder is supplied for a given
  /// state, that builder's widget is rendered instead and the corresponding
  /// [SlotCellStyle] fields are ignored for that state.
  ///
  /// Defaults to [SlotCellStyle.defaults] when omitted.
  final SlotSelectionGridThemeData? theme;

  /// Number of placeholder days when [loading] is true and [dates] is empty.
  final int loadingSkeletonDayCount;

  /// Placeholder time rows when [loading] is true and [timeSlots] is empty.
  /// Defaults to 8:00–20:00 in 30-minute steps.
  final List<TimeSlot>? loadingPlaceholderTimeSlots;

  /// [UnavailableSlotState.reason] for default loading cells (often left empty).
  final String loadingUnavailableReason;

  /// Configuration for the minimap overlay shown while scrolling.
  final MinimapConfiguration minimapConfiguration;

  @override
  State<SlotSelectionGrid> createState() => _SlotSelectionGridState();
}

class _SlotSelectionGridState extends State<SlotSelectionGrid> {
  double get _timeColumnWidth => widget.timeColumnWidth ?? widget.cellSize;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _timeColumnScrollController = ScrollController();

  Offset? _panStartPosition;
  double _panStartHorizontalOffset = 0.0;
  double _panStartVerticalOffset = 0.0;
  bool _isDragging = false;

  // For momentum scrolling
  Offset? _lastPanPosition;
  DateTime? _lastPanTime;
  double _horizontalVelocity = 0.0;
  double _verticalVelocity = 0.0;

  final _shadowWidth = 12.0;

  final _animationDuration = const Duration(milliseconds: 300);

  // Shadow visibility state
  bool _showLeftShadow = false;
  bool _showRightShadow = false;
  bool _showTopShadow = false;
  bool _showBottomShadow = false;

  // Minimap overlay state
  bool _showMiniMap = false;
  Timer? _miniMapHideTimer;

  @override
  void initState() {
    super.initState();
    // Note: We sync header and time column manually during pan updates
    // instead of using listeners to avoid conflicts during manual dragging

    // Add listeners to update shadow visibility and sync during momentum scrolling
    _horizontalScrollController.addListener(() {
      _updateHorizontalShadows();
      _syncHeaderDuringMomentum();
      _triggerMiniMap();
    });
    _verticalScrollController.addListener(() {
      _updateVerticalShadows();
      _syncTimeColumnDuringMomentum();
      _triggerMiniMap();
    });

    // Add listeners to sync main grid when header or time column are scrolled directly
    _headerScrollController.addListener(() {
      if (!_isDragging &&
          _headerScrollController.hasClients &&
          _horizontalScrollController.hasClients) {
        final headerOffset = _headerScrollController.offset.clamp(
          0.0,
          _horizontalScrollController.position.maxScrollExtent,
        );
        if ((_horizontalScrollController.offset - headerOffset).abs() > 0.1) {
          _horizontalScrollController.jumpTo(headerOffset);
        }
      }
    });

    _timeColumnScrollController.addListener(() {
      if (!_isDragging &&
          _timeColumnScrollController.hasClients &&
          _verticalScrollController.hasClients &&
          _timeColumnScrollController.position.maxScrollExtent > 0) {
        final timeColumnOffset = _timeColumnScrollController.offset.clamp(
          0.0,
          _verticalScrollController.position.maxScrollExtent,
        );
        if ((_verticalScrollController.offset - timeColumnOffset).abs() > 0.1) {
          _verticalScrollController.jumpTo(timeColumnOffset);
        }
      }
    });

    // Update shadows after first frame when scroll controllers are attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHorizontalShadows();
      _updateVerticalShadows();
    });
  }

  void _syncHeaderDuringMomentum() {
    // Only sync if we're not manually dragging (i.e., during momentum animation)
    if (!_isDragging &&
        _horizontalScrollController.hasClients &&
        _headerScrollController.hasClients) {
      final headerOffset = _horizontalScrollController.offset.clamp(
        0.0,
        _headerScrollController.position.maxScrollExtent,
      );
      // Use jumpTo to avoid creating new animations
      if ((_headerScrollController.offset - headerOffset).abs() > 0.1) {
        _headerScrollController.jumpTo(headerOffset);
      }
    }
  }

  void _syncTimeColumnDuringMomentum() {
    // Only sync if we're not manually dragging (i.e., during momentum animation)
    if (!_isDragging &&
        _verticalScrollController.hasClients &&
        _timeColumnScrollController.hasClients &&
        _timeColumnScrollController.position.maxScrollExtent > 0) {
      final timeColumnOffset = _verticalScrollController.offset.clamp(
        0.0,
        _timeColumnScrollController.position.maxScrollExtent,
      );
      // Use jumpTo to avoid creating new animations
      if ((_timeColumnScrollController.offset - timeColumnOffset).abs() > 0.1) {
        _timeColumnScrollController.jumpTo(timeColumnOffset);
      }
    }
  }

  @override
  void didUpdateWidget(SlotSelectionGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update shadows when widget rebuilds with new data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHorizontalShadows();
      _updateVerticalShadows();
    });
  }

  void _updateHorizontalShadows() {
    if (!_horizontalScrollController.hasClients) {
      if (_showLeftShadow || _showRightShadow) {
        setState(() {
          _showLeftShadow = false;
          _showRightShadow = false;
        });
      }
      return;
    }

    final position = _horizontalScrollController.position;
    final canScroll = position.maxScrollExtent > 0;
    final isAtStart = position.pixels <= 0;
    final isAtEnd = position.pixels >= position.maxScrollExtent;

    final newShowLeftShadow = canScroll && !isAtStart;
    final newShowRightShadow = canScroll && !isAtEnd;

    // Only update state if visibility actually changed
    if (_showLeftShadow != newShowLeftShadow ||
        _showRightShadow != newShowRightShadow) {
      setState(() {
        _showLeftShadow = newShowLeftShadow;
        _showRightShadow = newShowRightShadow;
      });
    }
  }

  void _updateVerticalShadows() {
    if (!_verticalScrollController.hasClients) {
      if (_showTopShadow || _showBottomShadow) {
        setState(() {
          _showTopShadow = false;
          _showBottomShadow = false;
        });
      }
      return;
    }

    final position = _verticalScrollController.position;
    final canScroll = position.maxScrollExtent > 0;
    final isAtStart = position.pixels <= 0;
    final isAtEnd = position.pixels >= position.maxScrollExtent;

    final newShowTopShadow = canScroll && !isAtStart;
    final newShowBottomShadow = canScroll && !isAtEnd;

    // Only update state if visibility actually changed
    if (_showTopShadow != newShowTopShadow ||
        _showBottomShadow != newShowBottomShadow) {
      setState(() {
        _showTopShadow = newShowTopShadow;
        _showBottomShadow = newShowBottomShadow;
      });
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _panStartPosition = details.localPosition;
    _lastPanPosition = details.localPosition;
    _lastPanTime = DateTime.now();
    _panStartHorizontalOffset = _horizontalScrollController.hasClients
        ? _horizontalScrollController.offset
        : 0.0;
    _panStartVerticalOffset = _verticalScrollController.hasClients
        ? _verticalScrollController.offset
        : 0.0;
    _isDragging = false;
    _horizontalVelocity = 0.0;
    _verticalVelocity = 0.0;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_panStartPosition == null) return;

    final delta = details.localPosition - _panStartPosition!;
    final dragDistance = delta.distance;

    // Calculate velocity for momentum scrolling
    if (_lastPanPosition != null && _lastPanTime != null) {
      final now = DateTime.now();
      final timeDelta =
          now.difference(_lastPanTime!).inMicroseconds / 1000000.0;
      if (timeDelta > 0) {
        final positionDelta = details.localPosition - _lastPanPosition!;
        _horizontalVelocity = positionDelta.dx / timeDelta;
        _verticalVelocity = positionDelta.dy / timeDelta;
      }
      _lastPanPosition = details.localPosition;
      _lastPanTime = now;
    }

    // Only start dragging if moved more than a small threshold
    if (!_isDragging && dragDistance > 5.0) {
      _isDragging = true;
    }

    if (_isDragging) {
      double newHorizontalOffset = _panStartHorizontalOffset - delta.dx;
      double newVerticalOffset = _panStartVerticalOffset - delta.dy;

      if (_horizontalScrollController.hasClients) {
        newHorizontalOffset = newHorizontalOffset.clamp(
          0.0,
          _horizontalScrollController.position.maxScrollExtent,
        );

        // Sync header before updating grid to avoid reset
        if (_headerScrollController.hasClients) {
          final maxExtent = _headerScrollController.position.maxScrollExtent;
          final headerOffset = newHorizontalOffset.clamp(0.0, maxExtent);
          _headerScrollController.jumpTo(headerOffset);
        }

        _horizontalScrollController.jumpTo(newHorizontalOffset);
        _updateHorizontalShadows();
      }

      if (_verticalScrollController.hasClients) {
        newVerticalOffset = newVerticalOffset.clamp(
          0.0,
          _verticalScrollController.position.maxScrollExtent,
        );

        // Manually sync time column before updating grid
        if (_timeColumnScrollController.hasClients &&
            _timeColumnScrollController.position.maxScrollExtent > 0) {
          final timeColumnOffset = newVerticalOffset.clamp(
            0.0,
            _timeColumnScrollController.position.maxScrollExtent,
          );
          _timeColumnScrollController.jumpTo(timeColumnOffset);
        }

        _verticalScrollController.jumpTo(newVerticalOffset);
        _updateVerticalShadows();
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging) {
      _panStartPosition = null;
      _lastPanPosition = null;
      _lastPanTime = null;
      _isDragging = false;
      return;
    }

    // Apply momentum scrolling using physics-based calculation
    // Horizontal momentum
    if (_horizontalScrollController.hasClients &&
        _horizontalVelocity.abs() > 50.0) {
      final position = _horizontalScrollController.position;
      final velocity =
          -_horizontalVelocity; // Negative because we're scrolling opposite to drag

      // Calculate target position based on velocity with deceleration
      // Using physics: distance = velocity * time, where time = |velocity| / deceleration
      // This preserves the sign of velocity (direction)
      const deceleration = 2000.0; // pixels per second squared
      final distance = velocity * (velocity.abs() / deceleration);
      final target = (position.pixels + distance).clamp(
        0.0,
        position.maxScrollExtent,
      );

      // Calculate duration based on velocity (faster = longer duration, up to a max)
      final durationMs = (velocity.abs() / deceleration * 1000).clamp(
        200.0,
        1000.0,
      );

      // Animate to target with deceleration curve
      _horizontalScrollController
          .animateTo(
        target,
        duration: Duration(milliseconds: durationMs.toInt()),
        curve: Curves.decelerate,
      )
          .then((_) {
        // Sync header after animation
        if (_headerScrollController.hasClients) {
          final headerOffset = _horizontalScrollController.offset.clamp(
            0.0,
            _headerScrollController.position.maxScrollExtent,
          );
          _headerScrollController.jumpTo(headerOffset);
        }
        _updateHorizontalShadows();
      });
    }

    // Vertical momentum
    if (_verticalScrollController.hasClients &&
        _verticalVelocity.abs() > 50.0) {
      final position = _verticalScrollController.position;
      final velocity =
          -_verticalVelocity; // Negative because we're scrolling opposite to drag

      // Calculate target position based on velocity with deceleration
      // Using physics: distance = velocity * time, where time = |velocity| / deceleration
      // This preserves the sign of velocity (direction)
      const deceleration = 2000.0; // pixels per second squared
      final distance = velocity * (velocity.abs() / deceleration);
      final target = (position.pixels + distance).clamp(
        0.0,
        position.maxScrollExtent,
      );

      // Calculate duration based on velocity
      final durationMs = (velocity.abs() / deceleration * 1000).clamp(
        200.0,
        1000.0,
      );

      // Animate to target with deceleration curve
      _verticalScrollController
          .animateTo(
        target,
        duration: Duration(milliseconds: durationMs.toInt()),
        curve: Curves.decelerate,
      )
          .then((_) {
        // Sync time column after animation
        if (_timeColumnScrollController.hasClients &&
            _timeColumnScrollController.position.maxScrollExtent > 0) {
          final timeColumnOffset = _verticalScrollController.offset.clamp(
            0.0,
            _timeColumnScrollController.position.maxScrollExtent,
          );
          _timeColumnScrollController.jumpTo(timeColumnOffset);
        }
        _updateVerticalShadows();
      });
    }

    _panStartPosition = null;
    _lastPanPosition = null;
    _lastPanTime = null;
    _isDragging = false;
    _horizontalVelocity = 0.0;
    _verticalVelocity = 0.0;
  }

  @override
  void dispose() {
    _miniMapHideTimer?.cancel();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _headerScrollController.dispose();
    _timeColumnScrollController.dispose();
    super.dispose();
  }

  /// Reveals the minimap and (re)schedules its hide timer.
  /// Called on every scroll tick from either axis.
  void _triggerMiniMap() {
    final config = widget.minimapConfiguration;
    // why: skip entirely when minimap is disabled or nothing is scrollable.
    if (!config.enabled || !_isContentScrollable()) return;

    if (!_showMiniMap) {
      setState(() => _showMiniMap = true);
    }
    _miniMapHideTimer?.cancel();
    _miniMapHideTimer = Timer(config.hideDelay, () {
      if (!mounted) return;
      setState(() => _showMiniMap = false);
    });
  }

  bool _isContentScrollable() {
    final hScrollable = _horizontalScrollController.hasClients &&
        _horizontalScrollController.position.maxScrollExtent > 0;
    final vScrollable = _verticalScrollController.hasClients &&
        _verticalScrollController.position.maxScrollExtent > 0;
    return hScrollable || vScrollable;
  }

  DateAndTimeSlot _getSlotKey(DateTime date, TimeSlot timeSlot) {
    return DateAndTimeSlot(date: date, timeSlot: timeSlot);
  }

  SlotState _getSlotState(DateTime date, TimeSlot timeSlot) {
    final key = _getSlotKey(date, timeSlot);
    return widget.slotStates[key] ?? SlotState.unselected();
  }

  void _handleSlotTap(DateTime date, TimeSlot timeSlot) {
    final slot = _getSlotKey(date, timeSlot);
    final currentState = _getSlotState(date, timeSlot);

    // Toggle between unselected and selected
    SlotState newState;
    if (currentState is SelectedSlotState) {
      newState = SlotState.unselected();
    } else if (currentState is UnselectedSlotState) {
      newState = SlotState.selected();
    } else {
      // Unavailable slots cannot be toggled
      return;
    }

    widget.onSlotTapped?.call(slot, newState);
  }

  List<DateTime> _generateDummyDates() {
    final now = DateTime.now();
    final n = widget.loadingSkeletonDayCount.clamp(1, 366);
    return List.generate(n, (index) {
      return DateTime(now.year, now.month, now.day).add(Duration(days: index));
    });
  }

  List<TimeSlot> _resolveLoadingTimeSlots() {
    if (widget.loadingPlaceholderTimeSlots != null) {
      return widget.loadingPlaceholderTimeSlots!;
    }
    final timeSlots = <TimeSlot>[];
    for (int hour = 8; hour < 20; hour++) {
      timeSlots.add(TimeSlot.fromTime(hour, 0));
      timeSlots.add(TimeSlot.fromTime(hour, 30));
    }
    return timeSlots;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.theme ?? const SlotSelectionGridThemeData();

    return SlotSelectionGridTheme(
      data: themeData,
      child: AnimatedSwitcher(
        duration: _animationDuration,
        child:
            widget.loading && widget.dates.isEmpty && widget.timeSlots.isEmpty
                ? _buildLoadingView(context)
                : Column(
                    key: const ValueKey('content'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: widget.headerColor ?? Colors.transparent,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.titleBuilder != null)
                              widget.titleBuilder!(context),
                            _buildHeader(context),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.showTimeLabels) _buildTimeColumn(),
                            Expanded(child: _buildSlotGrid()),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (widget.buildOriginSlotCell != null)
          Container(
            constraints: BoxConstraints(
              minWidth: _timeColumnWidth,
              maxWidth: _timeColumnWidth,
              minHeight: widget.cellSize,
              maxHeight: widget.cellSize,
            ),
            child: Center(child: widget.buildOriginSlotCell!(context)),
          )
        else
          SizedBox(height: widget.cellSize, width: _timeColumnWidth),
        if (widget.dateHeaderBuilder != null) _buildDateHeader(context),
      ],
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: SingleChildScrollView(
          controller: _headerScrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            children: widget.dates.map((date) {
              return SizedBox(
                width: widget.cellSize,
                child: Center(
                  child: widget.dateHeaderBuilder?.call(
                    context,
                    date,
                    widget.loading,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: _timeColumnWidth,
      child: SingleChildScrollView(
        controller: _timeColumnScrollController,
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: widget.timeSlots.map((timeSlot) {
            return SizedBox(
              width: _timeColumnWidth,
              height: widget.cellSize,
              child: Center(
                child: widget.slotTitleBuilder?.call(
                  context,
                  timeSlot,
                  widget.loading,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSlotGrid() {
    final gridContent = Column(
      children: widget.timeSlots.map((timeSlot) {
        return Row(
          children: widget.dates.map((date) {
            final state = _getSlotState(date, timeSlot);
            final slot = _getSlotKey(date, timeSlot);
            Widget? customWidget;
            if (state is SelectedSlotState &&
                widget.buildSelectedSlotCell != null) {
              customWidget = widget.buildSelectedSlotCell!(
                slot,
                widget.loading,
              );
            } else if (state is UnselectedSlotState &&
                widget.buildUnselectedSlotCell != null) {
              customWidget = widget.buildUnselectedSlotCell!(
                slot,
                widget.loading,
              );
            } else if (state is UnavailableSlotState &&
                widget.buildUnavailableSlotCell != null) {
              customWidget = widget.buildUnavailableSlotCell!(
                slot,
                widget.loading,
              );
            }
            if (customWidget != null) {
              return SizedBox(
                width: widget.cellSize,
                height: widget.cellSize,
                child: GestureDetector(
                  onTap: widget.loading
                      ? null
                      : state is UnavailableSlotState
                          ? () => widget.onUnavailableSlotTapped?.call(
                                slot,
                                state.reason,
                              )
                          : () => _handleSlotTap(date, timeSlot),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: widget.cellSize,
                      maxWidth: widget.cellSize,
                      minHeight: widget.cellSize,
                      maxHeight: widget.cellSize,
                    ),
                    child: customWidget,
                  ),
                ),
              );
            }
            return SizedBox(
              width: widget.cellSize,
              child: SlotCell(
                state: state,
                size: widget.cellSize,
                onTap: state is UnavailableSlotState || widget.loading
                    ? null
                    : () => _handleSlotTap(date, timeSlot),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );

    final scrollableGrid = GestureDetector(
      onPanStart: widget.loading ? null : _handlePanStart,
      onPanUpdate: widget.loading ? null : _handlePanUpdate,
      onPanEnd: widget.loading ? null : _handlePanEnd,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: gridContent,
        ),
      ),
    );

    // Wrap in Stack to add shadows
    return Stack(
      children: [
        scrollableGrid,
        // Left shadow
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: _animationDuration,
            width: _showLeftShadow ? _shadowWidth : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  widget.innerShadowColor ??
                      Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Right shadow
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: _animationDuration,
            width: _showRightShadow ? _shadowWidth : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  widget.innerShadowColor ??
                      Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Top shadow
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: _animationDuration,
            height: _showTopShadow ? _shadowWidth : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.innerShadowColor ??
                      Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom shadow
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: _animationDuration,
            height: _showBottomShadow ? _shadowWidth : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  widget.innerShadowColor ??
                      Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        _buildMiniMap(),
      ],
    );
  }

  /// Safe to read [ScrollPosition.pixels] / [ScrollPosition.viewportDimension].
  /// why: [ScrollController.hasClients] is true before layout; those getters assert non-null.
  bool _scrollMetricsReady(ScrollController controller) {
    if (!controller.hasClients) return false;
    final ScrollPosition p = controller.position;
    return p.hasPixels && p.hasViewportDimension;
  }

  /// Lightweight scroll minimap. Visible only while the user is scrolling and
  /// for [_miniMapHideDelay] afterwards. Uses a single [CustomPainter] inside
  /// an [AnimatedBuilder] driven by both scroll controllers, so it repaints
  /// without rebuilding the rest of the tree.
  Widget _buildMiniMap() {
    final config = widget.minimapConfiguration;

    if (!config.enabled) return const SizedBox.shrink();

    final double gridWidth = widget.dates.length * widget.cellSize;
    final double gridHeight = widget.timeSlots.length * widget.cellSize;

    if (gridWidth <= 0 || gridHeight <= 0) return const SizedBox.shrink();

    final double longest = gridWidth > gridHeight ? gridWidth : gridHeight;
    final double scale = config.maxDimension / longest;
    final double miniW = gridWidth * scale;
    final double miniH = gridHeight * scale;

    return Positioned(
      right: config.positionRight,
      bottom: config.positionBottom,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _showMiniMap ? 1.0 : 0.0,
          duration: config.fadeDuration,
          child: Container(
            width: miniW + config.internalPadding * 2,
            height: miniH + config.internalPadding * 2,
            padding: EdgeInsets.all(config.internalPadding),
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(config.borderRadius),
            ),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _horizontalScrollController,
                _verticalScrollController,
              ]),
              builder: (context, _) {
                final hasH = _scrollMetricsReady(_horizontalScrollController);
                final hasV = _scrollMetricsReady(_verticalScrollController);

                final double offsetX =
                    hasH ? _horizontalScrollController.position.pixels : 0.0;
                final double offsetY =
                    hasV ? _verticalScrollController.position.pixels : 0.0;
                final double viewportW = hasH
                    ? _horizontalScrollController.position.viewportDimension
                        .clamp(0.0, gridWidth)
                    : gridWidth;
                final double viewportH = hasV
                    ? _verticalScrollController.position.viewportDimension
                        .clamp(0.0, gridHeight)
                    : gridHeight;

                return CustomPaint(
                  size: Size(miniW, miniH),
                  painter: _MiniMapPainter(
                    gridWidth: gridWidth,
                    gridHeight: gridHeight,
                    viewportX: offsetX,
                    viewportY: offsetY,
                    viewportW: viewportW,
                    viewportH: viewportH,
                    dotColor: config.dotColor,
                    thumbBorderColor: config.thumbBorderColor,
                    thumbFillColor: config.thumbFillColor,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    final dates = widget.dates.isEmpty ? _generateDummyDates() : widget.dates;
    final timeSlots = widget.timeSlots.isEmpty
        ? _resolveLoadingTimeSlots()
        : widget.timeSlots;

    return Column(
      key: const ValueKey('loading'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: widget.headerColor ?? Colors.transparent,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.titleBuilder != null) widget.titleBuilder!(context),
              _buildLoadingHeader(context, dates),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTimeLabels) _buildLoadingTimeColumn(timeSlots),
              Expanded(child: _buildLoadingSlotGrid(dates, timeSlots)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingHeader(BuildContext context, List<DateTime> dummyDates) {
    return Row(
      children: [
        if (widget.buildOriginSlotCell != null)
          Container(
            constraints: BoxConstraints(
              minWidth: _timeColumnWidth,
              maxWidth: _timeColumnWidth,
              minHeight: widget.cellSize,
              maxHeight: widget.cellSize,
            ),
            child: Center(child: widget.buildOriginSlotCell!(context)),
          )
        else
          SizedBox(height: widget.cellSize, width: _timeColumnWidth),
        if (widget.dateHeaderBuilder != null)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: SingleChildScrollView(
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: dummyDates.map((date) {
                    return SizedBox(
                      width: widget.cellSize,
                      child: Center(
                        child: widget.dateHeaderBuilder!(
                          context,
                          date,
                          widget.loading,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingTimeColumn(List<TimeSlot> dummyTimeSlots) {
    return SizedBox(
      width: _timeColumnWidth,
      child: SingleChildScrollView(
        controller: _timeColumnScrollController,
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: dummyTimeSlots.map((timeSlot) {
            return SizedBox(
              width: _timeColumnWidth,
              height: widget.cellSize,
              child: Center(
                child: widget.slotTitleBuilder?.call(
                  context,
                  timeSlot,
                  widget.loading,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingSlotGrid(
    List<DateTime> dummyDates,
    List<TimeSlot> dummyTimeSlots,
  ) {
    final gridContent = Column(
      children: dummyTimeSlots.map((timeSlot) {
        return Row(
          children: dummyDates.map((date) {
            final slot = _getSlotKey(date, timeSlot);
            Widget? customWidget;

            // Use unselected slot cell builder if available
            if (widget.buildUnselectedSlotCell != null) {
              customWidget = widget.buildUnselectedSlotCell!(
                slot,
                widget.loading,
              );
            }

            Widget cellWidget;
            if (customWidget != null) {
              cellWidget = Container(
                constraints: BoxConstraints(
                  minWidth: widget.cellSize,
                  maxWidth: widget.cellSize,
                  minHeight: widget.cellSize,
                  maxHeight: widget.cellSize,
                ),
                child: customWidget,
              );
            } else {
              cellWidget = SlotCell(
                state: SlotState.unavailable(
                  reason: widget.loadingUnavailableReason,
                ),
                size: widget.cellSize,
                onTap: null,
              );
            }

            return SizedBox(
              width: widget.cellSize,
              height: widget.cellSize,
              child: cellWidget,
            );
          }).toList(),
        );
      }).toList(),
    );

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: gridContent,
        ),
      ),
    );
  }
}

/// Paints a fixed-pitch dot pattern as background texture and the visible
/// viewport rectangle on top. Dot count is derived from the minimap canvas
/// size (not slot counts), so the texture stays consistent regardless of how
/// many dates / time slots the grid actually holds.
class _MiniMapPainter extends CustomPainter {
  _MiniMapPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.viewportX,
    required this.viewportY,
    required this.viewportW,
    required this.viewportH,
    required this.dotColor,
    required this.thumbBorderColor,
    required this.thumbFillColor,
  });

  final double gridWidth;
  final double gridHeight;
  final double viewportX;
  final double viewportY;
  final double viewportW;
  final double viewportH;
  final Color dotColor;
  final Color thumbBorderColor;
  final Color thumbFillColor;

  static const double _dotPitch = 5.0;
  static const double _dotRadius = 0.6;

  @override
  void paint(Canvas canvas, Size size) {
    if (gridWidth <= 0 || gridHeight <= 0) return;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = dotColor;

    // why: center the dot grid within the canvas so dots aren't clipped at
    // either edge. drawPoints is faster than per-dot drawCircle calls.
    final int cols = (size.width / _dotPitch).floor();
    final int rows = (size.height / _dotPitch).floor();
    final double offsetX = (size.width - (cols - 1) * _dotPitch) / 2;
    final double offsetY = (size.height - (rows - 1) * _dotPitch) / 2;

    for (int r = 0; r < rows; r++) {
      final double cy = offsetY + r * _dotPitch;
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(offsetX + c * _dotPitch, cy),
          _dotRadius,
          dotPaint,
        );
      }
    }

    final double scaleX = size.width / gridWidth;
    final double scaleY = size.height / gridHeight;

    final double thumbLeft = (viewportX * scaleX).clamp(0.0, size.width);
    final double thumbTop = (viewportY * scaleY).clamp(0.0, size.height);
    final double thumbW = (viewportW * scaleX).clamp(
      0.0,
      size.width - thumbLeft,
    );
    final double thumbH = (viewportH * scaleY).clamp(
      0.0,
      size.height - thumbTop,
    );
    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(thumbLeft, thumbTop, thumbW, thumbH),
      const Radius.circular(2),
    );

    canvas.drawRRect(thumbRect, Paint()..color = thumbFillColor);
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = thumbBorderColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter old) {
    return old.gridWidth != gridWidth ||
        old.gridHeight != gridHeight ||
        old.viewportX != viewportX ||
        old.viewportY != viewportY ||
        old.viewportW != viewportW ||
        old.viewportH != viewportH ||
        old.dotColor != dotColor ||
        old.thumbBorderColor != thumbBorderColor ||
        old.thumbFillColor != thumbFillColor;
  }
}
