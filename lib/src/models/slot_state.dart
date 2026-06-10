/// Sealed base class representing the three possible states of a grid cell.
///
/// Use the factory constructors to create instances:
/// ```dart
/// SlotState.unselected()
/// SlotState.selected()
/// SlotState.unavailable(reason: 'Already booked')
/// ```
///
/// Exhaustive matching is supported via Dart's `switch` expression:
/// ```dart
/// final label = switch (state) {
///   UnselectedSlotState() => 'Free',
///   SelectedSlotState()   => 'Selected',
///   UnavailableSlotState(reason: final r) => r,
/// };
/// ```
sealed class SlotState {
  const SlotState();

  /// Creates an [UnselectedSlotState] — the default for cells absent from
  /// [SlotSelectionGrid.slotStates].
  factory SlotState.unselected() => UnselectedSlotState();

  /// Creates a [SelectedSlotState]. Tapping the cell toggles it back to
  /// [UnselectedSlotState] via [SlotSelectionGrid.onSlotTapped].
  factory SlotState.selected() => SelectedSlotState();

  /// Creates an [UnavailableSlotState] with the given [reason].
  ///
  /// Tapping the cell fires [SlotSelectionGrid.onUnavailableSlotTapped] with [reason].
  factory SlotState.unavailable({required String reason}) =>
      UnavailableSlotState(reason: reason);
}

/// A slot that has not yet been selected by the user.
///
/// Tapping a cell in this state fires [SlotSelectionGrid.onSlotTapped] with a
/// [SelectedSlotState] as the new state.
class UnselectedSlotState extends SlotState {
  const UnselectedSlotState();
}

/// A slot that has been selected by the user.
///
/// Tapping a cell in this state fires [SlotSelectionGrid.onSlotTapped] with an
/// [UnselectedSlotState] as the new state.
class SelectedSlotState extends SlotState {
  const SelectedSlotState();
}

/// A slot that cannot be selected (e.g. already booked, outside working hours).
///
/// Tapping a cell in this state fires [SlotSelectionGrid.onUnavailableSlotTapped]
/// with [reason]. The cell is rendered with the unavailable style and does not
/// participate in toggle logic.
class UnavailableSlotState extends SlotState {
  const UnavailableSlotState({required this.reason});

  /// Human-readable explanation passed to [SlotSelectionGrid.onUnavailableSlotTapped].
  final String reason;
}
