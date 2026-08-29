import 'dart:async';
import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/data/services/dashboard_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardServices dashboardService;
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
  int offset = 0;

  DashboardBloc({required this.dashboardService, required this.authUtils})
      : super(DashboardInitial()) {
    on<YearToDateFilterDashboard>(yearToDateFilterDashboard);
    on<LocationFilterDashboard>(handleLocationFilterDashboard);
  }

  FutureOr<void> handleLocationFilterDashboard(
    LocationFilterDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';

      if (isApiFlag) {
        await handleLocationFilterDashboardFromApi(event, emit);
      } else {
        await handleLocationFilterDashboardFromOffline(event, emit);
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  FutureOr<void> yearToDateFilterDashboard(
    YearToDateFilterDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';

      if (isApiFlag) {
        await yearToDateFilterDashboardFromApi(event, emit);
      } else {
        await yearToDateFilterDashboardFromOffline(event, emit);
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  FutureOr<void> yearToDateFilterDashboardFromApi(
    YearToDateFilterDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      skip = 0;
      // final now = DateTime.now();
      // final currentYearStart = DateTime(now.year, 1, 1);
      // final currentYearEnd = DateTime(now.year, 12, 31);

      DateTime normalize(DateTime date) =>
          DateTime(date.year, date.month, date.day);

      final normalizedFromDate = normalize(event.fromDate!);
      final normalizedToDate = normalize(event.toDate!);

      fromDate = normalizedFromDate;
      // ?? currentYearStart;
      toDate = normalizedToDate;
      // ?? currentYearEnd;
      final response = await dashboardService.fetchAssets(
        limit: limit,
        skip: 0,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
      );
      final List<ExRegister> filteredList =
          response['assets'] as List<ExRegister>;

      emit(
        DashboardLoaded(
          assets: filteredList,
          totalRecords: filteredList.length,
          statusCounts: countStatus(filteredList),
          repairedChartCounts: _chartCountStatus(filteredList),
          equipmentCounts: event.isBefore
              ? _equipmentCountStatus(filteredList, useInspectionStatus: true)
              : _equipmentCountStatus(filteredList, useInspectionStatus: false),
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  FutureOr<void> yearToDateFilterDashboardFromOffline(
    YearToDateFilterDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      skip = 0;
      final now = DateTime.now();
      final from = event.fromDate ?? DateTime(now.year, 1, 1);
      final to = event.toDate ?? DateTime(now.year, 12, 31);
      final String? userType = await authUtils.getUserType();
      final results = (userType == 'onshore')
          ? await _dbHelper.getExRegisterOnshore()
          : await _dbHelper.getExRegister();

      final assets = results.map((map) {
        final json = map['exregister_json'];
        final parsed =
            (json is String) ? jsonDecode(json) : json as Map<String, dynamic>?;
        if (parsed == null) {
          throw FormatException("Invalid exregister_json: ${json.runtimeType}");
        }
        return ExRegisterTableModel(
          id: map['id'],
          exregisterJson: ExRegister.fromJson(parsed['asset']),
          createdBy: map['created_by'],
          updatedBy: map['updated_by'],
          createdDate: map['created_date'],
          updatedDate: map['updated_date'],
        );
      }).toList();
      DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

      final normalizedFromDate = normalize(from);
      final normalizedToDate = normalize(to);

      final filteredAssets = assets
          .where((asset) {
            // Step 1: Parse or cast updatedDate
            DateTime? assetDate;

            if (asset.updatedDate is String) {
              assetDate = DateTime.tryParse(asset.updatedDate);
            } else if (asset.updatedDate is DateTime) {
              assetDate = asset.updatedDate;
            }

            if (assetDate == null) {
              return false;
            }

            final normalizedAssetDate = normalize(assetDate);

            final isInRange =
                normalizedAssetDate.isAtSameMomentAs(normalizedFromDate) ||
                    (normalizedAssetDate.isAfter(normalizedFromDate) &&
                        normalizedAssetDate.isBefore(normalizedToDate)) ||
                    normalizedAssetDate.isAtSameMomentAs(normalizedToDate);

            if (!isInRange) {
              return false;
            }

            return true;
          })
          .map((asset) => asset.exregisterJson)
          .where((e) {
            final matched = event.selectedLocations.any(
              (loc) => e.location.toLowerCase().contains(loc.toLowerCase()),
            );
            if (!matched) {}

            return matched;
          })
          .toList();

      emit(
        DashboardLoaded(
          assets: filteredAssets,
          totalRecords: filteredAssets.length,
          statusCounts: countStatus(filteredAssets),
          repairedChartCounts: _chartCountStatus(filteredAssets),
          equipmentCounts: event.isBefore
              ? _equipmentCountStatus(filteredAssets, useInspectionStatus: true)
              : _equipmentCountStatus(
                  filteredAssets,
                  useInspectionStatus: false,
                ),
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  FutureOr<void> handleLocationFilterDashboardFromOffline(
    LocationFilterDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final String? userType = await authUtils.getUserType();
      final now = DateTime.now();
      final from = event.fromDate ?? DateTime(now.year, 1, 1);
      final to = event.toDate ?? DateTime(now.year, 12, 31);

      // final String? userType = await authUtils.getUserType();

      final results = (userType == 'onshore')
          ? await _dbHelper.getExRegisterOnshore()
          : await _dbHelper.getExRegister();

      final assets = results.map((map) {
        final json = map['exregister_json'];
        final parsed =
            (json is String) ? jsonDecode(json) : json as Map<String, dynamic>?;
        if (parsed == null) {
          throw FormatException("Invalid exregister_json: ${json.runtimeType}");
        }
        return ExRegisterTableModel(
          id: map['id'],
          exregisterJson: ExRegister.fromJson(parsed['asset']),
          createdBy: map['created_by'],
          updatedBy: map['updated_by'],
          createdDate: map['created_date'],
          updatedDate: map['updated_date'],
        );
      }).toList();
      DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

      final normalizedFromDate = normalize(from);
      final normalizedToDate = normalize(to);

      final filteredAssets = assets
          .where((asset) {
            // Step 1: Parse or cast updatedDate
            DateTime? assetDate;

            if (asset.updatedDate is String) {
              assetDate = DateTime.tryParse(asset.updatedDate);
            } else if (asset.updatedDate is DateTime) {
              assetDate = asset.updatedDate;
            }

            if (assetDate == null) {
              return false;
            }

            final normalizedAssetDate = normalize(assetDate);

            final isInRange =
                normalizedAssetDate.isAtSameMomentAs(normalizedFromDate) ||
                    (normalizedAssetDate.isAfter(normalizedFromDate) &&
                        normalizedAssetDate.isBefore(normalizedToDate)) ||
                    normalizedAssetDate.isAtSameMomentAs(normalizedToDate);

            if (!isInRange) {
              return false;
            }

            return true;
          })
          .map((asset) => asset.exregisterJson)
          .where((e) {
            final matched = event.selectedLocations.any(
              (loc) => e.location.toLowerCase().contains(loc.toLowerCase()),
            );

            if (!matched) {}

            return matched;
          })
          .toList();
      // final filteredAssets = assets
      //     .where((asset) {
      //       final date = DateTime.tryParse(asset.updatedDate.toString()) ??
      //           asset.updatedDate as DateTime?;
      //       if (date == null) return false;
      //       final d = DateTime(date.year, date.month, date.day);
      //       return !d.isBefore(from) && !d.isAfter(to);
      //     })
      //     .map((e) => e.exregisterJson)
      //     .where((e) => event.selectedLocations.any(
      //         (loc) => e.location.toLowerCase().contains(loc.toLowerCase())))
      //     .toList();
      emit(
        DashboardLoaded(
          assets: filteredAssets,
          totalRecords: filteredAssets.length,
          statusCounts: countStatus(filteredAssets),
          repairedChartCounts: _chartCountStatus(filteredAssets),
          equipmentCounts: event.isBefore
              ? _equipmentCountStatus(filteredAssets, useInspectionStatus: true)
              : _equipmentCountStatus(
                  filteredAssets,
                  useInspectionStatus: false,
                ),
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  FutureOr<void> handleLocationFilterDashboardFromApi(
    LocationFilterDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      skip = 0;
      final now = DateTime.now();
      final currentYearStart = DateTime(now.year, 1, 1);
      final currentYearEnd = DateTime(now.year, 12, 31);

      fromDate = event.fromDate ?? currentYearStart;
      toDate = event.toDate ?? currentYearEnd;
      final response = await dashboardService.fetchAssets(
        limit: limit,
        skip: 0,
        type: type,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      final List<ExRegister> assets = response['assets'] as List<ExRegister>;

      emit(
        DashboardLoaded(
          assets: assets,
          totalRecords: assets.length,
          statusCounts: countStatus(assets),
          repairedChartCounts: _chartCountStatus(assets),
          equipmentCounts: event.isBefore
              ? _equipmentCountStatus(assets, useInspectionStatus: true)
              : _equipmentCountStatus(assets, useInspectionStatus: false),
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Map<String, int> _chartCountStatus(List<ExRegister> list) {
    return {
      "redToGreen": list
          .where(
            (e) => e.inspectionStatus == "Red" && e.currentStatus == "Green",
          )
          .length,
      "yellowToGreen": list
          .where(
            (e) => e.inspectionStatus == "Yellow" && e.currentStatus == "Green",
          )
          .length,
      "redToYellow": list
          .where(
            (e) => e.inspectionStatus == "Red" && e.currentStatus == "Yellow",
          )
          .length,
      "total": list
          .where(
            (e) => e.inspectionStatus.isNotEmpty && e.checkList!.isNotEmpty,
          )
          .length,
    };
  }

  Map<String, int> _equipmentCountStatus(
    List<ExRegister> list, {
    required bool useInspectionStatus,
  }) {
    // final statusSelector = useInspectionStatus
    //     ? (ExRegister e) => e.inspectionStatus
    //     : (ExRegister e) => e.currentStatus;
    if (useInspectionStatus) {
      final filtered = list.where(
        (e) =>
            e.inspectionStatus.isNotEmpty &&
            e.inspectedBy != null &&
            e.inspectedBy.toString().trim().isNotEmpty &&
            e.inspectedDate != null &&
            e.inspectedDate.toString().trim().isNotEmpty,
      );

      return {
        "redTags": filtered.where((e) => e.inspectionStatus == "Red").length,
        "yellowTags":
            filtered.where((e) => e.inspectionStatus == "Yellow").length,
        "greenTags":
            filtered.where((e) => e.inspectionStatus == "Green").length,
        "total": filtered.length,
      };
    } else {
      final filtered = list.where((e) {
        return e.currentStatus.toString().isNotEmpty &&
                (e.checkList?.isNotEmpty ?? false) ||
            e.currentStatus.toString().isNotEmpty &&
                (e.checkList?.isEmpty ?? true);
      }).toList();

      return {
        "redTags": filtered.where((e) => e.currentStatus == "Red").length,
        "yellowTags": filtered.where((e) => e.currentStatus == "Yellow").length,
        "greenTags": filtered.where((e) => e.currentStatus == "Green").length,
        "total": filtered.length,
      };
    }
  }

  Map<String, int> countStatus(List<ExRegister> list) {
    return {
      "unInspected": list
          .where(
            (e) =>
                // e.inspectionStatus.toString().isEmpty &&
                (e.inspectionPriority == null ||
                    e.inspectionPriority == 0 ||
                    e.inspectionPriority != 0) &&
                // ((e.inspectionType.toString().isEmpty &&
                //         e.inspectionChecklistType.isEmpty &&
                //         e.equipmentEquipmentType.toString().isEmpty &&
                //         e.inspectionGrade.toString().isEmpty) ||
                //     (e.inspectionType.toString().isNotEmpty &&
                //         e.inspectionChecklistType.isNotEmpty &&
                //         e.equipmentEquipmentType.toString().isNotEmpty &&
                //         e.inspectionGrade.toString().isNotEmpty)) &&
                // (e.checkList != null || e.checkList!.isNotEmpty) &&
                // (e.checkList == null || e.checkList!.isEmpty) &&
                (e.inspectedBy.toString().isEmpty ||
                    e.inspectedBy == null ||
                    e.inspectedBy == "null") &&
                (e.inspectedDate == null ||
                    e.inspectedDate.toString().isEmpty ||
                    e.inspectedDate == "null"),
          )
          .length,
      "inspected": list
          .where(
            (e) =>
                e.inspectionStatus.isNotEmpty &&
                (e.inspectedDate.toString().isNotEmpty) &&
                (e.inspectedBy.toString().isNotEmpty) &&
                (e.inspectionPriority != null || e.inspectionPriority != 0) &&
                e.inspectionType.toString().isNotEmpty &&
                e.inspectionChecklistType.isNotEmpty &&
                e.equipmentEquipmentType.toString().isNotEmpty &&
                e.inspectionGrade.toString().isNotEmpty,
          )
          .length,
      "partiallyRepaired": list.where((e) {
        String faultsRaw = e.existingFaults.toString().trim() == ''
            ? "0"
            : e.existingFaults.toString();
        String repairsRaw = e.repairsDone.toString().trim() == ''
            ? "0"
            : e.repairsDone.toString();

        int existingFaults = int.tryParse(faultsRaw) ?? 0;
        int repairsDone = int.tryParse(repairsRaw) ?? 0;

        if (existingFaults > 0 && repairsDone > 0) {
          return true;
        } else {
          return false;
        }
      }).length,
      "completelyRepaired": list
          .where((e) =>
              e.currentStatus == "Green" &&
                  (e.checkList?.isNotEmpty ?? false) ||
              e.currentStatus == "Green" && (e.checkList?.isEmpty ?? true))
          .length,
      "pendingRepaired": list.where((e) {
        final status = e.currentStatus.toString();
        // .isEmpty ? 'Red' : e.currentStatus;
        final priority = e.inspectionPriority;

        if (["Red", "Yellow"].contains(status)) {
          return true;
        }

        if (priority != null) {
          if (priority <= 2) return status == "Red";
          if (priority <= 5) return status == "Yellow";
        }
        return false;
      }).length,
    };
  }
}
