import 'package:flutter/material.dart';

/// Configuration for the scroll-position minimap overlay in [SlotSelectionGrid].
///
/// The minimap is a small floating thumbnail that appears in the bottom-right
/// corner of the grid while the user is scrolling. It shows a dot-grid
/// representation of the full grid and a semi-transparent rectangle (thumb)
/// indicating the currently visible portion. It fades out automatically after
/// [hideDelay].
///
/// ```dart
/// SlotSelectionGrid(
///   minimapConfiguration: const MinimapConfiguration(
///     enabled: true,
///     maxDimension: 80.0,
///     backgroundColor: Color(0x99000000),
///   ),
/// )
/// ```
///
/// Disable entirely with `MinimapConfiguration(enabled: false)`.
class MinimapConfiguration {
  /// Creates a minimap configuration.
  ///
  /// All parameters have defaults tuned for a 72px overlay in the
  /// bottom-right corner that fades out one second after scrolling stops.
  /// Pass `enabled: false` to suppress the minimap entirely.
  const MinimapConfiguration({
    this.enabled = true,
    this.maxDimension = 72.0,
    this.hideDelay = const Duration(milliseconds: 1000),
    this.fadeDuration = const Duration(milliseconds: 200),
    this.positionRight = 8.0,
    this.positionBottom = 8.0,
    this.internalPadding = 4.0,
    this.backgroundColor = const Color(0x73000000),
    this.borderRadius = 6.0,
    this.dotColor = const Color(0xA6FFFFFF),
    this.thumbBorderColor = const Color(0xF2FFFFFF),
    this.thumbFillColor = const Color(0x1AFFFFFF),
  });

  /// Whether the minimap overlay is shown while scrolling.
  final bool enabled;

  /// Maximum dimension (width or height) of the minimap in logical pixels.
  /// The minimap is scaled so its longest side equals this value.
  final double maxDimension;

  /// How long after the last scroll event before the minimap fades out.
  final Duration hideDelay;

  /// Duration of the fade-in / fade-out animation.
  final Duration fadeDuration;

  /// Distance from the right edge of the grid.
  final double positionRight;

  /// Distance from the bottom edge of the grid.
  final double positionBottom;

  /// Padding inside the minimap container, between the border and the canvas.
  final double internalPadding;

  /// Background color of the minimap container.
  /// Default: black at 45% opacity — `Color(0x73000000)`.
  final Color backgroundColor;

  /// Corner radius of the minimap container.
  final double borderRadius;

  /// Color of the dot-grid texture drawn on the minimap canvas.
  /// Default: white at 65% opacity — `Color(0xA6FFFFFF)`.
  final Color dotColor;

  /// Border color of the viewport thumb rectangle.
  /// Default: white at 95% opacity — `Color(0xF2FFFFFF)`.
  final Color thumbBorderColor;

  /// Fill color of the viewport thumb rectangle.
  /// Default: white at 10% opacity — `Color(0x1AFFFFFF)`.
  final Color thumbFillColor;
}
