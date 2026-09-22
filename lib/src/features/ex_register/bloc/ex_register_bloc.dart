// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/ex_register_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_function.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/services/ex_register_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../utils/excel_functions.dart';
import '../../../utils/pdf_functions.dart';
import '../../../utils/generate_itr_functions.dart';
import '../../ex_inspections/data/repository/inspection_checklist_repo.dart';
import '../data/assets_duplicate.dart';
import '../data/models/ex_register_table_model.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ExRegisterBloc extends Bloc<ExRegisterEvent, ExRegisterState> {
  final ExRegisterService exRegisterService;
  final DBHelper _dbHelper = DBHelper();
  final ExregisterRepo _exregisterRepo = ExregisterRepo();
  final AuthUtils authUtils;
  int skip = 0;
  int offset = 0;
  final int limit = 30;
  bool hasMoreData = true;
  final int loadMoreLimit = 30;
  String sortField = 'updatedAt';
  String sortOrder = 'descending';
  int? filterIndex;
  String? type;
  DateTime? fromDate;
  DateTime? toDate;
  Map<String, dynamic>? _checklistData;
  Map<String, dynamic>? _originalChecklistData;
  final InspectionChecklistRepo checklistRepo;

  ExRegisterBloc({
    required this.exRegisterService,
    required this.authUtils,
    required this.checklistRepo,
  }) : super(ExRegisterInitial()) {
    on<ResetExRegisterState>((event, emit) {
      emit(ExRegisterInitial());
    });
    on<LoadExRegister>(loadExRegister);
    on<InitLoadExRegister>(initLoadExRegister);
    on<LoadMoreExRegister>(loadMoreExRegister);
    on<SortExRegister>(sortExRegister);
    on<ResetFilterExRegister>(resetFilterExRegisterFromOffline);
    on<ShowAllFilterExRegister>(showAllFilterExRegister);
    on<YearToDateFilterExRegister>(yearToDateFilterExRegister);
    on<ExRegisterDownload>(exRegisterDownload);
    on<ExRegisterRowSelected>(exRegisterRowSelected);
    on<ExRegisterInitEvent>(exRegisterInitEvent);
    on<ExRegisterDuplicateOrDelete>(exRegisterDuplicateOrDelete);
    on<ExRegisterGenerateItr>(exRegisterGenerateItr);
    on<UpdateExRegisterAfterChange>(updateExRegisterAfterChange);
  }

  FutureOr<void> exRegisterInitEvent(
    ExRegisterInitEvent event,
    Emitter<ExRegisterState> emit,
  ) async {
    skip = 0;
    offset = 0;
    sortField = 'updatedAt';
    sortOrder = 'descending';
    filterIndex = null;
    type = null;
    fromDate = null;
    toDate = null;
    emit(ExRegisterInitial());
  }

  FutureOr<void> exRegisterRowSelected(
    ExRegisterRowSelected event,
    Emitter<ExRegisterState> emit,
  ) async {
    if (event.showIcon == false) {
      bool showIcon;
      event.selectedAssets.isNotEmpty
          ? showIcon = event.showIcon
          : showIcon = event.showIcon;
      emit(
        ShowExRegisterMoreOption(
          showIcon: showIcon,
          selectedAssets: event.selectedAssets,
        ),
      );
    } else {
      bool showIcon = true;
      event.selectedAssets.isNotEmpty ? showIcon = true : showIcon = false;
      emit(
        ShowExRegisterMoreOption(
          showIcon: showIcon,
          selectedAssets: event.selectedAssets,
        ),
      );
    }
  }

  FutureOr<void> loadExRegister(
    LoadExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await loadExRegisterFromApi(event, emit);
      } else {
        await loadExRegisterFromOffline(event, emit);
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> loadExRegisterFromApi(
    LoadExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
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
      final List<String> tableHeaders =
          response['tableHeaders'] as List<String>;
      final List<ExRegister> assets = response['assets'] as List<ExRegister>;
      final int totalRecords = response['totalRecords'] as int;
      skip += assets.length;
      emit(ShowExRegisterMoreOption(showIcon: false, selectedAssets: const []));
      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: tableHeaders,
          assets: assets,
          totalRecords: totalRecords,
          isLoadMore: false,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: skip,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> initLoadExRegister(
    InitLoadExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await initloadExRegisterFromApi(event, emit);
      } else {
        await initloadExRegisterFromOffline(event, emit);
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> initloadExRegisterFromApi(
    InitLoadExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
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
      final List<String> tableHeaders =
          response['tableHeaders'] as List<String>;
      final List<ExRegister> assets = response['assets'] as List<ExRegister>;
      final int totalRecords = response['totalRecords'] as int;
      skip += assets.length;
      emit(ShowExRegisterMoreOption(showIcon: false, selectedAssets: const []));
      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: tableHeaders,
          assets: assets,
          totalRecords: totalRecords,
          isLoadMore: false,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: skip,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> loadMoreExRegister(
    LoadMoreExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    // emit(ExRegisterLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await loadMoreExRegisterFromApi(event, emit);
      } else {
        await loadMoreExRegisterFromOffline(event, emit);
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> loadMoreExRegisterFromApi(
    LoadMoreExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    try {
      final newSkip = event.assets.length;
      skip = newSkip;
      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: event.tableHeaders,
          assets: event.assets,
          totalRecords: event.totalRecords,
          isLoadMore: true,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: newSkip,
        ),
      );
      final response = await exRegisterService.fetchAssets(
        limit: limit,
        skip: newSkip,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
        sortField: sortField,
        sortOrder: sortOrder,
      );
      final List<String> tableHeaders =
          response['tableHeaders'] as List<String>;
      final List<ExRegister> assets = response['assets'] as List<ExRegister>;
      final int totalRecords = response['totalRecords'] as int;
      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: tableHeaders,
          assets: event.assets + assets,
          totalRecords: totalRecords,
          isLoadMore: false,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: newSkip,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> showAllFilterExRegister(
    ShowAllFilterExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await showAllFilterExRegisterFromApi(event, emit);
      } else {
        await showAllFilterExRegisterFromOffline(event, emit);
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> showAllFilterExRegisterFromApi(
    ShowAllFilterExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      skip = 0;
      type = event.type;

      final response = await exRegisterService.fetchAssets(
        limit: limit,
        skip: 0,
        type: event.type,
        fromDate: fromDate,
        toDate: toDate,
        sortField: sortField,
        sortOrder: sortOrder,
      );
      final List<String> tableHeaders =
          response['tableHeaders'] as List<String>;
      final List<ExRegister> assets = response['assets'] as List<ExRegister>;
      final int totalRecords = response['totalRecords'] as int;
      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: tableHeaders,
          assets: assets,
          totalRecords: totalRecords,
          isLoadMore: false,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: 0,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> yearToDateFilterExRegister(
    YearToDateFilterExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await yearToDateFilterExRegisterFromApi(event, emit);
      } else {
        await yearToDateFilterExRegisterFromOffline(event, emit);
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> yearToDateFilterExRegisterFromApi(
    YearToDateFilterExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      skip = 0;
      fromDate = event.fromDate;
      toDate = event.toDate;

      final response = !event.isReset
          ? await exRegisterService.fetchAssets(
              limit: limit,
              skip: 0,
              type: type,
              fromDate: event.fromDate,
              toDate: event.toDate,
              sortField: sortField,
              sortOrder: sortOrder,
            )
          : await exRegisterService.fetchAssets(
              limit: limit,
              skip: 0,
              type: type,
              sortField: sortField,
              sortOrder: sortOrder,
            );
      final List<String> tableHeaders =
          response['tableHeaders'] as List<String>;
      final List<ExRegister> assets = response['assets'] as List<ExRegister>;
      final int totalRecords = response['totalRecords'] as int;
      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: tableHeaders,
          assets: assets,
          totalRecords: totalRecords,
          isLoadMore: false,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: 0,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> sortExRegister(
    SortExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await sortExRegisterByApi(event, emit);
      } else {
        await sortExRegisterByOffline(event, emit);
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> sortExRegisterByApi(
    SortExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      skip = 0;
      sortOrder = event.sortOrder;
      sortField = event.sortField;
      event.sortOrder == "descending"
          ? filterIndex = event.columnIndex
          : filterIndex = null;
      final response = await exRegisterService.fetchAssets(
        limit: limit,
        skip: 0,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
        sortField: sortField,
        sortOrder: sortOrder,
      );
      final List<String> tableHeaders =
          response['tableHeaders'] as List<String>;
      final List<ExRegister> assets = response['assets'] as List<ExRegister>;
      final int totalRecords = response['totalRecords'] as int;
      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: tableHeaders,
          assets: assets,
          totalRecords: totalRecords,
          filterIndex: filterIndex,
          skip: 0,
          sortOrder: sortOrder,
        ),
      );
      skip = limit;
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> exRegisterDownload(
    ExRegisterDownload event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterDownloadLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await exRegisterDownloadFromApi(event, emit);
      } else {
        await exRegisterDownloadFromOffline(event, emit);
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> exRegisterDownloadFromApi(
    ExRegisterDownload event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterDownloadLoading());
    try {
      ExcelFunctions excelFunctions = ExcelFunctions();
      PdfGenerator pdfFunctions = PdfGenerator();
      List<ExRegister> assets = [];
      if (event.assetIds.isNotEmpty) {
        for (String assetId in event.assetIds) {
          final response = await exRegisterService.fetchAssetById(
            assetId: assetId,
          );
          if (response['status'] == true) {
            final assetDetails = response['data']['assetDetails'];
            ExRegister collection = ExRegister.fromJson(assetDetails);
            assets.add(collection);
          }
        }
      } else {
        final response = await exRegisterService.fetchAssets(
          skip: 0,
          type: type,
          fromDate: fromDate,
          toDate: toDate,
          sortField: sortField,
          sortOrder: sortOrder,
          limit: 100,
        );
        assets = response['assets'] as List<ExRegister>;
      }
      Map<String, dynamic> downloadResponse = {};
      event.fileType == "excel"
          ? downloadResponse = await excelFunctions.downloadAssetExcel(assets)
          : downloadResponse = await pdfFunctions.downloadAssetPdf(assets);
      emit(
        ExRegisterDownloadSuccess(
          message: 'File Downloaded to ${downloadResponse['location']}',
          location: downloadResponse['location'],
        ),
      );
    } catch (e) {
      emit(
        ExRegisterDownloadError(
          message: 'Getting some error while download a File!!',
        ),
      );
    }
  }

  FutureOr<void> exRegisterDownloadFromOffline(
    ExRegisterDownload event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterDownloadLoading());
    try {
      ExcelFunctions excelFunctions = ExcelFunctions();
      PdfGenerator pdfFunctions = PdfGenerator();
      List<ExRegister> assets = [];
      final String? userType = await authUtils.getUserType();

      final now = DateTime.now();
      fromDate = event.fromDate ?? DateTime(now.year, 1, 1);
      toDate = event.toDate ?? DateTime(now.year, 12, 31);

      // If specific asset IDs are selected
      if (event.assetIds.isNotEmpty) {
        for (String assetId in event.assetIds) {
          try {
            final exRegisterData = (userType == 'onshore')
                ? await _dbHelper.getExRegisterByIdOnshore(assetId)
                : await _dbHelper.getExRegisterById(assetId);

            if (exRegisterData == null) {
              continue;
            }

            final rawJson = exRegisterData['exregister_json'];
            if (rawJson == null || rawJson.toString().isEmpty) {
              continue;
            }

            final exRegisterJson = (rawJson is String)
                ? jsonDecode(rawJson)
                : rawJson as Map<String, dynamic>;

            if (!exRegisterJson.containsKey('asset')) {
              continue;
            }

            final dynamic assetData = exRegisterJson['asset'];
            if (assetData is List) {
              for (var locationJson in assetData) {
                try {
                  ExRegister location = ExRegister.fromJson(locationJson);
                  assets.add(location);
                } catch (e) {}
              }
            } else if (assetData is Map<String, dynamic>) {
              try {
                ExRegister asset = ExRegister.fromJson(assetData);
                assets.add(asset);
              } catch (e) {}
            }
          } catch (e) {}
        }
      }
      // If no specific asset IDs, load all
      else {
        final exRegisterList = (userType == 'onshore')
            ? await _dbHelper.getExRegisterOnshore()
            : await _dbHelper.getExRegister();

        final allAssets = exRegisterList.map((map) {
          final dashboardJson = map['exregister_json'];
          final jsonMap = (dashboardJson is String)
              ? jsonDecode(dashboardJson)
              : dashboardJson as Map<String, dynamic>?;

          if (jsonMap == null) {
            throw FormatException(
              "Invalid type for exregister_json: ${dashboardJson.runtimeType}",
            );
          }

          return ExRegisterTableModel(
            id: map['id'],
            exregisterJson: ExRegister.fromJson(jsonMap['asset']),
            createdBy: map['created_by'],
            updatedBy: map['updated_by'],
            createdDate: map['created_date'],
            updatedDate: map['updated_date'],
          );
        }).toList();

        if (allAssets.isEmpty) {
          assets = [];
        } else {
          // Sort assets by updated and created date
          allAssets.sort((a, b) {
            final createdDateA =
                DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
            final createdDateB =
                DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
            final updatedDateA =
                DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
            final updatedDateB =
                DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

            final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
            return updatedDateComparison != 0
                ? updatedDateComparison
                : createdDateB.compareTo(createdDateA);
          });

          // Apply filters
          DateTime normalize(DateTime date) =>
              DateTime(date.year, date.month, date.day);
          final normalizedFromDate = normalize(fromDate!);
          final normalizedToDate = normalize(toDate!);

          List<ExRegister> filteredList = [];
          filteredList = _applyDateFilter(
            allAssets,
            normalizedFromDate,
            normalizedToDate,
            event.type ?? "",
          );

          final combinedFilteredList = _applyShowAllFilter(
            filteredList,
            event.showAllFilterType,
          );
          final filteredExRegister = _filterExRegister(
            combinedFilteredList,
            event.searchQuery,
          );
          assets = filteredExRegister;
        }
      }

      // Final check
      if (assets.isEmpty) {
        throw Exception("No valid assets found for download.");
      }

      // Generate Excel or PDF
      Map<String, dynamic> downloadResponse = {};
      if (event.fileType == "excel") {
        downloadResponse = await excelFunctions.downloadAssetExcel(assets);
      } else {
        downloadResponse = await pdfFunctions.downloadAssetPdf(assets);
      }

      emit(
        ExRegisterDownloadSuccess(
          message: 'File Downloaded to ${downloadResponse['location']}',
          location: downloadResponse['location'],
        ),
      );
    } catch (e) {
      emit(
        ExRegisterDownloadError(
          message: 'Getting some error while download a File!!',
        ),
      );
    }
  }

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
          _formatEquipmentProtection(asset).toLowerCase().contains(lowerQuery) ||
          (asset.equipmentTClass.any(
            (group) => group.toLowerCase().contains(lowerQuery),
          )) ||
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

  FutureOr<void> exRegisterDuplicateOrDelete(
    ExRegisterDuplicateOrDelete event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await exRegisterDuplicateOrDeleteFromApi(event, emit);
      } else {
        await exRegisterDuplicateOrDeleteFromOffline(event, emit);
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> exRegisterDuplicateOrDeleteFromApi(
    ExRegisterDuplicateOrDelete event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterShowLoader());
    try {
      final ExRegisterService service = ExRegisterService();
      if (event.type == "duplicate") {
        final response = await service.fetchAssetById(assetId: event.assetId);
        if (response['status'] == true) {
          final assetDetails = response['data']['assetDetails'];
          DuplicateAsset duplicateAsset = DuplicateAsset.fromJson(assetDetails);
          final postAssetResponse = await service.postAsset(
            asset: duplicateAsset,
          );
          if (postAssetResponse['status']) {
            emit(
              ExRegisterDuplicateOrDeleteSuccess(
                message: 'Selected equipment has been duplicated successfully!',
                isDuplicate: true,
              ),
            );
          } else {
            throw Exception('Failed to duplicate the equipment!');
          }
        } else {
          throw Exception('Failed to get equipment data!');
        }
      } else {
        final response = await service.deleteAssetById(assetId: event.assetId);
        if (response['status'] == true) {
          emit(
            ExRegisterDuplicateOrDeleteSuccess(
              message: 'Selected equipment has been deleted successfully!',
              isDuplicate: true,
            ),
          );
        } else {
          throw Exception('Failed to get equipment data!');
        }
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterSaveError(e.toString()));
    }
  }

  FutureOr<void> exRegisterDuplicateOrDeleteFromOffline(
    ExRegisterDuplicateOrDelete event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterShowLoader());
    try {
      if (event.type == "duplicate") {
        final response = await _exregisterRepo.fetchAssetById(event.assetId);
        if (response['status'] == true) {
          final assetDetails = response['assetDetails'];
          DuplicateAsset duplicateAsset = DuplicateAsset.fromJson(assetDetails);
          final postAssetResponse = await _exregisterRepo.postAsset(
            asset: duplicateAsset,
          );

          if (postAssetResponse['status']) {
            emit(
              ExRegisterDuplicateOrDeleteSuccess(
                message: 'Selected equipment has been duplicated successfully!',
                isDuplicate: true,
              ),
            );
          } else {
            emit(ExRegisterError('Failed to duplicate the equipment!'));
            throw Exception('Failed to duplicate the equipment!');
          }
        } else {
          emit(ExRegisterError('Failed to get equipment data!'));
          throw Exception('Failed to get equipment data!');
        }
      } else {
        final response = await _exregisterRepo.deleteAssetById(
          assetId: event.assetId,
          assetIds: event.assetIds,
        );
        if (response['status'] == true) {
          emit(
            ExRegisterDuplicateOrDeleteSuccess(
              message: 'Selected equipment has been deleted successfully!',
              isDuplicate: true,
            ),
          );
        } else {
          throw Exception('Failed to delete the equipment!');
        }
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterSaveError(e.toString()));
    } finally {
      emit(HideExRegisterMoreOption());
    }
  }
  // New Code

  FutureOr<void> initloadExRegisterFromOffline(
    InitLoadExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    try {
      final userType = await authUtils.getUserType();
      offset = 0;
      hasMoreData = true;

      final now = DateTime.now();
      fromDate = event.fromDate ?? DateTime(now.year, 1, 1);
      toDate = event.toDate ?? DateTime(now.year, 12, 31);

      final results = await _fetchExRegisterData(userType: userType);
      final assets = _parseExRegisterTableModels(results);
      assets.sort((a, b) {
        final createdDateA =
            DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
        final createdDateB =
            DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
        final updatedDateA =
            DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
        final updatedDateB =
            DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

        final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
        return updatedDateComparison != 0
            ? updatedDateComparison
            : createdDateB.compareTo(createdDateA);
      });
      final filtered = _applyShowAllFilter(
        _applyDateFilter(assets, fromDate!, toDate!, event.type.toString()),
        event.showAllFilterType,
      );

      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: _getHeaders(userType),
          assets: filtered,
          totalRecords: filtered.length,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: offset + filtered.length,
          isLoadMore: false,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> loadExRegisterFromOffline(
    LoadExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    try {
      final userType = await authUtils.getUserType();
      offset = 0;
      hasMoreData = true;

      final results = await _fetchExRegisterData(userType: userType);
      final models = _parseExRegisterTableModels(results);
      models.sort((a, b) {
        final createdDateA =
            DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
        final createdDateB =
            DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
        final updatedDateA =
            DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
        final updatedDateB =
            DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

        final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
        return updatedDateComparison != 0
            ? updatedDateComparison
            : createdDateB.compareTo(createdDateA);
      });
      final assets = models.map((e) => e.exregisterJson).toList();

      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: _getHeaders(userType),
          assets: assets,
          totalRecords: assets.length,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: offset + assets.length,
          isLoadMore: false,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> loadMoreExRegisterFromOffline(
    LoadMoreExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    try {
      emit(ExRegisterIsLoading(isLoadMore: true));
      final userType = await authUtils.getUserType();
      offset = event.assets.length;
      final results = await _fetchExRegisterData(
        userType: userType,
        offset: event.assets.length,
        limit: loadMoreLimit,
        all: !(event.showAllFilterType == "Show All" &&
            event.type == "Year to Date"),
      );

      if (results.isEmpty) {
        hasMoreData = false;
        emit(
          ExRegisterLoaded(
            isDuplicate: false,
            tableHeaders: event.tableHeaders,
            assets: event.assets,
            totalRecords: event.totalRecords,
            filterIndex: filterIndex,
            sortOrder: sortOrder,
            skip: offset,
            isLoadMore: false,
            isPaginatedReplace: true,
            hasMoreData: false,
          ),
        );
        return;
      }

      await Future.delayed(const Duration(seconds: 1)); // Optional UX delay

      final parsed = _parseExRegisterTableModels(results);
      parsed.sort((a, b) {
        final createdDateA =
            DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
        final createdDateB =
            DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
        final updatedDateA =
            DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
        final updatedDateB =
            DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

        final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
        return updatedDateComparison != 0
            ? updatedDateComparison
            : createdDateB.compareTo(createdDateA);
      });
      final normalizedFromDate = _normalizeDate(event.fromDate);
      final normalizedToDate = _normalizeDate(event.toDate);

      List<ExRegister> filteredList = [];
      if (normalizedFromDate != null && normalizedToDate != null) {
        filteredList = _applyDateFilter(
          parsed,
          normalizedFromDate,
          normalizedToDate,
          event.type.toString(),
        );
      }

      final combinedFilteredList = _applyShowAllFilter(
        filteredList,
        event.showAllFilterType,
      );
      List<ExRegister> updatedAssets = [];
      if (event.showAllFilterType == "Show All" &&
          event.type == "Year to Date") {
        updatedAssets = event.assets + combinedFilteredList;
        offset += combinedFilteredList.length;
        hasMoreData = combinedFilteredList.length == loadMoreLimit;
      } else {
        updatedAssets = combinedFilteredList;
        offset = combinedFilteredList.length;
        hasMoreData = combinedFilteredList.length == loadMoreLimit;
      }
      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: event.tableHeaders,
          assets: updatedAssets,
          totalRecords: updatedAssets.length,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: updatedAssets.length,
          isLoadMore: false,
          isPaginatedReplace: true,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> showAllFilterExRegisterFromOffline(
    ShowAllFilterExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      skip = 0;
      type = event.type;

      final userType = await authUtils.getUserType();
      final results = await _fetchExRegisterData(userType: userType, all: true);
      final allAssets = _parseExRegisterTableModels(results);
      allAssets.sort((a, b) {
        final createdDateA =
            DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
        final createdDateB =
            DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
        final updatedDateA =
            DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
        final updatedDateB =
            DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

        final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
        return updatedDateComparison != 0
            ? updatedDateComparison
            : createdDateB.compareTo(createdDateA);
      });
      final normalizedFromDate = _normalizeDate(event.fromDate);
      final normalizedToDate = _normalizeDate(event.toDate);

      List<ExRegister> filteredList = [];
      if (normalizedFromDate != null && normalizedToDate != null) {
        filteredList = _applyDateFilter(
          allAssets,
          normalizedFromDate,
          normalizedToDate,
          event.type.toString(),
        );
      }

      final combinedFilteredList = _applyShowAllFilter(
        filteredList,
        event.type,
      );

      final paginatedAssets = _paginateAssets(combinedFilteredList);

      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: _getHeaders(userType),
          assets: paginatedAssets,
          totalRecords: combinedFilteredList.length,
          isLoadMore: false,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: skip,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> yearToDateFilterExRegisterFromOffline(
    YearToDateFilterExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      skip = skip;
      final userType = await authUtils.getUserType();
      final results = await _fetchExRegisterData(userType: userType, all: true);
      final assets = _parseExRegisterTableModels(results);
      assets.sort((a, b) {
        final createdDateA =
            DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
        final createdDateB =
            DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
        final updatedDateA =
            DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
        final updatedDateB =
            DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

        final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
        return updatedDateComparison != 0
            ? updatedDateComparison
            : createdDateB.compareTo(createdDateA);
      });
      final normalizedFromDate = _normalizeDate(event.fromDate);
      final normalizedToDate = _normalizeDate(event.toDate);

      List<ExRegister> filteredList = [];
      if (normalizedFromDate != null && normalizedToDate != null) {
        filteredList = _applyDateFilter(
          assets,
          normalizedFromDate,
          normalizedToDate,
          event.type.toString(),
        );
      }

      final combinedFilteredList = _applyShowAllFilter(
        filteredList,
        event.showAllFilterType,
      );

      final paginatedAssets = _paginateAssets(combinedFilteredList);

      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: _getHeaders(userType),
          assets: paginatedAssets,
          totalRecords: combinedFilteredList.length,
          isLoadMore: false,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: skip,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> sortExRegisterByOffline(
    SortExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      final userType = await authUtils.getUserType();
      event.sortOrder == "descending"
          ? filterIndex = event.columnIndex
          : filterIndex = null;
      final results = await _fetchExRegisterData(userType: userType);
      final assets = _parseExRegisterTableModels(results);
      assets.sort((a, b) {
        final createdDateA =
            DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
        final createdDateB =
            DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
        final updatedDateA =
            DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
        final updatedDateB =
            DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

        final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
        return updatedDateComparison != 0
            ? updatedDateComparison
            : createdDateB.compareTo(createdDateA);
      });
      final normalizedFromDate = _normalizeDate(event.fromDate);
      final normalizedToDate = _normalizeDate(event.toDate);

      List<ExRegister> filteredLists = [];
      if (normalizedFromDate != null && normalizedToDate != null) {
        filteredLists = _applyDateFilter(
          assets,
          normalizedFromDate,
          normalizedToDate,
          event.type.toString(),
        );
      }

      final combinedFilteredLists = _applyShowAllFilter(
        filteredLists,
        event.showAllFilterType,
      );
      List<ExRegister> filteredList = _filterExRegister(
        combinedFilteredLists,
        event.searchQuery,
      );

      List<ExRegister> filteredListsort = _applyFilters(filteredList, event);
      List<String> tableHeaders = _getHeaders(userType);

      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: tableHeaders,
          assets: filteredListsort,
          totalRecords: filteredListsort.length,
          skip: 0,
          filterIndex: event.columnIndex,
          sortOrder: event.sortOrder,
          selectedFilters: event.selectedFilters,
          collectionSelectedFilter: event.collectionSelectedFilter,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  FutureOr<void> resetFilterExRegisterFromOffline(
    ResetFilterExRegister event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterLoading());
    try {
      skip = skip;
      fromDate = event.fromDate;
      toDate = event.toDate;
      final userType = await authUtils.getUserType();

      final results = await _fetchExRegisterData(userType: userType, all: true);
      final assets = _parseExRegisterTableModels(results);
      assets.sort((a, b) {
        final createdDateA =
            DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
        final createdDateB =
            DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
        final updatedDateA =
            DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
        final updatedDateB =
            DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

        final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
        return updatedDateComparison != 0
            ? updatedDateComparison
            : createdDateB.compareTo(createdDateA);
      });

      final filteredAssets = _applyAllFilters(
        assets,
        event.fromDate,
        event.toDate,
        event.type.toString(),
        event.showAllFilterType,
        event.collectionSelectedFilterData,
      );

      final paginatedAssets = _paginateList(filteredAssets, skip, limit);

      emit(
        ExRegisterLoaded(
          isDuplicate: false,
          tableHeaders: _getHeaders(userType),
          assets: paginatedAssets,
          totalRecords: filteredAssets.length,
          isLoadMore: false,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: skip,
          selectedFilters: _extractSelectedFilterFlags(
            event.collectionSelectedFilterData,
          ),
          collectionSelectedFilter: event.collectionSelectedFilterData,
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      emit(ExRegisterError(e.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchExRegisterData({
    required String? userType,
    int offset = 0,
    int limit = 30,
    bool all = false,
  }) async {
    if (all) {
      return (userType == 'onshore')
          ? await _dbHelper.getExRegisterOnshore()
          : await _dbHelper.getExRegister();
    } else {
      return (userType == 'onshore')
          ? await _dbHelper.getExRegisterByOffsetOnshore(offset, limit)
          : await _dbHelper.getExRegisterByOffset(offset, limit);
    }
  }

  // List<ExRegisterTableModel> _parseExRegisterTableModels(
  //     List<Map<String, dynamic>> results) {
  //   return results.map((map) {
  //     final jsonRaw = map['exregister_json'];
  //     final jsonMap = (jsonRaw is String)
  //         ? jsonDecode(jsonRaw)
  //         : jsonRaw as Map<String, dynamic>?;

  //     if (jsonMap == null) {
  //       throw const FormatException("Invalid JSON: \${jsonRaw.runtimeType}");
  //     }

  //     return ExRegisterTableModel(
  //       id: map['id'],
  //       exregisterJson: ExRegister.fromJson(jsonMap['asset']),
  //       createdBy: map['created_by'],
  //       updatedBy: map['updated_by'],
  //       createdDate: map['created_date'],
  //       updatedDate: map['updated_date'],
  //     );
  //   }).toList();
  // }

  List<ExRegisterTableModel> _parseExRegisterTableModels(
    List<Map<String, dynamic>> results,
  ) {
    final data = results.map((map) {
      final jsonRaw = map['exregister_json'];
      final jsonMap = (jsonRaw is String)
          ? jsonDecode(jsonRaw)
          : jsonRaw as Map<String, dynamic>?;
      if (jsonMap == null) {
        throw const FormatException("Invalid JSON");
      }

      final dynamic rawAsset = jsonMap['asset'] ?? jsonMap;
      Map<String, dynamic> assetMap = {};
      if (rawAsset is Map<String, dynamic>) {
        assetMap = Map<String, dynamic>.from(rawAsset);
      } else if (rawAsset is Map) {
        assetMap = Map<String, dynamic>.from(rawAsset);
      }

      final int rowId = (map['id'] is int)
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0;
      assetMap['primaryId'] = rowId;
      assetMap['_id'] = rowId.toString();

      return ExRegisterTableModel(
        id: map['id'],
        exregisterJson: ExRegister.fromJson(assetMap),
        createdBy: map['created_by'],
        updatedBy: map['updated_by'],
        createdDate: map['created_date'],
        updatedDate: map['updated_date'],
      );
    }).toList();
    return data;
  }

  List<String> _getHeaders(String? userType) {
    return userType == 'onshore'
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

  DateTime _normalizeDate(DateTime? date) =>
      date != null ? DateTime(date.year, date.month, date.day) : DateTime.now();

  List<ExRegister> _paginateAssets(List<ExRegister> assets) {
    final start = skip;
    final end = skip + limit;
    return assets.sublist(start, end > assets.length ? assets.length : end);
  }

  FutureOr<void> updateExRegisterAfterChange(
    UpdateExRegisterAfterChange event,
    Emitter<ExRegisterState> emit,
  ) async {
    final userType = await authUtils.getUserType();
    final tableHeaders = _getHeaders(userType);

    final results = await _fetchExRegisterData(userType: userType);

    if (results.isEmpty) {
      hasMoreData = false;
      emit(
        ExRegisterLoaded(
          tableHeaders: tableHeaders,
          assets: const [],
          totalRecords: 0,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          skip: offset,
          isDuplicate: event.isDuplicate,
          isLoadMore: false,
        ),
      );
      return;
    }

    final assets = _parseExRegisterTableModels(results);

    assets.sort((a, b) {
      final createdDateA =
          DateTime.tryParse(a.createdDate ?? '') ?? DateTime(0);
      final createdDateB =
          DateTime.tryParse(b.createdDate ?? '') ?? DateTime(0);
      final updatedDateA =
          DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(0);
      final updatedDateB =
          DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(0);

      final updatedDateComparison = updatedDateB.compareTo(updatedDateA);
      return updatedDateComparison != 0
          ? updatedDateComparison
          : createdDateB.compareTo(createdDateA);
    });

    final allAssets = assets.map((asset) => asset.exregisterJson).toList();
    final limitedAssets = allAssets.take(loadMoreLimit).toList();
    hasMoreData = allAssets.length > loadMoreLimit;

    emit(
      ExRegisterLoaded(
        isDuplicate: event.isDuplicate,
        tableHeaders: tableHeaders,
        assets: limitedAssets,
        totalRecords: allAssets.length,
        filterIndex: filterIndex,
        sortOrder: sortOrder,
        skip: offset + limitedAssets.length,
        isLoadMore: false,
      ),
    );
  }

  List<ExRegister> _applyFilters(
    List<ExRegister> assets,
    SortExRegister event,
  ) {
    var filteredList = assets;

    if (event.collectionSelectedFilter != null) {
      event.collectionSelectedFilter.forEach((sortField, selectedFilters) {
        if (selectedFilters.isNotEmpty) {
          filteredList = filteredList.where((asset) {
            String status = '';
            if (sortField == 'inspectionStatus') {
              status = _getStatusForAsset(asset, 'inspectionStatus');
            } else if (sortField == 'currentStatus') {
              status = _getStatusForAsset(asset, 'currentStatus');
            }
            return selectedFilters.contains(status);
          }).toList();
        }
      });
    }

    if (event.sortOrder.isNotEmpty) {
      filteredList = ExRegisterFunction.sortList(
        filteredList: filteredList,
        columnIndex: event.columnIndex,
        sortOrder: event.sortOrder,
      );
    }

    return filteredList;
  }

  String _getStatusForAsset(ExRegister asset, String sortField) {
    if (sortField == 'inspectionStatus') {
      return asset.inspectionStatus.isNotEmpty ? asset.inspectionStatus : "";
    } else if (sortField == 'currentStatus') {
      return asset.currentStatus.isNotEmpty ? asset.currentStatus : "";
    }
    return '';
  }

  List<ExRegister> _applyAllFilters(
    List<ExRegisterTableModel> assets,
    DateTime? from,
    DateTime? to,
    String type,
    String? showAllFilterType,
    Map<String, List<String>>? collectionSelectedFilters,
  ) {
    List<ExRegister> filtered;
    if (from != null && to != null) {
      DateTime normalize(DateTime date) =>
          DateTime(date.year, date.month, date.day);
      final fromDateNorm = normalize(from);
      final toDateNorm = normalize(to);

      filtered = _applyDateFilter(
        assets,
        fromDateNorm,
        toDateNorm,
        type,
      );
    } else {
      filtered = List.from(assets);
    }
    filtered = _applyShowAllFilter(filtered, showAllFilterType);

    if (collectionSelectedFilters != null) {
      for (final entry in collectionSelectedFilters.entries) {
        if (entry.value.isEmpty) continue;
        final sortField = entry.key;
        final selectedValues = entry.value;

        filtered = filtered.where((asset) {
          final status = _computeStatus(asset, sortField);
          return selectedValues.contains(status);
        }).toList();
      }
    }

    return filtered;
  }

  String _computeStatus(ExRegister asset, String sortField) {
    if (sortField == 'inspectionStatus') {
      return asset.inspectionStatus.isNotEmpty
          ? asset.inspectionStatus
          : _computeStatusFromChecklist(asset, asset.inspectionPriority);
    }

    if (sortField == 'currentStatus') {
      return asset.currentStatus.isNotEmpty
          ? asset.currentStatus
          : _computeStatusFromChecklist(asset, asset.repairPriority);
    }

    return '';
  }

  String _computeStatusFromChecklist(ExRegister asset, int? priority) {
    if (asset.inspectionGrade?.toString().isNotEmpty == true &&
        asset.inspectionType?.toString().isNotEmpty == true &&
        // asset.inspectionChecklistType.isNotEmpty == true &&
        asset.equipmentEquipmentType?.toString().isNotEmpty == true) {
      if (asset.checkList == null || asset.checkList!.isEmpty) {
        return "Green";
      } else if (priority != null) {
        if (priority <= 2) return "Red";
        if (priority >= 3 && priority <= 5) return "Yellow";
      }
    }
    return '';
  }

  List<ExRegister> _paginateList(List<ExRegister> list, int skip, int limit) {
    final end = (skip + limit > list.length) ? list.length : skip + limit;
    return list.sublist(skip, end);
  }

  List<String> _extractSelectedFilterFlags(Map<String, List<String>>? filters) {
    if (filters == null) return [];
    return filters.values
        .expand((e) => e)
        .toSet()
        .toList(); // Deduplicated list
  }

  List<ExRegister> _applyShowAllFilter(
    List<ExRegister> assets,
    String? filterType,
  ) {
    if (filterType == null || filterType.isEmpty) return assets;
    switch (filterType) {
      //Inspected --> If there is any values in the inspection status then its inspected
      case "Inspected":
        return assets.where((filter) {
          // 1st Condition: If inspectionStatus is not empty, return true
          // if (filter.inspectionStatus.isNotEmpty &&
          //     (filter.inspectedDate != null ||
          //         filter.inspectedDate.toString().isNotEmpty) &&
          //     (filter.inspectedBy != null ||
          //         filter.inspectedBy.toString().isNotEmpty)) {
          //
          //   return true;
          // }
          // 2nd Condition: If inspectionStatus is empty, check inspectionPriority
          // if (filter.inspectionPriority != null &&
          //     filter.inspectionPriority != 0) {
          //
          //   return true;
          // }
          // 3rd Condition: If inspectionType, inspectionChecklistType, equipmentEquipmentType, and inspectionGrade are not null,
          // and checkList is an empty array, return true
          // &&
          //     (filter.checkList != null || filter.checkList!.isNotEmpty
          if (filter.inspectionStatus.isNotEmpty &&
              (filter.inspectedDate.toString().isNotEmpty) &&
              (filter.inspectedBy.toString().isNotEmpty) &&
              (filter.inspectionPriority != null ||
                  filter.inspectionPriority != 0) &&
              filter.inspectionType.toString().isNotEmpty &&
              filter.inspectionChecklistType.isNotEmpty &&
              filter.equipmentEquipmentType.toString().isNotEmpty &&
              filter.inspectionGrade.toString().isNotEmpty) {
            return true;
          }
          return false;
        }).toList();

      case "Uninspected":
        return assets.where((filter) {
          if (
              // (filter.inspectionStatus.isEmpty) &&
              (filter.inspectionPriority == null ||
                      filter.inspectionPriority == 0 ||
                      filter.inspectionPriority != 0) &&
                  // (filter.inspectionType == null ||
                  //     filter.inspectionType.toString().isEmpty) &&
                  // // (filter.inspectionChecklistType == null ||
                  // //     filter.inspectionChecklistType.toString().isEmpty) &&
                  // (filter.equipmentEquipmentType == null ||
                  //     filter.equipmentEquipmentType.toString().isEmpty) &&
                  // (filter.inspectionGrade == null ||
                  //     filter.inspectionGrade.toString().isEmpty)
                  (filter.inspectedBy.toString().isEmpty ||
                      filter.inspectedBy == null ||
                      filter.inspectedBy == "null") &&
                  (filter.inspectedDate == null ||
                      filter.inspectedDate.toString().isEmpty ||
                      filter.inspectedDate == "null")) {
            return true;
          }
          return false;
        }).toList();

      //Repaired Completely --> If existingFaults is 0 (and repair completed or status is green)
      case "Repaired Completely":
        return assets.where((filter) {
          String faultsRaw = filter.existingFaults.toString().trim() == ''
              ? "0"
              : filter.existingFaults.toString();
          String repairsRaw = filter.repairsDone.toString().trim() == ''
              ? "0"
              : filter.repairsDone.toString();
          int existingFaults = int.tryParse(faultsRaw) ?? 0;
          int repairsDone = int.tryParse(repairsRaw) ?? 0;

          return existingFaults == 0 &&
              (repairsDone > 0 || filter.currentStatus == "Green");
        }).toList();

      //Repaired Partially --> Either Completed Repairs and Existing Faults has at least 1 count
      case "Repaired Partially":
        return assets.where((filter) {
          String faultsRaw = filter.existingFaults.toString().trim() == ''
              ? "0"
              : filter.existingFaults.toString();
          String repairsRaw = filter.repairsDone.toString().trim() == ''
              ? "0"
              : filter.repairsDone.toString();

          int existingFaults = int.tryParse(faultsRaw) ?? 0;
          int repairsDone = int.tryParse(repairsRaw) ?? 0;

          return existingFaults > 0 && repairsDone > 0;
        }).toList();

      //Corrective Actions --> If the current status is red or yellow then it should be Corrective Actions
      case "Corrective Actions":
        return assets.where((filter) {
          final status = filter.currentStatus.toString();
          // .isEmpty ? 'Red' : e.currentStatus;
          final priority = filter.inspectionPriority;
          if (["Red", "Yellow"].contains(status)) {
            return true;
          }

          if (priority != null) {
            if (priority <= 2) return status == "Red";
            if (priority <= 5) return status == "Yellow";
          }
          return false;
        }).toList();
      default:
        return assets;
    }
  }

  List<ExRegister> _applyDateFilter(
    List<ExRegisterTableModel> assets,
    DateTime fromDate,
    DateTime toDate,
    String type,
  ) {
    DateTime normalize(DateTime date) =>
        DateTime(date.year, date.month, date.day);

    final normalizedFromDate = normalize(fromDate);
    final normalizedToDate = normalize(toDate);

    return assets
        .where((asset) {
          final assetDateString = asset.updatedDate;
          if (assetDateString == null) return false;

          final assetDate = DateTime.tryParse(assetDateString);
          if (assetDate == null) return false;

          final normalizedAssetDate = normalize(assetDate);
          return normalizedAssetDate.isAtSameMomentAs(normalizedFromDate) ||
              (normalizedAssetDate.isAfter(normalizedFromDate) &&
                  normalizedAssetDate.isBefore(normalizedToDate)) ||
              normalizedAssetDate.isAtSameMomentAs(normalizedToDate);
        })
        .map((asset) => asset.exregisterJson)
        .toList();
  }

  // Generate ITR (Frontend Client-Side PDF generation)
  FutureOr<void> exRegisterGenerateItr(
    ExRegisterGenerateItr event,
    Emitter<ExRegisterState> emit,
  ) async {
    emit(ExRegisterGenerateItrLoading());
    try {
      final Map<String, String> res =
          await GenerateItrFunctions().generateItrForAsset(
        assetId: event.assetId,
      );

      emit(
        ExRegisterGenerateItrSuccess(
          message: 'File Downloaded to ${res['location'] ?? ''}',
          location: res['location'] ?? '',
        ),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: false);
      emit(
        ExRegisterGenerateItrError(
          message: 'Getting some error while generating the file: $e',
        ),
      );
    }
  }
}
