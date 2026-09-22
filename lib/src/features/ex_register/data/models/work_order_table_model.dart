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
  dynamic assignedTo;
  dynamic userId;
  dynamic assignedUserId;
  dynamic inspectorId;

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
    this.assignedTo,
    this.userId,
    this.assignedUserId,
    this.inspectorId,
  });

  factory WorkOrderTableJson.fromJson(Map<String, dynamic> json) {
    List<ExRegister> parsedAssets = [];
    final rawAssets = json["assignedAssets"] ?? json["assets"] ?? json["asset"] ?? json["work_order_assets"] ?? json["workOrder_assets"];
    if (rawAssets is List) {
      for (var item in rawAssets) {
        if (item is ExRegister) {
          parsedAssets.add(item);
        } else if (item is Map<String, dynamic>) {
          try {
            parsedAssets.add(ExRegister.fromJson(item));
          } catch (_) {}
        } else if (item is Map) {
          try {
            parsedAssets.add(
                ExRegister.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
    } else if (rawAssets is Map) {
      try {
        parsedAssets.add(
            ExRegister.fromJson(Map<String, dynamic>.from(rawAssets)));
      } catch (_) {}
    }

    return WorkOrderTableJson(
      id: json["_id"] ?? json["id"] ?? '',
      assets: parsedAssets,
      woNumber: json["woNumber"]?.toString() ?? '',
      woType: json["woType"]?.toString() ?? '',
      discipline: json["discipline"]?.toString() ?? '',
      woDate: json["woDate"] != null
          ? (DateTime.tryParse(json["woDate"].toString()) ?? DateTime.now())
          : DateTime.now(),
      department: json["department"]?.toString() ?? '',
      maintanaceType: json["maintanaceType"]?.toString() ?? '',
      description: json["description"]?.toString() ?? '',
      startDate: json["startDate"] != null
          ? (DateTime.tryParse(json["startDate"].toString()) ?? DateTime.now())
          : DateTime.now(),
      endDate: json["endDate"] != null
          ? (DateTime.tryParse(json["endDate"].toString()) ?? DateTime.now())
          : DateTime.now(),
      datumDuration: json["duration"]?.toString() ?? '',
      permitType: json["permitType"]?.toString() ?? '',
      priority: json["priority"]?.toString() ?? '',
      attachments: json["attachments"]?.toString() ?? '',
      createdBy: json["createdBy"]?.toString() ?? '',
      isActive: json["isActive"] ?? true,
      total: json["total"]?.toString() ?? '',
      completed: json["completed"]?.toString() ?? '',
      status: json["status"]?.toString() ?? '',
      remark: json["remark"]?.toString() ?? '',
      attachementUrl: json["attachementUrl"]?.toString() ?? '',
      woRequestFormattachements:
          json["woRequestFormattachements"]?.toString() ?? '',
      woCompletedFormAttachements:
          json["woCompletedFormAttachements"]?.toString() ?? '',
      woRequestFormattachementUrl:
          json["woRequestFormattachementUrl"]?.toString() ?? '',
      woCompletedFormAttachementstUrl:
          json["woCompletedFormAttachementstUrl"]?.toString() ?? '',
      fieldName: json["fieldName"]?.toString() ?? json["location"]?.toString() ?? '',
      platform: json["platform"]?.toString() ?? json["subLocation"]?.toString() ?? '',
      deckLevel: json["deckLevel"]?.toString() ?? json["area"]?.toString() ?? '',
      custodian: json["custodian"]?.toString() ?? '',
      issuedBy: json["issuedBy"]?.toString() ?? '',
      assigendTeam: json["assigendTeam"] ?? json["assignedTeam"] ?? '',
      issueDate: json["issueDate"]?.toString() ?? '',
      duration: (json["Duration"] ?? json["duration"])?.toString() ?? '',
      comletionDate: json["comletionDate"]?.toString() ?? '',
      closedOutBy: json["closedOutBy"]?.toString() ?? '',
      closeOutDate: json["closeOutDate"]?.toString() ?? '',
      progress: json["progress"]?.toString() ?? '',
      currentStatus: json["currentStatus"]?.toString() ?? '',
      remarks: json["remarks"]?.toString() ?? '',
      uploadedDate: json["uploadedDate"] != null
          ? (DateTime.tryParse(json["uploadedDate"].toString()) ??
              DateTime.now())
          : DateTime.now(),
      uploadedBy: json["uploadedBy"]?.toString() ?? '',
      workOrderRequest: json["workOrderRequest"]?.toString() ?? '',
      riskAssessmentForm: json["riskAssessmentForm"]?.toString() ?? '',
      completeWorkOrderForm: json["completeWorkOrderForm"]?.toString() ?? '',
      schedulingStartDate: json["schedulingStartDate"]?.toString() ?? '',
      schedulingFinishDate: json["schedulingFinishDate"]?.toString() ?? '',
      schedulingDuration: json["schedulingDuration"]?.toString() ?? '',
      actualStartDate: json["actualStartDate"]?.toString() ?? '',
      actualFinishDate: json["actualFinishDate"]?.toString() ?? '',
      actualDuration: json["actualDuration"]?.toString() ?? '',
      scheduledVariance: json["scheduledVariance"]?.toString() ?? '',
      estimateManPowerCost: json["estimateManPowerCost"]?.toString() ?? '',
      estimatedManHours: json["estimatedManHours"]?.toString() ?? '',
      estimateMaterialCost: json["estimateMaterialCost"]?.toString() ?? '',
      estimateMachineryCost: json["estimateMachineryCost"]?.toString() ?? '',
      estimateTotalCost: json["estimateTotalCost"]?.toString() ?? '',
      actualManHours: json["actualManHours"]?.toString() ?? '',
      actualManPowerCost: json["actualManPowerCost"]?.toString() ?? '',
      actualMaterialCost: json["actualMaterialCost"]?.toString() ?? '',
      actualMachineryCost: json["actualMachineryCost"]?.toString() ?? '',
      actualTotalCost: json["actualTotalCost"]?.toString() ?? '',
      costVariance: json["costVariance"]?.toString() ?? '',
      costBudgetRemarks: json["costBudgetRemarks"]?.toString() ?? '',
      projectName: json["projectName"]?.toString() ?? '',
      assignedTo: json["assignedTo"] ?? json["assigned_to"],
      userId: json["userId"] ?? json["user_id"],
      assignedUserId: json["assignedUserId"] ?? json["assigned_user_id"],
      inspectorId: json["inspectorId"] ?? json["technicianId"] ?? json["assignedInspector"],
    );
  }

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
        "assignedTo": assignedTo,
        "userId": userId,
        "assignedUserId": assignedUserId,
        "inspectorId": inspectorId,
      };
}
