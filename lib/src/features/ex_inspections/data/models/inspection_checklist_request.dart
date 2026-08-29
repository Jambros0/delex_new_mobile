class InspectionChecklistRequest {
  final String? inspectionType;
  final String? equipmentType;
  // final String? checklistName;
  final List<String> checklistName;
  final String? inspectionGrade;
  InspectionChecklistRequest({
    this.inspectionType,
    this.equipmentType,
    required this.checklistName,
    this.inspectionGrade,
  });

  Map<String, dynamic> toJson() {
    return {
      'inspectionType': inspectionType,
      'equipmentType': equipmentType,
      'checklistName': checklistName,
      'inspectionGrade': inspectionGrade,
    };
  }
}
