import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class DashboardInitEvent extends DashboardEvent {}

class YearToDateFilterDashboard extends DashboardEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isBefore;
  final List<String> selectedLocations;
  final String type;
  YearToDateFilterDashboard(
      {this.fromDate,
      this.toDate,
      required this.isBefore,
      required this.selectedLocations,
      required this.type});

  @override
  List<Object> get props =>
      [fromDate ?? '', toDate ?? '', isBefore, selectedLocations, type];
}

class LocationFilterDashboard extends DashboardEvent {
  final List<String> selectedLocations;
  final bool isBefore;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String type;

  LocationFilterDashboard(
      {required this.selectedLocations,
      required this.isBefore,
      this.fromDate,
      this.toDate,
      required this.type});
}
