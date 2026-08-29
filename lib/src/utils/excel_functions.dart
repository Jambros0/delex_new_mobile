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
      CellIndex.indexByString("P3"),
    );
    sheetObject.cell(CellIndex.indexByString("D3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue600,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("Q3")).value = TextCellValue(
      'Equipment Tag Details',
    );
    sheetObject.merge(
      CellIndex.indexByString("Q3"),
      CellIndex.indexByString("AA3"),
    );
    sheetObject.cell(CellIndex.indexByString("Q3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue400,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("AB3")).value = TextCellValue(
      'Ex Protection Details',
    );
    sheetObject.merge(
      CellIndex.indexByString("AB3"),
      CellIndex.indexByString("AL3"),
    );
    sheetObject.cell(CellIndex.indexByString("AB3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue200,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("AM3")).value = TextCellValue(
      'Inspection Overview',
    );
    sheetObject.merge(
      CellIndex.indexByString("AM3"),
      CellIndex.indexByString("BE3"),
    );
    sheetObject.cell(CellIndex.indexByString("AM3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue100,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );

    sheetObject.cell(CellIndex.indexByString("BF3")).value = TextCellValue(
      'Corrective Actions',
    );
    sheetObject.merge(
      CellIndex.indexByString("BF3"),
      CellIndex.indexByString("BS3"),
    );
    sheetObject.cell(CellIndex.indexByString("BF3")).cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue50,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 7,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: true,
    );
    // End of Asset Header

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
    // sheetObject.setRowHeight(3, 25);

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

    // Assets List
    // final String? userType = await authUtils.getUserType();
    // double column3Width = (userType == 'onshore') ? 10 : 5;

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

    for (int i = 0; i < assets.length; i++) {
      sheetObject.setRowHeight(i + 4, 40);
      sheetObject.setColumnWidth(0, 5);
      sheetObject.setColumnWidth(2, 13);
      sheetObject.setColumnWidth(3, 13);
      sheetObject.setColumnWidth(4, 14);
      sheetObject.setColumnWidth(5, 14);
      sheetObject.setColumnWidth(6, 18);
      sheetObject.setColumnWidth(7, 18);
      sheetObject.setColumnWidth(8, 13);
      sheetObject.setColumnWidth(9, 9);
      sheetObject.setColumnWidth(10, 13);
      sheetObject.setColumnWidth(11, 13);
      sheetObject.setColumnWidth(12, 13);
      sheetObject.setColumnWidth(13, 11);
      sheetObject.setColumnWidth(14, 13);
      sheetObject.setColumnWidth(15, 13);
      sheetObject.setColumnWidth(16, 13);
      sheetObject.setColumnWidth(17, 13);
      sheetObject.setColumnWidth(18, 13);
      sheetObject.setColumnWidth(19, 13);
      sheetObject.setColumnWidth(20, 13);
      sheetObject.setColumnWidth(21, 13);
      sheetObject.setColumnWidth(22, 13);
      sheetObject.setColumnWidth(23, 13);
      sheetObject.setColumnWidth(24, 13);
      sheetObject.setColumnWidth(25, 13);
      sheetObject.setColumnWidth(26, 13);
      sheetObject.setColumnWidth(27, 13);
      sheetObject.setColumnWidth(28, 13);
      sheetObject.setColumnWidth(29, 13);
      sheetObject.setColumnWidth(30, 13);
      sheetObject.setColumnWidth(31, 13);
      sheetObject.setColumnWidth(32, 13);
      sheetObject.setColumnWidth(33, 13);
      sheetObject.setColumnWidth(34, 13);
      sheetObject.setColumnWidth(35, 13);
      sheetObject.setColumnWidth(36, 13);
      sheetObject.setColumnWidth(37, 13);
      sheetObject.setColumnWidth(38, 13);
      sheetObject.setColumnWidth(39, 13);
      sheetObject.setColumnWidth(40, 25);
      sheetObject.setColumnWidth(41, 25);
      sheetObject.setColumnWidth(42, 25);
      sheetObject.setColumnWidth(43, 25);
      sheetObject.setColumnWidth(44, 13);
      // sheetObject.setColumnWidth(44, 14);
      // sheetObject.setColumnWidth(45, 14);
      // sheetObject.setColumnWidth(46, 14);
      // sheetObject.setColumnWidth(47, 14);
      // sheetObject.setColumnWidth(48, 12);
      // sheetObject.setColumnWidth(49, 12);
      // sheetObject.setColumnWidth(50, 14);
      // sheetObject.setColumnWidth(51, 14);
      // sheetObject.setColumnWidth(52, 14);
      sheetObject.setColumnWidth(45, 14);
      sheetObject.setColumnWidth(46, 14);
      sheetObject.setColumnWidth(47, 14);
      sheetObject.setColumnWidth(48, 15);
      sheetObject.setColumnWidth(49, 15);
      sheetObject.setColumnWidth(50, 14);
      sheetObject.setColumnWidth(51, 15);
      sheetObject.setColumnWidth(52, 14);
      sheetObject.setColumnWidth(53, 18);
      sheetObject.setColumnWidth(54, 15);
      sheetObject.setColumnWidth(55, 15);
      sheetObject.setColumnWidth(56, 14);
      sheetObject.setColumnWidth(57, 14);
      sheetObject.setColumnWidth(58, 14);
      sheetObject.setColumnWidth(59, 14);
      sheetObject.setColumnWidth(60, 14);
      sheetObject.setColumnWidth(61, 15);
      sheetObject.setColumnWidth(62, 15);
      sheetObject.setColumnWidth(63, 15);
      sheetObject.setColumnWidth(64, 15);
      sheetObject.setColumnWidth(65, 18);
      sheetObject.setColumnWidth(66, 14);
      sheetObject.setColumnWidth(67, 14);
      sheetObject.setColumnWidth(68, 14);
      sheetObject.setColumnWidth(69, 25);
      // sheetObject.setColumnWidth(79, 13);
      CellStyle defaultCellStyle({
        int fontSize = 5,
        HorizontalAlign horizontalAlign = HorizontalAlign.Left,
        bool bold = false,
        bool wrapText = true,
      }) {
        return CellStyle(
          fontFamily: getFontFamily(FontFamily.Calibri),
          fontSize: fontSize,
          horizontalAlign: horizontalAlign,
          verticalAlign: VerticalAlign.Center,
          bold: bold,
          textWrapping: wrapText ? TextWrapping.WrapText : TextWrapping.Clip,
          backgroundColorHex: ExcelColor.white,
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

      CellStyle statusCellStyle(String status) {
        return CellStyle(
          backgroundColorHex: status == ""
              ? ExcelColor.white
              : status == "Yellow"
                  ? ExcelColor.yellow
                  : status == "Red"
                      ? ExcelColor.red
                      : ExcelColor.green,
          fontFamily: getFontFamily(FontFamily.Calibri),
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontColorHex: ExcelColor.black,
          fontSize: 7,
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

      sheetObject.cell(CellIndex.indexByString("A${i + 5}")).value =
          TextCellValue("${i + 1}");
      sheetObject.cell(CellIndex.indexByString("A${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("B${i + 5}")).value =
          TextCellValue(assets[i].rfidRef.toString());
      sheetObject.cell(CellIndex.indexByString("B${i + 5}")).cellStyle =
          cellStyle2;
      sheetObject.cell(CellIndex.indexByString("C${i + 5}")).value =
          TextCellValue("");
      sheetObject.cell(CellIndex.indexByString("C${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("D${i + 5}")).value =
          TextCellValue(assets[i].location.toString());
      sheetObject.cell(CellIndex.indexByString("D${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("E${i + 5}")).value =
          TextCellValue(assets[i].area.toString());
      sheetObject.cell(CellIndex.indexByString("E${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("F${i + 5}")).value =
          TextCellValue(assets[i].deckLevel.toString());
      sheetObject.cell(CellIndex.indexByString("F${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("G${i + 5}")).value =
          TextCellValue(assets[i].subArea.toString());
      sheetObject.cell(CellIndex.indexByString("G${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("H${i + 5}")).value =
          TextCellValue(assets[i].gpsCord.toString());
      sheetObject.cell(CellIndex.indexByString("H${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("I${i + 5}")).value =
          TextCellValue(assets[i].zone.toString());
      sheetObject.cell(CellIndex.indexByString("I${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("J${i + 5}")).value =
          TextCellValue(assets[i].locationGasGroup.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("J${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("K${i + 5}")).value =
          TextCellValue(assets[i].locationTClass.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("K${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("L${i + 5}")).value =
          TextCellValue(assets[i].locationIpRating.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("L${i + 5}")).cellStyle =
          cellStyle2;

      // String? locationTAmbient = assets[i].locationTAmbient;
      // String locationTAmbientMin = "";
      // String locationTAmbientMax = "";

      // if (locationTAmbient.contains("to")) {
      //   List<String> parts = locationTAmbient.split("to");
      //   locationTAmbientMin = parts[0].trim();
      //   locationTAmbientMax = parts[1].trim();
      // }

      // sheetObject.cell(CellIndex.indexByString("L${i + 5}")).value =
      //     TextCellValue(locationTAmbientMin);
      // sheetObject.cell(CellIndex.indexByString("L${i + 5}")).cellStyle =
      //     cellStyle2;
      sheetObject.cell(CellIndex.indexByString("M${i + 5}")).value =
          TextCellValue(""); //$locationTAmbientMin to $locationTAmbientMax
      sheetObject.cell(CellIndex.indexByString("M${i + 5}")).cellStyle =
          cellStyle2;

      // sheetObject.cell(CellIndex.indexByString("M${i + 5}")).value =
      //     TextCellValue(locationTAmbientMax);
      // sheetObject.cell(CellIndex.indexByString("M${i + 5}")).cellStyle =
      //     cellStyle2;

      sheetObject.cell(CellIndex.indexByString("N${i + 5}")).value =
          TextCellValue(
        assets[i].areaClassDrawAttachOrgName.join('\n').toString(),
      );
      sheetObject.cell(CellIndex.indexByString("N${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("O${i + 5}")).value =
          TextCellValue(
        assets[i].eqpmtLytDrawAttachOrgName.join('\n').toString(),
      );
      sheetObject.cell(CellIndex.indexByString("O${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("P${i + 5}")).value =
          TextCellValue(assets[i].isActive == true ? "Active" : "In Active");
      sheetObject.cell(CellIndex.indexByString("P${i + 5}")).cellStyle =
          cellStyle2;
      sheetObject.cell(CellIndex.indexByString("Q${i + 5}")).value =
          TextCellValue(assets[i].eqpmtCatg.toString());
      sheetObject.cell(CellIndex.indexByString("Q${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("R${i + 5}")).value =
          TextCellValue(assets[i].gpsCord.toString());
      sheetObject.cell(CellIndex.indexByString("R${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("S${i + 5}")).value =
          TextCellValue(assets[i].eqpmtTag.toString());
      sheetObject.cell(CellIndex.indexByString("S${i + 5}")).cellStyle =
          cellStyle2;

      // sheetObject.cell(CellIndex.indexByString("T${i + 5}")).value =
      //     TextCellValue(assets[i].circuitId.toString());
      // sheetObject.cell(CellIndex.indexByString("T${i + 5}")).cellStyle =
      //     cellStyle2;
      sheetObject.cell(CellIndex.indexByString("T${i + 5}")).value =
          TextCellValue(assets[i].cableId.toString());
      sheetObject.cell(CellIndex.indexByString("T${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("U${i + 5}")).value =
          TextCellValue(
        assets[i].oracleId == "null" || assets[i].oracleId == null
            ? ""
            : assets[i].oracleId.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("U${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("V${i + 5}")).value =
          TextCellValue(assets[i].description.toString());
      sheetObject.cell(CellIndex.indexByString("V${i + 5}")).cellStyle =
          cellStyle2;
      sheetObject.cell(CellIndex.indexByString("W${i + 5}")).value =
          TextCellValue(assets[i].equipmentCategory.toString());
      sheetObject.cell(CellIndex.indexByString("W${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("X${i + 5}")).value =
          TextCellValue(assets[i].manufacturer.toString());
      sheetObject.cell(CellIndex.indexByString("X${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("Y${i + 5}")).value =
          TextCellValue(assets[i].type.toString());
      sheetObject.cell(CellIndex.indexByString("Y${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("Z${i + 5}")).value =
          TextCellValue(assets[i].serialNumber.toString());
      sheetObject.cell(CellIndex.indexByString("Z${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AA${i + 5}")).value =
          TextCellValue(
        assets[i].isActive == null
            ? "Archive"
            : assets[i].isActive == true
                ? "Active"
                : "In Active",
      );
      sheetObject.cell(CellIndex.indexByString("AA${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AB${i + 5}")).value =
          TextCellValue(assets[i].atexCatg.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("AB${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AC${i + 5}")).value =
          TextCellValue(assets[i].epl.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("AC${i + 5}")).cellStyle =
          cellStyle2;
      sheetObject.cell(CellIndex.indexByString("AD${i + 5}")).value =
          TextCellValue(assets[i].protectionStd.toString());
      sheetObject.cell(CellIndex.indexByString("AD${i + 5}")).cellStyle =
          cellStyle2;
      sheetObject.cell(CellIndex.indexByString("AE${i + 5}")).value =
          TextCellValue(assets[i].protectionType.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("AE${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AF${i + 5}")).value =
          TextCellValue(assets[i].equipmentGasGroup.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("AF${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AG${i + 5}")).value =
          TextCellValue(assets[i].equipmentTClass.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("AG${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AH${i + 5}")).value =
          TextCellValue(assets[i].equipmentIpRating.join(', ').toString());
      sheetObject.cell(CellIndex.indexByString("AH${i + 5}")).cellStyle =
          cellStyle2;

      String? tAmbient = assets[i].tAmbient.toString();
      dynamic tAmbientMin =
          assets[i].tAmbient == null || assets[i].tAmbient.toString() == ""
              ? "Not Available"
              : tAmbient.toString();
      // String tAmbientMax = "Not Available";

      // if (tAmbient != null && tAmbient.isNotEmpty) {
      //   if (tAmbient.contains("to")) {
      //     List<String> parts = tAmbient.split("to");
      //     if (parts.length == 2) {
      //       tAmbientMin = parts[0].trim();
      //       tAmbientMax = parts[1].trim();
      //     }
      //   } else {
      //     tAmbientMin = tAmbient.trim();
      //     tAmbientMax = "";
      //   }
      // }

      sheetObject.cell(CellIndex.indexByString("AI${i + 5}")).value =
          TextCellValue(tAmbientMin.toString());
      sheetObject.cell(CellIndex.indexByString("AI${i + 5}")).cellStyle =
          cellStyle2;

      // sheetObject.cell(CellIndex.indexByString("AH${i + 5}")).value =
      //     TextCellValue(tAmbientMax);
      // sheetObject.cell(CellIndex.indexByString("AH${i + 5}")).cellStyle =
      //     cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AJ${i + 5}")).value =
          TextCellValue(assets[i].certfnBody.toString());
      sheetObject.cell(CellIndex.indexByString("AJ${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AK${i + 5}")).value =
          TextCellValue(assets[i].certfnNo.toString());
      sheetObject.cell(CellIndex.indexByString("AK${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AL${i + 5}")).value =
          TextCellValue(assets[i].specialCond.toString());
      sheetObject.cell(CellIndex.indexByString("AL${i + 5}")).cellStyle =
          cellStyle2;
      var inspectedCheck = (assets[i].inspectedBy.toString().isEmpty ||
              assets[i].inspectedBy == null ||
              assets[i].inspectedBy == "null") &&
          (assets[i].inspectedDate == null ||
              assets[i].inspectedDate.toString().isEmpty ||
              assets[i].inspectedDate == "null");
      sheetObject.cell(CellIndex.indexByString("AM${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].inspectionType == null
                ? ""
                : assets[i].inspectionType.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("AM${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AN${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].equipmentEquipmentType == null
                ? ""
                : assets[i].equipmentEquipmentType.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("AN${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AO${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].inspectionChecklistType.join(', ').toString(),
      );
      sheetObject.cell(CellIndex.indexByString("AO${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AP${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].inspectionGrade == null
                ? ""
                : assets[i].inspectionGrade.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("AP${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AQ${i + 5}")).value =
          TextCellValue(
        inspectedCheck ? "" : getFindingAndActions(assets[i], 'findings'),
      );
      sheetObject.cell(CellIndex.indexByString("AQ${i + 5}")).cellStyle =
          CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: 5,
        horizontalAlign: HorizontalAlign.Left,
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

      sheetObject.cell(CellIndex.indexByString("AR${i + 5}")).value =
          TextCellValue(
        inspectedCheck ? "" : getFindingAndActions(assets[i], 'actions'),
      );
      sheetObject.cell(CellIndex.indexByString("AR${i + 5}")).cellStyle =
          CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: 5,
        horizontalAlign: HorizontalAlign.Left,
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

      // String? photoPath = [
      //   assets[i].defectivePhoto1OrgName,
      //   assets[i].defectivePhoto2OrgName,
      //   assets[i].defectivePhoto3OrgName,
      //   assets[i].defectivePhoto4OrgName,
      //   assets[i].defectivePhoto5OrgName,
      //   assets[i].defectivePhoto6OrgName,
      // ].where((photo) => photo != null).join('\n');
      // sheetObject.cell(CellIndex.indexByString("AR${i + 5}")).value =
      //     TextCellValue(photoPath);
      // sheetObject.cell(CellIndex.indexByString("AR${i + 5}")).cellStyle =
      //     cellStyle2;
      String photoPath = [
        assets[i].defectivePhoto1OrgName,
        assets[i].defectivePhoto2OrgName,
        assets[i].defectivePhoto3OrgName,
        assets[i].defectivePhoto4OrgName,
        assets[i].defectivePhoto5OrgName,
        assets[i].defectivePhoto6OrgName,
      ].where((photo) => photo != null && photo.isNotEmpty).join('\n');

      var cell = sheetObject.cell(CellIndex.indexByString("AS${i + 5}"));
      cell.value = TextCellValue(photoPath);

      cell.cellStyle = CellStyle(
        fontSize: 5,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        textWrapping: TextWrapping.WrapText,
      );

      sheetObject.cell(CellIndex.indexByString("AT${i + 5}")).value =
          TextCellValue(
        assets[i].faultyItems == null ? '0' : assets[i].faultyItems.toString(),
      );

      sheetObject.cell(CellIndex.indexByString("AT${i + 5}")).cellStyle =
          cellStyle2;
      if (assets[i].inspectionType.toString().isEmpty &&
          assets[i].equipmentEquipmentType.toString().isEmpty &&
          assets[i].inspectionChecklistType.isEmpty &&
          assets[i].inspectionGrade.toString().isEmpty) {
        sheetObject.cell(CellIndex.indexByString("AU${i + 5}")).value =
            TextCellValue('');
        sheetObject.cell(CellIndex.indexByString("AU${i + 5}")).cellStyle =
            cellStyle2;
        sheetObject.cell(CellIndex.indexByString("AV${i + 5}")).value =
            TextCellValue("");
        sheetObject.cell(CellIndex.indexByString("AV${i + 5}")).cellStyle =
            cellStyle2;
      } else {
        sheetObject.cell(CellIndex.indexByString("AU${i + 5}")).value =
            TextCellValue(
          inspectedCheck
              ? ""
              : assets[i].checkList == null || assets[i].checkList!.isEmpty
                  ? 'Not Applicable'
                  : assets[i].inspectionPriority.toString(),
        );
        sheetObject.cell(CellIndex.indexByString("AU${i + 5}")).cellStyle =
            cellStyle2;
        sheetObject.cell(CellIndex.indexByString("AV${i + 5}")).value =
            TextCellValue(
          inspectedCheck ? "" : assets[i].inspectionStatus.toString(),
        );

        sheetObject.cell(CellIndex.indexByString("AV${i + 5}")).value =
            TextCellValue(
          inspectedCheck
              ? ""
              : assets[i].inspectionStatus.toString() == "Yellow" ||
                      assets[i].inspectionStatus.toString() == "Red"
                  ? assets[i].inspectionStatus.toString()
                  : "Green",
        );
        sheetObject.cell(CellIndex.indexByString("AV${i + 5}")).cellStyle =
            statusCellStyle(
          inspectedCheck ? "" : assets[i].inspectionStatus.toString(),
        );
      }

      sheetObject.cell(CellIndex.indexByString("AW${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].defectOverallCondition == null
                ? ""
                : assets[i].defectOverallCondition.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("AW${i + 5}")).cellStyle =
          cellStyle2;
      sheetObject.cell(CellIndex.indexByString("AX${i + 5}")).value =
          TextCellValue(
        inspectedCheck == true
            ? ""
            : assets[i].repairDuration == "null" ||
                    assets[i].repairDuration == null
                ? ""
                : assets[i].repairDuration.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("AX${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AY${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].defectIsolation == null
                ? ""
                : assets[i].defectIsolation.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("AY${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("AZ${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].defectOtherRequirements.join(', ').toString(),
      );
      sheetObject.cell(CellIndex.indexByString("AZ${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("BA${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].additionalInfoForRepairs == null
                ? ""
                : assets[i].additionalInfoForRepairs.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BA${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("BB${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].dataSheetOrgName == null
                ? ""
                : assets[i].dataSheetOrgName.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BB${i + 5}")).cellStyle =
          cellStyle2;
      final materials = inspectedCheck ? [] : assets[i].materials;

      String col = '';

      if (materials != null && materials.isNotEmpty) {
        col = materials.map((material) {
          return 'Part Number : ${material.partNumber.toString()}\nMaterial Description : ${material.description.toString()}\nManufacturer : ${material.manufacturer.toString()}\nQuantity Unit : ${material.quantity.toString()}\nCertification : ${material.certificationOrgName.toString()}';
        }).join('\n\n');
      } else {
        col = '';
        // 'Part Number : \nMaterial Description : \nManufacturer : \nQuantity Unit : \nCertification : ';
      }
      sheetObject.cell(CellIndex.indexByString("BC${i + 5}")).value =
          TextCellValue(col.toString());
      sheetObject.cell(CellIndex.indexByString("BC${i + 5}")).cellStyle =
          defaultCellStyle();
      sheetObject.cell(CellIndex.indexByString("BD${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].inspectedBy == null
                ? ""
                : assets[i].inspectedBy.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BD${i + 5}")).cellStyle =
          cellStyle2;
      if (assets[i].inspectedDate == '' || assets[i].inspectedDate == null) {
        sheetObject.cell(CellIndex.indexByString("BE${i + 5}")).value =
            TextCellValue('');
      } else {
        sheetObject.cell(CellIndex.indexByString("BE${i + 5}")).value =
            TextCellValue(
          formatInspectedDate(
            inspectedCheck ? "" : assets[i].inspectedDate.toString(),
          ),
        );
      }
      sheetObject.cell(CellIndex.indexByString("BE${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("BF${i + 5}")).value =
          // TextCellValue(assets[i].repairsDone.toString());
          TextCellValue(
        inspectedCheck ? "" : getFindingAndActions(assets[i], 'defects'),
      );
      sheetObject.cell(CellIndex.indexByString("BF${i + 5}")).cellStyle =
          defaultCellStyle();

      sheetObject.cell(CellIndex.indexByString("BG${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].existingFaults == null
                ? ""
                : assets[i].existingFaults.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BG${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("BH${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].correctiveDefectCategory == null
                ? ""
                : assets[i].correctiveDefectCategory.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BH${i + 5}")).cellStyle =
          cellStyle2;
      if (assets[i].inspectionType.toString().isEmpty &&
          assets[i].equipmentEquipmentType.toString().isEmpty &&
          assets[i].inspectionChecklistType.toString().isEmpty &&
          assets[i].inspectionGrade.toString().isEmpty) {
        sheetObject.cell(CellIndex.indexByString("BI${i + 5}")).value =
            TextCellValue("");
      } else {
        sheetObject.cell(CellIndex.indexByString("BI${i + 5}")).value =
            TextCellValue(
          inspectedCheck
              ? ""
              : assets[i].currentStatus.toString() == "Yellow" ||
                      assets[i].currentStatus.toString() == "Red"
                  ? assets[i].currentStatus.toString()
                  : "Green",
        );
        sheetObject.cell(CellIndex.indexByString("BI${i + 5}")).cellStyle =
            statusCellStyle(
          inspectedCheck ? "" : assets[i].currentStatus.toString(),
        );
      }
      sheetObject.cell(CellIndex.indexByString("BJ${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].correctiveOverallCondition == null
                ? ""
                : assets[i].correctiveOverallCondition.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BJ${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("BK${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].repairsDone == null
                ? ""
                : assets[i].repairsDone.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BK${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("BL${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].repairTimeEstimate == "null" ||
                    assets[i].repairTimeEstimate == null
                ? ""
                : assets[i].repairTimeEstimate.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BL${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("BM${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].correctiveisolation == null
                ? ""
                : assets[i].correctiveisolation.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BM${i + 5}")).cellStyle =
          cellStyle2;

      sheetObject.cell(CellIndex.indexByString("BN${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].correctiveOtherRequirements == null
                ? ""
                : assets[i].correctiveOtherRequirements.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BN${i + 5}")).cellStyle =
          cellStyle2;
      final supplementaryMaterialReq = assets[i].supplementaryMaterialReq;

      String suppcol = '';

      if (supplementaryMaterialReq != null &&
          supplementaryMaterialReq.isNotEmpty) {
        suppcol = supplementaryMaterialReq.map((supp) {
          return 'Part Number: ${supp.partNumber}\nMaterial Description : ${supp.description}\nManufacturer : ${supp.manufacturer}\nQuantity Unit : ${supp.quantity}\nCertification : ${supp.certificationOrgName}';
        }).join('\n\n');
      } else {
        suppcol = '';
        // 'Part Number : \nMaterial Description : \nManufacturer : \nQuantity Unit : \nCertification : ';
      }
      sheetObject.cell(CellIndex.indexByString("BO${i + 5}")).value =
          TextCellValue(suppcol.toString());
      sheetObject.cell(CellIndex.indexByString("BO${i + 5}")).cellStyle =
          CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: 5,
        horizontalAlign: HorizontalAlign.Left,
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

      sheetObject.cell(CellIndex.indexByString("BP${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].remarksIfAny == null
                ? ""
                : assets[i].remarksIfAny.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BP${i + 5}")).cellStyle =
          cellStyle2;
      // String? currentPhotos = [
      //   assets[i].correctivePhoto1OrgName,
      //   assets[i].correctivePhoto2OrgName,
      //   assets[i].correctivePhoto3OrgName,
      //   assets[i].correctivePhoto4OrgName,
      //   assets[i].correctivePhoto5OrgName,
      //   assets[i].correctivePhoto6OrgName,
      // ].where((photo) => photo != null).join('\n');
      // sheetObject.cell(CellIndex.indexByString("BO${i + 5}")).value =
      //     TextCellValue(inspectedCheck ? "" : currentPhotos);
      // sheetObject.cell(CellIndex.indexByString("BO${i + 5}")).cellStyle =
      //     defaultCellStyle(horizontalAlign: HorizontalAlign.Center);
      String? currentPhotos = [
        assets[i].correctivePhoto1OrgName,
        assets[i].correctivePhoto2OrgName,
        assets[i].correctivePhoto3OrgName,
        assets[i].correctivePhoto4OrgName,
        assets[i].correctivePhoto5OrgName,
        assets[i].correctivePhoto6OrgName,
      ].where((photo) => photo != null && photo.isNotEmpty).join('\n');

      var cell1 = sheetObject.cell(CellIndex.indexByString("BQ${i + 5}"));
      cell1.value = TextCellValue(currentPhotos);

      cell1.cellStyle = CellStyle(
        fontSize: 5,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        textWrapping: TextWrapping.WrapText,
      );

      sheetObject.cell(CellIndex.indexByString("BR${i + 5}")).value =
          TextCellValue(
        inspectedCheck
            ? ""
            : assets[i].repairedBy == null
                ? ""
                : assets[i].repairedBy.toString(),
      );
      sheetObject.cell(CellIndex.indexByString("BR${i + 5}")).cellStyle =
          cellStyle2;
      if (assets[i].repairedDate == '' || assets[i].repairedDate == null) {
        sheetObject.cell(CellIndex.indexByString("BS${i + 5}")).value =
            TextCellValue('');
      } else {
        sheetObject.cell(CellIndex.indexByString("BS${i + 5}")).value =
            TextCellValue(
          formatInspectedDate(
            inspectedCheck ? "" : assets[i].repairedDate.toString(),
          ),
        );
      }
      sheetObject.cell(CellIndex.indexByString("BS${i + 5}")).cellStyle =
          cellStyle2;
    }
    // End of Assets List

    // sheetObject.cell(CellIndex.indexByString("AR${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.equipmentCriticality ?? '');
    // sheetObject.cell(CellIndex.indexByString("AR${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AS${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.faultCategory ?? '');
    // sheetObject.cell(CellIndex.indexByString("AS${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AT${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.failureHistory ?? '');
    // sheetObject.cell(CellIndex.indexByString("AT${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AU${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.equipmentAgening ?? '');
    // sheetObject.cell(CellIndex.indexByString("AU${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AV${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.envSeverity ?? '');
    // sheetObject.cell(CellIndex.indexByString("AV${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AW${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.protFlamambleAtom ?? '');
    // sheetObject.cell(CellIndex.indexByString("AW${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AX${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.ignitionSourceProb ?? '');
    // sheetObject.cell(CellIndex.indexByString("AX${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AY${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.ignitionFlask ?? '');
    // sheetObject.cell(CellIndex.indexByString("AY${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AZ${i + 5}")).value =
    //     TextCellValue(assets[i].rbiStrategy?.operationalImpact ?? '');
    // sheetObject.cell(CellIndex.indexByString("AZ${i + 5}")).cellStyle =
    //     cellStyle2;

    // sheetObject.cell(CellIndex.indexByString("AS${i + 5}")).value =
    //     TextCellValue(assets[i].faultyItems == null
    //         ? '0'
    //         : assets[i].faultyItems.toString());
    // sheetObject.cell(CellIndex.indexByString("AS${i + 5}")).cellStyle =
    //     cellStyle2;

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
