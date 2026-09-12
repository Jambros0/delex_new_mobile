// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/ex_register_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/ex_register_bloc.dart';
import '../../bloc/ex_register_event.dart';

class MoreVertDialog extends StatefulWidget {
  final List<String> selectedAssetIds;
  final String type;
  final String? showFilterType;
  final DateTime? fromDate;
  final DateTime? toDate;
  const MoreVertDialog({
    super.key,
    required this.selectedAssetIds,
    required this.type,
    this.showFilterType,
    this.fromDate,
    this.toDate,
  });

  @override
  MoreVertDialogState createState() => MoreVertDialogState();
}

class MoreVertDialogState extends State<MoreVertDialog> {
  String? alreadySelected;
  void Function(String?)? onFilterSelected;
  String selectedValue = '';
  List<ExRegister> assets = [];
  final ExregisterRepo exregisterRepo = ExregisterRepo();
  // final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double buttonWidth =
        isPortrait ? screenWidth * 0.16 : screenWidth * 0.19;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showCustomPositionedDialog(context, buttonWidth);
      },
      child: const Icon(Icons.more_vert, size: 34),
    );
  }

  void _showCustomPositionedDialog(BuildContext context, double buttonWidth) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double dialogFontSize = isPortrait ? 14 : 16;

    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: const Color(0x14000000),
        barrierLabel: 'Dismiss',
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = MediaQuery.of(context).size.width;
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  final bool isPortrait = MediaQuery.of(context).orientation ==
                      Orientation.portrait;
                  final double dialogWidth =
                      isPortrait ? screenWidth * 0.4 : screenWidth * 0.28;
                  final double dialogHeight =
                      isPortrait ? screenHeight * 0.4 : screenHeight * 0.8;
                  final double offsetX =
                      (constraints.maxWidth - dialogWidth) * 1.08;
                  final double offsetY =
                      (constraints.maxHeight - dialogHeight) * 1.36;

                  return Stack(
                    children: [
                      Positioned(
                        // top: screenHeight * (isPortrait ? 0.14 : 0.2),
                        // right: MediaQuery.of(context).size.width * 0.01,
                        left: offsetX,
                        top: offsetY,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: buttonWidth,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                widget.selectedAssetIds.length > 1
                                    ? const SizedBox()
                                    : _buildOption(context, 'Inspect',
                                        dialogFontSize, setState),
                                widget.selectedAssetIds.length > 1
                                    ? const SizedBox()
                                    : _buildOption(context, 'Repair',
                                        dialogFontSize, setState),
                                widget.selectedAssetIds.length > 1
                                    ? const SizedBox()
                                    : _buildOption(context, 'Duplicate',
                                        dialogFontSize, setState),
                                _buildOption(context, 'Delete', dialogFontSize,
                                    setState),
                                widget.selectedAssetIds.length > 1
                                    ? const SizedBox()
                                    : _buildOption(context, 'Directions',
                                        dialogFontSize, setState),
                                widget.selectedAssetIds.length > 1
                                    ? const SizedBox()
                                    : _buildOption(context, 'Generate ITR',
                                        dialogFontSize, setState),
                                const SizedBox(height: 20),
                                _buildButton(context, dialogFontSize),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        });
  }

  Widget _buildOption(BuildContext context, String option, double fontSize,
      StateSetter setState) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedValue = option;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedValue == option
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        // padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Radio<String>(
              activeColor: selectedValue == option
                  ? const Color(0xFF3B475B)
                  : const Color(0xFF9C9C9C),
              value: option,
              groupValue: selectedValue,
              onChanged: (String? value) {
                setState(() {
                  selectedValue = option;
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              option,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black, // Optional text color change
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: InkWell(
          onTap: () {
            Navigator.pop(context); // Button action
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 16), // Padding for button size
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
            ),
            child: const Center(
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF002B5C), // Text color
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        )),
        const SizedBox(width: 5),
        Expanded(
            child: InkWell(
          onTap: () {
            if (widget.selectedAssetIds.isNotEmpty) {
              if (selectedValue == "Inspect") {
                widget.selectedAssetIds.length != 1
                    ? null
                    : _navigateToInspectionScreen(
                        widget.selectedAssetIds[0], 2);
              } else if (selectedValue == "Repair") {
                widget.selectedAssetIds.length != 1
                    ? null
                    : _navigateToInspectionScreen(
                        widget.selectedAssetIds[0], 4);
              } else if (selectedValue == "Duplicate") {
                Navigator.pop(context);
                widget.selectedAssetIds.length != 1
                    ? null
                    : _fetchAssetData(widget.selectedAssetIds, 'duplicate');
              } else if (selectedValue == "Delete") {
                Navigator.pop(context);
                _showDeleteConfirmation();
              } else if (selectedValue == "Directions") {
                widget.selectedAssetIds.length != 1
                    ? null
                    : _fetchAssetDataForDirections(widget.selectedAssetIds[0]);
                Navigator.pop(context);
              } else if (selectedValue == "Generate ITR") {
                widget.selectedAssetIds.length != 1
                    ? null
                    : _fetchAssetDataForItr(widget.selectedAssetIds[0]);
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue, // Background color
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                "Go".toUpperCase(),
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white, // Text color
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ))
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            height: 219,
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: Color(0xFFF1F1F1),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(2, 4),
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 83,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Delete Confirmation',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF1C232E),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 0.07,
                                    letterSpacing: 0.90,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Are you sure you want to delete this file?',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF3B475B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 0.11,
                                    letterSpacing: 0.70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 1, color: Color(0xFF8C8C8C)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C1B2029),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Cancel',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: const Color(0xFF1C232E),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 0.08,
                                          letterSpacing: 0.80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop(true);
                            _fetchAssetData(widget.selectedAssetIds, 'delete');
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1E90FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C1B2029),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Delete',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: const Color(0xFFFAFBFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 0.08,
                                          letterSpacing: 0.80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToInspectionScreen(String assetId, int step) {
    Navigator.pushNamed(context, '/home', arguments: {
      'menu': 'Ex Inspections',
      'isCollapsed': true,
      'assetId': assetId,
      'step': step,
      'fromExRegister': true
    });
  }

  Future<void> _fetchAssetData(List<String> assetIds, String type) async {
    if (type == 'delete') {
      BlocProvider.of<ExRegisterBloc>(context).add(ExRegisterDuplicateOrDelete(
          assetId: '', type: type, assetIds: assetIds));
    } else {
      for (String assetId in assetIds) {
        BlocProvider.of<ExRegisterBloc>(context).add(
            ExRegisterDuplicateOrDelete(
                assetId: assetId, type: type, assetIds: assetIds));
      }
    }
  }

  Future<void> _fetchAssetDataForItr(String assetId) async {
    BlocProvider.of<ExRegisterBloc>(context)
        .add(ExRegisterGenerateItr(assetId: assetId));
  }

  Future<void> _fetchAssetDataForDirections(String assetId) async {
    try {
      final Map<String, dynamic>? exRegister =
          await exregisterRepo.getExRegisterByJsonId(assetId);
      if (exRegister == null) return;
      final exregisterJson = jsonDecode(exRegister['exregister_json']);
      final asset = exregisterJson['asset'];
      final gpsCord = asset?['gpsCord'];
      // final String? userType = await authUtils.getUserType();
      // final functionalAreaData = (userType == 'onshore')
      //     ? await _dbHelper.getFunctionalAreaByIdOnshore(asset['locationId'])
      //     : await _dbHelper.getFunctionalAreaById(asset['locationId']);
      // final functionalAreaJson = functionalAreaData == null
      //     ? null
      //     : jsonDecode(functionalAreaData['functional_area_json']);
      // Location location = Location.fromJson(functionalAreaJson['location']);
      if (gpsCord != null) {
        Navigator.pushNamed(
          context,
          '/home',
          arguments: {
            'menu': 'Locator',
            'isCollapsed': true,
            'gpsCord': gpsCord,
            'assetId': asset?['locationId'] ?? '',
          },
        );
      }
    } catch (e) {}
  }
}
