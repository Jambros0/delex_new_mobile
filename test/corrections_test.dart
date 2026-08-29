import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/searchable_dropdown.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchableDropdown Widget Tests', () {
    testWidgets('displays items and allows selecting', (WidgetTester tester) async {
      String? selectedValue;
      final items = ['Option A', 'Option B', 'Option C'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchableDropdown(
              value: selectedValue,
              items: items,
              onChanged: (val) {
                selectedValue = val;
              },
              isEditMode: true,
              isNotApplicable: false,
            ),
          ),
        ),
      );

      // Verify hint is displayed
      expect(find.text('Select the option'), findsOneWidget);

      // Tap the dropdown to open it
      await tester.tap(find.text('Select the option'));
      await tester.pumpAndSettle();

      // Verify dropdown items are displayed
      expect(find.text('Option A'), findsWidgets);
      expect(find.text('Option B'), findsWidgets);
      expect(find.text('Option C'), findsWidgets);

      // Select an option
      await tester.tap(find.text('Option B').last);
      await tester.pumpAndSettle();

      // Verify onChanged was triggered
      expect(selectedValue, equals('Option B'));
    });

    testWidgets('filters items when typing in search field', (WidgetTester tester) async {
      String? selectedValue;
      final items = ['Alpha', 'Beta', 'Gamma'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchableDropdown(
              value: selectedValue,
              items: items,
              onChanged: (val) {
                selectedValue = val;
              },
              isEditMode: true,
              isNotApplicable: false,
            ),
          ),
        ),
      );

      // Tap to open
      await tester.tap(find.text('Select the option'));
      await tester.pumpAndSettle();

      // Search for 'Bet'
      await tester.enterText(find.byType(TextFormField), 'Bet');
      await tester.pumpAndSettle();

      // 'Beta' should be visible, 'Alpha' and 'Gamma' should not be in the menu options
      expect(find.text('Beta'), findsWidgets);
      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Gamma'), findsNothing);
    });
  });
}
