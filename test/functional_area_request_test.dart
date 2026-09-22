import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';

void main() {
  group('FunctionalAreaRequest serialization tests', () {
    test('toJson includes local integer locationId when present', () {
      final request = FunctionalAreaRequest(
        locationId: '1',
        location: 'Field A',
        area: 'Platform B',
        deckLevel: 'Level 1',
        zone: 'Zone 1',
        locationGasGroup: ['IIA'],
        locationTClass: ['T1'],
        locationIpRating: ['IP65'],
        tAmbient: '25',
        areaClassDrawAttach: [],
        areaClassDrawNo: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawNo: [],
        eqpmtLytDrawAttachOrgName: [],
        isActive: true,
      );

      final json = request.toJson();
      expect(json['location']['locationId'], '1');
      expect(json['location']['location'], 'Field A');
    });

    test('toJson includes 24-character ObjectId locationId when present', () {
      const mongoId = '66de94b159f8c62768565b9e';
      final request = FunctionalAreaRequest(
        locationId: mongoId,
        location: 'Field B',
        area: 'Platform C',
        deckLevel: 'Level 2',
        zone: 'Zone 2',
        locationGasGroup: ['IIB'],
        locationTClass: ['T2'],
        locationIpRating: ['IP66'],
        tAmbient: '30',
        areaClassDrawAttach: [],
        areaClassDrawNo: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawNo: [],
        eqpmtLytDrawAttachOrgName: [],
        isActive: true,
      );

      final json = request.toJson();
      expect(json['location']['locationId'], mongoId);
    });

    test('toJson omits locationId when null or empty', () {
      final requestNull = FunctionalAreaRequest(
        locationId: null,
        location: 'Field A',
        area: 'Platform B',
        deckLevel: 'Level 1',
        zone: 'Zone 1',
        locationGasGroup: ['IIA'],
        locationTClass: ['T1'],
        locationIpRating: ['IP65'],
        tAmbient: '25',
        areaClassDrawAttach: [],
        areaClassDrawNo: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawNo: [],
        eqpmtLytDrawAttachOrgName: [],
        isActive: true,
      );

      final jsonNull = requestNull.toJson();
      expect(jsonNull['location'].containsKey('locationId'), isFalse);

      final requestEmpty = FunctionalAreaRequest(
        locationId: '',
        location: 'Field A',
        area: 'Platform B',
        deckLevel: 'Level 1',
        zone: 'Zone 1',
        locationGasGroup: ['IIA'],
        locationTClass: ['T1'],
        locationIpRating: ['IP65'],
        tAmbient: '25',
        areaClassDrawAttach: [],
        areaClassDrawNo: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawNo: [],
        eqpmtLytDrawAttachOrgName: [],
        isActive: true,
      );

      final jsonEmpty = requestEmpty.toJson();
      expect(jsonEmpty['location'].containsKey('locationId'), isFalse);
    });
  });
}
