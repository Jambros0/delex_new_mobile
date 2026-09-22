import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/ex_inspection_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';

void main() {
  group('Area Details Screen View Mode Population Tests', () {
    test('Location model deserializes full onshore & offshore records properly', () {
      final json = <String, dynamic>{
        '_id': '6a20062e379140daa45d5654',
        'location': 'Plant A',
        'area': 'Unit 100',
        'deckLevel': 'Level 2',
        'subArea': 'Near Pump 101',
        'zone': 'Zone 1',
        'locationGasGroup': ['IIC', 'IIB'],
        'locationTClass': ['T4-135°C'],
        'locationIpRating': ['IP66'],
        'locationLatitude': '25.011835',
        'locationLongitude': '55.061732',
        'tAmbient': '-20°C to +40°C',
        'isActive': true,
        'areaStatus': 'Active',
      };

      final loc = Location.fromJson(json);
      expect(loc.id, equals('6a20062e379140daa45d5654'));
      expect(loc.location, equals('Plant A'));
      expect(loc.area, equals('Unit 100'));
      expect(loc.deckLevel, equals('Level 2'));
      expect(loc.subArea, equals('Near Pump 101'));
      expect(loc.zone, equals('Zone 1'));
      expect(loc.locationGasGroup, equals(['IIC', 'IIB']));
      expect(loc.locationTClass, equals(['T4-135°C']));
      expect(loc.locationLatitude, equals('25.011835'));
      expect(loc.locationLongitude, equals('55.061732'));
      expect(loc.tAmbient, equals('-20°C to +40°C'));
      expect(loc.isActive, isTrue);
    });

    test('FunctionalAreaRequest maps all fields for View mode rendering', () {
      final Map<String, dynamic> locationData = <String, dynamic>{
        'locationId': '6a20062e379140daa45d5654',
        'location': 'Plant A',
        'area': 'Unit 100',
        'deckLevel': 'Level 2',
        'subArea': 'Near Pump 101',
        'zone': 'Zone 1',
        'locationGasGroup': ['IIC'],
        'locationTClass': ['T4-135°C'],
        'locationIpRating': ['IP66'],
        'gpsCoordinates': '25.011835, 55.061732',
        'tAmbient': '-20°C to +40°C',
        'isActive': true,
        'areaStatus': 'Active',
      };

      String latitude = locationData['locationLatitude']?.toString() ?? '';
      String longitude = locationData['locationLongitude']?.toString() ?? '';
      if ((latitude.isEmpty || longitude.isEmpty) &&
          locationData['gpsCoordinates'] != null) {
        final gps = locationData['gpsCoordinates'].toString();
        if (gps.contains(',')) {
          final parts = gps.split(',');
          latitude = parts[0].trim();
          longitude = parts[1].trim();
        }
      }

      final faReq = FunctionalAreaRequest(
        location: locationData['location']?.toString() ?? '',
        area: locationData['area']?.toString() ?? '',
        deckLevel: locationData['deckLevel']?.toString() ?? '',
        subArea: locationData['subArea']?.toString() ?? '',
        zone: locationData['zone']?.toString() ?? '',
        locationGasGroup: List<String>.from((locationData['locationGasGroup'] as Iterable?) ?? []),
        locationTClass: List<String>.from((locationData['locationTClass'] as Iterable?) ?? []),
        locationIpRating: List<String>.from((locationData['locationIpRating'] as Iterable?) ?? []),
        tAmbient: locationData['tAmbient']?.toString() ?? '',
        areaClassDrawAttach: [],
        areaClassDrawNo: [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawNo: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawAttachOrgName: [],
        locationId: locationData['locationId']?.toString() ?? '',
        locationLatitude: latitude,
        locationLongitude: longitude,
        isActive: locationData['isActive'] == true,
        areaStatus: locationData['areaStatus'] ?? 'Active',
      );

      final exReq = ExInspectionRequest(functionalAreaRequest: faReq);

      expect(exReq.functionalAreaRequest?.locationId, equals('6a20062e379140daa45d5654'));
      expect(exReq.functionalAreaRequest?.location, equals('Plant A'));
      expect(exReq.functionalAreaRequest?.area, equals('Unit 100'));
      expect(exReq.functionalAreaRequest?.deckLevel, equals('Level 2'));
      expect(exReq.functionalAreaRequest?.subArea, equals('Near Pump 101'));
      expect(exReq.functionalAreaRequest?.zone, equals('Zone 1'));
      expect(exReq.functionalAreaRequest?.locationLatitude, equals('25.011835'));
      expect(exReq.functionalAreaRequest?.locationLongitude, equals('55.061732'));
      expect(exReq.functionalAreaRequest?.locationGasGroup, equals(['IIC']));
      expect(exReq.functionalAreaRequest?.locationTClass, equals(['T4-135°C']));
      expect(exReq.functionalAreaRequest?.tAmbient, equals('-20°C to +40°C'));
      expect(exReq.functionalAreaRequest?.areaStatus, equals('Active'));
    });
  });
}
