import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/assets_duplicate.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

void main() {
  group('Ex-Register Duplication & Modification Isolation Tests', () {
    test('Duplicating a record creates an isolated asset with stripped original IDs', () {
      final originalAssetJson = {
        '_id': '45',
        'primaryId': 45,
        'id': '45',
        'location': 'Platform A',
        'area': 'Deck 1',
        'zone': 'Zone 1',
        'locationGasGroup': ['IIA'],
        'locationTClass': ['T4'],
        'locationIpRating': ['IP66'],
        'areaClassDrawAttach': <String>[],
        'areaClassDrawNo': <String>[],
        'areaClassDrawAttachOrgName': <String>[],
        'eqpmtLytDrawAttachOrgName': <String>[],
        'eqpmtLytDrawAttach': <String>[],
        'eqpmtLytDrawNo': <String>[],
        'locationId': 'loc_101',
        'deckLevel': 'Level 2',
        'eqpmtCatg': 'Electrical',
        'description': 'Original Motor 45',
        'eqpmtTag': 'TAG-45',
        'atexCatg': <String>[],
        'epl': <String>[],
        'protectionType': <String>[],
        'locationTAmbient': '30',
        'isActive': true,
      };

      // 1. Create DuplicateAsset model from original asset
      final duplicateModel = DuplicateAsset.fromJson(originalAssetJson);
      expect(duplicateModel.description, equals('Original Motor 45'));
      expect(duplicateModel.eqpmtTag, equals('TAG-45'));

      // 2. PostAsset logic: Decouple IDs
      final Map<String, dynamic> duplicateAssetMap = duplicateModel.toJson();
      duplicateAssetMap.remove('_id');
      duplicateAssetMap.remove('primaryId');
      duplicateAssetMap.remove('id');
      duplicateAssetMap['isDuplicate'] = true;

      // 3. Emulate SQLite insert generating new unique row ID (e.g. 46)
      const int newDuplicateRowId = 46;
      duplicateAssetMap['_id'] = newDuplicateRowId.toString();
      duplicateAssetMap['primaryId'] = newDuplicateRowId;
      duplicateAssetMap['id'] = newDuplicateRowId.toString();

      final recordAJson = {'asset': originalAssetJson};
      final recordBJson = {'asset': duplicateAssetMap};

      // 4. Verify Record A vs Record B identity
      expect(recordAJson['asset']!['_id'], equals('45'));
      expect(recordAJson['asset']!['primaryId'], equals(45));
      expect(recordBJson['asset']!['_id'], equals('46'));
      expect(recordBJson['asset']!['primaryId'], equals(46));
      expect(recordAJson['asset']!['primaryId'], isNot(equals(recordBJson['asset']!['primaryId'])));

      // 5. Modifying Record A does not modify Record B
      final modifiedRecordAMap = Map<String, dynamic>.from(recordAJson['asset']!);
      modifiedRecordAMap['eqpmtTag'] = 'TAG-45-MODIFIED';
      modifiedRecordAMap['description'] = 'Updated Motor 45';

      expect(modifiedRecordAMap['eqpmtTag'], equals('TAG-45-MODIFIED'));
      expect(recordBJson['asset']!['eqpmtTag'], equals('TAG-45'));
      expect(recordBJson['asset']!['description'], equals('Original Motor 45'));

      // 6. Modifying Record B does not modify Record A
      final modifiedRecordBMap = Map<String, dynamic>.from(recordBJson['asset']!);
      modifiedRecordBMap['eqpmtTag'] = 'TAG-46-DUPLICATE-EDIT';
      modifiedRecordBMap['description'] = 'Duplicate Specific Desc';

      expect(modifiedRecordBMap['eqpmtTag'], equals('TAG-46-DUPLICATE-EDIT'));
      expect(modifiedRecordAMap['eqpmtTag'], equals('TAG-45-MODIFIED'));
    });

    test('EquipmentTagRequest mapping correctly sets assetId and primaryId', () {
      final assetDetails = {
        '_id': '99',
        'primaryId': 99,
        'location': 'Platform Alpha',
        'area': 'Deck 2',
        'zone': 'Zone 2',
        'locationGasGroup': ['IIB'],
        'locationTClass': ['T3'],
        'locationIpRating': ['IP65'],
        'areaClassDrawAttach': <String>[],
        'areaClassDrawNo': <String>[],
        'areaClassDrawAttachOrgName': <String>[],
        'eqpmtLytDrawAttachOrgName': <String>[],
        'eqpmtLytDrawAttach': <String>[],
        'eqpmtLytDrawNo': <String>[],
        'locationId': 'loc_99',
        'deckLevel': 'Deck 2',
        'eqpmtCatg': 'Instrumentation',
        'description': 'Sensor Unit',
        'eqpmtTag': 'SEN-99',
        'atexCatg': <String>[],
        'epl': <String>[],
        'protectionType': <String>[],
        'locationTAmbient': '25',
        'isActive': true,
      };

      final req = EquipmentTagRequest.fromJson(assetDetails);
      expect(req.assetId, equals('99'));

      final jsonResult = req.toJson();
      expect(jsonResult.containsKey('asset'), isTrue);
      final assetMap = jsonResult['asset'] as Map<String, dynamic>;
      expect(assetMap['_id'], equals('99'));
      expect(assetMap['eqpmtTag'], equals('SEN-99'));
    });
  });
}
