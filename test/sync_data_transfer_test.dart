import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/models/mobile_sync_server_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Data Transfer and Sync Request/Response Verification Tests', () {
    test('Verify EquipmentTagRequest properly serializes signature and local DB fields', () {
      final sampleAssetJson = <String, dynamic>{
        '_id': '65fc99998888777766665555',
        'rfidRef': 'RFID-12345',
        'location': 'Platform A',
        'area': 'Deck 1',
        'deckLevel': 'Level 2',
        'zone': 'Zone 1',
        'eqpmtTag': 'TAG-001',
        'description': 'Ex d Junction Box',
        'manufacturer': 'ABB',
        'epl': ['Gb'],
        'inspectionStatus': 'Completed',
        'existingFaults': 'None',
        'currentStatus': 'Green',
        'checkList': [
          {
            'defectCategoryCode': 'CAT_1',
            'count': 1,
            'defectCodes': [
              {
                '_id': 'code_01',
                'checkListGroup': 'Electrical',
                'equipmentType': 'Junction Box',
                'checklistName': 'Enclosure',
                'inspectionGrade': 'Visual',
                'inspectionType': 'Detailed',
                'defectCode': 'DEF_01',
                'findingsAndActions': [
                  {
                    '_id': 'fa_01',
                    'defectCode': 'DEF_01',
                    'finding': 'Cover loose',
                    'remedialAction': 'Tighten bolts',
                    'defectCategory': 'CAT_1',
                    'isDone': true,
                    'isSelected': true,
                  }
                ],
                'defectPriority': {'CAT_1': 'High'}
              }
            ]
          }
        ],
        'subArea': 'North Wing',
        'isActive': true,
        'locationGasGroup': ['IIA', 'IIB'],
        'locationIpRating': ['IP66'],
        'locationTClass': ['T4'],
        'tAmbient': '-20 to +40',
        'tAmbientEquip': '-20 to +40',
        'inspectionSignOff': 'uploads/inspectionSignOff-123.png',
        'repairSignOff': 'uploads/repairSignOff-123.png',
        'areaClassDrawNo': ['DWG-01'],
        'eqpmtLytDrawNo': ['DWG-02'],
        'locationTAmbient': '30',
        'eqpmtCatg': 'Electrical',
        'oracleId': 'ORC-100',
        'equipmentEquipmentType': 'JB',
        'serialNumber': 'SN-001',
        'atexCatg': ['II 2 G'],
        'equipmentGasGroup': ['IIB'],
        'equipmentTClass': ['T4'],
        'equipmentIpRating': ['IP66'],
        'specialCond': 'X',
        'inspectionType': 'Detailed',
        'inspectionChecklistType': ['Standard'],
        'inspectionGrade': 'Visual',
        'faultyItems': 'Cover',
        'repairPriority': 1,
        'defectOverallCondition': 'Good',
        'defectIsolation': 'None',
        'defectOtherRequirements': ['None'],
        'remarks': 'All ok',
        'dataSheet': 'uploads/datasheet-123.pdf',
        'dataSheetNo': 'DS-01',
        'dataSheetOrgName': 'DS-01.pdf',
        'inspectedBy': 'Inspector Alex',
        'repairsDone': '1',
        'defectDefectCategory': 'CAT_1',
        'correctiveOverallCondition': 'Good',
        'repairedBy': 'Technician Bob',
        'inspectedDate': '2026-09-12T10:00:00.000Z',
        'repairedDate': '2026-09-12T11:00:00.000Z',
        'yesNoSelection': {'CHK_01': 'Yes'},
        'gpsCord': '1.3521,103.8198',
        'protectionStd': 'IEC 60079',
        'protectionType': ['Ex d'],
        'materials': [
          {
            'partNumber': 'BOLT-01',
            'description': 'M6 Bolt',
            'manufacturer': 'ABB',
            'certificationAttach': 'uploads/cert-01.pdf',
            'certificationOrgName': 'Cert',
            'unit': 'Pcs',
            'quantity': '4'
          }
        ],
        'locationId': '65fc123456789abcdef01230',
        'locationLatitude': '1.3521',
        'locationLongitude': '103.8198',
        'eqpmtLatitude': '1.3521',
        'eqpmtLongitude': '103.8198',
        'circuitId': 'CKT-1',
        'cableId': 'CBL-1',
        'equipmentCategory': 'Static',
        'type': 'Type A',
        'certfnBody': 'BASEEFA',
        'certfnNo': 'BAS01',
        'signature': 'uploads/userSignature-1726145261000.png',
        'areaStatus': 'Active',
        'inspectedId': 'USER_123',
      };

      final assetRequest = EquipmentTagRequest.fromJson(sampleAssetJson);
      expect(assetRequest.signature, equals('uploads/userSignature-1726145261000.png'));
      expect(assetRequest.inspectedBy, equals('Inspector Alex'));
      expect(assetRequest.repairedBy, equals('Technician Bob'));

      final requestJson = assetRequest.toJson();
      expect(requestJson.containsKey('asset'), isTrue);
      final assetMap = requestJson['asset'] as Map<String, dynamic>;

      // Check key fields
      expect(assetMap['signature'], equals('uploads/userSignature-1726145261000.png'));
      expect(assetMap['inspectedBy'], equals('Inspector Alex'));
      expect(assetMap['repairedBy'], equals('Technician Bob'));
      expect(assetMap['locationId'], equals('65fc123456789abcdef01230'));
      expect(assetMap['_id'], equals('65fc99998888777766665555'));
      expect(assetMap['materials']?.length, equals(1));
      expect(assetMap['checkList']?.length, equals(1));
    });

    test('Verify FunctionalAreaRequest JSON serialization', () {
      final sampleLocationJson = <String, dynamic>{
        'location': 'Platform A',
        'area': 'Deck 1',
        'deckLevel': 'Level 2',
        'subArea': 'North Wing',
        'zone': 'Zone 1',
        'locationGasGroup': ['IIA', 'IIB'],
        'locationTClass': ['T4'],
        'locationIpRating': ['IP66'],
        'tAmbient': '30',
        'areaClassDrawAttach': ['uploads/areaClassDrawAttach-01.pdf'],
        'areaClassDrawNo': ['DWG-01'],
        'areaClassDrawAttachOrgName': ['Drawing 1'],
        'eqpmtLytDrawAttachOrgName': ['Layout 1'],
        'eqpmtLytDrawAttach': ['uploads/eqpmtLytDrawAttach-01.pdf'],
        'eqpmtLytDrawNo': ['DWG-02'],
        'locationId': '65fc123456789abcdef01230',
        'locationLatitude': '1.3521',
        'locationLongitude': '103.8198',
        'isActive': true,
        'areaStatus': 'Active',
      };

      final locationRequest = FunctionalAreaRequest.fromJson(sampleLocationJson);
      final jsonOutput = locationRequest.toJson();

      expect(jsonOutput.containsKey('location'), isTrue);
      final locData = jsonOutput['location'] as Map<String, dynamic>;
      expect(locData['location'], equals('Platform A'));
      expect(locData['area'], equals('Deck 1'));
      expect(locData['locationId'], equals('65fc123456789abcdef01230'));
      expect(locData['isActive'], isTrue);
    });

    test('Verify API Response handling and Activity model persistence format', () {
      // 1. Functional Area API Response
      final Map<String, dynamic> locationApiResponse = {
        'status': true,
        'msg': 'Location synced successfully',
        'data': {
          'locationId': '65fc123456789abcdef01230'
        }
      };

      final dataMap = locationApiResponse['data'] as Map<String, dynamic>?;
      final returnedLocationId = dataMap?['locationId'] as String? ?? '';
      expect(returnedLocationId, equals('65fc123456789abcdef01230'));

      final locationActivity = Activity(
        assetId: '10',
        functionality: FunctionalityType.location,
        functionalityApiResponseId: returnedLocationId,
        status: true,
        lastSync: DateTime.now().toIso8601String(),
        createdBy: 'USER_123',
        updatedBy: 'USER_123',
      );

      final locActivityMap = locationActivity.toMap();
      expect(locActivityMap['assetId'], equals('10'));
      expect(locActivityMap['functionality'], equals('location'));
      expect(locActivityMap['functionality_api_response_id'], equals('65fc123456789abcdef01230'));
      expect(locActivityMap['status'], equals(1));

      // 2. Sync Assets API Response
      final Map<String, dynamic> assetApiResponse = {
        'status': true,
        'msg': 'Asset synced successfully',
        'data': {
          'asset': {
            '_id': '65fc99998888777766665555'
          }
        }
      };

      final assetDataMap = assetApiResponse['data'] as Map<String, dynamic>?;
      final assetObj = assetDataMap?['asset'] as Map<String, dynamic>?;
      final returnedAssetId = assetObj?['_id'] as String? ?? '';
      expect(returnedAssetId, equals('65fc99998888777766665555'));

      final assetActivity = Activity(
        assetId: '10',
        functionality: FunctionalityType.asset,
        functionalityApiResponseId: returnedAssetId,
        status: true,
        lastSync: DateTime.now().toIso8601String(),
        createdBy: 'USER_123',
        updatedBy: 'USER_123',
      );

      final assetActivityMap = assetActivity.toMap();
      expect(assetActivityMap['assetId'], equals('10'));
      expect(assetActivityMap['functionality'], equals('asset'));
      expect(assetActivityMap['functionality_api_response_id'], equals('65fc99998888777766665555'));
      expect(assetActivityMap['status'], equals(1));
    });
  });
}
