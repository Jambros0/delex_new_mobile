import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:equatable/equatable.dart';

abstract class ExRegisterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadExRegister extends ExRegisterEvent {}

class ResetExRegisterState extends ExRegisterEvent {}

class ResetFilterExRegister extends ExRegisterEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isReset;
  final String? type;
  final String? showAllFilterType;
  final Map<String, List<String>> collectionSelectedFilterData;
  ResetFilterExRegister(
      {this.fromDate,
      this.toDate,
      required this.isReset,
      this.type,
      this.showAllFilterType,
      required this.collectionSelectedFilterData});
  @override
  List<Object> get props => [fromDate ?? '', toDate ?? '', isReset];
}

class InitLoadExRegister extends ExRegisterEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isReset;
  final String? type;
  final String? showAllFilterType;
  InitLoadExRegister(
      {this.fromDate,
      this.toDate,
      required this.isReset,
      this.type,
      this.showAllFilterType});
  @override
  List<Object> get props => [fromDate ?? '', toDate ?? '', isReset];
}

class ExRegisterInitEvent extends ExRegisterEvent {}

class UpdateExRegisterAfterChange extends ExRegisterEvent {
  final List<ExRegister> currentAssets;
  final List<String> tableHeaders;
  final int totalRecords;
  final int skip;
  final int offset;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isDuplicate;
  UpdateExRegisterAfterChange(
      {required this.currentAssets,
      required this.tableHeaders,
      required this.totalRecords,
      required this.skip,
      required this.offset,
      this.fromDate,
      this.toDate,
      required this.isDuplicate});
}

class LoadMoreExRegister extends ExRegisterEvent {
  final List<String> tableHeaders;
  final List<ExRegister> assets;
  final int totalRecords;
  final bool isLoadMore;
  final int skip;
  final String? type;
  final String? showAllFilterType;
  final DateTime? fromDate;
  final DateTime? toDate;
  LoadMoreExRegister(
      {required this.tableHeaders,
      required this.assets,
      required this.totalRecords,
      required this.isLoadMore,
      required this.skip,
      this.type,
      this.showAllFilterType,
      this.fromDate,
      this.toDate});
  @override
  List<Object> get props =>
      [tableHeaders, assets, totalRecords, isLoadMore, skip];
}

class YearToDateFilterExRegister extends ExRegisterEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isReset;
  final String? type;
  final String? showAllFilterType;
  YearToDateFilterExRegister(
      {this.fromDate,
      this.toDate,
      required this.isReset,
      this.type,
      this.showAllFilterType});
  @override
  List<Object> get props => [fromDate ?? '', toDate ?? '', isReset];
}

class ShowAllFilterExRegister extends ExRegisterEvent {
  final String? type;
  final DateTime? fromDate;
  final DateTime? toDate;
  ShowAllFilterExRegister({this.type, this.fromDate, this.toDate});
  @override
  List<Object> get props => [type ?? '', fromDate ?? '', toDate ?? ''];
}

class SortExRegister extends ExRegisterEvent {
  final String sortField;
  final String sortOrder;
  final int columnIndex;
  final List<String> selectedFilters;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String type;
  final String showAllFilterType;
  final String searchQuery;
  final Map<String, List<String>> collectionSelectedFilter;
  SortExRegister(
      {required this.sortField,
      required this.sortOrder,
      required this.columnIndex,
      required this.selectedFilters,
      this.fromDate,
      this.toDate,
      required this.type,
      required this.showAllFilterType,
      required this.searchQuery,
      required this.collectionSelectedFilter});
  @override
  List<Object> get props =>
      [sortField, sortOrder, columnIndex, selectedFilters];
}

class ExRegisterDownload extends ExRegisterEvent {
  final String fileType;
  final List<ExRegister>? assets;
  final List<String> assetIds;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? type;
  final String? showAllFilterType;
  final String searchQuery;

  ExRegisterDownload(
      {required this.fileType,
      required this.assets,
      required this.assetIds,
      this.fromDate,
      this.toDate,
      this.type,
      this.showAllFilterType,
      required this.searchQuery});
  @override
  List<Object> get props => [fileType, assets!, assetIds];
}

class ExRegisterRowSelected extends ExRegisterEvent {
  final bool showIcon;
  final List<String> selectedAssets;
  ExRegisterRowSelected({required this.showIcon, required this.selectedAssets});
  @override
  List<Object> get props => [showIcon, selectedAssets];
}

class ExRegisterDuplicateOrDelete extends ExRegisterEvent {
  final String assetId;
  final String type;
  final List<String> assetIds;
  ExRegisterDuplicateOrDelete(
      {required this.assetId, required this.type, required this.assetIds});
  @override
  List<Object> get props => [assetId, type, assetIds];
}

class ExRegisterGenerateItr extends ExRegisterEvent {
  final String assetId;
  ExRegisterGenerateItr({required this.assetId});
  @override
  List<Object> get props => [assetId];
}
