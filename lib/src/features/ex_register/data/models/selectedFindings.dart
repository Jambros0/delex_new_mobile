import 'dart:convert';

SelectedFindingsModel selectedFindingsModelFromJson(String str) => SelectedFindingsModel.fromJson(json.decode(str));

String selectedFindingsModelToJson(SelectedFindingsModel data) => json.encode(data.toJson());

class SelectedFindingsModel {
  String id;
  String defectCode;
  String finding;
  String remedialAction;
  String defectCategory;
  bool isDone;
  bool isSelected;
  dynamic repairedAt;
  dynamic repairedBy;
  dynamic updatedAt;

  SelectedFindingsModel({
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

  factory SelectedFindingsModel.fromJson(Map<String, dynamic> json) => SelectedFindingsModel(
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
