import 'package:flutter_test/flutter_test.dart';
import 'package:slot_selection_grid_example/main.dart';

void main() {
  testWidgets('example loads slot picker screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SlotPickerExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Book a slot'), findsOneWidget);
  });
}
