import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/multi_select_dropdown.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/searchable_dropdown.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Protection Standard and MultiSelect Dropdown Field Tests', () {
    test('EquipmentTagRequest initializes protectionStd as empty or null', () {
      final request = EquipmentTagRequest(
        location: 'Platform A',
        area: 'Deck 1',
        zone: 'Zone 1',
        locationGasGroup: [],
        locationTClass: [],
        locationIpRating: [],
        areaClassDrawAttach: [],
        areaClassDrawNo: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawAttachOrgName: [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawNo: [],
        locationId: 'loc1',
        deckLevel: 'Level 1',
        eqpmtCatg: 'Electrical',
        description: 'Motor',
        atexCatg: [],
        epl: [],
        protectionStd: null,
        protectionType: [],
        equipmentGasGroup: [],
        equipmentTClass: [],
        equipmentIpRating: [],
        defectOtherRequirements: [],
        isActive: true,
        yesNoSelection: const {},
        inspectionChecklistType: const [],
        locationTAmbient: '',
      );

      expect(request.protectionStd, isNull);
    });

    testWidgets('SearchableDropdown displays "Select item" hint when value is null', (WidgetTester tester) async {
      String? selectedValue;
      final standards = ['IEC', 'NEC', 'ATEX', 'Not Applicable'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchableDropdown(
              value: selectedValue,
              items: standards,
              hint: 'Select item',
              onChanged: (val) {
                selectedValue = val;
              },
              isEditMode: true,
              isNotApplicable: false,
            ),
          ),
        ),
      );

      // Verify "Select item" is displayed as the placeholder hint
      expect(find.text('Select item'), findsOneWidget);
      // Verify no standard option is pre-selected
      expect(find.text('IEC'), findsNothing);
      expect(find.text('NEC'), findsNothing);
      expect(find.text('ATEX'), findsNothing);
    });

    testWidgets('SearchableDropdown displays item name after selecting from list', (WidgetTester tester) async {
      String? selectedValue;
      final standards = ['IEC', 'NEC', 'ATEX', 'Not Applicable'];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SearchableDropdown(
                  value: selectedValue,
                  items: standards,
                  hint: 'Select item',
                  onChanged: (val) {
                    setState(() {
                      selectedValue = val;
                    });
                  },
                  isEditMode: true,
                  isNotApplicable: false,
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Select item'), findsOneWidget);

      // Open the dropdown menu by tapping the dropdown
      await tester.tap(find.text('Select item'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Tap on 'NEC' option
      expect(find.text('NEC'), findsWidgets);
      await tester.tap(find.text('NEC').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify selected value is updated and displayed
      expect(selectedValue, equals('NEC'));
      expect(find.text('NEC'), findsOneWidget);
      expect(find.text('Select item'), findsNothing);
    });

    testWidgets('MultiSelectDropdown for EPL displays items and allows selection', (WidgetTester tester) async {
      final allEPLs = [
        'Ga',
        'Gb',
        'Gc',
        'Da',
        'Db',
        'Dc',
        'Ma',
        'Mb',
        'Class I, Div 1',
        'Class I, Div 2',
        'Class II, Div 1',
        'Class II, Div 2',
        'Class III, Div 1',
        'Class III, Div 2',
        'Zone 0',
        'Zone 1',
        'Zone 2',
        'Zone 20',
        'Zone 21',
        'Zone 22',
        'Not Available',
        'Not Applicable',
      ];
      List<String> selected = ['Not Available'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MultiSelectDropdown(
                  label: 'EPL',
                  items: allEPLs,
                  selectedItems: selected,
                  isSubmitting: false,
                  selectedItemString: selected.join(', '),
                  onChanged: (val) {
                    setState(() {
                      selected = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Not Available'), findsOneWidget);

      // Tap dropdown to open overlay
      await tester.tap(find.text('Not Available'));
      await tester.pumpAndSettle();

      // Verify selected items count header
      expect(find.text('Selected(1)'), findsOneWidget);
      expect(find.text('Ga'), findsOneWidget);
      expect(find.text('Gb'), findsOneWidget);

      // Select 'Ga'
      await tester.tap(find.text('Ga'));
      await tester.pumpAndSettle();

      // Apply selection
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(selected.contains('Ga'), isTrue);
      expect(selected.contains('Not Available'), isTrue);
    });

    testWidgets('MultiSelectDropdown for Protection Type displays items and allows selection', (WidgetTester tester) async {
      final allProtectionTypes = [
        'Ex d',
        'Ex db',
        'Ex e',
        'Ex ia',
        'Explosionproof (XP)',
        'Intrinsically Safe (IS)',
        'Not Available',
        'Not Applicable',
        'Others'
      ];
      List<String> selected = ['Not Available'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MultiSelectDropdown(
                  label: 'Protection Type',
                  items: allProtectionTypes,
                  selectedItems: selected,
                  isSubmitting: false,
                  selectedItemString: selected.join(', '),
                  onChanged: (val) {
                    setState(() {
                      selected = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Not Available'), findsOneWidget);

      // Tap dropdown to open overlay
      await tester.tap(find.text('Not Available'));
      await tester.pumpAndSettle();

      expect(find.text('Selected(1)'), findsOneWidget);
      expect(find.text('Ex d'), findsOneWidget);
      expect(find.text('Ex ia'), findsOneWidget);

      // Select 'Ex d'
      await tester.tap(find.text('Ex d'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(selected.contains('Ex d'), isTrue);
    });

    testWidgets('MultiSelectDropdown for ATEX Category displays items and allows selection', (WidgetTester tester) async {
      final allAtexCategories = [
        '1G',
        '2G',
        '3G',
        '1D',
        '2D',
        '3D',
        'M1',
        'M2',
        'Not Available',
        'Not Applicable',
      ];
      List<String> selected = ['Not Available'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MultiSelectDropdown(
                  label: 'Atex Category (if applicable)',
                  items: allAtexCategories,
                  selectedItems: selected,
                  isSubmitting: false,
                  selectedItemString: selected.join(', '),
                  onChanged: (val) {
                    setState(() {
                      selected = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Not Available'), findsOneWidget);

      // Tap dropdown to open overlay
      await tester.tap(find.text('Not Available'));
      await tester.pumpAndSettle();

      expect(find.text('Selected(1)'), findsOneWidget);
      expect(find.text('1G'), findsOneWidget);
      expect(find.text('2G'), findsOneWidget);

      // Select '1G'
      await tester.tap(find.text('1G'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(selected.contains('1G'), isTrue);
    });
  });
}
