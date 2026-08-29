import 'dart:async';

import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_function.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceSyncBloc extends Bloc<DeviceSyncEvent, DeviceSyncState> {
  final DeviceSyncServices deviceSyncServices;
  // final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils;

  int skip = 0;
  final int limit = 30;
  String sortField = 'updatedAt';
  String sortOrder = 'descending';
  int? filterIndex;
  String? type;
  DateTime? fromDate;
  DateTime? toDate;

  DeviceSyncBloc({required this.deviceSyncServices, required this.authUtils})
      : super(WorkOrderInitial()) {
    on<LoadWorkOrder>(_onLoadWorkOrder);
    on<LoadNewWorkOrder>(_onLoadNewWorkOrder);
    on<SortLoadMoreWorkOrder>(sortLoadMoreWorkOrder);
    on<ResetLoadMoreWorkOrder>(resetLoadMoreWorkOrderFromOffline);
  }
  FutureOr<void> _onLoadNewWorkOrder(
    LoadNewWorkOrder event,
    Emitter<DeviceSyncState> emit,
  ) async {
    emit(WorkOrderLoading());
    try {
      final response = await deviceSyncServices.fetchWorkOrderAssets();
      final String? userType = await authUtils.getUserType();

      List<String> tableHeaders = (userType == 'onshore')
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
              "Equipment Manufacturer",
              "Equipment Protection",
              "Inspection Faults",
              "Inspection Status",
              "Completed Repairs",
              "Existing Faults",
              "Current Status",
            ];
      final List<ExRegister> assets = response['assets'] as List<ExRegister>;
      final int fetchedTotalRecords = response['totalRecords'] as int;
      final List<WorkOrderTableJson> workOrderCollection =
          response['work_order'] as List<WorkOrderTableJson>;

      emit(
        WorkOrderNewLoaded(
          tableHeaders: tableHeaders,
          assets: assets,
          totalRecords: fetchedTotalRecords,
          skip: assets.length,
          sortOrder: sortOrder,
          filterIndex: filterIndex,
          workOrderCollection: workOrderCollection,
        ),
      );
    } catch (e) {
      emit(WorkOrderError(e.toString()));
    }
  }

  FutureOr<void> _onLoadWorkOrder(
    LoadWorkOrder event,
    Emitter<DeviceSyncState> emit,
  ) async {
    emit(WorkOrderLoading());
    try {
      final response = await deviceSyncServices.fetchWorkOrderAssets();
      final String? userType = await authUtils.getUserType();

      List<String> tableHeaders = (userType == 'onshore')
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
              "Equipment Manufacturer",
              "Equipment Protection",
              "Inspection Faults",
              "Inspection Status",
              "Completed Repairs",
              "Existing Faults",
              "Current Status",
            ];
      final List<ExRegister> assets = response['assets'] as List<ExRegister>;
      final int fetchedTotalRecords = response['totalRecords'] as int;
      final List<WorkOrderTableJson> workOrderCollection =
          response['work_order'] as List<WorkOrderTableJson>;

      final prefs = await SharedPreferences.getInstance();
      final existingIds = prefs.getStringList('asset_ids') ?? [];
      // const encoder = JsonEncoder.withIndent('  ');
      final newIds = assets
          .map((e) => e.id.trim())
          // ignore: unnecessary_null_comparison
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();
      final mergedSet = {...existingIds, ...newIds};
      final mergedList = mergedSet.toList();

      await prefs.setStringList('asset_ids', mergedList);
      emit(
        WorkOrderLoaded(
          tableHeaders: tableHeaders,
          assets: assets,
          totalRecords: fetchedTotalRecords,
          skip: assets.length,
          sortOrder: sortOrder,
          filterIndex: filterIndex,
          workOrderCollection: workOrderCollection,
          isupdateAsset: true,
        ),
      );
    } catch (e) {
      emit(WorkOrderError("Error => ${e.toString()}"));
    }
  }

  FutureOr<void> sortLoadMoreWorkOrder(
    SortLoadMoreWorkOrder event,
    Emitter<DeviceSyncState> emit,
  ) async {
    emit(WorkOrderLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await sortLoadMoreWorkOrderByApi(event, emit);
      } else {
        await sortLoadMoreWorkOrderByOffline(event, emit);
      }
    } catch (e) {
      emit(WorkOrderError(e.toString()));
    }
  }

  FutureOr<void> sortLoadMoreWorkOrderByApi(
    SortLoadMoreWorkOrder event,
    Emitter<DeviceSyncState> emit,
  ) async {
    emit(WorkOrderLoading());
    try {
      skip = 0;
      sortOrder = event.sortOrder;
      sortField = event.sortField;
      event.sortOrder == "descending"
          ? filterIndex = event.columnIndex
          : filterIndex = null;
      skip = limit;
    } catch (e) {
      emit(WorkOrderError(e.toString()));
    }
  }

  FutureOr<void> resetLoadMoreWorkOrderFromOffline(
    ResetLoadMoreWorkOrder event,
    Emitter<DeviceSyncState> emit,
  ) async {
    emit(WorkOrderLoading());
    try {
      final String? userType = await authUtils.getUserType();
      List<ExRegister> assets = [];
      // final assets = await _fetchFilteredAssets(
      //   userType: userType,
      //   selectedFilters: event.collectionSelectedFilter,
      // );
      if (event.collectionSelectedFilter.isEmpty) {
        assets = event.registerCollections;
      } else {
        assets = event.registerCollections.where((asset) {
          // Check all filters, and ensure the asset satisfies *all* conditions
          return event.collectionSelectedFilter.entries.every((entry) {
            final field = entry.key;
            final selectedValues = entry.value;

            // If no filters for this field, treat as match
            if (selectedValues.isEmpty) return true;

            final status = _getStatus(asset, field);
            return selectedValues.contains(status);
          });
        }).toList();
      }

      emit(
        WorkOrderLoaded(
          tableHeaders: _getTableHeaders(userType),
          assets: assets,
          totalRecords: assets.length,
          skip: 0,
          sortOrder: '',
          isupdateAsset: false,
        ),
      );
    } catch (e) {
      emit(WorkOrderError(e.toString()));
    }
  }

  FutureOr<void> sortLoadMoreWorkOrderByOffline(
    SortLoadMoreWorkOrder event,
    Emitter<DeviceSyncState> emit,
  ) async {
    emit(WorkOrderLoading());
    try {
      sortOrder = event.sortOrder;
      sortField = event.sortField;
      filterIndex = sortOrder == "descending" ? event.columnIndex : null;

      final String? userType = await authUtils.getUserType();
      List<ExRegister> assets = [];
      // var assets = await _fetchFilteredAssets(
      //   userType: userType,
      //   selectedFilters: event.collectionSelectedFilter,
      // );
      if (event.collectionSelectedFilter.isEmpty) {
        assets = event.registerCollections;
      } else {
        assets = event.registerCollections.where((asset) {
          // Check all filters, and ensure the asset satisfies *all* conditions
          return event.collectionSelectedFilter.entries.every((entry) {
            final field = entry.key;
            final selectedValues = entry.value;

            // If no filters for this field, treat as match
            if (selectedValues.isEmpty) return true;

            final status = _getStatus(asset, field);
            return selectedValues.contains(status);
          });
        }).toList();
      }
      if (sortOrder.isNotEmpty) {
        assets = ExRegisterFunction.sortList(
          filteredList: assets,
          columnIndex: event.columnIndex,
          sortOrder: sortOrder,
        );
      }
      emit(
        WorkOrderLoaded(
          tableHeaders: _getTableHeaders(userType),
          assets: assets,
          totalRecords: assets.length,
          skip: 0,
          sortOrder: sortOrder,
          filterIndex: event.columnIndex,
          collectionSelectedFilter: event.collectionSelectedFilter,
          isupdateAsset: false,
        ),
      );
    } catch (e) {
      emit(WorkOrderError(e.toString()));
    }
  }

  // Future<List<ExRegister>> _fetchFilteredAssets({
  //   required String? userType,
  //   required Map<String, List<String>> selectedFilters,
  // }) async {
  //   final results = (userType == 'onshore')
  //       ? await _dbHelper.getExRegisterOnshore()
  //       : await _dbHelper.getExRegister();

  //   List<ExRegister> assets = results.map((map) {
  //     final dashboardJson = map['exregister_json'];
  //     final jsonMap = (dashboardJson is String)
  //         ? jsonDecode(dashboardJson)
  //         : dashboardJson as Map<String, dynamic>?;

  //     if (jsonMap == null) {
  //       throw FormatException(
  //           "Invalid type for exregister_json: ${dashboardJson.runtimeType}");
  //     }

  //     return ExRegister.fromJson(jsonMap['asset']);
  //   }).toList();

  //   // Apply filters
  //   assets = assets.where((asset) {
  //     return selectedFilters.entries.every((entry) {
  //       final field = entry.key;
  //       final selectedValues = entry.value;
  //       if (selectedValues.isEmpty) return true;

  //       final status = _getStatus(asset, field);
  //       return selectedValues.contains(status);
  //     });
  //   }).toList();
  //   return assets;
  // }

  String _getStatus(ExRegister asset, String sortField) {
    if (sortField == 'inspectionStatus') {
      return _resolveStatus(
        status: asset.inspectionStatus,
        fallback: _evaluateStatus(asset, isInspection: true),
      );
    } else if (sortField == 'currentStatus') {
      return _resolveStatus(
        status: asset.currentStatus,
        fallback: _evaluateStatus(asset, isInspection: false),
      );
    }

    String inspection = _resolveStatus(
      status: asset.inspectionStatus,
      fallback: _evaluateStatus(asset, isInspection: true),
    );

    if (inspection.isNotEmpty) return inspection;

    return _resolveStatus(
      status: asset.currentStatus,
      fallback: _evaluateStatus(asset, isInspection: false),
    );
  }

  String _resolveStatus({required String status, required String fallback}) {
    return status.isNotEmpty ? status : fallback;
  }

  String _evaluateStatus(ExRegister asset, {required bool isInspection}) {
    final hasRequiredFields =
        asset.inspectionGrade?.toString().isNotEmpty == true &&
            asset.inspectionType?.toString().isNotEmpty == true &&
            asset.inspectionChecklistType.isNotEmpty &&
            asset.equipmentEquipmentType?.toString().isNotEmpty == true;

    if (!hasRequiredFields) return '';

    final isCheckListEmpty =
        asset.checkList == null || asset.checkList!.isEmpty;

    if (isCheckListEmpty) return "Green";

    final priority =
        isInspection ? asset.inspectionPriority : asset.repairPriority;

    if (priority == null) return '';

    if (priority <= 2) return "Red";
    if (priority >= 3 && priority <= 5) return "Yellow";

    return '';
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
            "Discpline",
            "Equipment Tag Number",
            "Equipment Description",
            "Manufacutrer",
            "Equipment Protection",
            "Inspection Faults",
            "Inspection Status",
            "Completed Repairs",
            "Existing Faults",
            "Current Status",
          ];
  }
}
