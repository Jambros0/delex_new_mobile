import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import '../features/functional_areas/data/models/location_model.dart';
import 'file_download_util.dart';

class PdfGenerator {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final AuthUtils authUtils = AuthUtils();

  Future<void> initialize() async {
    final String? userType = await authUtils.getUserType();

    if (userType == 'onshore') {
      locationPDFHeaders = [
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
        'Area Classification Drawing Number',
        'Equipment Layout Drawing Number',
      ];
    } else {
      locationPDFHeaders = [
        'S.No',
        'Field Name',
        'Platform',
        'Deck Level',
        'Sub Area (Nearest Landmark)',
        'GPS Coordinates',
        'Zone',
        'Gas Group',
        'Temperature Class',
        // 'Area T-Ambient(Max °C)',
        'Area Classification Drawing Number',
        'Equipment Layout Drawing Number',
      ];
    }

    if (userType == 'onshore') {
      assetPDFHeaders = [
        'S.No',
        'RFID Reference',
        'Location',
        'Sub Location',
        'Area',
        'Zone',
        'Equipment Tag',
        'Equipment Description',
        'Equipment Manufacturer',
        'Ex Protection',
        'Findings',
        'Remedial Actions',
        'Inspection Status',
        'Repairs Done',
        'Current Status',
        // 'Work Status',
      ];
      headerBackgroundColors = [
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue100,
        PdfColors.blue100,
        PdfColors.blue100,
        PdfColors.blue100,
        PdfColors.blue50,
        PdfColors.blue50,
        PdfColors.blue50,
        PdfColors.blue50,
        PdfColors.blue50,
        PdfColors.blue50,
      ];
      headerTextColors = [
        PdfColors.white,
        PdfColors.white,
        PdfColors.white,
        PdfColors.white,
        PdfColors.white,
        PdfColors.white,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
      ];
    } else {
      assetPDFHeaders = [
        'S.No',
        'RFID Reference',
        'Field Name',
        'Platform',
        'Deck Level',
        'Zone',
        'Equipment Tag',
        'Equipment Description',
        'Equipment Manufacturer',
        'Ex Protection',
        'Findings',
        'Remedial Actions',
        'Inspection Status',
        'Repairs Done',
        'Current Status',
        // 'Work Status',
      ];
      headerBackgroundColors = [
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue100,
        PdfColors.blue100,
        PdfColors.blue100,
        PdfColors.blue100,
        PdfColors.blue50,
        PdfColors.blue50,
        PdfColors.blue50,
        PdfColors.blue50,
        PdfColors.blue50,
        PdfColors.blue50,
      ];
      headerTextColors = [
        PdfColors.white,
        PdfColors.white,
        PdfColors.white,
        PdfColors.white,
        PdfColors.white,
        PdfColors.white,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
        PdfColors.blue,
      ];
    }
  }

  List<String> locationPDFHeaders = [];
  List<String> assetPDFHeaders = [];
  List<PdfColor> headerBackgroundColors = [];
  List<PdfColor> headerTextColors = [];

  PdfGenerator() {
    initialize();
  }
  int estimateLineCount(String text, {int maxCharsPerLine = 40}) {
    return (text.length / maxCharsPerLine).ceil();
  }

  Future<Map<String, dynamic>> downloadAssetPdf(
    List<ExRegister> allAssets,
  ) async {
    getInspectionColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'red':
          return PdfColors.red;
        case 'yellow':
          return PdfColors.yellow;
        case 'green':
          return PdfColors.green;
        default:
          return null;
      }
    }

    getCurrentStatusColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'red':
          return PdfColors.red;
        case 'yellow':
          return PdfColors.yellow;
        case 'green':
          return PdfColors.green;
        default:
          return null;
      }
    }

    String formattedDate = formatDateTime(DateTime.now());
    String formattedDateHeader = DateFormat(
      "dd MMM yy HH:mm 'Hrs'",
    ).format(DateTime.now());
    final pdf = pw.Document();
    final indexCounter = ValueNotifier<int>(1);

    const double baseLineHeight = 10;
    const double maxPageContentHeight = 520; // space for content per page

    // Estimate lines for text field
    int estimateLines(String text) =>
        text.trim().isEmpty ? 2 : '\n'.allMatches(text).length + 1;
    // Estimate line count for a record row
    int estimateAssetRowLines(ExRegister asset) {
      final findings = getFindingAndActions(asset, 'findings');
      final actions = getFindingAndActions(asset, 'actions');
      final repairs = getFindingAndActions(asset, 'repairsDone');
      return [
        estimateLines(findings),
        estimateLines(actions),
        estimateLines(repairs),
      ].reduce((a, b) => a > b ? a : b).clamp(1, 999);
    }

    // Split assets dynamically per page by measuring row height
    List<List<ExRegister>> splitAssetsForDynamicPages(List<ExRegister> assets) {
      List<List<ExRegister>> pages = [];
      List<ExRegister> currentPage = [];
      double usedHeight = 0;

      for (final asset in assets) {
        int lines = estimateAssetRowLines(asset);
        double rowHeight = lines * baseLineHeight;

        if (usedHeight + rowHeight > maxPageContentHeight) {
          pages.add(currentPage);
          currentPage = [asset];
          usedHeight = rowHeight;
        } else {
          currentPage.add(asset);
          usedHeight += rowHeight;
        }
      }

      if (currentPage.isNotEmpty) pages.add(currentPage);
      return pages;
    }

    pw.Widget buildHeader(String label) => pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 40,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.lightBlue800,
          ),
        ),
      ],
    );

    pw.Widget buildDetailRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(left: 65),
      child: pw.Row(
        children: [
          pw.Container(width: 100, child: pw.Text(label)),
          pw.Text(
            ': $value',
            style: (label == 'Project Name' || label == 'Client')
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                : null,
          ),
        ],
      ),
    );

    pw.Widget buildFooter(String leftContent, String rightContent) =>
        pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10.0),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                leftContent,
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
              pw.Text(
                rightContent,
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
            ],
          ),
        );

    var largeWidth = 40 * PdfPageFormat.inch;
    var standardHeight = PdfPageFormat.a4.height;

    final dynamicPages = splitAssetsForDynamicPages(allAssets);

    for (int pageIndex = 0; pageIndex < dynamicPages.length; pageIndex++) {
      final isFirstPage = pageIndex == 0;
      final pageAssets = dynamicPages[pageIndex];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(largeWidth, standardHeight),
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(
                top: 50,
                left: 30,
                right: 30,
                bottom: 30,
              ),
              child: pw.Stack(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (isFirstPage) ...[
                        buildHeader('Ex Register'),
                        pw.SizedBox(height: 30),
                        buildDetailRow(
                          'Project Name',
                          'Explosion Proof (EX) Equipment - Inspection & Repair Works at DPE Facilities',
                        ),
                        pw.SizedBox(height: 7),
                        buildDetailRow(
                          'Client',
                          'Dubai Petroleum Establishment',
                        ),
                        pw.SizedBox(height: 7),
                        buildDetailRow(
                          'Contractor',
                          'Delta Solutions Engineering Services',
                        ),
                        pw.SizedBox(height: 7),
                        buildDetailRow('Date Updated', formattedDateHeader),
                        pw.SizedBox(height: 25),
                      ],
                      pw.Table(
                        border: pw.TableBorder.all(
                          color: PdfColors.grey400,
                          width: 2,
                        ),
                        columnWidths: {
                          0: const pw.FixedColumnWidth(30),
                          1: const pw.FixedColumnWidth(80),
                          2: const pw.FixedColumnWidth(80),
                          3: const pw.FixedColumnWidth(80),
                          4: const pw.FixedColumnWidth(80),
                          5: const pw.FixedColumnWidth(60),
                          6: const pw.FixedColumnWidth(60),
                          7: const pw.FixedColumnWidth(120),
                          8: const pw.FixedColumnWidth(80),
                          9: const pw.FixedColumnWidth(80),
                          10: const pw.FixedColumnWidth(150),
                          11: const pw.FixedColumnWidth(150),
                          12: const pw.FixedColumnWidth(80),
                          13: const pw.FixedColumnWidth(80),
                          14: const pw.FixedColumnWidth(80),
                        },
                        children: [
                          pw.TableRow(
                            children: List.generate(assetPDFHeaders.length, (
                              index,
                            ) {
                              return pw.Container(
                                color: headerBackgroundColors[index],
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  assetPDFHeaders[index],
                                  style: pw.TextStyle(
                                    color: headerTextColors[index],
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              );
                            }),
                          ),
                          ...pageAssets.map((asset) {
                            final findings = getFindingAndActions(
                              asset,
                              'findings',
                            );
                            final actions = getFindingAndActions(
                              asset,
                              'actions',
                            );
                            final repairs = getFindingAndActions(
                              asset,
                              'repairsDone',
                            );

                            final rowHeight =
                                estimateAssetRowLines(asset) * baseLineHeight;

                            final cells = [
                              (indexCounter.value++).toString(),
                              asset.rfidRef,
                              asset.location,
                              asset.area,
                              asset.deckLevel ?? '',
                              asset.zone,
                              asset.eqpmtTag ?? '',
                              asset.description,
                              asset.manufacturer,
                              asset.epl.join(', '),
                              findings,
                              actions,
                              asset.inspectionStatus,
                              repairs,
                              asset.currentStatus,
                            ];

                            return pw.TableRow(
                              children: cells.asMap().entries.map((entry) {
                                final i = entry.key;
                                final text = entry.value;
                                final isInspectionStatus = i == 12;
                                final isCurrentStatus = i == 14;

                                return pw.Container(
                                  color: isInspectionStatus
                                      ? getInspectionColor(
                                          asset.inspectionStatus,
                                        )
                                      : isCurrentStatus
                                      ? getCurrentStatusColor(
                                          asset.currentStatus,
                                        )
                                      : null,
                                  height: rowHeight,
                                  padding: const pw.EdgeInsets.only(
                                    top: 2,
                                    bottom: 5,
                                    left: 5,
                                    right: 5,
                                  ),
                                  alignment: i == 10 || i == 11 || i == 13
                                      ? pw.Alignment.centerLeft
                                      : pw.Alignment.center,
                                  child: pw.Text(
                                    text,
                                    textAlign: i == 10 || i == 11 || i == 13
                                        ? pw.TextAlign.left
                                        : pw.TextAlign.center,
                                    maxLines: null,
                                    softWrap: true,
                                    style: const pw.TextStyle(fontSize: 7),
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  pw.Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: buildFooter(
                      "Ex Register updated on $formattedDate @ ${DateTime.now().year} by DelEx Software",
                      "Explosion Proof (EX) - Inspection Repair Works at DPE Facilities",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    try {
      final fileDownloadUtil = FileDownloadUtil();
      final path = await fileDownloadUtil.getLocalPath;
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      File file = File('$path/Ex Register $timestamp.pdf');
      await file.writeAsBytes(await pdf.save());
      await fileDownloadUtil.scanFile(file.path);

      return {
        "status": true,
        "location": file.path,
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

  String processField(String? field) {
    return field?.toUpperCase() ?? '';
  }

  String getFormattedData(List<String> dataList) {
    // .take(4)
    return dataList.join('\n');
  }

  String getFindingAndActions(ExRegister asset, String type) {
    try {
      if (asset.checkList == null || asset.checkList!.isEmpty) {
        return '';
      }

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
                'repairsDone':
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
        resultList = dataList.map((e) => e['repairsDone']!).toList();
      }

      return getFormattedData(resultList);
    } catch (e) {
      return '';
    }
  }

  String determineAssetStatus(ExRegister asset) {
    // Check for Repaired Completely first (highest priority)
    if (asset.currentStatus == "Green") {
      return "Repaired Completely";
    }

    // Check for Repaired Partially (second priority)
    int existingFaults = asset.existingFaults == null
        ? 0
        : int.tryParse(asset.existingFaults.toString()) ?? 0;
    int repairsDone = int.tryParse(asset.repairsDone.toString()) ?? 0;
    if (existingFaults > 0 && repairsDone > 0) {
      return "Repaired Partially";
    }

    // Check for Corrective Actions (third priority)
    if (["Red", "Yellow"].contains(asset.currentStatus.toString())) {
      return "Corrective Actions";
    }

    if (asset.inspectionPriority != null) {
      if (asset.inspectionPriority == 1 || asset.inspectionPriority == 2) {
        return "Corrective Actions";
      } else if (asset.inspectionPriority! >= 3 &&
          asset.inspectionPriority! <= 5) {
        return "Corrective Actions";
      }
    }

    // Check for Inspected (fourth priority)
    if (asset.inspectionStatus.isNotEmpty ||
        (asset.inspectionPriority != null && asset.inspectionPriority != 0) ||
        (asset.inspectionType?.isNotEmpty == true &&
            asset.inspectionChecklistType.isNotEmpty == true &&
            asset.equipmentEquipmentType?.isNotEmpty == true &&
            asset.inspectionGrade?.isNotEmpty == true &&
            (asset.checkList == null || asset.checkList!.isEmpty))) {
      return "Inspected";
    }

    // Check for Uninspected (lowest priority, no changes)
    if ((asset.inspectionStatus.isEmpty) &&
        (asset.inspectionPriority == null || asset.inspectionPriority == 0) &&
        (asset.inspectionType == null || asset.inspectionType.isEmpty) &&
        // (asset.inspectionChecklistType == null ||
        //     asset.inspectionChecklistType.isEmpty) &&
        (asset.equipmentEquipmentType == null ||
            asset.equipmentEquipmentType.isEmpty) &&
        (asset.inspectionGrade == null || asset.inspectionGrade.isEmpty)) {
      return "Uninspected";
    }

    // Default case
    return "Unknown";
  }

  Future<Map<String, dynamic>> downloadLocationPdf(
    List<Location> locations,
  ) async {
    int indexNumber = 26;
    DateTime now = DateTime.now();

    String formattedDateHeader =
        // DateFormat("dd-MM-yyyy hh:mm a")
        //     .format(now);
        DateFormat("dd MMM yy HH:mm 'Hrs'").format(now);
    String formattedDate = formatDateTime(now);
    // String formattedDateHeader =
    //     "${now.day.toString().padLeft(2, '0')} ${now.month == 1 ? 'Jan' : now.month == 2 ? 'Feb' : now.month == 3 ? 'Mar' : now.month == 4 ? 'Apr' : now.month == 5 ? 'May' : now.month == 6 ? 'Jun' : now.month == 7 ? 'Jul' : now.month == 8 ? 'Aug' : now.month == 9 ? 'Sep' : now.month == 10 ? 'Oct' : now.month == 11 ? 'Nov' : 'Dec'} ${now.year.toString().substring(2)} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} Hrs";
    List<Location> firstPageLocations = [];
    int totalPages = 0;
    const int recordsPerPage = 30;
    if (locations.length > 25) {
      firstPageLocations = locations.sublist(0, 25);
      locations = locations.sublist(25);
    } else {
      firstPageLocations = locations.toList();
      locations = [];
    }
    final pdf = pw.Document();

    totalPages = (locations.length / recordsPerPage).ceil();

    var largeWidth = 25 * PdfPageFormat.inch;
    var standardHeight = PdfPageFormat.a4.height;
    pw.Widget buildHeader(String label) {
      return pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 40,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.lightBlue800,
            ),
          ),
        ],
      );
    }

    pw.Widget buildDetailRow(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(left: 20),
        child: pw.Row(
          children: [
            pw.Container(
              width: 100,
              child: pw.Text(
                label,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Text(': $value'),
          ],
        ),
      );
    }

    pw.Widget buildFooter(String leftContent, String rightContent) {
      return pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 10.0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              leftContent,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
            pw.Text(
              rightContent,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(largeWidth, standardHeight),
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Stack(
              children: [
                pw.Column(
                  children: [
                    buildHeader('Location Register'),
                    pw.SizedBox(height: 20),
                    buildDetailRow(
                      'Project Name',
                      'Explosion Proof (EX) Equipment - Inspection & Repair Works at DPE Facilities',
                    ),
                    buildDetailRow('Client', 'Dubai Petroleum Establishment'),
                    buildDetailRow(
                      'Contractor',
                      'Delta Solutions Engineering Services',
                    ),
                    buildDetailRow('Date Updated', formattedDateHeader),
                    pw.SizedBox(height: 20),
                    pw.TableHelper.fromTextArray(
                      headerStyle: pw.TextStyle(
                        color: PdfColors.white, // Set header text color
                        fontWeight: pw.FontWeight.bold,
                      ),
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors
                            .lightBlue800, // Set header background color
                      ),
                      cellStyle: const pw.TextStyle(color: PdfColors.black),
                      headers: locationPDFHeaders,
                      data: List<List<String>>.generate(
                        firstPageLocations.length,
                        (index) => [
                          (index + 1).toString(),
                          firstPageLocations[index].location,
                          firstPageLocations[index].area,
                          firstPageLocations[index].deckLevel ?? '',
                          firstPageLocations[index].subArea.toString(),
                          firstPageLocations[index].locationLatitude
                                          .toString() !=
                                      "" &&
                                  firstPageLocations[index].locationLongitude
                                          .toString() !=
                                      ""
                              ? (firstPageLocations[index].locationLatitude +
                                    ", " +
                                    firstPageLocations[index].locationLongitude)
                              : '',
                          firstPageLocations[index].zone ?? '',
                          firstPageLocations[index].locationGasGroup.join(', '),
                          firstPageLocations[index].locationTClass.join(', '),
                          // firstPageLocations[index].tAmbient ?? '',
                          firstPageLocations[index].areaClassDrawAttachOrgName
                              .join('\n'),
                          firstPageLocations[index].eqpmtLytDrawAttachOrgName
                              .join('\n'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: buildFooter(
                    "Area Detail updated on $formattedDate @ ${now.year.toString()} by DelEx Software",
                    "Explosion Proof (EX) - Inspection Repair Works at DPE Facilities",
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    for (int i = 0; i < totalPages; i++) {
      final start = i * recordsPerPage;
      final end = start + recordsPerPage < locations.length
          ? start + recordsPerPage
          : locations.length;

      final pageRecords = locations.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(largeWidth, standardHeight),
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Stack(
                children: [
                  pw.Column(
                    children: [
                      pw.TableHelper.fromTextArray(
                        headerStyle: pw.TextStyle(
                          color: PdfColors.white, // Set header text color
                          fontWeight: pw.FontWeight.bold,
                        ),
                        headerDecoration: const pw.BoxDecoration(
                          color: PdfColors
                              .lightBlue800, // Set header background color
                        ),
                        cellStyle: const pw.TextStyle(color: PdfColors.black),
                        headers: locationPDFHeaders,
                        data: List<List<String>>.generate(pageRecords.length, (
                          index,
                        ) {
                          List<String> row = [
                            indexNumber.toString(),
                            pageRecords[index].location,
                            pageRecords[index].area,
                            pageRecords[index].deckLevel ?? '',
                            pageRecords[index].subArea.toString(),
                            pageRecords[index].locationLatitude.toString() !=
                                        "" &&
                                    pageRecords[index].locationLongitude
                                            .toString() !=
                                        ""
                                ? (pageRecords[index].locationLatitude +
                                      ", " +
                                      pageRecords[index].locationLongitude)
                                : '',
                            pageRecords[index].zone ?? '',
                            pageRecords[index].locationGasGroup.join(', '),
                            pageRecords[index].locationTClass.join(', '),
                            // pageRecords[index].tAmbient ?? '',
                            pageRecords[index].areaClassDrawAttachOrgName.join(
                              '\n',
                            ),
                            pageRecords[index].eqpmtLytDrawAttachOrgName.join(
                              '\n',
                            ),
                          ];
                          indexNumber++;
                          return row;
                        }),
                      ),
                    ],
                  ),
                  pw.Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: buildFooter(
                      "Area Detail updated on $formattedDate @ ${now.year.toString()} by DelEx Software",
                      "Explosion Proof (EX) - Inspection Repair Works at DPE Facilities",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    try {
      // final path = await FileDownloadUtil().getLocalPath;
      // File file = File('$path/Location Register $timestamp.pdf');
      // await file.writeAsBytes(await pdf.save());
      final fileDownloadUtil = FileDownloadUtil();
      final path = await fileDownloadUtil.getLocalPath;
      File file = File('$path/Location Register $timestamp.pdf');
      await file.writeAsBytes(await pdf.save());
      await fileDownloadUtil.scanFile(file.path);
      return {
        "status": true,
        "location": "$path/Location Register $timestamp.pdf",
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
