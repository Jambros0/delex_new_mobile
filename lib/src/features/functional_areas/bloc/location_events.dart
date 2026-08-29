import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadLocations extends LocationEvent {}

class LocationsInitEvent extends LocationEvent {}

class LoadMoreLocations extends LocationEvent {
  final List<String> tableHeaders;
  final List<Location> locations;
  final int totalRecords;
  final bool isLoadMore;
  final int? filterIndex;
  final int offset;
  final Map<String, List<String>> filterList;
  final Map<String, String> filters;
  LoadMoreLocations(
      {required this.tableHeaders,
      this.filterIndex,
      required this.locations,
      required this.totalRecords,
      required this.isLoadMore,
      required this.offset,
      required this.filterList,
      required this.filters});
  @override
  List<Object> get props =>
      [tableHeaders, locations, totalRecords, isLoadMore, offset];
}

class CreateLocation extends LocationEvent {
  final Location location;

  CreateLocation(this.location);

  @override
  List<Object> get props => [location];
}

class SortLocations extends LocationEvent {
  final String sortField;
  final String sortOrder;
  final int columnIndex;
  final Map<String, List<String>> filters;
  final List<Location> locations;
  SortLocations(
      {required this.sortField,
      required this.sortOrder,
      required this.columnIndex,
      required this.filters,
      required this.locations});
  @override
  List<Object> get props => [sortField, sortOrder, columnIndex];
}

class LocationRowSelected extends LocationEvent {
  final bool showIcon;
  final List<String> selectedAssets;
  LocationRowSelected({required this.showIcon, required this.selectedAssets});
  @override
  List<Object> get props => [showIcon, selectedAssets];
}

class LocationDownload extends LocationEvent {
  final String fileType;
  final List<Location> locations;
  final List<String> locationIds;
  final String searchQuery;
  final Map<String, List<String>> filters;
  LocationDownload(
      {required this.fileType,
      required this.locations,
      required this.locationIds,
      required this.searchQuery,
      required this.filters});
  @override
  List<Object> get props => [fileType, locations, locationIds];
}

class LocationMultipleDeletedList extends LocationEvent {
  final String locationId;
  final String type;
  final Map<String, List<String>> filterList;
  final Map<String, String> filters;
  final List<Location> locations;
  final List<String> selectedLists;
  LocationMultipleDeletedList({
    required this.locationId,
    required this.type,
    required this.filterList,
    required this.filters,
    required this.locations,
    required this.selectedLists,
  });
  @override
  List<Object> get props => [
        locationId,
        type,
        filterList,
        filters,
        locations,
        selectedLists,
      ];
}

class LocationFilterInitEvent extends LocationEvent {
  final Map<String, List<String>> filters;
  LocationFilterInitEvent({required this.filters});
  @override
  List<Object> get props => [filters];
}

class LocationFilterResetEvent extends LocationEvent {
  final Map<String, List<String>> filters;
  final List<Location> locations;
  LocationFilterResetEvent({required this.filters, required this.locations});
  @override
  List<Object> get props => [filters];
}

class LocationFilterEvent extends LocationEvent {
  final Map<String, List<String>> filterList;
  LocationFilterEvent({required this.filterList});
  @override
  List<Object> get props => [filterList];
}
