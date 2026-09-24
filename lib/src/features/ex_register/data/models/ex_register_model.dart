import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';

ExRegister exRegisterFromJson(String str) =>
    ExRegister.fromJson(json.decode(str));

String exRegisterToJson(ExRegister data) => json.encode(data.toJson());

class ExRegister {
  String id;
  final dynamic repairPriority;
  final dynamic defectDefectCategory;
  List<CheckList>? checkList;
  final List<Materials>? materials;
  List<Materials>? supplementaryMaterialReq;
  final int? primaryId;
  final String rfidRef;
  final String location;
  final String area;
  final String? deckLevel;
  final String zone;
  final dynamic subArea;
  final List<String> locationGasGroup;
  final List<String> locationIpRating;
  final List<String> locationTClass;
  final dynamic tAmbient;
  final dynamic tAmbientEquip;
  dynamic inspectionSignOff;
  dynamic repairSignOff;
  final String? eqpmtTag;
  final String description;
  final String manufacturer;
  final List<String> epl;
  String inspectionStatus;
  final dynamic existingFaults;
  String currentStatus;
  Map<String, dynamic>? yesNoSelection;
  final dynamic inspectionReferenceNumber;
  final dynamic status;
  final String eqpmtCatg;
  final dynamic oracleId;
  final dynamic equipmentEquipmentType;
  final dynamic serialNumber;
  final List<String> atexCatg;
  final List<String> equipmentGasGroup;
  final List<String> equipmentTClass;
  final List<String> equipmentIpRating;
  final dynamic specialCond;
  final dynamic inspectionType;
  final List<String> inspectionChecklistType;
  final dynamic inspectionGrade;
  final dynamic faultyItems;
  final dynamic defectOverallCondition;
  final dynamic defectIsolation;
  final List<String> defectOtherRequirements;
  final dynamic remarks;
  dynamic dataSheetNo;
  dynamic dataSheet;
  dynamic dataSheetOrgName;
  final dynamic inspectedBy;
  final dynamic inspectedDate;
  final dynamic repairsDone;
  final dynamic correctiveOverallCondition;
  // final dynamic remarks;
  final dynamic repairedBy;
  final dynamic repairedDate;
  final dynamic gpsCord;
  final dynamic protectionStd;
  final List<String> protectionType;
  final dynamic correctiveisolation;
  final dynamic correctiveOtherRequirements;
  String? defectivePhoto1;
  String? defectivePhoto1OrgName;
  String? defectivePhoto2;
  String? defectivePhoto2OrgName;
  String? defectivePhoto3;
  String? defectivePhoto3OrgName;
  String? defectivePhoto4;
  String? defectivePhoto4OrgName;
  String? defectivePhoto5;
  String? defectivePhoto5OrgName;
  String? defectivePhoto6;
  String? defectivePhoto6OrgName;
  String? defectCertificationNo;
  String? defectCertificationOrgName;
  String? defectCertificationAttach;
  String? correctiveCertificationNo;
  String? correctiveCertificationOrgName;
  String? correctiveCertificationAttach;
  String? correctivePhoto1;
  String? correctivePhoto1OrgName;
  String? correctivePhoto2;
  String? correctivePhoto2OrgName;
  String? correctivePhoto3;
  String? correctivePhoto3OrgName;
  String? correctivePhoto4;
  String? correctivePhoto4OrgName;
  String? correctivePhoto5;
  String? correctivePhoto5OrgName;
  String? correctivePhoto6;
  String? correctivePhoto6OrgName;
  RbiStrategy? rbiStrategy;
  String? additionalInfoForRepairs;
  List<String> areaClassDrawAttach;
  List<String> areaClassDrawNo;
  List<String> areaClassDrawAttachOrgName;
  List<String> eqpmtLytDrawAttachOrgName;
  List<String> eqpmtLytDrawAttach;
  List<String> eqpmtLytDrawNo;
  String locationId;
  final String? locationLatitude;
  final String? locationLongitude;
  final String? circuitId;
  final String? cableId;
  String? equipmentCategory;
  final String? type;
  final String? certfnBody;
  final String? certfnNo;
  final String? correctiveDefectCategory;
  String? createdBy;
  bool? isSubmit;
  String? repairDuration;
  String? repairTimeEstimate;
  String locationTAmbient;
  String? remarksIfAny;
  dynamic areaStatus;
  final bool isActive;
  int? inspectionPriority;
  String? signature;
  String? assignedTo;
  String? assignedUserId;
  String? userId;
  String? inspectedId;
  String? inspectorId;
  dynamic assignedTeam;

  ExRegister({
    required this.id,
    this.primaryId,
    required this.rfidRef,
    required this.isActive,
    required this.location,
    required this.area,
    this.deckLevel,
    required this.zone,
    this.eqpmtTag,
    required this.description,
    required this.manufacturer,
    required this.epl,
    required this.inspectionStatus,
    required this.existingFaults,
    required this.currentStatus,
    this.yesNoSelection,
    this.inspectionReferenceNumber,
    this.subArea,
    required this.locationGasGroup,
    required this.locationIpRating,
    required this.locationTClass,
    this.tAmbient,
    this.tAmbientEquip,
    this.inspectionSignOff,
    this.repairSignOff,
    required this.areaClassDrawNo,
    required this.eqpmtLytDrawNo,
    this.status,
    required this.eqpmtCatg,
    this.oracleId,
    this.equipmentEquipmentType,
    this.serialNumber,
    required this.atexCatg,
    required this.equipmentGasGroup,
    required this.equipmentTClass,
    required this.equipmentIpRating,
    this.specialCond,
    this.inspectionType,
    required this.inspectionChecklistType,
    this.inspectionGrade,
    this.faultyItems,
    this.repairPriority,
    this.defectOverallCondition,
    this.defectIsolation,
    required this.defectOtherRequirements,
    this.remarks,
    this.dataSheet,
    required this.checkList,
    this.materials,
    this.supplementaryMaterialReq,
    this.inspectedBy,
    this.inspectedDate,
    this.repairsDone,
    this.defectDefectCategory,
    this.correctiveOverallCondition,
    // this.remarks,
    this.repairedBy,
    this.repairedDate,
    this.gpsCord,
    this.protectionStd,
    required this.protectionType,
    this.correctiveisolation,
    this.correctiveOtherRequirements,
    this.defectivePhoto1,
    this.rbiStrategy,
    this.correctiveCertificationNo,
    this.correctiveCertificationOrgName,
    this.correctiveCertificationAttach,
    this.defectCertificationAttach,
    this.defectCertificationOrgName,
    this.dataSheetOrgName,
    this.dataSheetNo,
    this.correctivePhoto3,
    this.correctivePhoto2,
    this.correctivePhoto1OrgName,
    this.correctivePhoto1,
    this.defectivePhoto6,
    this.defectivePhoto5,
    this.defectivePhoto4,
    this.defectivePhoto3,
    this.correctiveDefectCategory,
    this.type,
    this.defectCertificationNo,
    required this.eqpmtLytDrawAttachOrgName,
    required this.areaClassDrawAttachOrgName,
    required this.eqpmtLytDrawAttach,
    required this.areaClassDrawAttach,
    this.locationLongitude,
    this.locationLatitude,
    this.correctivePhoto3OrgName,
    this.correctivePhoto2OrgName,
    this.defectivePhoto3OrgName,
    this.defectivePhoto2OrgName,
    this.defectivePhoto1OrgName,
    this.certfnNo,
    this.certfnBody,
    this.circuitId,
    this.cableId,
    this.equipmentCategory,
    this.additionalInfoForRepairs,
    required this.locationId,
    this.defectivePhoto2,
    this.correctivePhoto4,
    this.correctivePhoto4OrgName,
    this.correctivePhoto5,
    this.correctivePhoto5OrgName,
    this.correctivePhoto6,
    this.correctivePhoto6OrgName,
    this.defectivePhoto4OrgName,
    this.defectivePhoto5OrgName,
    this.defectivePhoto6OrgName,
    this.isSubmit,
    this.repairTimeEstimate,
    this.repairDuration,
    this.areaStatus,
    required this.locationTAmbient,
    this.remarksIfAny,
    this.inspectionPriority,
    this.signature,
    this.assignedTo,
    this.assignedUserId,
    this.userId,
    this.inspectedId,
    this.inspectorId,
    this.assignedTeam,
  });

  factory ExRegister.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id']?.toString() ??
        json['asset_id']?.toString() ??
        json['id']?.toString() ??
        json['primaryId']?.toString() ??
        '';
    final parsedPrimaryId = json['primaryId'] != null
        ? (json['primaryId'] is int
            ? json['primaryId'] as int
            : int.tryParse(json['primaryId'].toString()))
        : (json['id'] != null
            ? (json['id'] is int
                ? json['id'] as int
                : int.tryParse(json['id'].toString()))
            : null);

    return ExRegister(
      id: rawId,
      repairPriority: json['repairPriority'],
      defectDefectCategory: json['defectDefectCategory']?.toString() ?? '',
      primaryId: parsedPrimaryId,
      rfidRef: json['rfidRef']?.toString() ?? json['rfidReference']?.toString() ?? json['rfid']?.toString() ?? '',
      location: json['location']?.toString() ?? json['fieldName']?.toString() ?? json['locationName']?.toString() ?? '',
      area: (json['subLocation'] != null && json['subLocation'].toString().trim().isNotEmpty)
          ? json['subLocation'].toString()
          : (json['platform']?.toString() ??
              json['platformName']?.toString() ??
              json['area']?.toString() ??
              json['sublocationName']?.toString() ??
              json['areaName']?.toString() ??
              ''),
      deckLevel: (json['subLocation'] != null && json['subLocation'].toString().trim().isNotEmpty)
          ? (json['deckLevel']?.toString() ??
              json['deck']?.toString() ??
              json['deckLevelName']?.toString() ??
              (json['area']?.toString() != json['subLocation']?.toString() ? json['area']?.toString() : null) ??
              '')
          : (json['deckLevel']?.toString() ??
              json['deck']?.toString() ??
              json['deckLevelName']?.toString()),
      isActive: json['isActive'] == true || json['isActive'] == 1 || json['isActive'] == 'true' || json['isActive'] == '1',
      zone: json['zone']?.toString() ?? json['zoneName']?.toString() ?? '',
      eqpmtTag: json['eqpmtTag']?.toString() ?? json['equipmentTag']?.toString() ?? json['tagNo']?.toString() ?? json['equipmentTagNo']?.toString() ?? json['tagNumber']?.toString(),
      description: json['description']?.toString() ?? json['equipmentDescription']?.toString() ?? json['desc']?.toString() ?? '',
      manufacturer: json['manufacturer']?.toString() ?? json['equipmentManufacturer']?.toString() ?? json['mfg']?.toString() ?? '',
      epl: toStringList(json['epl']),
      inspectionStatus: json['inspectionStatus']?.toString() ?? '',
      existingFaults: json['existingFaults'],
      currentStatus: json['currentStatus']?.toString() ?? '',
      yesNoSelection:
          json.containsKey('yesNoSelection') && json['yesNoSelection'] != null
          ? Map<String, dynamic>.from(json['yesNoSelection'] as Map)
          : null,
      inspectionReferenceNumber: json['inspectionReferenceNumber']?.toString(),
      subArea: json['subArea']?.toString() ?? json['subAreaName']?.toString() ?? json['nearestLandmark']?.toString(),
      locationGasGroup: toStringList(json['locationGasGroup'] ?? json['gasGroup'] ?? json['areaGasGroup'] ?? json['locationGasGroups']),
      locationIpRating: toStringList(json['locationIpRating'] ?? json['ipRating'] ?? json['locationIpRatings']),
      locationTClass: toStringList(json['locationTClass'] ?? json['tClass'] ?? json['temperatureClass'] ?? json['tempClass'] ?? json['areaTClass'] ?? json['locationTClasses']),
      locationTAmbient: json['locationTAmbient']?.toString() ?? json['tAmbient']?.toString() ?? json['ambientTemperature']?.toString() ?? '',
      tAmbient: json['tAmbient']?.toString() ?? json['locationTAmbient']?.toString() ?? json['ambientTemperature']?.toString(),
      tAmbientEquip: json['tAmbientEquip']?.toString(),
      inspectionSignOff: json['inspectionSignOff']?.toString(),
      repairSignOff: json['repairSignOff']?.toString(),
      status: (json['status'] == null || json['status'] == 'null')
          ? null
          : json['status'].toString(),
      eqpmtCatg: json['eqpmtCatg']?.toString() ?? json['discipline']?.toString() ?? json['disciplineName']?.toString() ?? json['equipmentCategory']?.toString() ?? json['category']?.toString() ?? '',
      oracleId: json['oracleId']?.toString(),
      equipmentEquipmentType: json['equipmentEquipmentType']?.toString() ?? json['equipmentType']?.toString() ?? json['eqpmtType']?.toString(),
      serialNumber: json['serialNumber']?.toString() ?? json['serialNo']?.toString() ?? json['serial']?.toString(),
      atexCatg: toStringList(json['atexCatg']),
      equipmentGasGroup: toStringList(json['equipmentGasGroup'] ?? json['gasGroup']),
      equipmentTClass: toStringList(json['equipmentTClass'] ?? json['tClass'] ?? json['temperatureClass']),
      equipmentIpRating: toStringList(json['equipmentIpRating'] ?? json['ipRating']),
      specialCond: json['specialCond']?.toString(),
      inspectionType: json['inspectionType']?.toString(),
      inspectionChecklistType: toStringList(json['inspectionChecklistType']),
      inspectionGrade: json['inspectionGrade']?.toString(),
      faultyItems: json['faultyItems'],
      defectOverallCondition: json['defectOverallCondition']?.toString(),
      defectIsolation: json['defectIsolation']?.toString(),
      defectOtherRequirements: toStringList(json['defectOtherRequirements']),
      remarks: json['remarks']?.toString(),
      dataSheet: json['dataSheet']?.toString(),
      dataSheetNo: json['dataSheetNo']?.toString(),
      dataSheetOrgName: json['dataSheetOrgName']?.toString(),
      inspectedBy: json['inspectedBy']?.toString(),
      inspectedDate: json['inspectedDate']?.toString(),
      repairsDone: json['repairsDone']?.toString(),
      correctiveOverallCondition:
          json['correctiveOverallCondition']?.toString(),
      // remarks: json['remarks'],
      repairedBy: json['repairedBy']?.toString(),
      repairedDate: json['repairedDate']?.toString(),
      gpsCord: json['gpsCord']?.toString(),
      protectionStd: json['protectionStd']?.toString() ?? json['protectionStandard']?.toString(),
      protectionType: toStringList(json['protectionType'] ?? json['equipmentProtection'] ?? json['protection']),
      correctiveisolation: json['correctiveisolation'],
      correctiveOtherRequirements: json['correctiveOtherRequirements'],
      defectivePhoto1: json['defectivePhoto1']?.toString(),
      defectivePhoto1OrgName: json['defectivePhoto1OrgName']?.toString(),
      defectivePhoto2: json['defectivePhoto2']?.toString(),
      defectivePhoto2OrgName: json['defectivePhoto2OrgName']?.toString(),
      defectivePhoto3: json['defectivePhoto3']?.toString(),
      defectivePhoto3OrgName: json['defectivePhoto3OrgName']?.toString(),
      defectivePhoto4: json['defectivePhoto4']?.toString(),
      defectivePhoto4OrgName: json['defectivePhoto4OrgName']?.toString(),
      defectivePhoto5: json['defectivePhoto5']?.toString(),
      defectivePhoto5OrgName: json['defectivePhoto5OrgName']?.toString(),
      defectivePhoto6: json['defectivePhoto6']?.toString(),
      defectivePhoto6OrgName: json['defectivePhoto6OrgName']?.toString(),
      // materials: (json['materials'] as List<dynamic>?)
      checkList: (json['checkList'] as List<dynamic>?)
          ?.map((item) {
            if (item is CheckList) return item;
            if (item is Map<String, dynamic>) return CheckList.fromJson(item);
            if (item is Map) return CheckList.fromJson(Map<String, dynamic>.from(item));
            return null;
          })
          .whereType<CheckList>()
          .toList(),
      materials: (json['materials'] as List<dynamic>?)
          ?.map((x) {
            if (x is Materials) return x;
            if (x is Map<String, dynamic>) return Materials.fromJson(x);
            if (x is Map) return Materials.fromJson(Map<String, dynamic>.from(x));
            return null;
          })
          .whereType<Materials>()
          .toList(),
      supplementaryMaterialReq:
          (json['supplementaryMaterialReq'] as List<dynamic>?)
              ?.map((x) {
                if (x is Materials) return x;
                if (x is Map<String, dynamic>) return Materials.fromJson(x);
                if (x is Map) return Materials.fromJson(Map<String, dynamic>.from(x));
                return null;
              })
              .whereType<Materials>()
              .toList(),
      defectCertificationNo: json['defectCertificationNo']?.toString(),
      defectCertificationOrgName:
          json['defectCertificationOrgName']?.toString(),
      defectCertificationAttach: json['defectCertificationAttach']?.toString(),
      correctiveCertificationNo: json['correctiveCertificationNo']?.toString(),
      correctiveCertificationOrgName:
          json['correctiveCertificationOrgName']?.toString(),
      correctiveCertificationAttach:
          json['correctiveCertificationAttach']?.toString(),
      correctivePhoto1: json['correctivePhoto1']?.toString(),
      correctivePhoto1OrgName: json['correctivePhoto1OrgName']?.toString(),
      correctivePhoto2: json['correctivePhoto2']?.toString(),
      correctivePhoto2OrgName: json['correctivePhoto2OrgName']?.toString(),
      correctivePhoto3: json['correctivePhoto3']?.toString(),
      correctivePhoto3OrgName: json['correctivePhoto3OrgName']?.toString(),
      correctivePhoto4: json['correctivePhoto4']?.toString(),
      correctivePhoto4OrgName: json['correctivePhoto4OrgName']?.toString(),
      correctivePhoto5: json['correctivePhoto5']?.toString(),
      correctivePhoto5OrgName: json['correctivePhoto5OrgName']?.toString(),
      correctivePhoto6: json['correctivePhoto6']?.toString(),
      correctivePhoto6OrgName: json['correctivePhoto6OrgName']?.toString(),
      rbiStrategy: json['rbiStrategy'] != null
          ? (json['rbiStrategy'] is RbiStrategy
              ? json['rbiStrategy'] as RbiStrategy
              : RbiStrategy.fromJson(
                  json['rbiStrategy'] is Map<String, dynamic>
                      ? json['rbiStrategy'] as Map<String, dynamic>
                      : Map<String, dynamic>.from(json['rbiStrategy'] as Map),
                ))
          : null,
      areaClassDrawNo: toStringList(json['areaClassDrawNo'] ?? json['areaClassificationDrawingNo'] ?? json['areaClassificationDrawing'] ?? json['areaClassificationDrawNo']),
      eqpmtLytDrawNo: toStringList(json['eqpmtLytDrawNo'] ?? json['equipmentLayoutDrawingNo'] ?? json['equipmentLayoutDrawing'] ?? json['equipmentLayoutDrawNo']),
      areaClassDrawAttach: toStringList(json['areaClassDrawAttach'] ?? json['areaClassificationDrawingAttach'] ?? json['areaClassDrawAttachment']),
      areaClassDrawAttachOrgName: toStringList(
        json['areaClassDrawAttachOrgName'] ?? json['areaClassificationDrawingOrgName'] ?? json['areaClassDrawOrgName'],
      ),
      eqpmtLytDrawAttachOrgName: toStringList(
        json['eqpmtLytDrawAttachOrgName'] ?? json['equipmentLayoutDrawingOrgName'] ?? json['eqpmtLytDrawOrgName'],
      ),
      eqpmtLytDrawAttach: toStringList(json['eqpmtLytDrawAttach'] ?? json['equipmentLayoutDrawingAttach'] ?? json['eqpmtLytDrawAttachment']),
      locationId: json['locationId']?.toString() ?? json['location_id']?.toString() ?? json['functionalAreaId']?.toString() ?? '',
      locationLatitude: () {
        final lat = json['locationLatitude']?.toString() ?? json['latitude']?.toString();
        if (lat != null && lat.isNotEmpty && lat != 'null') return lat;
        final gps = json['gpsCord']?.toString() ?? json['gpsCoordinates']?.toString() ?? json['gps']?.toString();
        if (gps != null && gps.contains(',')) {
          return gps.split(',')[0].trim();
        }
        return null;
      }(),
      locationLongitude: () {
        final lon = json['locationLongitude']?.toString() ?? json['longitude']?.toString();
        if (lon != null && lon.isNotEmpty && lon != 'null') return lon;
        final gps = json['gpsCord']?.toString() ?? json['gpsCoordinates']?.toString() ?? json['gps']?.toString();
        if (gps != null && gps.contains(',')) {
          return gps.split(',')[1].trim();
        }
        return null;
      }(),
      circuitId: json['circuitId']?.toString(),
      cableId: json['cableId']?.toString(),
      equipmentCategory: json['equipmentCategory']?.toString(),
      type: json['type']?.toString(),
      certfnBody: json['certfnBody']?.toString(),
      certfnNo: json['certfnNo']?.toString(),
      areaStatus: (json['areaStatus'] == null || json['areaStatus'] == 'null')
          ? null
          : json['areaStatus'].toString(),
      correctiveDefectCategory: json['correctiveDefectCategory']?.toString(),
      isSubmit: json['isSubmit'] == true || json['isSubmit'] == 'true',
      repairTimeEstimate: json['repairTimeEstimate']?.toString(),
      repairDuration: json['repairDuration']?.toString(),
      remarksIfAny: json['remarksIfAny']?.toString(),
      inspectionPriority: json['inspectionPriority'] is int
          ? json['inspectionPriority'] as int
          : int.tryParse(json['inspectionPriority']?.toString() ?? ''),
      signature: json['signature']?.toString(),
      assignedTo: json['assignedTo']?.toString() ?? json['assigned_to']?.toString(),
      assignedUserId: json['assignedUserId']?.toString() ?? json['assigned_user_id']?.toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      inspectedId: json['inspectedId']?.toString() ?? json['inspected_id']?.toString() ?? json['inspectedBy']?.toString(),
      inspectorId: json['inspectorId']?.toString() ?? json['technicianId']?.toString(),
      assignedTeam: json['assignedTeam'] ?? json['assigendTeam'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'repairPriority': repairPriority,
      'defectDefectCategory': defectDefectCategory,
      'inspectionChecklistType': inspectionChecklistType,
      'inspectionType': inspectionType,
      'inspectionGrade': inspectionGrade,
      'yesNoSelection': yesNoSelection,
      'equipmentEquipmentType': equipmentEquipmentType,
      'materials': materials?.map((dynamic x) {
        if (x is Materials) return x.toJson();
        if (x is Map) return Map<String, dynamic>.from(x);
        try {
          return x.toJson();
        } catch (_) {
          return x;
        }
      }).toList(),
      'supplementaryMaterialReq': supplementaryMaterialReq?.map((dynamic x) {
        if (x is Materials) return x.toJson();
        if (x is Map) return Map<String, dynamic>.from(x);
        try {
          return x.toJson();
        } catch (_) {
          return x;
        }
      }).toList(),
      'checkList': checkList?.map((dynamic x) {
        if (x is CheckList) return x.toJson();
        if (x is Map) return Map<String, dynamic>.from(x);
        try {
          return x.toJson();
        } catch (_) {
          return x;
        }
      }).toList(),
      'primaryId': primaryId,
      'rfidRef': rfidRef,
      'location': location,
      'area': area,
      'subLocation': area,
      'platform': area,
      'deckLevel': deckLevel,
      'zone': zone,
      'locationTAmbient': locationTAmbient,
      'isActive': isActive,
      'eqpmtTag': eqpmtTag,
      'description': description,
      'manufacturer': manufacturer,
      'epl': epl,
      'inspectionStatus': inspectionStatus,
      'existingFaults': existingFaults,
      'currentStatus': currentStatus,
      'inspectionReferenceNumber': inspectionReferenceNumber,
      'subArea': subArea,
      'locationGasGroup': locationGasGroup,
      'locationIpRating': locationIpRating,
      'locationTClass': locationTClass,
      'tAmbient': tAmbient,
      'tAmbientEquip': tAmbientEquip,
      'inspectionSignOff': inspectionSignOff,
      'repairSignOff': repairSignOff,
      'areaClassDrawNo': areaClassDrawNo,
      'eqpmtLytDrawNo': eqpmtLytDrawNo,
      'status': status,
      'eqpmtCatg': eqpmtCatg,
      'oracleId': oracleId,
      'serialNumber': serialNumber,
      'atexCatg': atexCatg,
      'equipmentGasGroup': equipmentGasGroup,
      'equipmentTClass': equipmentTClass,
      'equipmentIpRating': equipmentIpRating,
      'specialCond': specialCond,
      'faultyItems': faultyItems,
      'defectOverallCondition': defectOverallCondition,
      'defectIsolation': defectIsolation,
      'defectOtherRequirements': defectOtherRequirements,
      'remarks': remarks,
      'dataSheet': dataSheet,
      'dataSheetNo': dataSheetNo,
      'dataSheetOrgName': dataSheetOrgName,
      'inspectedBy': inspectedBy,
      'inspectedDate': inspectedDate,
      'repairsDone': repairsDone,
      'correctiveOverallCondition': correctiveOverallCondition,
      // 'remarks': remarks,
      'repairedBy': repairedBy,
      'repairedDate': repairedDate,
      'gpsCord': gpsCord,
      'protectionStd': protectionStd,
      'protectionType': protectionType,
      'correctiveisolation': correctiveisolation,
      'correctiveOtherRequirements': correctiveOtherRequirements,
      'defectivePhoto1': defectivePhoto1,
      'defectivePhoto1OrgName': defectivePhoto1OrgName,
      'defectivePhoto2': defectivePhoto2,
      'defectivePhoto2OrgName': defectivePhoto2OrgName,
      'defectivePhoto3': defectivePhoto3,
      'defectivePhoto3OrgName': defectivePhoto3OrgName,
      'defectivePhoto4': defectivePhoto4,
      'defectivePhoto4OrgName': defectivePhoto4OrgName,
      'defectivePhoto5': defectivePhoto5,
      'defectivePhoto5OrgName': defectivePhoto5OrgName,
      'defectivePhoto6': defectivePhoto6,
      'defectivePhoto6OrgName': defectivePhoto6OrgName,
      'defectCertificationNo': defectCertificationNo,
      'defectCertificationOrgName': defectCertificationOrgName,
      'defectCertificationAttach': defectCertificationAttach,
      'correctiveCertificationNo': correctiveCertificationNo,
      'correctiveCertificationOrgName': correctiveCertificationOrgName,
      'correctiveCertificationAttach': correctiveCertificationAttach,
      'correctivePhoto1': correctivePhoto1,
      'correctivePhoto1OrgName': correctivePhoto1OrgName,
      'correctivePhoto2': correctivePhoto2,
      'correctivePhoto2OrgName': correctivePhoto2OrgName,
      'correctivePhoto3': correctivePhoto3,
      'correctivePhoto3OrgName': correctivePhoto3OrgName,
      'correctivePhoto4': correctivePhoto4,
      'correctivePhoto4OrgName': correctivePhoto4OrgName,
      'correctivePhoto5': correctivePhoto5,
      'correctivePhoto5OrgName': correctivePhoto5OrgName,
      'correctivePhoto6': correctivePhoto6,
      'correctivePhoto6OrgName': correctivePhoto6OrgName,
      'rbiStrategy': rbiStrategy?.toJson(),
      'additionalInfoForRepairs': additionalInfoForRepairs,
      'areaClassDrawAttach': areaClassDrawAttach,
      'areaClassDrawAttachOrgName': areaClassDrawAttachOrgName,
      'eqpmtLytDrawAttachOrgName': eqpmtLytDrawAttachOrgName,
      'eqpmtLytDrawAttach': eqpmtLytDrawAttach,
      'locationId': locationId,
      'locationLatitude': locationLatitude,
      'locationLongitude': locationLongitude,
      'circuitId': circuitId,
      'cableId': cableId,
      'equipmentCategory': equipmentCategory,
      'type': type,
      'certfnBody': certfnBody,
      'certfnNo': certfnNo,
      'areaStatus': areaStatus,
      'correctiveDefectCategory': correctiveDefectCategory,
      'isSubmit': isSubmit,
      'repairDuration': repairDuration,
      'repairTimeEstimate': repairTimeEstimate,
      'remarksIfAny': remarksIfAny,
      'inspectionPriority': inspectionPriority,
      'signature': signature,
      'assignedTo': assignedTo,
      'assignedUserId': assignedUserId,
      'userId': userId,
      'inspectedId': inspectedId,
      'inspectorId': inspectorId,
      'assignedTeam': assignedTeam,
    };
  }
}

List<String> toStringList(dynamic value) {
  if (value is List) {
    return value
        .where((e) => e != null)
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .toList();
  } else if (value is String) {
    final str = value.trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return [];
    if (str.contains(',')) {
      return str
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
          .toList();
    }
    return [str];
  } else {
    return [];
  }
}

AssetPopup assetPopupFromJson(String str) =>
    AssetPopup.fromJson(json.decode(str));

String assetPopupToJson(AssetPopup data) => json.encode(data.toJson());

class AssetPopup {
  List<Inspection> inspection;
  List<Completed> completed;
  List<Existing> existing;

  AssetPopup({
    required this.inspection,
    required this.completed,
    required this.existing,
  });

  factory AssetPopup.fromJson(Map<String, dynamic> json) => AssetPopup(
    inspection: List<Inspection>.from(
      json["inspection"].map((x) => Inspection.fromJson(x)),
    ),
    completed: List<Completed>.from(
      json["completed"].map((x) => Completed.fromJson(x)),
    ),
    existing: List<Existing>.from(
      json["existing"].map((x) => Existing.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "inspection": List<dynamic>.from(inspection.map((x) => x.toJson())),
    "completed": List<dynamic>.from(completed.map((x) => x.toJson())),
    "existing": List<dynamic>.from(existing.map((x) => x.toJson())),
  };
}

class Inspection {
  String defectCode;
  String finding;

  Inspection({required this.defectCode, required this.finding});

  factory Inspection.fromJson(Map<String, dynamic> json) =>
      Inspection(defectCode: json["defectCode"], finding: json["finding"]);

  Map<String, dynamic> toJson() => {
    "defectCode": defectCode,
    "finding": finding,
  };
}

class Completed {
  bool isDone;
  dynamic remedialAction;

  Completed({required this.isDone, required this.remedialAction});

  factory Completed.fromJson(Map<String, dynamic> json) => Completed(
    isDone: json["isDone"],
    remedialAction: json["remedialAction"] is List
        ? List<String>.from(json["remedialAction"])
        : json["remedialAction"],
  );

  Map<String, dynamic> toJson() => {
    "isDone": isDone,
    "remedialAction": remedialAction is List
        ? List<dynamic>.from(remedialAction as List<String>)
        : remedialAction,
  };
}

class Existing {
  String defectCode;
  String finding;

  Existing({required this.defectCode, required this.finding});

  factory Existing.fromJson(Map<String, dynamic> json) =>
      Existing(defectCode: json["defectCode"], finding: json["finding"]);

  Map<String, dynamic> toJson() => {
    "defectCode": defectCode,
    "finding": finding,
  };
}
