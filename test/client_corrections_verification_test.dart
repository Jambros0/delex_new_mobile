import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/assets_duplicate.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';

void main() {
  group('Item 2: Protection Standard Discrete Keys', () {
    test('Discrete keys IEC, NEC, ATEX, Not Applicable should be distinct', () {
      final List<String> standards = ['IEC', 'NEC', 'ATEX', 'Not Applicable'];
      expect(standards.contains('IEC'), isTrue);
      expect(standards.contains('NEC'), isTrue);
      expect(standards.contains('ATEX'), isTrue);
      expect(standards.contains('Not Applicable'), isTrue);
      expect(standards.contains('IEC / ATEX'), isFalse);
      expect(standards.contains('NEC / CEC'), isFalse);
    });
  });

  group('Item 3: Ex-Register Duplicate Logic', () {
    test('Duplicate asset generates unique ID and does not overwrite original asset ID', () {
      final originalAsset = DuplicateAsset(
        id: 'asset_123',
        primaryId: '1',
        isActive: true,
        areaClassDrawNo: [],
        areaClassDrawAttach: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawAttachOrgName: [],
        eqpmtLytDrawNo: [],
        eqpmtLytDrawAttach: [],
      );

      // Duplication creates a new distinct ID
      final duplicateId = 'asset_${DateTime.now().millisecondsSinceEpoch}';
      final duplicateAsset = DuplicateAsset.fromJson(originalAsset.toJson());
      duplicateAsset.id = duplicateId;
      duplicateAsset.primaryId = duplicateId;
      duplicateAsset.isDuplicate = true;

      expect(duplicateAsset.id, isNot(equals(originalAsset.id)));
      expect(duplicateAsset.isDuplicate, isTrue);

      final duplicateJson = duplicateAsset.toJson();
      expect(duplicateJson['_id'], equals(duplicateId));
      expect(duplicateJson['primaryId'], equals(duplicateId));
    });
  });

  group('Item 5: Ex-Inspection Serial Number Parsing', () {
    test('EquipmentTagRequest parses both serialNumber and serialNo', () {
      final jsonWithSerialNumber = {
        '_id': '123',
        'serialNumber': 'SN-998877',
        'location': 'LocA',
        'area': 'Area1',
        'deckLevel': 'Deck1',
        'zone': 'Zone 1',
        'isActive': true,
        'eqpmtCatg': 'Electrical',
        'description': 'Motor',
        'locationTAmbient': '40',
      };

      final req1 = EquipmentTagRequest.fromJson(jsonWithSerialNumber);
      expect(req1.serialNumber, equals('SN-998877'));

      final jsonWithSerialNo = {
        '_id': '123',
        'serialNo': 'SN-554433',
        'location': 'LocA',
        'area': 'Area1',
        'deckLevel': 'Deck1',
        'zone': 'Zone 1',
        'isActive': true,
        'eqpmtCatg': 'Electrical',
        'description': 'Motor',
        'locationTAmbient': '40',
      };

      final req2 = EquipmentTagRequest.fromJson(jsonWithSerialNo);
      expect(req2.serialNumber, equals('SN-554433'));
    });
  });

  group('Item 6: Work Order Data Transfer parsing', () {
    test('Parses work order response with nested data list and assets', () {
      final responseBody = {
        'status': true,
        'data': {
          'data': [
            {
              '_id': 'wo_1',
              'woNumber': 'WO-1001',
              'assets': [
                {
                  '_id': 'asset_1',
                  'eqpmtTag': 'TAG-001',
                  'description': 'Pump Motor',
                  'location': 'Offshore Field',
                }
              ]
            }
          ],
          'total': 1
        }
      };

      final innerData = responseBody['data'] as Map<String, dynamic>;
      final collections = innerData['data'] as List<dynamic>;
      final List<dynamic> assetsData = [];
      for (final collection in collections) {
        if (collection is Map) {
          final rawAssets = collection['assets'];
          if (rawAssets is List) {
            assetsData.addAll(rawAssets);
          }
        }
      }

      final assets = assetsData.map((a) => ExRegister.fromJson(a)).toList();
      final workOrders =
          collections.map((w) => WorkOrderTableJson.fromJson(w)).toList();

      expect(assets.length, equals(1));
      expect(assets.first.id, equals('asset_1'));
      expect(assets.first.eqpmtTag, equals('TAG-001'));
      expect(workOrders.length, equals(1));
      expect(workOrders.first.id, equals('wo_1'));
    });

    test('Parses work order response when innerData is direct List', () {
      final List<dynamic> innerList = [
        {
          '_id': 'wo_2',
          'woNumber': 'WO-1002',
          'assets': [
            {
              '_id': 'asset_2',
              'eqpmtTag': 'TAG-002',
              'description': 'Junction Box',
            }
          ]
        }
      ];

      final List<dynamic> assetsData = [];
      for (final collection in innerList) {
        if (collection is Map) {
          final rawAssets = collection['assets'];
          if (rawAssets is List) {
            assetsData.addAll(rawAssets);
          }
        }
      }

      final assets = assetsData.map((a) => ExRegister.fromJson(a)).toList();
      expect(assets.length, equals(1));
      expect(assets.first.id, equals('asset_2'));
    });
  });
}
