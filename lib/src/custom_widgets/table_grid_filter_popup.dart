import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/device_sync/bloc/device_sync_bloc.dart';
import '../features/device_sync/bloc/device_sync_event.dart';
import '../features/device_sync/bloc/to_server_bloc.dart';
import '../features/ex_register/bloc/ex_register_bloc.dart';
import '../features/ex_register/bloc/ex_register_event.dart';

class FilterPopup extends StatefulWidget {
  final String filterField;
  final Offset position;
  final Function(String sortField, List<String> selectedFilters,
      Map<String, List<String>> collectionSelectedData)? onFilterApplied;
  final Function(
    DateTime? fromDate,
    DateTime? toDate,
    bool isReset,
    String datetype,
    String showFilterType,
    Map<String, List<String>> collectionSelectedData,
    String sortField,
    List<String> selectedFilters,
  )? onFilterRemove;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String datetype;
  final String showFilterType;
  final List<String> alreadyselectedFilters;
  final Map<String, List<String>> alreadycollectionSelectedFilter;
  final String tableType;
  final List<ExRegister> assets;
  final List<ExRegister> registerCollections;
  const FilterPopup(
      {super.key,
      required this.filterField,
      required this.position,
      this.onFilterApplied,
      this.onFilterRemove,
      this.fromDate,
      this.toDate,
      required this.datetype,
      required this.showFilterType,
      required this.alreadyselectedFilters,
      required this.alreadycollectionSelectedFilter,
      required this.tableType,
      required this.assets,
      required this.registerCollections});

  @override
  FilterPopupState createState() => FilterPopupState();
}

class FilterPopupState extends State<FilterPopup> {
  List<String> _selectedFilters = [];
  Map<String, List<String>> data = {};
  void _toggleFilter(String filterOption) {
    setState(() {
      if (_selectedFilters.contains(filterOption)) {
        _selectedFilters.remove(filterOption);
      } else {
        _selectedFilters.add(filterOption);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final List<String>? selectedFilters =
        widget.alreadycollectionSelectedFilter[widget.filterField];
    _selectedFilters = selectedFilters == null
        ? List.from(_selectedFilters)
        : List.from(selectedFilters);
  }

  void _resetFilters() {
    setState(() {
      // _selectedFilters.clear();
      widget.alreadycollectionSelectedFilter.remove(widget.filterField);
      widget.onFilterRemove?.call(
          widget.fromDate,
          widget.toDate,
          true,
          widget.datetype,
          widget.showFilterType,
          widget.alreadycollectionSelectedFilter,
          widget.filterField,
          _selectedFilters);
    });

    Navigator.pop(context);
    // BlocProvider.of<ExRegisterBloc>(context).add(ExRegisterInitEvent());
    // BlocProvider.of<ExRegisterBloc>(context).add(LoadExRegister());
    if (widget.tableType == "Ex Register") {
      BlocProvider.of<ExRegisterBloc>(context).add(ResetFilterExRegister(
        fromDate: widget.fromDate,
        toDate: widget.toDate,
        isReset: true,
        type: widget.datetype,
        showAllFilterType: widget.showFilterType,
        collectionSelectedFilterData: widget.alreadycollectionSelectedFilter,
      ));
    } else if (widget.tableType == 'Server To Device') {
      BlocProvider.of<DeviceSyncBloc>(context).add(ResetLoadMoreWorkOrder(
          collectionSelectedFilter: widget.alreadycollectionSelectedFilter,
          assets: widget.assets,
          registerCollections: widget.registerCollections));
    } else if (widget.tableType == 'Device To Server') {
      BlocProvider.of<ToServerBloc>(context).add(ResetWorkOrderToServer(
        collectionSelectedFilter: widget.alreadycollectionSelectedFilter,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const double dialogWidth = 260;
    const double dialogHeight = 310;

    return Positioned(
      top: widget.position.dy - 0.1,
      left: widget.position.dx - (dialogWidth / 1.25),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Dialog(
            // insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFD0D3D8)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckboxOption("Red"),
                  _buildCheckboxOption("Yellow"),
                  _buildCheckboxOption("Green"),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: _resetFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFD0D3D8),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'lib/src/features/ex_register/assets/refresh.svg',
                                  width: 18,
                                  height: 18,
                                  color: const Color(0xFF3B475B),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            // icon: const Icon(Icons.search,color: Colors.white70),
                            label: Text('Go',
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 20 / 15)),
                            onPressed: () {
                              // Make a mutable copy of the alreadycollectionSelectedFilter map
                              data = Map<String, List<String>>.fromEntries(
                                widget.alreadycollectionSelectedFilter.entries
                                    .map(
                                  (e) => MapEntry(
                                      e.key, List<String>.from(e.value)),
                                ),
                              );
                              data[widget.filterField] =
                                  List.from(_selectedFilters);
                              if (data[widget.filterField]!.isEmpty) {
                                data.remove(widget.filterField);
                              } else {
                                widget.alreadycollectionSelectedFilter
                                    .forEach((key, value) {
                                  if (key == widget.filterField) return;
                                  if (data.containsKey(key)) {
                                    data[key]!.addAll(value);
                                  } else {
                                    data[key] = List.from(value);
                                  }
                                  data[key] = data[key]!.toSet().toList();
                                });
                              }
                              widget.onFilterApplied?.call(
                                  widget.filterField, _selectedFilters, data);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8), // Border radius
                              ),
                            ),
                          ),
                        ),
                        // ElevatedButton.icon(
                        //   icon: const Icon(Icons.replay_sharp,
                        //       color: Colors.black54),
                        //   label: const Text('',
                        //       style: TextStyle(color: Colors.black)),
                        //   onPressed: _resetFilters,
                        //   style: ElevatedButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 10, vertical: 8),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius:
                        //           BorderRadius.circular(10), // Border radius
                        //     ),
                        //   ),
                        // ),
                        // ElevatedButton.icon(
                        //   // icon: const Icon(Icons.search,color: Colors.white70),
                        //   label: const Text('Go ',
                        //       style: TextStyle(color: Colors.white)),
                        //   onPressed: () {
                        //     widget.onFilterApplied
                        //         ?.call(widget.filterField, _selectedFilters);
                        //     Navigator.of(context).pop();
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.blue,
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 10, vertical: 8),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius:
                        //           BorderRadius.circular(10), // Border radius
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String filterText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _toggleFilter(filterText),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: _selectedFilters.contains(filterText)
                ? const Color(0xFFEDF3F8)
                : Colors.white70,
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _selectedFilters.contains(filterText)
                      ? const Color(0xFFEDF3F8)
                      : Colors.transparent,
                  border: Border.all(
                    color: _selectedFilters.contains(filterText)
                        ? const Color(0xFF3B475B)
                        : const Color(0xFF9C9C9C),
                    width: 1.25,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: 19,
                height: 19,
                child: Center(
                  child: _selectedFilters.contains(filterText)
                      ? SvgPicture.asset(
                          "lib/src/features/ex_register/assets/checkbox.svg",
                          color: _selectedFilters.contains(filterText)
                              ? const Color(0xFF002B5C)
                              : Colors.black54,
                          // size: 16,
                        )
                      : const SizedBox(),
                ),
              ),

              const SizedBox(
                width: 16,
              ),
              // Checkbox(
              //     shape: const RoundedRectangleBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(5.0))),
              //     side: WidgetStateBorderSide.resolveWith(
              //       (states) =>
              //           const BorderSide(width: 1.0, color: Colors.black54),
              //     ),
              //     value: _selectedFilters.contains(filterText),
              //     onChanged: (bool? value) {
              //       _toggleFilter(filterText);
              //     },
              //     checkColor: const Color(0xFF002B5C),
              //     activeColor: Colors.white70),
              Text(
                filterText,
                style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF3B475B),
                    height: 24 / 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
