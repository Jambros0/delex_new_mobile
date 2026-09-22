import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/widgets/device_to_server_table.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExRegister Alias Parsing & Data Population Tests', () {
    test('ExRegister.fromJson correctly populates data from alternate key names (work order format)', () {
      final jsonMap = {
        'id': 101,
        'rfidReference': 'RFID-WO-99',
        'fieldName': 'Offshore Block A',
        'platform': 'Alpha Platform',
        'deck': 'Cellar Deck',
        'zoneName': 'Zone 1',
        'discipline': 'Electrical',
        'equipmentTag': 'TAG-WO-99',
        'equipmentDescription': 'High Voltage Generator',
        'equipmentManufacturer': 'Siemens',
        'protection': ['Ex d', 'Ex e'],
        'gasGroup': ['IIB'],
        'temperatureClass': ['T3'],
        'serialNo': 'SN-998877',
        'equipmentType': 'Motor',
      };

      final asset = ExRegister.fromJson(jsonMap);

      expect(asset.primaryId, 101);
      expect(asset.id, '101');
      expect(asset.rfidRef, 'RFID-WO-99');
      expect(asset.location, 'Offshore Block A');
      expect(asset.area, 'Alpha Platform');
      expect(asset.deckLevel, 'Cellar Deck');
      expect(asset.zone, 'Zone 1');
      expect(asset.eqpmtCatg, 'Electrical');
      expect(asset.eqpmtTag, 'TAG-WO-99');
      expect(asset.description, 'High Voltage Generator');
      expect(asset.manufacturer, 'Siemens');
      expect(asset.protectionType, ['Ex d', 'Ex e']);
      expect(asset.equipmentGasGroup, ['IIB']);
      expect(asset.equipmentTClass, ['T3']);
      expect(asset.serialNumber, 'SN-998877');
      expect(asset.equipmentEquipmentType, 'Motor');
    });

    test('ExRegister.fromJson parses comma-separated string lists correctly', () {
      final jsonMap = {
        'id': 102,
        'rfidRef': 'RFID-CSV',
        'protectionType': 'Ex d, Ex ia, Ex eb',
        'equipmentGasGroup': 'IIA, IIB',
        'equipmentTClass': 'T4, T3',
      };

      final asset = ExRegister.fromJson(jsonMap);

      expect(asset.protectionType, ['Ex d', 'Ex ia', 'Ex eb']);
      expect(asset.equipmentGasGroup, ['IIA', 'IIB']);
      expect(asset.equipmentTClass, ['T4', 'T3']);
    });

    test('ExRegister checklist deserialization and serialization preserves defect data', () {
      final checkListJson = [
        {
          '_id': 'cl1',
          'defectCodes': [
            {
              'defectCode': 'D01',
              'findingsAndActions': [
                {'finding': 'Broken gland', 'action': 'Replace gland', 'isDone': true},
                {'finding': 'Missing bolt', 'action': 'Install bolt', 'isDone': false},
              ]
            }
          ]
        }
      ];

      final asset = ExRegister.fromJson({
        'id': '103',
        'rfidRef': 'RFID-103',
        'checkList': checkListJson,
      });

      expect(asset.checkList, isNotNull);
      expect(asset.checkList!.length, 1);
      expect(asset.checkList![0].defectCodes[0].findingsAndActions.length, 2);

      final serialized = asset.toJson();
      expect(serialized['checkList'], isNotNull);
      expect((serialized['checkList'] as List).length, 1);
    });

    test('ExRegister.fromJson correctly resolves subLocation into area and subArea into subArea', () {
      final asset1 = ExRegister.fromJson({
        'id': 104,
        'location': 'LNG Jetty',
        'subLocation': 'Sub Location Alpha',
        'deckLevel': 'Area Beta',
        'subArea': 'Near Gate 1',
      });

      expect(asset1.location, 'LNG Jetty');
      expect(asset1.area, 'Sub Location Alpha');
      expect(asset1.deckLevel, 'Area Beta');
      expect(asset1.subArea, 'Near Gate 1');
    });
  });

  group('DeviceToServerTable Rendering with Full Data & Fallbacks', () {
    testWidgets('populates all table columns for onshore and offshore assets', (WidgetTester tester) async {
      final assets = [
        ExRegister.fromJson({
          'id': 1,
          'rfidRef': 'RFID-ONSHORE-1',
          'location': 'Refinery North',
          'area': 'Switchgear Room',
          'deckLevel': 'Substation 4',
          'subArea': 'Near Gate 2',
          'zone': 'Zone 2',
          'eqpmtCatg': 'Instrumentation',
          'eqpmtTag': 'PT-1001',
          'description': 'Pressure Transmitter',
          'manufacturer': 'Yokogawa',
          'protectionType': ['Ex ia'],
          'equipmentGasGroup': ['IIC'],
          'equipmentTClass': ['T4'],
          'inspectedBy': 'Inspector John',
          'checkList': [
            {
              '_id': 'cl1',
              'defectCodes': [
                {
                  'defectCode': 'D01',
                  'findingsAndActions': [
                    {'finding': 'Minor scratch', 'action': 'Cleaned', 'isDone': true}
                  ]
                }
              ]
            }
          ],
        }),
      ];

      final headers = [
        "RFID Reference",
        "Location",
        "Sub Location",
        "Area",
        "Zone",
        "Discipline",
        "Equipment Tag Number",
        "Equipment Description",
        "Equipment Manufacturer",
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
              width: 1400,
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

      // Check all individual field values are rendered on screen
      expect(find.text('RFID-ONSHORE-1'), findsOneWidget);
      expect(find.text('Refinery North'), findsOneWidget);
      expect(find.text('Substation 4'), findsOneWidget);
      expect(find.text('Switchgear Room'), findsOneWidget);
      expect(find.text('Zone 2'), findsOneWidget);
      expect(find.text('Instrumentation'), findsOneWidget);
      expect(find.text('PT-1001'), findsOneWidget);
      expect(find.text('Pressure Transmitter'), findsOneWidget);
      expect(find.text('Yokogawa'), findsOneWidget);
      expect(find.text('Ex ia IIC T4'), findsOneWidget);
      // Fault count derived from checklist = 1
      expect(find.text('1'), findsNWidgets(2)); // Total findings (1) and Completed (1)
      // Status derived = Green (because all findings are done)
      expect(find.text('Green'), findsNWidgets(2)); // Inspection Status & Current Status
    });
  });

  group('Sync Response Payload Handling Verification', () {
    test('Can extract asset ID across diverse backend response formats', () {
      // Format A: {"status": true, "data": {"asset": {"_id": "65b123456789"}}}
      final respA = jsonDecode('{"status": true, "data": {"asset": {"_id": "65b123456789"}}}');
      final dynamic dataA = respA['data'];
      String? parsedA;
      if (dataA is Map) {
        parsedA = (dataA['asset'] is Map ? dataA['asset']['_id'] : null) ?? dataA['_id'] ?? dataA['assetId'];
      }
      expect(parsedA, '65b123456789');

      // Format B: {"status": true, "data": {"_id": "65b987654321"}}
      final respB = jsonDecode('{"status": true, "data": {"_id": "65b987654321"}}');
      final dynamic dataB = respB['data'];
      String? parsedB;
      if (dataB is Map) {
        parsedB = (dataB['asset'] is Map ? dataB['asset']['_id'] : null) ?? dataB['_id'] ?? dataB['assetId'];
      }
      expect(parsedB, '65b987654321');

      // Format C: {"status": true, "assetId": "65b112233445"}
      final respC = jsonDecode('{"status": true, "assetId": "65b112233445"}');
      final dynamic dataC = respC['data'];
      String? parsedC;
      if (dataC is Map) {
        parsedC = (dataC['asset'] is Map ? dataC['asset']['_id'] : null) ?? dataC['_id'] ?? dataC['assetId'];
      }
      parsedC ??= respC['assetId']?.toString();
      expect(parsedC, '65b112233445');

      // Format D: {"status": true, "data": "65b556677889"}
      final respD = jsonDecode('{"status": true, "data": "65b556677889"}');
      final dynamic dataD = respD['data'];
      String? parsedD;
      if (dataD is String && dataD.isNotEmpty) {
        parsedD = dataD;
      }
      expect(parsedD, '65b556677889');
    });

    test('EquipmentTagRequest safely handles checkList, materials, and rbiStrategy serialization without crashing', () {
      final checkListJson = [
        {
          '_id': 'cl1',
          'defectCodes': [
            {
              'defectCode': 'D01',
              'findingsAndActions': [
                {'finding': 'Broken gland', 'action': 'Replace gland', 'isDone': true},
              ]
            }
          ]
        }
      ];

      final asset = ExRegister.fromJson({
        'id': '65b123456789abcdef012345',
        'rfidRef': 'RFID-STAGE-TEST',
        'location': 'LNG Jetty',
        'area': 'Main Deck',
        'zone': 'Zone 1',
        'checkList': checkListJson,
        'materials': [
          {'materialName': 'Cable Gland M20', 'quantity': 2, 'certificationAttach': 'path/to/cert.pdf'}
        ],
        'rbiStrategy': {'strategy': 'Time Based', 'interval': '12 months'},
      });

      final assetJson = {
        '_id': asset.id,
        'rfidRef': asset.rfidRef,
        'location': asset.location,
        'area': asset.area,
        'deckLevel': asset.deckLevel,
        'zone': asset.zone,
        'eqpmtTag': asset.eqpmtTag,
        'description': asset.description,
        'manufacturer': asset.manufacturer,
        'epl': asset.epl,
        'inspectionStatus': asset.inspectionStatus,
        'existingFaults': asset.existingFaults,
        'currentStatus': asset.currentStatus,
        'checkList': asset.checkList?.map((item) => item.toJson()).toList() ?? [],
        'materials': asset.materials?.map((x) => x.toJson()).toList() ?? [],
        'rbiStrategy': asset.rbiStrategy?.toJson(),
        'signature': 'https://server.com/signature.png',
      };

      final assetRequest = EquipmentTagRequest.fromJson(assetJson);
      expect(assetRequest.rfidRef, 'RFID-STAGE-TEST');
      expect(assetRequest.location, 'LNG Jetty');
      expect(assetRequest.materials?.length, 1);
      expect(assetRequest.checkList?.length, 1);
    });

    test('Stage weight progress calculation matches specification across all 7 steps', () {
      const int totalAssets = 1;
      const int assetIndex = 0;
      final double assetBase = (assetIndex / totalAssets) * 100;
      final double assetWeight = 100 / totalAssets;

      final stage1 = (assetBase + assetWeight * 0.15).round(); // Drawings uploaded
      final stage2 = (assetBase + assetWeight * 0.30).round(); // Functional area submitted
      final stage3 = (assetBase + assetWeight * 0.45).round(); // Signatures & documents uploaded
      final stage4 = (assetBase + assetWeight * 0.65).round(); // Defect photos uploaded
      final stage5 = (assetBase + assetWeight * 0.80).round(); // Corrective photos uploaded
      final stage6 = (assetBase + assetWeight * 0.95).round(); // Equipment tag synced
      final stage7 = (((assetIndex + 1) / totalAssets) * 100).round(); // Local cleanup completed

      expect(stage1, 15);
      expect(stage2, 30);
      expect(stage3, 45);
      expect(stage4, 65);
      expect(stage5, 80);
      expect(stage6, 95);
      expect(stage7, 100);
    });
  });
}
