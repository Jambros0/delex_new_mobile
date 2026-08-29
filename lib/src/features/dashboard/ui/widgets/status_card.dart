// ignore_for_file: must_be_immutable
import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/bloc/dashboard_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/ui/widgets/equipment_chart.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/ui/widgets/repairs_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusCard extends StatefulWidget {
  bool isBeforeRepairs;
  final Function(bool) onChangedValue;
  double height;
  double width;
  DateTime? toDate;
  DateTime? fromDate;
  final Map<String, int> statusCounts;
  final Map<String, dynamic> repairedChartCounts;
  final Map<String, int> equipmentCounts;
  final List<String> selectedLocations;
  String dataType;
  StatusCard(
      {super.key,
      required this.isBeforeRepairs,
      required this.onChangedValue,
      required this.height,
      required this.width,
      required this.statusCounts,
      required this.repairedChartCounts,
      required this.equipmentCounts,
      required this.selectedLocations,
      this.toDate,
      this.fromDate,
      required this.dataType});

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  DashboardBloc get _bloc => BlocProvider.of<DashboardBloc>(context);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, orientation) {
      final bool isPortrait = orientation == Orientation.portrait;
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;

      final double paddingValuePortrait = (screenWidth + screenHeight) * 0.002;

      final double paddingValueLandscape = (screenWidth + screenHeight) * 0.006;

      final double paddingValue =
          isPortrait ? paddingValuePortrait : paddingValueLandscape;

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: paddingValue * 1.2,
                bottom: paddingValue * 0.5,
                left: paddingValue * 1.2,
                right: paddingValue * 2.2),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home',
                                  arguments: {
                                    'menu': 'Ex Register',
                                    'filter': 'Uninspected',
                                    'fromDatefilter': widget.fromDate,
                                    'ToDatefilter': widget.toDate,
                                    'fltertype': widget.dataType,
                                    'isCollapsed': true,
                                    'isSelectedScreen': "Dashboard",
                                    'isSelectedScreenFlag': false,
                                  });
                            },
                            child: buildCard(
                              width: widget.width,
                              height: widget.height,
                              containerColor: const Color(0xFFA4D4FA),
                              iconColor: Colors.white,
                              iconName:
                                  "lib/src/features/dashboard/assets/svg/uninspection.svg",
                              titleName: "Uninspected",
                              count: widget.statusCounts['unInspected'] == null
                                  ? "0"
                                  : widget.statusCounts['unInspected']
                                      .toString(),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home',
                                  arguments: {
                                    'menu': 'Ex Register',
                                    'filter': 'Inspected',
                                    'fromDatefilter': widget.fromDate,
                                    'ToDatefilter': widget.toDate,
                                    'fltertype': widget.dataType,
                                    'isCollapsed': true,
                                    'isSelectedScreen': "Dashboard",
                                    'isSelectedScreenFlag': false,
                                  });
                            },
                            child: buildCard(
                              width: widget.width,
                              height: widget.height,
                              containerColor: const Color(0xFFB6DEB7),
                              iconColor: Colors.white,
                              iconName:
                                  "lib/src/features/dashboard/assets/svg/inspection.svg",
                              titleName: "Inspected",
                              count: widget.statusCounts['inspected'] == null
                                  ? "0"
                                  : widget.statusCounts['inspected'].toString(),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: widget.width * 0.06),
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home',
                                  arguments: {
                                    'menu': 'Ex Register',
                                    'filter': 'Repaired Partially',
                                    'fromDatefilter': widget.fromDate,
                                    'ToDatefilter': widget.toDate,
                                    'fltertype': widget.dataType,
                                    'isCollapsed': true,
                                    'isSelectedScreen': "Dashboard",
                                    'isSelectedScreenFlag': false,
                                  });
                            },
                            child: buildCard(
                              width: widget.width,
                              height: widget.height,
                              containerColor: const Color(0xFFFFE699),
                              iconColor: Colors.white,
                              iconName:
                                  "lib/src/features/dashboard/assets/svg/partially_repaired.svg",
                              titleName: "Partially Repaired",
                              count: widget.statusCounts['partiallyRepaired'] ==
                                      null
                                  ? "0"
                                  : widget.statusCounts['partiallyRepaired']
                                      .toString(),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home',
                                  arguments: {
                                    'menu': 'Ex Register',
                                    'filter': 'Repaired Completely',
                                    'fromDatefilter': widget.fromDate,
                                    'ToDatefilter': widget.toDate,
                                    'fltertype': widget.dataType,
                                    'isCollapsed': true,
                                    'isSelectedScreen': "Dashboard",
                                    'isSelectedScreenFlag': false,
                                  });
                            },
                            child: buildCard(
                              width: widget.width,
                              height: widget.height,
                              containerColor: const Color(0xFFB6DEB7),
                              iconColor: Colors.white,
                              iconName:
                                  "lib/src/features/dashboard/assets/svg/completely_repaired.svg",
                              titleName: "Completely Repaired",
                              count: widget
                                          .statusCounts['completelyRepaired'] ==
                                      null
                                  ? "0"
                                  : widget.statusCounts['completelyRepaired']
                                      .toString(),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/home',
                                  arguments: {
                                    'menu': 'Ex Register',
                                    'filter': 'Corrective Actions',
                                    'fromDatefilter': widget.fromDate,
                                    'ToDatefilter': widget.toDate,
                                    'fltertype': widget.dataType,
                                    'isCollapsed': true,
                                    'isSelectedScreen': "Dashboard",
                                    'isSelectedScreenFlag': false,
                                  });
                            },
                            child: Container(
                              width: double.infinity,
                              height: 96,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFFAB2AD)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: SvgPicture.asset(
                                      "lib/src/features/dashboard/assets/svg/pending_repairs.svg",
                                      width: 22,
                                      height: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 6,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Pending Repairs",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.inter(
                                            height: 16 / 12,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          widget.statusCounts[
                                                      'pendingRepaired'] ==
                                                  null
                                              ? "0"
                                              : widget.statusCounts[
                                                      'pendingRepaired']
                                                  .toString(),
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.inter(
                                            height: 20 / 14,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                      flex: 1,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: screenHeight * 0.029,
                                            width: screenWidth * 0.023,
                                            padding: const EdgeInsets.all(6.9),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.25),
                                                  blurRadius: 4.0,
                                                  spreadRadius: 0.0,
                                                  offset: const Offset(0, 1.33),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: SvgPicture.asset(
                                              'lib/src/features/dashboard/assets/svg/arrow_outline.svg',
                                              width: 8,
                                              height: 8,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                Colors.black,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))
                                  // Expanded(
                                  //   flex: 1,
                                  //   child: SvgPicture.asset(
                                  //     'lib/src/features/dashboard/assets/svg/arrow_outline.svg',
                                  //     width: 10,
                                  //     height: 10,
                                  //     colorFilter: const ColorFilter.mode(
                                  //         Colors.black, BlendMode.srcIn),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: paddingValue * 1.4,
                bottom: paddingValue * 2.2,
                left: paddingValue * 1.2,
                right: paddingValue * 2.2),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFF2F2F7)),
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    "Equipment Status",
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                        fontSize: 17,
                                        height: 24 / 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Container(
                                    width: 220,
                                    height: 38,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      boxShadow: const [
                                        BoxShadow(
                                          color:
                                              Color.fromRGBO(0, 43, 92, 0.24),
                                          blurRadius: 2,
                                          spreadRadius: 0,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        AnimatedAlign(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          curve: Curves.easeInOut,
                                          alignment: widget.isBeforeRepairs
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          child: Container(
                                            width: 104,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  _bloc.add(YearToDateFilterDashboard(
                                                      toDate: widget.toDate,
                                                      fromDate: widget.fromDate,
                                                      isBefore: true,
                                                      selectedLocations: widget
                                                          .selectedLocations,
                                                      type: widget
                                                          .dataType)); // Dispatch event
                                                  widget.onChangedValue(true);
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Before Repairs",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          height: 14 / 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  _bloc.add(YearToDateFilterDashboard(
                                                      toDate: widget.toDate,
                                                      fromDate: widget.fromDate,
                                                      isBefore: false,
                                                      selectedLocations: widget
                                                          .selectedLocations,
                                                      type: widget
                                                          .dataType)); // Dispatch event
                                                  widget.onChangedValue(false);
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "After Repairs",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          height: 14 / 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xFFF2F2F7),
                              ),
                              EquipmentChart(
                                statusZero: widget.statusCounts.values
                                    .every((value) => value == 0),
                                equipmentCounts: widget.isBeforeRepairs
                                    ? widget.equipmentCounts
                                    : widget.equipmentCounts,
                              ),
                            ],
                          )),
                    ),
                    SizedBox(
                      width: widget.width * 0.09,
                    ),
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFF2F2F7)),
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Repair Analysis",
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                        fontSize: 17,
                                        height: 24 / 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Container(
                                      width: screenWidth * 0.15,
                                      height: screenHeight * 0.047,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Total Repairs",
                                            textAlign: TextAlign.left,
                                            style: GoogleFonts.inter(
                                                fontSize: 14,
                                                height: 21 / 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Text(
                                            widget.repairedChartCounts[
                                                        'total'] ==
                                                    null
                                                ? "0 Nos"
                                                : "${widget.repairedChartCounts['total']} Nos",
                                            textAlign: TextAlign.right,
                                            style: GoogleFonts.inter(
                                                fontSize: 15,
                                                height: 20 / 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                              const Divider(
                                color: Color(0xFFF2F2F7),
                              ),
                              RepairsChart(
                                  statusCounts: widget.statusCounts,
                                  statusZero: widget.statusCounts.values
                                      .every((value) => value == 0),
                                  repairedChartCounts:
                                      widget.repairedChartCounts)
                            ],
                          )),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget buildCard(
      {required dynamic iconName,
      required dynamic titleName,
      required dynamic count,
      required Color containerColor,
      required Color iconColor,
      required double width,
      required double height,
      required GestureTapCallback? onTap}) {
    return LayoutBuilder(builder: (context, orientation) {
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;

      return Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
            border: Border.all(color: containerColor),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: SvgPicture.asset(
                iconName,
                height: 17,
                width: 16,
                // colorFilter: const ColorFilter.mode(
                //   Colors.black,
                //   BlendMode.srcIn,
                // ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titleName,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                          height: 16 / 12,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      count,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                          height: 20 / 14,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )),
            const SizedBox(
              width: 16,
            ),
            Expanded(
                flex: 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: screenHeight * 0.029,
                        width: screenWidth * 0.023,
                        padding: const EdgeInsets.all(6.9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4.0,
                              spreadRadius: 0.0,
                              offset: const Offset(0, 1.33),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: SvgPicture.asset(
                          'lib/src/features/dashboard/assets/svg/arrow_outline.svg',
                          width: 8,
                          height: 8,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      );
    });
  }
}
