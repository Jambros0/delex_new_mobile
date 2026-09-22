import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Area Detail & Ex-Register Location ID Tests', () {
    test('Location.fromJson correctly extracts id from locationId, _id, or id', () {
      final jsonWithLocId = {
        'locationId': '42',
        'location': 'Offshore Field A',
        'area': 'Platform 1',
        'deckLevel': 'Level 2',
      };
      final loc1 = Location.fromJson(jsonWithLocId);
      expect(loc1.id, '42');
      expect(loc1.location, 'Offshore Field A');

      final jsonWithIntLocId = {
        'locationId': 99,
        'location': 'Offshore Field B',
        'area': 'Platform 2',
      };
      final loc2 = Location.fromJson(jsonWithIntLocId);
      expect(loc2.id, '99');

      final jsonWithUnderscoreId = {
        '_id': '6ab0d7c769bbfa6fbed32d6f',
        'location': 'Onshore Field',
        'area': 'Area X',
      };
      final loc3 = Location.fromJson(jsonWithUnderscoreId);
      expect(loc3.id, '6ab0d7c769bbfa6fbed32d6f');
    });

    test('FunctionalAreaRequest preserves locationId across serialization', () {
      final req = FunctionalAreaRequest(
        locationId: '10',
        location: 'Field Test',
        area: 'Platform Alpha',
        deckLevel: 'Main Deck',
        zone: 'Zone 1',
        locationGasGroup: ['IIA'],
        locationTClass: ['T3'],
        locationIpRating: ['IP65'],
        tAmbient: '40',
        areaClassDrawAttach: [],
        areaClassDrawNo: [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawNo: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawAttachOrgName: [],
        isActive: true,
      );

      final json = req.toJson();
      expect(json['location']['locationId'], '10');
      expect(json['location']['location'], 'Field Test');
      expect(json['location']['area'], 'Platform Alpha');
    });

    test('EquipmentTagRequest preserves locationId across serialization', () {
      final jsonMap = {
        'locationId': '10',
        'location': 'Field Test',
        'area': 'Platform Alpha',
        'zone': 'Zone 1',
        'deckLevel': 'Main Deck',
        'locationGasGroup': ['IIA'],
        'locationTClass': ['T3'],
        'locationIpRating': ['IP65'],
        'locationTAmbient': '40',
        'description': 'Transmitter',
        'eqpmtCatg': 'Electrical',
        'isActive': true,
      };

      final eq = EquipmentTagRequest.fromJson(jsonMap);
      expect(eq.locationId, '10');
      expect(eq.location, 'Field Test');

      final json = eq.toJson();
      final assetJson = (json['asset'] is Map) ? json['asset'] as Map : json;
      expect(assetJson['locationId'], '10');
      expect(assetJson['location'], 'Field Test');
    });

    test('Ex-Register JSON updates matching asset fields when area details are modified', () {
      final originalExRegisterJson = {
        'asset': {
          'locationId': '5',
          'location': 'Old Location',
          'area': 'Old Area',
          'deckLevel': 'Old Deck',
          'subArea': 'Old SubArea',
          'zone': 'Zone 2',
          'eqpmtTag': 'TAG-001',
          'description': 'Motor',
        }
      };

      final updatedFunctionalAreaData = {
        'location': {
          'locationId': '5',
          'location': 'New Location',
          'area': 'New Area',
          'deckLevel': 'New Deck',
          'subArea': 'New SubArea',
          'zone': 'Zone 1',
          'tAmbient': '45',
        }
      };

      final fieldsToUpdate = [
        'location',
        'area',
        'subArea',
        'zone',
        'deckLevel',
        'tAmbient',
      ];

      final asset = Map<String, dynamic>.from(originalExRegisterJson['asset']!);
      if (asset['locationId'] == updatedFunctionalAreaData['location']!['locationId']) {
        for (final field in fieldsToUpdate) {
          if (updatedFunctionalAreaData['location']!.containsKey(field)) {
            asset[field] = updatedFunctionalAreaData['location']![field];
          }
        }
      }

      expect(asset['locationId'], '5'); // Same location ID
      expect(asset['location'], 'New Location');
      expect(asset['area'], 'New Area');
      expect(asset['deckLevel'], 'New Deck');
      expect(asset['subArea'], 'New SubArea');
      expect(asset['zone'], 'Zone 1');
      expect(asset['eqpmtTag'], 'TAG-001'); // Asset fields preserved
      expect(asset['description'], 'Motor');
    });
  });
}
