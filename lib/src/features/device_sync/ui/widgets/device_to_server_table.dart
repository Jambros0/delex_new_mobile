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

    _rowSelection = List<bool>.filled(widget.assets.length, false, growable: true);
    _chunkSize = widget.assets.length > 0 ? widget.assets.length : 50;
    rows = [];

    _loadNextChunkSync();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNextChunk();
      }
    });
  }

  void _loadNextChunkSync() {
    if (_loadedCount >= widget.assets.length) return;

    final end = (_loadedCount + _chunkSize).clamp(
      0,
      widget.assets.length,
    );

    final newRows = <List<String>>[];
    for (int i = _loadedCount; i < end; i++) {
      newRows.add(_buildRow(i));
    }

    rows.addAll(newRows);
    _loadedCount = end;
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
      _rowSelection = List<bool>.filled(widget.assets.length, false, growable: true);
      _loadNextChunkSync();
    }
  }

  String _formatEquipmentProtection(ExRegister asset) {
    List<String> parts = [];
    String getCleanString(List<String>? items) {
      if (items == null || items.isEmpty) return '';
      final filtered = items.where((e) {
        if (e == null) return false;
        final val = e.toString().trim().toLowerCase();
        return val.isNotEmpty &&
            val != 'not available' &&
            val != 'n/a' &&
            val != 'na' &&
            val != 'null';
      }).map((e) => e.toString().trim()).toList();
      return filtered.join(', ');
    }

    final protType = getCleanString(asset.protectionType);
    var gasGroup = getCleanString(asset.equipmentGasGroup);
    if (gasGroup.isEmpty) {
      gasGroup = getCleanString(asset.locationGasGroup);
    }
    var tempClass = getCleanString(asset.equipmentTClass);
    if (tempClass.isEmpty) {
      tempClass = getCleanString(asset.locationTClass);
    }
    final protStd = asset.protectionStd?.toString().trim() ?? '';

    if (protType.isNotEmpty) parts.add(protType);
    if (gasGroup.isNotEmpty) parts.add(gasGroup);
    if (tempClass.isNotEmpty) parts.add(tempClass);
    if (parts.isEmpty && protStd.isNotEmpty && protStd.toLowerCase() != 'null') {
      parts.add(protStd);
    }
    if (parts.isEmpty && asset.epl.isNotEmpty) {
      final eplStr = getCleanString(asset.epl);
      if (eplStr.isNotEmpty) parts.add(eplStr);
    }

    return parts.join(' ');
  }

  int _countChecklistFindings(ExRegister asset) {
    if (asset.checkList == null || asset.checkList!.isEmpty) return 0;
    int count = 0;
    for (var cl in asset.checkList!) {
      for (var dc in cl.defectCodes) {
        count += dc.findingsAndActions.length;
      }
    }
    return count;
  }

  int _countChecklistCompleted(ExRegister asset) {
    if (asset.checkList == null || asset.checkList!.isEmpty) return 0;
    int count = 0;
    for (var cl in asset.checkList!) {
      for (var dc in cl.defectCodes) {
        count += dc.findingsAndActions.where((fa) => fa.isDone == true).length;
      }
    }
    return count;
  }

  int _countChecklistExisting(ExRegister asset) {
    if (asset.checkList == null || asset.checkList!.isEmpty) return 0;
    int count = 0;
    for (var cl in asset.checkList!) {
      for (var dc in cl.defectCodes) {
        count += dc.findingsAndActions.where((fa) => fa.isDone != true).length;
      }
    }
    return count;
  }

  List<String> _buildRow(int index) {
    final asset = widget.assets[index];

    String sanitize(dynamic value) {
      if (value == null) return '';
      final str = value.toString().trim();
      return (str.isEmpty || str.toLowerCase() == 'null') ? '' : str;
    }

    final isOnshore = widget.headers.contains('Sub Location');
    final hasChecklist = asset.checkList != null && asset.checkList!.isNotEmpty;
    final totalFindings = _countChecklistFindings(asset);
    final completedRepairs = _countChecklistCompleted(asset);
    final existingFaultsCount = _countChecklistExisting(asset);

    final rawFaults = sanitize(asset.faultyItems);
    final faultsDisplay = rawFaults.isNotEmpty
        ? rawFaults
        : (hasChecklist ? totalFindings.toString() : '');

    final rawRepairs = sanitize(asset.repairsDone);
    final repairsDisplay = rawRepairs.isNotEmpty
        ? rawRepairs
        : (hasChecklist ? completedRepairs.toString() : '');

    final rawExisting = sanitize(asset.existingFaults);
    final existingDisplay = rawExisting.isNotEmpty
        ? rawExisting
        : (hasChecklist ? existingFaultsCount.toString() : '');

    final isInspected = (asset.inspectedBy != null &&
            asset.inspectedBy.toString().trim().isNotEmpty &&
            asset.inspectedBy.toString() != 'null') ||
        (asset.inspectedDate != null &&
            asset.inspectedDate.toString().trim().isNotEmpty &&
            asset.inspectedDate.toString() != 'null') ||
        hasChecklist;

    String inspectionStatusDisplay = sanitize(asset.inspectionStatus);
    if (inspectionStatusDisplay.isEmpty && isInspected) {
      if (asset.inspectionPriority != null) {
        if (asset.inspectionPriority! <= 2 && asset.inspectionPriority! > 0) {
          inspectionStatusDisplay = 'Red';
        } else if (asset.inspectionPriority! >= 3 && asset.inspectionPriority! <= 5) {
          inspectionStatusDisplay = 'Yellow';
        } else {
          inspectionStatusDisplay = 'Green';
        }
      } else if (hasChecklist) {
        inspectionStatusDisplay = existingFaultsCount > 0 ? 'Yellow' : 'Green';
      } else {
        inspectionStatusDisplay = 'Green';
      }
    }

    String currentStatusDisplay = sanitize(asset.currentStatus);
    if (currentStatusDisplay.isEmpty && isInspected) {
      final p = asset.repairPriority ?? asset.inspectionPriority;
      if (p != null) {
        if (p is int && p <= 2 && p > 0) {
          currentStatusDisplay = 'Red';
        } else if (p is int && p >= 3 && p <= 5) {
          currentStatusDisplay = 'Yellow';
        } else {
          currentStatusDisplay = 'Green';
        }
      } else if (hasChecklist) {
        currentStatusDisplay = existingFaultsCount > 0 ? 'Yellow' : 'Green';
      } else {
        currentStatusDisplay = 'Green';
      }
    }

    final locationVal = sanitize(asset.location);
    final areaVal = sanitize(asset.area);
    final deckLevelVal = sanitize(asset.deckLevel);

    return [
      sanitize(asset.id),
      sanitize(asset.rfidRef),
      locationVal,
      areaVal,
      deckLevelVal,
      sanitize(asset.zone),
      sanitize(asset.eqpmtCatg),
      sanitize(asset.eqpmtTag),
      sanitize(asset.description),
      sanitize(asset.manufacturer),
      _formatEquipmentProtection(asset),
      faultsDisplay,
      inspectionStatusDisplay,
      repairsDisplay,
      existingDisplay,
      currentStatusDisplay,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final columnKeys = widget.headers.contains('Sub Location')
        ? [
            'rfidRef',
            'location',
            'subLocation',
            'area',
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
          ]
        : [
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
