import 'dart:io';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/ex_inspection_request.dart';
import 'package:equatable/equatable.dart';

import '../data/models/inspection_checklist_request.dart';

abstract class ExInspectionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAllDropDwn extends ExInspectionsEvent {}

class SubmitFunctionalArea extends ExInspectionsEvent {
  final ExInspectionRequest request;
  SubmitFunctionalArea(this.request);
  @override
  List<Object?> get props => [request];
}

class SubmitEquipmentTag extends ExInspectionsEvent {
  final ExInspectionRequest request;
  final String? screenType;
  final bool? clearFlag;
  final bool userUpdateSign;
  SubmitEquipmentTag(this.request,
      {this.screenType, this.clearFlag, this.userUpdateSign = false});

  @override
  List<Object?> get props => [request, screenType, clearFlag];
}

class SubmitInspectionChecklist extends ExInspectionsEvent {
  final InspectionChecklistRequest exInspectionRequest;
  final Map<String, Object?>? filters;
  final List<CheckList>? checkList;
  SubmitInspectionChecklist(
      this.exInspectionRequest, this.filters, this.checkList);
}

class UploadFile extends ExInspectionsEvent {
  final File file;
  final String fileOf;
  UploadFile(this.file, this.fileOf);
}

class UploadFunctionalAreaFile extends ExInspectionsEvent {
  final File file;
  final String fileOf;
  final int index;
  UploadFunctionalAreaFile(this.file, this.fileOf, this.index);
}

class FilterInspectionChecklist extends ExInspectionsEvent {
  final Map<String, String?> selectedFilters;

  FilterInspectionChecklist(this.selectedFilters);

  @override
  List<Object?> get props => [selectedFilters];
}
