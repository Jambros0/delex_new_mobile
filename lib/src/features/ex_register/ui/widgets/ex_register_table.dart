import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/custom_table_grid.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExRegisterTable extends StatefulWidget {
  final List<ExRegister> assets;
  final List<String> headers;
  final String searchQuery;
  final int? filterIndex;
  final dynamic sortOrder;
  final Function(int, List<ExRegister>)
  onRowSelectionCountChanged; // Callback for row selection count
  final DateTime? fromDate;
  final DateTime? toDate;
  final String datetype;
  final String showFilterType;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  final ExRegisterBloc bloc;
  final String tableHeader;
  const ExRegisterTable({
    super.key,
    required this.assets,
    required this.headers,
    required this.searchQuery,
    this.filterIndex,
    required this.sortOrder,
    required this.onRowSelectionCountChanged,
    this.fromDate,
    this.toDate,
    required this.datetype,
    required this.showFilterType,
    required this.selectedFilters,
    required this.collectionSelectedFilter,
    required this.bloc,
    this.tableHeader = '',
  });

  @override
  ExRegisterTableState createState() => ExRegisterTableState();
}

class ExRegisterTableState extends State<ExRegisterTable> {
  late List<ExRegister> _filteredExRegister;
  late List<bool> _rowSelection;

  Map<String, dynamic> actions = {};

  @override
  void initState() {
    super.initState();
    _updateFilteredExRegister();
  }

  @override
  void didUpdateWidget(covariant ExRegisterTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assets != oldWidget.assets ||
        widget.searchQuery != oldWidget.searchQuery) {
      _updateFilteredExRegister();
    }
  }

  void _updateFilteredExRegister() {
    _filteredExRegister = _filterExRegister(widget.assets, widget.searchQuery);
    _rowSelection = List.generate(_filteredExRegister.length, (index) => false);
    _notifyRowSelectionCount();
  }

  void _notifyRowSelectionCount() {
    widget.onRowSelectionCountChanged(
      _rowSelection.length,
      _filteredExRegister,
    );
  }

  // void _toggleRowSelection(int index) {
  //   setState(() {
  //     _rowSelection[index] = !_rowSelection[index];
  //     _notifyRowSelectionCount();
  //   });
  // }

  List<ExRegister> _filterExRegister(List<ExRegister> assets, String query) {
    if (query.isEmpty) {
      return assets;
    }
    final lowerQuery = query.toLowerCase();
    return assets.where((asset) {
      return asset.rfidRef.toLowerCase().contains(lowerQuery) ||
          asset.location.toLowerCase().contains(lowerQuery) ||
          asset.area.toLowerCase().contains(lowerQuery) ||
          (asset.eqpmtTag ?? '').toLowerCase().contains(lowerQuery) ||
          asset.description.toLowerCase().contains(lowerQuery) ||
          (asset.epl.any(
            (group) => group.toLowerCase().contains(lowerQuery),
          )) ||
          (asset.deckLevel ?? '').toLowerCase().contains(lowerQuery) ||
          asset.zone.toLowerCase().contains(lowerQuery) ||
          (asset.eqpmtCatg).toLowerCase().contains(lowerQuery) ||
          asset.manufacturer.toLowerCase().contains(lowerQuery) ||
          asset.inspectionStatus.toLowerCase().contains(lowerQuery) ||
          asset.currentStatus.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Map<String, dynamic> getFindingsList(ExRegister asset) {
    List<Inspection> findings = [];
    List<Completed> completed = [];
    List<Existing> existing = [];
    Map<String, dynamic> findingList = {};

    for (var checkListDetail in asset.checkList!) {
      if (checkListDetail.defectCodes.isNotEmpty) {
        for (var defectCode in checkListDetail.defectCodes) {
          for (var findingsAndAction in defectCode.findingsAndActions) {
            findings.add(
              Inspection(
                defectCode: findingsAndAction.defectCode,
                finding: findingsAndAction.finding,
              ),
            );
            findingList['Inspection Faults'] = findings;
            if (findingsAndAction.isDone) {
              completed.add(
                Completed(
                  isDone: findingsAndAction.isDone,
                  remedialAction: findingsAndAction.remedialAction,
                ),
              );
              findingList['Completed Repairs'] = completed;
            }
            if (findingsAndAction.isDone != true) {
              existing.add(
                Existing(
                  defectCode: findingsAndAction.defectCode,
                  finding: findingsAndAction.finding,
                ),
              );
              findingList['Existing Faults'] = existing;
            }
          }
        }
      }
    }
    return findingList;
  }

  @override
  Widget build(BuildContext context) {
    List<List<String>> rows = _filteredExRegister.map((asset) {
      if (asset.checkList != null && asset.checkList!.isNotEmpty) {
        actions[asset.id] = getFindingsList(asset);
      }
      var inspectedCheck =
          (asset.inspectedBy.toString().isEmpty ||
              asset.inspectedBy == null ||
              asset.inspectedBy == "null") &&
          (asset.inspectedDate == null ||
              asset.inspectedDate.toString().isEmpty ||
              asset.inspectedDate == "null");
      return [
        asset.id,
        asset.rfidRef.isNotEmpty ? asset.rfidRef : '',
        asset.location.isNotEmpty ? asset.location : '',
        asset.area.isNotEmpty ? asset.area : '',
        asset.deckLevel?.isNotEmpty == true ? asset.deckLevel! : '',
        asset.zone.isNotEmpty ? asset.zone : '',
        asset.eqpmtCatg.isNotEmpty == true ? asset.eqpmtCatg : '',
        asset.eqpmtTag?.isNotEmpty == true ? asset.eqpmtTag! : '',
        asset.description.isNotEmpty ? asset.description : '',
        asset.manufacturer.isNotEmpty ? asset.manufacturer : '',
        asset.epl.isNotEmpty == true ? asset.epl.join(', ') : '',
        inspectedCheck
            ? ""
            : asset.faultyItems?.toString().isNotEmpty == true
            ? asset.faultyItems.toString()
            : '',
        inspectedCheck
            ? ""
            : asset.inspectionStatus.isNotEmpty
            ? asset.inspectionStatus
            : (asset.inspectionPriority != null
                  ? (asset.inspectionPriority! <= 2
                        ? "Red"
                        : (asset.inspectionPriority! >= 3 &&
                                  asset.inspectionPriority! <= 5
                              ? "Yellow"
                              : 'Green'))
                  : ''),
        inspectedCheck
            ? ''
            : (asset.repairsDone != null &&
                  asset.repairsDone.toString().trim().isNotEmpty &&
                  asset.repairsDone != "null")
            ? asset.repairsDone.toString()
            : '',
        inspectedCheck ? "" : asset.existingFaults?.toString() ?? '',
        inspectedCheck
            ? ""
            : (asset.currentStatus.isNotEmpty
                  ? asset.currentStatus
                  : (asset.checkList == null || asset.checkList!.isEmpty
                        ? "Green"
                        : (asset.repairPriority != null
                              ? (asset.repairPriority! <= 2
                                    ? "Red"
                                    : (asset.repairPriority! >= 3 &&
                                              asset.repairPriority! <= 5
                                          ? "Yellow"
                                          : 'Green'))
                              : ''))),
      ].map((e) => e.toString()).toList();
    }).toList();

    final columnKeys = [
      'rfidRef',
      'location',
      'area',
      'deckLevel',
      'zone',
      'discipline',
      'eqpmtTag',
      'description',
      'manufacturer',
      'epl',
      'inspectionFaults',
      'inspectionStatus',
      'completedRepairs',
      'existingFaults',
      'currentStatus',
    ];

    return CustomTableGrid(
      filterIndex: widget.filterIndex,
      actions: actions,
      headers: widget.headers,
      rows: rows,
      columnKeys: columnKeys,
      initialSelection: _rowSelection,
      sortOrder: widget.sortOrder,
      tableType: 'Ex Register',
      onRowSelected: (index) {
        setState(() {
          _rowSelection[index] = !_rowSelection[index];
        });
      },
      onSortChanged:
          (
            sortField,
            sortOrder,
            columnIndex,
            selectedFilters,
            collectionSelectedFilter,
          ) {
            // Map<String, List<String>> data = {};
            // data[sortField] = selectedFilters;
            context.read<ExRegisterBloc>().add(
              SortExRegister(
                sortField: sortField,
                sortOrder: sortOrder,
                columnIndex: columnIndex,
                selectedFilters: selectedFilters,
                fromDate: widget.fromDate,
                toDate: widget.toDate,
                type: widget.datetype,
                showAllFilterType: widget.showFilterType,
                searchQuery: widget.searchQuery,
                collectionSelectedFilter: collectionSelectedFilter,
              ),
            );
          },
      onFilterRemove:
          (
            fromDate,
            toDate,
            isReset,
            datetype,
            showFilterType,
            collectionSelectedData,
            sortField,
            selectedFilters,
          ) {
            if (widget.tableHeader == "Ex Register") {
              widget.bloc.add(
                ResetFilterExRegister(
                  fromDate: fromDate,
                  toDate: toDate,
                  isReset: isReset,
                  type: datetype,
                  showAllFilterType: showFilterType,
                  collectionSelectedFilterData: collectionSelectedData,
                ),
              );
            }
          },
      fromDate: widget.fromDate,
      toDate: widget.toDate,
      datetype: widget.datetype,
      showFilterType: widget.showFilterType,
      searchQuery: widget.searchQuery,
      selectedFilters: widget.selectedFilters,
      alreadycollectionSelectedFilter: widget.collectionSelectedFilter,
      assets: widget.assets,
    );
  }
}
