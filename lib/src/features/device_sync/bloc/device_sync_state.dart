import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:equatable/equatable.dart';

abstract class DeviceSyncState extends Equatable {
  @override
  List<Object> get props => [];
}

class WorkOrderLoading extends DeviceSyncState {}

class WorkOrderInitial extends DeviceSyncState {}

class WorkOrderLoaded extends DeviceSyncState {
  final List<String> tableHeaders;
  final List<ExRegister> assets;
  final int totalRecords;
  final int skip;
  final dynamic sortOrder;
  final int? filterIndex;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  final bool hasMoreData;
  final List<WorkOrderTableJson> workOrderCollection;
  final bool isupdateAsset;
  WorkOrderLoaded({
    required this.tableHeaders,
    required this.assets,
    this.totalRecords = 0,
    required this.skip,
    required this.sortOrder,
    this.filterIndex,
    this.selectedFilters = const [],
    this.collectionSelectedFilter = const {},
    this.hasMoreData = true,
    this.workOrderCollection = const [],
    required this.isupdateAsset,
  });

  @override
  List<Object> get props =>
      [tableHeaders, assets, totalRecords, skip, sortOrder, filterIndex ?? -1];
}

class WorkOrderNewLoaded extends DeviceSyncState {
  final List<String> tableHeaders;
  final List<ExRegister> assets;
  final int totalRecords;
  final int skip;
  final dynamic sortOrder;
  final int? filterIndex;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  final bool hasMoreData;
  final List<WorkOrderTableJson> workOrderCollection;
  WorkOrderNewLoaded({
    required this.tableHeaders,
    required this.assets,
    this.totalRecords = 0,
    required this.skip,
    required this.sortOrder,
    this.filterIndex,
    this.selectedFilters = const [],
    this.collectionSelectedFilter = const {},
    this.hasMoreData = true,
    this.workOrderCollection = const [],
  });

  @override
  List<Object> get props =>
      [tableHeaders, assets, totalRecords, skip, sortOrder, filterIndex ?? -1];
}

class WorkOrderError extends DeviceSyncState {
  final String error;

  WorkOrderError(this.error);

  @override
  List<Object> get props => [error];
}
