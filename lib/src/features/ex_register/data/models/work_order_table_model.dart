import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

WorkOrderTableJson workOrderTableFromJson(String str) =>
    WorkOrderTableJson.fromJson(json.decode(str));

String workOrderTableToJson(WorkOrderTableJson data) =>
    json.encode(data.toJson());

class WorkOrderTableJson {
  dynamic id;
  List<ExRegister> assets;
  dynamic woNumber;
  dynamic woType;
  dynamic discipline;
  DateTime woDate;
  dynamic department;
  dynamic maintanaceType;
  dynamic description;
  DateTime startDate;
  DateTime endDate;
  dynamic datumDuration;
  dynamic permitType;
  dynamic priority;
  dynamic attachments;
  dynamic createdBy;
  dynamic isActive;
  dynamic total;
  dynamic completed;
  dynamic status;
  dynamic remark;
  dynamic attachementUrl;
  dynamic woRequestFormattachements;
  dynamic woCompletedFormAttachements;
  dynamic woRequestFormattachementUrl;
  dynamic woCompletedFormAttachementstUrl;
  dynamic fieldName;
  dynamic platform;
  dynamic deckLevel;
  dynamic custodian;
  dynamic issuedBy;
  dynamic assigendTeam;
  dynamic issueDate;
  dynamic duration;
  dynamic comletionDate;
  dynamic closedOutBy;
  dynamic closeOutDate;
  dynamic progress;
  dynamic currentStatus;
  dynamic remarks;
  DateTime uploadedDate;
  dynamic uploadedBy;
  dynamic workOrderRequest;
  dynamic riskAssessmentForm;
  dynamic completeWorkOrderForm;
  dynamic schedulingStartDate;
  dynamic schedulingFinishDate;
  dynamic schedulingDuration;
  dynamic actualStartDate;
  dynamic actualFinishDate;
  dynamic actualDuration;
  dynamic scheduledVariance;
  dynamic estimateManPowerCost;
  dynamic estimatedManHours;
  dynamic estimateMaterialCost;
  dynamic estimateMachineryCost;
  dynamic estimateTotalCost;
  dynamic actualManHours;
  dynamic actualManPowerCost;
  dynamic actualMaterialCost;
  dynamic actualMachineryCost;
  dynamic actualTotalCost;
  dynamic costVariance;
  dynamic costBudgetRemarks;
  dynamic projectName;

  WorkOrderTableJson({
    required this.id,
    required this.woNumber,
    required this.woType,
    required this.discipline,
    required this.woDate,
    required this.department,
    required this.maintanaceType,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.datumDuration,
    required this.permitType,
    required this.priority,
    required this.attachments,
    required this.createdBy,
    required this.isActive,
    required this.total,
    required this.completed,
    required this.status,
    required this.remark,
    required this.attachementUrl,
    required this.woRequestFormattachements,
    required this.woCompletedFormAttachements,
    required this.woRequestFormattachementUrl,
    required this.woCompletedFormAttachementstUrl,
    required this.fieldName,
    required this.platform,
    required this.deckLevel,
    required this.custodian,
    required this.issuedBy,
    required this.assigendTeam,
    required this.issueDate,
    required this.duration,
    required this.comletionDate,
    required this.closedOutBy,
    required this.closeOutDate,
    required this.progress,
    required this.currentStatus,
    required this.remarks,
    required this.uploadedDate,
    required this.uploadedBy,
    required this.workOrderRequest,
    required this.riskAssessmentForm,
    required this.completeWorkOrderForm,
    required this.schedulingStartDate,
    required this.schedulingFinishDate,
    required this.schedulingDuration,
    required this.actualStartDate,
    required this.actualFinishDate,
    required this.actualDuration,
    required this.scheduledVariance,
    required this.estimateManPowerCost,
    required this.estimatedManHours,
    required this.estimateMaterialCost,
    required this.estimateMachineryCost,
    required this.estimateTotalCost,
    required this.actualManHours,
    required this.actualManPowerCost,
    required this.actualMaterialCost,
    required this.actualMachineryCost,
    required this.actualTotalCost,
    required this.costVariance,
    required this.costBudgetRemarks,
    required this.projectName,
    required this.assets,
  });

  factory WorkOrderTableJson.fromJson(Map<String, dynamic> json) =>
      WorkOrderTableJson(
        id: json["_id"],
        assets: json["assets"] == null
            ? []
            : List<ExRegister>.from(
                (json["assets"] as List).map((x) => ExRegister.fromJson(x))),
        woNumber: json["woNumber"].toString(),
        woType: json["woType"].toString(),
        discipline: json["discipline"].toString(),
        woDate: DateTime.now(),
        department: json["department"].toString(),
        maintanaceType: json["maintanaceType"].toString(),
        description: json["description"].toString(),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        datumDuration: json["duration"].toString(),
        permitType: json["permitType"].toString(),
        priority: json["priority"].toString(),
        attachments: json["attachments"].toString(),
        createdBy: json["createdBy"].toString(),
        isActive: json["isActive"],
        total: json["total"].toString(),
        completed: json["completed"].toString(),
        status: json["status"].toString(),
        remark: json["remark"].toString(),
        attachementUrl: json["attachementUrl"].toString(),
        woRequestFormattachements: json["woRequestFormattachements"].toString(),
        woCompletedFormAttachements:
            json["woCompletedFormAttachements"].toString(),
        woRequestFormattachementUrl:
            json["woRequestFormattachementUrl"].toString(),
        woCompletedFormAttachementstUrl:
            json["woCompletedFormAttachementstUrl"].toString(),
        fieldName: json["fieldName"].toString(),
        platform: json["platform"].toString(),
        deckLevel: json["deckLevel"].toString(),
        custodian: json["custodian"].toString(),
        issuedBy: json["issuedBy"].toString(),
        assigendTeam: json["assigendTeam"].toString(),
        issueDate: json["issueDate"].toString(),
        duration: json["Duration"].toString(),
        comletionDate: json["comletionDate"].toString(),
        closedOutBy: json["closedOutBy"].toString(),
        closeOutDate: json["closeOutDate"].toString(),
        progress: json["progress"].toString(),
        currentStatus: json["currentStatus"].toString(),
        remarks: json["remarks"].toString(),
        uploadedDate: DateTime.now(),
        uploadedBy: json["uploadedBy"].toString(),
        workOrderRequest: json["workOrderRequest"].toString(),
        riskAssessmentForm: json["riskAssessmentForm"].toString(),
        completeWorkOrderForm: json["completeWorkOrderForm"].toString(),
        schedulingStartDate: json["schedulingStartDate"].toString(),
        schedulingFinishDate: json["schedulingFinishDate"].toString(),
        schedulingDuration: json["schedulingDuration"].toString(),
        actualStartDate: json["actualStartDate"].toString(),
        actualFinishDate: json["actualFinishDate"].toString(),
        actualDuration: json["actualDuration"].toString(),
        scheduledVariance: json["scheduledVariance"].toString(),
        estimateManPowerCost: json["estimateManPowerCost"].toString(),
        estimatedManHours: json["estimatedManHours"].toString(),
        estimateMaterialCost: json["estimateMaterialCost"].toString(),
        estimateMachineryCost: json["estimateMachineryCost"].toString(),
        estimateTotalCost: json["estimateTotalCost"].toString(),
        actualManHours: json["actualManHours"].toString(),
        actualManPowerCost: json["actualManPowerCost"].toString(),
        actualMaterialCost: json["actualMaterialCost"].toString(),
        actualMachineryCost: json["actualMachineryCost"].toString(),
        actualTotalCost: json["actualTotalCost"].toString(),
        costVariance: json["costVariance"].toString(),
        costBudgetRemarks: json["costBudgetRemarks"].toString(),
        projectName: json["projectName"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "assets": assets,
        "woNumber": woNumber,
        "woType": woType,
        "discipline": discipline,
        "woDate": woDate.toIso8601String(),
        "department": department,
        "maintanaceType": maintanaceType,
        "description": description,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "duration": datumDuration,
        "permitType": permitType,
        "priority": priority,
        "attachments": attachments,
        "createdBy": createdBy,
        "isActive": isActive,
        "total": total,
        "completed": completed,
        "status": status,
        "remark": remark,
        "attachementUrl": attachementUrl,
        "woRequestFormattachements": woRequestFormattachements,
        "woCompletedFormAttachements": woCompletedFormAttachements,
        "woRequestFormattachementUrl": woRequestFormattachementUrl,
        "woCompletedFormAttachementstUrl": woCompletedFormAttachementstUrl,
        "fieldName": fieldName,
        "platform": platform,
        "deckLevel": deckLevel,
        "custodian": custodian,
        "issuedBy": issuedBy,
        "assigendTeam": assigendTeam,
        "issueDate": issueDate,
        "Duration": duration,
        "comletionDate": comletionDate,
        "closedOutBy": closedOutBy,
        "closeOutDate": closeOutDate,
        "progress": progress,
        "currentStatus": currentStatus,
        "remarks": remarks,
        "uploadedDate": uploadedDate.toIso8601String(),
        "uploadedBy": uploadedBy,
        "workOrderRequest": workOrderRequest,
        "riskAssessmentForm": riskAssessmentForm,
        "completeWorkOrderForm": completeWorkOrderForm,
        "schedulingStartDate": schedulingStartDate,
        "schedulingFinishDate": schedulingFinishDate,
        "schedulingDuration": schedulingDuration,
        "actualStartDate": actualStartDate,
        "actualFinishDate": actualFinishDate,
        "actualDuration": actualDuration,
        "scheduledVariance": scheduledVariance,
        "estimateManPowerCost": estimateManPowerCost,
        "estimatedManHours": estimatedManHours,
        "estimateMaterialCost": estimateMaterialCost,
        "estimateMachineryCost": estimateMachineryCost,
        "estimateTotalCost": estimateTotalCost,
        "actualManHours": actualManHours,
        "actualManPowerCost": actualManPowerCost,
        "actualMaterialCost": actualMaterialCost,
        "actualMachineryCost": actualMachineryCost,
        "actualTotalCost": actualTotalCost,
        "costVariance": costVariance,
        "costBudgetRemarks": costBudgetRemarks,
        "projectName": projectName,
      };
}
