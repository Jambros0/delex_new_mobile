// ignore_for_file: deprecated_member_use

import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/columStyle.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/round_checkbox.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/table_grid_filter_popup.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/table_grid_popup.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../features/ex_register/bloc/ex_register_bloc.dart';
import '../features/ex_register/bloc/ex_register_event.dart';

class CustomTableGrid extends StatefulWidget {
  final int? filterIndex;
  final dynamic sortOrder;
  final List<String> headers;
  final Map<String, dynamic>? actions;
  final List<List<String>> rows;
  final List<String> columnKeys;
  final Function(int)? onRowSelected;
  final List<bool>? initialSelection;
  final Function(
    String fieldName,
    String sortOrder,
    int sortFieldIndex,
    List<String> selectedFilters,
    Map<String, List<String>> collectionSelectedData,
  )?
  onSortChanged;
  final Function(
    DateTime? fromDate,
    DateTime? toDate,
    bool isReset,
    String datetype,
    String showFilterType,
    Map<String, List<String>> collectionSelectedData,
    String sortField,
    List<String> selectedFilters,
  )?
  onFilterRemove;
  final String tableType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String datetype;
  final String showFilterType;
  final String searchQuery;
  final List<String> selectedFilters;
  final Map<String, List<String>> alreadycollectionSelectedFilter;
  final List<ExRegister> assets;
  final List<ExRegister> registerCollections;
  final List<Location> locations;
  const CustomTableGrid({
    super.key,
    required this.headers,
    this.actions,
    this.filterIndex,
    required this.sortOrder,
    required this.rows,
    required this.columnKeys,
    this.onRowSelected,
    this.initialSelection,
    this.onSortChanged,
    this.onFilterRemove,
    required this.tableType,
    this.fromDate,
    this.toDate,
    required this.datetype,
    required this.showFilterType,
    required this.searchQuery,
    required this.selectedFilters,
    required this.alreadycollectionSelectedFilter,
    this.assets = const [],
    this.registerCollections = const [],
    this.locations = const [],
  });

  @override
  CustomTableGridState createState() => CustomTableGridState();
}

class CustomTableGridState extends State<CustomTableGrid>
    with SingleTickerProviderStateMixin {
  // late LinkedScrollControllerGroup _controllers;
  late ScrollController _headerController;
  late ScrollController _bodyController;
  late List<bool> _selectionStates;
  List<String> selectedAssetIds = [];
  bool _isAllSelected = false;
  bool showMoreIcon = false;

  late AnimationController _controller;
  late Animation<Offset> _animation;
  List<GlobalKey> iconKeys = [];

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start completely offscreen on the right
      end: const Offset(0.0, 0.0), // End at the middle (right side)
    ).animate(_controller);
    iconKeys = List.generate(widget.columnKeys.length, (_) => GlobalKey());
    super.initState();
    // _controllers = LinkedScrollControllerGroup();
    // _headerController = _controllers.addAndGet();
    // _bodyController = _controllers.addAndGet();
    _headerController = ScrollController();
    _bodyController = ScrollController();

    _updateSelectionStates();
  }

  @override
  void didUpdateWidget(CustomTableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.rows.length != _selectionStates.length) {
      _updateSelectionStates();
    }
  }

  void _updateSelectionStates() {
    setState(() {
      _selectionStates = List.generate(
        widget.rows.length,
        (index) =>
            widget.initialSelection != null &&
                widget.initialSelection!.length > index
            ? widget.initialSelection![index]
            : false,
      );
      _isAllSelected = _selectionStates.every((isSelected) => isSelected);
      showMoreIcon = _selectionStates.every((isSelected) => isSelected);
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final double columnWidth =
        widget.tableType == "Ex Register" ||
            widget.tableType == 'Server To Device' ||
            widget.tableType == 'Device To Server'
        ? (isPortrait ? screenWidth * 0.18 : screenWidth * 0.145)
        : (isPortrait ? screenWidth * 0.18 : screenWidth * 0.135);
    final double checkboxWidth = isPortrait
        ? screenWidth * 0.08
        : screenWidth * 0.053;
    final double leftPadding = isPortrait ? 30 : 30;

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _headerController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                color: Color(0xFF002B5C),
              ),
              height: 48,
              child: _buildHeader(
                columnWidth,
                checkboxWidth,
                leftPadding,
                widget.tableType,
              ),
            ),
            SizedBox(
              height: isPortrait
                  ? screenHeight * 0.55
                  : widget.tableType == 'Area Detail'
                  ? screenHeight * 0.525
                  : widget.tableType == 'Ex Register'
                  ? screenHeight * 0.545
                  : screenHeight * 0.52,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _bodyController,
                    child: Column(
                      children: widget.rows.asMap().entries.map((entry) {
                        int index = entry.key;
                        List<String> row = entry.value;

                        return Container(
                          height: 56,
                          color: index % 2 == 0
                              ? Colors.white
                              : const Color(0xFFEDF3F8),
                          child: _buildRowCells(
                            index,
                            row,
                            columnWidth,
                            checkboxWidth,
                            leftPadding,
                            widget.tableType,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    double columnWidth,
    double checkboxWidth,
    double leftPadding,
    String tableType,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left:
            tableType == "Ex Register" ||
                tableType == 'Device To Server' ||
                tableType == 'Server To Device'
            ? widget.headers.first == "RFID Reference"
                  ? 10
                  : 0
            : tableType == 'Area Detail'
            ? widget.headers.first == "Field Name"
                  ? 10
                  : 0
            : 0,
      ),
      child: Row(
        children: [
          CustomRoundCheckbox(
            value: _isAllSelected,
            onChanged: (bool? value) {
              _allAssetSelected(value, widget.tableType);
            },
            isHeader: true,
            checkboxWidth: checkboxWidth,
            leftPadding: leftPadding,
          ),
          const SizedBox(width: 16),
          ...widget.headers.asMap().entries.map((entry) {
            int columnIndex = entry.key;
            String header = entry.value;
            bool isFiltered = columnIndex == widget.filterIndex;
            bool isFilterColumn =
                header == "Inspection Status" || header == "Current Status";
            return Container(
              padding: EdgeInsets.only(
                right:
                    tableType == "Ex Register" ||
                        tableType == 'Device To Server' ||
                        tableType == 'Server To Device'
                    ? ColumnStyleHelper.getExRegisterHeaderRightPadding(header)
                    : ColumnStyleHelper.getFunctionalHeaderRightPadding(header),
              ),
              width:
                  tableType == "Ex Register" ||
                      tableType == 'Device To Server' ||
                      tableType == 'Server To Device'
                  ? ColumnStyleHelper.getExRegisterHeaderCustomWidth(
                      header,
                      columnWidth,
                    )
                  : ColumnStyleHelper.getFunctionalHeaderCustomWidth(
                      header,
                      columnWidth,
                    ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (TapDownDetails details) {
                  final RenderBox? box =
                      iconKeys[entry.key].currentContext?.findRenderObject()
                          as RenderBox?;
                  if (box != null) {
                    final Offset iconPosition = box.localToGlobal(Offset.zero);
                    final Size iconSize = box.size;
                    final Offset popupPosition =
                        iconPosition + Offset(iconSize.width - 10.0, 0);
                    if (isFilterColumn) {
                      _showFilterPopup(
                        context,
                        columnIndex,
                        popupPosition,
                        widget.selectedFilters,
                        widget.alreadycollectionSelectedFilter,
                        widget.tableType,
                      );
                    } else {
                      _showSortPopup(context, columnIndex, popupPosition);
                    }
                  }
                },
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        header,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 14 / 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      key: iconKeys[entry.key], // Moved key to outer container
                      child: isFilterColumn
                          ? SvgPicture.asset(
                              widget.alreadycollectionSelectedFilter.isEmpty
                                  ? "lib/src/features/ex_register/assets/Before_Filter.svg"
                                  : widget.alreadycollectionSelectedFilter
                                            .containsKey('inspectionStatus') &&
                                        header == "Inspection Status"
                                  ? "lib/src/features/ex_register/assets/After_Filter.svg"
                                  : widget.alreadycollectionSelectedFilter
                                            .containsKey('currentStatus') &&
                                        header == "Current Status"
                                  ? "lib/src/features/ex_register/assets/After_Filter.svg"
                                  : widget.alreadycollectionSelectedFilter
                                            .containsKey('currentStatus') &&
                                        widget.alreadycollectionSelectedFilter
                                            .containsKey('inspectionStatus')
                                  ? "lib/src/features/ex_register/assets/After_Filter.svg"
                                  : "lib/src/features/ex_register/assets/Before_Filter.svg",
                              width: 15,
                              height: 15,
                              color:
                                  widget.alreadycollectionSelectedFilter.isEmpty
                                  ? Colors.white
                                  : widget.alreadycollectionSelectedFilter
                                            .containsKey('inspectionStatus') &&
                                        header == "Inspection Status"
                                  ? null
                                  : widget.alreadycollectionSelectedFilter
                                            .containsKey('currentStatus') &&
                                        header == "Current Status"
                                  ? null
                                  : widget.alreadycollectionSelectedFilter
                                            .containsKey('currentStatus') &&
                                        widget.alreadycollectionSelectedFilter
                                            .containsKey('inspectionStatus')
                                  ? null
                                  : Colors.white,
                            )
                          : isFiltered
                          ? widget.sortOrder == "ascending"
                                ? SvgPicture.asset(
                                    "lib/src/features/functional_areas/assets/svg/asc_desc.svg",
                                    width: 14,
                                    height: 14,
                                  )
                                : widget.sortOrder == "descending"
                                ? Transform.rotate(
                                    angle: 3.14,
                                    child: SvgPicture.asset(
                                      "lib/src/features/functional_areas/assets/svg/asc_desc.svg",
                                      width: 14,
                                      height: 14,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    "lib/src/features/functional_areas/assets/svg/remove.svg",
                                    width: 14,
                                    height: 14,
                                    color: Colors.white,
                                  )
                          : SvgPicture.asset(
                              "lib/src/features/functional_areas/assets/svg/remove.svg",
                              width: 14,
                              height: 14,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRowCells(
    int rowIndex,
    List<String> row,
    double columnWidth,
    double checkboxWidth,
    double leftPadding,
    String tableType,
  ) {
    if (widget.tableType == 'Ex Register') {
      return Padding(
        padding: EdgeInsets.only(
          left:
              (tableType == "Ex Register" ||
                      tableType == 'Device To Server' ||
                      tableType == 'Server To Device') &&
                  widget.headers.first == "RFID Reference"
              ? 0
              : 0,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CustomRoundCheckbox(
                value: _selectionStates[rowIndex],
                onChanged: (bool? value) {
                  _assetChecked(rowIndex, value, row[0], widget.tableType);
                },
                isHeader: false,
                checkboxWidth: checkboxWidth,
                leftPadding: leftPadding,
              ),
            ),
            if (widget.headers.first == "RFID Reference")
              Container(
                padding: const EdgeInsets.only(left: 17),
                width: ColumnStyleHelper.getExRegisterCellCustomWidth(
                  1,
                  columnWidth,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _navigateToInspectionScreen(row[0]);
                  },
                  child: Text(
                    row[1],
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF3B475B),
                      height: 20 / 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ...row.asMap().entries.skip(2).map((entry) {
              int columnIndex = entry.key - 1;
              String cell = entry.value;
              bool isSpecialColumn =
                  widget.headers[columnIndex] == "Inspection Status" ||
                  widget.headers[columnIndex] == "Current Status";
              bool isHasViewMore =
                  widget.headers[columnIndex] == "Inspection Faults" ||
                  widget.headers[columnIndex] == "Completed Repairs" ||
                  widget.headers[columnIndex] == "Existing Faults";
              Widget cellContent;
              final String assetPath = _getFlagAssetPath(cell);
              if (isSpecialColumn) {
                cellContent = GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _navigateToInspectionScreen(row[0]);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      right: ColumnStyleHelper.getExRegisterCellRightPadding(
                        entry.key,
                      ),
                    ),
                    width: ColumnStyleHelper.getExRegisterCellCustomWidth(
                      entry.key,
                      columnWidth,
                    ),
                    child: Row(
                      children: [
                        assetPath.isNotEmpty
                            ? SvgPicture.asset(assetPath, width: 20, height: 20)
                            : const SizedBox(width: 20, height: 20),
                        const SizedBox(width: 16),
                        Text(
                          cell,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF3B475B),
                            height: 20 / 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              } else if (isHasViewMore) {
                cellContent = Container(
                  padding: EdgeInsets.only(
                    right: cell == "0"
                        ? 90
                        : ColumnStyleHelper.getExRegisterCellRightPadding(
                            entry.key,
                          ),
                  ),
                  width: ColumnStyleHelper.getExRegisterCellCustomWidth(
                    entry.key,
                    columnWidth,
                  ),
                  child: Row(
                    mainAxisAlignment: cell == "0"
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _navigateToInspectionScreen(row[0]);
                        },
                        child: Text(
                          cell,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF3B475B),
                            height: 20 / 14,
                          ),
                        ),
                      ),
                      if (cell != "0" && cell.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _showRightModal(
                              widget.headers[columnIndex],
                              widget.actions,
                              row[1],
                              row,
                            );
                          },
                          child: Row(
                            children: [
                              const SizedBox(width: 3),
                              SvgPicture.asset(
                                'lib/src/features/ex_register/assets/external_link.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              } else {
                cellContent = GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _navigateToInspectionScreen(row[0]);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      right: ColumnStyleHelper.getExRegisterCellRightPadding(
                        entry.key,
                      ),
                    ),
                    width: ColumnStyleHelper.getExRegisterCellCustomWidth(
                      entry.key,
                      columnWidth,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(
                            cell,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF3B475B),
                              height: 20 / 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return cellContent;
            }),
          ],
        ),
      );
    } else if (widget.tableType == 'Server To Device' ||
        widget.tableType == 'Device To Server') {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: CustomRoundCheckbox(
              value: _selectionStates[rowIndex],
              onChanged: (bool? value) {
                setState(() {
                  if (rowIndex < _selectionStates.length) {
                    _selectionStates[rowIndex] = value ?? false;
                  }
                  _isAllSelected = _selectionStates.every(
                    (isSelected) => isSelected,
                  );
                  showMoreIcon = _selectionStates.every(
                    (isSelected) => isSelected,
                  );
                });
                if (widget.onRowSelected != null) {
                  widget.onRowSelected!(rowIndex);
                }
              },
              isHeader: false,
              checkboxWidth: checkboxWidth,
              leftPadding: 0,
            ),
          ),
          ...row.asMap().entries.skip(1).map((entry) {
            int columnIndex = entry.key - 1;
            String cell = entry.value;
            bool isSpecialColumn =
                widget.headers[columnIndex] == "Inspection Status" ||
                widget.headers[columnIndex] == "Current Status";
            bool isHasViewMore =
                widget.headers[columnIndex] == "Inspection Faults" ||
                widget.headers[columnIndex] == "Completed Repairs" ||
                widget.headers[columnIndex] == "Existing Faults";
            Widget cellContent;
            double leftPadding =
                (widget.headers[columnIndex] == "RFID Reference") ? 17 : 0;
            final String assetPath = _getFlagAssetPath(cell);
            if (isSpecialColumn) {
              cellContent = Container(
                padding: EdgeInsets.only(
                  left: leftPadding,
                  right: ColumnStyleHelper.getExRegisterCellRightPadding(
                    entry.key,
                  ),
                ),
                width: ColumnStyleHelper.getExRegisterCellCustomWidth(
                  entry.key,
                  columnWidth,
                ),
                child: Row(
                  children: [
                    assetPath.isNotEmpty
                        ? SvgPicture.asset(assetPath, width: 20, height: 20)
                        : const SizedBox(width: 20, height: 20),
                    const SizedBox(width: 16),
                    Text(
                      cell,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF3B475B),
                        height: 20 / 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            } else if (isHasViewMore) {
              cellContent = Container(
                padding: EdgeInsets.only(
                  right: cell == "0"
                      ? 90
                      : ColumnStyleHelper.getExRegisterCellRightPadding(
                          entry.key,
                        ),
                ),
                width: ColumnStyleHelper.getExRegisterCellCustomWidth(
                  entry.key,
                  columnWidth,
                ),
                child: Row(
                  mainAxisAlignment: cell == "0"
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _navigateToInspectionScreen(row[0]);
                      },
                      child: Text(
                        cell,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF3B475B),
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    if (cell != "0" && cell.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          // _showRightModal(widget.headers[columnIndex],
                          //     widget.actions, row[1], row);
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 3),
                            SvgPicture.asset(
                              'lib/src/features/ex_register/assets/external_link.svg',
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            } else {
              cellContent = Container(
                padding: EdgeInsets.only(
                  left: leftPadding,
                  right: ColumnStyleHelper.getExRegisterCellRightPadding(
                    entry.key,
                  ),
                ),
                width: ColumnStyleHelper.getExRegisterCellCustomWidth(
                  entry.key,
                  columnWidth,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        cell,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF3B475B),
                          height: 20 / 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              );
            }
            return cellContent;
          }),
        ],
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(
          left: tableType == 'Area Detail'
              ? widget.headers.first == "Field Name"
                    ? 10
                    : 0
              : 0,
        ),
        child: Row(
          children: [
            CustomRoundCheckbox(
              value: _selectionStates[rowIndex],
              onChanged: (bool? value) {
                setState(() {
                  if (rowIndex < _selectionStates.length) {
                    _selectionStates[rowIndex] = value ?? false;
                  }
                  _isAllSelected = _selectionStates.every(
                    (isSelected) => isSelected,
                  );
                  showMoreIcon = _selectionStates.every(
                    (isSelected) => isSelected,
                  );
                  final String currentLocId =
                      (widget.locations.length > rowIndex &&
                              widget.locations[rowIndex].id != null)
                          ? widget.locations[rowIndex].id!
                          : (row.length > 7 ? row[7] : row[0]);
                  if (!selectedAssetIds.contains(currentLocId) && value!) {
                    selectedAssetIds.add(currentLocId);
                  } else {
                    selectedAssetIds.remove(currentLocId);
                  }
                });
                if (widget.onRowSelected != null) {
                  widget.onRowSelected!(rowIndex);
                }
                if (widget.tableType == 'Area Detail') {
                  BlocProvider.of<LocationBloc>(context).add(
                    LocationRowSelected(
                      showIcon: showMoreIcon,
                      selectedAssets: selectedAssetIds,
                    ),
                  );
                }
              },
              isHeader: false,
              checkboxWidth: checkboxWidth,
              leftPadding: leftPadding,
            ),
            const SizedBox(width: 16),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                final String targetId =
                    (widget.locations.length > rowIndex &&
                            widget.locations[rowIndex].id != null)
                        ? widget.locations[rowIndex].id!
                        : (row.length > 7 ? row[7] : row[0]);
                _navigateToInspectionScreen(targetId);
              },
              child: Container(
                padding: EdgeInsets.only(
                  right: ColumnStyleHelper.getFunctionalCellRightPadding(0),
                ),
                width: ColumnStyleHelper.getFunctionalCellCustomWidth(
                  0,
                  columnWidth,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        row[0],
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF3B475B),
                          height: 20 / 14,
                        ),
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...row.asMap().entries.skip(1).map(
              (entry) {
                String cell = entry.value;
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    final String targetId =
                        (widget.locations.length > rowIndex &&
                                widget.locations[rowIndex].id != null)
                            ? widget.locations[rowIndex].id!
                            : (row.length > 7 ? row[7] : row[0]);
                    _navigateToInspectionScreen(targetId);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      right: ColumnStyleHelper.getFunctionalCellRightPadding(
                        entry.key,
                      ),
                    ),
                    width: ColumnStyleHelper.getFunctionalCellCustomWidth(
                      entry.key,
                      columnWidth,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            cell,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF3B475B),
                              height: 20 / 14,
                            ),
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  }

  void _allAssetSelected(bool? value, String tableType) {
    setState(() {
      _isAllSelected = value ?? false;
      showMoreIcon = _isAllSelected;
      _selectionStates = List<bool>.filled(widget.rows.length, _isAllSelected);
      selectedAssetIds = _isAllSelected
          ? widget.rows.asMap().entries.map((entry) {
              int idx = entry.key;
              if (tableType == 'Area Detail') {
                return (widget.locations.length > idx &&
                        widget.locations[idx].id != null)
                    ? widget.locations[idx].id!
                    : (entry.value.length > 7 ? entry.value[7] : entry.value[0]);
              } else {
                return entry.value[0];
              }
            }).toList()
          : [];
      if (widget.onRowSelected != null) {
        for (int i = 0; i < _selectionStates.length; i++) {
          widget.onRowSelected!(i);
        }
      }
    });

    if (tableType == 'Area Detail') {
      BlocProvider.of<LocationBloc>(context).add(
        LocationRowSelected(
          showIcon: showMoreIcon,
          selectedAssets: selectedAssetIds,
        ),
      );
    } else {
      BlocProvider.of<ExRegisterBloc>(context).add(
        ExRegisterRowSelected(
          showIcon: showMoreIcon,
          selectedAssets: selectedAssetIds,
        ),
      );
    }
  }

  void _assetChecked(rowIndex, bool? value, String assetId, String tableType) {
    setState(() {
      if (rowIndex < _selectionStates.length) {
        _selectionStates[rowIndex] = value ?? false;
      }
      _isAllSelected = _selectionStates.every((isSelected) => isSelected);
      showMoreIcon = _selectionStates.contains(true);
      if (!selectedAssetIds.contains(assetId) && value!) {
        selectedAssetIds.add(assetId);
      } else {
        selectedAssetIds.remove(assetId);
      }
    });
    if (widget.onRowSelected != null) {
      widget.onRowSelected!(rowIndex);
    }
    BlocProvider.of<ExRegisterBloc>(context).add(
      ExRegisterRowSelected(
        showIcon: showMoreIcon,
        selectedAssets: selectedAssetIds,
      ),
    );
  }

  void _navigateToInspectionScreen(String id) {
    if (widget.tableType == "Ex Register") {
      Navigator.pushNamed(
        context,
        '/home',
        arguments: {
          'menu': 'Ex Inspections',
          'isCollapsed': true,
          'assetId': id,
          'step': 0,
          'fromExRegister': false,
        },
      );
    } else {
      Navigator.pushNamed(
        context,
        '/home',
        arguments: {
          'menu': 'Ex Inspections',
          'isCollapsed': true,
          'locationId': id,
          'step': 0,
        },
      );
    }
  }

  String _getFlagAssetPath(String color) {
    switch (color) {
      case "Red":
        return 'lib/src/features/ex_register/assets/red_flag.svg';
      case "Green":
        return 'lib/src/features/ex_register/assets/green_flag.svg';
      case "Yellow":
        return 'lib/src/features/ex_register/assets/yellow_flag.svg';
      default:
        return '';
    }
  }

  void _showSortPopup(BuildContext context, int columnIndex, Offset position) {
    final sortField = widget.columnKeys[columnIndex];
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x14000000),
      barrierLabel: 'Sort',
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            SortPopup(
              sortField: sortField,
              position: position,
              onSortApplied: (sortField, sortOrder) {
                widget.onSortChanged?.call(
                  sortField,
                  sortOrder,
                  columnIndex,
                  [],
                  {},
                );
              },
              assets: widget.assets,
              registerCollections: widget.registerCollections,
            ),
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

  void _showFilterPopup(
    BuildContext context,
    int columnIndex,
    Offset position,
    List<String> selectedFilters,
    Map<String, List<String>> alreadycollectionSelectedFilter,
    String tableType,
  ) {
    final filterField = widget.columnKeys[columnIndex];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x14000000),
      barrierLabel: 'Filter',
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            FilterPopup(
              filterField: filterField,
              position: position,
              onFilterApplied:
                  (sortField, selectedFilters, collectionSelectedData) {
                    widget.onSortChanged?.call(
                      sortField,
                      selectedFilters.join(','),
                      columnIndex,
                      selectedFilters,
                      collectionSelectedData,
                    );
                  },
              onFilterRemove:
                  (
                    ffromDate,
                    ftoDate,
                    fisReset,
                    fdatetype,
                    fshowFilterType,
                    fcollectionSelectedData,
                    fsortField,
                    fselectedFilters,
                  ) {
                    widget.onFilterRemove?.call(
                      ffromDate,
                      ftoDate,
                      fisReset,
                      fdatetype,
                      fshowFilterType,
                      fcollectionSelectedData,
                      fsortField,
                      fselectedFilters,
                    );
                  },
              fromDate: widget.fromDate,
              toDate: widget.toDate,
              datetype: widget.datetype,
              showFilterType: widget.showFilterType,
              alreadyselectedFilters: selectedFilters,
              alreadycollectionSelectedFilter: alreadycollectionSelectedFilter,
              tableType: tableType,
              assets: widget.assets,
              registerCollections: widget.registerCollections,
            ),
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

  // void _toggleSelectAll(bool isSelected) {
  //   setState(() {
  //     _selectionStates =
  //         List<bool>.generate(widget.rows.length, (_) => isSelected);
  //     _isAllSelected = isSelected;
  //     showMoreIcon = isSelected;
  //   });
  // }

  void _showRightModal(
    String header,
    Map<String, dynamic>? actions,
    String rfidRef,
    List<String> row,
  ) {
    Map<String, dynamic> val = {};

    if (actions!.containsKey(row[0])) {
      val = actions[row[0]];
    }
    // if (actions!.containsKey(rfidRef)) {
    //   val = actions[rfidRef];
    // }
    val[header] != null
        ? showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: const Color(0x14000000),
            builder: (BuildContext context) {
              return SlideTransition(
                position: _animation,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          offset: const Offset(-4, 0),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.9,
                    margin: const EdgeInsets.only(top: 70),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  header,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF152026),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: SvgPicture.asset(
                                    'lib/src/features/device_sync/assets/Close.svg',
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        top: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        right: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        left: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(7),
                                        topLeft: Radius.circular(7),
                                      ),
                                      color: const Color(0xFF2A6FB2),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Text(
                                              textAlign: TextAlign.left,
                                              header == "Completed Repairs"
                                                  ? 'Repairs Done'
                                                  : 'Defect Code',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Text(
                                              header == "Completed Repairs"
                                                  ? 'Remedial Actions'
                                                  : 'Findings',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  for (int i = 0; i < val[header].length; i++)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                          right: BorderSide(
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                          left: BorderSide(
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: header == "Completed Repairs"
                                                ? Center(
                                                    child: SvgPicture.asset(
                                                      'lib/src/features/ex_inspections/assets/check_icon.svg',
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 15,
                                                          right: 15,
                                                        ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        color: const Color(
                                                          0xFFEDF3F8,
                                                        ),
                                                      ),
                                                      height: 25,
                                                      width: 40,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              2.0,
                                                            ),
                                                        child: Center(
                                                          child: Text(
                                                            val[header][i]
                                                                .defectCode
                                                                .toString(),
                                                            style: GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  const Color(
                                                                    0xFF353535,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 16,
                                              ),
                                              child: Text(
                                                header == "Completed Repairs"
                                                    ? val[header][i]
                                                          .remedialAction
                                                          .toString()
                                                    : val[header][i].finding
                                                          .toString(),
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.withOpacity(0.1),
                                        ),
                                        right: BorderSide(
                                          color: Colors.grey.withOpacity(0.1),
                                        ),
                                        left: BorderSide(
                                          color: Colors.grey.withOpacity(0.1),
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                      color: header == "Completed Repairs"
                                          ? const Color(0xFFEDF7EE)
                                          : header == "Inspection Faults"
                                          ? const Color.fromARGB(
                                              27,
                                              255,
                                              102,
                                              0,
                                            )
                                          : const Color.fromARGB(
                                              144,
                                              255,
                                              219,
                                              111,
                                            ),
                                    ),
                                    width: double.infinity,
                                    // color: Colors.green.shade50,
                                    padding: const EdgeInsets.all(2),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        header == "Completed Repairs"
                                            ? SvgPicture.asset(
                                                'lib/src/features/ex_register/assets/shield_done.svg',
                                                height: 13,
                                              )
                                            : header == "Inspection Faults"
                                            ? SvgPicture.asset(
                                                'lib/src/features/ex_register/assets/danger_triangle.svg',
                                                height: 13,
                                              )
                                            : SvgPicture.asset(
                                                'lib/src/features/ex_register/assets/danger_circle.svg',
                                                height: 13,
                                              ),
                                        const SizedBox(width: 2),
                                        Text(
                                          header == "Completed Repairs"
                                              ? (val[header].length == 1
                                                    ? " ${val[header].length.toString()} Fault Completely Repaired"
                                                    : " ${val[header].length.toString()} Faults Completely Repaired")
                                              : header == "Inspection Faults"
                                              ? (val[header].length == 1
                                                    ? " ${val[header].length.toString()} Fault Identified!"
                                                    : " ${val[header].length.toString()} Faults Identified!")
                                              : (val[header].length == 1
                                                    ? " ${val[header].length.toString()} Fault Still Pending!"
                                                    : " ${val[header].length.toString()} Faults Still Pending!"),
                                          style: GoogleFonts.inter(
                                            color: header == "Completed Repairs"
                                                ? const Color(0xFF357A38)
                                                : header == "Inspection Faults"
                                                ? const Color(0xFFFF6600)
                                                : const Color(0xFF9C7604),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ).whenComplete(() {
            _controller.reverse();
          })
        : null;
    _controller.forward();
  }
}
