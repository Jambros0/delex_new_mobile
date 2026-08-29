import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:equatable/equatable.dart';

abstract class LocationState extends Equatable {
  @override
  List<Object> get props => [];
}

class LocationLoading extends LocationState {}

class LoadLocation extends LocationState {}

class LocationInitial extends LocationState {}

class LocationsInitial extends LocationState {}

class LocationsLoading extends LocationState {
  final bool isLoadMore;

  LocationsLoading({
    this.isLoadMore = false,
  });

  @override
  List<Object> get props => [
        isLoadMore,
      ];
}

class LocationsLoaded extends LocationState {
  final List<String> tableHeaders;
  final List<Location> locations;
  final int totalRecords;
  final bool isLoadMore;
  final int? filterIndex;
  final int offset;
  final dynamic sortOrder;
  final bool hasMoreData;
  LocationsLoaded(
      {required this.tableHeaders,
      required this.locations,
      this.totalRecords = 0,
      this.isLoadMore = false,
      this.filterIndex,
      required this.offset,
      required this.sortOrder,
      this.hasMoreData = true});

  @override
  List<Object> get props => [
        tableHeaders,
        locations,
        totalRecords,
        isLoadMore,
        filterIndex ?? -1,
        offset
      ];
}

class LocationCreated extends LocationState {
  final Location location;

  LocationCreated(this.location);

  @override
  List<Object> get props => [location];
}

class LocationError extends LocationState {
  final String error;

  LocationError(this.error);

  @override
  List<Object> get props => [error];
}

class LocationDownloadLoading extends LocationState {}

class LocationDownloadError extends LocationState {
  final String message;
  LocationDownloadError({required this.message});
  @override
  List<Object> get props => [message];
}

class LocationDownloadSuccess extends LocationState {
  final String message;
  final String location;
  LocationDownloadSuccess({required this.message, required this.location});
  @override
  List<Object> get props => [message];
}

class LocationFilterResetState extends LocationState {
  final Map<String, List<String>> filters;
  final DateTime timeStamp;
  LocationFilterResetState({required this.filters, required this.timeStamp});
  @override
  List<Object> get props => [filters, timeStamp];
}

class ShowLocationMoreOption extends LocationState {
  final bool showIcon;
  final List<String> selectedAssets;
  ShowLocationMoreOption(
      {required this.showIcon, required this.selectedAssets});
  @override
  List<Object> get props => [showIcon, selectedAssets];
}
