import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:equatable/equatable.dart';

abstract class ToServerState extends Equatable {
  @override
  List<Object> get props => [];
}

class WorkOrderToServerLoading extends ToServerState {}

class WorkOrderToServerInitial extends ToServerState {}

class ToServerLoading extends ToServerState {}

class ToServerError extends ToServerState {
  final String error;

  ToServerError(this.error);

  @override
  List<Object> get props => [error];
}

class WorkOrderToServerLoaded extends ToServerState {
  final List<String> tableHeaders;
  final List<ExRegister> assets;
  final int totalRecords;
  final bool isLoadMore;
  final int? filterIndex;
  final int skip;
  final dynamic sortOrder;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  final bool hasMoreData;
  WorkOrderToServerLoaded({
    required this.tableHeaders,
    required this.assets,
    this.totalRecords = 0,
    this.isLoadMore = false,
    this.filterIndex,
    required this.skip,
    required this.sortOrder,
    this.selectedFilters = const [],
    this.collectionSelectedFilter = const {},
    this.hasMoreData = true,
  });

  @override
  List<Object> get props =>
      [tableHeaders, assets, totalRecords, isLoadMore, filterIndex ?? -1, skip];
}

class WorkOrderToServerError extends ToServerState {
  final String error;

  WorkOrderToServerError(this.error);

  @override
  List<Object> get props => [error];
}

class ShowToServerMoreOption extends ToServerState {
  final bool showIcon;
  final List<String> selectedAssets;
  ShowToServerMoreOption(
      {required this.showIcon, required this.selectedAssets});
  @override
  List<Object> get props => [showIcon, selectedAssets];
}
