import 'dart:async';

import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_function.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceSyncBloc extends Bloc<DeviceSyncEvent, DeviceSyncState> {
  final DeviceSyncServices deviceSyncServices;
  final DBHelper _dbHelper;
  final AuthUtils authUtils;

  int skip = 0;
  final int limit = 30;
  String sortField = 'updatedAt';
  String sortOrder = 'descending';
  int? filterIndex;
  String? type;
  DateTime? fromDate;
  DateTime? toDate;

  DeviceSyncBloc({
    required this.deviceSyncServices,
    required this.authUtils,
    DBHelper? dbHelper,
  })  : _dbHelper = dbHelper ?? DBHelper(),
        super(WorkOrderInitial()) {
    on<LoadWorkOrder>(_onLoadWorkOrder);
    on<LoadNewWorkOrder>(_onLoadNewWorkOrder);
    on<SortLoadMoreWorkOrder>(sortLoadMoreWorkOrder);
    on<ResetLoadMoreWorkOrder>(resetLoadMoreWorkOrderFromOffline);
    on<RemoveTransferredAssetsFromDeviceSync>(_onRemoveTransferredAssets);
  }

  FutureOr<void> _onRemoveTransferredAssets(
    RemoveTransferredAssetsFromDeviceSync event,
    Emitter<DeviceSyncState> emit,
  ) async {
    if (state is WorkOrderLoaded) {
      final current = state as WorkOrderLoaded;
      final transferredSet =
          event.transferredAssetIds.map((e) => e.trim()).toSet();

      final updatedAssets = current.assets
          .where((asset) => !transferredSet.contains(asset.id.trim()))
          .toList();

      final updatedWorkOrders = current.workOrderCollection.map((wo) {
        final filteredAssets = wo.assets
            .where((asset) => !transferredSet.contains(asset.id.trim()))
            .toList();
        wo.assets = filteredAssets;
        return wo;
      }).where((wo) => wo.assets.isNotEmpty).toList();

      final prefs = await SharedPreferences.getInstance();
      final untransferredIds = updatedAssets
          .map((e) => e.id.trim())
          .where((id) => id.isNotEmpty)
          .toList();
      await prefs.setStringList('asset_ids', untransferredIds);

      emit(
        WorkOrderLoaded(
          tableHeaders: current.tableHeaders,
          assets: updatedAssets,
          totalRecords: updatedAssets.length,
          skip: updatedAssets.length,
          sortOrder: current.sortOrder,
          filterIndex: current.filterIndex,
          workOrderCollection: updatedWorkOrders,
          isupdateAsset: true,
        ),
      );
    }
  }

  FutureOr<void> _onLoadNewWorkOrder(
    LoadNewWorkOrder event,
    Emitter<DeviceSyncState> emit,
  ) async {
    emit(WorkOrderLoading());
    try {
      final String? userId = await authUtils.getUserId();
      final String? userType = await authUtils.getUserType();
      dynamic userDetails;
      try {
        if (userId != null && userId.isNotEmpty) {
          userDetails = await _dbHelper.getLoggedInUserByUserId(userId);
        }
        userDetails ??= await _dbHelper.getLoggedInUser();
      } catch (_) {}
      final String? userName =
          userDetails?.userName ?? await authUtils.getUsername();
      final String? email = userDetails?.email;
      final String? firstName = userDetails?.firstName;
      final String? lastName = userDetails?.lastName;

      final response =
          await deviceSyncServices.fetchWorkOrderAssets(userId: userId);
      final List<String> tableHeaders = _getTableHeaders(userType);
      final List<ExRegister> rawAssets = response['assets'] as List<ExRegister>;
      final List<WorkOrderTableJson> rawWorkOrderCollection =
          response['work_order'] as List<WorkOrderTableJson>;

      final userFilteredData = _filterDataForUser(
        assets: rawAssets,
        workOrders: rawWorkOrderCollection,
        userId: userId ?? '',
        userType: userType,
        userName: userName,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      // Deduplicate assets by ID (same asset may appear in multiple work orders)
      final List<ExRegister> userAssets = _deduplicateAssets(userFilteredData.assets);
      final List<WorkOrderTableJson> userWorkOrders =
          userFilteredData.workOrders;

      Set<String> localAssetIds = {};
      try {
        localAssetIds = await _dbHelper.getLocalAssetIds(
          userType: userType,
          userId: userId, // Per-user filtering: only exclude THIS user's transferred assets
        );
      } catch (_) {}

      final untransferredAssets = userAssets.where((asset) {
        final id = asset.id.trim();
        return id.isNotEmpty && !localAssetIds.contains(id);
      }).toList();

      final untransferredWorkOrders = userWorkOrders.map((wo) {
        final filteredAssets = wo.assets.where((asset) {
          final id = asset.id.trim();
          return id.isNotEmpty && !localAssetIds.contains(id);
        }).toList();
        wo.assets = filteredAssets;
        return wo;
      }).where((wo) => wo.assets.isNotEmpty).toList();

      emit(
        WorkOrderNewLoaded(
          tableHeaders: tableHeaders,
          assets: untransferredAssets,
          totalRecords: untransferredAssets.length,
          skip: untransferredAssets.length,
          sortOrder: sortOrder,
          filterIndex: filterIndex,
          workOrderCollection: untransferredWorkOrders,
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
      final String? userId = await authUtils.getUserId();
      final String? userType = await authUtils.getUserType();
      dynamic userDetails;
      try {
        if (userId != null && userId.isNotEmpty) {
          userDetails = await _dbHelper.getLoggedInUserByUserId(userId);
        }
        userDetails ??= await _dbHelper.getLoggedInUser();
      } catch (_) {}
      final String? userName =
          userDetails?.userName ?? await authUtils.getUsername();
      final String? email = userDetails?.email;
      final String? firstName = userDetails?.firstName;
      final String? lastName = userDetails?.lastName;

      final response =
          await deviceSyncServices.fetchWorkOrderAssets(userId: userId);
      final List<String> tableHeaders = _getTableHeaders(userType);
      final List<ExRegister> rawAssets = response['assets'] as List<ExRegister>;
      final List<WorkOrderTableJson> rawWorkOrderCollection =
          response['work_order'] as List<WorkOrderTableJson>;

      final userFilteredData = _filterDataForUser(
        assets: rawAssets,
        workOrders: rawWorkOrderCollection,
        userId: userId ?? '',
        userType: userType,
        userName: userName,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      // Deduplicate assets by ID (same asset may appear in multiple work orders)
      final List<ExRegister> userAssets = _deduplicateAssets(userFilteredData.assets);
      final List<WorkOrderTableJson> userWorkOrders =
          userFilteredData.workOrders;

      Set<String> localAssetIds = {};
      try {
        localAssetIds = await _dbHelper.getLocalAssetIds(
          userType: userType,
          userId: userId, // Per-user filtering: only exclude THIS user's transferred assets
        );
      } catch (_) {}

      final untransferredAssets = userAssets.where((asset) {
        final id = asset.id.trim();
        return id.isNotEmpty && !localAssetIds.contains(id);
      }).toList();


      final untransferredWorkOrders = userWorkOrders.map((wo) {
        final filteredAssets = wo.assets.where((asset) {
          final id = asset.id.trim();
          return id.isNotEmpty && !localAssetIds.contains(id);
        }).toList();
        wo.assets = filteredAssets;
        return wo;
      }).where((wo) => wo.assets.isNotEmpty).toList();

      final prefs = await SharedPreferences.getInstance();
      final untransferredIds = untransferredAssets
          .map((e) => e.id.trim())
          .where((id) => id.isNotEmpty)
          .toList();

      await prefs.setStringList('asset_ids', untransferredIds);
      emit(
        WorkOrderLoaded(
          tableHeaders: tableHeaders,
          assets: untransferredAssets,
          totalRecords: untransferredAssets.length,
          skip: untransferredAssets.length,
          sortOrder: sortOrder,
          filterIndex: filterIndex,
          workOrderCollection: untransferredWorkOrders,
          isupdateAsset: true,
        ),
      );
    } catch (e) {
      emit(WorkOrderError("Error => ${e.toString()}"));
    }
  }

  _UserFilteredResult _filterDataForUser({
    required List<ExRegister> assets,
    required List<WorkOrderTableJson> workOrders,
    required String userId,
    String? userType,
    String? userName,
    String? email,
    String? firstName,
    String? lastName,
  }) {
    final bool isOffshore = (userType?.toLowerCase() == 'offshore');
    if (userId.trim().isEmpty) {
      return _UserFilteredResult(assets: assets, workOrders: workOrders);
    }

    final Set<String> targetIds = {
      userId.trim().toLowerCase(),
      if (userName != null && userName.trim().isNotEmpty)
        userName.trim().toLowerCase(),
      if (email != null && email.trim().isNotEmpty)
        email.trim().toLowerCase(),
      if (firstName != null &&
          firstName.trim().isNotEmpty &&
          lastName != null &&
          lastName.trim().isNotEmpty)
        '$firstName $lastName'.trim().toLowerCase(),
      if (firstName != null && firstName.trim().isNotEmpty)
        firstName.trim().toLowerCase(),
    };

    bool isTargetUser(dynamic value) {
      if (value == null) return false;
      if (value is String) {
        final v = value.trim().toLowerCase();
        if (v.isEmpty || v == 'null') return false;
        if (targetIds.contains(v)) return true;
        if (v.contains(',')) {
          final parts =
              v.split(',').map((e) => e.trim().toLowerCase()).toSet();
          if (parts.any((p) => targetIds.contains(p))) return true;
        }
      } else if (value is num) {
        if (targetIds.contains(value.toString())) return true;
      } else if (value is List) {
        for (var item in value) {
          if (isTargetUser(item)) return true;
        }
      } else if (value is Map) {
        final idCandidate = value['_id'] ??
            value['userId'] ??
            value['id'] ??
            value['user_id'] ??
            value['userName'] ??
            value['username'] ??
            value['email'] ??
            value['name'];
        if (isTargetUser(idCandidate)) return true;
      }
      return false;
    }

    bool isWorkOrderAssigned(WorkOrderTableJson wo) {
      if (isOffshore) {
        // In offshore, if work order is assigned to target user OR is unassigned / open
        final assignedToStr = wo.assignedTo?.toString().trim();
        final isUnassigned = assignedToStr == null ||
            assignedToStr.isEmpty ||
            assignedToStr.toLowerCase() == 'null';
        if (isUnassigned) return true;
      }
      return isTargetUser(wo.assigendTeam) ||
          isTargetUser(wo.assignedTo) ||
          isTargetUser(wo.userId) ||
          isTargetUser(wo.assignedUserId) ||
          isTargetUser(wo.inspectorId) ||
          isTargetUser(wo.custodian) ||
          isTargetUser(wo.createdBy) ||
          isTargetUser(wo.issuedBy) ||
          isTargetUser(wo.uploadedBy);
    }

    bool isAssetAssigned(ExRegister asset) {
      return isTargetUser(asset.assignedTo) ||
          isTargetUser(asset.assignedUserId) ||
          isTargetUser(asset.userId) ||
          isTargetUser(asset.inspectedId) ||
          isTargetUser(asset.inspectedBy) ||
          isTargetUser(asset.inspectorId) ||
          isTargetUser(asset.assignedTeam) ||
          isTargetUser(asset.createdBy);
    }

    final hasAnyAssignment = workOrders.any((wo) =>
        (wo.assigendTeam != null &&
            wo.assigendTeam.toString().isNotEmpty &&
            wo.assigendTeam.toString() != 'null') ||
        (wo.assignedTo != null &&
            wo.assignedTo.toString().isNotEmpty &&
            wo.assignedTo.toString() != 'null') ||
        (wo.userId != null &&
            wo.userId.toString().isNotEmpty &&
            wo.userId.toString() != 'null') ||
        (wo.assignedUserId != null &&
            wo.assignedUserId.toString().isNotEmpty &&
            wo.assignedUserId.toString() != 'null') ||
        (wo.inspectorId != null &&
            wo.inspectorId.toString().isNotEmpty &&
            wo.inspectorId.toString() != 'null') ||
        (wo.custodian != null &&
            wo.custodian.toString().isNotEmpty &&
            wo.custodian.toString() != 'null')
    ) || assets.any((a) =>
        (a.assignedTo != null &&
            a.assignedTo.toString().isNotEmpty &&
            a.assignedTo.toString() != 'null') ||
        (a.assignedUserId != null &&
            a.assignedUserId.toString().isNotEmpty &&
            a.assignedUserId.toString() != 'null') ||
        (a.userId != null &&
            a.userId.toString().isNotEmpty &&
            a.userId.toString() != 'null') ||
        (a.inspectedId != null &&
            a.inspectedId.toString().isNotEmpty &&
            a.inspectedId.toString() != 'null') ||
        (a.assignedTeam != null &&
            a.assignedTeam.toString().isNotEmpty &&
            a.assignedTeam.toString() != 'null')
    );

    if (!hasAnyAssignment && !isOffshore) {
      return _UserFilteredResult(assets: assets, workOrders: workOrders);
    }

    final List<WorkOrderTableJson> filteredWorkOrders = [];
    final Set<String> assignedAssetIds = {};
    final List<ExRegister> filteredAssets = [];

    for (final wo in workOrders) {
      final woMatches = isWorkOrderAssigned(wo);
      if (woMatches || isOffshore) {
        filteredWorkOrders.add(wo);
        for (final asset in wo.assets) {
          assignedAssetIds.add(asset.id);
          filteredAssets.add(asset);
        }
      } else {
        final matchingWoAssets =
            wo.assets.where((asset) => isAssetAssigned(asset)).toList();
        if (matchingWoAssets.isNotEmpty) {
          wo.assets = matchingWoAssets;
          filteredWorkOrders.add(wo);
          for (final asset in matchingWoAssets) {
            assignedAssetIds.add(asset.id);
            filteredAssets.add(asset);
          }
        }
      }
    }

    for (final asset in assets) {
      if (!assignedAssetIds.contains(asset.id)) {
        if (isOffshore || isAssetAssigned(asset)) {
          assignedAssetIds.add(asset.id);
          filteredAssets.add(asset);
        }
      }
    }

    if (filteredAssets.isEmpty && assets.isNotEmpty) {
      return _UserFilteredResult(
        assets: assets,
        workOrders: workOrders,
      );
    }

    return _UserFilteredResult(
      assets: filteredAssets,
      workOrders: filteredWorkOrders,
    );
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
    final bool isOnshore = (userType?.toLowerCase() == 'onshore');
    return isOnshore
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
  }

  /// Deduplicates a list of assets by their ID.
  /// When the same asset appears in multiple work orders, only the first
  /// occurrence is kept (preserving the order they come in).
  List<ExRegister> _deduplicateAssets(List<ExRegister> assets) {
    final seen = <String>{};
    final result = <ExRegister>[];
    for (final asset in assets) {
      final id = asset.id.trim();
      if (id.isNotEmpty && !seen.contains(id)) {
        seen.add(id);
        result.add(asset);
      } else if (id.isEmpty) {
        // Keep assets without an ID (edge case)
        result.add(asset);
      }
    }
    return result;
  }
}

class _UserFilteredResult {
  final List<ExRegister> assets;
  final List<WorkOrderTableJson> workOrders;

  _UserFilteredResult({
    required this.assets,
    required this.workOrders,
  });
}

