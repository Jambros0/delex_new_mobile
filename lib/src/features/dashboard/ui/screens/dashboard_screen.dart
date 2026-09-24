// ignore_for_file: unrelated_type_equality_checks, unused_field

import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/bloc/dashboard_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/ui/widgets/location_field.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/ui/widgets/status_card.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/dropdown_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/auth_util.dart';
import '../../../ex_register/data/models/dateFilterModel.dart';
import '../../../ex_register/ui/widgets/date_picker_box.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateFilter? date;
  final authUtils = AuthUtils();
  // final DBHelper _dbHelper = DBHelper();
  bool customRangeFlag = false;
  bool isBeforeRepairs = true;
  List<String> locationDropDown = [];
  String selectedFilter = 'All Locations';
  Map<String, dynamic>? _allDropDowns;
  final DropdownRepository dropdownRepository = DropdownRepository();
  String? _userType;
  List<String> selectedLocations = [];

  String dateType = 'Year to Date';

  @override
  void initState() {
    super.initState();
    _initDateFilter();
    // _loadUserType();
    locationDropDownFields();
  }

  Future<void> locationDropDownFields() async {
    final userType = await AuthUtils().getUserType();

    _allDropDowns = await dropdownRepository.getLocalDropDownData();
    if (!mounted) return;
    setState(() {
      final locationDropDownMap = _allDropDowns!['result']['locationDropDown']
          [0] as Map<String, dynamic>;
      final fieldNames =
          (locationDropDownMap['locationDropDown'] as List<dynamic>)
              .map((item) => item['name'].toString())
              .toList();

      _userType = userType;
      locationDropDown = fieldNames;
      selectedFilter = 'All Locations';
      selectedLocations = List.from(fieldNames);
    });
  }

  Future<void> _initDateFilter() async {
    final now = DateTime.now();
    final userType = await authUtils.getUserType();
    _userType = userType;
    final DateTime defaultStartDate = (_userType == 'onshore')
        ? DateTime(2023, 6, 13)
        : DateTime(2022, 5, 18);

    _allDropDowns = await dropdownRepository.getLocalDropDownData();
    if (!mounted) return;
    setState(() {
      final locationDropDownMap = _allDropDowns!['result']['locationDropDown']
          [0] as Map<String, dynamic>;
      final fieldNames =
          (locationDropDownMap['locationDropDown'] as List<dynamic>)
              .map((item) => item['name'].toString())
              .toList();
      date = DateFilter(
          filterType: "Year to Date",
          fromDate: defaultStartDate,
          toDate: DateTime(now.year, now.month, now.day));
      BlocProvider.of<DashboardBloc>(context).add(YearToDateFilterDashboard(
        fromDate: defaultStartDate,
        toDate: DateTime(now.year, now.month, now.day),
        isBefore: isBeforeRepairs,
        selectedLocations: fieldNames,
        type: "Year to Date",
      ));
      // BlocProvider.of<DashboardBloc>(context).add(
      //   LocationFilterDashboard(
      //     selectedLocations: userType == 'onshore'
      //         ? ['GCS', 'Margham', 'LNG Jetty', 'Pipeline']
      //         : [
      //             'Fateh Complex',
      //             'Fateh NUI',
      //             'SWF Complex',
      //             'SWF NUI',
      //             'Rashid'
      //           ],
      //     isBefore: isBeforeRepairs,
      //     // fromDate: DateTime(2025, 02, 25),
      //     // toDate: DateTime(2025, 02, 25),
      //   ),
      // );
    });
  }

  // Future<void> _loadUserType() async {
  //   final userType = await AuthUtils().getUserType();
  //   setState(() {
  //     _userType = userType;
  //     locationDropDown = _userType == 'onshore'
  //         ? ['GCS', 'Margham', 'LNG Jetty', 'Pipeline']
  //         : ['Fateh Complex', 'Fateh NUI', 'SWF Complex', 'SWF NUI', 'Rashid'];
  //   });
  // }

  void _updateDateRange(String? type, DateTime? fromDate, DateTime? toDate,
      bool isReset, String isSelectedtype) async {
    setState(() {
      if (type == "Custom Range") {
        customRangeFlag = true;
      } else {
        customRangeFlag = false;
      }
      if (isSelectedtype == "") {
        dateType = "Custom Range";
        type = "Custom Range";
        fromDate = DateTime.now();
        toDate = DateTime.now();
        date = DateFilter(filterType: type, fromDate: fromDate, toDate: toDate);
      } else {
        dateType = type!;
        date = DateFilter(filterType: type, fromDate: fromDate, toDate: toDate);
      }
    });
    BlocProvider.of<DashboardBloc>(context).add(YearToDateFilterDashboard(
      fromDate: date?.fromDate,
      toDate: date?.toDate,
      isBefore: isBeforeRepairs,
      selectedLocations: (selectedFilter.toLowerCase() == 'all fields' ||
              selectedFilter.toLowerCase() == 'all locations')
          ? locationDropDown
          : selectedLocations,
      type: dateType,
    ));

    // BlocProvider.of<ExRegisterBloc>(context).add(YearToDateFilterExRegister(
    //     fromDate: date?.fromDate, toDate: date?.toDate, isReset: isReset));
  }

  void _onChangedValue(bool type) async {
    setState(() {
      isBeforeRepairs = type;
    });
  }

  void _showFilterPopup(
    BuildContext context,
    Offset position,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x14000000),
      barrierLabel: 'Filter',
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            LocationField(
                position: position,
                locationDropDown: locationDropDown,
                onFilterApplied: (selectedFilters) async {
                  setState(() {
                    selectedLocations = selectedFilters;
                    selectedFilter = (selectedFilters.length >= locationDropDown.length ||
                            selectedFilters.isEmpty)
                        ? 'All Locations'
                        : selectedFilters.join(', ');
                  });
                  await authUtils.setDashboardFilter(selectedFilter);
                  if (selectedFilter == "All Locations" ||
                      selectedLocations.isEmpty ||
                      selectedLocations.length == locationDropDown.length) {
                    BlocProvider.of<DashboardBloc>(context).add(
                      LocationFilterDashboard(
                        selectedLocations: locationDropDown,
                        isBefore: isBeforeRepairs,
                        toDate: date?.toDate,
                        fromDate: date?.fromDate,
                        type: dateType,
                      ),
                    );
                  } else {
                    BlocProvider.of<DashboardBloc>(context).add(
                      LocationFilterDashboard(
                        selectedLocations: selectedFilters,
                        isBefore: isBeforeRepairs,
                        toDate: date?.toDate,
                        fromDate: date?.fromDate,
                        type: dateType,
                      ),
                    );
                  }
                },
                resetFilters: (selectedFilters) {
                  setState(() {
                    selectedLocations = List.from(locationDropDown);
                    selectedFilter = 'All Locations';
                  });
                  BlocProvider.of<DashboardBloc>(context).add(
                    LocationFilterDashboard(
                      selectedLocations: locationDropDown,
                      isBefore: isBeforeRepairs,
                      toDate: date?.toDate,
                      fromDate: date?.fromDate,
                      type: dateType,
                    ),
                  );
                },
                selectedFilters: selectedLocations)
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, orientation) {
        final bool isPortrait = orientation == Orientation.portrait;
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;

        final double searchBarWidthPortrait = screenWidth * 0.3;
        final double paddingValuePortrait =
            (screenWidth + screenHeight) * 0.002;
        final double buttonHeightPortrait = (screenWidth + screenHeight) * 0.02;

        final double searchBarWidthLandscape = screenWidth * 0.35;
        final double paddingValueLandscape =
            (screenWidth + screenHeight) * 0.006;
        final double buttonHeightLandscape =
            (screenWidth + screenHeight) * 0.025;

        final double searchBarWidth =
            isPortrait ? searchBarWidthPortrait : searchBarWidthLandscape;
        final double paddingValue =
            isPortrait ? paddingValuePortrait : paddingValueLandscape;
        final double buttonHeight =
            isPortrait ? buttonHeightPortrait : buttonHeightLandscape;
        final double customHorizantal = screenWidth * 0.015;
        return Padding(
          padding: EdgeInsets.only(
              left: customHorizantal,
              right: customHorizantal,
              top: screenHeight * 0.02,
              bottom: screenHeight * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: paddingValue),
                child: Text(
                  'Dashboard',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: paddingValue * 1.5,
                            bottom: paddingValue * 1.2,
                            left: paddingValue * 1.2,
                            right: paddingValue * 1.2),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Text(
                              'Status Overview',
                              style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTapDown: (TapDownDetails details) {
                                    _showFilterPopup(
                                        context, details.globalPosition);
                                  },
                                  child: Container(
                                    width: isPortrait ? 180 : 160,
                                    height: (48 / screenHeight) * screenHeight,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.015,
                                      vertical: screenHeight * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFB3B3B3),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          fit: FlexFit.tight,
                                          child: Text(
                                            selectedFilter,
                                            style: GoogleFonts.inter(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF212121),
                                              height: 24 / 17,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF3B475B),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                YearToDateBox(
                                    dateType: dateType,
                                    customRangeFlag: customRangeFlag,
                                    type: "dashboard",
                                    height: 38,
                                    width: isPortrait ? 180 : 160,
                                    onDateRangeSelected: _updateDateRange,
                                    selectedDateFilter: date),
                              ],
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<DashboardBloc, DashboardState>(
                        buildWhen: (previous, current) =>
                            current is DashboardLoaded,
                        builder: (context, state) {
                          if (state is DashboardLoaded) {
                            return StatusCard(
                              statusCounts: state.statusCounts,
                              height: buttonHeight,
                              width: searchBarWidth,
                              isBeforeRepairs: isBeforeRepairs,
                              repairedChartCounts: state.repairedChartCounts,
                              onChangedValue: _onChangedValue,
                              equipmentCounts: state.equipmentCounts,
                              selectedLocations: (selectedFilter.toLowerCase() ==
                                          'all fields' ||
                                      selectedFilter.toLowerCase() ==
                                          'all locations')
                                  ? locationDropDown
                                  : selectedLocations,
                              toDate: date?.toDate,
                              fromDate: date?.fromDate,
                              dataType: dateType,
                            );
                          } else {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

void navigateToHome(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/home', arguments: {
    'menu': 'Ex Inspections',
    'isCollapsed': true,
    'assetId': null,
  });
}
