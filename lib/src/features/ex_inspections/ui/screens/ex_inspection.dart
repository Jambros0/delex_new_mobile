import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/ex_inspection_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/inspection_checklist_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/corrective_action_step.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/defect_analysis_step.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/equipment_tag_step.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/functional_area_step.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/inspection_checklist_step.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/rbi_strategy_step.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/services/ex_register_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/services/location_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/common_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/models/functional_area_request.dart';

class ExInspectionScreen extends StatefulWidget {
  final int initialStep;
  final String? assetId;
  final String? locationId;
  final int? step;
  final bool fromExRegister;

  const ExInspectionScreen({
    super.key,
    this.initialStep = 0,
    this.assetId,
    this.step,
    this.locationId,
    required this.fromExRegister,
  });

  @override
  ExInspectionScreenState createState() => ExInspectionScreenState();
}

class ExInspectionScreenState extends State<ExInspectionScreen> {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();
  int _currentStep = 0;
  late ExInspectionRequest _exInspectionRequest;
  bool _isStepDataSaved = false;
  bool _isUpdate = false;
  bool _isInitialLoad = true;
  bool _isDataFetched = false;
  bool checkInspection = false;
  bool checklistAnyoneCheck = true;
  // bool _isEditMode = false;
  final ValueNotifier<bool> isEditModeNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isEditAreaModeNotifier = ValueNotifier<bool>(false);

  final List<bool> _stepCompleted = List<bool>.generate(6, (index) => false);
  final List<String> _stepTitles = [
    'Area Detail',
    "Equipment Tags",
    "Inspection Checklist",
    "Defect Analysis",
    "Corrective Actions",
    // "RBI Strategy"
  ];
  bool _hasValidationError = false;
  final isApiFlag = dotenv.env['IS_API_FLAG']?.toLowerCase() == 'true';

  final GlobalKey<FunctionalAreaStepState> _functionalAreaKey =
      GlobalKey<FunctionalAreaStepState>();
  final GlobalKey<EquipmentTagsStepState> _equipmentTagKey =
      GlobalKey<EquipmentTagsStepState>();
  final GlobalKey<InspectionChecklistStepState> _inspectionChecklistKey =
      GlobalKey<InspectionChecklistStepState>();
  final GlobalKey<DefectAnalysisStepState> _defectAnalysisKey =
      GlobalKey<DefectAnalysisStepState>();
  final GlobalKey<CorrectiveActionsStepState> _correctiveActionsKey =
      GlobalKey<CorrectiveActionsStepState>();
  final GlobalKey<RBIStrategyStepState> _rbiStrategyKey =
      GlobalKey<RBIStrategyStepState>();

  @override
  void initState() {
    super.initState();
    if (widget.step != null) {
      _currentStep = widget.step!;
    } else {
      _currentStep = widget.initialStep;
    }
    if (widget.assetId == null || widget.assetId == "") {
      isEditModeNotifier.value = true;
    }
    if (widget.locationId == null || widget.locationId == "") {
      isEditAreaModeNotifier.value = true;
    }
    _initializeExInspectionRequest();
  }

  void _initializeExInspectionRequest() {
    _exInspectionRequest = ExInspectionRequest(
      functionalAreaRequest: FunctionalAreaRequest(
        location: '',
        area: '',
        deckLevel: '',
        subArea: '',
        zone: '',
        locationGasGroup: [],
        locationTClass: [],
        locationIpRating: [],
        tAmbient: '',
        areaClassDrawAttach: [],
        areaClassDrawNo: [],
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawAttachOrgName: [],
        areaClassDrawAttachOrgName: [],
        eqpmtLytDrawNo: [],
        locationLatitude: '',
        locationLongitude: '',
        isActive: true,
      ),
      equipmentTagRequest: EquipmentTagRequest(
        location: '',
        area: '',
        subArea: '',
        zone: '',
        locationGasGroup: [],
        locationTAmbient: '',
        locationTClass: [],
        locationIpRating: [],
        locationId: '',
        deckLevel: '',
        locationLatitude: '',
        locationLongitude: '',
        rfidRef: '',
        gpsCord: '',
        eqpmtCatg: '',
        eqpmtTag: '',
        circuitId: '',
        cableId: '',
        equipmentCategory: '',
        description: '',
        manufacturer: '',
        type: '',
        serialNumber: '',
        atexCatg: [],
        epl: [],
        protectionStd: '',
        protectionType: [],
        equipmentGasGroup: [],
        equipmentTClass: [],
        equipmentIpRating: [],
        certfnBody: '',
        certfnNo: '',
        tAmbient: '',
        tAmbientEquip: '',
        inspectionSignOff: '',
        repairSignOff: '',
        specialCond: '',
        oracleId: '',
        checkList: [],
        yesNoSelection: {},
        inspectedBy: '',
        inspectedDate: '',
        repairedBy: '',
        repairedDate: '',
        faultyItems: '',
        repairPriority: '',
        inspectionStatus: '',
        defectOverallCondition: '',
        defectIsolation: '',
        defectOtherRequirements: [],
        remarks: '',
        dataSheet: '',
        dataSheetOrgName: '',
        defectivePhoto1: '',
        defectivePhoto1OrgName: '',
        defectivePhoto2: '',
        defectivePhoto2OrgName: '',
        defectivePhoto3: '',
        defectivePhoto3OrgName: '',
        defectivePhoto4: '',
        defectivePhoto4OrgName: '',
        defectivePhoto5: '',
        defectivePhoto5OrgName: '',
        defectivePhoto6: '',
        defectivePhoto6OrgName: '',
        materials: [],
        existingFaults: '',
        correctiveDefectCategory: '',
        currentStatus: '',
        correctiveOverallCondition: '',
        correctiveisolation: '',
        correctiveOtherRequirements: '',
        repairsDone: '',
        correctivePhoto1: '',
        correctivePhoto1OrgName: '',
        correctivePhoto2: '',
        correctivePhoto2OrgName: '',
        correctivePhoto3: '',
        correctivePhoto3OrgName: '',
        correctivePhoto4: '',
        correctivePhoto4OrgName: '',
        correctivePhoto5: '',
        correctivePhoto5OrgName: '',
        correctivePhoto6: '',
        correctivePhoto6OrgName: '',
        rbiStrategy: null,
        additionalInfoForRepairs: '',
        remarksIfAny: '',
        supplementaryMaterialReq: [],
        defectCertificationNo: '',
        defectCertificationOrgName: '',
        correctiveCertificationNo: '',
        correctiveCertificationOrgName: '',
        areaClassDrawAttach: [],
        areaClassDrawAttachOrgName: [],
        areaClassDrawNo: [],
        equipmentEquipmentType: '',
        eqpmtLytDrawAttach: [],
        eqpmtLytDrawAttachOrgName: [],
        eqpmtLytDrawNo: [],
        correctiveCertificationAttach: '',
        defectCertificationAttach: '',
        dataSheetNo: '',
        defectDefectCategory: '',
        inspectionChecklistType: [],
        inspectionGrade: '',
        inspectionType: '',
        primaryId: 0,
        repairDuration: '',
        inspectionPriority: null,
        // repairTimeEstimate: '',
        isActive: true,
        areaStatus: null,
        isDuplicate: false,
      ),
      inspectionChecklistRequest: InspectionChecklistRequest(
        inspectionType: '',
        equipmentType: '',
        // checklistName: '',
        checklistName: [],
        inspectionGrade: '',
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialLoad &&
        widget.locationId != null &&
        widget.locationId!.isNotEmpty &&
        !_isDataFetched) {
      _isUpdate = true;
      _fetchLocationData(widget.locationId!);
      _isInitialLoad = false;
    }
    if (_isInitialLoad &&
        widget.assetId != null &&
        widget.assetId!.isNotEmpty &&
        !_isDataFetched) {
      _isUpdate = true;
      _fetchAssetData(widget.assetId!);
      _isInitialLoad = false;
    } else if (widget.assetId != null && _isUpdate && _isDataFetched) {
      return;
    } else if (widget.assetId == null) {
      return;
    } else {
      _isUpdate = false;
      _initializeExInspectionRequest();
    }
  }

  Future<void> _fetchAssetData(String assetId) async {
    if (_isDataFetched) return;
    if (isApiFlag) {
      await _fetchAssetDataFromApi(assetId);
    } else {
      await _fetchAssetDataFromOffline(assetId);
    }
  }

  Future<void> _fetchLocationData(String locationId) async {
    if (_isDataFetched) return;
    if (isApiFlag) {
      await _fetchLocationDataFromApi(locationId);
    } else {
      await _fetchLocationDataFromOffline(locationId);
    }
  }

  Future<void> _fetchAssetDataFromApi(String assetId) async {
    if (_isDataFetched) return;
    final ExRegisterService service = ExRegisterService();
    // try {
    final response = await service.fetchAssetById(assetId: assetId);
    if (response['status'] == true) {
      final assetDetails = response['data']['assetDetails'];
      String locationId = assetDetails['locationId'] ?? '';
      Map<String, dynamic> locationData = {};
      if (locationId.isNotEmpty) {
        final LocationService locationService = LocationService();
        final locationResponse = await locationService.fetchLocationById(
          locationId: locationId,
        );
        if (locationResponse.containsKey('data')) {
          locationData = locationResponse['data'];
        }
      }

      final mergedLocationData = Map<String, dynamic>.from(assetDetails);
      locationData.forEach((k, v) {
        if (v != null && v != '' && !(v is List && v.isEmpty)) {
          mergedLocationData[k] = v;
        }
      });
      if (locationId.isNotEmpty) {
        mergedLocationData['locationId'] = locationId;
      }

      setState(() {
        _isUpdate = true;
        _exInspectionRequest = ExInspectionRequest(
          functionalAreaRequest:
              _mapLocationToFunctionalAreaRequest(mergedLocationData),
          equipmentTagRequest: _mapEquipmentTagRequest(assetDetails),
        );
        _isDataFetched = true;
      });
    }
    // else {
    //   throw Exception('Failed to load assets');
    // }
    // } catch (e) {
    //   throw Exception('Error fetching asset data: $e');
    // }
  }

  Future<void> _fetchLocationDataFromApi(String locationId) async {
    if (_isDataFetched) return;
    try {
      Map<String, dynamic> locationData = {};
      final LocationService locationService = LocationService();
      final locationResponse = await locationService.fetchLocationById(
        locationId: locationId,
      );
      if (locationResponse.containsKey('data')) {
        locationData = locationResponse['data'];
      }
      setState(() {
        _isUpdate = true;
        final faReq = locationId.isNotEmpty
            ? _mapLocationToFunctionalAreaRequest(locationData)
            : null;
        if (faReq != null) {
          faReq.locationId = locationId;
        }

        if (_exInspectionRequest.equipmentTagRequest == null) {
          _initializeExInspectionRequest();
        }

        _exInspectionRequest = ExInspectionRequest(
          functionalAreaRequest: faReq,
          equipmentTagRequest: _exInspectionRequest.equipmentTagRequest,
          inspectionChecklistRequest:
              _exInspectionRequest.inspectionChecklistRequest,
        );
        if (_exInspectionRequest.equipmentTagRequest != null) {
          _exInspectionRequest.equipmentTagRequest!.locationId = locationId;
        }

        _isDataFetched = true;
        if (widget.locationId != null && widget.locationId!.isNotEmpty) {
          for (int i = 0; i < _stepTitles.length; i++) {
            if (i == 0 &&
                _exInspectionRequest.functionalAreaRequest != null &&
                _exInspectionRequest.functionalAreaRequest!.location.isNotEmpty) {
              _stepCompleted[i] = true;
            } else {
              _stepCompleted[i] = false;
            }
          }
        }
      });
    } catch (e) {
      throw Exception('Error fetching asset data: $e');
    }
  }

  Future<void> _fetchLocationDataFromOffline(String locationId) async {
    if (_isDataFetched) return;
    final String? userType = await authUtils.getUserType();

    List<Map<String, dynamic>> results = (userType == 'onshore')
        ? await _dbHelper.getFunctionalAreaOnshore()
        : await _dbHelper.getFunctionalArea();
    Map<String, dynamic> locationData = {};
    String matchedLocationId = locationId;

    for (var record in results) {
      dynamic functionalAreaJson = record['functional_area_json'];
      Map<String, dynamic> jsonMap = CommonFunctions().decodeJson(
        functionalAreaJson,
      );
      final loc = (jsonMap['location'] is Map)
          ? Map<String, dynamic>.from(jsonMap['location'])
          : Map<String, dynamic>.from(jsonMap);
      final String? locId = loc['locationId']?.toString() ??
          loc['_id']?.toString() ??
          jsonMap['locationId']?.toString() ??
          jsonMap['_id']?.toString() ??
          record['id']?.toString();
      final String? rowId = record['id']?.toString();
      final String? locName = loc['location']?.toString();

      if (locId == locationId || rowId == locationId || locName == locationId) {
        locationData = loc;
        matchedLocationId = locId ?? rowId ?? locationId;
        locationData['locationId'] = matchedLocationId;
        break;
      }
    }

    setState(() {
      _isUpdate = true;
      final faReq = locationData.isNotEmpty
          ? _mapLocationToFunctionalAreaRequest(locationData)
          : null;
      if (faReq != null) {
        faReq.locationId = matchedLocationId;
      }

      if (_exInspectionRequest.equipmentTagRequest == null) {
        _initializeExInspectionRequest();
      }

      _exInspectionRequest = ExInspectionRequest(
        functionalAreaRequest: faReq,
        equipmentTagRequest: _exInspectionRequest.equipmentTagRequest,
        inspectionChecklistRequest:
            _exInspectionRequest.inspectionChecklistRequest,
      );
      if (_exInspectionRequest.equipmentTagRequest != null) {
        _exInspectionRequest.equipmentTagRequest!.locationId = matchedLocationId;
      }

      _isDataFetched = true;
      if (widget.locationId != null && widget.locationId!.isNotEmpty) {
        for (int i = 0; i < _stepTitles.length; i++) {
          if (i == 0 &&
              _exInspectionRequest.functionalAreaRequest != null &&
              _exInspectionRequest.functionalAreaRequest!.location.isNotEmpty) {
            _stepCompleted[i] = true;
          } else {
            _stepCompleted[i] = false;
          }
        }
      }
    });
  }

  Future<void> _fetchAssetDataFromOffline(String assetId) async {
    if (_isDataFetched) return;
    try {
      final String? userType = await authUtils.getUserType();
      final record = (userType == 'onshore')
          ? await _dbHelper.getExRegisterByIdOnshore(assetId)
          : await _dbHelper.getExRegisterById(assetId);
      Map<String, dynamic> assetDetails = {};
      if (record != null) {
        dynamic exRegisterJson = record['exregister_json'];
        Map<String, dynamic> jsonMap = (exRegisterJson is String)
            ? jsonDecode(exRegisterJson)
            : exRegisterJson as Map<String, dynamic>;
        assetDetails = (jsonMap['asset'] is Map)
            ? Map<String, dynamic>.from(jsonMap['asset'])
            : Map<String, dynamic>.from(jsonMap);
        final int rowId = record['id'] is int
            ? record['id']
            : int.tryParse(record['id'].toString()) ?? int.tryParse(assetId) ?? 0;
        assetDetails['primaryId'] = rowId;
        assetDetails['_id'] = rowId.toString();
      }

      if (assetDetails.isEmpty) {
        final woRows = (userType == 'onshore')
            ? await _dbHelper.getWorkOrderAssetsOnshore()
            : await _dbHelper.getWorkOrderAssets();
        for (final row in woRows) {
          if (row['id']?.toString() == assetId) {
            final raw = row['work_order_json'];
            if (raw != null) {
              final Map<String, dynamic> parsed = (raw is String)
                  ? jsonDecode(raw)
                  : Map<String, dynamic>.from(raw);
              if (parsed['asset'] is Map) {
                assetDetails = Map<String, dynamic>.from(parsed['asset']);
              } else if (parsed['assets'] is Map) {
                assetDetails = Map<String, dynamic>.from(parsed['assets']);
              } else {
                assetDetails = parsed;
              }
              break;
            }
          }
        }
      }

      String locationId = assetDetails['locationId']?.toString() ?? '';
      Map<String, dynamic> locationData = {};
      List<Map<String, dynamic>> functionalAreas = (userType == 'onshore')
          ? await _dbHelper.getFunctionalAreaOnshore()
          : await _dbHelper.getFunctionalArea();

      for (var record in functionalAreas) {
        dynamic functionalAreaJson = record['functional_area_json'];
        Map<String, dynamic> functionalAreaMap = CommonFunctions().decodeJson(
          functionalAreaJson,
        );
        final loc = (functionalAreaMap['location'] is Map)
            ? Map<String, dynamic>.from(functionalAreaMap['location'])
            : Map<String, dynamic>.from(functionalAreaMap);
        final String? locId = loc['locationId']?.toString() ??
            loc['_id']?.toString() ??
            functionalAreaMap['locationId']?.toString() ??
            functionalAreaMap['_id']?.toString() ??
            record['id']?.toString();
        final String? rowId = record['id']?.toString();
        final String? locName = loc['location']?.toString();

        if (locationId.isNotEmpty &&
            (locId == locationId || rowId == locationId || locName == locationId)) {
          locationData = loc;
          locationData['locationId'] = locId ?? rowId ?? locationId;
          break;
        }
      }

      if (locationData.isEmpty) {
        final targetLoc = assetDetails['location']?.toString();
        if (targetLoc != null && targetLoc.isNotEmpty) {
          for (var record in functionalAreas) {
            dynamic functionalAreaJson = record['functional_area_json'];
            Map<String, dynamic> functionalAreaMap = CommonFunctions().decodeJson(
              functionalAreaJson,
            );
            final loc = (functionalAreaMap['location'] is Map)
                ? Map<String, dynamic>.from(functionalAreaMap['location'])
                : Map<String, dynamic>.from(functionalAreaMap);
            if (loc['location']?.toString() == targetLoc) {
              locationData = loc;
              break;
            }
          }
        }
      }

      // Check work order assets table for any location details (drawings, gasGroup, etc.)
      if (locationData['subArea'] == null ||
          locationData['subArea'].toString().isEmpty ||
          locationData['locationGasGroup'] == null ||
          (locationData['locationGasGroup'] is List && (locationData['locationGasGroup'] as List).isEmpty) ||
          locationData['areaClassDrawNo'] == null ||
          (locationData['areaClassDrawNo'] is List && (locationData['areaClassDrawNo'] as List).isEmpty)) {
        try {
          final woRows = (userType == 'onshore')
              ? await _dbHelper.getWorkOrderAssetsOnshore()
              : await _dbHelper.getWorkOrderAssets();
          for (final row in woRows) {
            final raw = row['work_order_json'];
            if (raw == null) continue;
            final Map<String, dynamic> parsed = (raw is String)
                ? jsonDecode(raw)
                : Map<String, dynamic>.from(raw);
            final wo = parsed['workOrder'] is Map ? parsed['workOrder'] : parsed;
            final ass = parsed['asset'] is Map ? parsed['asset'] : (parsed['assets'] is Map ? parsed['assets'] : {});

            final match = (row['id']?.toString() == assetId) ||
                (ass['_id']?.toString() == assetId) ||
                (ass['id']?.toString() == assetId) ||
                (locationId.isNotEmpty && (ass['locationId']?.toString() == locationId || wo['locationId']?.toString() == locationId));

            if (match) {
              for (final src in [ass, wo]) {
                if (src is! Map) continue;
                for (final key in [
                  'subArea',
                  'locationGasGroup',
                  'locationTClass',
                  'locationIpRating',
                  'tAmbient',
                  'locationTAmbient',
                  'locationLatitude',
                  'locationLongitude',
                  'gpsCoordinates',
                  'gpsCord',
                  'areaClassDrawNo',
                  'areaClassDrawAttach',
                  'areaClassDrawAttachOrgName',
                  'eqpmtLytDrawNo',
                  'eqpmtLytDrawAttach',
                  'eqpmtLytDrawAttachOrgName',
                  'areaStatus',
                ]) {
                  final v = src[key];
                  if (v != null &&
                      (v is! String || v.isNotEmpty) &&
                      (v is! List || v.isNotEmpty)) {
                    if (locationData[key] == null ||
                        (locationData[key] is String && (locationData[key] as String).isEmpty) ||
                        (locationData[key] is List && (locationData[key] as List).isEmpty)) {
                      locationData[key] = v;
                    }
                  }
                }
              }
              break;
            }
          }
        } catch (_) {}
      }

      // If location area details are still missing, query LocationService
      if (locationId.isNotEmpty &&
          (locationData['subArea'] == null ||
              locationData['subArea'].toString().isEmpty ||
              locationData['locationGasGroup'] == null ||
              (locationData['locationGasGroup'] is List && (locationData['locationGasGroup'] as List).isEmpty) ||
              locationData['areaClassDrawNo'] == null ||
              (locationData['areaClassDrawNo'] is List && (locationData['areaClassDrawNo'] as List).isEmpty))) {
        try {
          final LocationService locationService = LocationService();
          final locResponse = await locationService.fetchLocationById(
            locationId: locationId,
          ).timeout(const Duration(seconds: 4));
          if (locResponse.containsKey('data') && locResponse['data'] is Map) {
            final locApiData = Map<String, dynamic>.from(locResponse['data']);
            locApiData.forEach((k, v) {
              if (v != null && v != '' && !(v is List && v.isEmpty)) {
                locationData[k] = v;
              }
            });
            locationData['locationId'] = locationId;

            // Cache back into SQLite functional_area
            try {
              final faPayload = {
                'functional_area_json': jsonEncode({'location': locationData}),
                'created_by': assetDetails['createdBy'] ?? 'system',
                'updated_by': assetDetails['createdBy'] ?? 'system',
              };
              if (userType == 'onshore') {
                final db = await _dbHelper.onshoreDatabase;
                await db.insert('functional_area_onshore', faPayload,
                    conflictAlgorithm: ConflictAlgorithm.replace);
              } else {
                final db = await _dbHelper.workOrderDatabase;
                await db.insert('functional_area', faPayload,
                    conflictAlgorithm: ConflictAlgorithm.replace);
              }
            } catch (_) {}
          }
        } catch (_) {}
      }

      final Map<String, dynamic> mergedLocationData =
          Map<String, dynamic>.from(locationData);
      assetDetails.forEach((k, v) {
        if (v != null &&
            (v is! String || v.isNotEmpty) &&
            (v is! List || v.isNotEmpty)) {
          if (!mergedLocationData.containsKey(k) ||
              mergedLocationData[k] == null ||
              (mergedLocationData[k] is String &&
                  (mergedLocationData[k] as String).isEmpty) ||
              (mergedLocationData[k] is List &&
                  (mergedLocationData[k] as List).isEmpty)) {
            mergedLocationData[k] = v;
          }
        }
      });

      // Also ensure assetDetails has all enriched location details
      mergedLocationData.forEach((k, v) {
        if (v != null &&
            (v is! String || v.isNotEmpty) &&
            (v is! List || v.isNotEmpty)) {
          if (!assetDetails.containsKey(k) ||
              assetDetails[k] == null ||
              (assetDetails[k] is String && (assetDetails[k] as String).isEmpty) ||
              (assetDetails[k] is List && (assetDetails[k] as List).isEmpty)) {
            assetDetails[k] = v;
          }
        }
      });

      final mappedFa = mergedLocationData.isNotEmpty
          ? _mapLocationToFunctionalAreaRequest(mergedLocationData)
          : null;
      if (mappedFa != null && locationId.isNotEmpty) {
        mappedFa.locationId = locationId;
      }
      final mappedEq = _mapEquipmentTagRequest(assetDetails);
      if (locationId.isNotEmpty) {
        mappedEq.locationId = locationId;
      }

      setState(() {
        _isUpdate = true;
        _exInspectionRequest = ExInspectionRequest(
          functionalAreaRequest: mappedFa,
          equipmentTagRequest: mappedEq,
        );
        _isDataFetched = true;

        if (widget.assetId != null && widget.assetId!.isNotEmpty) {
          _isUpdate = true;
          for (int i = 0; i < _stepTitles.length; i++) {
            if (i == 0 &&
                _exInspectionRequest.equipmentTagRequest!.location.isNotEmpty) {
              //   _exInspectionRequest
              // .equipmentTagRequest!.locationTAmbient.isNotEmpty
              _stepCompleted[i] = true;
            } else if (i == 1 &&
                _exInspectionRequest
                    .equipmentTagRequest!.description.isNotEmpty) {
              _stepCompleted[i] = true;
            } else if (i == 2 &&
                    _exInspectionRequest
                        .equipmentTagRequest!.checkList!.isNotEmpty ||
                i ==
                        2 &&
                    _exInspectionRequest.equipmentTagRequest!.inspectionType
                        .toString()
                        .isNotEmpty &&
                    _exInspectionRequest
                        .equipmentTagRequest!.eqpmtTag
                        .toString()
                        .isNotEmpty &&
                    _exInspectionRequest.equipmentTagRequest!
                        .inspectionChecklistType.isNotEmpty &&
                    _exInspectionRequest.equipmentTagRequest!.inspectionGrade
                        .toString()
                        .isNotEmpty) {
              //    _exInspectionRequest
              // .equipmentTagRequest!.checkList!.isNotEmpty //laksmana kumar
              // if (_exInspectionRequest
              //     .equipmentTagRequest!.checkList![0].defectCodes.isNotEmpty) {
              //   _stepCompleted[i] = true;
              // } else {
              //   _stepCompleted[i] = false;
              // }
              _stepCompleted[i] = true;
            } else if (i == 3 &&
                (_exInspectionRequest.equipmentTagRequest!.inspectedDate !=
                    "")) {
              // ||
              //                     _exInspectionRequest
              //                             .equipmentTagRequest!.inspectionStatus !=
              //                         ""
              _stepCompleted[i] = true;
            } else if (i == 4 &&
                (_exInspectionRequest.equipmentTagRequest!.repairedDate !=
                    "")) {
              // ||
              //                     _exInspectionRequest
              //                             .equipmentTagRequest!.inspectionStatus !=
              //                         ""
              _stepCompleted[i] = true;
            } else if (i == 5 &&
                _exInspectionRequest.equipmentTagRequest!.rbiStrategy != null) {
              _stepCompleted[i] = true;
            } else {
              _stepCompleted[i] = false;
            }
          }
        }
      });
    } catch (e) {
      throw Exception('Error fetching asset data from offline: $e');
    }
  }

  // Map<String, dynamic> _decodeJson(dynamic json) {
  //   Map<String, dynamic> jsonMap = {};
  //   if (json is String) {
  //     try {
  //       jsonMap = jsonDecode(json);
  //     } catch (e) {
  //       throw FormatException("Invalid JSON string: $json");
  //     }
  //   } else if (json is Map<String, dynamic>) {
  //     jsonMap = json;
  //   } else {
  //     throw FormatException("Invalid type for JSON: ${json.runtimeType}");
  //   }
  //
  //   return jsonMap;
  // }

  List<String> _toListOfString(dynamic val) {
    if (val == null) return [];
    if (val is List) return val.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    if (val is String && val.trim().isNotEmpty) {
      if (val.contains(',')) {
        return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [val.trim()];
    }
    return [];
  }

  FunctionalAreaRequest _mapLocationToFunctionalAreaRequest(
    Map<String, dynamic> locationData,
  ) {
    String latitude = locationData['locationLatitude']?.toString() ?? '';
    String longitude = locationData['locationLongitude']?.toString() ?? '';
    final rawGps = locationData['gpsCoordinates'] ??
        locationData['gpsCord'] ??
        locationData['gps'];
    if ((latitude.isEmpty || longitude.isEmpty) && rawGps != null) {
      final gps = rawGps.toString();
      if (gps.contains(',')) {
        final parts = gps.split(',');
        latitude = parts[0].trim();
        longitude = parts[1].trim();
      }
    }

    final gasGroupVal = locationData['locationGasGroup'] ??
        locationData['gasGroup'] ??
        locationData['areaGasGroup'];
    final tClassVal = locationData['locationTClass'] ??
        locationData['tClass'] ??
        locationData['temperatureClass'] ??
        locationData['areaTClass'];
    final ipRatingVal = locationData['locationIpRating'] ??
        locationData['ipRating'] ??
        locationData['areaIpRating'];

    final areaDrawing = locationData['areaClassificationDrawing']?.toString() ??
        locationData['areaClassificationDrawingNo']?.toString();
    final eqDrawing = locationData['equipmentLayoutDrawing']?.toString() ??
        locationData['equipmentLayoutDrawingNo']?.toString();

    List<String> areaClassDrawNo =
        _toListOfString(locationData['areaClassDrawNo']);
    if (areaClassDrawNo.isEmpty && areaDrawing != null && areaDrawing.isNotEmpty) {
      areaClassDrawNo = [areaDrawing];
    }
    List<String> areaClassDrawAttachOrgName =
        _toListOfString(locationData['areaClassDrawAttachOrgName']);
    if (areaClassDrawAttachOrgName.isEmpty &&
        areaDrawing != null &&
        areaDrawing.isNotEmpty) {
      areaClassDrawAttachOrgName = [areaDrawing];
    }

    List<String> eqpmtLytDrawNo =
        _toListOfString(locationData['eqpmtLytDrawNo']);
    if (eqpmtLytDrawNo.isEmpty && eqDrawing != null && eqDrawing.isNotEmpty) {
      eqpmtLytDrawNo = [eqDrawing];
    }
    List<String> eqpmtLytDrawAttachOrgName =
        _toListOfString(locationData['eqpmtLytDrawAttachOrgName']);
    if (eqpmtLytDrawAttachOrgName.isEmpty &&
        eqDrawing != null &&
        eqDrawing.isNotEmpty) {
      eqpmtLytDrawAttachOrgName = [eqDrawing];
    }

    return FunctionalAreaRequest(
      location: locationData['location']?.toString() ?? '',
      area: (locationData['subLocation'] ??
              locationData['platform'] ??
              locationData['area'])
              ?.toString() ??
          '',
      deckLevel: (locationData['deckLevel'] ??
              (locationData['subLocation'] != null
                  ? locationData['area']
                  : null))
              ?.toString() ??
          '',
      subArea: locationData['subArea']?.toString() ?? '',
      zone: locationData['zone']?.toString() ?? '',
      locationGasGroup: _toListOfString(gasGroupVal),
      locationTClass: _toListOfString(tClassVal),
      locationIpRating: _toListOfString(ipRatingVal),
      tAmbient: (locationData['tAmbient'] ??
              locationData['locationTAmbient'] ??
              locationData['ambientTemperature'] ??
              '')
          .toString(),
      areaClassDrawAttach: _toListOfString(locationData['areaClassDrawAttach']),
      areaClassDrawNo: areaClassDrawNo,
      eqpmtLytDrawAttach: _toListOfString(locationData['eqpmtLytDrawAttach']),
      eqpmtLytDrawNo: eqpmtLytDrawNo,
      areaClassDrawAttachOrgName: areaClassDrawAttachOrgName,
      eqpmtLytDrawAttachOrgName: eqpmtLytDrawAttachOrgName,
      locationId: locationData['locationId']?.toString() ??
          locationData['_id']?.toString() ??
          locationData['id']?.toString() ??
          '',
      locationLatitude: latitude,
      locationLongitude: longitude,
      isActive: locationData['isActive'] ?? true,
      areaStatus: locationData['areaStatus'] ??
          (locationData['isActive'] == false ? 'In Active' : 'Active'),
    );
  }

  EquipmentTagRequest _mapEquipmentTagRequest(
    Map<String, dynamic> assetDetails,
  ) {
    String latitude = assetDetails['locationLatitude']?.toString() ?? '';
    String longitude = assetDetails['locationLongitude']?.toString() ?? '';
    final rawGps = assetDetails['gpsCord'] ??
        assetDetails['gpsCoordinates'] ??
        assetDetails['gps'];
    if ((latitude.isEmpty || longitude.isEmpty) && rawGps != null) {
      final gps = rawGps.toString();
      if (gps.contains(',')) {
        final parts = gps.split(',');
        latitude = parts[0].trim();
        longitude = parts[1].trim();
      }
    }

    final gasGroupVal = assetDetails['locationGasGroup'] ??
        assetDetails['gasGroup'] ??
        assetDetails['areaGasGroup'];
    final tClassVal = assetDetails['locationTClass'] ??
        assetDetails['tClass'] ??
        assetDetails['temperatureClass'] ??
        assetDetails['areaTClass'];
    final ipRatingVal = assetDetails['locationIpRating'] ??
        assetDetails['ipRating'] ??
        assetDetails['areaIpRating'];

    final areaDrawing = assetDetails['areaClassificationDrawing']?.toString() ??
        assetDetails['areaClassificationDrawingNo']?.toString();
    final eqDrawing = assetDetails['equipmentLayoutDrawing']?.toString() ??
        assetDetails['equipmentLayoutDrawingNo']?.toString();

    List<String> areaClassDrawNo =
        _toListOfString(assetDetails['areaClassDrawNo']);
    if (areaClassDrawNo.isEmpty && areaDrawing != null && areaDrawing.isNotEmpty) {
      areaClassDrawNo = [areaDrawing];
    }
    List<String> areaClassDrawAttachOrgName =
        _toListOfString(assetDetails['areaClassDrawAttachOrgName']);
    if (areaClassDrawAttachOrgName.isEmpty &&
        areaDrawing != null &&
        areaDrawing.isNotEmpty) {
      areaClassDrawAttachOrgName = [areaDrawing];
    }

    List<String> eqpmtLytDrawNo =
        _toListOfString(assetDetails['eqpmtLytDrawNo']);
    if (eqpmtLytDrawNo.isEmpty && eqDrawing != null && eqDrawing.isNotEmpty) {
      eqpmtLytDrawNo = [eqDrawing];
    }
    List<String> eqpmtLytDrawAttachOrgName =
        _toListOfString(assetDetails['eqpmtLytDrawAttachOrgName']);
    if (eqpmtLytDrawAttachOrgName.isEmpty &&
        eqDrawing != null &&
        eqDrawing.isNotEmpty) {
      eqpmtLytDrawAttachOrgName = [eqDrawing];
    }

    return EquipmentTagRequest(
      location: assetDetails['location'],
      area: (assetDetails['subLocation'] ??
              assetDetails['platform'] ??
              assetDetails['area'])
              ?.toString() ??
          '',
      subArea: assetDetails['subArea'],
      zone: assetDetails['zone'],
      isActive: assetDetails['isActive'] ?? true,
      locationGasGroup: _toListOfString(gasGroupVal),
      locationTAmbient: (assetDetails['locationTAmbient'] ??
              assetDetails['tAmbient'] ??
              assetDetails['ambientTemperature'] ??
              '')
          .toString(),
      locationTClass: _toListOfString(tClassVal),
      locationIpRating: _toListOfString(ipRatingVal),
      areaClassDrawAttach: _toListOfString(assetDetails['areaClassDrawAttach']),
      areaClassDrawAttachOrgName: areaClassDrawAttachOrgName,
      eqpmtLytDrawAttachOrgName: eqpmtLytDrawAttachOrgName,
      areaClassDrawNo: areaClassDrawNo,
      eqpmtLytDrawAttach: _toListOfString(assetDetails['eqpmtLytDrawAttach']),
      eqpmtLytDrawNo: eqpmtLytDrawNo,
      locationId: assetDetails['locationId']?.toString() ?? '',
      deckLevel: (assetDetails['deckLevel'] ??
              (assetDetails['subLocation'] != null
                  ? assetDetails['area']
                  : null))
              ?.toString() ??
          '',
      locationLatitude: latitude,
      locationLongitude: longitude,
      rfidRef: assetDetails['rfidRef'] ?? '',
      gpsCord: rawGps?.toString() ?? (latitude.isNotEmpty && longitude.isNotEmpty ? '$latitude, $longitude' : ''),
      eqpmtCatg: assetDetails['eqpmtCatg'] ?? '',
      eqpmtTag: assetDetails['eqpmtTag'] ?? '',
      circuitId: assetDetails['circuitId'] ?? '',
      cableId: assetDetails['cableId'] ?? '',
      equipmentCategory: assetDetails['equipmentCategory'] ?? '',
      description: assetDetails['description'] ?? '',
      manufacturer: assetDetails['manufacturer'] ?? '',
      type: assetDetails['type'] ?? '',
      serialNumber: assetDetails['serialNumber'] ?? assetDetails['serialNo'] ?? '',
      atexCatg: List<String>.from(assetDetails['atexCatg'] ?? []),
      epl: List<String>.from(assetDetails['epl'] ?? []),
      protectionStd: assetDetails['protectionStd'] ?? '',
      protectionType: List<String>.from(assetDetails['protectionType'] ?? []),
      equipmentGasGroup: List<String>.from(
        assetDetails['equipmentGasGroup'] ?? [],
      ),
      equipmentTClass: List<String>.from(assetDetails['equipmentTClass'] ?? []),
      equipmentIpRating: List<String>.from(
        assetDetails['equipmentIpRating'] ?? [],
      ),
      certfnBody: assetDetails['certfnBody'] ?? '',
      certfnNo: assetDetails['certfnNo'] ?? '',
      tAmbient: assetDetails['tAmbient'] ?? '',
      tAmbientEquip: assetDetails['tAmbientEquip'] ?? '',
      inspectionSignOff: assetDetails['inspectionSignOff'] ?? '',
      repairSignOff: assetDetails['repairSignOff'] ?? '',
      specialCond: assetDetails['specialCond'] ?? '',
      oracleId: assetDetails['oracleId'] ?? '',
      assetId: assetDetails['_id'],
      primaryId: assetDetails['primaryId'],
      isDuplicate: assetDetails['isDuplicate'] ?? false,
      yesNoSelection: assetDetails['yesNoSelection'] != null
          ? Map<String, dynamic>.from(assetDetails['yesNoSelection'] as Map)
          : {},
      checkList: (assetDetails['checkList'] as List<dynamic>? ?? [])
          .map(
            (item) => CheckList(
              defectCategory: item['defectCategoryCode'] ?? '',
              count: item['count'] as int? ?? 0,
              defectCodes: (item['defectCodes'] as List<dynamic>? ?? []).map((
                code,
              ) {
                return DefectCode(
                  id: code['_id'] ?? '',
                  yesNoSelection:
                      assetDetails['yesNoSelection'][code['defectCode']] ?? '',
                  checkListGroup: code['checkListGroup'] ?? '',
                  equipmentType: code['equipmentType'] ?? '',
                  checklistName: code['checklistName'] ?? '',
                  inspectionGrade: code['inspectionGrade'] ?? '',
                  inspectionType: code['inspectionType'] ?? '',
                  defectCode: code['defectCode'] ?? '',
                  findingsAndActions:
                      (code['findingsAndActions'] as List<dynamic>? ?? [])
                          .map(
                            (fa) => FindingAndAction(
                              id: fa['_id'] ?? '',
                              defectCode: fa['defectCode'] ?? '',
                              finding: fa['finding'] ?? '',
                              remedialAction: fa['remedialAction'] ?? '',
                              defectCategory: fa['defectCategory'] ?? '',
                              isDone: fa['isDone'] ?? false,
                              isSelected: fa['isSelected'] ?? false,
                              repairedAt: fa['repairedAt'],
                              repairedBy: fa['repairedBy'],
                              updatedAt: fa['updatedUp'],
                            ),
                          )
                          .toList(),
                  defectPriority: Map<String, dynamic>.from(
                    code['defectPriority'] ?? {},
                  ),
                );
              }).toList(),
            ),
          )
          .toList(),
      inspectedBy: assetDetails['inspectedBy'] ?? '',
      inspectedDate: assetDetails['inspectedDate'] ?? '',
      repairedBy: assetDetails['repairedBy'] ?? '',
      repairedDate: assetDetails['repairedDate'] ?? '',
      faultyItems: assetDetails['faultyItems']?.toString() ?? '',
      repairPriority: assetDetails['repairPriority']?.toString() ?? '',
      inspectionStatus: assetDetails['inspectionStatus'] ?? '',
      defectOverallCondition: assetDetails['defectOverallCondition'] ?? '',
      defectIsolation: assetDetails['defectIsolation'] ?? '',
      defectOtherRequirements: List<String>.from(
        assetDetails['defectOtherRequirements'] ?? [],
      ),
      remarks: assetDetails['remarks'] ?? '',
      dataSheet: assetDetails['dataSheet'] ?? '',
      dataSheetOrgName: assetDetails['dataSheetOrgName'] ?? '',
      dataSheetNo: assetDetails['dataSheetNo'] ?? '',
      defectivePhoto1: assetDetails['defectivePhoto1'] ?? '',
      defectivePhoto1OrgName: assetDetails['defectivePhoto1OrgName'] ?? '',
      defectivePhoto2: assetDetails['defectivePhoto2'] ?? '',
      defectivePhoto2OrgName: assetDetails['defectivePhoto2OrgName'] ?? '',
      defectivePhoto3: assetDetails['defectivePhoto3'] ?? '',
      defectivePhoto3OrgName: assetDetails['defectivePhoto3OrgName'] ?? '',
      defectivePhoto4: assetDetails['defectivePhoto4'] ?? '',
      defectivePhoto4OrgName: assetDetails['defectivePhoto4OrgName'] ?? '',
      defectivePhoto5: assetDetails['defectivePhoto5'] ?? '',
      defectivePhoto5OrgName: assetDetails['defectivePhoto5OrgName'] ?? '',
      defectivePhoto6: assetDetails['defectivePhoto6'] ?? '',
      defectivePhoto6OrgName: assetDetails['defectivePhoto6OrgName'] ?? '',
      materials: (assetDetails['materials'] as List<dynamic>?)
              ?.map(
                (material) => Materials(
                  partNumber: material['partNumber'] as String?,
                  description: material['description'] as String?,
                  manufacturer: material['manufacturer'] as String?,
                  certificationAttach:
                      material['certificationAttach'] as String?,
                  certificationOrgName:
                      material['certificationOrgName'] as String?,
                  unit: material['unit'] as String?,
                  quantity: material['quantity'] as String?,
                ),
              )
              .toList() ??
          [],
      existingFaults: assetDetails['existingFaults']?.toString() ?? '',
      correctiveDefectCategory: assetDetails['correctiveDefectCategory'] ?? '',
      currentStatus: assetDetails['currentStatus'] ?? '',
      correctiveOverallCondition:
          assetDetails['correctiveOverallCondition'] ?? '',
      correctiveisolation: assetDetails['correctiveisolation'] ?? '',
      correctiveOtherRequirements:
          assetDetails['correctiveOtherRequirements'] ?? '',
      repairsDone: assetDetails['repairsDone']?.toString() ?? '',
      correctivePhoto1: assetDetails['correctivePhoto1'] ?? '',
      correctivePhoto1OrgName: assetDetails['correctivePhoto1OrgName'] ?? '',
      correctivePhoto2: assetDetails['correctivePhoto2'] ?? '',
      correctivePhoto2OrgName: assetDetails['correctivePhoto2OrgName'] ?? '',
      correctivePhoto3: assetDetails['correctivePhoto3'] ?? '',
      correctivePhoto3OrgName: assetDetails['correctivePhoto3OrgName'] ?? '',
      correctivePhoto4: assetDetails['correctivePhoto4'] ?? '',
      correctivePhoto4OrgName: assetDetails['correctivePhoto4OrgName'] ?? '',
      correctivePhoto5: assetDetails['correctivePhoto5'] ?? '',
      correctivePhoto5OrgName: assetDetails['correctivePhoto5OrgName'] ?? '',
      correctivePhoto6: assetDetails['correctivePhoto6'] ?? '',
      correctivePhoto6OrgName: assetDetails['correctivePhoto6OrgName'] ?? '',
      areaStatus: assetDetails['areaStatus'],
      rbiStrategy: assetDetails['rbiStrategy'] != null
          ? RbiStrategy(
              equipmentCriticality: assetDetails['rbiStrategy']
                  ['equipmentCriticality'],
              faultCategory: assetDetails['rbiStrategy']['faultCategory'],
              failureHistory: assetDetails['rbiStrategy']['failureHistory'],
              equipmentAgening: assetDetails['rbiStrategy']['equipmentAgening'],
              envSeverity: assetDetails['rbiStrategy']['envSeverity'],
              protFlamambleAtom: assetDetails['rbiStrategy']
                  ['protFlamambleAtom'],
              ignitionSourceProb: assetDetails['rbiStrategy']
                  ['ignitionSourceProb'],
              ignitionFlask: assetDetails['rbiStrategy']['ignitionFlask'],
              operationalImpact: assetDetails['rbiStrategy']
                  ['operationalImpact'],
              remarks: assetDetails['rbiStrategy']['remarks'],
            )
          : null,
      additionalInfoForRepairs: assetDetails['additionalInfoForRepairs'] ?? '',
      remarksIfAny: assetDetails['remarksIfAny'] ?? '',
      supplementaryMaterialReq:
          (assetDetails['supplementaryMaterialReq'] as List<dynamic>?)
                  ?.map(
                    (material) => Materials(
                      partNumber: material['partNumber'] as String?,
                      description: material['description'] as String?,
                      manufacturer: material['manufacturer'] as String?,
                      certificationAttach:
                          material['certificationAttach'] as String?,
                      certificationOrgName:
                          material['certificationOrgName'] as String?,
                      unit: material['unit'] as String?,
                      quantity: material['quantity'] as String?,
                    ),
                  )
                  .toList() ??
              [],
      defectCertificationNo: assetDetails['defectCertificationNo'] ?? '',
      defectCertificationOrgName:
          assetDetails['defectCertificationOrgName'] ?? '',
      defectCertificationAttach:
          assetDetails['defectCertificationAttach'] ?? '',
      correctiveCertificationAttach:
          assetDetails['correctiveCertificationAttach'] ?? '',
      correctiveCertificationNo:
          assetDetails['correctiveCertificationNo'] ?? '',
      correctiveCertificationOrgName:
          assetDetails['correctiveCertificationOrgName'] ?? '',
      inspectionGrade: assetDetails['inspectionGrade'] ?? '',
      inspectionType: assetDetails['inspectionType'] ?? '',
      inspectionChecklistType: List<String>.from(
        assetDetails['inspectionChecklistType'] ?? [],
      ),
      equipmentEquipmentType: assetDetails['equipmentEquipmentType'] ?? '',
      defectDefectCategory: assetDetails['defectDefectCategory'] ?? '',
      repairDuration: assetDetails['repairDuration'] ?? '',
      repairTimeEstimate: assetDetails['repairTimeEstimate'] ?? '',
      inspectionPriority: assetDetails['inspectionPriority'],
    );
  }

  Future<void> _onSave() async {
    switch (_currentStep) {
      case 0:
        final functionalAreaStepState = _functionalAreaKey.currentState;
        if (functionalAreaStepState != null) {
          final success =
              await functionalAreaStepState.onSubmitFunctionalArea();
          _isStepDataSaved = success;
          if (_isStepDataSaved) {
            _hasValidationError = false;
            _isUpdate = true;
            _stepCompleted[0] = true;
          } else {
            _hasValidationError = true;
          }
        }
        break;
      case 1:
        final equipmentTagsStepState = _equipmentTagKey.currentState;
        if (equipmentTagsStepState != null) {
          equipmentTagsStepState.onSubmitEquipmentTag();
          _isStepDataSaved =
              equipmentTagsStepState.formKey.currentState?.validate() ?? false;
          if (_isStepDataSaved) {
            _hasValidationError = false;
            _stepCompleted[1] = true;
          } else {
            _hasValidationError = true;
          }
        }
        break;
      case 2:
        final inspectionChecklistState = _inspectionChecklistKey.currentState;
        if (inspectionChecklistState != null) {
          inspectionChecklistState.onSubmitEquipmentTag([], [], {}, 'save');

          _isStepDataSaved =
              (inspectionChecklistState.formKey.currentState?.validate() ??
                  false) &&
              inspectionChecklistState.checkLableFlag;
          checkInspection = inspectionChecklistState.checkLableFlag;
          if (_isStepDataSaved) {
            _hasValidationError = false;
            _stepCompleted[2] = true;
          } else {
            _hasValidationError = true;
          }
        }
        break;
      case 3:
        final defectAnalysisStepState = _defectAnalysisKey.currentState;
        if (defectAnalysisStepState != null) {
          defectAnalysisStepState.onSubmitDefectAnalysis(clearFlag: false);
          _isStepDataSaved = true;
          _hasValidationError = false;
          _stepCompleted[3] = true;
        }
        break;
      case 4:
        final correctiveActionStepState = _correctiveActionsKey.currentState;
        if (correctiveActionStepState != null) {
          correctiveActionStepState.onSubmitCorrectiveActions(
            clearFlag: false,
          );
          _isStepDataSaved = true;
          _hasValidationError = false;
          _stepCompleted[4] = true;
        }
        break;
      default:
        break;
    }
  }

  Future<void> _handleNext() async {
    await _onSave();
    if (_isStepDataSaved) {
      _hasValidationError = false;
      if (_currentStep == 3) {
        final defectAnalysisStepState = _defectAnalysisKey.currentState;
        if (defectAnalysisStepState != null &&
            defectAnalysisStepState.selectedDefectCategory ==
                'Not Applicable') {
          Fluttertoast.showToast(
            msg:
                "No corrective action needed as Repair Priority is 'Not Applicable'.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0,
          );
          return;
        }
      }

      if (_currentStep < _stepTitles.length - 1) {
        setState(() {
          _stepCompleted[_currentStep] = true;
          _currentStep++;
          _isStepDataSaved = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: "Ex Inspection Submitted successfully.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 15.0,
        );

        // Navigate to home screen
        Get.offAllNamed(
          '/home',
          arguments: {
            'menu': 'Ex Register',
            'isCollapsed': true,
            'isSelectedScreenFlag': true,
            'filter': 'Show All',
            'fltertype': 'Year to Date',
          },
        );
      }
    } else {
      setState(() {
        _hasValidationError = true;
      });
    }
  }

  bool _isStepDataAvailable(int stepIndex) {
    switch (stepIndex) {
      case 0:
        final req = _exInspectionRequest.functionalAreaRequest;
        return req != null &&
            req.location.isNotEmpty &&
            req.area.isNotEmpty &&
            req.zone.isNotEmpty &&
            req.locationGasGroup.isNotEmpty &&
            req.locationTClass.isNotEmpty;
      case 1:
        final req = _exInspectionRequest.equipmentTagRequest;
        return req != null &&
            req.eqpmtCatg.isNotEmpty &&
            req.description.isNotEmpty &&
            req.protectionStd != null &&
            req.protectionStd.toString().isNotEmpty &&
            req.atexCatg.isNotEmpty &&
            req.epl.isNotEmpty &&
            req.protectionType.isNotEmpty &&
            req.equipmentGasGroup.isNotEmpty &&
            req.equipmentTClass.isNotEmpty &&
            req.equipmentIpRating.isNotEmpty;
      case 2:
        final req = _exInspectionRequest.equipmentTagRequest;
        return req != null &&
            req.inspectionType != null &&
            req.inspectionType!.isNotEmpty &&
            req.inspectionGrade != null &&
            req.inspectionGrade!.isNotEmpty &&
            req.checkList != null &&
            req.checkList!.isNotEmpty;
      case 3:
        final req = _exInspectionRequest.equipmentTagRequest;
        return req != null &&
            req.defectDefectCategory != null &&
            req.defectDefectCategory.toString().isNotEmpty;
      case 4:
        return _exInspectionRequest.equipmentTagRequest != null;
      default:
        return false;
    }
  }

  Future<void> _navigateToStep(int stepIndex) async {
    if (stepIndex == _currentStep) return;

    if (stepIndex > 3) {
      final defectAnalysisStepState = _defectAnalysisKey.currentState;
      if (defectAnalysisStepState != null &&
          (defectAnalysisStepState.selectedDefectCategory == '' ||
              defectAnalysisStepState.selectedDefectCategory ==
                  'Not Applicable')) {
        Fluttertoast.showToast(
          msg:
              "No corrective action needed as Repair Priority is 'Not Applicable'.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 15.0,
        );
        return;
      }
    }

    if (stepIndex > _currentStep) {
      await _onSave();
      if (!_isStepDataSaved) {
        setState(() {
          _hasValidationError = true;
        });
        Fluttertoast.showToast(
          msg: "Please fill out all mandatory fields before proceeding.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0,
        );
        return;
      }

      for (int i = 0; i < stepIndex; i++) {
        if (!_isStepDataAvailable(i) && !_stepCompleted[i]) {
          Fluttertoast.showToast(
            msg: "Please complete ${_stepTitles[i]} before proceeding!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0,
          );
          setState(() {
            _currentStep = i;
            _hasValidationError = false;
            _isStepDataSaved = false;
          });
          return;
        }
      }

      setState(() {
        _currentStep = stepIndex;
        _hasValidationError = false;
        _isStepDataSaved = false;
      });
    } else if (stepIndex < _currentStep) {
      setState(() {
        _currentStep = stepIndex;
        _hasValidationError = false;
        _isStepDataSaved = false;
      });
    }
  }

  void _clearStep(int stepIndex) {
    switch (stepIndex) {
      case 0:
        final functionalAreaStepState = _functionalAreaKey.currentState;
        if (functionalAreaStepState != null) {
          functionalAreaStepState.clearFields();
          _isUpdate = false;
        }
        break;
      case 1:
        final equipmentTagsStepState = _equipmentTagKey.currentState;
        if (equipmentTagsStepState != null) {
          equipmentTagsStepState.clearFields();
        }
        break;
      case 2:
        final inspectionChecklistState = _inspectionChecklistKey.currentState;
        if (inspectionChecklistState != null) {
          inspectionChecklistState.clearFields();
        }
        break;
      case 3:
        final defectAnalysisStepState = _defectAnalysisKey.currentState;
        if (defectAnalysisStepState != null) {
          defectAnalysisStepState.clearFields();
        }
        break;
      case 4:
        final correctiveActionsStepState = _correctiveActionsKey.currentState;
        if (correctiveActionsStepState != null) {
          correctiveActionsStepState.clearFields();
        }
        break;
      // case 5:
      //   final rbiStrategyStepState = _rbiStrategyKey.currentState;
      //   if (rbiStrategyStepState != null) {
      //     rbiStrategyStepState.clearFields();
      //   }
      //   break;
      default:
        break;
    }
    _isStepDataSaved = false;
  }

  bool get _isChecklistEmpty {
    final checklist = _exInspectionRequest.equipmentTagRequest?.checkList;
    return checklist == null || checklist.isEmpty;
  }

  bool _isStepRestricted(int stepIndex) {
    final lastStepIndex = _stepTitles.length - 1;

    return _isChecklistEmpty && stepIndex >= lastStepIndex;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;
    double buttonFontSize = orientation == Orientation.portrait ? 16 : 18;
    double buttonPaddingVertical =
        orientation == Orientation.portrait ? 12 : 12;
    double buttonPaddingHorizontal =
        orientation == Orientation.portrait ? 16 : 20;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: screenWidth * 0.01,
            left: screenWidth * 0.01,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.02,
          ),
          child: Row(
            children: [
              Text(
                'Ex Inspection',
                style: GoogleFonts.inter(
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B2029),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 24.0,
                    left: 90,
                    right: 90,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      // Top Row: Circles and Dividers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_stepTitles.length * 2 - 1, (
                          index,
                        ) {
                          if (index.isEven) {
                            int stepIndex = index ~/ 2;
                            bool isActive = _currentStep == stepIndex;
                            bool isComplete = _stepCompleted[stepIndex];
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (stepIndex != _currentStep) {
                                  _navigateToStep(stepIndex);
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: isActive
                                    ? BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                        border: Border.all(
                                          color: const Color(0xFF002B5C),
                                          width: 2.0,
                                        ),
                                      )
                                    : null,
                                child: Center(
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isActive || isComplete
                                          ? const Color(0xFF002B5C)
                                          : Colors.white,
                                      border: !isActive && !isComplete
                                          ? Border.all(
                                              color: const Color(0xFF9C9C9C),
                                              width: 1.0,
                                            )
                                          : null,
                                    ),
                                    child: Center(
                                      child: (isEditModeNotifier.value &&
                                              isActive &&
                                              isComplete)
                                          ? SvgPicture.asset(
                                              'lib/src/features/ex_inspections/assets/stepper_edit.svg',
                                              width: screenWidth * 0.010,
                                              height: screenWidth * 0.010,
                                            )
                                          : isComplete
                                              ? Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: screenWidth * 0.014,
                                                )
                                              : Text(
                                                  (stepIndex + 1).toString(),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color:
                                                        isActive || isComplete
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFF9C9C9C),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            int dividerIndex = index ~/ 2;
                            bool isDividerComplete =
                                _stepCompleted[dividerIndex];
                            return Expanded(
                              child: isDividerComplete
                                  ? const Divider(
                                      color: Color(0xFF6B84A0),
                                      thickness: 1.8,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          35,
                                          (_) => const Text(
                                            '-',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            );
                          }
                        }),
                      ),

                      SizedBox(height: screenHeight * 0.015),

                      // Step Titles Below Circles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_stepTitles.length, (index) {
                          bool isActive = _currentStep == index;
                          bool isComplete = _stepCompleted[index];

                          return Transform.translate(
                            offset: Offset(
                              index == 0
                                  ? -screenWidth * 0.018
                                  : index == 1
                                      ? -screenWidth * 0.0001 * -120
                                      : index == 2
                                          ? -screenWidth * 0.00001 * -1800
                                          : index == 3
                                              ? -screenWidth * 0.000001 * -25000
                                              : index == 4
                                                  ? screenWidth * 0.04
                                                  : index ==
                                                          _stepTitles.length - 1
                                                      ? screenWidth * 0.025
                                                      : 0,
                              0,
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (_currentStep != index) {
                                  _navigateToStep(index);
                                }
                              },
                              child: Text(
                                _stepTitles[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.012,
                                  color: isActive || isComplete
                                      ? const Color(0xFF212121)
                                      : const Color(0xFF979797),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Step Content
                _currentStep < _stepTitles.length
                    ? _getStepContent(_currentStep)
                    : Container(),
              ],
            ),
          ),
        ),
        Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF2F2F7), width: 1)),
            boxShadow: [
              BoxShadow(
                color: Color(0x29002B5C),
                offset: Offset(0, -1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24,
              bottom: 16.0,
              top: 16.0,
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: isEditModeNotifier,
              builder: (context, isEditMode, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: isEditAreaModeNotifier,
                  builder: (context, isEditAreaMode, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          Row(
                            children: [
                              if (widget.locationId != null &&
                                  !isEditAreaMode) ...[
                                _buildStyledButton(
                                  text: 'Edit',
                                  onPressed: () {
                                    setState(() {
                                      // _isEditMode = true;
                                      isEditAreaModeNotifier.value = true;
                                    });
                                  },
                                  isPrimary: false,
                                  width: 92,
                                  height: 48,
                                  fontSize: buttonFontSize,
                                  paddingVertical: buttonPaddingVertical,
                                  paddingHorizontal: buttonPaddingHorizontal,
                                ),
                              ] else if (widget.assetId != null &&
                                  !isEditMode) ...[
                                _buildStyledButton(
                                  text: 'Edit',
                                  onPressed: () {
                                    setState(() {
                                      // _isEditMode = true;
                                      isEditModeNotifier.value = true;
                                    });
                                  },
                                  isPrimary: false,
                                  width: 92,
                                  height: 48,
                                  fontSize: buttonFontSize,
                                  paddingVertical: buttonPaddingVertical,
                                  paddingHorizontal: buttonPaddingHorizontal,
                                ),
                              ] else ...[
                                if (isEditMode) ...[
                                  _buildStyledButton(
                                    text: 'Clear',
                                    onPressed: () {
                                      _showDeleteConfirmation(context);
                                    },
                                    isPrimary: false,
                                    width: 92,
                                    height: 48,
                                    fontSize: buttonFontSize,
                                    paddingVertical: buttonPaddingVertical,
                                    paddingHorizontal: buttonPaddingHorizontal,
                                  ),
                                ],
                                const SizedBox(width: 24),
                                _buildStyledButton(
                                  text: 'Back',
                                  onPressed: () => setState(() {
                                    if (_currentStep > 0) {
                                      _currentStep--;
                                      _hasValidationError = false;
                                      _isStepDataSaved = false;
                                    }
                                  }),
                                  isPrimary: false,
                                  width: 89,
                                  height: 48,
                                  fontSize: buttonFontSize,
                                  paddingVertical: buttonPaddingVertical,
                                  paddingHorizontal: buttonPaddingHorizontal,
                                ),
                              ],
                              const SizedBox(width: 50),
                              if (_hasValidationError)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'lib/src/features/ex_inspections/assets/error_icon.svg',
                                      width: 18,
                                      height: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _currentStep == 2 && !checkInspection
                                          ? 'Please fill out all Checklist.'
                                          : 'Please fill out all mandatory fields(*) before proceeding.',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFF44336),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          )
                        else if (_currentStep == 0)
                          Row(
                            children: [
                              if (widget.locationId != null &&
                                  !isEditAreaMode) ...[
                                _buildStyledButton(
                                  text: 'Edit',
                                  onPressed: () {
                                    setState(() {
                                      // _isEditMode = true;
                                      isEditAreaModeNotifier.value = true;
                                    });
                                  },
                                  isPrimary: false,
                                  width: 92,
                                  height: 48,
                                  fontSize: buttonFontSize,
                                  paddingVertical: buttonPaddingVertical,
                                  paddingHorizontal: buttonPaddingHorizontal,
                                ),
                              ] else if (widget.assetId != null &&
                                  !isEditMode) ...[
                                _buildStyledButton(
                                  text: 'Edit',
                                  onPressed: () {
                                    setState(() {
                                      // _isEditMode = true;
                                      isEditModeNotifier.value = true;
                                    });
                                  },
                                  isPrimary: false,
                                  width: 92,
                                  height: 48,
                                  fontSize: buttonFontSize,
                                  paddingVertical: buttonPaddingVertical,
                                  paddingHorizontal: buttonPaddingHorizontal,
                                ),
                              ] else ...[
                                if (isEditMode) ...[
                                  _buildStyledButton(
                                    text: 'Clear',
                                    onPressed: () {
                                      _showDeleteConfirmation(context);
                                    },
                                    isPrimary: false,
                                    width: 92,
                                    height: 48,
                                    fontSize: buttonFontSize,
                                    paddingVertical: buttonPaddingVertical,
                                    paddingHorizontal: buttonPaddingHorizontal,
                                  ),
                                ],
                              ],
                              const SizedBox(width: 140),
                              if (_hasValidationError)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'lib/src/features/ex_inspections/assets/error_icon.svg',
                                      width: 18,
                                      height: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Please fill out all mandatory fields(*) before proceeding.',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFF44336),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            if (_currentStep != _stepTitles.length - 1)
                              if (widget.locationId != null &&
                                  !isEditAreaMode) ...[
                                if (_currentStep > 0) ...[
                                  _buildStyledButton(
                                    text: 'Back',
                                    onPressed: () => setState(() {
                                      if (_currentStep > 0) {
                                        _currentStep--;
                                        _hasValidationError = false;
                                        _isStepDataSaved = false;
                                      }
                                    }),
                                    isPrimary: false,
                                    width: 89,
                                    height: 48,
                                    fontSize: buttonFontSize,
                                    paddingVertical: buttonPaddingVertical,
                                    paddingHorizontal: buttonPaddingHorizontal,
                                  ),
                                ],
                              ] else if (widget.assetId != null &&
                                  !isEditMode) ...[
                                if (_currentStep > 0) ...[
                                  _buildStyledButton(
                                    text: 'Back',
                                    onPressed: () => setState(() {
                                      if (_currentStep > 0) {
                                        _currentStep--;
                                        _hasValidationError = false;
                                        _isStepDataSaved = false;
                                      }
                                    }),
                                    isPrimary: false,
                                    width: 89,
                                    height: 48,
                                    fontSize: buttonFontSize,
                                    paddingVertical: buttonPaddingVertical,
                                    paddingHorizontal: buttonPaddingHorizontal,
                                  ),
                                ],
                              ] else ...[
                                _buildStyledButton(
                                  text: 'Save',
                                  onPressed: () async {
                                    await _onSave();
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  isPrimary: false,
                                  width: 89,
                                  height: 48,
                                  fontSize: buttonFontSize,
                                  paddingVertical: buttonPaddingVertical,
                                  paddingHorizontal: buttonPaddingHorizontal,
                                ),
                              ],
                            if (_currentStep == _stepTitles.length - 1 &&
                                widget.assetId != null &&
                                !isEditMode) ...[
                              _buildStyledButton(
                                text: 'Back',
                                onPressed: () => setState(() {
                                  if (_currentStep > 0) {
                                    _currentStep--;
                                    _hasValidationError = false;
                                    _isStepDataSaved = false;
                                  }
                                }),
                                isPrimary: false,
                                width: 89,
                                height: 48,
                                fontSize: buttonFontSize,
                                paddingVertical: buttonPaddingVertical,
                                paddingHorizontal: buttonPaddingHorizontal,
                              ),
                            ],
                            const SizedBox(width: 24),
                            _buildStyledButton(
                              text: _currentStep == _stepTitles.length - 1
                                  ? 'Submit'
                                  : 'Next',
                              onPressed: () async {
                                if (_currentStep == 0) {
                                  setState(() {
                                    isEditAreaModeNotifier.value = true;
                                  });
                                }

                                await _handleNext();
                              },
                              isPrimary: true,
                              width: _currentStep == _stepTitles.length - 1
                                  ? 120
                                  : 120,
                              height: 48,
                              fontSize: buttonFontSize,
                              paddingVertical: buttonPaddingVertical,
                              paddingHorizontal: buttonPaddingHorizontal,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required double width,
    required double height,
    required double fontSize,
    required double paddingVertical,
    required double paddingHorizontal,
  }) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: Color(0xFF002B5C)),
          backgroundColor: isPrimary ? const Color(0xFF1E90FF) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFF002B5C),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _getStepContent(int step) {
    switch (step) {
      case 0:
        return FunctionalAreaStep(
          key: _functionalAreaKey,
          exInspectionRequest: _exInspectionRequest,
          isUpdate: _isUpdate,
          isEditModeNotifier: isEditModeNotifier,
          isEditAreaModeNotifier: isEditAreaModeNotifier,
        );
      case 1:
        return EquipmentTagsStep(
          key: _equipmentTagKey,
          exInspectionRequest: _exInspectionRequest,
          isUpdate: _isUpdate,
          isEditModeNotifier: isEditModeNotifier,
        );
      case 2:
        return InspectionChecklistStep(
          key: _inspectionChecklistKey,
          exInspectionRequest: _exInspectionRequest,
          isUpdate: _isUpdate,
          fromExRegister: widget.fromExRegister,
          assetId: widget.assetId ?? '',
          isEditModeNotifier: isEditModeNotifier,
        );
      case 3:
        return DefectAnalysisStep(
          key: _defectAnalysisKey,
          exInspectionRequest: _exInspectionRequest,
          isUpdate: _isUpdate,
          isEditModeNotifier: isEditModeNotifier,
        );
      case 4:
        return CorrectiveActionsStep(
          key: _correctiveActionsKey,
          exInspectionRequest: _exInspectionRequest,
          isUpdate: _isUpdate,
          isEditModeNotifier: isEditModeNotifier,
        );
      case 5:
        return RBIStrategyStep(
          key: _rbiStrategyKey,
          exInspectionRequest: _exInspectionRequest,
          isUpdate: _isUpdate,
          isEditModeNotifier: isEditModeNotifier,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            height: 219,
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: Color(0xFFF1F1F1),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(2, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 83,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Delete Confirmation',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF1C232E),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 0.07,
                                    letterSpacing: 0.90,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Do you want to clear all data?',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF3B475B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 0.11,
                                    letterSpacing: 0.70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF8C8C8C),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C1B2029),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Cancel',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: const Color(0xFF1C232E),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 0.08,
                                          letterSpacing: 0.80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _clearStep(_currentStep);
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1E90FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C1B2029),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Delete',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: const Color(0xFFFAFBFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 0.08,
                                          letterSpacing: 0.80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
