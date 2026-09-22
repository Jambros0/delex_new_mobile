import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:equatable/equatable.dart';

abstract class DeviceSyncEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadWorkOrder extends DeviceSyncEvent {}

class LoadNewWorkOrder extends DeviceSyncEvent {}

class LoadMoreWorkOrder extends DeviceSyncEvent {
  final List<String> tableHeaders;
  final List<ExRegister> assets;
  final int totalRecords;

  LoadMoreWorkOrder({
    required this.tableHeaders,
    required this.assets,
    required this.totalRecords,
  });
  @override
  List<Object> get props => [tableHeaders, assets, totalRecords];
}

class ResetLoadMoreWorkOrder extends DeviceSyncEvent {
  final Map<String, List<String>> collectionSelectedFilter;
  final List<ExRegister> assets;
  final List<ExRegister> registerCollections;
  ResetLoadMoreWorkOrder(
      {required this.collectionSelectedFilter,
      required this.assets,
      required this.registerCollections});
  @override
  List<Object> get props =>
      [collectionSelectedFilter, assets, registerCollections];
}

class SortLoadMoreWorkOrder extends DeviceSyncEvent {
  final String sortField;
  final String sortOrder;
  final int columnIndex;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  final List<ExRegister> assets;
  final List<ExRegister> registerCollections;
  SortLoadMoreWorkOrder(
      {required this.sortField,
      required this.sortOrder,
      required this.columnIndex,
      required this.selectedFilters,
      required this.collectionSelectedFilter,
      required this.assets,
      required this.registerCollections});
  @override
  List<Object> get props => [
        sortField,
        sortOrder,
        columnIndex,
        selectedFilters,
        collectionSelectedFilter,
        assets
      ];
}

class RemoveTransferredAssetsFromDeviceSync extends DeviceSyncEvent {
  final List<String> transferredAssetIds;
  RemoveTransferredAssetsFromDeviceSync(this.transferredAssetIds);

  @override
  List<Object> get props => [transferredAssetIds];
}
