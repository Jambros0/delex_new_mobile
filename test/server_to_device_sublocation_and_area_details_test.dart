import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/ex_inspection_request.dart';

void main() {
  group('Issue 1: Sub Location column value mismatch resolution', () {
    test('Onshore transferred asset maps subLocation to asset.area (Sub Location column)', () {
      final jsonPayload = {
        '_id': '101',
        'location': 'Location North',
        'subLocation': 'Sub Location Alpha',
        'area': 'Area Beta',
        'subArea': 'Building 4',
        'zone': 'Zone 1',
        'eqpmtTag': 'TAG-001',
      };

      final asset = ExRegister.fromJson(jsonPayload);

      // Onshore table:
      // Column 'Sub Location' displays asset.area -> must be 'Sub Location Alpha'
      // Column 'Area' displays asset.deckLevel -> must be 'Area Beta'
      // Column 'Sub Area' displays asset.subArea -> must be 'Building 4'
      expect(asset.area, equals('Sub Location Alpha'));
      expect(asset.deckLevel, equals('Area Beta'));
      expect(asset.subArea, equals('Building 4'));
    });

    test('Offshore asset maps platform to asset.area and deckLevel to asset.deckLevel', () {
      final jsonPayload = {
        '_id': '102',
        'location': 'Offshore Field A',
        'platform': 'Platform Echo',
        'deckLevel': 'Upper Deck',
        'zone': 'Zone 2',
        'eqpmtTag': 'TAG-002',
      };

      final asset = ExRegister.fromJson(jsonPayload);

      expect(asset.area, equals('Platform Echo'));
      expect(asset.deckLevel, equals('Upper Deck'));
    });
  });

  group('Issue 2: Transferred data autofills Area details in Step 1 of Ex Inspection', () {
    test('Transferred asset with area details populates all 7 fields in requests', () {
      final transferredAsset = {
        '_id': '201',
        'location': 'Main Facility',
        'subLocation': 'Processing Unit 1',
        'area': 'Control Section',
        'subArea': 'East Wing Near Generator',
        'zone': 'Zone 1',
        'gasGroup': 'IIC',
        'temperatureClass': 'T4',
        'gpsCoordinates': '24.4539, 54.3773',
        'areaClassificationDrawing': 'ACD-99881',
        'equipmentLayoutDrawing': 'ELD-77662',
      };

      // ExRegister parses all 7 fields correctly
      final exRegister = ExRegister.fromJson(transferredAsset);
      expect(exRegister.area, equals('Processing Unit 1'));
      expect(exRegister.subArea, equals('East Wing Near Generator'));
      expect(exRegister.locationGasGroup, contains('IIC'));
      expect(exRegister.locationTClass, contains('T4'));
      expect(exRegister.locationLatitude, equals('24.4539'));
      expect(exRegister.locationLongitude, equals('54.3773'));
      expect(exRegister.areaClassDrawNo, contains('ACD-99881'));
      expect(exRegister.eqpmtLytDrawNo, contains('ELD-77662'));

      // Simulate mapping transferred asset to FunctionalAreaRequest
      final fa = FunctionalAreaRequest(
        location: exRegister.location ?? '',
        area: exRegister.area ?? '',
        deckLevel: exRegister.deckLevel ?? '',
        subArea: exRegister.subArea,
        zone: exRegister.zone ?? '',
        locationGasGroup: exRegister.locationGasGroup ?? [],
        locationTClass: exRegister.locationTClass ?? [],
        locationIpRating: exRegister.locationIpRating ?? [],
        tAmbient: exRegister.locationTAmbient ?? '',
        areaClassDrawAttach: [],
        areaClassDrawNo: exRegister.areaClassDrawNo ?? [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawNo: exRegister.eqpmtLytDrawNo ?? [],
        areaClassDrawAttachOrgName: exRegister.areaClassDrawAttachOrgName ?? [],
        eqpmtLytDrawAttachOrgName: exRegister.eqpmtLytDrawAttachOrgName ?? [],
        locationLatitude: exRegister.locationLatitude,
        locationLongitude: exRegister.locationLongitude,
        isActive: true,
      );

      final eq = EquipmentTagRequest.fromJson({
        'location': exRegister.location,
        'area': exRegister.area,
        'deckLevel': exRegister.deckLevel,
        'subArea': exRegister.subArea,
        'zone': exRegister.zone,
        'locationGasGroup': exRegister.locationGasGroup,
        'locationTClass': exRegister.locationTClass,
        'locationIpRating': exRegister.locationIpRating,
        'locationLatitude': exRegister.locationLatitude,
        'locationLongitude': exRegister.locationLongitude,
        'gpsCord': '${exRegister.locationLatitude}, ${exRegister.locationLongitude}',
        'areaClassDrawNo': exRegister.areaClassDrawNo,
        'eqpmtLytDrawNo': exRegister.eqpmtLytDrawNo,
        'isActive': true,
      });

      final inspectionReq = ExInspectionRequest(
        functionalAreaRequest: fa,
        equipmentTagRequest: eq,
      );

      // Verify the 7 fields are NOT empty
      // 1. Sub location
      expect(inspectionReq.functionalAreaRequest?.area, equals('Processing Unit 1'));
      expect(inspectionReq.equipmentTagRequest?.area, equals('Processing Unit 1'));
      // 2. Sub area
      expect(inspectionReq.functionalAreaRequest?.subArea, equals('East Wing Near Generator'));
      expect(inspectionReq.equipmentTagRequest?.subArea, equals('East Wing Near Generator'));
      // 3. Gas group
      expect(inspectionReq.functionalAreaRequest?.locationGasGroup, contains('IIC'));
      expect(inspectionReq.equipmentTagRequest?.locationGasGroup, contains('IIC'));
      // 4. Temperature class
      expect(inspectionReq.functionalAreaRequest?.locationTClass, contains('T4'));
      expect(inspectionReq.equipmentTagRequest?.locationTClass, contains('T4'));
      // 5. GPS coordinates
      expect(inspectionReq.functionalAreaRequest?.locationLatitude, equals('24.4539'));
      expect(inspectionReq.functionalAreaRequest?.locationLongitude, equals('54.3773'));
      expect(inspectionReq.equipmentTagRequest?.gpsCord, contains('24.4539, 54.3773'));
      // 6. Area classification drawing
      expect(inspectionReq.functionalAreaRequest?.areaClassDrawNo, contains('ACD-99881'));
      expect(inspectionReq.equipmentTagRequest?.areaClassDrawNo, contains('ACD-99881'));
      // 7. Equipment layout drawing
      expect(inspectionReq.functionalAreaRequest?.eqpmtLytDrawNo, contains('ELD-77662'));
      expect(inspectionReq.equipmentTagRequest?.eqpmtLytDrawNo, contains('ELD-77662'));
    });
  });
}
