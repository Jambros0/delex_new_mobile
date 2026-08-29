import 'package:equatable/equatable.dart';

abstract class EquipmentLocatorEvents extends Equatable {
  const EquipmentLocatorEvents();

  @override
  List<Object> get props => [];
}

class LoadEquipmentLocator extends EquipmentLocatorEvents {}

class EquipmentLocatorInitEvent extends EquipmentLocatorEvents {}
