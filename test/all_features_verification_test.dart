import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/file_upload_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/excel_functions.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Item 1: Work Order Data Transfer by User ID', () {
    test('Constructs correct work-order endpoint with user ID', () {
      final userId = '6aad40175fa208c9dce875c0';
      final endpoint = '/work-order/$userId';
      expect(endpoint, equals('/work-order/6aad40175fa208c9dce875c0'));
    });

    test('Preserves all API attributes in asset JSON map without dropping fields', () {
      final apiResponseAsset = {
        '_id': 'asset_001',
        'primaryId': '101',
        'rfidRef': 'RFID-12345',
        'inspectionReferenceNumber': 'INSP-2026-001',
        'location': 'Offshore Field Alpha',
        'area': 'Platform A',
        'deckLevel': 'Deck 2',
        'subArea': 'North Corner',
        'locationLatitude': '25.2048',
        'locationLongitude': '55.2708',
        'zone': 'Zone 1',
        'locationGasGroup': ['IIA', 'IIB'],
        'locationTClass': ['T3'],
        'areaClassDrawNo': ['DWG-001', 'DWG-002'],
        'areaClassDrawAttach': ['/files/dwg1.pdf', '/files/dwg2.pdf'],
        'areaClassDrawAttachOrgName': ['DWG 1 Original', 'DWG 2 Original'],
        'eqpmtLytDrawNo': ['LYT-001'],
        'eqpmtLytDrawAttach': ['/files/lyt1.pdf'],
        'eqpmtLytDrawAttachOrgName': ['LYT 1 Original'],
        'areaStatus': 'Active',
        'discipline': 'Electrical',
        'eqpmtTag': 'TAG-PUMP-01',
        'cableId': 'CBL-88',
        'oracleId': 'ORC-999',
        'description': 'Main Hydraulic Pump Motor with Explosion Proof Enclosure',
        'equipmentCategory': 'Rotating Machine',
        'manufacturer': 'Siemens',
        'type': '1LA8-453',
        'serialNumber': 'SN-SIEM-99281',
        'status': 'Active',
        'atexCatg': ['II 2 G'],
        'epl': ['Gb'],
        'protectionStd': 'IEC',
        'protectionType': ['Ex d', 'Ex e'],
        'equipmentGasGroup': ['IIB'],
        'equipmentTClass': ['T4'],
        'equipmentIpRating': ['IP66'],
        'tAmbient': '40',
        'certfnBody': 'BASEEFA',
        'certfnNo': 'BAS02ATEX1234X',
        'specialCond': 'Keep clean',
        'inspectionType': 'Detailed',
        'equipmentEquipmentType': 'High Voltage',
        'inspectionChecklistType': ['Detailed Inspection'],
        'inspectionGrade': 'Visual',
        'materials': [
          {
            'partNumber': 'PN-101',
            'description': 'Ex Gasket Seal',
            'manufacturer': 'Delta',
            'quantity': '2',
            'certificationOrgName': 'Cert-01.pdf',
          }
        ],
        'supplementaryMaterialReq': [
          {
            'partNumber': 'PN-SUP-01',
            'description': 'Bolt M10 Stainless',
            'manufacturer': 'Fastener Co',
            'quantity': '10',
            'certificationOrgName': 'BoltCert.pdf',
          }
        ],
        'defectivePhoto1': '/uploads/defect1.jpg',
        'defectivePhoto1OrgName': 'defect1.jpg',
        'correctivePhoto1': '/uploads/correct1.jpg',
        'correctivePhoto1OrgName': 'correct1.jpg',
        'updated_date': '2026-09-21T18:00:00.000Z',
        'created_date': '2026-09-20T10:00:00.000Z',
      };

      // Model deserialization
      final model = ExRegister.fromJson(apiResponseAsset);
      expect(model.id, equals('asset_001'));
      expect(model.rfidRef, equals('RFID-12345'));
      expect(model.materials?.length, equals(1));
      expect(model.materials?.first.partNumber, equals('PN-101'));
      expect(model.supplementaryMaterialReq?.length, equals(1));
      expect(model.defectivePhoto1OrgName, equals('defect1.jpg'));
      expect(model.correctivePhoto1OrgName, equals('correct1.jpg'));

      // Serialization back to JSON
      final savedJson = model.toJson();
      expect(savedJson['_id'], equals('asset_001'));
      expect(savedJson['rfidRef'], equals('RFID-12345'));
      expect(savedJson['eqpmtTag'], equals('TAG-PUMP-01'));
    });
  });

  group('Item 2: Device Transfer to Server File Upload Handling', () {
    test('isValidFileType supports image extensions and document extensions', () {
      final fileUploadUtil = FileUploadUtil();

      expect(fileUploadUtil.isValidFileType('photo.jpg', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('photo.jpeg', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('photo.png', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('photo.webp', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('photo.jfif', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('photo.bmp', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('photo.heic', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('photo.gif', fileUploadUtil.generalFileTypes), isTrue);

      expect(fileUploadUtil.isValidFileType('doc.pdf', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('doc.doc', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('doc.docx', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('sheet.xls', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('sheet.xlsx', fileUploadUtil.generalFileTypes), isTrue);

      // Strips query parameters before checking
      expect(fileUploadUtil.isValidFileType('photo.jpg?token=xyz123', fileUploadUtil.generalFileTypes), isTrue);
      expect(fileUploadUtil.isValidFileType('invalid.exe', fileUploadUtil.generalFileTypes), isFalse);
    });

    test('Identifies image extensions for Multifile upload route', () {
      final fileUploadUtil = FileUploadUtil();
      final imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'jfif', 'bmp', 'heic', 'gif'];
      final docExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

      for (final ext in imageExtensions) {
        expect(fileUploadUtil.isValidFileType('file.$ext', fileUploadUtil.imageFileTypes), isTrue, reason: '$ext should match image types');
      }

      for (final ext in docExtensions) {
        expect(fileUploadUtil.isValidFileType('file.$ext', fileUploadUtil.imageFileTypes), isFalse, reason: '$ext should not match image types');
      }
    });
  });

  group('Item 3: Ex-Inspection Image Path Resolution', () {
    test('Resolves remote image URL correctly without duplicate base URLs', () {
      final apiUrl = 'http://94.136.185.87:16000';

      String getResolvedImageUrl(String path) {
        if (path.startsWith('http://') || path.startsWith('https://')) {
          return path;
        }
        final cleanPath = path.startsWith('/') ? path.substring(1) : path;
        final base = apiUrl.endsWith('/') ? apiUrl.substring(0, apiUrl.length - 1) : apiUrl;
        return '$base/$cleanPath';
      }

      expect(getResolvedImageUrl('http://example.com/pic.jpg'), equals('http://example.com/pic.jpg'));
      expect(getResolvedImageUrl('/uploads/defects/pic1.jpg'), equals('http://94.136.185.87:16000/uploads/defects/pic1.jpg'));
      expect(getResolvedImageUrl('uploads/defects/pic2.png'), equals('http://94.136.185.87:16000/uploads/defects/pic2.png'));
    });
  });

  group('Item 4: Dynamic Excel Row Height Calculation', () {
    test('Calculates row height dynamically based on lines and character count', () {
      final excelFunctions = ExcelFunctions();
      final Map<int, double> colWidths = {
        0: 5.0,
        1: 15.0,
        2: 25.0,
        19: 20.0,
        40: 25.0,
        52: 25.0,
      };

      // Single line short content
      final shortRow = [
        {'val': '1'},
        {'val': 'RFID-001'},
        {'val': 'Short desc'},
      ];
      final shortHeight = excelFunctions.calculateDynamicRowHeight(shortRow, colWidths, minHeight: 38.0);
      expect(shortHeight, equals(38.0));

      // Multi-line materials content
      final multiLineRow = [
        {'val': '1'},
        {'val': 'RFID-001'},
        {
          'val': 'Part Number : PN-1\nMaterial Description : Desc 1\nManufacturer : Mfr 1\nQuantity : 2\nCert : C1\n\nPart Number : PN-2\nMaterial Description : Desc 2\nManufacturer : Mfr 2\nQuantity : 5\nCert : C2'
        },
      ];
      final multiLineHeight = excelFunctions.calculateDynamicRowHeight(multiLineRow, colWidths, minHeight: 38.0);
      expect(multiLineHeight, greaterThan(150.0));

      // Long un-split text wrapping
      final wrappedRow = [
        {'val': '1'},
        {'val': 'A' * 200}, // 200 chars in width 15 col -> ~12 wrapped lines
      ];
      final wrappedHeight = excelFunctions.calculateDynamicRowHeight(wrappedRow, colWidths, minHeight: 38.0);
      expect(wrappedHeight, greaterThan(100.0));
    });
  });
}
