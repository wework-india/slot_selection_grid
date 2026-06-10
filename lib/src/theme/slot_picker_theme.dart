import 'package:flutter/material.dart';

/// Visual styling applied to default [SlotCell] widgets.
///
/// **Only takes effect when the corresponding `build*SlotCell` builder on
/// [SlotPicker] is `null` for a given state.** If you supply
/// `buildSelectedSlotCell`, `buildUnselectedSlotCell`, or
/// `buildUnavailableSlotCell`, those builders fully replace the default
/// [SlotCell] for their respective state and the related [SlotCellStyle]
/// fields are ignored.
///
/// Pass an instance via [SlotPickerThemeData.cellStyle], or supply it directly
/// to [SlotCell.style] to override individual cells.
///
/// ```dart
/// // Only effective when NO custom builder is passed for that state:
/// SlotPicker(
///   theme: const SlotPickerThemeData(
///     cellStyle: SlotCellStyle(
///       selectedBackgroundColor: Color(0xFF1976D2),
///       selectedBorderColor:     Color(0xFF1976D2),
///       selectedIconColor:       Colors.white,
///     ),
///   ),
/// )
/// ```
@immutable
class SlotCellStyle {
  /// Creates a [SlotCellStyle]. All parameters have sensible Material defaults.
  const SlotCellStyle({
    this.selectedBackgroundColor = const Color(0xFF4CAF50),
    this.selectedBorderColor = const Color(0xFF4CAF50),
    this.unavailableBackgroundColor = const Color(0xFFE0E0E0),
    this.unavailableBorderColor = const Color(0xFFBDBDBD),
    this.unselectedBackgroundColor = Colors.white,
    this.unselectedBorderColor = const Color(0xFFE0E0E0),
    this.selectedIconColor = Colors.white,
    this.unselectedIconColor = const Color(0xFF9E9E9E),
    this.stripeColor = const Color(0xFFBDBDBD),
    this.iconSize = 20,
  });

  /// Background fill for [SelectedSlotState] cells. Default: `Color(0xFF4CAF50)`.
  final Color selectedBackgroundColor;

  /// Border color for [SelectedSlotState] cells. Default: `Color(0xFF4CAF50)`.
  final Color selectedBorderColor;

  /// Background fill for [UnavailableSlotState] cells. Default: `Color(0xFFE0E0E0)`.
  final Color unavailableBackgroundColor;

  /// Border color for [UnavailableSlotState] cells. Default: `Color(0xFFBDBDBD)`.
  final Color unavailableBorderColor;

  /// Background fill for [UnselectedSlotState] cells. Default: `Colors.white`.
  final Color unselectedBackgroundColor;

  /// Border color for [UnselectedSlotState] cells. Default: `Color(0xFFE0E0E0)`.
  final Color unselectedBorderColor;

  /// Icon color for the checkmark on [SelectedSlotState] cells. Default: `Colors.white`.
  final Color selectedIconColor;

  /// Icon color for the add (+) icon on [UnselectedSlotState] cells. Default: `Color(0xFF9E9E9E)`.
  final Color unselectedIconColor;

  /// Color of the diagonal stripe pattern on [UnavailableSlotState] cells. Default: `Color(0xFFBDBDBD)`.
  final Color stripeColor;

  /// Size of the cell icon in logical pixels. Default: `20`.
  final double iconSize;

  /// A [SlotCellStyle] with all default values.
  static const SlotCellStyle defaults = SlotCellStyle();
}

/// Theme data for [SlotPicker]; controls the appearance of default [SlotCell]
/// widgets when no custom cell builders are supplied.
///
/// Resolved by [SlotPickerTheme.of] so all cells in the subtree share the same
/// style without requiring each cell to receive it explicitly.
@immutable
class SlotPickerThemeData {
  /// Creates a [SlotPickerThemeData] with the given [cellStyle].
  const SlotPickerThemeData({this.cellStyle = SlotCellStyle.defaults});

  /// Visual style applied to default [SlotCell] rendering.
  final SlotCellStyle cellStyle;

  /// Returns a copy with an optionally overridden [cellStyle].
  SlotPickerThemeData copyWith({SlotCellStyle? cellStyle}) {
    return SlotPickerThemeData(cellStyle: cellStyle ?? this.cellStyle);
  }
}

/// [InheritedWidget] that provides [SlotPickerThemeData] to all [SlotCell]
/// descendants inside the [SlotPicker] subtree.
///
/// Obtain the nearest theme with [SlotPickerTheme.of], which falls back to
/// [SlotPickerThemeData] defaults when no ancestor [SlotPickerTheme] is found.
class SlotPickerTheme extends InheritedWidget {
  /// Creates a [SlotPickerTheme] that provides [data] to its [child] subtree.
  const SlotPickerTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme data available to all [SlotCell] descendants.
  final SlotPickerThemeData data;

  /// Returns the nearest [SlotPickerThemeData] or the default if none is found.
  ///
  /// Establishes a dependency so the widget rebuilds when the theme changes.
  static SlotPickerThemeData of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SlotPickerTheme>();
    return scope?.data ?? const SlotPickerThemeData();
  }

  /// Returns the nearest [SlotPickerThemeData] or `null` if no ancestor
  /// [SlotPickerTheme] exists. Does not establish a dependency.
  static SlotPickerThemeData? maybeOf(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<SlotPickerTheme>();
    return scope?.data;
  }

  @override
  bool updateShouldNotify(SlotPickerTheme oldWidget) => data != oldWidget.data;
}
