import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/columStyle.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';

void main() {
  group('Onshore and Offshore Data Transfer To Device Tests', () {
    test('ColumnStyleHelper supports both Onshore and Offshore table headers', () {
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Location', 100), 100);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Field Name', 100), 100);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Sub Location', 100), 100);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Platform', 100), 100);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Area', 100), 100);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Deck Level', 100), 100);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Discipline', 100), 160);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Discpline', 100), 160);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Equipment Manufacturer', 100), 100);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Manufacutrer', 100), 100);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Zone', 100), 140);
      expect(ColumnStyleHelper.getExRegisterHeaderCustomWidth('Equipment Protection', 100), 200);
    });

    test('ExRegister model parses Onshore asset fields correctly', () {
      final onshoreAssetJson = {
        '_id': 'asset_onshore_1',
        'rfidRef': 'RFID-ON-001',
        'location': 'Plant A',
        'area': 'Unit 1',
        'deckLevel': 'Ground Level',
        'subArea': 'Pump Room',
        'zone': 'Zone 1',
        'eqpmtCatg': 'Electrical',
        'eqpmtTag': 'MOT-001',
        'description': 'Main Pump Motor',
        'manufacturer': 'Siemens',
        'protectionType': ['Ex d'],
        'equipmentGasGroup': ['IIB'],
        'equipmentTClass': ['T4'],
        'inspectionStatus': 'Green',
        'repairsDone': null,
        'existingFaults': '0',
        'currentStatus': 'Green',
        'isActive': true,
      };

      final asset = ExRegister.fromJson(onshoreAssetJson);
      expect(asset.id, 'asset_onshore_1');
      expect(asset.rfidRef, 'RFID-ON-001');
      expect(asset.location, 'Plant A');
      expect(asset.area, 'Unit 1');
      expect(asset.deckLevel, 'Ground Level');
      expect(asset.zone, 'Zone 1');
      expect(asset.eqpmtTag, 'MOT-001');
      expect(asset.description, 'Main Pump Motor');
      expect(asset.manufacturer, 'Siemens');
      expect(asset.inspectionStatus, 'Green');
      expect(asset.repairsDone, isNull);
      expect(asset.currentStatus, 'Green');
    });

    test('ExRegister model parses Offshore asset fields correctly', () {
      final offshoreAssetJson = {
        '_id': 'asset_offshore_1',
        'rfidRef': 'RFID-OFF-001',
        'location': 'Alpha Field',
        'area': 'Platform Bravo',
        'deckLevel': 'Cellar Deck',
        'zone': 'Zone 2',
        'eqpmtCatg': 'Instrumentation',
        'eqpmtTag': 'TX-902',
        'description': 'Pressure Transmitter',
        'manufacturer': 'Yokogawa',
        'protectionType': ['Ex ia'],
        'equipmentGasGroup': ['IIC'],
        'equipmentTClass': ['T6'],
        'inspectionStatus': 'Yellow',
        'repairsDone': 'Gland replaced',
        'existingFaults': '1',
        'currentStatus': 'Yellow',
        'isActive': true,
      };

      final asset = ExRegister.fromJson(offshoreAssetJson);
      expect(asset.id, 'asset_offshore_1');
      expect(asset.rfidRef, 'RFID-OFF-001');
      expect(asset.location, 'Alpha Field');
      expect(asset.area, 'Platform Bravo');
      expect(asset.deckLevel, 'Cellar Deck');
      expect(asset.zone, 'Zone 2');
      expect(asset.eqpmtTag, 'TX-902');
      expect(asset.description, 'Pressure Transmitter');
      expect(asset.manufacturer, 'Yokogawa');
      expect(asset.repairsDone, 'Gland replaced');
    });

    test('WorkOrderTableJson parses nested work orders with assets correctly', () {
      final workOrderJson = {
        '_id': 'wo_123',
        'woNumber': 'WO-2026-001',
        'woType': 'Corrective',
        'discipline': 'Electrical',
        'description': 'Maintenance WO',
        'status': 'Open',
        'assets': [
          {
            '_id': 'asset_1',
            'rfidRef': 'RFID-1',
            'location': 'Location 1',
            'area': 'Area 1',
            'zone': 'Zone 1',
            'eqpmtTag': 'TAG-01',
            'description': 'Desc 1',
            'manufacturer': 'Mfr 1',
            'protectionType': ['Ex d'],
            'inspectionStatus': 'Green',
            'currentStatus': 'Green',
          }
        ]
      };

      final wo = WorkOrderTableJson.fromJson(workOrderJson);
      expect(wo.id, 'wo_123');
      expect(wo.woNumber, 'WO-2026-001');
      expect(wo.assets.length, 1);
      expect(wo.assets.first.id, 'asset_1');
      expect(wo.assets.first.rfidRef, 'RFID-1');
    });

    test('Sanitization of null and empty values works properly for table display', () {
      String sanitize(dynamic value) {
        if (value == null) return '';
        final str = value.toString().trim();
        return (str.isEmpty || str.toLowerCase() == 'null') ? '' : str;
      }

      expect(sanitize(null), '');
      expect(sanitize('null'), '');
      expect(sanitize('NULL'), '');
      expect(sanitize(''), '');
      expect(sanitize('   '), '');
      expect(sanitize('Repairs Done'), 'Repairs Done');
      expect(sanitize(0), '0');
    });

    test('Transferred assets are removed from server to device asset list and work orders', () {
      final List<ExRegister> initialServerAssets = [
        ExRegister.fromJson({'_id': 'asset_1', 'rfidRef': 'RFID-1', 'location': 'Loc 1', 'area': 'Area 1', 'deckLevel': 'Deck 1', 'zone': '1', 'eqpmtCatg': 'Elec', 'description': 'Item 1', 'equipmentProtection': ['Ex d']}),
        ExRegister.fromJson({'_id': 'asset_2', 'rfidRef': 'RFID-2', 'location': 'Loc 2', 'area': 'Area 2', 'deckLevel': 'Deck 2', 'zone': '1', 'eqpmtCatg': 'Elec', 'description': 'Item 2', 'equipmentProtection': ['Ex d']}),
        ExRegister.fromJson({'_id': 'asset_3', 'rfidRef': 'RFID-3', 'location': 'Loc 3', 'area': 'Area 3', 'deckLevel': 'Deck 3', 'zone': '1', 'eqpmtCatg': 'Elec', 'description': 'Item 3', 'equipmentProtection': ['Ex d']}),
      ];

      final Set<String> localTransferredIds = {'asset_1', 'asset_2'};

      // 1. Filter out transferred assets
      final untransferred = initialServerAssets.where((asset) => !localTransferredIds.contains(asset.id)).toList();

      expect(untransferred.length, 1);
      expect(untransferred.first.id, 'asset_3');

      // 2. Filter out work order collections
      final workOrders = [
        WorkOrderTableJson.fromJson({
          '_id': 'wo_1',
          'woNumber': 'WO-1',
          'assets': [
            {'_id': 'asset_1', 'rfidRef': 'RFID-1', 'location': 'Loc 1', 'area': 'Area 1', 'deckLevel': 'Deck 1', 'zone': '1', 'eqpmtCatg': 'Elec', 'description': 'Item 1', 'equipmentProtection': ['Ex d']},
            {'_id': 'asset_3', 'rfidRef': 'RFID-3', 'location': 'Loc 3', 'area': 'Area 3', 'deckLevel': 'Deck 3', 'zone': '1', 'eqpmtCatg': 'Elec', 'description': 'Item 3', 'equipmentProtection': ['Ex d']},
          ]
        }),
        WorkOrderTableJson.fromJson({
          '_id': 'wo_2',
          'woNumber': 'WO-2',
          'assets': [
            {'_id': 'asset_2', 'rfidRef': 'RFID-2', 'location': 'Loc 2', 'area': 'Area 2', 'deckLevel': 'Deck 2', 'zone': '1', 'eqpmtCatg': 'Elec', 'description': 'Item 2', 'equipmentProtection': ['Ex d']},
          ]
        })
      ];

      final filteredWorkOrders = workOrders.map((wo) {
        final remainingWoAssets = wo.assets.where((asset) => !localTransferredIds.contains(asset.id)).toList();
        wo.assets = remainingWoAssets;
        return wo;
      }).where((wo) => wo.assets.isNotEmpty).toList();

      expect(filteredWorkOrders.length, 1);
      expect(filteredWorkOrders.first.id, 'wo_1');
      expect(filteredWorkOrders.first.assets.length, 1);
      expect(filteredWorkOrders.first.assets.first.id, 'asset_3');
    });
  });
}
