import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:slot_selection_grid/slot_selection_grid.dart';
import 'package:slot_selection_grid_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('example app shows slot picker', (WidgetTester tester) async {
    await tester.pumpWidget(const SlotPickerExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Book a slot'), findsOneWidget);
    expect(find.byType(SlotPicker), findsOneWidget);
  });
}
