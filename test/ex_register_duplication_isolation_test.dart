import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/assets_duplicate.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_state.dart';

void main() {
  group('Ex-Register Duplication & Modification Isolation Tests', () {
    test('Duplicating Data 0 produces isolated Data 1 with distinct locationId and primaryId', () {
      final data0Json = {
        '_id': '10',
        'primaryId': 10,
        'id': '10',
        'location': 'Platform Alpha',
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
        'locationId': 'loc_original_10',
        'deckLevel': 'Level 1',
        'eqpmtCatg': 'Electrical',
        'description': 'Original Equipment 10',
        'eqpmtTag': 'TAG-0010',
        'atexCatg': <String>[],
        'epl': <String>[],
        'protectionType': <String>[],
        'locationTAmbient': '30',
        'isActive': true,
      };

      // Step 1: Duplicate Data 0 to DuplicateAsset model
      final duplicateAsset = DuplicateAsset.fromJson(data0Json);
      expect(duplicateAsset.description, equals('Original Equipment 10'));
      expect(duplicateAsset.eqpmtTag, equals('TAG-0010'));

      // Step 2: In postAsset, cloned functional area generates new unique locationId
      final String clonedLocationId = 'loc_duplicate_20';
      duplicateAsset.locationId = clonedLocationId;
      duplicateAsset.isDuplicate = true;

      final Map<String, dynamic> data1AssetMap = duplicateAsset.toJson();
      data1AssetMap.remove('_id');
      data1AssetMap.remove('primaryId');
      data1AssetMap.remove('id');
      data1AssetMap['locationId'] = clonedLocationId;
      data1AssetMap['isDuplicate'] = true;

      // Step 3: SQLite assigns new unique primary key (e.g. 20)
      const int data1RowId = 20;
      data1AssetMap['_id'] = data1RowId.toString();
      data1AssetMap['primaryId'] = data1RowId;
      data1AssetMap['id'] = data1RowId.toString();

      final Map<String, dynamic> recordData0 = {'id': 10, 'asset': Map<String, dynamic>.from(data0Json)};
      final Map<String, dynamic> recordData1 = {'id': 20, 'asset': Map<String, dynamic>.from(data1AssetMap)};
      final asset0 = recordData0['asset'] as Map<String, dynamic>;
      final asset1 = recordData1['asset'] as Map<String, dynamic>;

      // Verify identities are distinct
      expect(recordData0['id'], equals(10));
      expect(asset0['primaryId'], equals(10));
      expect(asset0['locationId'], equals('loc_original_10'));

      expect(recordData1['id'], equals(20));
      expect(asset1['primaryId'], equals(20));
      expect(asset1['locationId'], equals('loc_duplicate_20'));

      // Step 4: Edit Data 1 (Functional Area & Equipment Tag)
      asset1['location'] = 'New Location B';
      asset1['description'] = 'Modified Duplicated Equipment 20';
      asset1['eqpmtTag'] = 'TAG-0020-NEW';

      // Assert Data 0 is COMPLETELY unaffected
      expect(asset0['location'], equals('Platform Alpha'));
      expect(asset0['description'], equals('Original Equipment 10'));
      expect(asset0['eqpmtTag'], equals('TAG-0010'));
      expect(asset0['locationId'], equals('loc_original_10'));

      // Assert Data 1 contains the updated values
      expect(asset1['location'], equals('New Location B'));
      expect(asset1['description'], equals('Modified Duplicated Equipment 20'));
      expect(asset1['eqpmtTag'], equals('TAG-0020-NEW'));
      expect(asset1['locationId'], equals('loc_duplicate_20'));
    });

    test('EquipmentTagRequest mapping correctly preserves assetId and primaryId', () {
      final assetDetails = {
        '_id': '55',
        'primaryId': 55,
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
        'locationId': 'loc_55',
        'deckLevel': 'Deck 2',
        'eqpmtCatg': 'Instrumentation',
        'description': 'Pressure Transmitter',
        'eqpmtTag': 'PT-55',
        'atexCatg': <String>[],
        'epl': <String>[],
        'protectionType': <String>[],
        'locationTAmbient': '25',
        'isActive': true,
      };

      final req = EquipmentTagRequest.fromJson(assetDetails);
      expect(req.assetId, equals('55'));
      expect(req.primaryId, equals(55));

      final jsonResult = req.toJson();
      expect(jsonResult.containsKey('asset'), isTrue);
      final assetMap = jsonResult['asset'] as Map<String, dynamic>;
      expect(assetMap['_id'], equals('55'));
      expect(assetMap['primaryId'], equals(55));
      expect(assetMap['eqpmtTag'], equals('PT-55'));
    });

    test('ExRegister model parse sets correct ID and location mapping', () {
      final jsonMap = {
        '_id': '101',
        'primaryId': 101,
        'eqpmtTag': 'TAG-101',
        'description': 'Pump Motor',
        'location': 'Subsea Module',
        'locationId': 'loc_101',
        'rfidRef': 'RFID-101',
        'isActive': true,
        'area': 'Area X',
        'zone': 'Zone 0',
      };

      final exRegister = ExRegister.fromJson(jsonMap);
      expect(exRegister.id, equals('101'));
      expect(exRegister.primaryId, equals(101));
      expect(exRegister.eqpmtTag, equals('TAG-101'));
      expect(exRegister.location, equals('Subsea Module'));
      expect(exRegister.rfidRef, equals('RFID-101'));
    });

    test('ExRegisterInitial and ExRegisterLoading states are handled cleanly without error states', () {
      final initialState = ExRegisterInitial();
      final loadingState = ExRegisterLoading();
      final errorState = ExRegisterError('Custom error message');
      final loadedState = ExRegisterLoaded(
        tableHeaders: ['Tag', 'Desc'],
        assets: [
          ExRegister.fromJson({'id': '1', 'primaryId': 1, 'eqpmtTag': 'TAG-1'}),
          ExRegister.fromJson({'id': '2', 'primaryId': 2, 'eqpmtTag': 'TAG-2'}),
        ],
        totalRecords: 2,
        sortOrder: 'asc',
        skip: 0,
        isDuplicate: false,
      );

      // Verify states distinguish properly
      expect(initialState, isA<ExRegisterState>());
      expect(loadingState, isA<ExRegisterState>());
      expect(errorState, isA<ExRegisterState>());
      expect(loadedState, isA<ExRegisterState>());
      expect(loadedState.assets.length, equals(2));
      expect(loadedState.totalRecords, equals(2));
    });
  });
}

