import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:equatable/equatable.dart';

abstract class ToServerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class WorkOrderToServerLoad extends ToServerEvent {}

class WorkOrderToServerLoadMore extends ToServerEvent {
  final List<String> tableHeaders;
  final List<ExRegister> assets;
  final int totalRecords;
  final bool isLoadMore;
  final int skip;
  WorkOrderToServerLoadMore(
      {required this.tableHeaders,
      required this.assets,
      required this.totalRecords,
      required this.isLoadMore,
      required this.skip});
  @override
  List<Object> get props =>
      [tableHeaders, assets, totalRecords, isLoadMore, skip];
}

class ResetWorkOrderToServer extends ToServerEvent {
  final Map<String, List<String>> collectionSelectedFilter;
  ResetWorkOrderToServer({required this.collectionSelectedFilter});
  @override
  List<Object> get props => [collectionSelectedFilter];
}

class SortToServerLoad extends ToServerEvent {
  final String sortField;
  final String sortOrder;
  final int columnIndex;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  SortToServerLoad(
      {required this.sortField,
      required this.sortOrder,
      required this.columnIndex,
      required this.selectedFilters,
      required this.collectionSelectedFilter});
  @override
  List<Object> get props => [
        sortField,
        sortOrder,
        columnIndex,
        selectedFilters,
        collectionSelectedFilter
      ];
}
