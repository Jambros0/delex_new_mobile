import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

ExRegisterTableModel exRegisterTableModelFromJson(String str) =>
    ExRegisterTableModel.fromJson(json.decode(str));

String exRegisterTableModelToJson(ExRegisterTableModel data) =>
    json.encode(data.toJson());

// class ExRegisterTableModel {
//   int id;
//   WorkOrderTable workOrderTableJson;
//   dynamic createdBy;
//   dynamic updatedBy;
//   dynamic createdDate;
//   dynamic updatedDate;

//   ExRegisterTableModel({
//     required this.id,
//     required this.workOrderTableJson,
//     required this.createdBy,
//     required this.updatedBy,
//     required this.createdDate,
//     required this.updatedDate,
//   });

//   factory ExRegisterTableModel.fromJson(Map<String, dynamic> json) =>
//       ExRegisterTableModel(
//         id: json["id"],
//         workOrderTableJson: WorkOrderTable.fromJson(json["data"]),
//         createdBy: json["created_by"],
//         updatedBy: json["updated_by"],
//         createdDate: json["created_date"],
//         updatedDate: json["updated_date"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "data": workOrderTableJson.toJson(),
//         "created_by": createdBy,
//         "updated_by": updatedBy,
//         "created_date": createdDate,
//         "updated_date": updatedDate,
//       };
// }

// class WorkOrderTable {
//   String id;
//   String woNumber;
//   String woType;
//   String discipline;
//   DateTime woDate;
//   dynamic department;
//   dynamic maintanaceType;
//   String description;
//   DateTime startDate;
//   DateTime endDate;
//   dynamic datumDuration;
//   dynamic permitType;
//   String priority;
//   dynamic attachments;
//   String createdBy;
//   bool isActive;
//   String total;
//   String completed;
//   String status;
//   dynamic remark;
//   dynamic attachementUrl;
//   String woRequestFormattachements;
//   String woCompletedFormAttachements;
//   String woRequestFormattachementUrl;
//   String woCompletedFormAttachementstUrl;
//   String fieldName;
//   String platform;
//   String deckLevel;
//   dynamic custodian;
//   String issuedBy;
//   dynamic assigendTeam;
//   dynamic issueDate;
//   dynamic duration;
//   dynamic comletionDate;
//   dynamic closedOutBy;
//   dynamic closeOutDate;
//   dynamic progress;
//   dynamic currentStatus;
//   String remarks;
//   DateTime uploadedDate;
//   dynamic uploadedBy;
//   String workOrderRequest;
//   dynamic riskAssessmentForm;
//   String completeWorkOrderForm;
//   dynamic schedulingStartDate;
//   dynamic schedulingFinishDate;
//   dynamic schedulingDuration;
//   dynamic actualStartDate;
//   dynamic actualFinishDate;
//   int actualDuration;
//   dynamic scheduledVariance;
//   dynamic estimateManPowerCost;
//   dynamic estimatedManHours;
//   dynamic estimateMaterialCost;
//   dynamic estimateMachineryCost;
//   dynamic estimateTotalCost;
//   dynamic actualManHours;
//   dynamic actualManPowerCost;
//   dynamic actualMaterialCost;
//   dynamic actualMachineryCost;
//   dynamic actualTotalCost;
//   dynamic costVariance;
//   String costBudgetRemarks;
//   String projectName;
//   ExRegister exregisterJson;

//   WorkOrderTable({
//     required this.id,
//     required this.woNumber,
//     required this.woType,
//     required this.discipline,
//     required this.woDate,
//     required this.department,
//     required this.maintanaceType,
//     required this.description,
//     required this.startDate,
//     required this.endDate,
//     required this.datumDuration,
//     required this.permitType,
//     required this.priority,
//     required this.attachments,
//     required this.createdBy,
//     required this.isActive,
//     required this.total,
//     required this.completed,
//     required this.status,
//     required this.remark,
//     required this.attachementUrl,
//     required this.woRequestFormattachements,
//     required this.woCompletedFormAttachements,
//     required this.woRequestFormattachementUrl,
//     required this.woCompletedFormAttachementstUrl,
//     required this.fieldName,
//     required this.platform,
//     required this.deckLevel,
//     required this.custodian,
//     required this.issuedBy,
//     required this.assigendTeam,
//     required this.issueDate,
//     required this.duration,
//     required this.comletionDate,
//     required this.closedOutBy,
//     required this.closeOutDate,
//     required this.progress,
//     required this.currentStatus,
//     required this.remarks,
//     required this.uploadedDate,
//     required this.uploadedBy,
//     required this.workOrderRequest,
//     required this.riskAssessmentForm,
//     required this.completeWorkOrderForm,
//     required this.schedulingStartDate,
//     required this.schedulingFinishDate,
//     required this.schedulingDuration,
//     required this.actualStartDate,
//     required this.actualFinishDate,
//     required this.actualDuration,
//     required this.scheduledVariance,
//     required this.estimateManPowerCost,
//     required this.estimatedManHours,
//     required this.estimateMaterialCost,
//     required this.estimateMachineryCost,
//     required this.estimateTotalCost,
//     required this.actualManHours,
//     required this.actualManPowerCost,
//     required this.actualMaterialCost,
//     required this.actualMachineryCost,
//     required this.actualTotalCost,
//     required this.costVariance,
//     required this.costBudgetRemarks,
//     required this.projectName,
//     required this.exregisterJson,
//   });

//   factory WorkOrderTable.fromJson(Map<String, dynamic> json) => WorkOrderTable(
//         id: json["_id"],
//         woNumber: json["woNumber"],
//         woType: json["woType"],
//         discipline: json["discipline"],
//         woDate: DateTime.parse(json["woDate"]),
//         department: json["department"],
//         maintanaceType: json["maintanaceType"],
//         description: json["description"],
//         startDate: DateTime.parse(json["startDate"]),
//         endDate: DateTime.parse(json["endDate"]),
//         datumDuration: json["duration"],
//         permitType: json["permitType"],
//         priority: json["priority"],
//         attachments: json["attachments"],
//         createdBy: json["createdBy"],
//         isActive: json["isActive"],
//         total: json["total"],
//         completed: json["completed"],
//         status: json["status"],
//         remark: json["remark"],
//         attachementUrl: json["attachementUrl"],
//         woRequestFormattachements: json["woRequestFormattachements"],
//         woCompletedFormAttachements: json["woCompletedFormAttachements"],
//         woRequestFormattachementUrl: json["woRequestFormattachementUrl"],
//         woCompletedFormAttachementstUrl:
//             json["woCompletedFormAttachementstUrl"],
//         fieldName: json["fieldName"],
//         platform: json["platform"],
//         deckLevel: json["deckLevel"],
//         custodian: json["custodian"],
//         issuedBy: json["issuedBy"],
//         assigendTeam: json["assigendTeam"],
//         issueDate: json["issueDate"],
//         duration: json["Duration"],
//         comletionDate: json["comletionDate"],
//         closedOutBy: json["closedOutBy"],
//         closeOutDate: json["closeOutDate"],
//         progress: json["progress"],
//         currentStatus: json["currentStatus"],
//         remarks: json["remarks"],
//         uploadedDate: DateTime.parse(json["uploadedDate"]),
//         uploadedBy: json["uploadedBy"],
//         workOrderRequest: json["workOrderRequest"],
//         riskAssessmentForm: json["riskAssessmentForm"],
//         completeWorkOrderForm: json["completeWorkOrderForm"],
//         schedulingStartDate: json["schedulingStartDate"],
//         schedulingFinishDate: json["schedulingFinishDate"],
//         schedulingDuration: json["schedulingDuration"],
//         actualStartDate: json["actualStartDate"],
//         actualFinishDate: json["actualFinishDate"],
//         actualDuration: json["actualDuration"],
//         scheduledVariance: json["scheduledVariance"],
//         estimateManPowerCost: json["estimateManPowerCost"],
//         estimatedManHours: json["estimatedManHours"],
//         estimateMaterialCost: json["estimateMaterialCost"],
//         estimateMachineryCost: json["estimateMachineryCost"],
//         estimateTotalCost: json["estimateTotalCost"],
//         actualManHours: json["actualManHours"],
//         actualManPowerCost: json["actualManPowerCost"],
//         actualMaterialCost: json["actualMaterialCost"],
//         actualMachineryCost: json["actualMachineryCost"],
//         actualTotalCost: json["actualTotalCost"],
//         costVariance: json["costVariance"],
//         costBudgetRemarks: json["costBudgetRemarks"],
//         projectName: json["projectName"],
//         exregisterJson: ExRegister.fromJson(json["asset"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "woNumber": woNumber,
//         "woType": woType,
//         "discipline": discipline,
//         "woDate": woDate.toIso8601String(),
//         "department": department,
//         "maintanaceType": maintanaceType,
//         "description": description,
//         "startDate": startDate.toIso8601String(),
//         "endDate": endDate.toIso8601String(),
//         "duration": datumDuration,
//         "permitType": permitType,
//         "priority": priority,
//         "attachments": attachments,
//         "createdBy": createdBy,
//         "isActive": isActive,
//         "total": total,
//         "completed": completed,
//         "status": status,
//         "remark": remark,
//         "attachementUrl": attachementUrl,
//         "woRequestFormattachements": woRequestFormattachements,
//         "woCompletedFormAttachements": woCompletedFormAttachements,
//         "woRequestFormattachementUrl": woRequestFormattachementUrl,
//         "woCompletedFormAttachementstUrl": woCompletedFormAttachementstUrl,
//         "fieldName": fieldName,
//         "platform": platform,
//         "deckLevel": deckLevel,
//         "custodian": custodian,
//         "issuedBy": issuedBy,
//         "assigendTeam": assigendTeam,
//         "issueDate": issueDate,
//         "Duration": duration,
//         "comletionDate": comletionDate,
//         "closedOutBy": closedOutBy,
//         "closeOutDate": closeOutDate,
//         "progress": progress,
//         "currentStatus": currentStatus,
//         "remarks": remarks,
//         "uploadedDate": uploadedDate.toIso8601String(),
//         "uploadedBy": uploadedBy,
//         "workOrderRequest": workOrderRequest,
//         "riskAssessmentForm": riskAssessmentForm,
//         "completeWorkOrderForm": completeWorkOrderForm,
//         "schedulingStartDate": schedulingStartDate,
//         "schedulingFinishDate": schedulingFinishDate,
//         "schedulingDuration": schedulingDuration,
//         "actualStartDate": actualStartDate,
//         "actualFinishDate": actualFinishDate,
//         "actualDuration": actualDuration,
//         "scheduledVariance": scheduledVariance,
//         "estimateManPowerCost": estimateManPowerCost,
//         "estimatedManHours": estimatedManHours,
//         "estimateMaterialCost": estimateMaterialCost,
//         "estimateMachineryCost": estimateMachineryCost,
//         "estimateTotalCost": estimateTotalCost,
//         "actualManHours": actualManHours,
//         "actualManPowerCost": actualManPowerCost,
//         "actualMaterialCost": actualMaterialCost,
//         "actualMachineryCost": actualMachineryCost,
//         "actualTotalCost": actualTotalCost,
//         "costVariance": costVariance,
//         "costBudgetRemarks": costBudgetRemarks,
//         "projectName": projectName,
//         "asset": exregisterJson.toJson(),
//       };
// }

class ExRegisterTableModel {
  int id;
  ExRegister exregisterJson;
  dynamic createdBy;
  dynamic updatedBy;
  dynamic createdDate;
  dynamic updatedDate;

  ExRegisterTableModel({
    required this.id,
    required this.exregisterJson,
    required this.createdBy,
    required this.updatedBy,
    required this.createdDate,
    required this.updatedDate,
  });

  factory ExRegisterTableModel.fromJson(Map<String, dynamic> json) =>
      ExRegisterTableModel(
        id: json["id"],
        exregisterJson: ExRegister.fromJson(json["asset"]),
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        createdDate: json["created_date"],
        updatedDate: json["updated_date"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "asset": exregisterJson.toJson(),
    "created_by": createdBy,
    "updated_by": updatedBy,
    "created_date": createdDate,
    "updated_date": updatedDate,
  };
}

class ExregisterJson {
  Asset asset;

  ExregisterJson({required this.asset});

  factory ExregisterJson.fromJson(Map<String, dynamic> json) =>
      ExregisterJson(asset: Asset.fromJson(json["asset"]));

  Map<String, dynamic> toJson() => {"asset": asset.toJson()};
}

class Asset {
  dynamic location;
  dynamic area;
  dynamic zone;
  dynamic locationGasGroup;
  dynamic locationTClass;
  dynamic locationIpRating;
  List<String> areaClassDrawAttach;
  List<String> areaClassDrawNo;
  List<String> areaClassDrawAttachOrgName;
  List<String> eqpmtLytDrawAttachOrgName;
  List<String> eqpmtLytDrawAttach;
  List<String> eqpmtLytDrawNo;
  dynamic locationId;
  dynamic deckLevel;
  dynamic locationLongitude;
  dynamic locationLatitude;
  dynamic eqpmtCatg;
  dynamic description;
  dynamic atexCatg;
  dynamic epl;
  dynamic protectionType;
  dynamic subArea;
  dynamic rfidRef;
  dynamic gpsCord;
  dynamic eqpmtTag;
  dynamic circuitId;
  dynamic cableId;
  dynamic equipmentCategory;
  dynamic manufacturer;
  dynamic type;
  dynamic serialNumber;
  dynamic protectionStd;
  dynamic equipmentGasGroup;
  dynamic equipmentTClass;
  dynamic equipmentIpRating;
  dynamic certfnBody;
  dynamic certfnNo;
  dynamic tAmbient;
  dynamic tAmbientEquip;
  dynamic inspectionSignOff;
  dynamic repairSignOff;
  dynamic oracleId;
  dynamic id;
  List<CheckList> checkList;
  Map<String, dynamic> yesNoSelection;
  dynamic inspectedBy;
  dynamic inspectedDate;
  dynamic repairedBy;
  dynamic repairedDate;
  dynamic faultyItems;
  dynamic inspectionStatus;
  dynamic defectOverallCondition;
  dynamic defectIsolation;
  List<String> defectOtherRequirements;
  dynamic remarks;
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
  List<dynamic> materials;
  dynamic existingFaults;
  dynamic correctiveDefectCategory;
  dynamic currentStatus;
  dynamic correctiveOverallCondition;
  dynamic correctiveIsolation;
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
  // RbiStrategy rbiStrategy;
  List<dynamic> supplementaryMaterialReq;
  List<String> inspectionChecklistType;
  dynamic inspectionType;
  dynamic inspectionGrade;
  dynamic equipmentEquipmentType;
  bool isSubmit;
  int primaryId;
  dynamic areaStatus;

  Asset({
    required this.location,
    required this.area,
    required this.zone,
    required this.locationGasGroup,
    required this.locationTClass,
    required this.locationIpRating,
    required this.areaClassDrawAttach,
    required this.areaClassDrawNo,
    required this.areaClassDrawAttachOrgName,
    required this.eqpmtLytDrawAttachOrgName,
    required this.eqpmtLytDrawAttach,
    required this.eqpmtLytDrawNo,
    required this.locationId,
    required this.deckLevel,
    required this.locationLongitude,
    required this.locationLatitude,
    required this.eqpmtCatg,
    required this.description,
    required this.atexCatg,
    required this.epl,
    required this.protectionType,
    required this.subArea,
    required this.rfidRef,
    required this.gpsCord,
    required this.eqpmtTag,
    required this.circuitId,
    required this.cableId,
    required this.equipmentCategory,
    required this.manufacturer,
    required this.type,
    required this.serialNumber,
    required this.protectionStd,
    required this.equipmentGasGroup,
    required this.equipmentTClass,
    required this.equipmentIpRating,
    required this.certfnBody,
    required this.certfnNo,
    required this.tAmbient,
    required this.tAmbientEquip,
    required this.inspectionSignOff,
    required this.repairSignOff,
    required this.oracleId,
    required this.id,
    required this.checkList,
    required this.yesNoSelection,
    required this.inspectedBy,
    required this.inspectedDate,
    required this.repairedBy,
    required this.repairedDate,
    required this.faultyItems,
    required this.inspectionStatus,
    required this.defectOverallCondition,
    required this.defectIsolation,
    required this.defectOtherRequirements,
    required this.remarks,
    required this.dataSheetOrgName,
    required this.defectivePhoto1,
    required this.defectivePhoto1OrgName,
    required this.defectivePhoto2,
    required this.defectivePhoto2OrgName,
    required this.defectivePhoto3,
    required this.defectivePhoto3OrgName,
    required this.defectivePhoto4,
    required this.defectivePhoto4OrgName,
    required this.defectivePhoto5,
    required this.defectivePhoto5OrgName,
    required this.defectivePhoto6,
    required this.defectivePhoto6OrgName,
    required this.materials,
    required this.existingFaults,
    required this.correctiveDefectCategory,
    required this.currentStatus,
    required this.correctiveOverallCondition,
    required this.correctiveIsolation,
    required this.correctiveOtherRequirements,
    required this.repairsDone,
    required this.correctivePhoto1,
    required this.correctivePhoto1OrgName,
    required this.correctivePhoto2,
    required this.correctivePhoto2OrgName,
    required this.correctivePhoto3,
    required this.correctivePhoto3OrgName,
    required this.correctivePhoto4,
    required this.correctivePhoto4OrgName,
    required this.correctivePhoto5,
    required this.correctivePhoto5OrgName,
    required this.correctivePhoto6,
    required this.correctivePhoto6OrgName,
    // required this.rbiStrategy,
    required this.supplementaryMaterialReq,
    required this.inspectionChecklistType,
    required this.inspectionType,
    required this.inspectionGrade,
    required this.equipmentEquipmentType,
    required this.isSubmit,
    required this.areaStatus,
    required this.primaryId,
  });

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    location: json["location"],
    area: json["area"],
    zone: json["zone"],
    locationGasGroup: json["locationGasGroup"],
    locationTClass: json["locationTClass"],
    locationIpRating: json["locationIpRating"],
    areaClassDrawAttach: List<String>.from(json["areaClassDrawAttach"] ?? []),
    areaClassDrawNo: List<String>.from(json["areaClassDrawNo"] ?? []),
    areaClassDrawAttachOrgName: List<String>.from(
      json["areaClassDrawAttachOrgName"] ?? [],
    ),
    eqpmtLytDrawAttachOrgName: List<String>.from(
      json["eqpmtLytDrawAttachOrgName"] ?? [],
    ),
    eqpmtLytDrawAttach: List<String>.from(json["eqpmtLytDrawAttach"] ?? []),
    eqpmtLytDrawNo: List<String>.from(json["eqpmtLytDrawNo"] ?? []),
    locationId: json["locationId"],
    deckLevel: json["deckLevel"],
    locationLongitude: json["locationLongitude"],
    locationLatitude: json["locationLatitude"],
    eqpmtCatg: json["eqpmtCatg"],
    description: json["description"],
    atexCatg: json["atexCatg"],
    epl: json["epl"],
    protectionType: json["protectionType"],
    subArea: json["subArea"],
    rfidRef: json["rfidRef"],
    gpsCord: json["gpsCord"],
    eqpmtTag: json["eqpmtTag"],
    circuitId: json["circuitId"],
    cableId: json["cableId"],
    equipmentCategory: json["equipmentCategory"],
    manufacturer: json["manufacturer"],
    type: json["type"],
    serialNumber: json["serialNumber"],
    protectionStd: json["protectionStd"],
    equipmentGasGroup: json["equipmentGasGroup"],
    equipmentTClass: json["equipmentTClass"],
    equipmentIpRating: json["equipmentIpRating"],
    certfnBody: json["certfnBody"],
    certfnNo: json["certfnNo"],
    tAmbient: json["tAmbient"],
    tAmbientEquip: json["tAmbientEquip"],
    inspectionSignOff: json["inspectionSignOff"],
    repairSignOff: json["repairSignOff"],
    oracleId: json["oracleId"],
    id: json["_id"],
    checkList: List<CheckList>.from(
      json["checkList"].map((x) => CheckList.fromJson(x)),
    ),
    yesNoSelection: json['yesNoSelection'] != null
        ? Map<String, dynamic>.from(json['yesNoSelection'] as Map)
        : {},
    inspectedBy: json["inspectedBy"],
    inspectedDate: json["inspectedDate"],
    repairedBy: json["repairedBy"],
    repairedDate: json["repairedDate"],
    faultyItems: json["faultyItems"],
    inspectionStatus: json["inspectionStatus"],
    defectOverallCondition: json["defectOverallCondition"],
    defectIsolation: json["defectIsolation"],
    defectOtherRequirements: List<String>.from(
      json["defectOtherRequirements"] ?? [],
    ),
    remarks: json["remarks"],
    dataSheetOrgName: json["dataSheetOrgName"],
    defectivePhoto1: json["defectivePhoto1"],
    defectivePhoto1OrgName: json["defectivePhoto1OrgName"],
    defectivePhoto2: json["defectivePhoto2"],
    defectivePhoto2OrgName: json["defectivePhoto2OrgName"],
    defectivePhoto3: json["defectivePhoto3"],
    defectivePhoto3OrgName: json["defectivePhoto3OrgName"],
    defectivePhoto4: json["defectivePhoto4"],
    defectivePhoto4OrgName: json["defectivePhoto4OrgName"],
    defectivePhoto5: json["defectivePhoto5"],
    defectivePhoto5OrgName: json["defectivePhoto5OrgName"],
    defectivePhoto6: json["defectivePhoto6"],
    defectivePhoto6OrgName: json["defectivePhoto6OrgName"],
    materials: List<dynamic>.from(json["materials"].map((x) => x)),
    existingFaults: json["existingFaults"],
    correctiveDefectCategory: json["correctiveDefectCategory"],
    currentStatus: json["currentStatus"],
    correctiveOverallCondition: json["correctiveOverallCondition"],
    correctiveIsolation: json["correctiveIsolation"],
    correctiveOtherRequirements: json["correctiveOtherRequirements"],
    repairsDone: json["repairsDone"],
    correctivePhoto1: json["correctivePhoto1"],
    correctivePhoto1OrgName: json["correctivePhoto1OrgName"],
    correctivePhoto2: json["correctivePhoto2"],
    correctivePhoto2OrgName: json["correctivePhoto2OrgName"],
    correctivePhoto3: json["correctivePhoto3"],
    correctivePhoto3OrgName: json["correctivePhoto3OrgName"],
    correctivePhoto4: json["correctivePhoto4"],
    correctivePhoto4OrgName: json["correctivePhoto4OrgName"],
    correctivePhoto5: json["correctivePhoto5"],
    correctivePhoto5OrgName: json["correctivePhoto5OrgName"],
    correctivePhoto6: json["correctivePhoto6"],
    correctivePhoto6OrgName: json["correctivePhoto6OrgName"],
    // rbiStrategy: RbiStrategy.fromJson(json["rbiStrategy"]),
    supplementaryMaterialReq: List<dynamic>.from(
      json["supplementaryMaterialReq"].map((x) => x),
    ),
    inspectionChecklistType: List<String>.from(
      json["inspectionChecklistType"] ?? [],
    ),
    inspectionType: json["inspectionType"],
    inspectionGrade: json["inspectionGrade"],
    equipmentEquipmentType: json["equipmentEquipmentType"],
    areaStatus: json["areaStatus"],
    isSubmit: json["isSubmit"],
    primaryId: json["primaryId"],
  );

  Map<String, dynamic> toJson() => {
    "location": location,
    "area": area,
    "zone": zone,
    "locationGasGroup": locationGasGroup,
    "locationTClass": locationTClass,
    "locationIpRating": locationIpRating,
    "areaClassDrawAttach": areaClassDrawAttach,
    "areaClassDrawNo": areaClassDrawNo,
    "areaClassDrawAttachOrgName": areaClassDrawAttachOrgName,
    "eqpmtLytDrawAttachOrgName": eqpmtLytDrawAttachOrgName,
    "eqpmtLytDrawAttach": eqpmtLytDrawAttach,
    "eqpmtLytDrawNo": eqpmtLytDrawNo,
    "locationId": locationId,
    "deckLevel": deckLevel,
    "locationLongitude": locationLongitude,
    "locationLatitude": locationLatitude,
    "eqpmtCatg": eqpmtCatg,
    "description": description,
    "atexCatg": atexCatg,
    "epl": epl,
    "protectionType": protectionType,
    "subArea": subArea,
    "rfidRef": rfidRef,
    "gpsCord": gpsCord,
    "eqpmtTag": eqpmtTag,
    "circuitId": circuitId,
    "cableId": cableId,
    "equipmentCategory": equipmentCategory,
    "manufacturer": manufacturer,
    "type": type,
    "serialNumber": serialNumber,
    "protectionStd": protectionStd,
    "equipmentGasGroup": equipmentGasGroup,
    "equipmentTClass": equipmentTClass,
    "equipmentIpRating": equipmentIpRating,
    "certfnBody": certfnBody,
    "certfnNo": certfnNo,
    "tAmbient": tAmbient,
    "tAmbientEquip": tAmbientEquip,
    "inspectionSignOff": inspectionSignOff,
    "repairSignOff": repairSignOff,
    "oracleId": oracleId,
    "_id": id,
    "checkList": List<dynamic>.from(checkList.map((x) => x.toJson())),
    'yesNoSelection': yesNoSelection,
    "inspectedBy": inspectedBy,
    "inspectedDate": inspectedDate,
    "repairedBy": repairedBy,
    "repairedDate": repairedDate,
    "faultyItems": faultyItems,
    "inspectionStatus": inspectionStatus,
    "defectOverallCondition": defectOverallCondition,
    "defectIsolation": defectIsolation,
    "defectOtherRequirements": defectOtherRequirements,
    "remarks": remarks,
    "dataSheetOrgName": dataSheetOrgName,
    "defectivePhoto1": defectivePhoto1,
    "defectivePhoto1OrgName": defectivePhoto1OrgName,
    "defectivePhoto2": defectivePhoto2,
    "defectivePhoto2OrgName": defectivePhoto2OrgName,
    "defectivePhoto3": defectivePhoto3,
    "defectivePhoto3OrgName": defectivePhoto3OrgName,
    "defectivePhoto4": defectivePhoto4,
    "defectivePhoto4OrgName": defectivePhoto4OrgName,
    "defectivePhoto5": defectivePhoto5,
    "defectivePhoto5OrgName": defectivePhoto5OrgName,
    "defectivePhoto6": defectivePhoto6,
    "defectivePhoto6OrgName": defectivePhoto6OrgName,
    "materials": List<dynamic>.from(materials.map((x) => x)),
    "existingFaults": existingFaults,
    "correctiveDefectCategory": correctiveDefectCategory,
    "currentStatus": currentStatus,
    "correctiveOverallCondition": correctiveOverallCondition,
    "correctiveIsolation": correctiveIsolation,
    "correctiveOtherRequirements": correctiveOtherRequirements,
    "repairsDone": repairsDone,
    "correctivePhoto1": correctivePhoto1,
    "correctivePhoto1OrgName": correctivePhoto1OrgName,
    "correctivePhoto2": correctivePhoto2,
    "correctivePhoto2OrgName": correctivePhoto2OrgName,
    "correctivePhoto3": correctivePhoto3,
    "correctivePhoto3OrgName": correctivePhoto3OrgName,
    "correctivePhoto4": correctivePhoto4,
    "correctivePhoto4OrgName": correctivePhoto4OrgName,
    "correctivePhoto5": correctivePhoto5,
    "correctivePhoto5OrgName": correctivePhoto5OrgName,
    "correctivePhoto6": correctivePhoto6,
    "correctivePhoto6OrgName": correctivePhoto6OrgName,
    // "rbiStrategy": rbiStrategy.toJson(),
    "supplementaryMaterialReq": List<dynamic>.from(
      supplementaryMaterialReq.map((x) => x),
    ),
    "inspectionChecklistType": inspectionChecklistType,
    "inspectionType": inspectionType,
    "inspectionGrade": inspectionGrade,
    "equipmentEquipmentType": equipmentEquipmentType,
    "isSubmit": isSubmit,
    "areaStatus": areaStatus,
    "primaryId": primaryId,
  };
}

class CheckList {
  dynamic defectCategoryCode;
  int count;
  List<DefectCode> defectCodes;

  CheckList({
    required this.defectCategoryCode,
    required this.count,
    required this.defectCodes,
  });

  factory CheckList.fromJson(Map<String, dynamic> json) => CheckList(
    defectCategoryCode: json["defectCategoryCode"],
    count: json["count"],
    defectCodes: List<DefectCode>.from(
      json["defectCodes"].map((x) => DefectCode.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "defectCategoryCode": defectCategoryCode,
    "count": count,
    "defectCodes": List<dynamic>.from(defectCodes.map((x) => x.toJson())),
  };
}

class DefectCode {
  dynamic id;
  dynamic checkListGroup;
  dynamic equipmentType;
  dynamic checklistName;
  dynamic inspectionGrade;
  dynamic inspectionType;
  dynamic defectCode;
  List<FindingsAndAction> findingsAndActions;
  DefectPriority defectPriority;

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
  });

  factory DefectCode.fromJson(Map<String, dynamic> json) => DefectCode(
    id: json["_id"],
    checkListGroup: json["checkListGroup"],
    equipmentType: json["equipmentType"],
    checklistName: json["checklistName"],
    inspectionGrade: json["inspectionGrade"],
    inspectionType: json["inspectionType"],
    defectCode: json["defectCode"],
    findingsAndActions: List<FindingsAndAction>.from(
      json["findingsAndActions"].map((x) => FindingsAndAction.fromJson(x)),
    ),
    defectPriority: DefectPriority.fromJson(json["defectPriority"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "checkListGroup": checkListGroup,
    "equipmentType": equipmentType,
    "checklistName": checklistName,
    "inspectionGrade": inspectionGrade,
    "inspectionType": inspectionType,
    "defectCode": defectCode,
    "findingsAndActions": List<dynamic>.from(
      findingsAndActions.map((x) => x.toJson()),
    ),
    "defectPriority": defectPriority.toJson(),
  };
}

class DefectPriority {
  dynamic zoneCategory;
  int priority;

  DefectPriority({required this.zoneCategory, required this.priority});

  factory DefectPriority.fromJson(Map<String, dynamic> json) => DefectPriority(
    zoneCategory: json["zoneCategory"],
    priority: json["priority"],
  );

  Map<String, dynamic> toJson() => {
    "zoneCategory": zoneCategory,
    "priority": priority,
  };
}

class FindingsAndAction {
  dynamic id;
  dynamic defectCode;
  dynamic finding;
  dynamic remedialAction;
  dynamic defectCategory;
  bool isDone;
  bool isSelected;
  dynamic repairedAt;
  dynamic repairedBy;
  dynamic updatedAt;

  FindingsAndAction({
    required this.id,
    required this.defectCode,
    required this.finding,
    required this.remedialAction,
    required this.defectCategory,
    required this.isDone,
    required this.isSelected,
    required this.repairedAt,
    required this.repairedBy,
    required this.updatedAt,
  });

  factory FindingsAndAction.fromJson(Map<String, dynamic> json) =>
      FindingsAndAction(
        id: json["_id"],
        defectCode: json["defectCode"],
        finding: json["finding"],
        remedialAction: json["remedialAction"],
        defectCategory: json["defectCategory"],
        isDone: json["isDone"],
        isSelected: json["isSelected"],
        repairedAt: json["repairedAt"],
        repairedBy: json["repairedBy"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "defectCode": defectCode,
    "finding": finding,
    "remedialAction": remedialAction,
    "defectCategory": defectCategory,
    "isDone": isDone,
    "isSelected": isSelected,
    "repairedAt": repairedAt,
    "repairedBy": repairedBy,
    "updatedAt": updatedAt,
  };
}

class RbiStrategy {
  dynamic equipmentCriticality;
  dynamic faultCategory;
  dynamic failureHistory;
  dynamic equipmentAgening;
  dynamic envSeverity;
  dynamic protFlamambleAtom;
  dynamic ignitionSourceProb;
  dynamic ignitionFlask;
  dynamic operationalImpact;
  dynamic remarks;

  RbiStrategy({
    required this.equipmentCriticality,
    required this.faultCategory,
    required this.failureHistory,
    required this.equipmentAgening,
    required this.envSeverity,
    required this.protFlamambleAtom,
    required this.ignitionSourceProb,
    required this.ignitionFlask,
    required this.operationalImpact,
    required this.remarks,
  });

  factory RbiStrategy.fromJson(Map<String, dynamic> json) => RbiStrategy(
    equipmentCriticality: json["equipmentCriticality"],
    faultCategory: json["faultCategory"],
    failureHistory: json["failureHistory"],
    equipmentAgening: json["equipmentAgening"],
    envSeverity: json["envSeverity"],
    protFlamambleAtom: json["protFlamambleAtom"],
    ignitionSourceProb: json["ignitionSourceProb"],
    ignitionFlask: json["ignitionFlask"],
    operationalImpact: json["operationalImpact"],
    remarks: json["remarks"],
  );

  Map<String, dynamic> toJson() => {
    "equipmentCriticality": equipmentCriticality,
    "faultCategory": faultCategory,
    "failureHistory": failureHistory,
    "equipmentAgening": equipmentAgening,
    "envSeverity": envSeverity,
    "protFlamambleAtom": protFlamambleAtom,
    "ignitionSourceProb": ignitionSourceProb,
    "ignitionFlask": ignitionFlask,
    "operationalImpact": operationalImpact,
    "remarks": remarks,
  };
}
