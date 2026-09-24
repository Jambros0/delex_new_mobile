import 'dart:async';
import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_function.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/services/ex_register_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ToServerBloc extends Bloc<ToServerEvent, ToServerState> {
  final ExRegisterService exRegisterService;
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils;

  int skip = 0;
  final int limit = 30;
  String sortField = 'updatedAt';
  String sortOrder = 'descending';
  int? filterIndex;
  String? type;
  DateTime? fromDate;
  DateTime? toDate;

  ToServerBloc({required this.exRegisterService, required this.authUtils})
      : super(WorkOrderToServerInitial()) {
    on<WorkOrderToServerLoad>(loadWorkOrderToServer);
    on<SortToServerLoad>(sortToServerLoad);
    on<ResetWorkOrderToServer>(resetWorkOrderToServerFromOffline);
  }

  FutureOr<void> loadWorkOrderToServer(
      WorkOrderToServerLoad event, Emitter<ToServerState> emit) async {
    emit(WorkOrderToServerLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await loadWorkOrderToServerFromApi(event, emit);
      } else {
        await loadWorkOrderToServerFromOffline(event, emit);
      }
    } catch (e) {
      emit(WorkOrderToServerError(e.toString()));
    }
  }

  FutureOr<void> loadWorkOrderToServerFromApi(
      WorkOrderToServerLoad event, Emitter<ToServerState> emit) async {
    emit(WorkOrderToServerLoading());
    try {
      skip = 0;
      final response = await exRegisterService.fetchAssets(
        limit: limit,
        skip: skip,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      emit(ShowToServerMoreOption(showIcon: false, selectedAssets: const []));

      emit(WorkOrderToServerLoaded(
        tableHeaders: response['tableHeaders'] as List<String>,
        assets: response['assets'] as List<ExRegister>,
        totalRecords: (response['assets'] as List).length,
        isLoadMore: false,
        filterIndex: filterIndex,
        skip: skip + (response['assets'] as List).length,
        sortOrder: sortOrder,
      ));
    } catch (e) {
      emit(WorkOrderToServerError(e.toString()));
    }
  }

  FutureOr<void> loadWorkOrderToServerFromOffline(
      WorkOrderToServerLoad event, Emitter<ToServerState> emit) async {
    emit(WorkOrderToServerLoading());
    try {
      final String? userType = await authUtils.getUserType();

      final rawAssets = await _loadOfflineAssets();
      var filteredList = rawAssets.map((e) => e.exregisterJson).toList();

      List<String> tableHeaders = _getTableHeaders(userType);
      emit(WorkOrderToServerLoaded(
          tableHeaders: tableHeaders,
          assets: filteredList,
          totalRecords: filteredList.length,
          isLoadMore: false,
          filterIndex: filterIndex,
          skip: filteredList.length,
          sortOrder: sortOrder));
    } catch (e) {
      emit(WorkOrderToServerError(e.toString()));
    }
  }

  Future<List<ExRegisterTableModel>> _loadOfflineAssets() async {
    final String? userType = await authUtils.getUserType();
    final targetIds = await _dbHelper.getUserTargetIds(authUtils);
    final String? ownerId = await authUtils.getUserId();
    final results = await _dbHelper.getExRegisterForUser(
      userType: userType,
      targetIds: targetIds,
      ownerId: ownerId,
    );

    final List<ExRegisterTableModel> list = [];
    for (var map in results) {
      try {
        final jsonRaw = map['exregister_json'];
        final jsonMap = (jsonRaw is String)
            ? jsonDecode(jsonRaw)
            : jsonRaw as Map<String, dynamic>?;
        if (jsonMap == null) continue;

        final dynamic rawAsset = jsonMap['asset'] ?? jsonMap;
        Map<String, dynamic> assetMap = {};
        if (rawAsset is Map<String, dynamic>) {
          assetMap = Map<String, dynamic>.from(rawAsset);
        } else if (rawAsset is Map) {
          assetMap = Map<String, dynamic>.from(rawAsset);
        }
        if ((assetMap['_id'] == null || assetMap['_id'].toString().isEmpty)) {
          if (map['asset_id'] != null && map['asset_id'].toString().isNotEmpty) {
            assetMap['_id'] = map['asset_id'];
          } else if (map['id'] != null) {
            assetMap['_id'] = map['id'].toString();
          }
        }
        if (assetMap['primaryId'] == null && map['id'] != null) {
          assetMap['primaryId'] = map['id'] is int
              ? map['id']
              : int.tryParse(map['id'].toString());
        }

        final locationId = assetMap['locationId']?.toString() ?? '';
        final locationEmpty = (assetMap['location'] == null || assetMap['location'].toString().trim().isEmpty) &&
            (assetMap['fieldName'] == null || assetMap['fieldName'].toString().trim().isEmpty);
        final areaEmpty = (assetMap['area'] == null || assetMap['area'].toString().trim().isEmpty) &&
            (assetMap['platform'] == null || assetMap['platform'].toString().trim().isEmpty);

        if (locationId.isNotEmpty && (locationEmpty || areaEmpty)) {
          try {
            final locRow = (userType == 'onshore')
                ? await _dbHelper.getFunctionalAreaByIdOnshore(locationId)
                : await _dbHelper.getFunctionalAreaById(locationId);
            if (locRow != null && locRow['functional_area_json'] != null) {
              final locJsonRaw = locRow['functional_area_json'];
              final locJsonMap = (locJsonRaw is String)
                  ? jsonDecode(locJsonRaw)
                  : locJsonRaw as Map<String, dynamic>?;
              final locData = locJsonMap?['location'] ?? locJsonMap;
              if (locData is Map) {
                if (locationEmpty && locData['location'] != null) {
                  assetMap['location'] = locData['location'];
                }
                if (areaEmpty && locData['area'] != null) {
                  assetMap['area'] = locData['area'];
                }
                if ((assetMap['subArea'] == null || assetMap['subArea'].toString().isEmpty) && locData['subArea'] != null) {
                  assetMap['subArea'] = locData['subArea'];
                }
                if ((assetMap['deckLevel'] == null || assetMap['deckLevel'].toString().isEmpty) && locData['deckLevel'] != null) {
                  assetMap['deckLevel'] = locData['deckLevel'];
                }
                if ((assetMap['zone'] == null || assetMap['zone'].toString().isEmpty) && locData['zone'] != null) {
                  assetMap['zone'] = locData['zone'];
                }
                if ((assetMap['locationGasGroup'] == null || (assetMap['locationGasGroup'] is List && (assetMap['locationGasGroup'] as List).isEmpty)) && locData['locationGasGroup'] != null) {
                  assetMap['locationGasGroup'] = locData['locationGasGroup'];
                }
                if ((assetMap['locationTClass'] == null || (assetMap['locationTClass'] is List && (assetMap['locationTClass'] as List).isEmpty)) && locData['locationTClass'] != null) {
                  assetMap['locationTClass'] = locData['locationTClass'];
                }
                if ((assetMap['locationIpRating'] == null || (assetMap['locationIpRating'] is List && (assetMap['locationIpRating'] as List).isEmpty)) && locData['locationIpRating'] != null) {
                  assetMap['locationIpRating'] = locData['locationIpRating'];
                }
                if ((assetMap['locationTAmbient'] == null || assetMap['locationTAmbient'].toString().isEmpty) && (locData['locationTAmbient'] != null || locData['tAmbient'] != null)) {
                  assetMap['locationTAmbient'] = locData['locationTAmbient'] ?? locData['tAmbient'];
                }
              }
            }
          } catch (_) {}
        }

        list.add(ExRegisterTableModel(
          id: map['id'],
          exregisterJson: ExRegister.fromJson(assetMap),
          createdBy: map['created_by'],
          updatedBy: map['updated_by'],
          createdDate: map['created_date'],
          updatedDate: map['updated_date'],
        ));
      } catch (e) {
        // Safe skip on corrupt row
      }
    }
    return list;
  }

  List<String> _getTableHeaders(String? userType) {
    return (userType == 'onshore')
        ? [
            "RFID Reference",
            "Location",
            "Sub Location",
            "Area",
            "Zone",
            "Discipline",
            "Equipment Tag Number",
            "Equipment Description",
            "Equipment Manufacturer",
            "Equipment Protection",
            "Inspection Faults",
            "Inspection Status",
            "Completed Repairs",
            "Existing Faults",
            "Current Status",
          ]
        : [
            "RFID Reference",
            "Field Name",
            "Platform",
            "Deck Level",
            "Zone",
            "Discipline",
            "Equipment Tag Number",
            "Equipment Description",
            "Manufacturer",
            "Equipment Protection",
            "Inspection Faults",
            "Inspection Status",
            "Completed Repairs",
            "Existing Faults",
            "Current Status"
          ];
  }

  String _deriveStatus(ExRegister asset, String field) {
    final isInspection = field == 'inspectionStatus';
    final defaultStatus =
        isInspection ? asset.inspectionStatus : asset.currentStatus;

    if (defaultStatus.isNotEmpty) return defaultStatus;

    final priority =
        isInspection ? asset.inspectionPriority : asset.repairPriority;

    if ([
      asset.inspectionGrade,
      asset.inspectionType,
      asset.inspectionChecklistType,
      asset.equipmentEquipmentType
    ].any((e) => e?.isEmpty ?? true)) {
      return '';
    }

    if (asset.checkList?.isEmpty ?? true) return "Green";
    if (priority == null) return '';

    if (priority <= 2) return "Red";
    if (priority >= 3 && priority <= 5) return "Yellow";
    return '';
  }

  List<ExRegister> _applyFilters(
      List<ExRegister> list, Map<String, List<String>> filters) {
    filters.forEach((field, selected) {
      if (selected.isEmpty) return;

      list = list.where((asset) {
        final status = _deriveStatus(asset, field);
        return selected.contains(status);
      }).toList();
    });
    return list;
  }

  FutureOr<void> sortToServerLoad(
      SortToServerLoad event, Emitter<ToServerState> emit) async {
    emit(ToServerLoading());
    try {
      if (dotenv.env['IS_API_FLAG'] == 'true') {
        await sortToServerLoadByApi(event, emit);
      } else {
        await _handleOfflineSortOrReset(event, emit, isReset: false);
      }
    } catch (e) {
      emit(ToServerError(e.toString()));
    }
  }

  FutureOr<void> sortToServerLoadByApi(
      SortToServerLoad event, Emitter<ToServerState> emit) async {
    emit(ToServerLoading());
    try {
      skip = 0;
      sortOrder = event.sortOrder;
      sortField = event.sortField;
      filterIndex = sortOrder == "descending" ? event.columnIndex : null;

      final response = await exRegisterService.fetchAssets(
        limit: limit,
        skip: 0,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      emit(WorkOrderToServerLoaded(
        tableHeaders: response['tableHeaders'] as List<String>,
        assets: response['assets'] as List<ExRegister>,
        totalRecords: response['totalRecords'] as int,
        filterIndex: event.columnIndex,
        skip: 0,
        sortOrder: sortOrder,
      ));
      skip = limit;
    } catch (e) {
      emit(ToServerError(e.toString()));
    }
  }

  FutureOr<void> resetWorkOrderToServerFromOffline(
      ResetWorkOrderToServer event, Emitter<ToServerState> emit) async {
    emit(WorkOrderToServerLoading());
    await _handleOfflineSortOrReset(event, emit, isReset: true);
  }

  Future<void> _handleOfflineSortOrReset(
      dynamic event, Emitter<ToServerState> emit,
      {required bool isReset}) async {
    emit(WorkOrderToServerLoading());
    try {
      final userType = await authUtils.getUserType();
      final rawAssets = await _loadOfflineAssets();
      var filteredList = rawAssets.map((e) => e.exregisterJson).toList();

      if (!isReset) {
        sortOrder = event.sortOrder;
        sortField = event.sortField;
        filterIndex = sortOrder == "descending" ? event.columnIndex : null;
        filteredList =
            _applyFilters(filteredList, event.collectionSelectedFilter);

        if (sortOrder.isNotEmpty) {
          filteredList = ExRegisterFunction.sortList(
            filteredList: filteredList,
            columnIndex: event.columnIndex,
            sortOrder: sortOrder,
          );
        }
      } else {
        filteredList =
            _applyFilters(filteredList, event.collectionSelectedFilter);
      }

      emit(WorkOrderToServerLoaded(
        tableHeaders: _getTableHeaders(userType),
        assets: filteredList,
        totalRecords: rawAssets.length,
        skip: 0,
        sortOrder: sortOrder,
        filterIndex: isReset ? null : event.columnIndex,
        collectionSelectedFilter: event.collectionSelectedFilter,
      ));
    } catch (e) {
      emit(ToServerError(e.toString()));
    }
  }
}
