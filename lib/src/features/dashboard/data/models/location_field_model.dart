import 'dart:convert';

LocationFieldModel locationFieldModelFromJson(String str) =>
    LocationFieldModel.fromJson(json.decode(str));

String locationFieldModelToJson(LocationFieldModel data) =>
    json.encode(data.toJson());

class LocationFieldModel {
  bool status;
  String message;
  Result result;

  LocationFieldModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory LocationFieldModel.fromJson(Map<String, dynamic> json) =>
      LocationFieldModel(
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result.toJson(),
      };
}

class Result {
  List<ResultLocationDropDown> locationDropDown;
  List<ExResiterDropDown> exResiterDropDown;

  Result({
    required this.locationDropDown,
    required this.exResiterDropDown,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        locationDropDown: List<ResultLocationDropDown>.from(
            json["locationDropDown"]
                .map((x) => ResultLocationDropDown.fromJson(x))),
        exResiterDropDown: List<ExResiterDropDown>.from(
            json["exResiterDropDown"]
                .map((x) => ExResiterDropDown.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "locationDropDown":
            List<dynamic>.from(locationDropDown.map((x) => x.toJson())),
        "exResiterDropDown":
            List<dynamic>.from(exResiterDropDown.map((x) => x.toJson())),
      };
}

class ExResiterDropDown {
  String id;
  List<String> zone;
  List<String> gasGroup;
  List<String> temperatureClass;
  List<String> ipRating;
  List<String> areaStatus;
  List<String> discipline;
  List<String> equipementDescription;
  List<String> atexCategory;
  List<dynamic> equipmentCategory;
  List<String> epl;
  List<ProtectionStandard> protectionStandard;
  List<String> protectionType;
  List<String> specialCondition;
  List<String> inspectionType;
  List<String> equipmentType;
  List<String> inspectionCheckList;
  List<String> inspectionGrade;
  List<String> faultCategory;
  List<String> failureHistory;
  List<String> envSeverity;
  List<String> equipmentAgening;
  List<String> equipmentCriticality;
  List<String> ignitionSourceProb;
  List<String> protFlamambleAtom;
  List<String> ignitionFlask;
  List<String> inspectionStatus;
  List<String> repairPriority;
  List<String> overAllCondition;
  List<String> isolationRepairs;
  List<String> requirementRepairs;
  List<String> currentStatus;
  List<String> defectCategory;
  List<String> currentCondition;
  List<String> isolationRequirement;
  List<String> otherRequirement;
  List<String> exRegisterDefFilter;
  String createdBy;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  ExResiterDropDown({
    required this.id,
    required this.zone,
    required this.gasGroup,
    required this.temperatureClass,
    required this.ipRating,
    required this.areaStatus,
    required this.discipline,
    required this.equipementDescription,
    required this.atexCategory,
    required this.equipmentCategory,
    required this.epl,
    required this.protectionStandard,
    required this.protectionType,
    required this.specialCondition,
    required this.inspectionType,
    required this.equipmentType,
    required this.inspectionCheckList,
    required this.inspectionGrade,
    required this.faultCategory,
    required this.failureHistory,
    required this.envSeverity,
    required this.equipmentAgening,
    required this.equipmentCriticality,
    required this.ignitionSourceProb,
    required this.protFlamambleAtom,
    required this.ignitionFlask,
    required this.inspectionStatus,
    required this.repairPriority,
    required this.overAllCondition,
    required this.isolationRepairs,
    required this.requirementRepairs,
    required this.currentStatus,
    required this.defectCategory,
    required this.currentCondition,
    required this.isolationRequirement,
    required this.otherRequirement,
    required this.exRegisterDefFilter,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ExResiterDropDown.fromJson(Map<String, dynamic> json) =>
      ExResiterDropDown(
        id: json["_id"],
        zone: List<String>.from(json["zone"].map((x) => x)),
        gasGroup: List<String>.from(json["gasGroup"].map((x) => x)),
        temperatureClass:
            List<String>.from(json["temperatureClass"].map((x) => x)),
        ipRating: List<String>.from(json["ipRating"].map((x) => x)),
        areaStatus: List<String>.from(json["areaStatus"].map((x) => x)),
        discipline: List<String>.from(json["discipline"].map((x) => x)),
        equipementDescription:
            List<String>.from(json["equipementDescription"].map((x) => x)),
        atexCategory: List<String>.from(json["atexCategory"].map((x) => x)),
        equipmentCategory:
            List<dynamic>.from(json["equipmentCategory"].map((x) => x)),
        epl: List<String>.from(json["epl"].map((x) => x)),
        protectionStandard: List<ProtectionStandard>.from(
            json["protectionStandard"]
                .map((x) => ProtectionStandard.fromJson(x))),
        protectionType: List<String>.from(json["protectionType"].map((x) => x)),
        specialCondition:
            List<String>.from(json["specialCondition"].map((x) => x)),
        inspectionType: List<String>.from(json["inspectionType"].map((x) => x)),
        equipmentType: List<String>.from(json["equipmentType"].map((x) => x)),
        inspectionCheckList:
            List<String>.from(json["inspectionCheckList"].map((x) => x)),
        inspectionGrade:
            List<String>.from(json["inspectionGrade"].map((x) => x)),
        faultCategory: List<String>.from(json["faultCategory"].map((x) => x)),
        failureHistory: List<String>.from(json["failureHistory"].map((x) => x)),
        envSeverity: List<String>.from(json["envSeverity"].map((x) => x)),
        equipmentAgening:
            List<String>.from(json["equipmentAgening"].map((x) => x)),
        equipmentCriticality:
            List<String>.from(json["equipmentCriticality"].map((x) => x)),
        ignitionSourceProb:
            List<String>.from(json["ignitionSourceProb"].map((x) => x)),
        protFlamambleAtom:
            List<String>.from(json["protFlamambleAtom"].map((x) => x)),
        ignitionFlask: List<String>.from(json["ignitionFlask"].map((x) => x)),
        inspectionStatus:
            List<String>.from(json["inspectionStatus"].map((x) => x)),
        repairPriority: List<String>.from(json["repairPriority"].map((x) => x)),
        overAllCondition:
            List<String>.from(json["overAllCondition"].map((x) => x)),
        isolationRepairs:
            List<String>.from(json["isolationRepairs"].map((x) => x)),
        requirementRepairs:
            List<String>.from(json["requirementRepairs"].map((x) => x)),
        currentStatus: List<String>.from(json["currentStatus"].map((x) => x)),
        defectCategory: List<String>.from(json["defectCategory"].map((x) => x)),
        currentCondition:
            List<String>.from(json["currentCondition"].map((x) => x)),
        isolationRequirement:
            List<String>.from(json["isolationRequirement"].map((x) => x)),
        otherRequirement:
            List<String>.from(json["otherRequirement"].map((x) => x)),
        exRegisterDefFilter:
            List<String>.from(json["exRegisterDefFilter"].map((x) => x)),
        createdBy: json["createdBy"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "zone": List<dynamic>.from(zone.map((x) => x)),
        "gasGroup": List<dynamic>.from(gasGroup.map((x) => x)),
        "temperatureClass": List<dynamic>.from(temperatureClass.map((x) => x)),
        "ipRating": List<dynamic>.from(ipRating.map((x) => x)),
        "areaStatus": List<dynamic>.from(areaStatus.map((x) => x)),
        "discipline": List<dynamic>.from(discipline.map((x) => x)),
        "equipementDescription":
            List<dynamic>.from(equipementDescription.map((x) => x)),
        "atexCategory": List<dynamic>.from(atexCategory.map((x) => x)),
        "equipmentCategory":
            List<dynamic>.from(equipmentCategory.map((x) => x)),
        "epl": List<dynamic>.from(epl.map((x) => x)),
        "protectionStandard":
            List<dynamic>.from(protectionStandard.map((x) => x.toJson())),
        "protectionType": List<dynamic>.from(protectionType.map((x) => x)),
        "specialCondition": List<dynamic>.from(specialCondition.map((x) => x)),
        "inspectionType": List<dynamic>.from(inspectionType.map((x) => x)),
        "equipmentType": List<dynamic>.from(equipmentType.map((x) => x)),
        "inspectionCheckList":
            List<dynamic>.from(inspectionCheckList.map((x) => x)),
        "inspectionGrade": List<dynamic>.from(inspectionGrade.map((x) => x)),
        "faultCategory": List<dynamic>.from(faultCategory.map((x) => x)),
        "failureHistory": List<dynamic>.from(failureHistory.map((x) => x)),
        "envSeverity": List<dynamic>.from(envSeverity.map((x) => x)),
        "equipmentAgening": List<dynamic>.from(equipmentAgening.map((x) => x)),
        "equipmentCriticality":
            List<dynamic>.from(equipmentCriticality.map((x) => x)),
        "ignitionSourceProb":
            List<dynamic>.from(ignitionSourceProb.map((x) => x)),
        "protFlamambleAtom":
            List<dynamic>.from(protFlamambleAtom.map((x) => x)),
        "ignitionFlask": List<dynamic>.from(ignitionFlask.map((x) => x)),
        "inspectionStatus": List<dynamic>.from(inspectionStatus.map((x) => x)),
        "repairPriority": List<dynamic>.from(repairPriority.map((x) => x)),
        "overAllCondition": List<dynamic>.from(overAllCondition.map((x) => x)),
        "isolationRepairs": List<dynamic>.from(isolationRepairs.map((x) => x)),
        "requirementRepairs":
            List<dynamic>.from(requirementRepairs.map((x) => x)),
        "currentStatus": List<dynamic>.from(currentStatus.map((x) => x)),
        "defectCategory": List<dynamic>.from(defectCategory.map((x) => x)),
        "currentCondition": List<dynamic>.from(currentCondition.map((x) => x)),
        "isolationRequirement":
            List<dynamic>.from(isolationRequirement.map((x) => x)),
        "otherRequirement": List<dynamic>.from(otherRequirement.map((x) => x)),
        "exRegisterDefFilter":
            List<dynamic>.from(exRegisterDefFilter.map((x) => x)),
        "createdBy": createdBy,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class ProtectionStandard {
  Iec iec;
  Iec nec;
  Iec notApplicable;
  Iec notAvailable;

  ProtectionStandard({
    required this.iec,
    required this.nec,
    required this.notApplicable,
    required this.notAvailable,
  });

  factory ProtectionStandard.fromJson(Map<String, dynamic> json) =>
      ProtectionStandard(
        iec: Iec.fromJson(json["IEC"]),
        nec: Iec.fromJson(json["NEC"]),
        notApplicable: Iec.fromJson(json["Not Applicable"]),
        notAvailable: Iec.fromJson(json["Not Available"]),
      );

  Map<String, dynamic> toJson() => {
        "IEC": iec.toJson(),
        "NEC": nec.toJson(),
        "Not Applicable": notApplicable.toJson(),
        "Not Available": notAvailable.toJson(),
      };
}

class Iec {
  List<String> protectionType;
  List<String> gasGroup;
  List<String> temperatureClass;
  List<String> epl;
  List<String> atexCategory;

  Iec({
    required this.protectionType,
    required this.gasGroup,
    required this.temperatureClass,
    required this.epl,
    required this.atexCategory,
  });

  factory Iec.fromJson(Map<String, dynamic> json) => Iec(
        protectionType: List<String>.from(json["protectionType"].map((x) => x)),
        gasGroup: List<String>.from(json["gasGroup"].map((x) => x)),
        temperatureClass:
            List<String>.from(json["temperatureClass"].map((x) => x)),
        epl: List<String>.from(json["epl"].map((x) => x)),
        atexCategory: List<String>.from(json["atexCategory"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "protectionType": List<dynamic>.from(protectionType.map((x) => x)),
        "gasGroup": List<dynamic>.from(gasGroup.map((x) => x)),
        "temperatureClass": List<dynamic>.from(temperatureClass.map((x) => x)),
        "epl": List<dynamic>.from(epl.map((x) => x)),
        "atexCategory": List<dynamic>.from(atexCategory.map((x) => x)),
      };
}

class ResultLocationDropDown {
  String id;
  List<LocationDropDown> locationDropDown;
  List<String> deckLevel;
  String createdBy;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  ResultLocationDropDown({
    required this.id,
    required this.locationDropDown,
    required this.deckLevel,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ResultLocationDropDown.fromJson(Map<String, dynamic> json) =>
      ResultLocationDropDown(
        id: json["_id"],
        locationDropDown: List<LocationDropDown>.from(
            json["locationDropDown"].map((x) => LocationDropDown.fromJson(x))),
        deckLevel: List<String>.from(json["deckLevel"].map((x) => x)),
        createdBy: json["createdBy"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "locationDropDown":
            List<dynamic>.from(locationDropDown.map((x) => x.toJson())),
        "deckLevel": List<dynamic>.from(deckLevel.map((x) => x)),
        "createdBy": createdBy,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class LocationDropDown {
  String name;
  List<String> platform;

  LocationDropDown({
    required this.name,
    required this.platform,
  });

  factory LocationDropDown.fromJson(Map<String, dynamic> json) =>
      LocationDropDown(
        name: json["name"],
        platform: List<String>.from(json["platform"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "platform": List<dynamic>.from(platform.map((x) => x)),
      };
}
