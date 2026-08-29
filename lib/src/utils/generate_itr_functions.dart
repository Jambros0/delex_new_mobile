import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/file_download_util.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../features/ex_register/data/models/selectedFindings.dart';
import 'database_helper.dart';

String formatDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty || rawDate == "null") return '--';

  try {
    DateTime dateTime;
    if (rawDate.endsWith('Z')) {
      final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      dateTime = inputFormat.parseUtc(rawDate).toLocal();
    } else {
      final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      dateTime = inputFormat.parse(rawDate, true).toLocal();
    }

    final outputFormat = DateFormat('dd/MM/yyyy, hh:mm a');
    return outputFormat.format(dateTime);
  } catch (e) {
    return rawDate;
  }
}

class GenerateItrFunctions {
  final AuthUtils authUtils = AuthUtils();

  Future<pw.Font> loadFont(String fontPath) async {
    final fontData = await rootBundle.load(fontPath);
    return pw.Font.ttf(fontData);
  }

  Future<Uint8List?> parseSignature(dynamic rawSign) async {
    // 1. Try explicit rawSign passed into function
    if (rawSign != null) {
      final String str = rawSign.toString().trim();
      if (str.isNotEmpty && str != "null" && str != "undefined") {
        try {
          if (str.startsWith("data:image") || str.contains(";base64,")) {
            final String base64Data = str.split(',').last;
            return base64Decode(base64Data);
          }
          if (str.length > 100 && !str.contains('/') && !str.contains('\\')) {
            return base64Decode(str);
          }
          final file = File(str);
          if (await file.exists()) {
            return await file.readAsBytes();
          }
        } catch (_) {}
      }
    }

    // 2. Try DB logged in user signature
    try {
      final DBHelper dbHelper = DBHelper();
      final UserDetails? loggedInUser = await dbHelper.getLoggedInUser();
      if (loggedInUser?.signature != null && loggedInUser!.signature.isNotEmpty) {
        final String str = loggedInUser.signature.trim();
        if (str.startsWith("data:image") || str.contains(";base64,")) {
          final String base64Data = str.split(',').last;
          return base64Decode(base64Data);
        }
        final file = File(str);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    } catch (_) {}

    // 3. Try DB user by stored active userId
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id') ?? prefs.getString('userId');
      if (userId != null && userId.isNotEmpty) {
        final DBHelper dbHelper = DBHelper();
        final UserDetails? user = await dbHelper.getLoggedInUserByUserId(userId);
        if (user?.signature != null && user!.signature.isNotEmpty) {
          final String str = user.signature.trim();
          if (str.startsWith("data:image") || str.contains(";base64,")) {
            final String base64Data = str.split(',').last;
            return base64Decode(base64Data);
          }
          final file = File(str);
          if (await file.exists()) {
            return await file.readAsBytes();
          }
        }
      }
    } catch (_) {}

    // 4. Try local App Document Directory signature files
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filesToCheck = [
        'signature.png',
        'signature.jpg',
        'signature.jpeg',
        'user_signature.png',
        'user_signature.jpg',
      ];
      for (var name in filesToCheck) {
        final f = File('${directory.path}/$name');
        if (f.existsSync()) {
          return await f.readAsBytes();
        }
      }
    } catch (_) {}

    // 5. Try SharedPreferences saved signature strings
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedSign = prefs.getString('userSignature') ?? prefs.getString('inspectionSignOff') ?? prefs.getString('repairSignOff');
      if (savedSign != null && savedSign.isNotEmpty) {
        if (savedSign.startsWith("data:image") || savedSign.contains(";base64,")) {
          final String base64Data = savedSign.split(',').last;
          return base64Decode(base64Data);
        }
        final f = File(savedSign);
        if (await f.exists()) {
          return await f.readAsBytes();
        }
      }
    } catch (_) {}

    return null;
  }

  Future<Map<String, String>> generateItrPdf(
    Map<String, dynamic> assetDetails,
    List<Map<String, List<Map<String, dynamic>>>> checkListDetails,
    Map<String, int> totalData,
    Map<String, int> totalSelectedData,
    List<SelectedFindingsModel> selectedFindingsModel,
  ) async {
    final pdf = pw.Document();

    final DateTime now = DateTime.now();
    final String reportDate = DateFormat('dd/MM/yyyy').format(now);
    final String reportTime = DateFormat('hh:mm a').format(now);

    final String? userType = await authUtils.getUserType();
    final bool isOnshore = userType == "onshore";

    final robotoFont = await loadFont(
      'lib/src/features/ex_register/fonts/Roboto-Regular.ttf',
    );
    final interFont = await loadFont(
      'lib/src/features/ex_register/fonts/Inter_28pt-Regular.ttf',
    );

    // Signatures & Logged in user details
    final DBHelper dbHelper = DBHelper();
    final UserDetails? loggedInUser = await dbHelper.getLoggedInUser();

    Uint8List? signatureInImage = await parseSignature(assetDetails['inspectionSignOff']) ??
        await parseSignature(assetDetails['inspectorSignature']) ??
        await parseSignature(loggedInUser?.signature);

    Uint8List? signatureRepairImage = await parseSignature(assetDetails['repairSignOff']) ??
        await parseSignature(assetDetails['repairerSignature']) ??
        await parseSignature(loggedInUser?.signature);

    final String inspectedName = assetDetails['inspectorName']?.toString().isNotEmpty == true
        ? assetDetails['inspectorName'].toString()
        : (loggedInUser?.userName?.isNotEmpty == true ? loggedInUser!.userName : 'Test-${isOnshore ? 'onshore' : 'offshore'}');
    final String inspectedPos = assetDetails['inspectorPosition']?.toString().isNotEmpty == true
        ? assetDetails['inspectorPosition'].toString()
        : (loggedInUser?.userRole?.isNotEmpty == true ? loggedInUser!.userRole : 'admin-user');
    final String inspectedDate = assetDetails['inspectionDate'] != null ? formatDate(assetDetails['inspectionDate'].toString()) : formatDate(now.toIso8601String());

    final String repairedName = assetDetails['repairerName']?.toString().isNotEmpty == true
        ? assetDetails['repairerName'].toString()
        : (signatureRepairImage != null ? inspectedName : '--');
    final String repairedPos = assetDetails['repairerPosition']?.toString().isNotEmpty == true
        ? assetDetails['repairerPosition'].toString()
        : (signatureRepairImage != null ? inspectedPos : '--');
    final String repairedDate = assetDetails['repairDate'] != null ? formatDate(assetDetails['repairDate'].toString()) : (signatureRepairImage != null ? inspectedDate : '--');

    final String approvedName = assetDetails['approverName']?.toString() ?? '--';
    final String approvedPos = assetDetails['approverPosition']?.toString() ?? '--';
    final String approvedDate = assetDetails['approvedDate'] != null ? formatDate(assetDetails['approvedDate'].toString()) : '--';

    // Defect Findings and Remedial Actions Parsing
    List<Map<String, String>> defectFindingsList = [];
    List<Map<String, String>> correctiveActionsList = [];

    for (var model in selectedFindingsModel) {
      defectFindingsList.add({
        'code': model.defectCode.toString(),
        'finding': model.finding.toString(),
        'remedial': model.remedialAction.toString(),
      });
      if (model.isDone == true || model.remedialAction.toString().isNotEmpty) {
        correctiveActionsList.add({
          'code': model.defectCode.toString(),
          'remedial': model.remedialAction.toString(),
          'done': model.isDone == true ? 'yes' : 'no',
          'repairedBy': inspectedName,
          'date': inspectedDate,
        });
      }
    }

    if (assetDetails['checkList'] != null && assetDetails['checkList'] is List) {
      for (var category in assetDetails['checkList']) {
        if (category['defectCodes'] != null && category['defectCodes'] is List) {
          for (var subCategory in category['defectCodes']) {
            if (subCategory['findingsAndActions'] != null && subCategory['findingsAndActions'] is List) {
              for (var fa in subCategory['findingsAndActions']) {
                final String code = fa['defectCode']?.toString() ?? subCategory['defectCode']?.toString() ?? 'A';
                final String finding = fa['finding']?.toString() ?? '';
                final String remedial = fa['remedialAction']?.toString() ?? '';
                final bool isDone = fa['isDone'] == true;

                if (finding.isNotEmpty || remedial.isNotEmpty) {
                  if (!defectFindingsList.any((e) => e['code'] == code && e['finding'] == finding)) {
                    defectFindingsList.add({
                      'code': code,
                      'finding': finding,
                      'remedial': remedial,
                    });
                  }
                  if (!correctiveActionsList.any((e) => e['code'] == code && e['remedial'] == remedial)) {
                    correctiveActionsList.add({
                      'code': code,
                      'remedial': remedial,
                      'done': isDone ? 'yes' : 'no',
                      'repairedBy': inspectedName,
                      'date': inspectedDate,
                    });
                  }
                }
              }
            }
          }
        }
      }
    }

    // Default Baseline Master Checklist (18 Standard Inspection Checks)
    final Map<String, Map<String, dynamic>> allCheckItems = {
      'A1': {'code': 'A1', 'category': 'A', 'description': 'Equipment is appropriate to the EPL/Zone requirements of the location', 'isSelected': true},
      'A2': {'code': 'A2', 'category': 'A', 'description': 'Equipment group is correct', 'isSelected': true},
      'A3': {'code': 'A3', 'category': 'A', 'description': 'Equipment temperature class is correct', 'isSelected': true},
      'A4': {'code': 'A4', 'category': 'A', 'description': 'Degree of protection (IP grade) of equipment is appropriate for the level of protection/group/conductivity', 'isSelected': true},
      'A6': {'code': 'A6', 'category': 'A', 'description': 'Equipment/circuit identification is available', 'isSelected': true},
      'A7': {'code': 'A7', 'category': 'A', 'description': 'Enclosure, glass parts and glass-to-metal sealing gaskets and/or compounds are satisfactory', 'isSelected': true},
      'A9': {'code': 'A9', 'category': 'A', 'description': 'There is no evidence of unauthorized modifications', 'isSelected': true},
      'A10': {'code': 'A10', 'category': 'A', 'description': 'Bolts, cable entry devices (direct and indirect) and blanking elements are of the correct type and are complete, not damaged and tight', 'isSelected': true},
      'A11': {'code': 'A11', 'category': 'A', 'description': 'Threaded covers on enclosures are of the correct type, are tight and secured', 'isSelected': true},
      'A15': {'code': 'A15', 'category': 'A', 'description': 'Dimensions of flange joint gaps are within maximum values permitted', 'isSelected': true},
      'A22': {'code': 'A22', 'category': 'A', 'description': 'Breathing and draining devices are satisfactory', 'isSelected': true},
      'B2': {'code': 'B2', 'category': 'B', 'description': 'There is no obvious damage to cables', 'isSelected': true},
      'B3': {'code': 'B3', 'category': 'B', 'description': 'Sealing of trunking, ducts, pipes and/or conduits is satisfactory', 'isSelected': true},
      'B6': {'code': 'B6', 'category': 'B', 'description': 'Earthing connections, including any supplementary earthing bonding connections are satisfactory', 'isSelected': true},
      'B12': {'code': 'B12', 'category': 'B', 'description': 'Obstructions adjacent to flameproof flanged joints are in accordance with IEC 60079-14', 'isSelected': true},
      'B13': {'code': 'B13', 'category': 'B', 'description': 'Variable voltage/frequency installation complies with documentation', 'isSelected': true},
      'C1': {'code': 'C1', 'category': 'C', 'description': 'Equipment is adequately protected against corrosion, weather, vibration and other adverse factors', 'isSelected': true},
      'C2': {'code': 'C2', 'category': 'C', 'description': 'No undue accumulation of dust and dirt', 'isSelected': true},
    };

    // Merge checkListDetails parameter items & newly created rows
    for (var chunk in checkListDetails) {
      for (var entry in chunk.entries) {
        final groupKey = entry.key.toUpperCase();
        for (var item in entry.value) {
          final String code = item['defectCode']?.toString() ?? item['code']?.toString() ?? '';
          if (code.isNotEmpty) {
            final String desc = item['checkListGroup']?.toString() ?? item['description']?.toString() ?? '';
            allCheckItems[code] = {
              'code': code,
              'category': groupKey,
              'description': desc.isNotEmpty ? desc : (allCheckItems[code]?['description'] ?? ''),
              'selection': item['selection']?.toString() ?? 'yes',
              'isSelected': true,
            };
          }
        }
      }
    }

    // Merge saved assetDetails['checkList'] states and newly created rows
    if (assetDetails['checkList'] != null && assetDetails['checkList'] is List) {
      for (var category in assetDetails['checkList']) {
        if (category['defectCodes'] != null && category['defectCodes'] is List) {
          for (var item in category['defectCodes']) {
            final String code = item['defectCode']?.toString() ?? item['code']?.toString() ?? '';
            if (code.isNotEmpty) {
              final String cat = item['defectCategory']?.toString() ?? code.substring(0, 1);
              final String desc = item['checkListGroup']?.toString() ?? item['description']?.toString() ?? '';
              final String sel = item['selection']?.toString().toLowerCase() ?? '';
              final bool isDone = item['isDone'] == true;

              bool hasDefect = defectFindingsList.any((d) => d['code'] == code);
              bool isPassed = true;
              if (sel == 'no' || sel == 'fail' || (hasDefect && !isDone)) {
                isPassed = false;
              }

              if (allCheckItems.containsKey(code)) {
                allCheckItems[code]!['selection'] = sel;
                allCheckItems[code]!['isSelected'] = isPassed;
                if (desc.isNotEmpty) allCheckItems[code]!['description'] = desc;
              } else {
                allCheckItems[code] = {
                  'code': code,
                  'category': cat.toUpperCase(),
                  'description': desc,
                  'selection': sel,
                  'isSelected': isPassed,
                };
              }
            }
          }
        }
      }
    }

    List<Map<String, dynamic>> groupAChecks = [];
    List<Map<String, dynamic>> groupBChecks = [];
    List<Map<String, dynamic>> groupCChecks = [];

    allCheckItems.forEach((code, item) {
      final cat = item['category']?.toString().toUpperCase() ?? code.substring(0, 1).toUpperCase();
      if (cat == 'B') {
        groupBChecks.add(item);
      } else if (cat == 'C') {
        groupCChecks.add(item);
      } else {
        groupAChecks.add(item);
      }
    });

    int parseCodeNum(String code) {
      final numStr = code.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(numStr) ?? 0;
    }

    groupAChecks.sort((a, b) => parseCodeNum(a['code']).compareTo(parseCodeNum(b['code'])));
    groupBChecks.sort((a, b) => parseCodeNum(a['code']).compareTo(parseCodeNum(b['code'])));
    groupCChecks.sort((a, b) => parseCodeNum(a['code']).compareTo(parseCodeNum(b['code'])));

    int totalChecks = groupAChecks.length + groupBChecks.length + groupCChecks.length;
    int passedCount = 0;
    int failedCount = 0;
    int naCount = 0;
    int notCheckedCount = 0;

    void countChecklistResults(List<Map<String, dynamic>> items) {
      for (var item in items) {
        if (item['isSelected'] == true) {
          passedCount++;
        } else {
          failedCount++;
        }
      }
    }

    countChecklistResults(groupAChecks);
    countChecklistResults(groupBChecks);
    countChecklistResults(groupCChecks);

    if (totalChecks == 0) totalChecks = 18;
    final double passPercentage = (passedCount / totalChecks) * 100;
    final String reportId = assetDetails['equipmentId']?.toString() ?? assetDetails['exId']?.toString() ?? assetDetails['tagNo']?.toString() ?? 'DEX-ITR-REPORT';

    // Header Banner Widget
    pw.Widget buildHeaderBanner() {
      return pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#0B1C33')),
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#1E293B'),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(text: 'Del', style: pw.TextStyle(color: PdfColor.fromHex('#EF4444'), fontSize: 15, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                            pw.TextSpan(text: 'Ex', style: pw.TextStyle(color: PdfColors.white, fontSize: 15, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Explosion Protection', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold, font: interFont)),
                        pw.Text('Management System', style: pw.TextStyle(color: PdfColor.fromHex('#94A3B8'), fontSize: 7, font: interFont)),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Ex Inspection Test Report', style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                    pw.SizedBox(height: 2),
                    pw.Text('Explosion Proof (Ex) Equipment - Inspection & Repair Works At DPE Facilities', style: pw.TextStyle(color: PdfColor.fromHex('#94A3B8'), fontSize: 8.5, font: interFont)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#071527'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Text('CLIENT\'S NAME : ', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 7.5, fontWeight: pw.FontWeight.bold, font: interFont)),
                      pw.Text('Dubai Petroleum Establishment', style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Text('CONTRACTOR\'S NAME : ', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 7.5, fontWeight: pw.FontWeight.bold, font: interFont)),
                      pw.Text('Delta Solutions Engineering Services', style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildMetadataCardBar() {
      return pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('REPORT GENERATED ON', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6.5, fontWeight: pw.FontWeight.bold, font: interFont)),
                  pw.SizedBox(height: 2),
                  pw.Text(reportDate, style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 9, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('REPORT TIME', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6.5, fontWeight: pw.FontWeight.bold, font: interFont)),
                  pw.SizedBox(height: 2),
                  pw.Text(reportTime, style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 9, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('GENERATED BY', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6.5, fontWeight: pw.FontWeight.bold, font: interFont)),
                  pw.SizedBox(height: 2),
                  pw.Text('DelEx Software', style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 9, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    pw.Widget buildCardHeader(String title) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F1F5F9'),
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(6),
            topRight: pw.Radius.circular(6),
          ),
        ),
        child: pw.Text(
          title,
          style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 8.5, fontWeight: pw.FontWeight.bold, font: robotoFont, letterSpacing: 0.5),
        ),
      );
    }

    pw.Widget buildInfoRow(String label, dynamic value) {
      String displayVal = '--';
      if (value != null) {
        if (value is List) {
          displayVal = value.isNotEmpty ? value.join(', ') : '--';
        } else {
          final str = value.toString().trim();
          if (str.isNotEmpty && str != "null") displayVal = str;
        }
      }

      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 4,
              child: pw.Text(label, style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 7, font: interFont)),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(
              flex: 5,
              child: pw.Text(displayVal, style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 7.5, fontWeight: pw.FontWeight.bold, font: robotoFont), textAlign: pw.TextAlign.right),
            ),
          ],
        ),
      );
    }

    // Top Cards
    pw.Widget buildAreaDetailsCard() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildCardHeader('AREA DETAILS'),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                children: [
                  buildInfoRow(isOnshore ? 'Location' : 'Field Name', assetDetails['location']),
                  buildInfoRow(isOnshore ? 'Sub Location' : 'Platform', assetDetails['area']),
                  buildInfoRow(isOnshore ? 'Area' : 'Deck Level', assetDetails['deckLevel']),
                  buildInfoRow('Sub Area (Nearest Landmark)', assetDetails['subArea']),
                  buildInfoRow('Zone', assetDetails['zone']),
                  buildInfoRow('Gas Group', assetDetails['locationGasGroup']),
                  buildInfoRow('Temperature Class', assetDetails['locationTClass']),
                  buildInfoRow('GPS Coordinates', assetDetails['gpsCord']),
                  buildInfoRow('Area Status', assetDetails['areaStatus'] ?? 'Green'),
                  buildInfoRow('Area Classification Drawing Number', assetDetails['areaClassDrawAttachOrgName']),
                  buildInfoRow('Equipment Layout Drawing Number', assetDetails['eqpmtLytDrawAttachOrgName']),
                ],
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildEquipmentTagsCard() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildCardHeader('EQUIPMENT TAGS'),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                children: [
                  buildInfoRow('RFID Reference', assetDetails['rfid']),
                  buildInfoRow('Inspection Reference', assetDetails['equipmentId'] ?? assetDetails['exId']),
                  buildInfoRow('GPS Coordinates', assetDetails['gpsCord']),
                  buildInfoRow('Discipline', assetDetails['discipline'] ?? 'Instrumentation'),
                  buildInfoRow('Equipment Tag Number', assetDetails['tagNo']),
                  buildInfoRow('Equipment Description', assetDetails['description']),
                  buildInfoRow('Equipment Category', assetDetails['category']),
                  buildInfoRow('Cable Tag Number', assetDetails['cableTagNo']),
                  buildInfoRow('Oracle ID', assetDetails['oracleId']),
                  buildInfoRow('Equipment Manufacturer', assetDetails['manufacturer']),
                  buildInfoRow('Equipment Type / Model', assetDetails['typeModel']),
                  buildInfoRow('Equipment Serial Number', assetDetails['serialNo']),
                ],
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildEquipmentCertCard() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildCardHeader('EQUIPMENT CERTIFICATION'),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                children: [
                  buildInfoRow('Protection Standard', assetDetails['protectionStandard'] ?? 'NEC'),
                  buildInfoRow('ATEX Category (If Applicable)', assetDetails['atexCategory'] ?? 'Not Applicable'),
                  buildInfoRow('EPL', assetDetails['epl'] ?? 'Not Applicable'),
                  buildInfoRow('Protection Type', assetDetails['protectionType']),
                  buildInfoRow('Gas Group', assetDetails['certGasGroup']),
                  buildInfoRow('Temperature Class', assetDetails['certTempClass']),
                  buildInfoRow('IP Rating', assetDetails['ipRating']),
                  buildInfoRow('Ambient Temperature', assetDetails['tAmbient']),
                  buildInfoRow('Certification Body', assetDetails['certificationBody']),
                  buildInfoRow('Certification Number', assetDetails['certificateNo']),
                  buildInfoRow('Special Conditions', assetDetails['specialConditions']),
                  buildInfoRow('Equipment Status', assetDetails['equipmentStatus']),
                ],
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildInspectionScoreCard() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildCardHeader('INSPECTION SCORE'),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                children: [
                  pw.Center(
                    child: pw.Container(
                      width: 68,
                      height: 68,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: PdfColor.fromHex('#10B981'), width: 4),
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('$passedCount/$totalChecks', style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 12, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                          pw.Text('PASSED', style: pw.TextStyle(color: PdfColor.fromHex('#10B981'), fontSize: 6, fontWeight: pw.FontWeight.bold, font: interFont)),
                          pw.Text('${passPercentage.toStringAsFixed(1)}%', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6.5, font: interFont)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  buildInfoRow('Passed', passedCount),
                  buildInfoRow('Failed / Defects', failedCount),
                  buildInfoRow('Not Applicable', naCount),
                  buildInfoRow('Not Checked', notCheckedCount),
                  pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 0.5),
                  buildInfoRow('Total Checks', totalChecks),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Checklist Column Builder with (failedCount/totalCount)
    pw.Widget buildChecklistColumn(String title, List<Map<String, dynamic>> items) {
      int failedInGroup = items.where((e) => e['isSelected'] == false).length;

      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              color: PdfColor.fromHex('#F1F5F9'),
              child: pw.Text(
                '$title ($failedInGroup/${items.length})',
                style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 7.5, fontWeight: pw.FontWeight.bold, font: robotoFont),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(24),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(22),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('CODE', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6, fontWeight: pw.FontWeight.bold, font: interFont)),
                      pw.Text('DESCRIPTION', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6, fontWeight: pw.FontWeight.bold, font: interFont)),
                      pw.Text('RESULT', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6, fontWeight: pw.FontWeight.bold, font: interFont), textAlign: pw.TextAlign.center),
                    ],
                  ),
                  ...items.map((item) {
                    final code = item['code']?.toString() ?? 'A';
                    final desc = item['description']?.toString() ?? '';
                    final isPass = item['isSelected'] == true;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Text(code, style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 6.5, fontWeight: pw.FontWeight.bold, font: robotoFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Text(desc, style: pw.TextStyle(color: PdfColor.fromHex('#334155'), fontSize: 6, font: interFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Center(
                            child: pw.Container(
                              width: 9,
                              height: 9,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                color: isPass ? PdfColor.fromHex('#10B981') : PdfColor.fromHex('#EF4444'),
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  isPass ? 'v' : 'x',
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 5.5, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildChecklistSection() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              color: PdfColor.fromHex('#0B1C33'),
              child: pw.Text(
                'INSPECTION CHECKLIST',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold, font: robotoFont, letterSpacing: 0.5),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: buildChecklistColumn('A. GENERAL EQUIPMENT CHECKS', groupAChecks)),
                  pw.SizedBox(width: 6),
                  pw.Expanded(child: buildChecklistColumn('B. GENERAL INSTALLATION CHECKS', groupBChecks)),
                  pw.SizedBox(width: 6),
                  pw.Expanded(child: buildChecklistColumn('C. ENVIRONMENT CHECKS', groupCChecks)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Summary & Corrective Actions
    pw.Widget buildInspectionSummaryCard() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildCardHeader('INSPECTION SUMMARY'),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(45),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('CODE', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6, fontWeight: pw.FontWeight.bold, font: interFont))),
                          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('FINDINGS', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6, fontWeight: pw.FontWeight.bold, font: interFont))),
                          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('REMEDIAL ACTION', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 6, fontWeight: pw.FontWeight.bold, font: interFont))),
                        ],
                      ),
                      if (defectFindingsList.isEmpty)
                        pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('--', style: pw.TextStyle(fontSize: 6, font: interFont))),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('No findings recorded', style: pw.TextStyle(fontSize: 6, color: PdfColor.fromHex('#94A3B8'), font: interFont))),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('--', style: pw.TextStyle(fontSize: 6, font: interFont))),
                          ],
                        )
                      else
                        ...defectFindingsList.map((item) {
                          return pw.TableRow(
                            children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(item['code'] ?? '', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, font: robotoFont))),
                              pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(item['finding'] ?? '', style: pw.TextStyle(fontSize: 6, font: interFont))),
                              pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(item['remedial'] ?? '', style: pw.TextStyle(fontSize: 6, font: interFont))),
                            ],
                          );
                        }).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  buildInfoRow('FAULTY ITEMS', assetDetails['faultyItems']),
                  buildInfoRow('REPAIR PRIORITY', assetDetails['inspectionPriority']),
                  buildInfoRow('INSPECTION STATUS', assetDetails['inspectionStatus'] ?? 'Green'),
                  buildInfoRow('OVERALL CONDITION', assetDetails['defectOverallCondition'] ?? 'Good to Use'),
                  buildInfoRow('REPAIR DURATION (MINUTES)', assetDetails['repairDuration']),
                  buildInfoRow('ISOLATION FOR REPAIRS', assetDetails['defectIsolation']),
                  buildInfoRow('OTHER REQUIREMENTS', assetDetails['defectOtherRequirements']),
                  buildInfoRow('ADDITIONAL INFORMATION FOR REPAIRS', assetDetails['defectAdditionalInfo']),
                ],
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildCorrectiveActionsCard() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildCardHeader('CORRECTIVE ACTIONS'),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(35),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FixedColumnWidth(25),
                      3: const pw.FlexColumnWidth(1.5),
                      4: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('CODE', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 5.5, fontWeight: pw.FontWeight.bold, font: interFont))),
                          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('REMEDIAL ACTIONS', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 5.5, fontWeight: pw.FontWeight.bold, font: interFont))),
                          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('DONE', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 5.5, fontWeight: pw.FontWeight.bold, font: interFont), textAlign: pw.TextAlign.center)),
                          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('REPAIRED BY', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 5.5, fontWeight: pw.FontWeight.bold, font: interFont))),
                          pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('DATE', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 5.5, fontWeight: pw.FontWeight.bold, font: interFont))),
                        ],
                      ),
                      if (correctiveActionsList.isEmpty)
                        pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('--', style: pw.TextStyle(fontSize: 5.5, font: interFont))),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('No corrective actions recorded', style: pw.TextStyle(fontSize: 5.5, color: PdfColor.fromHex('#94A3B8'), font: interFont))),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('--', style: pw.TextStyle(fontSize: 5.5, font: interFont), textAlign: pw.TextAlign.center)),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('--', style: pw.TextStyle(fontSize: 5.5, font: interFont))),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('--', style: pw.TextStyle(fontSize: 5.5, font: interFont))),
                          ],
                        )
                      else
                        ...correctiveActionsList.map((item) {
                          final bool isDone = item['done'] == 'yes';
                          return pw.TableRow(
                            children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(item['code'] ?? '', style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold, font: robotoFont))),
                              pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(item['remedial'] ?? '', style: pw.TextStyle(fontSize: 5.5, font: interFont))),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Center(
                                  child: pw.Text(
                                    isDone ? 'v' : 'x',
                                    style: pw.TextStyle(color: isDone ? PdfColor.fromHex('#10B981') : PdfColor.fromHex('#EF4444'), fontSize: 6, fontWeight: pw.FontWeight.bold),
                                  ),
                                ),
                              ),
                              pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(item['repairedBy'] ?? '--', style: pw.TextStyle(fontSize: 5.5, font: interFont))),
                              pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(item['date'] ?? '--', style: pw.TextStyle(fontSize: 5.5, font: interFont))),
                            ],
                          );
                        }).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  buildInfoRow('EXISTING FAULTS', assetDetails['existingFaults']),
                  buildInfoRow('DEFECT CATEGORY', assetDetails['defectCategory'] ?? 'Not Applicable'),
                  buildInfoRow('CURRENT STATUS', assetDetails['currentStatus'] ?? 'Green'),
                  buildInfoRow('CURRENT CONDITION', assetDetails['currentCondition'] ?? 'Good to Use'),
                  buildInfoRow('COMPLETED REPAIRS', assetDetails['completedRepairs'] ?? '0'),
                  buildInfoRow('REPAIR TIME ESTIMATE (MINUTES)', assetDetails['repairTimeEstimate']),
                  buildInfoRow('ISOLATION REQUIREMENTS', assetDetails['isolationRequirements']),
                  buildInfoRow('OTHER REQUIREMENTS', assetDetails['otherRequirements']),
                  buildInfoRow('REMARKS IF ANY', assetDetails['remarks']),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Approvals Section
    pw.Widget buildApprovalsSection() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildCardHeader('APPROVALS'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, font: robotoFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('INSPECTED BY', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, font: robotoFont), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('REPAIRED BY', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, font: robotoFont), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('REVIEWED & APPROVED BY', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, font: robotoFont), textAlign: pw.TextAlign.center)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Signature', style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#64748B'), font: interFont))),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: signatureInImage != null
                          ? pw.Center(child: pw.Image(pw.MemoryImage(signatureInImage), height: 18, fit: pw.BoxFit.contain))
                          : pw.Center(child: pw.Text('--', style: pw.TextStyle(fontSize: 6.5, font: interFont))),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: signatureRepairImage != null
                          ? pw.Center(child: pw.Image(pw.MemoryImage(signatureRepairImage), height: 18, fit: pw.BoxFit.contain))
                          : pw.Center(child: pw.Text('--', style: pw.TextStyle(fontSize: 6.5, font: interFont))),
                    ),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Center(child: pw.Text('--', style: pw.TextStyle(fontSize: 6.5, font: interFont)))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Name', style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#64748B'), font: interFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(inspectedName, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(repairedName, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(approvedName, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Position', style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#64748B'), font: interFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(inspectedPos, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(repairedPos, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(approvedPos, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Date', style: pw.TextStyle(fontSize: 6.5, color: PdfColor.fromHex('#64748B'), font: interFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(inspectedDate, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(repairedDate, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(approvedDate, style: pw.TextStyle(fontSize: 6.5, font: robotoFont))),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Footer
    pw.Widget buildFooterBar(int pageNum, int totalPagesCount) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#E2E8F0'), width: 0.5)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'DelEx Explosion Protection Management System',
              style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 7.5, fontWeight: pw.FontWeight.bold, font: robotoFont),
            ),
            pw.Text(
              'Report ID : $reportId',
              style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 7.5, font: interFont),
            ),
            pw.Text(
              'PAGE $pageNum OF $totalPagesCount',
              style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 7.5, font: interFont),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(816, 1180, marginAll: 16),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeaderBanner(),
            pw.SizedBox(height: 6),
            buildMetadataCardBar(),
            pw.SizedBox(height: 6),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: buildAreaDetailsCard()),
                pw.SizedBox(width: 6),
                pw.Expanded(child: buildEquipmentTagsCard()),
                pw.SizedBox(width: 6),
                pw.Expanded(child: buildEquipmentCertCard()),
                pw.SizedBox(width: 6),
                pw.Expanded(child: buildInspectionScoreCard()),
              ],
            ),
            pw.SizedBox(height: 6),
            buildChecklistSection(),
            pw.SizedBox(height: 6),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: buildInspectionSummaryCard()),
                pw.SizedBox(width: 6),
                pw.Expanded(child: buildCorrectiveActionsCard()),
              ],
            ),
            pw.SizedBox(height: 6),
            buildApprovalsSection(),
            pw.Spacer(),
            buildFooterBar(1, 1),
          ],
        ),
      ),
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = "Inspection_Itr_Report_$timestamp.pdf";
    final downloadPath = await FileDownloadUtil().getExternalDocumentPath();
    final downloadFile = File("$downloadPath/$fileName");

    await downloadFile.writeAsBytes(await pdf.save());
    if (!await downloadFile.exists()) {
      throw Exception("Failed to create the PDF file.");
    }
    final result = await OpenFilex.open(downloadFile.path);
    if (result.type != ResultType.done) {
      throw Exception("Failed to open PDF: ${result.message}");
    }
    return {"location": downloadFile.path};
  }
}
