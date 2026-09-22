import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/widgets/device_to_server_table.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceToServerTable Tests', () {
    testWidgets('renders rows safely even when asset fields (repairsDone, faultyItems, etc.) are null', (WidgetTester tester) async {
      final List<ExRegister> assets = [
        ExRegister.fromJson({
          '_id': '1',
          'id': '1',
          'rfidRef': 'RFID-001',
          'location': 'Location 1',
          'area': 'Area 1',
          'deckLevel': 'Level 1',
          'zone': 'Zone 1',
          'eqpmtCatg': 'Electrical',
          'eqpmtTag': 'TAG-001',
          'description': 'Motor 1',
          'manufacturer': 'ABB',
          'protectionType': ['Ex d'],
          'equipmentGasGroup': ['IIB'],
          'equipmentTClass': ['T4'],
          'faultyItems': null,
          'inspectionStatus': 'Green',
          'repairsDone': null, // was crashing before
          'existingFaults': null,
          'currentStatus': 'Active',
          'locationGasGroup': ['IIA'],
          'locationTClass': ['T4'],
          'locationIpRating': ['IP66'],
        }),
        ExRegister.fromJson({
          '_id': '2',
          'id': '2',
          'rfidRef': 'RFID-002',
          'location': 'Location 2',
          'area': 'Area 2',
          'deckLevel': null,
          'zone': 'Zone 2',
          'eqpmtCatg': 'Instrumentation',
          'eqpmtTag': 'TAG-002',
          'description': 'Transmitter',
          'manufacturer': null,
          'protectionType': null,
          'equipmentGasGroup': null,
          'equipmentTClass': null,
          'faultyItems': 'Fault A',
          'inspectionStatus': '',
          'repairsDone': 'Replaced gasket',
          'existingFaults': 'Corrosion',
          'currentStatus': '',
          'locationGasGroup': ['IIA'],
          'locationTClass': ['T4'],
          'locationIpRating': ['IP66'],
        }),
      ];

      final headers = [
        "RFID Reference",
        "Field Name",
        "Platform",
        "Deck Level",
        "Zone",
        "Discipline",
        "Equipment Tag Number",
        "Equipment Description",
        "Manufacturer",
        "Equipment Protection",
        "Inspection Faults",
        "Inspection Status",
        "Completed Repairs",
        "Existing Faults",
        "Current Status"
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              height: 800,
              child: DeviceToServerTable(
                assets: assets,
                headers: headers,
                onRowSelected: (index, selection) {},
                sortOrder: 'descending',
                selectedFilters: const [],
                collectionSelectedFilter: const {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify records are rendered without crashing
      expect(find.text('RFID-001'), findsOneWidget);
      expect(find.text('RFID-002'), findsOneWidget);
      expect(find.text('TAG-001'), findsOneWidget);
      expect(find.text('TAG-002'), findsOneWidget);
      expect(find.text('Motor 1'), findsOneWidget);
    });
  });
}
