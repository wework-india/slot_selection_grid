import 'package:flutter/material.dart';

import '../models/slot_state.dart';
import '../theme/slot_selection_grid_theme.dart';

/// A single cell in the [SlotSelectionGrid] grid.
///
/// Renders a square widget whose appearance depends on [state]:
/// - [UnselectedSlotState] — white background with an add (+) icon.
/// - [SelectedSlotState] — colored background with a checkmark.
/// - [UnavailableSlotState] — striped background via [StripePainter].
///
/// Colors and icon sizes are read from the ambient [SlotSelectionGridTheme] unless
/// overridden by [style]. [SlotSelectionGrid] uses [SlotCell] as its default cell
/// renderer; swap it out with the `build*SlotCell` builder callbacks when you
/// need a custom look.
class SlotCell extends StatelessWidget {
  /// Creates a [SlotCell] with the given [state].
  const SlotCell({
    super.key,
    required this.state,
    this.onTap,
    this.size = 50.0,
    this.style,
  });

  /// The current slot state that drives the visual appearance.
  final SlotState state;

  /// Called when the cell is tapped, in any [state]. `null` disables
  /// interaction (e.g. while the grid is in loading mode).
  final VoidCallback? onTap;

  /// Width and height of the cell in logical pixels. Default: `50.0`.
  final double size;

  /// Per-cell style override. When `null`, the style is resolved from the
  /// nearest [SlotSelectionGridTheme] ancestor.
  final SlotCellStyle? style;

  @override
  Widget build(BuildContext context) {
    final s = style ?? SlotSelectionGridTheme.of(context).cellStyle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: _backgroundColor(s),
          border: Border.all(color: _borderColor(s), width: 1.0),
        ),
        child: _buildContent(s),
      ),
    );
  }

  Color _backgroundColor(SlotCellStyle s) {
    return switch (state) {
      SelectedSlotState() => s.selectedBackgroundColor,
      UnavailableSlotState() => s.unavailableBackgroundColor,
      UnselectedSlotState() => s.unselectedBackgroundColor,
    };
  }

  Color _borderColor(SlotCellStyle s) {
    return switch (state) {
      SelectedSlotState() => s.selectedBorderColor,
      UnavailableSlotState() => s.unavailableBorderColor,
      UnselectedSlotState() => s.unselectedBorderColor,
    };
  }

  Widget _buildContent(SlotCellStyle s) {
    return switch (state) {
      SelectedSlotState() => Icon(
          Icons.check,
          color: s.selectedIconColor,
          size: s.iconSize,
        ),
      UnavailableSlotState() => CustomPaint(
          painter: StripePainter(stripeColor: s.stripeColor),
          child: const SizedBox.expand(),
        ),
      UnselectedSlotState() => Icon(
          Icons.add,
          color: s.unselectedIconColor,
          size: s.iconSize,
        ),
    };
  }
}

/// [CustomPainter] that draws a diagonal stripe pattern for [UnavailableSlotState]
/// cells.
///
/// Stripes are drawn at 45 degrees with a fixed 4 px pitch and 1 px stroke.
/// The [stripeColor] is typically sourced from [SlotCellStyle.stripeColor].
class StripePainter extends CustomPainter {
  /// Creates a [StripePainter] with the given [stripeColor].
  StripePainter({required this.stripeColor});

  /// Color of the diagonal stripe lines.
  final Color stripeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 4.0;
    final path = Path();

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      path.moveTo(i, 0);
      path.lineTo(i + size.height, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StripePainter oldDelegate) =>
      oldDelegate.stripeColor != stripeColor;
}
