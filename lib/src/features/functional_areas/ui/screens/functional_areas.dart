// ignore_for_file: deprecated_member_use

import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_states.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/ui/widgets/download_option_popup.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/ui/widgets/filter_box.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/ui/widgets/location_table.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';

import '../../data/models/location_model.dart';

class FunctionalAreasScreen extends StatefulWidget {
  const FunctionalAreasScreen({super.key});

  @override
  FunctionalAreasScreenState createState() => FunctionalAreasScreenState();
}

class FunctionalAreasScreenState extends State<FunctionalAreasScreen> {
  List<Location> locations = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode searchFocus = FocusNode();
  FocusNode searchFoucs = FocusNode();
  String _searchQuery = '';
  String showSelectedCount = "0";
  bool showErrorIDColor = false;
  bool isLoadMore = false;
  String? _userType;
  List<String> selectedLocations = [];
  Map<String, String> _filters = {};
  Map<String, List<String>> filterList = {};
  late List<String> selectedLists;

  @override
  void initState() {
    super.initState();
    selectedLists = [];
    showSelectedCount = "0";

    final bloc = BlocProvider.of<LocationBloc>(context);
    bloc
      ..add(LocationsInitEvent())
      ..add(LoadLocations());

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });

    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final userType = await AuthUtils().getUserType();
    setState(() => _userType = userType);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, String> _getFieldNames() {
    return {
      'Field Name': _userType == 'onshore' ? 'Location' : 'Field Name',
      'Platform': _userType == 'onshore' ? 'SubLocation' : 'Platform',
      'Deck Level': _userType == 'onshore' ? 'Area' : 'Deck Level',
    };
  }

  void _onFilterApply(Map<String, List<String>> filters) {
    final fieldNames = _getFieldNames();

    final selectedFilters = {
      for (var key in fieldNames.entries)
        if (filters[key.value]?.isNotEmpty ?? false)
          key.key: filters[key.value]!.join(','),
    };

    setState(() {
      filterList = filters;
      _filters = selectedFilters;
    });

    BlocProvider.of<LocationBloc>(
      context,
    ).add(LocationFilterEvent(filterList: filterList));
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      filterList.clear();
    });

    BlocProvider.of<LocationBloc>(
      context,
    ).add(LocationFilterResetEvent(filters: const {}, locations: locations));
    final bloc = BlocProvider.of<LocationBloc>(context);
    bloc.add(LoadLocations());
  }

  void clearSingleFilter(String type) {
    setState(() {
      filterList.remove(type);
      _filters.remove(type);
    });

    BlocProvider.of<LocationBloc>(
      context,
    ).add(LocationFilterResetEvent(filters: filterList, locations: locations));
    final bloc = BlocProvider.of<LocationBloc>(context);
    bloc.add(LoadLocations());
  }

  void onRowSelectionCountChanged(int selectedCount, dynamic exCollection) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => showSelectedCount = selectedCount.toString());
    });
  }

  Widget _buildSelectedFilters() {
    List<Widget> filterWidgets = _filters.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 8.0),
          padding: const EdgeInsets.only(top: 6, bottom: 6, left: 16, right: 8),
          decoration: BoxDecoration(
            color: const Color(0x26007AFF),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${entry.key}: ${entry.value}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12.0,
                  height: 15 / 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF3B475B),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  clearSingleFilter(entry.key);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SvgPicture.asset(
                    'lib/src/features/functional_areas/assets/svg/close.svg',
                    height: 10,
                    width: 10,
                    color: const Color(0xFF6F7886),
                  ),
                ),
                // const Icon(Icons.clear, size: 16, color: Color(0xFF3B475B)),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (_filters.isNotEmpty) {
      filterWidgets.insert(
        filterWidgets.length,
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.red.withOpacity(0.5),
            //     width: 1.0,
            //   ),
            //   borderRadius: BorderRadius.circular(10),
            // ),
            // margin: const EdgeInsets.only(left: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _clearFilters,
              child: Row(
                children: [
                  Text(
                    'Clear All ',
                    style: GoogleFonts.nunitoSans(
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFFFF0000),
                      fontSize: 14.0,
                      height: 19 / 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFFF0000),
                    ),
                  ),
                  // const Icon(Icons.clear, size: 20, color: Colors.red),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: filterWidgets),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final bool isPortrait = orientation == Orientation.portrait;
            final double screenWidth = MediaQuery.of(context).size.width;
            final double screenHeight = MediaQuery.of(context).size.height;

            // final double searchBarWidthPortrait = screenWidth * 0.3;
            final double paddingValuePortrait =
                (screenWidth + screenHeight) * 0.002;
            final double buttonHeightPortrait =
                (screenWidth + screenHeight) * 0.03;

            // final double searchBarWidthLandscape = screenWidth * 0.5;
            final double paddingValueLandscape =
                (screenWidth + screenHeight) * 0.006;
            final double buttonHeightLandscape =
                (screenWidth + screenHeight) * 0.03;

            // final double searchBarWidth = isPortrait
            //     ? searchBarWidthPortrait
            //     : searchBarWidthLandscape;
            final double paddingValue =
                isPortrait ? paddingValuePortrait : paddingValueLandscape;
            final double buttonHeight =
                isPortrait ? buttonHeightPortrait : buttonHeightLandscape;
            final double customHorizantal = screenWidth * 0.025;
            // final double customVertical = screenHeight * 0.04;
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: BlocConsumer<LocationBloc, LocationState>(
                listener: (context, locationState) {
                  if (locationState is ShowLocationMoreOption) {
                    setState(() {
                      selectedLists = locationState.selectedAssets;
                    });
                  }
                },
                builder: (context, locationState) {
                  if (locationState is ShowLocationMoreOption) {
                    selectedLists = locationState.selectedAssets;
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                      left: customHorizantal,
                      right: customHorizantal,
                      top: screenHeight * 0.04,
                      bottom: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: paddingValue * 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: searchFoucs.hasFocus
                                        ? [
                                            const BoxShadow(
                                              color: Color(0xA3002B5C),
                                              blurRadius: 4,
                                              offset: Offset(0, 0),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  width:
                                      //  selectedLists.isEmpty
                                      //     ? searchBarWidth
                                      //     :
                                      screenWidth * 0.48,
                                  height: buttonHeight,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: TextField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      focusNode: searchFoucs,
                                      controller: _searchController,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                        height: 24 / 17,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF979797),
                                          height: 24 / 17,
                                        ),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12.0,
                                            bottom: 12.0,
                                            left: 16,
                                            right: 8.0,
                                          ),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'lib/src/features/landing_page/assets/svg/search_icon.svg',
                                                height: 18,
                                                width: 18,
                                                color: const Color(0xFF3B475B),
                                              ),
                                            ),
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          borderSide: BorderSide(
                                            color: showErrorIDColor
                                                ? const Color(0xFFF44336)
                                                : const Color(0xFFD0D3D8),
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                _searchController.text.isEmpty
                                                    ? const Color(0xFFD0D3D8)
                                                    : const Color(0xFF9C9C9C),
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF002B5C),
                                            width: 1.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFF44336),
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFF44336),
                                            width: 1.0,
                                          ),
                                        ),
                                        errorStyle: GoogleFonts.inter(
                                          color: const Color(0xFFF44336),
                                          fontSize: 12.0,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        suffixIcon: _searchController
                                                .text.isNotEmpty
                                            ? GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  setState(() {
                                                    _searchController.clear();
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 12.0,
                                                    bottom: 12.0,
                                                    left: 8,
                                                    right: 16.0,
                                                  ),
                                                  child: Container(
                                                    height: 24,
                                                    width: 24,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFF3B475B,
                                                        ),
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size:
                                                          17, // Close icon size
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                BlocBuilder<LocationBloc, LocationState>(
                                  buildWhen: (previous, current) =>
                                      current is LocationsLoaded,
                                  builder: (context, state) {
                                    if (state is LocationsLoaded) {
                                      locations = state.locations;
                                      return FilterBox(
                                        onFilterApply: _onFilterApply,
                                        locations: state.locations,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                BlocConsumer<LocationBloc, LocationState>(
                                  listener: (context, state) {
                                    if (state is LocationDownloadSuccess) {
                                      OpenFilex.open(state.location);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(state.message),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                    if (state is LocationDownloadError) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(state.message),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  buildWhen: (previous, current) =>
                                      current is LocationDownloadLoading ||
                                      current is LocationDownloadError ||
                                      current is LocationDownloadSuccess,
                                  builder: (context, state) {
                                    if (state is LocationDownloadLoading) {
                                      return Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: paddingValue,
                                            ),
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 4.0,
                                        ),
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTapDown: (TapDownDetails details) {
                                            showDownloadOptionsMenu(
                                              context,
                                              details.globalPosition,
                                              "location",
                                              locations: locations,
                                              selectedIds: selectedLists,
                                              searchQuery: _searchQuery,
                                              filters: filterList,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right:
                                                  // selectedLists.isEmpty
                                                  //     ? paddingValue
                                                  //     :
                                                  0,
                                            ),
                                            child: SvgPicture.asset(
                                              'lib/src/features/functional_areas/assets/svg/download.svg',
                                              height: 36,
                                              width: 32,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(
                                  width:
                                      //  selectedLists.isEmpty ? 16 :
                                      15,
                                ),
                                addButton(),
                              ],
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   children: [
                            //     BlocConsumer<LocationBloc, LocationState>(
                            //         listener: (context, locationState) {
                            //       // if (locationState is ShowLocationMoreOption) {
                            //       //   selectedLists =
                            //       //       locationState.selectedAssets;
                            //       // }
                            //     }, builder: (context, locationState) {
                            //       if (locationState is ShowLocationMoreOption) {
                            //         // selectedLists =
                            //         //     locationState.selectedAssets;
                            //         return selectedLists.isEmpty
                            //             ? const SizedBox()
                            //             : Padding(
                            //                 padding: const EdgeInsets.only(
                            //                     left: 1.0, right: 8),
                            //                 child: GestureDetector(
                            //                   behavior:
                            //                       HitTestBehavior.translucent,
                            //                   onTapDown:
                            //                       (TapDownDetails details) {
                            //                     _showDeleteConfirmation();
                            //                   },
                            //                   child: Padding(
                            //                     padding: EdgeInsets.only(
                            //                         right: paddingValue),
                            //                     child: SvgPicture.asset(
                            //                       'lib/src/features/functional_areas/assets/svg/delete.svg',
                            //                       height: 28,
                            //                       width: 28,
                            //                       color: Colors.black,
                            //                     ),
                            //                   ),
                            //                 ),
                            //               );
                            //       }
                            //       return const SizedBox();
                            //     }),
                            //   ],
                            // )
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildSelectedFilters(),
                        SizedBox(height: screenHeight * 0.02),
                        Expanded(
                          child: BlocConsumer<LocationBloc, LocationState>(
                            listener:
                                (BuildContext context, LocationState state) {
                              if (state is LocationsLoading) {
                                setState(() {
                                  isLoadMore = state.isLoadMore;
                                });
                              } else if (state is LocationsLoaded) {
                                setState(() {
                                  locations = state.locations;
                                  isLoadMore = state.isLoadMore;
                                });
                              }
                            },
                            buildWhen: (previous, current) =>
                                current is LocationLoading ||
                                current is LocationsLoaded ||
                                current is LocationError,
                            builder: (context, state) {
                              if (state is LocationLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is LocationsLoaded) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFF2F2F7),
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: NotificationListener<
                                            ScrollEndNotification>(
                                          onNotification: (notification) {
                                            if (notification.metrics.axis ==
                                                    Axis.vertical &&
                                                notification.metrics.atEdge &&
                                                notification.metrics.pixels !=
                                                    0 &&
                                                !isLoadMore &&
                                                state.hasMoreData) {
                                              setState(() {
                                                isLoadMore = true;
                                              });

                                              BlocProvider.of<LocationBloc>(
                                                context,
                                              ).add(
                                                LoadMoreLocations(
                                                  tableHeaders:
                                                      state.tableHeaders,
                                                  totalRecords:
                                                      state.totalRecords,
                                                  isLoadMore: true,
                                                  offset: state.offset,
                                                  locations: state.locations,
                                                  filterList: filterList,
                                                  filters: _filters,
                                                ),
                                              );
                                              return true;
                                            }
                                            return false;
                                          },
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return LocationTable(
                                                locations: state.locations,
                                                headers: state.tableHeaders,
                                                searchQuery: _searchQuery,
                                                filters: filterList,
                                                filterIndex: state.filterIndex,
                                                sortOrder: state.sortOrder,
                                                onRowSelectionCountChanged:
                                                    onRowSelectionCountChanged,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxHeight: screenHeight * 0.06,
                                        ),
                                        padding: EdgeInsets.all(paddingValue),
                                        margin: EdgeInsets.only(
                                          top: paddingValue,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFF2F2F7),
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                27,
                                                32,
                                                41,
                                                0.05,
                                              ),
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Showing: $showSelectedCount Area Details',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: const Color(
                                                    0xFF979797,
                                                  ),
                                                  height: 20 / 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            if (isLoadMore)
                                              Container(
                                                // padding: const EdgeInsets.all(7),
                                                child:
                                                    const CircularProgressIndicator(
                                                  color: Colors.blue,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (state is LocationError) {
                                return Center(
                                  child: Text('Error: ${state.error}'),
                                );
                              } else {
                                return const Center(
                                  child: Text('No Data Availablee'),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget addButton() {
    return Padding(
      padding:
          // selectedLists.isEmpty
          //     ? const EdgeInsets.all(2.0)
          //     :
          const EdgeInsets.only(top: 2.0, bottom: 2.0, right: 10.0),
      child: TextButton(
        onPressed: () => {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: {
              'menu': 'Ex Inspections',
              'isCollapsed': true,
              'fromFunctionalArea': true,
            },
          ),
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.blue.shade700;
            }
            return Colors.blue;
          }),
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add   ",
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            const Icon(Icons.add, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // Future<void> _fetchLocationData(List<String> locationIds, String type) async {
  //   for (String locationId in locationIds) {
  //     BlocProvider.of<LocationBloc>(context).add(
  //       LocationMultipleDeletedList(
  //         locationId: locationId,
  //         type: type,
  //         filterList: filterList,
  //         filters: _filters,
  //         locations: locations,
  //         selectedLists: selectedLists,
  //       ),
  //     );
  //   }
  // }

  // void _showDeleteConfirmation() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: ConstrainedBox(
  //           constraints: const BoxConstraints(maxWidth: 400),
  //           child: SingleChildScrollView(
  //             child: Container(
  //               padding: const EdgeInsets.all(24),
  //               decoration: ShapeDecoration(
  //                 color: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   side: const BorderSide(
  //                     width: 1,
  //                     strokeAlign: BorderSide.strokeAlignOutside,
  //                     color: Color(0xFFF1F1F1),
  //                   ),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 shadows: const [
  //                   BoxShadow(
  //                     color: Color(0x14000000),
  //                     blurRadius: 8,
  //                     offset: Offset(2, 4),
  //                     spreadRadius: 2,
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Delete Confirmation',
  //                     style: GoogleFonts.roboto(
  //                       color: const Color(0xFF1C232E),
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.w600,
  //                       height: 1.2,
  //                       letterSpacing: 0.90,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 30),
  //                   Text(
  //                     selectedLists.length == 1
  //                         ? "This will permanently delete the area and it associated asset."
  //                         : "This will permanently delete the area and its associated assets.",
  //                     style: GoogleFonts.roboto(
  //                       color: const Color(0xFF3B475B),
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w400,
  //                       height: 1.5,
  //                       letterSpacing: 0.70,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     'Are you sure you want to proceed?',
  //                     style: GoogleFonts.roboto(
  //                       color: const Color(0xFF3B475B),
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w400,
  //                       height: 1.5,
  //                       letterSpacing: 0.70,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 40),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: GestureDetector(
  //                           behavior: HitTestBehavior.translucent,
  //                           onTap: () {
  //                             Navigator.of(context).pop();
  //                           },
  //                           child: Container(
  //                             height: 48,
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 16,
  //                               vertical: 12,
  //                             ),
  //                             decoration: ShapeDecoration(
  //                               shape: RoundedRectangleBorder(
  //                                 side: const BorderSide(
  //                                   width: 1,
  //                                   color: Color(0xFF8C8C8C),
  //                                 ),
  //                                 borderRadius: BorderRadius.circular(8),
  //                               ),
  //                               shadows: const [
  //                                 BoxShadow(
  //                                   color: Color(0x0C1B2029),
  //                                   blurRadius: 2,
  //                                   offset: Offset(0, 1),
  //                                   spreadRadius: 0,
  //                                 ),
  //                               ],
  //                             ),
  //                             child: Center(
  //                               child: Text(
  //                                 'Cancel',
  //                                 style: GoogleFonts.roboto(
  //                                   color: const Color(0xFF1C232E),
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w600,
  //                                   height: 1.2,
  //                                   letterSpacing: 0.80,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 24),
  //                       Expanded(
  //                         child: GestureDetector(
  //                           behavior: HitTestBehavior.translucent,
  //                           onTap: () {
  //                             Navigator.of(context).pop(true);
  //                             _fetchLocationData(selectedLists, 'delete');
  //                           },
  //                           child: Container(
  //                             height: 48,
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 16,
  //                               vertical: 12,
  //                             ),
  //                             decoration: ShapeDecoration(
  //                               color: const Color(0xFF1E90FF),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(8),
  //                               ),
  //                               shadows: const [
  //                                 BoxShadow(
  //                                   color: Color(0x0C1B2029),
  //                                   blurRadius: 2,
  //                                   offset: Offset(0, 1),
  //                                   spreadRadius: 0,
  //                                 ),
  //                               ],
  //                             ),
  //                             child: Center(
  //                               child: Text(
  //                                 'Delete',
  //                                 style: GoogleFonts.roboto(
  //                                   color: const Color(0xFFFAFBFF),
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w600,
  //                                   height: 1.2,
  //                                   letterSpacing: 0.80,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
