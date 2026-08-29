import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_bloc.dart';
import '../../bloc/location_bloc.dart';
import '../../bloc/location_events.dart';
import '../../data/models/location_model.dart';

void showDownloadEXOptionsMenu(
  BuildContext context,
  Offset position,
  String type, {
  List<ExRegister>? assets,
  List<Location>? locations,
  required List<String> selectedIds,
  DateTime? fromDate,
  DateTime? toDate,
  String? datetype,
  String? showFilterType,
  required String searchQuery,
  required Map<String, List<String>> filters,
  required ExRegisterBloc bloc,
}) {
  // final RenderBox overlay =
  //     Overlay.of(context).context.findRenderObject() as RenderBox;
  final Size screenSize = MediaQuery.of(context).size;
  final bool isPortrait = screenSize.height > screenSize.width;
  // final double fontSize =
  //     isPortrait ? screenSize.height * 0.015 : screenSize.width * 0.015;
  final double iconSize = isPortrait
      ? screenSize.height * 0.03
      : screenSize.width * 0.03;
  // const double dialogWidth = 150.0;
  // final Offset adjustedPosition = type == "asset"
  // ? Offset(
  //     isPortrait
  //         ? screenSize.width * 1.0
  //         : selectedIds.isEmpty
  //             ? screenSize.height * 1.60
  //             : screenSize.height * 1.54,
  //     isPortrait
  //         ? screenSize.height * 0.16
  //         : selectedIds.isEmpty
  //             ? screenSize.width * 0.15
  //             : screenSize.width * 0.15,
  //   )
  // : Offset(
  //     isPortrait ? screenSize.width * 0.8 : screenSize.height * 1.37,
  //     isPortrait ? screenSize.height * 0.1 : screenSize.width * 0.16,
  //   );
  // final Offset adjustedPosition = Offset(position.dx + 60, position.dy+15);

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
              final double screenHeight = MediaQuery.of(context).size.height;
              final bool isPortrait =
                  MediaQuery.of(context).orientation == Orientation.portrait;
              final double dialogWidth = isPortrait
                  ? screenWidth * 0.4
                  : screenWidth * 0.12;
              final double dialogHeight = isPortrait
                  ? screenHeight * 0.4
                  : screenHeight * 0.8;
              final double offsetX = type == "asset"
                  ? selectedIds.isEmpty
                        ? (constraints.maxWidth - dialogWidth) * 0.967
                        : (constraints.maxWidth - dialogWidth) * 0.93
                  : (constraints.maxWidth - dialogWidth) * 0.81;
              final double offsetY = type == "asset"
                  ? selectedIds.isEmpty
                        ? (constraints.maxHeight - dialogHeight) * 1.36
                        : (constraints.maxHeight - dialogHeight) * 1.36
                  : (constraints.maxHeight - dialogHeight) * 1.42;

              return Stack(
                children: [
                  Positioned(
                    // top: screenHeight * (isPortrait ? 0.14 : 0.2),
                    // right: MediaQuery.of(context).size.width * 0.01,
                    left: offsetX,
                    top: offsetY,
                    child: PopupMenuItem(
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: dialogWidth,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 8.0),
                              leading: SvgPicture.asset(
                                'lib/src/features/functional_areas/assets/svg/pdf_icon.svg',
                                width: iconSize,
                                height: iconSize,
                              ),
                              title: Text(
                                'PDF',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  height: 24 / 17,
                                ),
                              ),
                              onTap: () {
                                downloadFile(
                                  "pdf",
                                  type,
                                  context,
                                  assets: assets,
                                  locations: locations,
                                  selectedIds: selectedIds,
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  datetype: datetype,
                                  showFilterType: showFilterType,
                                  searchQuery: searchQuery,
                                  filters: filters,
                                  bloc: bloc,
                                );
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 8.0),
                              leading: SvgPicture.asset(
                                'lib/src/features/functional_areas/assets/svg/excel_icon.svg',
                                width: iconSize,
                                height: iconSize,
                              ),
                              title: Text(
                                'Excel',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  height: 24 / 17,
                                ),
                              ),
                              onTap: () {
                                downloadFile(
                                  "excel",
                                  type,
                                  context,
                                  assets: assets,
                                  locations: locations,
                                  selectedIds: selectedIds,
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  datetype: datetype,
                                  showFilterType: showFilterType,
                                  searchQuery: searchQuery,
                                  filters: filters,
                                  bloc: bloc,
                                );
                                Navigator.pop(context);
                              },
                            ),
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
    },
  );
}

Future<void> downloadFile(
  String fileType,
  String from,
  BuildContext context, {
  List<ExRegister>? assets,
  List<Location>? locations,
  required List<String> selectedIds,
  DateTime? fromDate,
  DateTime? toDate,
  String? datetype,
  String? showFilterType,
  required String searchQuery,
  required Map<String, List<String>> filters,
  required ExRegisterBloc bloc,
}) async {
  if (from == "asset") {
    bloc.add(
      ExRegisterDownload(
        fileType: fileType,
        assets: assets ?? [],
        assetIds: selectedIds,
        fromDate: fromDate,
        toDate: toDate,
        type: datetype,
        showAllFilterType: showFilterType,
        searchQuery: searchQuery,
      ),
    );
  } else {
    context.read<LocationBloc>().add(
      LocationDownload(
        fileType: fileType,
        locations: locations ?? [],
        locationIds: selectedIds,
        searchQuery: searchQuery,
        filters: filters,
      ),
    );
  }
}
