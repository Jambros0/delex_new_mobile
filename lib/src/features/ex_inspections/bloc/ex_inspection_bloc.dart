// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/dropdown_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/ex_register_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/file_uploads_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/inspection_checklist_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/services/ex_inspection_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/funtional_area_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/file_upload_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExInspectionsBloc extends Bloc<ExInspectionsEvent, ExInspectionsState> {
  final ExInspectionService exInspectionService;
  final FileUploadUtil commonServiceUtil;
  Map<String, dynamic>? _allDropDowns;
  Map<String, dynamic>? _checklistData;
  Map<String, dynamic>? _originalChecklistData;
  final DropdownRepository dropdownRepository;
  final FunctionalAreaRepository functionalAreaRepo;
  final ExregisterRepo exregisterRepo;
  final InspectionChecklistRepo checklistRepo;
  final FileUploadRepository fileUploadRepo;
  bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';

  ExInspectionsBloc({
    required this.exInspectionService,
    required this.commonServiceUtil,
    required this.dropdownRepository,
    required this.functionalAreaRepo,
    required this.exregisterRepo,
    required this.checklistRepo,
    required this.fileUploadRepo,
  }) : super(ExInspectionInitial()) {
    on<FetchAllDropDwn>(_onFetchAllDropDwn);
    on<SubmitFunctionalArea>(_onSubmitFunctionalArea);
    on<SubmitEquipmentTag>(_onSubmitEquipmentTag);
    on<UploadFile>(_onUploadFile);
    on<UploadFunctionalAreaFile>(_onUploadFunctionalAreaFile);
    on<SubmitInspectionChecklist>(_onSubmitInspectionChecklist);
    on<FilterInspectionChecklist>(_onFilterInspectionChecklist);
  }

  Future<void> _onFetchAllDropDwn(
    FetchAllDropDwn event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      if (isApiFlag) {
        await _onFetchAllDropDwnFromApi(event, emit);
      } else {
        await _onFetchAllDropDwnFromOffline(event, emit);
      }
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onFetchAllDropDwnFromApi(
    FetchAllDropDwn event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionLoading());
    try {
      final rawDropDowns = await exInspectionService.getAllDropDwn();
      _allDropDowns = dropdownRepository.sortDropdownData(rawDropDowns);

      emit(
        ExInspectionLoaded(
          allDropDowns: _allDropDowns,
          checklistData: _checklistData,
        ),
      );
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onFetchAllDropDwnFromOffline(
    FetchAllDropDwn event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionLoading());
    try {
      _allDropDowns = await dropdownRepository.getLocalDropDownData();
      emit(
        ExInspectionLoaded(
          allDropDowns: _allDropDowns,
          checklistData: _checklistData,
        ),
      );
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onSubmitFunctionalArea(
    SubmitFunctionalArea event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      if (isApiFlag) {
        await _onSubmitFunctionalAreaFromApi(event, emit);
      } else {
        await _onSubmitFunctionalAreaFromOffline(event, emit);
      }
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onSubmitFunctionalAreaFromApi(
    SubmitFunctionalArea event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      Map<String, dynamic> result;
      if (event.request.functionalAreaRequest != null) {
        result = await exInspectionService.functionalAreaPost(
          event.request.functionalAreaRequest!,
          locationId: event.request.functionalAreaRequest!.locationId ?? '',
        );
      } else {
        throw Exception('Invalid form data');
      }
      if (result['status'] == true) {
        if (event.request.functionalAreaRequest!.locationId == null ||
            event.request.functionalAreaRequest!.locationId!.isEmpty) {
          String locationId = result['data']['locationId'];
          event.request.functionalAreaRequest!.locationId = locationId;
          event.request.equipmentTagRequest?.locationId = locationId;
          emit(
            ExInspectionSuccess(
              "Area Detail Created Successfully",
              locationId,
              false,
            ),
          );
        } else {
          event.request.equipmentTagRequest?.locationId =
              event.request.functionalAreaRequest!.locationId!;
          emit(
            ExInspectionSuccess(
              "Area Detail Updated Successfully",
              event.request.functionalAreaRequest!.locationId!,
              false,
            ),
          );
        }
      } else {
        emit(ExInspectionError(result['msg'] ?? 'Unknown error occurred'));
      }
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onSubmitFunctionalAreaFromOffline(
    SubmitFunctionalArea event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      final request = event.request.functionalAreaRequest;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      String? locationId = request?.locationId;
      if (locationId == null || locationId.isEmpty) {
        locationId = event.request.equipmentTagRequest?.locationId;
      }

      Map<String, dynamic> functionalAreaData = {
        'functional_area_json': jsonEncode(request!.toJson()),
        'created_by': userId,
        'updated_by': userId,
        if (locationId != null && locationId.isNotEmpty) 'locationId': locationId,
        if (locationId != null && locationId.isNotEmpty) 'id': locationId,
      };

      if (request == null ||
          (request.location.isEmpty) &&
              (request.area.isEmpty) &&
              (request.deckLevel.isEmpty) &&
              (request.zone.isEmpty) &&
              (request.subArea?.isEmpty ?? true)) {
        emit(
          ExInspectionSuccess(
            "Area Detail Clear Successfully",
            request?.locationId ?? "",
            false,
          ),
        );
        return;
      }
      print("locationId => $locationId");
      if (locationId == null || locationId.isEmpty) {
        Map<String, dynamic> result =
            await functionalAreaRepo.insertFunctionalArea(functionalAreaData);

        if (result['status'] == true) {
          locationId = result['data']['locationId'];
          event.request.functionalAreaRequest!.locationId = locationId;
          event.request.equipmentTagRequest?.locationId = locationId ?? '';
          emit(
            ExInspectionSuccess(
              "Area Detail Created Successfully",
              locationId ?? "",
              false,
            ),
          );
        } else {
          emit(ExInspectionError(result['msg'] ?? 'Unknown error occurred'));
        }
      } else {
        functionalAreaData['locationId'] = locationId;
        functionalAreaData['id'] = locationId;
        print("functionalAreaData => ${jsonEncode(functionalAreaData)}");
        await functionalAreaRepo.updateFunctionalArea(functionalAreaData);
        event.request.functionalAreaRequest!.locationId = locationId;
        if (event.request.equipmentTagRequest != null) {
          event.request.equipmentTagRequest!.locationId = locationId;
        }
        emit(
          ExInspectionSuccess(
            "Area Detail Updated Successfully",
            locationId,
            false,
          ),
        );
      }
    } catch (e) {
      emit(ExInspectionError("Failed to submit Area Detail: ${e.toString()}"));
    }
  }

  Future<void> _onSubmitEquipmentTag(
    SubmitEquipmentTag event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      if (isApiFlag) {
        await _onSubmitExRegisterFromApi(event, emit);
      } else {
        await _onSubmitExRegisterFromOffline(event, emit);
      }
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onSubmitExRegisterFromApi(
    SubmitEquipmentTag event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      if (event.request.equipmentTagRequest == null) {
        throw Exception('Invalid form data');
      }

      final result = await exInspectionService.equipmentTagPost(
        event.request.equipmentTagRequest!,
        assetId: event.request.equipmentTagRequest!.assetId ?? '',
      );

      if (result['status'] == true) {
        if (event.request.equipmentTagRequest!.assetId == null ||
            event.request.equipmentTagRequest!.assetId!.isEmpty) {
          String assetId = result['assetId'];
          event.request.equipmentTagRequest!.assetId = assetId;
          final message = _getSuccessMessage(event.screenType, "Created");
          if (message != null) {
            emit(ExInspectionSuccess(message, assetId, event.clearFlag));
          }
        } else {
          final message = _getSuccessMessage(event.screenType, "Updated");
          if (message != null) {
            emit(
              ExInspectionSuccess(
                message,
                event.request.equipmentTagRequest!.assetId!,
                event.clearFlag,
              ),
            );
          }
        }
      } else {
        emit(ExInspectionError(result['msg'] ?? 'Unknown error occurred'));
      }
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onSubmitExRegisterFromOffline(
    SubmitEquipmentTag event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if ((event.request.equipmentTagRequest?.locationId == null ||
              event.request.equipmentTagRequest!.locationId.isEmpty) &&
          event.request.functionalAreaRequest?.locationId != null &&
          event.request.functionalAreaRequest!.locationId!.isNotEmpty) {
        event.request.equipmentTagRequest?.locationId =
            event.request.functionalAreaRequest!.locationId!;
      }

      if (event.request.equipmentTagRequest?.assetId == null ||
          event.request.equipmentTagRequest!.assetId!.isEmpty ||
          event.request.equipmentTagRequest!.assetId == '0') {
        final requestMap = event.request.equipmentTagRequest!.toJson();
        final Map<String, dynamic> assetMap = (requestMap['asset'] is Map)
            ? Map<String, dynamic>.from(requestMap['asset'] as Map)
            : Map<String, dynamic>.from(requestMap);
        if (userId != null && userId.isNotEmpty) {
          assetMap['userId'] ??= userId;
          assetMap['createdBy'] ??= userId;
        }
        final exRegisterData = {
          'exregister_json': jsonEncode({'asset': assetMap}),
          'created_by': userId,
          'updated_by': userId,
          'updated_date': DateTime.now().toIso8601String(),
        };
        final result = await exregisterRepo.insertExRegister(exRegisterData);
        if (result['status'] == true) {
          String newAssetId = result['assetId'];
          event.request.equipmentTagRequest!.assetId = newAssetId;
          event.request.equipmentTagRequest!.primaryId =
              int.tryParse(newAssetId) ?? 0;
          final message = _getSuccessMessage(event.screenType, "Created");
          if (message != null) {
            emit(ExInspectionSuccess(message, newAssetId, event.clearFlag));
          }
        } else {
          emit(ExInspectionError(result['msg'] ?? 'Unknown error occurred'));
        }
      } else {
        final requestMap = event.request.equipmentTagRequest!.toJson();
        final Map<String, dynamic> assetMap = (requestMap['asset'] is Map)
            ? Map<String, dynamic>.from(requestMap['asset'] as Map)
            : Map<String, dynamic>.from(requestMap);
        final assetIdStr = event.request.equipmentTagRequest!.assetId.toString();
        final primaryIdVal = event.request.equipmentTagRequest!.primaryId ??
            int.tryParse(assetIdStr);
        assetMap['_id'] = assetIdStr;
        assetMap['primaryId'] = primaryIdVal;

        final exRegisterData = {
          'id': primaryIdVal,
          'exregister_json': jsonEncode({'asset': assetMap}),
          'created_by': userId,
          'updated_by': userId,
          'updated_date': DateTime.now().toIso8601String(),
        };
        await exregisterRepo.updateExRegister(exRegisterData);
        final message = _getSuccessMessage(event.screenType, "Updated");
        if (message != null) {
          emit(
            ExInspectionSuccess(
              message,
              assetIdStr,
              event.clearFlag,
              userUpdateSign: event.userUpdateSign,
            ),
          );
        }
      }
    } catch (e) {
      emit(ExInspectionError("Error => ${e.toString()}"));
    }
  }

  String? _getSuccessMessage(String? screenType, String action) {
    switch (screenType) {
      case 'Inspection Checklist':
        return "Inspection Checklist $action Successfully";
      case 'Defect Analysis':
        return "Defect Analysis $action Successfully";
      case 'Corrective Actions':
        return "Corrective Actions $action Successfully";
      case 'Equipment Tag':
        return "Equipment Tag $action Successfully";
      case 'RBI Stratrgy':
        return "RBI Stratrgy $action Successfully";
      default:
        return null;
    }
  }

  Future<void> _onUploadFile(
    UploadFile event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      if (isApiFlag) {
        await _onUploadFileFromApi(event, emit);
      } else {
        await _onUploadFileFromOffline(event, emit);
      }
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onUploadFileFromApi(
    UploadFile event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionLoading());
    try {
      dynamic uploadResult;
      if (event.fileOf == 'DefectUpload' ||
          event.fileOf == 'CorrectiveUpload') {
        uploadResult = await commonServiceUtil.imageUpload(
          event.file,
          event.fileOf,
        );
      } else {
        uploadResult = await commonServiceUtil.fileUpload(
          event.file,
          event.fileOf,
        );
      }
      if (uploadResult is List) {
        emit(FileUploadSuccess(uploadResult, event.fileOf));
      } else if (uploadResult is Map && uploadResult.containsKey('data')) {
        emit(FileUploadSuccess(uploadResult['data'], event.fileOf));
      } else {
        throw Exception('Unexpected upload result type');
      }
      final updatedDropDowns = await exInspectionService.getAllDropDwn();
      emit(ExInspectionLoaded(allDropDowns: updatedDropDowns));
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onUploadFileFromOffline(
    UploadFile event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionLoading());
    try {
      dynamic uploadResult;
      if (event.fileOf == 'DefectUpload' ||
          event.fileOf == 'CorrectiveUpload') {
        uploadResult = await fileUploadRepo.uploadImage(
          event.file,
          event.fileOf,
        );
      } else {
        uploadResult = await fileUploadRepo.uploadFile(
          event.file,
          event.fileOf,
        );
      }
      if (uploadResult is List) {
        emit(FileUploadSuccess(uploadResult, event.fileOf));
      } else if (uploadResult is Map && uploadResult.containsKey('data')) {
        emit(FileUploadSuccess(uploadResult['data'], event.fileOf));
      } else {
        throw Exception('Unexpected upload result type');
      }
      final updatedDropDowns = await dropdownRepository.getLocalDropDownData();
      emit(ExInspectionLoaded(allDropDowns: updatedDropDowns));
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onUploadFunctionalAreaFile(
    UploadFunctionalAreaFile event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      if (isApiFlag) {
        await _onUploadFunctionalAreaFileFromApi(event, emit);
      } else {
        await _onUploadFunctionalAreaFileFromOffline(event, emit);
      }
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onUploadFunctionalAreaFileFromApi(
    UploadFunctionalAreaFile event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionLoading());
    try {
      dynamic uploadResult;
      if (event.fileOf == 'DefectUpload' ||
          event.fileOf == 'CorrectiveUpload') {
        uploadResult = await commonServiceUtil.imageUpload(
          event.file,
          event.fileOf,
        );
      } else {
        uploadResult = await commonServiceUtil.fileUpload(
          event.file,
          event.fileOf,
        );
      }
      if (uploadResult is List) {
        emit(
          FileUploadFunctionalAreaSuccess(
            uploadResult,
            event.fileOf,
            event.index,
          ),
        );
      } else if (uploadResult is Map && uploadResult.containsKey('data')) {
        emit(
          FileUploadFunctionalAreaSuccess(
            uploadResult['data'],
            event.fileOf,
            event.index,
          ),
        );
      } else {
        throw Exception('Unexpected upload result type');
      }
      final updatedDropDowns = await exInspectionService.getAllDropDwn();
      emit(ExInspectionLoaded(allDropDowns: updatedDropDowns));
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onUploadFunctionalAreaFileFromOffline(
    UploadFunctionalAreaFile event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionLoading());
    try {
      dynamic uploadResult;
      if (event.fileOf == 'DefectUpload' ||
          event.fileOf == 'CorrectiveUpload') {
        uploadResult = await fileUploadRepo.uploadImage(
          event.file,
          event.fileOf,
        );
      } else {
        uploadResult = await fileUploadRepo.uploadFile(
          event.file,
          event.fileOf,
        );
      }
      if (uploadResult is List) {
        emit(
          FileUploadFunctionalAreaSuccess(
            uploadResult,
            event.fileOf,
            event.index,
          ),
        );
      } else if (uploadResult is Map && uploadResult.containsKey('data')) {
        emit(
          FileUploadFunctionalAreaSuccess(
            uploadResult['data'],
            event.fileOf,
            event.index,
          ),
        );
      } else {
        throw Exception('Unexpected upload result type');
      }
      final updatedDropDowns = await dropdownRepository.getLocalDropDownData();
      emit(ExInspectionLoaded(allDropDowns: updatedDropDowns));
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onSubmitInspectionChecklist(
    SubmitInspectionChecklist event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      if (isApiFlag) {
        await _onSubmitInspectionChecklistFromApi(event, emit);
      } else {
        await _onSubmitInspectionChecklistFromOffline(event, emit);
      }
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onSubmitInspectionChecklistFromApi(
    SubmitInspectionChecklist event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      _checklistData = await exInspectionService.fetchInspectionChecklist();
      _originalChecklistData = _checklistData;
      final List<dynamic> checkLists = _checklistData?['checkLists'] ?? [];
      final List<dynamic> checkListDetails =
          _checklistData?['checkListDetails'] ?? [];
      final filteredDetails = event.filters != null
          ? _filterChecklistData(event.filters!)
          : checkListDetails;
      final Map<String, dynamic> uniqueDetails = _getUniqueDefectCodes(
        filteredDetails,
      );
      emit(
        ExInspectionLoaded(
          checklistData: {
            'checkLists': checkLists,
            'checkListDetails': uniqueDetails.values.toList(),
          },
          allDropDowns: _allDropDowns,
        ),
      );
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onSubmitInspectionChecklistFromOffline(
    SubmitInspectionChecklist event,
    Emitter<ExInspectionsState> emit,
  ) async {
    emit(ExInspectionSubmitting());
    try {
      _checklistData = await checklistRepo.getLocalChecklistData();
      _originalChecklistData = _checklistData;

      final List<dynamic> checkLists = _checklistData?['checkLists'] ?? [];
      final List<dynamic> checkListDetails =
          _checklistData?['checkListDetails'] ?? [];

      final filteredDetails = event.filters != null
          ? _filterChecklistData(event.filters!)
          : checkListDetails;

      final Map<String, dynamic> uniqueDetails =
          _getUniqueDefectCodes(filteredDetails);
      if (event.checkList != null && event.checkList!.isNotEmpty) {
        for (final updatedChecklist in event.checkList!) {
          final updatedDefectCodes = updatedChecklist.defectCodes;

          for (final updatedDefect in updatedDefectCodes) {
            final matchingDetail = uniqueDetails.values.firstWhere(
              (d) => d['defectCode'] == updatedDefect.defectCode,
              // &&
              // d['checklistName'] == updatedDefect.checklistName,
              orElse: () => null,
            );

            if (matchingDetail != null) {
              final existingFindings =
                  (matchingDetail['findingsAndActions'] ?? []) as List;

              for (final updatedFinding in updatedDefect.findingsAndActions) {
                final existingFinding = existingFindings.firstWhere(
                  (f) => f['_id'] == updatedFinding.id,
                  orElse: () => null,
                );
                if (existingFinding != null) {
                  existingFinding['isSelected'] = updatedFinding.isSelected;
                  existingFinding['isDone'] = updatedFinding.isDone;
                  existingFinding['finding'] = updatedFinding.finding;
                  existingFinding['remedialAction'] =
                      updatedFinding.remedialAction;
                  existingFinding['defectCategory'] =
                      updatedFinding.defectCategory;
                  existingFinding['repairedBy'] = updatedFinding.repairedBy;
                  existingFinding['repairedAt'] = updatedFinding.repairedAt;
                }
              }
            }
          }
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));

      emit(
        ExInspectionLoaded(
          checklistData: {
            'checkLists': checkLists,
            'checkListDetails': uniqueDetails.values.toList(),
          },
          allDropDowns: _allDropDowns,
        ),
      );
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  Future<void> _onFilterInspectionChecklist(
    FilterInspectionChecklist event,
    Emitter<ExInspectionsState> emit,
  ) async {
    try {
      final filteredDetails = _filterChecklistData(event.selectedFilters);
      final uniqueDetails = _getUniqueDefectCodes(filteredDetails);
      emit(
        ExInspectionLoaded(
          checklistData: {
            'checkLists': _originalChecklistData?['checkLists'] ?? [],
            'checkListDetails': uniqueDetails.values.toList(),
          },
          allDropDowns: _allDropDowns,
        ),
      );
    } catch (e) {
      emit(ExInspectionError(e.toString()));
    }
  }

  List<dynamic> _filterChecklistData(Map<String, Object?> selectedFilters) {
    final List<dynamic> checkListDetails =
        _originalChecklistData?['checkListDetails'] ?? [];
    return checkListDetails.where((detail) {
      bool matches = true;
      if (selectedFilters['inspectionType'] != null &&
          selectedFilters['inspectionType']!.toString().trim().isNotEmpty) {
        final inspectionType = selectedFilters['inspectionType']!.toString().trim();
        final detailType = detail['inspectionType']?.toString().trim() ?? '';
        if (inspectionType.toLowerCase() == 'initial') {
          matches &= detailType.toLowerCase() == 'initial' ||
              detailType.toLowerCase() == 'periodic' ||
              detailType.toLowerCase() == 'sampling';
        } else if (inspectionType.toLowerCase() == 'periodic' ||
            inspectionType.toLowerCase() == 'sampling') {
          matches &= detailType.toLowerCase() == 'periodic' ||
              detailType.toLowerCase() == 'sampling';
        } else {
          matches &= detailType.toLowerCase() == inspectionType.toLowerCase();
        }
      }

      if (selectedFilters['equipmentType'] != null &&
          selectedFilters['equipmentType']!.toString().trim().isNotEmpty) {
        final equipmentType = selectedFilters['equipmentType']!.toString().trim();
        final detailEqType = detail['equipmentType']?.toString().trim() ?? '';
        if (equipmentType.toLowerCase() == 'motors' ||
            equipmentType.toLowerCase() == 'motor') {
          matches &= (detailEqType.toLowerCase() == 'motors' ||
                  detailEqType.toLowerCase() == 'motor' ||
                  detailEqType.toLowerCase() == 'others') &&
              detailEqType.toLowerCase() != 'lighting';
        } else if (equipmentType.toLowerCase() == 'lighting') {
          matches &= (detailEqType.toLowerCase() == 'lighting' ||
                  detailEqType.toLowerCase() == 'others') &&
              detailEqType.toLowerCase() != 'motors' &&
              detailEqType.toLowerCase() != 'motor';
        } else if (equipmentType.toLowerCase() == 'others') {
          matches &= detailEqType.toLowerCase() == 'others';
        } else {
          matches &= detailEqType.toLowerCase() == equipmentType.toLowerCase();
        }
      }

      if (selectedFilters['checklistName'] != null) {
        final rawChecklist = selectedFilters['checklistName'];
        List<String> selectedChecklists = [];
        if (rawChecklist is List) {
          selectedChecklists = rawChecklist
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else if (rawChecklist is String && rawChecklist.trim().isNotEmpty) {
          selectedChecklists = rawChecklist
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
        if (selectedChecklists.isNotEmpty) {
          final detailChecklist = detail['checklistName']?.toString().trim() ?? '';
          matches &= selectedChecklists.any(
            (c) => c.toLowerCase() == detailChecklist.toLowerCase(),
          );
        }
      }

      if (selectedFilters['inspectionGrade'] != null &&
          selectedFilters['inspectionGrade']!.toString().trim().isNotEmpty) {
        final inspectionGrade = selectedFilters['inspectionGrade']!.toString().trim();
        final detailGrade = detail['inspectionGrade']?.toString().trim() ?? '';
        if (inspectionGrade.toLowerCase() == 'visual') {
          matches &= detailGrade.toLowerCase() == 'visual';
        } else if (inspectionGrade.toLowerCase() == 'close') {
          matches &= detailGrade.toLowerCase() == 'close' ||
              detailGrade.toLowerCase() == 'visual';
        } else if (inspectionGrade.toLowerCase() == 'detailed') {
          matches &= detailGrade.toLowerCase() == 'close' ||
              detailGrade.toLowerCase() == 'visual' ||
              detailGrade.toLowerCase() == 'detailed';
        } else {
          matches &= detailGrade.toLowerCase() == inspectionGrade.toLowerCase();
        }
      }

      return matches;
    }).toList();
  }

  Map<String, dynamic> _getUniqueDefectCodes(List<dynamic> checkListDetails) {
    final Map<String, dynamic> uniqueDetails = {};
    for (var detail in checkListDetails) {
      final defectCode = detail['defectCode'];
      if (!uniqueDetails.containsKey(defectCode)) {
        uniqueDetails[defectCode] = detail;
      }
    }
    return uniqueDetails;
  }
}
