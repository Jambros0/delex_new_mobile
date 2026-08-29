class EquipmentTagRequest {
  final String location;
  final String area;
  final dynamic subArea;
  final String zone;
  final List<String> locationGasGroup;
  final List<String> locationTClass;
  final List<String> locationIpRating;
  final List<String> areaClassDrawAttach;
  final List<String> areaClassDrawNo;
  final List<String> areaClassDrawAttachOrgName;
  final List<String> eqpmtLytDrawAttachOrgName;
  final List<String> eqpmtLytDrawAttach;
  final List<String> eqpmtLytDrawNo;
  String locationId;
  final String deckLevel;
  final dynamic locationLatitude;
  final dynamic locationLongitude;
  final dynamic eqpmtLongitude;
  final dynamic eqpmtLatitude;
  final dynamic rfidRef;
  final dynamic gpsCord;
  final String eqpmtCatg;
  final dynamic eqpmtTag;
  final dynamic circuitId;
  final dynamic cableId;
  final String description;
  final dynamic manufacturer;
  final dynamic type;
  final dynamic serialNumber;
  final List<String> atexCatg;
  final List<String> epl;
  final dynamic protectionStd;
  final List<String> protectionType;
  final List<String> equipmentGasGroup;
  final List<String> equipmentTClass;
  final List<String> equipmentIpRating;
  final dynamic certfnBody;
  final dynamic certfnNo;
  final dynamic tAmbient;
  final dynamic tAmbientEquip;
  final dynamic inspectionSignOff;
  final dynamic repairSignOff;
  final dynamic specialCond;
  final dynamic oracleId;
  dynamic assetId;
  List<CheckList>? checkList;
  dynamic inspectedBy;
  dynamic inspectedDate;
  dynamic repairedBy;
  dynamic repairedDate;
  dynamic faultyItems;
  dynamic repairPriority;
  dynamic inspectionStatus;
  dynamic defectOverallCondition;
  dynamic defectIsolation;
  List<String> defectOtherRequirements;
  dynamic remarks;
  dynamic dataSheetNo;
  dynamic dataSheet;
  dynamic dataSheetOrgName;
  dynamic defectivePhoto1;
  dynamic defectivePhoto1OrgName;
  dynamic defectivePhoto2;
  dynamic defectivePhoto2OrgName;
  dynamic defectivePhoto3;
  dynamic defectivePhoto3OrgName;
  dynamic defectivePhoto4;
  dynamic defectivePhoto4OrgName;
  dynamic defectivePhoto5;
  dynamic defectivePhoto5OrgName;
  dynamic defectivePhoto6;
  dynamic defectivePhoto6OrgName;
  List<Materials>? materials;
  dynamic existingFaults;
  dynamic correctiveDefectCategory;
  dynamic currentStatus;
  dynamic correctiveOverallCondition;
  dynamic correctiveisolation;
  dynamic correctiveOtherRequirements;
  dynamic repairsDone;
  dynamic correctivePhoto1;
  dynamic correctivePhoto1OrgName;
  dynamic correctivePhoto2;
  dynamic correctivePhoto2OrgName;
  dynamic correctivePhoto3;
  dynamic correctivePhoto3OrgName;
  dynamic correctivePhoto4;
  dynamic correctivePhoto4OrgName;
  dynamic correctivePhoto5;
  dynamic correctivePhoto5OrgName;
  dynamic correctivePhoto6;
  dynamic correctivePhoto6OrgName;
  RbiStrategy? rbiStrategy;
  dynamic additionalInfoForRepairs;
  dynamic remarksIfAny;
  List<Materials>? supplementaryMaterialReq;
  dynamic defectCertificationNo;
  dynamic defectCertificationOrgName;
  dynamic defectCertificationAttach;
  dynamic correctiveCertificationNo;
  dynamic correctiveCertificationOrgName;
  dynamic correctiveCertificationAttach;
  dynamic equipmentEquipmentType;
  List<String> inspectionChecklistType;
  Map<String, dynamic> yesNoSelection;
  dynamic inspectionGrade;
  dynamic inspectionType;
  dynamic defectDefectCategory;
  dynamic primaryId;
  dynamic repairDuration;
  dynamic repairTimeEstimate;
  String locationTAmbient;
  dynamic inspectionPriority;
  dynamic equipmentCategory;
  final bool isActive;
  dynamic isDuplicate;
  dynamic inspectedId;
  dynamic areaStatus;
  EquipmentTagRequest({
    required this.location,
    required this.area,
    required this.isActive,
    this.subArea,
    required this.zone,
    this.defectDefectCategory,
    required this.locationGasGroup,
    required this.locationTClass,
    required this.locationIpRating,
    required this.areaClassDrawAttach,
    required this.areaClassDrawNo,
    required this.eqpmtLytDrawAttach,
    required this.eqpmtLytDrawNo,
    required this.areaClassDrawAttachOrgName,
    required this.eqpmtLytDrawAttachOrgName,
    required this.locationId,
    required this.deckLevel,
    this.rfidRef,
    this.gpsCord,
    required this.eqpmtCatg,
    this.eqpmtTag,
    this.circuitId,
    this.cableId,
    required this.description,
    this.manufacturer,
    this.type,
    this.serialNumber,
    required this.atexCatg,
    required this.epl,
    this.protectionStd,
    required this.protectionType,
    required this.equipmentGasGroup,
    required this.equipmentTClass,
    required this.equipmentIpRating,
    this.certfnBody,
    this.certfnNo,
    this.tAmbient,
    this.tAmbientEquip,
    this.inspectionSignOff,
    this.repairSignOff,
    this.specialCond,
    this.oracleId,
    this.assetId,
    this.checkList,
    required this.yesNoSelection,
    this.inspectedBy,
    this.inspectedDate,
    this.repairedBy,
    this.repairedDate,
    this.faultyItems,
    this.repairPriority,
    this.inspectionStatus,
    this.defectOverallCondition,
    this.defectIsolation,
    required this.defectOtherRequirements,
    this.remarks,
    this.dataSheet,
    this.dataSheetNo,
    this.dataSheetOrgName,
    this.defectivePhoto1,
    this.defectivePhoto1OrgName,
    this.defectivePhoto2,
    this.defectivePhoto2OrgName,
    this.defectivePhoto3,
    this.defectivePhoto3OrgName,
    this.defectivePhoto4,
    this.defectivePhoto4OrgName,
    this.defectivePhoto5,
    this.defectivePhoto5OrgName,
    this.defectivePhoto6,
    this.defectivePhoto6OrgName,
    this.existingFaults,
    this.correctiveDefectCategory,
    this.currentStatus,
    this.correctiveOverallCondition,
    this.correctiveisolation,
    this.correctiveOtherRequirements,
    this.repairsDone,
    this.correctivePhoto1,
    this.correctivePhoto1OrgName,
    this.correctivePhoto2,
    this.correctivePhoto2OrgName,
    this.correctivePhoto3,
    this.correctivePhoto3OrgName,
    this.correctivePhoto4,
    this.correctivePhoto4OrgName,
    this.correctivePhoto5,
    this.correctivePhoto5OrgName,
    this.correctivePhoto6,
    this.correctivePhoto6OrgName,
    this.rbiStrategy,
    this.additionalInfoForRepairs,
    this.remarksIfAny,
    this.supplementaryMaterialReq,
    this.materials,
    this.defectCertificationNo,
    this.defectCertificationOrgName,
    this.correctiveCertificationNo,
    this.correctiveCertificationOrgName,
    this.inspectionGrade,
    this.inspectionType,
    this.equipmentEquipmentType,
    required this.inspectionChecklistType,
    this.locationLongitude,
    this.locationLatitude,
    this.eqpmtLongitude,
    this.eqpmtLatitude,
    this.defectCertificationAttach,
    this.correctiveCertificationAttach,
    this.primaryId,
    this.repairDuration,
    this.repairTimeEstimate,
    required this.locationTAmbient,
    this.inspectionPriority,
    this.equipmentCategory,
    this.isDuplicate,
    this.inspectedId,
    this.areaStatus,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'location': location,
      'area': area,
      'zone': zone,
      'locationGasGroup': locationGasGroup,
      'locationTClass': locationTClass,
      'locationIpRating': locationIpRating,
      'locationTAmbient': locationTAmbient,
      'areaClassDrawAttach': areaClassDrawAttach,
      'areaClassDrawNo': areaClassDrawNo,
      'areaClassDrawAttachOrgName': areaClassDrawAttachOrgName,
      'eqpmtLytDrawAttachOrgName': eqpmtLytDrawAttachOrgName,
      'eqpmtLytDrawAttach': eqpmtLytDrawAttach,
      'eqpmtLytDrawNo': eqpmtLytDrawNo,
      'locationId': locationId,
      'deckLevel': deckLevel,
      'locationLongitude': locationLongitude,
      'locationLatitude': locationLatitude,
      'eqpmtLongitude': eqpmtLongitude,
      'eqpmtLatitude': eqpmtLatitude,
      'eqpmtCatg': eqpmtCatg,
      'description': description,
      'atexCatg': atexCatg,
      'epl': epl,
      'protectionType': protectionType,
      'yesNoSelection': yesNoSelection,
      "isDuplicate": isDuplicate,
      "inspectedId": inspectedId,
    };

    if (subArea != null) {
      data['subArea'] = subArea;
    }
    if (rfidRef != null) {
      data['rfidRef'] = rfidRef;
    }
    if (gpsCord != null) {
      data['gpsCord'] = gpsCord;
    }
    if (eqpmtTag != null) {
      data['eqpmtTag'] = eqpmtTag;
    }
    if (circuitId != null) {
      data['circuitId'] = circuitId;
    }
    if (cableId != null) {
      data['cableId'] = cableId;
    }
    if (manufacturer != null) {
      data['manufacturer'] = manufacturer;
    }
    if (type != null) {
      data['type'] = type;
    }
    if (serialNumber != null) {
      data['serialNumber'] = serialNumber;
    }
    if (protectionStd != null) {
      data['protectionStd'] = protectionStd;
    }
    data['equipmentGasGroup'] = equipmentGasGroup;
    data['equipmentTClass'] = equipmentTClass;
    data['equipmentIpRating'] = equipmentIpRating;
    if (certfnBody != null) {
      data['certfnBody'] = certfnBody;
    }
    if (certfnNo != null) {
      data['certfnNo'] = certfnNo;
    }
    if (tAmbient != null) {
      data['tAmbient'] = tAmbient;
    }
    if (tAmbientEquip != null) {
      data['tAmbientEquip'] = tAmbientEquip;
    }
    if (inspectionSignOff != null) {
      data['inspectionSignOff'] = inspectionSignOff;
    }
    if (repairSignOff != null) {
      data['repairSignOff'] = repairSignOff;
    }
    if (specialCond != null) {
      data['specialCond'] = specialCond;
    }
    if (oracleId != null) {
      data['oracleId'] = oracleId;
    }
    if (assetId != null) {
      data['_id'] = assetId;
    }
    if (checkList != null) {
      data['checkList'] =
          checkList?.map((item) => item.toJson()).toList() ?? [];
    }
    if (inspectedBy != null) {
      data['inspectedBy'] = inspectedBy;
    }
    if (inspectedDate != null) {
      data['inspectedDate'] = inspectedDate;
    }
    if (repairedBy != null) {
      data['repairedBy'] = repairedBy;
    }
    if (repairedDate != null) {
      data['repairedDate'] = repairedDate;
    }
    if (faultyItems != null) {
      data['faultyItems'] = faultyItems;
    }
    if (repairPriority != null) {
      data['repairPriority'] = repairPriority;
    }
    if (inspectionStatus != null) {
      data['inspectionStatus'] = inspectionStatus;
    }
    if (defectOverallCondition != null) {
      data['defectOverallCondition'] = defectOverallCondition;
    }
    if (defectIsolation != null) {
      data['defectIsolation'] = defectIsolation;
    }
    data['defectOtherRequirements'] = defectOtherRequirements;
    if (remarks != null) {
      data['remarks'] = remarks;
    }
    if (dataSheet != null) {
      data['dataSheet'] = dataSheet;
    }
    if (dataSheetNo != null) {
      data['dataSheetNo'] = dataSheetNo;
    }
    if (dataSheetOrgName != null) {
      data['dataSheetOrgName'] = dataSheetOrgName;
    }
    if (defectivePhoto1 != null) {
      data['defectivePhoto1'] = defectivePhoto1;
    }
    if (defectivePhoto1OrgName != null) {
      data['defectivePhoto1OrgName'] = defectivePhoto1OrgName;
    }
    if (defectivePhoto2 != null) {
      data['defectivePhoto2'] = defectivePhoto2;
    }
    if (defectivePhoto2OrgName != null) {
      data['defectivePhoto2OrgName'] = defectivePhoto2OrgName;
    }
    if (defectivePhoto3 != null) {
      data['defectivePhoto3'] = defectivePhoto3;
    }
    if (defectivePhoto3OrgName != null) {
      data['defectivePhoto3OrgName'] = defectivePhoto3OrgName;
    }
    if (defectivePhoto4 != null) {
      data['defectivePhoto4'] = defectivePhoto4;
    }
    if (defectivePhoto4OrgName != null) {
      data['defectivePhoto4OrgName'] = defectivePhoto4OrgName;
    }
    if (defectivePhoto5 != null) {
      data['defectivePhoto5'] = defectivePhoto5;
    }
    if (defectivePhoto5OrgName != null) {
      data['defectivePhoto5OrgName'] = defectivePhoto5OrgName;
    }
    if (defectivePhoto6 != null) {
      data['defectivePhoto6'] = defectivePhoto6;
    }
    if (defectivePhoto6OrgName != null) {
      data['defectivePhoto6OrgName'] = defectivePhoto6OrgName;
    }
    if (materials != null) {
      data['materials'] = materials;
    }
    if (existingFaults != null) {
      data['existingFaults'] = existingFaults;
    }
    if (correctiveDefectCategory != null) {
      data['correctiveDefectCategory'] = correctiveDefectCategory;
    }
    if (currentStatus != null) {
      data['currentStatus'] = currentStatus;
    }
    if (correctiveOverallCondition != null) {
      data['correctiveOverallCondition'] = correctiveOverallCondition;
    }
    if (correctiveisolation != null) {
      data['correctiveisolation'] = correctiveisolation;
    }
    if (correctiveOtherRequirements != null) {
      data['correctiveOtherRequirements'] = correctiveOtherRequirements;
    }
    if (repairsDone != null) {
      data['repairsDone'] = repairsDone;
    }
    if (correctivePhoto1 != null) {
      data['correctivePhoto1'] = correctivePhoto1;
    }
    if (correctivePhoto1OrgName != null) {
      data['correctivePhoto1OrgName'] = correctivePhoto1OrgName;
    }
    if (correctivePhoto2 != null) {
      data['correctivePhoto2'] = correctivePhoto2;
    }
    if (correctivePhoto2OrgName != null) {
      data['correctivePhoto2OrgName'] = correctivePhoto2OrgName;
    }
    if (correctivePhoto3 != null) {
      data['correctivePhoto3'] = correctivePhoto3;
    }
    if (correctivePhoto3OrgName != null) {
      data['correctivePhoto3OrgName'] = correctivePhoto3OrgName;
    }
    if (correctivePhoto4 != null) {
      data['correctivePhoto4'] = correctivePhoto4;
    }
    if (correctivePhoto4OrgName != null) {
      data['correctivePhoto4OrgName'] = correctivePhoto4OrgName;
    }
    if (correctivePhoto5 != null) {
      data['correctivePhoto5'] = correctivePhoto5;
    }
    if (correctivePhoto5OrgName != null) {
      data['correctivePhoto5OrgName'] = correctivePhoto5OrgName;
    }
    if (correctivePhoto6 != null) {
      data['correctivePhoto6'] = correctivePhoto6;
    }
    if (correctivePhoto6OrgName != null) {
      data['correctivePhoto6OrgName'] = correctivePhoto6OrgName;
    }
    if (rbiStrategy != null) {
      data['rbiStrategy'] = rbiStrategy;
    }
    if (additionalInfoForRepairs != null) {
      data['additionalInfoForRepairs'] = additionalInfoForRepairs;
    }
    if (remarksIfAny != null) {
      data['remarksIfAny'] = remarksIfAny;
    }
    if (supplementaryMaterialReq != null) {
      data['supplementaryMaterialReq'] = supplementaryMaterialReq;
    }
    if (defectCertificationOrgName != null) {
      data['defectCertificationOrgName'] = defectCertificationOrgName;
    }
    if (defectCertificationNo != null) {
      data['defectCertificationNo'] = defectCertificationNo;
    }
    if (defectCertificationAttach != null) {
      data['defectCertificationAttach'] = defectCertificationAttach;
    }
    if (correctiveCertificationNo != null) {
      data['correctiveCertificationNo'] = correctiveCertificationNo;
    }
    if (correctiveCertificationOrgName != null) {
      data['correctiveCertificationOrgName'] = correctiveCertificationOrgName;
    }
    if (correctiveCertificationAttach != null) {
      data['correctiveCertificationAttach'] = correctiveCertificationAttach;
    }
    data['inspectionChecklistType'] = inspectionChecklistType;
    if (inspectionType != null) {
      data['inspectionType'] = inspectionType;
    }
    if (inspectionGrade != null) {
      data['inspectionGrade'] = inspectionGrade;
    }
    if (equipmentEquipmentType != null) {
      data['equipmentEquipmentType'] = equipmentEquipmentType;
    }
    if (primaryId != null) {
      data['primaryId'] = primaryId;
    }
    if (repairDuration != null) {
      data['repairDuration'] = repairDuration;
    }
    if (equipmentCategory != null) {
      data['equipmentCategory'] = equipmentCategory;
    }
    if (repairTimeEstimate != null) {
      data['repairTimeEstimate'] = repairTimeEstimate;
    }
    if (inspectionPriority != null) {
      data['inspectionPriority'] = inspectionPriority;
    }
    if (areaStatus != null) {
      data['areaStatus'] = areaStatus;
    }
    data['isActive'] = isActive;
    return {'asset': data};
  }

  factory EquipmentTagRequest.fromJson(Map<String, dynamic> json) {
    return EquipmentTagRequest(
      assetId: json['_id'] ?? "",
      rfidRef: json['rfidRef'] ?? "",
      location: json['location'] ?? "",
      area: json['area'] ?? "",
      deckLevel: json['deckLevel'] ?? "",
      zone: json['zone'] ?? "",
      isActive: json['isActive'] ?? "",
      eqpmtTag: json['eqpmtTag'] ?? "",
      description: json['description'] ?? "",
      manufacturer: json['manufacturer'] ?? "",
      epl: List<String>.from(json['epl'] ?? []),
      faultyItems: json['faultyItems'],
      inspectionStatus: json['inspectionStatus'] ?? "",
      repairsDone: json['repairsDone'] ?? '',
      existingFaults: json['existingFaults'],
      currentStatus: json['currentStatus'] ?? "",
      subArea: json['subArea'] ?? "",
      locationGasGroup: List<String>.from(json['locationGasGroup'] ?? []),
      locationTAmbient: json['locationTAmbient'] ?? "",
      locationIpRating: List<String>.from(json['locationIpRating'] ?? []),
      locationTClass: List<String>.from(json['locationTClass'] ?? []),
      tAmbient: json['tAmbient'] ?? "",
      tAmbientEquip: json['tAmbientEquip'] ?? "",
      areaClassDrawNo: List<String>.from(json['areaClassDrawNo'] ?? []),
      eqpmtLytDrawNo: List<String>.from(json['eqpmtLytDrawNo'] ?? []),
      eqpmtCatg: json['eqpmtCatg'] ?? "",
      oracleId: json['oracleId'] ?? "",
      equipmentEquipmentType: json['equipmentEquipmentType'] ?? "",
      serialNumber: json['serialNumber'] ?? "",
      atexCatg: List<String>.from(json['atexCatg'] ?? []),
      equipmentGasGroup: List<String>.from(json['equipmentGasGroup'] ?? []),
      equipmentTClass: List<String>.from(json['equipmentTClass'] ?? []),
      equipmentIpRating: List<String>.from(json['equipmentIpRating'] ?? []),
      specialCond: json['specialCond'] ?? "",
      inspectionSignOff: json['inspectionSignOff'] ?? "",
      repairSignOff: json['repairSignOff'] ?? "",
      inspectionType: json['inspectionType'] ?? "",
      inspectionChecklistType: List<String>.from(
        json['inspectionChecklistType'] ?? [],
      ),
      inspectionGrade: json['inspectionGrade'] ?? "",
      repairPriority: json['repairPriority'] ?? "",
      defectOverallCondition: json['defectOverallCondition'] ?? "",
      defectIsolation: json['defectIsolation'] ?? "",
      defectOtherRequirements: List<String>.from(
        json['defectOtherRequirements'] ?? [],
      ),
      remarks: json['remarks'] ?? "",
      dataSheet: json['dataSheet'] ?? "",
      dataSheetNo: json['dataSheetNo'] ?? "",
      dataSheetOrgName: json['dataSheetOrgName'] ?? "",
      inspectedBy: json['inspectedBy'] ?? "",
      inspectedDate: json['inspectedDate'] ?? "",
      remarksIfAny: json['remarksIfAny'] ?? "",
      defectDefectCategory: json['defectDefectCategory'] ?? "",
      correctiveOverallCondition: json['correctiveOverallCondition'] ?? "",
      repairedBy: json['repairedBy'] ?? "",
      repairedDate: json['repairedDate'] ?? "",
      gpsCord: json['gpsCord'] ?? "",
      protectionStd: json['protectionStd'] ?? "",
      protectionType: List<String>.from(json['protectionType'] ?? []),
      equipmentCategory: json['equipmentCategory'] ?? "",
      correctiveisolation: json['correctiveisolation'] ?? "",
      correctiveOtherRequirements: json['correctiveOtherRequirements'] ?? "",
      defectivePhoto1: json['defectivePhoto1'] ?? "",
      defectivePhoto1OrgName: json['defectivePhoto1OrgName'] ?? "",
      defectivePhoto2: json['defectivePhoto2'] ?? "",
      defectivePhoto2OrgName: json['defectivePhoto2OrgName'] ?? "",
      defectivePhoto3: json['defectivePhoto3'] ?? "",
      defectivePhoto3OrgName: json['defectivePhoto3OrgName'] ?? "",
      defectivePhoto4: json['defectivePhoto4'] ?? "",
      defectivePhoto4OrgName: json['defectivePhoto4OrgName'] ?? "",
      defectivePhoto5: json['defectivePhoto5'] ?? "",
      defectivePhoto5OrgName: json['defectivePhoto5OrgName'] ?? "",
      defectivePhoto6: json['defectivePhoto6'] ?? "",
      defectivePhoto6OrgName: json['defectivePhoto6OrgName'] ?? "",
      materials: (json['materials'] as List<dynamic>?)
          ?.map((x) => Materials.fromJson(x as Map<String, dynamic>))
          .toList(),
      supplementaryMaterialReq: [],
      // (json['supplementaryMaterialReq'] as List<dynamic>?)
      //     ?.map((x) => Materials.fromJson(x as Map<String, dynamic>))
      //     .toList(),
      defectCertificationNo: json['defectCertificationNo'] ?? "",
      defectCertificationOrgName: json['defectCertificationOrgName'] ?? "",
      defectCertificationAttach: json['defectCertificationAttach'] ?? "",
      correctiveCertificationNo: json['correctiveCertificationNo'] ?? "",
      correctiveCertificationOrgName:
          json['correctiveCertificationOrgName'] ?? "",
      correctiveCertificationAttach:
          json['correctiveCertificationAttach'] ?? "",
      correctivePhoto1: json['correctivePhoto1'] ?? "",
      correctivePhoto1OrgName: json['correctivePhoto1OrgName'] ?? "",
      correctivePhoto2: json['correctivePhoto2'] ?? "",
      correctivePhoto2OrgName: json['correctivePhoto2OrgName'] ?? "",
      correctivePhoto3: json['correctivePhoto3'] ?? "",
      correctivePhoto3OrgName: json['correctivePhoto3OrgName'] ?? "",
      correctivePhoto4: json['correctivePhoto4'] ?? "",
      correctivePhoto4OrgName: json['correctivePhoto4OrgName'] ?? "",
      correctivePhoto5: json['correctivePhoto5'] ?? "",
      correctivePhoto5OrgName: json['correctivePhoto5OrgName'] ?? "",
      correctivePhoto6: json['correctivePhoto6'] ?? "",
      correctivePhoto6OrgName: json['correctivePhoto6OrgName'] ?? "",
      rbiStrategy: json['rbiStrategy'] != null
          ? RbiStrategy.fromJson(json['rbiStrategy'] as Map<String, dynamic>)
          : null,
      additionalInfoForRepairs: json['additionalInfoForRepairs'],
      areaClassDrawAttach: List<String>.from(json['areaClassDrawAttach'] ?? []),
      areaClassDrawAttachOrgName: List<String>.from(
        json['areaClassDrawAttachOrgName'] ?? [],
      ),
      eqpmtLytDrawAttachOrgName: List<String>.from(
        json['eqpmtLytDrawAttachOrgName'] ?? [],
      ),
      eqpmtLytDrawAttach: List<String>.from(json['eqpmtLytDrawAttach'] ?? []),
      locationId: json['locationId'] ?? "",
      locationLatitude: json['locationLatitude'] ?? "",
      locationLongitude: json['locationLongitude'] ?? "",
      eqpmtLatitude: json['eqpmtLatitude'] ?? "",
      eqpmtLongitude: json['eqpmtLongitude'] ?? "",
      circuitId: json['circuitId'] ?? "",
      cableId: json['cableId'] ?? "",
      type: json['type'] ?? "",
      certfnBody: json['certfnBody'] ?? "",
      certfnNo: json['certfnNo'] ?? "",
      areaStatus: json['areaStatus'] ?? "",
      correctiveDefectCategory: json['correctiveDefectCategory'] ?? "",
      checkList: json['checkList'] ?? [],
      yesNoSelection:
          (json['yesNoSelection'] as Map?)?.cast<String, dynamic>() ?? {},
      repairDuration: json['repairDuration'] ?? "",
      repairTimeEstimate: json['repairTimeEstimate'] ?? "",
      inspectionPriority: json['inspectionPriority'] ?? "",
      isDuplicate: json["isDuplicate"] ?? false,
      inspectedId: json["inspectedId"] ?? '',
    );
  }
}

class CheckList {
  final String defectCategory;
  int count;
  final List<DefectCode> defectCodes;

  CheckList({
    required this.defectCategory,
    required this.count,
    required this.defectCodes,
  });

  factory CheckList.fromJson(Map<String, dynamic> json) {
    return CheckList(
      defectCategory: json['defectCategoryCode'] ?? '',
      count: json['count'] ?? 0,
      defectCodes: (json['defectCodes'] as List<dynamic>?)
              ?.map((item) => DefectCode.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defectCategoryCode': defectCategory,
      'count': count,
      'defectCodes': defectCodes.map((item) => item.toJson()).toList(),
    };
  }
}

class DefectCode {
  final String id;
  final String checkListGroup;
  final String equipmentType;
  final String checklistName;
  final String inspectionGrade;
  final String inspectionType;
  final String defectCode;
  List<FindingAndAction> findingsAndActions;
  Map<String, dynamic> defectPriority;
  final dynamic yesNoSelection;
  DefectCode({
    required this.id,
    required this.checkListGroup,
    required this.equipmentType,
    required this.checklistName,
    required this.inspectionGrade,
    required this.inspectionType,
    required this.defectCode,
    required this.findingsAndActions,
    required this.defectPriority,
    this.yesNoSelection,
  });

  factory DefectCode.fromJson(Map<String, dynamic> json) {
    return DefectCode(
      id: json['_id'] ?? '',
      checkListGroup: json['checkListGroup'] ?? '',
      equipmentType: json['equipmentType'] ?? '',
      checklistName: json['checklistName'] ?? '',
      inspectionGrade: json['inspectionGrade'] ?? '',
      inspectionType: json['inspectionType'] ?? '',
      defectCode: json['defectCode'] ?? '',
      findingsAndActions: (json['findingsAndActions'] as List<dynamic>?)
              ?.map((item) => FindingAndAction.fromJson(item))
              .toList() ??
          [],
      defectPriority: json['defectPriority'] ?? {},
      yesNoSelection: json['yesNoSelection'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'checkListGroup': checkListGroup,
      'equipmentType': equipmentType,
      'checklistName': checklistName,
      'inspectionGrade': inspectionGrade,
      'inspectionType': inspectionType,
      'defectCode': defectCode,
      'findingsAndActions':
          findingsAndActions.map((item) => item.toJson()).toList(),
      'defectPriority': defectPriority.map(
        (key, value) => MapEntry(key, value),
      ),
      'yesNoSelection': yesNoSelection,
    };
  }
}

class FindingAndAction {
  final String id;
  final String defectCode;
  final String finding;
  final String remedialAction;
  final String defectCategory;
  bool isDone;
  bool isSelected;
  dynamic repairedAt;
  dynamic repairedBy;
  dynamic updatedAt;

  FindingAndAction({
    required this.id,
    required this.defectCode,
    required this.finding,
    required this.remedialAction,
    required this.defectCategory,
    this.isDone = false,
    this.isSelected = false,
    this.repairedAt,
    this.repairedBy,
    this.updatedAt,
  });

  factory FindingAndAction.fromJson(Map<String, dynamic> json) {
    bool done = json['isDone'] == true ||
        json['isDone'] == 'true' ||
        json['isDone'] == 1 ||
        json['isDone'] == '1';
    if (!done &&
        json['repairedBy'] != null &&
        json['repairedBy'].toString().isNotEmpty &&
        json['repairedBy'].toString() != 'null') {
      done = true;
    }
    bool selected = json['isSelected'] == true ||
        json['isSelected'] == 'true' ||
        json['isSelected'] == 1 ||
        json['isSelected'] == '1';

    return FindingAndAction(
      id: json['_id'] ?? json['id'] ?? '',
      defectCode: json['defectCode'] ?? '',
      finding: json['finding'] ?? '',
      remedialAction: json['remedialAction'] ?? '',
      defectCategory: json['defectCategory'] ?? '',
      isDone: done,
      isSelected: selected,
      repairedAt: json['repairedAt'],
      repairedBy: json['repairedBy'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'defectCode': defectCode,
      'finding': finding,
      'remedialAction': remedialAction,
      'defectCategory': defectCategory,
      'isDone': isDone,
      'isSelected': isSelected,
      'repairedAt': repairedAt,
      'repairedBy': repairedBy,
      'updatedAt': updatedAt,
    };
  }
}

class RbiStrategy {
  final dynamic equipmentCriticality;
  final dynamic faultCategory;
  final dynamic failureHistory;
  final dynamic equipmentAgening;
  final dynamic envSeverity;
  final dynamic protFlamambleAtom;
  final dynamic ignitionSourceProb;
  final dynamic ignitionFlask;
  final dynamic operationalImpact;
  final dynamic remarks;

  RbiStrategy({
    this.equipmentCriticality,
    this.faultCategory,
    this.failureHistory,
    this.equipmentAgening,
    this.envSeverity,
    this.protFlamambleAtom,
    this.ignitionSourceProb,
    this.ignitionFlask,
    this.operationalImpact,
    this.remarks,
  });

  factory RbiStrategy.fromJson(Map<String, dynamic> json) {
    return RbiStrategy(
      equipmentCriticality: json['equipmentCriticality'] as dynamic,
      faultCategory: json['faultCategory'] as dynamic,
      failureHistory: json['failureHistory'] as dynamic,
      equipmentAgening: json['equipmentAgening'] as dynamic,
      envSeverity: json['envSeverity'] as dynamic,
      protFlamambleAtom: json['protFlamambleAtom'] as dynamic,
      ignitionSourceProb: json['ignitionSourceProb'] as dynamic,
      ignitionFlask: json['ignitionFlask'] as dynamic,
      operationalImpact: json['operationalImpact'] as dynamic,
      remarks: json['remarks'] as dynamic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipmentCriticality': equipmentCriticality,
      'faultCategory': faultCategory,
      'failureHistory': failureHistory,
      'equipmentAgening': equipmentAgening,
      'envSeverity': envSeverity,
      'protFlamambleAtom': protFlamambleAtom,
      'ignitionSourceProb': ignitionSourceProb,
      'ignitionFlask': ignitionFlask,
      'operationalImpact': operationalImpact,
      'remarks': remarks,
    };
  }
}

class Materials {
  final dynamic partNumber;
  final dynamic description;
  final dynamic manufacturer;
  dynamic certificationAttach;
  dynamic certificationOrgName;
  final dynamic unit;
  final dynamic quantity;

  Materials({
    this.partNumber,
    this.description,
    this.manufacturer,
    this.certificationAttach,
    this.certificationOrgName,
    this.unit,
    this.quantity,
  });

  factory Materials.fromJson(Map<String, dynamic> json) {
    return Materials(
      partNumber: json['partNumber'] as dynamic,
      description: json['description'] as dynamic,
      manufacturer: json['manufacturer'] as dynamic,
      certificationAttach: json['certificationAttach'] as dynamic,
      certificationOrgName: json['certificationOrgName'] as dynamic,
      unit: json['unit'] as dynamic,
      quantity: json['quantity'] as dynamic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partNumber': partNumber,
      'description': description,
      'manufacturer': manufacturer,
      'certificationAttach': certificationAttach,
      'certificationOrgName': certificationOrgName,
      'unit': unit,
      'quantity': quantity,
    };
  }
}
