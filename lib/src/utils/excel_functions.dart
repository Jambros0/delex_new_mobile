// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import '../features/functional_areas/data/models/location_model.dart';
import 'file_download_util.dart';

// String formatInspectedDate(String? date) {
//   if (date == null || date.trim().isEmpty) {
//     return "";
//   }

//   try {
//     final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
//     final dateTime = inputFormat.parse(date);

//     final outputFormat = DateFormat("dd-MM-yyyy hh:mm a");
//     return outputFormat.format(dateTime);
//   } catch (e) {
//     return "";
//   }
// }

class ExcelFunctions {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final AuthUtils authUtils = AuthUtils();

  String formatInspectedDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';

    try {
      final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      final dateTime = inputFormat.parse(rawDate);
      final outputFormat = DateFormat('dd-MM-yyyy hh:mm a');
      return outputFormat.format(dateTime);
    } catch (e) {
      return '';
    }
  }

  Future<void> initialize() async {
    final String? userType = await authUtils.getUserType();
    if (userType == 'onshore') {
      locationExcelHeaders = [
        'S.No',
        'Location',
        'Sub Location',
        'Area',
        'Sub Area (Nearest Landmark)',
        'GPS Coordinates',
        'Zone',
        'Gas Group',
        'Temperature Class',
        // 'Area T-Ambient(Min °C) to (Max °C)',
        // 'Area T-Ambient(Max °C)',
        'Area Classification Drawing Number',
        'Equipment Layout Drawing Number',
      ];
    } else {
      locationExcelHeaders = [
        'S.No',
        'Field Name',
        'Platform',
        'Deck Level',
        'Sub Area (Nearest Landmark)',
        'GPS Coordinates',
        'Zone',
        'Gas Group',
        'Temperature Class',
        // 'Area T-Ambient(Max °C) to (Max °C)',
        // 'Area T-Ambient(Max °C)',
        'Area Classification Drawing Number',
        'Equipment Layout Drawing Number',
      ];
    }
    if (userType == 'onshore') {
      assetExcelHeaders = [
        'Sl.No',
        'RFID\nReference',
        'Inspection\nReference',
        'Location',
        'Sub Location',
        'Area',
        'Sub Area (Nearest Landmark)',
        'GPS Coordinates',
        'Zone',
        'Gas Group',
        'Temperature\nClass',
        // 'IP Rating',
        // 'T-Ambient\n(Min °C) to (Max °C)',
        // 'T-Ambient\n(Max °C)',
        'Area Classification\nDrawing Number',
        'Equipment Layout\nDrawing Number',
        'Area Status',
        'Discipline',
        'GPS\nCoordinates',
        'Equipment Tag Number',
        'Cable Tag Number',
        'Oracle ID',
        'Equipment\nDescription',
        'Equipment Category',
        'Manufacturer',
        'Type/Model',
        'Serial Number',
        'Equipment Status',
        'ATEX Category',
        'EPL',
        'Protection\nStandard',
        'Protection Type',
        'Equipment\nGas Group',
        'Temperature Class',
        'Equipment IP Rating',
        'T-Ambient\n(Min °C) to (Max °C)',
        // 'T-Ambient (Max °C)',
        'Certification Body',
        'Certification\nNumber',
        'Special Conditions',
        'Inspection Type',
        'Equipment Type',
        'Inspection\nChecklist',
        'Inspection Grade',
        'Findings',
        'Remedial Actions',
        'Inspection\nPhotos',
        // 'Equipment\nCriticality',
        // 'Fault Category',
        // 'Fault History',
        // 'Equipment\nAgeing',
        // 'Environmental\nSeverity',
        // 'Flammable\nAtmosphere',
        // 'Ignition Source',
        // 'Ignition Risk',
        // 'Operational\nImpact',
        'Faulty Items',
        'Repair Priority',
        'Inspection\nStatus',
        'Overall Condition',
        'Repair Duration\n(Minutes)',
        'Isolation for\nRepairs',
        'Other Requirements',
        'Additional\nInformation for Repairs',
        'Equipment Data Sheet',
        'Material\nRequirements',
        'Inspected By',
        'Inspected Date',
        'Repairs Done',
        'Existing Faults',
        'Defect Category',
        'Current Status',
        'Current Condition',
        'Completed Repairs',
        'Repair Time Estimate',
        'Isolation\nRequirements',
        'Other\nRequirements',
        'Supplementary\nMaterial',
        'Remarks if any',
        'Current\nPhotos',
        'Repaired By',
        'Repaired Date',
      ];
    } else {
      assetExcelHeaders = [
        'Sl.No',
        'RFID\nReference',
        'Inspection\nReference',
        'Field Name',
        'Platform',
        'Deck Level',
        'Sub Area (Nearest Landmark)',
        'GPS Coordinates',
        'Zone',
        'Gas Group',
        'Temperature\nClass',
        // 'IP Rating',
        // 'T-Ambient\n(Min °C) to (Max °C)',
        // 'T-Ambient\n(Max °C)',
        'Area Classification\nDrawing Number',
        'Equipment Layout\nDrawing Number',
        'Area Status',
        'Discipline',
        'GPS\nCoordinates',
        'Equipment Tag Number',
        'Cable Tag Number',
        'Oracle ID',
        'Equipment\nDescription',
        'Equipment Category',
        'Manufacturer',
        'Type/Model',
        'Serial Number',
        'Equipment Status',
        'ATEX Category',
        'EPL',
        'Protection\nStandard',
        'Protection Type',
        'Equipment\nGas Group',
        'Temperature Class',
        'Equipment IP Rating',
        'T-Ambient\n(Min °C) to (Max °C)',
        // 'T-Ambient (Max °C)',
        'Certification Body',
        'Certification\nNumber',
        'Special Conditions',
        'Inspection Type',
        'Equipment Type',
        'Inspection\nChecklist',
        'Inspection Grade',
        'Findings',
        'Remedial Actions',
        'Inspection\nPhotos',
        // 'Equipment\nCriticality',
        // 'Fault Category',
        // 'Fault History',
        // 'Equipment\nAgeing',
        // 'Environmental\nSeverity',
        // 'Flammable\nAtmosphere',
        // 'Ignition Source',
        // 'Ignition Risk',
        // 'Operational\nImpact',
        'Faulty Items',
        'Repair Priority',
        'Inspection\nStatus',
        'Overall Condition',
        'Repair Duration\n(Minutes)',
        'Isolation for\nRepairs',
        'Other Requirements',
        'Additional\nInformation for Repairs',
        'Equipment Data Sheet',
        'Material\nRequirements',
        'Inspected By',
        'Inspected Date',
        'Repairs Done',
        'Existing Faults',
        'Defect Category',
        'Current Status',
        'Current Condition',
        'Completed Repairs',
        'Repair Time Estimate',
        'Isolation\nRequirements',
        'Other\nRequirements',
        'Supplementary\nMaterial',
        'Remarks if any',
        'Current\nPhotos',
        'Repaired By',
        'Repaired Date',
      ];
    }
  }

  List<String> locationExcelHeaders = [];
  List<String> assetExcelHeaders = [];

  ExcelFunctions() {
    initialize();
  }

  Future<Map<String, dynamic>> downloadAssetExcel(
    List<ExRegister> assets,
  ) async {
    await initialize();
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Ex Register'];
    sheetObject.setRowHeight(0, 18);
    sheetObject.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('BQ1'),
    );
    var headerCell = sheetObject.cell(CellIndex.indexByString('A1'));
    headerCell.value = TextCellValue("Ex Inspection Register"); // Header text
    headerCell.cellStyle = CellStyle(
      fontColorHex: ExcelColor.blue,
      fontSize: 15,
      fontFamily: getFontFamily(FontFamily.Calibri),
      bold: true,
      verticalAlign: VerticalAlign.Top,
      horizontalAlign: HorizontalAlign.Left,
      bottomBorder: Border(borderColorHex: ExcelColor.white),
      topBorder: Border(borderColorHex: ExcelColor.white),
      rightBorder: Border(borderColorHex: ExcelColor.white),
      leftBorder: Border(borderColorHex: ExcelColor.white),
    );
    // End of Main Header

    // Sub Header
    sheetObject.setRowHeight(1, 54);
    sheetObject.merge(
      CellIndex.indexByString('A2'),
      CellIndex.indexByString('BQ2'),
    );
    DateTime now = DateTime.now();
    String formattedDate =
        // DateFormat("dd-MM-yyyy hh:mm a")
        //     .format(now);
        DateFormat("dd MMM yy HH:mm 'Hrs'").format(now);
    // String formattedDate =
    //     "${now.day.toString().padLeft(2, '0')} ${now.month == 1 ? 'Jan' : now.month == 2 ? 'Feb' : now.month == 3 ? 'Mar' : now.month == 4 ? 'Apr' : now.month == 5 ? 'May' : now.month == 6 ? 'Jun' : now.month == 7 ? 'Jul' : now.month == 8 ? 'Aug' : now.month == 9 ? 'Sep' : now.month == 10 ? 'Oct' : now.month == 11 ? 'Nov' : 'Dec'} ${now.year.toString().substring(2)} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} Hrs";
    var subHeader = sheetObject.cell(CellIndex.indexByString('A2'));
    subHeader.value = TextCellValue('''
    Project Name\t:\tExplosion Proof (EX) Equipment - Inspection & Repair Works at DPE Facilities
    Client\t\t\t:\tDubai Petroleum Establishment
    Contractor\t\t:\tDelta Solutions Engineering Services
    Date Updated\t:\t$formattedDate
    ''');
    var subHeaderStyle = CellStyle(
      textWrapping: TextWrapping.WrapText,
      bottomBorder: Border(borderColorHex: ExcelColor.white),
      topBorder: Border(borderColorHex: ExcelColor.white),
      rightBorder: Border(borderColorHex: ExcelColor.white),
      leftBorder: Border(borderColorHex: ExcelColor.white),
    );
    subHeaderStyle.fontSize = 7;
    var text = subHeader.value as TextCellValue;
    String alignedText = text.value.toString().split('\n').map((line) {
      if (line.trim().isEmpty) return line;
      return '  $line';
    }).join('\n');
    subHeader.value = TextCellValue(alignedText);
    for (int colIndex = 0; colIndex <= 67; colIndex++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1),
      );
      cell.cellStyle = subHeaderStyle;
    }
    // End of Sub Header

    // Asset Header
    // Section Headers
    sheetObject.cell(CellIndex.indexByString("A3")).value = TextCellValue(
      'Equipment References',
    );
    sheetObject.merge(
      CellIndex.indexByString("A3"),
      CellIndex.indexByString("C3"),
    );
    sheetObject.cell(CellIndex.indexByString("A3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue800,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      fontColorHex: ExcelColor.white38,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("D3")).value = TextCellValue(
      'Area Details',
    );
    sheetObject.merge(
      CellIndex.indexByString("D3"),
      CellIndex.indexByString("N3"),
    );
    sheetObject.cell(CellIndex.indexByString("D3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue600,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("O3")).value = TextCellValue(
      'Equipment Tag Details',
    );
    sheetObject.merge(
      CellIndex.indexByString("O3"),
      CellIndex.indexByString("Y3"),
    );
    sheetObject.cell(CellIndex.indexByString("O3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue400,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("Z3")).value = TextCellValue(
      'Ex Protection Details',
    );
    sheetObject.merge(
      CellIndex.indexByString("Z3"),
      CellIndex.indexByString("AJ3"),
    );
    sheetObject.cell(CellIndex.indexByString("Z3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue200,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("AK3")).value = TextCellValue(
      'Inspection Overview',
    );
    sheetObject.merge(
      CellIndex.indexByString("AK3"),
      CellIndex.indexByString("BC3"),
    );
    sheetObject.cell(CellIndex.indexByString("AK3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue100,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("BD3")).value = TextCellValue(
      'Corrective Actions',
    );
    sheetObject.merge(
      CellIndex.indexByString("BD3"),
      CellIndex.indexByString("BQ3"),
    );
    sheetObject.cell(CellIndex.indexByString("BD3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue50,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );
    // End of Section Headers

    // Asset Sub Header
    CellStyle assetSubHeaderCell = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 6,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
      backgroundColorHex: ExcelColor.grey200,
      bottomBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      topBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      rightBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      leftBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
    );

    for (int i = 0; i < assetExcelHeaders.length; i++) {
      sheetObject
          .cell(CellIndex.indexByString("${intToExcelColumn(i)}4"))
          .value = TextCellValue(
        assetExcelHeaders[i],
      );
      sheetObject
          .cell(CellIndex.indexByString("${intToExcelColumn(i)}4"))
          .cellStyle = assetSubHeaderCell;
    }
    // End of Asset Sub Header

    // Column Widths
    for (int colIndex = 0; colIndex < assetExcelHeaders.length; colIndex++) {
      sheetObject.setColumnWidth(colIndex, 14);
    }
    sheetObject.setColumnWidth(0, 5); // Sl.No
    sheetObject.setColumnWidth(1, 15); // RFID
    sheetObject.setColumnWidth(2, 15); // Inspection Ref
    sheetObject.setColumnWidth(19, 20); // Description
    sheetObject.setColumnWidth(40, 25); // Findings
    sheetObject.setColumnWidth(41, 25); // Remedial Actions
    sheetObject.setColumnWidth(42, 20); // Photos
    sheetObject.setColumnWidth(52, 25); // Material Requirements
    sheetObject.setColumnWidth(55, 25); // Repairs Done
    sheetObject.setColumnWidth(64, 25); // Supplementary Material
    sheetObject.setColumnWidth(66, 20); // Current Photos

    CellStyle defaultCell({
      int fontSize = 5,
      HorizontalAlign align = HorizontalAlign.Center,
      bool bold = false,
      bool wrap = true,
      dynamic bgHex,
    }) {
      return CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: fontSize,
        horizontalAlign: align,
        verticalAlign: VerticalAlign.Center,
        bold: bold,
        textWrapping: wrap ? TextWrapping.WrapText : TextWrapping.Clip,
        backgroundColorHex: bgHex ?? ExcelColor.white,
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        topBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
      );
    }

    CellStyle statusCell(String status) {
      dynamic bg = ExcelColor.white;
      if (status == "Yellow") {
        bg = ExcelColor.yellow;
      } else if (status == "Red") {
        bg = ExcelColor.red;
      } else if (status == "Green") {
        bg = ExcelColor.green;
      }
      return CellStyle(
        backgroundColorHex: bg,
        fontFamily: getFontFamily(FontFamily.Calibri),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        fontColorHex: ExcelColor.black,
        fontSize: 7,
        bold: true,
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        topBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
      );
    }

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      sheetObject.setRowHeight(i + 4, 38);

      var inspectedCheck = (asset.inspectedBy.toString().isEmpty ||
              asset.inspectedBy == null ||
              asset.inspectedBy == "null") &&
          (asset.inspectedDate == null ||
              asset.inspectedDate.toString().isEmpty ||
              asset.inspectedDate == "null");

      String defectivePhotos = [
        asset.defectivePhoto1OrgName,
        asset.defectivePhoto2OrgName,
        asset.defectivePhoto3OrgName,
        asset.defectivePhoto4OrgName,
        asset.defectivePhoto5OrgName,
        asset.defectivePhoto6OrgName,
      ].where((photo) => photo != null && photo.isNotEmpty).join('\n');

      String correctivePhotos = [
        asset.correctivePhoto1OrgName,
        asset.correctivePhoto2OrgName,
        asset.correctivePhoto3OrgName,
        asset.correctivePhoto4OrgName,
        asset.correctivePhoto5OrgName,
        asset.correctivePhoto6OrgName,
      ].where((photo) => photo != null && photo.isNotEmpty).join('\n');

      String materialCol = '';
      if (!inspectedCheck && asset.materials != null && asset.materials!.isNotEmpty) {
        materialCol = asset.materials!.map((material) {
          return 'Part Number : ${material.partNumber.toString()}\nMaterial Description : ${material.description.toString()}\nManufacturer : ${material.manufacturer.toString()}\nQuantity Unit : ${material.quantity.toString()}\nCertification : ${material.certificationOrgName.toString()}';
        }).join('\n\n');
      }

      String suppMaterialCol = '';
      if (!inspectedCheck && asset.supplementaryMaterialReq != null && asset.supplementaryMaterialReq!.isNotEmpty) {
        suppMaterialCol = asset.supplementaryMaterialReq!.map((supp) {
          return 'Part Number: ${supp.partNumber}\nMaterial Description : ${supp.description}\nManufacturer : ${supp.manufacturer}\nQuantity Unit : ${supp.quantity}\nCertification : ${supp.certificationOrgName}';
        }).join('\n\n');
      }

      String areaClassDrawings = asset.areaClassDrawAttachOrgName.isNotEmpty
          ? asset.areaClassDrawAttachOrgName.join(',\n')
          : asset.areaClassDrawNo.join(',\n');

      String eqpmtLytDrawings = asset.eqpmtLytDrawAttachOrgName.isNotEmpty
          ? asset.eqpmtLytDrawAttachOrgName.join(',\n')
          : asset.eqpmtLytDrawNo.join(',\n');

      String tAmbientVal = asset.tAmbient?.toString() ?? '';
      if (tAmbientVal.isEmpty || tAmbientVal == "null") {
        tAmbientVal = asset.tAmbientEquip?.toString() ?? '';
      }
      if (tAmbientVal.isEmpty || tAmbientVal == "null") {
        tAmbientVal = "Not Available";
      }

      String inspectionStatusVal = inspectedCheck ? "" : asset.inspectionStatus;
      String currentStatusVal = inspectedCheck ? "" : asset.currentStatus;

      List<Map<String, dynamic>> rowCells = [
        // 0: Sl.No
        {'val': '${i + 1}', 'style': defaultCell()},
        // 1: RFID Reference
        {'val': asset.rfidRef, 'style': defaultCell()},
        // 2: Inspection Reference
        {'val': asset.inspectionReferenceNumber != null && asset.inspectionReferenceNumber != 'null' && asset.inspectionReferenceNumber.toString().isNotEmpty ? asset.inspectionReferenceNumber.toString() : (asset.id.isNotEmpty ? asset.id : ''), 'style': defaultCell()},
        // 3: Location / Field Name
        {'val': asset.location, 'style': defaultCell()},
        // 4: Sub Location / Platform
        {'val': asset.area, 'style': defaultCell()},
        // 5: Area / Deck Level
        {'val': asset.deckLevel ?? '', 'style': defaultCell()},
        // 6: Sub Area (Nearest Landmark)
        {'val': asset.subArea?.toString() ?? '', 'style': defaultCell()},
        // 7: GPS Coordinates (Area)
        {'val': asset.locationLatitude != null && asset.locationLongitude != null && asset.locationLatitude!.isNotEmpty && asset.locationLongitude!.isNotEmpty ? '${asset.locationLatitude}, ${asset.locationLongitude}' : (asset.gpsCord?.toString() ?? ''), 'style': defaultCell()},
        // 8: Zone
        {'val': asset.zone, 'style': defaultCell()},
        // 9: Gas Group
        {'val': asset.locationGasGroup.join(', '), 'style': defaultCell()},
        // 10: Temperature Class
        {'val': asset.locationTClass.join(', '), 'style': defaultCell()},
        // 11: Area Classification Drawing Number
        {'val': areaClassDrawings, 'style': defaultCell()},
        // 12: Equipment Layout Drawing Number
        {'val': eqpmtLytDrawings, 'style': defaultCell()},
        // 13: Area Status
        {
          'val': (asset.areaStatus != null &&
                  asset.areaStatus != 'null' &&
                  asset.areaStatus.toString().trim().isNotEmpty)
              ? asset.areaStatus.toString()
              : (asset.isActive == true ? 'Active' : 'In Active'),
          'style': defaultCell(),
        },
        // 14: Discipline
        {'val': asset.eqpmtCatg, 'style': defaultCell()},
        // 15: GPS Coordinates (Equipment)
        {'val': asset.gpsCord?.toString() ?? '', 'style': defaultCell()},
        // 16: Equipment Tag Number
        {'val': asset.eqpmtTag ?? '', 'style': defaultCell()},
        // 17: Cable Tag Number
        {'val': asset.cableId ?? '', 'style': defaultCell()},
        // 18: Oracle ID
        {
          'val': asset.oracleId == "null" || asset.oracleId == null
              ? ""
              : asset.oracleId.toString(),
          'style': defaultCell(),
        },
        // 19: Equipment Description
        {
          'val': asset.description,
          'style': defaultCell(align: HorizontalAlign.Left),
        },
        // 20: Equipment Category
        {'val': asset.equipmentCategory ?? '', 'style': defaultCell()},
        // 21: Manufacturer
        {'val': asset.manufacturer, 'style': defaultCell()},
        // 22: Type/Model
        {'val': asset.type ?? '', 'style': defaultCell()},
        // 23: Serial Number
        {'val': asset.serialNumber?.toString() ?? '', 'style': defaultCell()},
        // 24: Equipment Status
        {
          'val': (asset.status != null &&
                  asset.status != 'null' &&
                  asset.status.toString().trim().isNotEmpty)
              ? asset.status.toString()
              : (asset.isActive == true ? 'Active' : 'In Active'),
          'style': defaultCell(),
        },
        // 25: ATEX Category
        {'val': asset.atexCatg.join(', '), 'style': defaultCell()},
        // 26: EPL
        {'val': asset.epl.join(', '), 'style': defaultCell()},
        // 27: Protection Standard
        {'val': asset.protectionStd?.toString() ?? '', 'style': defaultCell()},
        // 28: Protection Type
        {'val': asset.protectionType.join(', '), 'style': defaultCell()},
        // 29: Equipment Gas Group
        {'val': asset.equipmentGasGroup.join(', '), 'style': defaultCell()},
        // 30: Temperature Class
        {'val': asset.equipmentTClass.join(', '), 'style': defaultCell()},
        // 31: Equipment IP Rating
        {'val': asset.equipmentIpRating.join(', '), 'style': defaultCell()},
        // 32: T-Ambient (Min °C) to (Max °C)
        {'val': tAmbientVal, 'style': defaultCell()},
        // 33: Certification Body
        {'val': asset.certfnBody?.toString() ?? '', 'style': defaultCell()},
        // 34: Certification Number
        {'val': asset.certfnNo?.toString() ?? '', 'style': defaultCell()},
        // 35: Special Conditions
        {'val': asset.specialCond?.toString() ?? '', 'style': defaultCell()},
        // 36: Inspection Type
        {'val': inspectedCheck ? "" : (asset.inspectionType?.toString() ?? ''), 'style': defaultCell()},
        // 37: Equipment Type
        {'val': inspectedCheck ? "" : (asset.equipmentEquipmentType?.toString() ?? ''), 'style': defaultCell()},
        // 38: Inspection Checklist
        {'val': inspectedCheck ? "" : asset.inspectionChecklistType.join(', '), 'style': defaultCell()},
        // 39: Inspection Grade
        {'val': inspectedCheck ? "" : (asset.inspectionGrade?.toString() ?? ''), 'style': defaultCell()},
        // 40: Findings
        {'val': inspectedCheck ? "" : getFindingAndActions(asset, 'findings'), 'style': defaultCell(align: HorizontalAlign.Left)},
        // 41: Remedial Actions
        {'val': inspectedCheck ? "" : getFindingAndActions(asset, 'actions'), 'style': defaultCell(align: HorizontalAlign.Left)},
        // 42: Inspection Photos
        {'val': defectivePhotos, 'style': defaultCell()},
        // 43: Faulty Items
        {'val': inspectedCheck ? "" : (asset.faultyItems == null ? '0' : asset.faultyItems.toString()), 'style': defaultCell()},
        // 44: Repair Priority
        {'val': inspectedCheck ? "" : (asset.checkList == null || asset.checkList!.isEmpty ? 'Not Applicable' : (asset.inspectionPriority?.toString() ?? asset.repairPriority?.toString() ?? '')), 'style': defaultCell()},
        // 45: Inspection Status
        {'val': inspectionStatusVal, 'style': statusCell(inspectionStatusVal)},
        // 46: Overall Condition
        {'val': inspectedCheck ? "" : (asset.defectOverallCondition?.toString() ?? ''), 'style': defaultCell()},
        // 47: Repair Duration (Minutes)
        {'val': inspectedCheck || asset.repairDuration == "null" || asset.repairDuration == null ? "" : asset.repairDuration.toString(), 'style': defaultCell()},
        // 48: Isolation for Repairs
        {'val': inspectedCheck ? "" : (asset.defectIsolation?.toString() ?? ''), 'style': defaultCell()},
        // 49: Other Requirements
        {'val': inspectedCheck ? "" : asset.defectOtherRequirements.join(', '), 'style': defaultCell()},
        // 50: Additional Information for Repairs
        {'val': inspectedCheck ? "" : (asset.additionalInfoForRepairs?.toString() ?? ''), 'style': defaultCell()},
        // 51: Equipment Data Sheet
        {'val': inspectedCheck ? "" : (asset.dataSheetOrgName?.toString() ?? asset.dataSheetNo?.toString() ?? ''), 'style': defaultCell()},
        // 52: Material Requirements
        {'val': materialCol, 'style': defaultCell(align: HorizontalAlign.Left)},
        // 53: Inspected By
        {'val': inspectedCheck ? "" : (asset.inspectedBy?.toString() ?? ''), 'style': defaultCell()},
        // 54: Inspected Date
        {'val': inspectedCheck ? "" : formatInspectedDate(asset.inspectedDate?.toString()), 'style': defaultCell()},
        // 55: Repairs Done
        {'val': inspectedCheck ? "" : getFindingAndActions(asset, 'defects'), 'style': defaultCell(align: HorizontalAlign.Left)},
        // 56: Existing Faults
        {'val': inspectedCheck ? "" : (asset.existingFaults?.toString() ?? ''), 'style': defaultCell()},
        // 57: Defect Category
        {'val': inspectedCheck ? "" : (asset.correctiveDefectCategory?.toString() ?? asset.defectDefectCategory?.toString() ?? ''), 'style': defaultCell()},
        // 58: Current Status
        {'val': currentStatusVal, 'style': statusCell(currentStatusVal)},
        // 59: Current Condition
        {'val': inspectedCheck ? "" : (asset.correctiveOverallCondition?.toString() ?? ''), 'style': defaultCell()},
        // 60: Completed Repairs
        {'val': inspectedCheck ? "" : (asset.repairsDone?.toString() ?? ''), 'style': defaultCell()},
        // 61: Repair Time Estimate
        {'val': inspectedCheck || asset.repairTimeEstimate == "null" || asset.repairTimeEstimate == null ? "" : asset.repairTimeEstimate.toString(), 'style': defaultCell()},
        // 62: Isolation Requirements
        {'val': inspectedCheck ? "" : (asset.correctiveisolation?.toString() ?? ''), 'style': defaultCell()},
        // 63: Other Requirements
        {'val': inspectedCheck ? "" : (asset.correctiveOtherRequirements?.toString() ?? ''), 'style': defaultCell()},
        // 64: Supplementary Material
        {'val': suppMaterialCol, 'style': defaultCell(align: HorizontalAlign.Left)},
        // 65: Remarks if any
        {'val': inspectedCheck ? "" : (asset.remarksIfAny?.toString() ?? asset.remarks?.toString() ?? ''), 'style': defaultCell()},
        // 66: Current Photos
        {'val': correctivePhotos, 'style': defaultCell()},
        // 67: Repaired By
        {'val': inspectedCheck ? "" : (asset.repairedBy?.toString() ?? ''), 'style': defaultCell()},
        // 68: Repaired Date
        {'val': inspectedCheck ? "" : formatInspectedDate(asset.repairedDate?.toString()), 'style': defaultCell()},
      ];

      for (int c = 0; c < rowCells.length; c++) {
        var cell = sheetObject.cell(CellIndex.indexByString("${intToExcelColumn(c)}${i + 5}"));
        cell.value = TextCellValue(rowCells[c]['val'].toString());
        cell.cellStyle = rowCells[c]['style'] as CellStyle;
      }
    }
    // End of Assets List

    excel.delete("Sheet1");
    var fileBytes = excel.save();
    try {
      final fileDownloadUtil = FileDownloadUtil();
      final path = await fileDownloadUtil.getLocalPath;
      File file = File('$path/Ex Register $timestamp.xlsx');
      await file.writeAsBytes(fileBytes!);
      await fileDownloadUtil.scanFile(file.path);
      // final path = await FileDownloadUtil().getLocalPath;
      // File file = File('$path/Ex Register $timestamp.xlsx');
      // await file.writeAsBytes(fileBytes!);
      // await FileDownloadUtil().scanFile(file.path);
      return {
        "status": true,
        "location": "$path/Ex Register $timestamp.xlsx",
        "message": "Successfully Downloaded",
      };
    } catch (e) {
      return {
        "status": false,
        "location": "",
        "message": "Getting some error while download",
      };
    }
  }

  Future<Map<String, dynamic>> downloadLocationExcel(
    List<Location> locations,
  ) async {
    await initialize();
    DateTime now = DateTime.now();
    // String formattedDate = formatDateTime(DateTime.now());
    String formattedDate =
        // DateFormat("dd-MM-yyyy hh:mm a")
        //     .format(now);
        DateFormat("dd MMM yy HH:mm 'Hrs'").format(now);
    var excel = Excel.createExcel();

    Sheet sheetObject = excel['Location Register'];

    sheetObject.setRowHeight(0, 15);
    sheetObject.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('K1'),
    );
    var headerCell = sheetObject.cell(CellIndex.indexByString('A1'));
    headerCell.value = TextCellValue("Location Register"); // Header text
    headerCell.cellStyle = CellStyle(
      fontColorHex: ExcelColor.blue,
      fontSize: 15,
      fontFamily: getFontFamily(FontFamily.Calibri),
      bold: true,
      verticalAlign: VerticalAlign.Top,
      horizontalAlign: HorizontalAlign.Left,
      bottomBorder: Border(borderColorHex: ExcelColor.white),
      topBorder: Border(borderColorHex: ExcelColor.white),
      rightBorder: Border(borderColorHex: ExcelColor.white),
      leftBorder: Border(borderColorHex: ExcelColor.white),
    );
    // End of Main Header
    // Sub Header
    sheetObject.setRowHeight(1, 60);
    sheetObject.merge(
      CellIndex.indexByString('A2'),
      CellIndex.indexByString('K2'),
    );
    var subHeader = sheetObject.cell(CellIndex.indexByString('A2'));
    subHeader.value = TextCellValue(
      "Project Name : Explosion Proof (EX) Equipment - Inspection & Repair Works at DPE Facilities\n"
      "Client : Dubai Petroleum Establishment\n"
      "Contractor : Delta Solutions Engineering Services\n"
      "Date Updated : $formattedDate",
    );
    var subHeaderStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 8,
      bold: true,
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Left,
      textWrapping: TextWrapping.WrapText,
      bottomBorder: Border(borderColorHex: ExcelColor.white),
      topBorder: Border(borderColorHex: ExcelColor.white),
      rightBorder: Border(borderColorHex: ExcelColor.white),
      leftBorder: Border(borderColorHex: ExcelColor.white),
    );
    subHeader.cellStyle = subHeaderStyle;
    for (int colIndex = 0; colIndex <= 20; colIndex++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1),
      );
      cell.cellStyle = subHeaderStyle;
    }
    // End of Sub Header

    // Asset Sub Header
    CellStyle locationSubHeaderCell = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 6,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
      backgroundColorHex: ExcelColor.grey350,
      bottomBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      topBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      rightBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      leftBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
    );
    sheetObject.setRowHeight(2, 20);
    sheetObject.setRowHeight(3, 25);

    for (int i = 0; i < locationExcelHeaders.length; i++) {
      sheetObject
          .cell(CellIndex.indexByString("${intToExcelColumn(i)}3"))
          .value = TextCellValue(
        locationExcelHeaders[i],
      );
      sheetObject
          .cell(CellIndex.indexByString("${intToExcelColumn(i)}3"))
          .cellStyle = locationSubHeaderCell;
    }
    // End of Asset Sub Header

    // Assets List
    CellStyle cellStyle2 = CellStyle(
      backgroundColorHex: ExcelColor.white,
      fontFamily: getFontFamily(FontFamily.Calibri),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      fontSize: 5,
      bottomBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      topBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      rightBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
      leftBorder: Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.grey400,
      ),
    );
    for (int i = 0; i < locations.length; i++) {
      sheetObject.setColumnWidth(0, 5);
      sheetObject.setColumnWidth(1, 12);
      sheetObject.setColumnWidth(2, 12);
      sheetObject.setColumnWidth(3, 15);
      sheetObject.setColumnWidth(4, 20);
      sheetObject.setColumnWidth(5, 20);
      sheetObject.setColumnWidth(6, 11);
      sheetObject.setColumnWidth(7, 15);
      sheetObject.setColumnWidth(8, 15);
      sheetObject.setColumnWidth(9, 25);
      sheetObject.setColumnWidth(10, 25);

      sheetObject.cell(CellIndex.indexByString("A${i + 4}")).value =
          TextCellValue("${i + 1}");
      sheetObject.cell(CellIndex.indexByString("A${i + 4}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("B${i + 4}")).value =
          TextCellValue(locations[i].location);
      sheetObject.cell(CellIndex.indexByString("B${i + 4}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("C${i + 4}")).value =
          TextCellValue(locations[i].area);
      sheetObject.cell(CellIndex.indexByString("C${i + 4}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("D${i + 4}")).value =
          TextCellValue(locations[i].deckLevel.toString());
      sheetObject.cell(CellIndex.indexByString("D${i + 4}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("E${i + 4}")).value =
          TextCellValue(locations[i].subArea.toString());
      sheetObject.cell(CellIndex.indexByString("E${i + 4}")).cellStyle =
          CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: 5,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        bold: false,
        textWrapping: TextWrapping.WrapText,
        backgroundColorHex: ExcelColor.white,
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        topBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
      );

      sheetObject.cell(CellIndex.indexByString("F${i + 4}")).value =
          TextCellValue(
        locations[i].locationLatitude == null &&
                locations[i].locationLongitude == null
            ? ""
            : "${locations[i].locationLatitude}, ${locations[i].locationLongitude}",
      );
      sheetObject.cell(CellIndex.indexByString("F${i + 4}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("G${i + 4}")).value =
          TextCellValue(locations[i].zone.toString());
      sheetObject.cell(CellIndex.indexByString("G${i + 4}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("H${i + 4}")).value =
          TextCellValue(locations[i].locationGasGroup.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("H${i + 4}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("I${i + 4}")).value =
          TextCellValue(locations[i].locationTClass.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("I${i + 4}")).cellStyle =
          cellStyle2;

      String areaClassDrawings = locations[i].areaClassDrawAttachOrgName.isNotEmpty
          ? (locations[i].areaClassDrawAttachOrgName as List).join(',\n')
          : locations[i].areaClassDrawNo.toString();

      sheetObject.cell(CellIndex.indexByString("J${i + 4}")).value =
          TextCellValue(areaClassDrawings);
      sheetObject.cell(CellIndex.indexByString("J${i + 4}")).cellStyle =
          CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: 5,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText,
        backgroundColorHex: ExcelColor.white,
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        topBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
      );

      String eqpmtLytDrawings = locations[i].eqpmtLytDrawAttachOrgName.isNotEmpty
          ? (locations[i].eqpmtLytDrawAttachOrgName as List).join(',\n')
          : locations[i].eqpmtLytDrawNo.toString();

      sheetObject.cell(CellIndex.indexByString("K${i + 4}")).value =
          TextCellValue(eqpmtLytDrawings);
      sheetObject.cell(CellIndex.indexByString("K${i + 4}")).cellStyle =
          CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: 5,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText,
        backgroundColorHex: ExcelColor.white,
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        topBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.grey400,
        ),
      );
    }
    // End of Assets List

    excel.delete("Sheet1");
    var fileBytes = excel.save();
    try {
      final fileDownloadUtil = FileDownloadUtil();
      final path = await fileDownloadUtil.getLocalPath;
      File file = File('$path/Location Register $timestamp.xlsx');
      await file.writeAsBytes(fileBytes!);

      await fileDownloadUtil.scanFile(file.path);
      // final path = await FileDownloadUtil().getLocalPath;
      // File file = File('$path/Location Register $timestamp.xlsx');
      // await file.writeAsBytes(fileBytes!);
      // await FileDownloadUtil().scanFile(file.path);

      return {
        "status": true,
        "location": "$path/Location Register $timestamp.xlsx",
        "message": "Successfully Downloaded",
      };
    } catch (e) {
      return {
        "status": false,
        "location": "",
        "message": "Getting some error while download",
      };
    }
  }

  String getFormattedData(List<String> dataList) {
    // .take(4)
    return dataList.join('\n');
  }

  String getFindingAndActions(ExRegister asset, String type) {
    try {
      List<Map<String, String>> dataList = [];

      for (var checkListDetail in asset.checkList!) {
        if (checkListDetail.defectCodes.isNotEmpty) {
          for (var defectCode in checkListDetail.defectCodes) {
            for (var findingsAndAction in defectCode.findingsAndActions) {
              dataList.add({
                'defectCode': findingsAndAction.defectCode,
                'finding':
                    "${findingsAndAction.defectCode}. ${findingsAndAction.finding}",
                'action':
                    "${findingsAndAction.defectCode}. ${findingsAndAction.remedialAction}",
                'status':
                    "${findingsAndAction.defectCode}. ${findingsAndAction.isDone ? 'Done' : 'Pending'}",
              });
            }
          }
        }
      }

      dataList.sort((a, b) {
        final regex = RegExp(r'([A-Z]+)(\d+)');
        var matchA = regex.firstMatch(a['defectCode']!);
        var matchB = regex.firstMatch(b['defectCode']!);

        if (matchA != null && matchB != null) {
          var letterA = matchA.group(1)!;
          var letterB = matchB.group(1)!;
          var numberA = int.parse(matchA.group(2)!);
          var numberB = int.parse(matchB.group(2)!);

          if (letterA == letterB) {
            return numberA.compareTo(numberB);
          } else {
            return letterA.compareTo(letterB);
          }
        }
        return a['defectCode']!.compareTo(b['defectCode']!);
      });

      List<String> resultList;
      if (type == "findings") {
        resultList = dataList.map((e) => e['finding']!).toList();
      } else if (type == "actions") {
        resultList = dataList.map((e) => e['action']!).toList();
      } else {
        resultList = dataList.map((e) => e['status']!).toList();
      }

      return getFormattedData(resultList);
    } catch (e) {
      return '';
    }
  }

  String intToExcelColumn(int number) {
    String result = '';
    number++; // Increment number by 1 to handle 0 as 'A'

    while (number > 0) {
      int remainder = (number - 1) % 26;
      result = String.fromCharCode(65 + remainder) + result; // 65 is 'A'
      number = (number - remainder) ~/ 26; // Update number for next iteration
    }

    return result;
  }

  String formatDateTime(DateTime dateTime) {
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    int hour = dateTime.hour;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    String formattedHour = hour.toString().padLeft(2, '0');
    return '$day-$month-$year $formattedHour:$minute $period';
  }
}
