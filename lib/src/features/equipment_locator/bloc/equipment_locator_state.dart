import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:equatable/equatable.dart';

abstract class EquipmentLocatorState extends Equatable {
  const EquipmentLocatorState();

  @override
  List<Object> get props => [];
}

class EquipmentLocatorInitial extends EquipmentLocatorState {}

class EquipmentLocatorLoaded extends EquipmentLocatorState {
  final List<String> tableHeaders;
  final List<ExRegister> assets;
  final List<Location> locationCollection;
  const EquipmentLocatorLoaded({
    required this.tableHeaders,
    required this.assets,
    required this.locationCollection,
  });

  @override
  List<Object> get props => [tableHeaders, assets, locationCollection];
}

class EquipmentLocatorError extends EquipmentLocatorState {
  final String error;

  const EquipmentLocatorError(this.error);

  @override
  List<Object> get props => [error];
}

class EquipmentLocatorLoading extends EquipmentLocatorState {}
