import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/inspection_checklist_request.dart';

class ExInspectionRequest {
  FunctionalAreaRequest? functionalAreaRequest;
  EquipmentTagRequest? equipmentTagRequest;
  InspectionChecklistRequest? inspectionChecklistRequest;

  ExInspectionRequest(
      {this.functionalAreaRequest,
      this.equipmentTagRequest,
      this.inspectionChecklistRequest,
     });
}
