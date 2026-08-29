import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/custom_table_grid.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/device_sync_event.dart';

class ServerToDeviceTable extends StatefulWidget {
  final List<ExRegister> assets;
  final List<String> headers;
  final Function(int) onRowSelected;
  final dynamic sortOrder;
  final int? filterIndex;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  final List<ExRegister> registerCollections;
  final List<bool> rowSelection;

  const ServerToDeviceTable(
      {super.key,
      required this.assets,
      required this.headers,
      required this.onRowSelected,
      required this.sortOrder,
      this.filterIndex,
      required this.selectedFilters,
      required this.collectionSelectedFilter,
      required this.registerCollections,
      this.rowSelection = const []});

  @override
  ExRegisterTableState createState() => ExRegisterTableState();
}

class ExRegisterTableState extends State<ServerToDeviceTable> {
  List<bool> rowSelection = [];

  late List<List<String>> rows;
  static int _chunkSize = 50;
  int _loadedCount = 0;
  @override
  void initState() {
    super.initState();
    rowSelection = List<bool>.filled(widget.assets.length, false);
    _chunkSize = widget.assets.length;
    rows = [];

    _loadNextChunk();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNextChunk(); // continue loading after first render
    });
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
      asset.epl.join(', '),
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
      asset.repairsDone?.toString().isNotEmpty == true
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

  void _loadNextChunk() {
    if (_loadedCount >= widget.assets.length) return;

    final end = (_loadedCount + _chunkSize).clamp(0, widget.assets.length);

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
  void didUpdateWidget(covariant ServerToDeviceTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assets != widget.assets) {
      _loadedCount = 0;
      rows.clear();
      rowSelection = List<bool>.filled(widget.assets.length, false);
      _loadNextChunk();
    }
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
    //     asset.repairsDone?.toString().isNotEmpty == true
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
      initialSelection: widget.rowSelection,
      filterIndex: widget.filterIndex,
      tableType: 'Server To Device',
      sortOrder: widget.sortOrder,
      onRowSelected: (index) => widget.onRowSelected(index),
      // onRowSelected: (index) {
      //   setState(() {
      //     rowSelection[index] = !rowSelection[index];
      //   });
      //   widget.onRowSelected(index, rowSelection);
      // },
      onSortChanged: (sortField, sortOrder, columnIndex, selectedFilters,
          collectionSelectedFilter) {
        BlocProvider.of<DeviceSyncBloc>(context).add(SortLoadMoreWorkOrder(
          sortField: sortField,
          sortOrder: sortOrder,
          columnIndex: columnIndex,
          selectedFilters: selectedFilters,
          collectionSelectedFilter: collectionSelectedFilter,
          assets: widget.assets,
          registerCollections: widget.registerCollections,
        ));
      },
      datetype: '',
      searchQuery: '',
      showFilterType: '',
      selectedFilters: widget.selectedFilters,
      alreadycollectionSelectedFilter: widget.collectionSelectedFilter,
      assets: widget.assets,
      registerCollections: widget.registerCollections,
    );
  }
}
