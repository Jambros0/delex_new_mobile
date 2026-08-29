import 'package:equatable/equatable.dart';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object> get props => [];
}

class DashboardLoading extends DashboardState {}

class DashboardShowLoader extends DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardError extends DashboardState {
  final String error;

  DashboardError(this.error);

  @override
  List<Object> get props => [error];
}

class DashboardLoaded extends DashboardState {
  final List<ExRegister> assets;
  final int totalRecords;
  final Map<String, int> statusCounts;
  final Map<String, int> repairedChartCounts;
  final Map<String, int> equipmentCounts;
  DashboardLoaded({
    required this.assets,
    this.totalRecords = 0,
    required this.statusCounts,
    required this.repairedChartCounts, required this.equipmentCounts,
  });

  @override
  List<Object> get props =>
      [assets, totalRecords, statusCounts, repairedChartCounts, equipmentCounts];
}
