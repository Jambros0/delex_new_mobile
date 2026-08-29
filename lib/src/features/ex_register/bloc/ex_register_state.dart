import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:equatable/equatable.dart';

abstract class ExRegisterState extends Equatable {
  @override
  List<Object> get props => [];
}

class ExRegisterLoading extends ExRegisterState {}

class ExRegisterShowLoader extends ExRegisterState {}

class ExRegisterIsLoading extends ExRegisterState {
  final bool isLoadMore;

  ExRegisterIsLoading({
    this.isLoadMore = false,
  });

  @override
  List<Object> get props => [
        isLoadMore,
      ];
}

class ExRegisterDuplicateOrDeleteSuccess extends ExRegisterState {
  final String message;
  final bool isDuplicate;
  // final String? deletedAssetId;
  ExRegisterDuplicateOrDeleteSuccess({
    required this.message,
    required this.isDuplicate,
    //this.deletedAssetId
  });
  @override
  List<Object> get props => [
        message,
        isDuplicate,
        //deletedAssetId ?? ''
      ];
}

class ExRegisterLoadMore extends ExRegisterState {}

class ExRegisterInitial extends ExRegisterState {}

class ShowExRegisterMoreOption extends ExRegisterState {
  final bool showIcon;
  final List<String> selectedAssets;
  ShowExRegisterMoreOption(
      {required this.showIcon, required this.selectedAssets});
  @override
  List<Object> get props => [showIcon, selectedAssets];
}

class ExRegisterDownloadLoading extends ExRegisterState {}

class ExRegisterDownloadError extends ExRegisterState {
  final String message;
  ExRegisterDownloadError({required this.message});
  @override
  List<Object> get props => [message];
}

class ExRegisterDownloadSuccess extends ExRegisterState {
  final String message;
  final String location;
  ExRegisterDownloadSuccess({required this.message, required this.location});
  @override
  List<Object> get props => [message, location];
}

class ExRegisterLoaded extends ExRegisterState {
  final List<String> tableHeaders;
  final List<ExRegister> assets;
  final int totalRecords;
  final bool isLoadMore;
  final int? filterIndex;
  final dynamic sortOrder;
  final int skip;
  final bool isPaginatedReplace;
  final bool isDuplicate;
  final List<String> selectedFilters;
  final Map<String, List<String>> collectionSelectedFilter;
  final bool hasMoreData;
  ExRegisterLoaded({
    required this.tableHeaders,
    required this.assets,
    this.totalRecords = 0,
    this.isLoadMore = false,
    this.filterIndex = 0,
    required this.sortOrder,
    required this.skip,
    this.isPaginatedReplace = false,
    required this.isDuplicate,
    this.selectedFilters = const [],
    this.collectionSelectedFilter = const {},
    this.hasMoreData = true,
  });

  @override
  List<Object> get props => [
        tableHeaders,
        assets,
        totalRecords,
        isLoadMore,
        filterIndex ?? -1,
        sortOrder,
        skip
      ];
}

class ExRegisterError extends ExRegisterState {
  final String error;

  ExRegisterError(this.error);

  @override
  List<Object> get props => [error];
}

class ExRegisterSaveError extends ExRegisterState {
  final String error;

  ExRegisterSaveError(this.error);

  @override
  List<Object> get props => [error];
}

class ExRegisterGenerateItrLoading extends ExRegisterState {}

class ExRegisterGenerateItrLoaded extends ExRegisterState {}

class ExRegisterGenerateItrSuccess extends ExRegisterState {
  final String message;
  final String location;
  ExRegisterGenerateItrSuccess({required this.message, required this.location});
  @override
  List<Object> get props => [message, location];
}

class ExRegisterGenerateItrError extends ExRegisterState {
  final String message;
  ExRegisterGenerateItrError({required this.message});
  @override
  List<Object> get props => [message];
}

class HideExRegisterMoreOption extends ExRegisterState {}
