import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/custom_table_grid.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceToServerTable extends StatefulWidget {
  final List<ExRegister> assets;
  final List<String> headers;
  final Function(int, List<bool>) onRowSelected;
  final dynamic sortOrder;
  final int? filterIndex;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  const DeviceToServerTable(
      {super.key,
      required this.assets,
      required this.headers,
      required this.onRowSelected,
      required this.sortOrder,
      this.filterIndex,
      required this.selectedFilters,
      required this.collectionSelectedFilter});

  @override
  DeviceToServerTableState createState() => DeviceToServerTableState();
}

class DeviceToServerTableState extends State<DeviceToServerTable> {
  late List<List<String>> rows;
  static int _chunkSize = 50;
  int _loadedCount = 0;
  late List<bool> _rowSelection;

  @override
  void initState() {
    super.initState();

    _rowSelection = List<bool>.filled(widget.assets.length, false);
    _chunkSize = widget.assets.length;
    rows = [];

    _loadNextChunk();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNextChunk(); // continue after first render
    });
  }

  void _loadNextChunk() {
    if (_loadedCount >= widget.assets.length) return;

    final end = (_loadedCount + _chunkSize).clamp(
      0,
      widget.assets.length,
    );

    final newRows = <List<String>>[];
    for (int i = _loadedCount; i < end; i++) {
      newRows.add(_buildRow(i));
    }

    setState(() {
      rows.addAll(newRows);
      _loadedCount = end;
    });
  }

  @override
  void didUpdateWidget(covariant DeviceToServerTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assets != widget.assets) {
      _loadedCount = 0;
      rows.clear();
      _rowSelection = List<bool>.filled(widget.assets.length, false);
      _loadNextChunk();
    }
  }

  // @override
  // void didUpdateWidget(covariant DeviceToServerTable oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   // Reinitialize selection if sort order or assets change
  //   if (widget.sortOrder != oldWidget.sortOrder ||
  //       widget.assets != oldWidget.assets) {
  //     _initializeSelection();
  //   }
  // }

  // void _initializeSelection() {
  //   _selectedRows = List<bool>.filled(widget.assets.length, false);

  //   // Optional: pre-select rows based on sortOrder
  //   if (widget.sortOrder.isNotEmpty) {
  //     for (int i = 0; i < widget.assets.length; i++) {
  //       final asset = widget.assets[i];
  //       if (widget.sortOrder.contains(asset.status.toLowerCase())) {
  //         _selectedRows[i] = true;
  //       }
  //     }
  //   }

  //   setState(() {}); // trigger UI update
  // }
  String _formatEquipmentProtection(ExRegister asset) {
    List<String> parts = [];
    String getCleanString(List<String>? items) {
      if (items == null || items.isEmpty) return '';
      final filtered = items.where((e) {
        final val = e.trim().toLowerCase();
        return val.isNotEmpty &&
            val != 'not available' &&
            val != 'n/a' &&
            val != 'na' &&
            val != 'null';
      }).toList();
      return filtered.join(', ');
    }

    final protType = getCleanString(asset.protectionType);
    final gasGroup = getCleanString(asset.equipmentGasGroup);
    final tempClass = getCleanString(asset.equipmentTClass);

    if (protType.isNotEmpty) parts.add(protType);
    if (gasGroup.isNotEmpty) parts.add(gasGroup);
    if (tempClass.isNotEmpty) parts.add(tempClass);

    return parts.join(' ');
  }

  List<String> _buildRow(int index) {
    final asset = widget.assets[index];

    return [
      asset.id,
      asset.rfidRef.isNotEmpty ? asset.rfidRef : '',
      asset.location.isNotEmpty ? asset.location : '',
      asset.area.isNotEmpty ? asset.area : '',
      asset.deckLevel ?? '',
      asset.zone.isNotEmpty ? asset.zone : '',
      asset.eqpmtCatg,
      asset.eqpmtTag ?? '',
      asset.description.isNotEmpty ? asset.description : '',
      asset.manufacturer.isNotEmpty ? asset.manufacturer : '',
      _formatEquipmentProtection(asset),
      asset.faultyItems?.toString().isNotEmpty == true
          ? asset.faultyItems.toString()
          : '',
      (asset.inspectionStatus.isNotEmpty
          ? asset.inspectionStatus
          : (asset.inspectionGrade?.isNotEmpty == true &&
                  asset.inspectionType?.isNotEmpty == true &&
                  asset.inspectionChecklistType.isNotEmpty == true &&
                  asset.equipmentEquipmentType?.isNotEmpty == true)
              ? (asset.checkList == null || asset.checkList!.isEmpty
                  ? "Green"
                  : (asset.inspectionPriority != null
                      ? (asset.inspectionPriority! <= 2
                          ? "Red"
                          : (asset.inspectionPriority! >= 3 &&
                                  asset.inspectionPriority! <= 5
                              ? "Yellow"
                              : ''))
                      : ''))
              : ''),
      (asset.repairsDone!.toString().isNotEmpty &&
              asset.repairsDone != null &&
              asset.repairsDone != "null")
          ? asset.repairsDone.toString()
          : '',
      asset.existingFaults?.toString() ?? '',
      (asset.currentStatus.isNotEmpty
          ? asset.currentStatus
          : (asset.inspectionGrade?.isNotEmpty == true &&
                  asset.inspectionType?.isNotEmpty == true &&
                  asset.inspectionChecklistType.isNotEmpty == true &&
                  asset.equipmentEquipmentType?.isNotEmpty == true)
              ? (asset.checkList == null || asset.checkList!.isEmpty
                  ? "Green"
                  : (asset.inspectionPriority != null
                      ? (asset.inspectionPriority! <= 2
                          ? "Red"
                          : (asset.inspectionPriority! >= 3 &&
                                  asset.inspectionPriority! <= 5
                              ? "Yellow"
                              : ''))
                      : ''))
              : '')
    ];
  }

  @override
  Widget build(BuildContext context) {
    // final rows = widget.assets.map((asset) {
    //   return [
    //     asset.id,
    //     asset.rfidRef.isNotEmpty ? asset.rfidRef : '',
    //     asset.location.isNotEmpty ? asset.location : '',
    //     asset.area.isNotEmpty ? asset.area : '',
    //     asset.deckLevel ?? '',
    //     asset.zone.isNotEmpty ? asset.zone : '',
    //     asset.eqpmtCatg,
    //     asset.eqpmtTag ?? '',
    //     asset.description.isNotEmpty ? asset.description : '',
    //     asset.manufacturer.isNotEmpty ? asset.manufacturer : '',
    //     asset.epl.join(', '),
    //     asset.faultyItems?.toString().isNotEmpty == true
    //         ? asset.faultyItems.toString()
    //         : '',
    //     (asset.inspectionStatus.isNotEmpty
    //         ? asset.inspectionStatus
    //         : (asset.inspectionGrade?.isNotEmpty == true &&
    //                 asset.inspectionType?.isNotEmpty == true &&
    //                 asset.inspectionChecklistType.isNotEmpty == true &&
    //                 asset.equipmentEquipmentType?.isNotEmpty == true)
    //             ? (asset.checkList == null || asset.checkList!.isEmpty
    //                 ? "Green"
    //                 : (asset.inspectionPriority != null
    //                     ? (asset.inspectionPriority! <= 2
    //                         ? "Red"
    //                         : (asset.inspectionPriority! >= 3 &&
    //                                 asset.inspectionPriority! <= 5
    //                             ? "Yellow"
    //                             : ''))
    //                     : ''))
    //             : ''),
    //     (asset.repairsDone!.toString().isNotEmpty &&
    //             asset.repairsDone != null &&
    //             asset.repairsDone != "null")
    //         ? asset.repairsDone.toString()
    //         : '',
    //     asset.existingFaults?.toString() ?? '',
    //     (asset.currentStatus.isNotEmpty
    //         ? asset.currentStatus
    //         : (asset.inspectionGrade?.isNotEmpty == true &&
    //                 asset.inspectionType?.isNotEmpty == true &&
    //                 asset.inspectionChecklistType.isNotEmpty == true &&
    //                 asset.equipmentEquipmentType?.isNotEmpty == true)
    //             ? (asset.checkList == null || asset.checkList!.isEmpty
    //                 ? "Green"
    //                 : (asset.inspectionPriority != null
    //                     ? (asset.inspectionPriority! <= 2
    //                         ? "Red"
    //                         : (asset.inspectionPriority! >= 3 &&
    //                                 asset.inspectionPriority! <= 5
    //                             ? "Yellow"
    //                             : ''))
    //                     : ''))
    //             : '')
    //   ];
    // }).toList();

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
        headers: widget.headers,
        rows: rows,
        columnKeys: columnKeys,
        initialSelection: _rowSelection,
        filterIndex: widget.filterIndex,
        sortOrder: widget.sortOrder,
        tableType: 'Device To Server',
        onRowSelected: (index) {
          setState(() {
            _rowSelection[index] = !_rowSelection[index];
          });
          widget.onRowSelected(index, _rowSelection);
        },
        onSortChanged: (sortField, sortOrder, columnIndex, selectedFilters,
            collectionSelectedFilter) {
          BlocProvider.of<ToServerBloc>(context).add(SortToServerLoad(
              sortField: sortField,
              sortOrder: sortOrder,
              columnIndex: columnIndex,
              selectedFilters: selectedFilters,
              collectionSelectedFilter: collectionSelectedFilter));
        },
        datetype: '',
        searchQuery: '',
        showFilterType: '',
        selectedFilters: widget.selectedFilters,
        alreadycollectionSelectedFilter: widget.collectionSelectedFilter,
        assets: widget.assets);
  }
}
