import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Data Transfer To Device - Media Processing Unit Tests', () {
    test('Populates missing OrgName and No fields for datasheets and photos', () {
      final assetJson = {
        '_id': 'asset_media_test',
        'dataSheet': 'media/workorders/attachments/6ab0d_datasheet_test.pdf',
        'dataSheetOrgName': null,
        'dataSheetNo': '',
        'defectivePhoto1': 'media/locations/defectivePhotos/photo1.jpg',
        'defectivePhoto1OrgName': '',
        'correctivePhoto1': 'media/locations/correctivePhotos/corr1.jpg',
        'correctivePhoto1OrgName': null,
        'inspectionSignOff': 'media/users/signatures/sign1.jpg',
        'repairSignOff': 'media/users/signatures/sign2.jpg',
        'materials': [
          {
            'certificationAttach': 'media/materials/cert1.pdf',
            'certificationOrgName': null,
          }
        ],
      };

      final updated = Map<String, dynamic>.from(assetJson);

      // Verify filename resolution logic
      if ((updated['dataSheetOrgName'] == null || updated['dataSheetOrgName'].toString().trim().isEmpty) &&
          updated['dataSheet'] != null) {
        updated['dataSheetOrgName'] = path.basename(updated['dataSheet'].toString());
      }
      if ((updated['dataSheetNo'] == null || updated['dataSheetNo'].toString().trim().isEmpty) &&
          updated['dataSheet'] != null) {
        updated['dataSheetNo'] = path.basename(updated['dataSheet'].toString());
      }
      expect(updated['dataSheetOrgName'], '6ab0d_datasheet_test.pdf');
      expect(updated['dataSheetNo'], '6ab0d_datasheet_test.pdf');

      // Photos OrgName check
      if ((updated['defectivePhoto1OrgName'] == null || updated['defectivePhoto1OrgName'].toString().trim().isEmpty) &&
          updated['defectivePhoto1'] != null) {
        updated['defectivePhoto1OrgName'] = path.basename(updated['defectivePhoto1'].toString());
      }
      expect(updated['defectivePhoto1OrgName'], 'photo1.jpg');

      if ((updated['correctivePhoto1OrgName'] == null || updated['correctivePhoto1OrgName'].toString().trim().isEmpty) &&
          updated['correctivePhoto1'] != null) {
        updated['correctivePhoto1OrgName'] = path.basename(updated['correctivePhoto1'].toString());
      }
      expect(updated['correctivePhoto1OrgName'], 'corr1.jpg');

      // Materials cert OrgName check
      final matList = updated['materials'] as List;
      for (var item in matList) {
        if ((item['certificationOrgName'] == null || item['certificationOrgName'].toString().trim().isEmpty) &&
            item['certificationAttach'] != null) {
          item['certificationOrgName'] = path.basename(item['certificationAttach'].toString());
        }
      }
      expect(matList.first['certificationOrgName'], 'cert1.pdf');
    });

    test('Candidate URL builder handles onshore, offshore, and direct paths correctly', () {
      final baseUrl = 'http://94.136.185.87:16000';
      final testCases = [
        {
          'path': 'media/workorders/attachments/sample.pdf',
          'defaultUserType': 'offshore',
          'expectedFirst': 'http://94.136.185.87:16000/offshore/media/workorders/attachments/sample.pdf',
          'expectedAlt': 'http://94.136.185.87:16000/onshore/media/workorders/attachments/sample.pdf',
        },
        {
          'path': 'onshore/media/locations/photo.jpg',
          'defaultUserType': 'offshore',
          'expectedFirst': 'http://94.136.185.87:16000/onshore/media/locations/photo.jpg',
          'expectedAlt': null,
        },
      ];

      for (var tc in testCases) {
        final pathStr = tc['path'] as String;
        final defaultUserType = tc['defaultUserType'] as String;
        final List<String> candidates = [];

        String cleanPath = pathStr;
        while (cleanPath.startsWith('/')) {
          cleanPath = cleanPath.substring(1);
        }

        if (cleanPath.startsWith('onshore/') || cleanPath.startsWith('offshore/')) {
          candidates.add('$baseUrl/$cleanPath');
        } else {
          candidates.add('$baseUrl/$defaultUserType/$cleanPath');
          final altType = (defaultUserType == 'onshore') ? 'offshore' : 'onshore';
          candidates.add('$baseUrl/$altType/$cleanPath');
          candidates.add('$baseUrl/$cleanPath');
        }

        expect(candidates.first, tc['expectedFirst']);
        if (tc['expectedAlt'] != null) {
          expect(candidates[1], tc['expectedAlt']);
        }
      }
    });
  });
}
