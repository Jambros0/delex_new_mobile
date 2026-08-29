import 'dart:async';
import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/features/equipment_locator/bloc/equipment_locator_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/equipment_locator/bloc/equipment_locator_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/services/ex_register_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EquipmentLocatorBloc
    extends Bloc<EquipmentLocatorEvents, EquipmentLocatorState> {
  final ExRegisterService exRegisterService;
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils;

  EquipmentLocatorBloc(
      {required this.exRegisterService, required this.authUtils})
      : super(EquipmentLocatorInitial()) {
    on<LoadEquipmentLocator>(loadExRegisterFromOffline);
  }

  FutureOr<void> loadExRegisterFromOffline(
      LoadEquipmentLocator event, Emitter<EquipmentLocatorState> emit) async {
    try {
      final String? userType = await authUtils.getUserType();
      List<Map<String, dynamic>> results = (userType == 'onshore')
          ? await _dbHelper.getExRegisterOnshore()
          : await _dbHelper.getExRegister();
      List<Map<String, dynamic>> functioanlResults = (userType == 'onshore')
          ? await _dbHelper.getFunctionalAreaDataOnshore()
          : await _dbHelper.getFunctionalAreaData();
      List<ExRegister> assets = results.map((e) {
        dynamic exRegisterJson = e['exregister_json'];
        Map<String, dynamic> jsonMap;
        if (exRegisterJson is String) {
          try {
            jsonMap = jsonDecode(exRegisterJson);
          } catch (decodeError) {
            throw FormatException(
                "Invalid JSON string in exregister_json: $exRegisterJson");
          }
        } else if (exRegisterJson is Map<String, dynamic>) {
          jsonMap = exRegisterJson;
        } else {
          throw FormatException(
              "Invalid type for exregister_json: ${exRegisterJson.runtimeType}");
        }
        return ExRegister.fromJson(jsonMap['asset']);
      }).toList();
      List<Location> locationCollection = functioanlResults.map((e) {
        dynamic functionalAreaJson = e['functional_area_json'];
        Map<String, dynamic> jsonMap;
        if (functionalAreaJson is String) {
          try {
            jsonMap = jsonDecode(functionalAreaJson);
          } catch (decodeError) {
            throw FormatException(
                "Invalid JSON string in functional_area_json: $functionalAreaJson");
          }
        } else if (functionalAreaJson is Map<String, dynamic>) {
          jsonMap = functionalAreaJson;
        } else {
          throw FormatException(
              "Invalid type for functional_area_json: ${functionalAreaJson.runtimeType}");
        }
        return Location.fromJson(jsonMap['location']);
      }).toList();
      List<String> tableHeaders = [
        "RFID Reference",
        "Field Name",
        "Platform",
        "Deck Level",
        "Zone",
        "Discipline",
        "Equipment Tag Number",
        "Equipment Description",
        "Equipment Manufacturer",
        "Equipment Protection",
        "Inspection Faults",
        "Inspection Status",
        "Completed Repairs",
        "Existing Faults",
        "Current Status",
      ];
      emit(EquipmentLocatorLoaded(
        tableHeaders: tableHeaders,
        assets: assets,
        locationCollection: locationCollection,
      ));
    } catch (e) {
      emit(EquipmentLocatorError(e.toString()));
    }
  }
}
