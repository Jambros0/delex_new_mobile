import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_function.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_states.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/services/location_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../utils/excel_functions.dart';
import '../../../utils/pdf_functions.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final DBHelper _dbHelper = DBHelper();

  final LocationService locationService;
  final AuthUtils authUtils;

  int skip = 0;
  int offset = 0;
  bool hasMoreData = true;
  final int limit = 10;
  final int loadMoreLimit = 10;
  String sortField = 'updatedAt';
  String sortOrder = 'descending';
  int? filterIndex;

  LocationBloc({required this.locationService, required this.authUtils})
      : super(LocationInitial()) {
    on<LoadLocations>(loadLocations);
    on<LocationsInitEvent>(locationsInitEvent);
    on<LoadMoreLocations>(loadMoreLocations);
    on<LocationFilterEvent>(locationFilter);
    on<LocationDownload>(locationDownload);
    on<SortLocations>(sortLocations);
    on<LocationFilterResetEvent>(locationFilterResetEvent);
    on<LocationRowSelected>(locationRowSelected);
    on<LocationMultipleDeletedList>(locationMultipleDeletedList);
  }
  FutureOr<void> locationsInitEvent(
      LocationsInitEvent event, Emitter<LocationState> emit) async {
    skip = 0;
    offset = 0;
    sortField = 'updatedAt';
    sortOrder = 'descending';
    filterIndex = null;
    emit(LocationsInitial());
  }

  FutureOr<void> locationFilter(
      LocationFilterEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await locationFilterFromApi(event, emit);
      } else {
        await locationFilterFromOffline(event, emit);
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> locationFilterFromApi(
      LocationFilterEvent event, Emitter<LocationState> emit) async {
    try {
      final String? userType = await authUtils.getUserType();
      final totalRecords = await _fetchTotalRecords();
      offset = max(0, totalRecords - limit);
      final response = await locationService.fetchLocations(
        limit: limit,
        offset: offset,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      List<String> tableHeaders = (userType == 'onshore')
          ? [
              "Location",
              "Sub Location",
              "Area",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ]
          : response['tableHeaders'] as List<String>;

      final List<Location> locations = response['locations'] as List<Location>;
      final int fetchedTotalRecords = response['totalRecords'] as int;

      emit(LocationsLoaded(
        tableHeaders: tableHeaders,
        locations: locations,
        totalRecords: fetchedTotalRecords,
        offset: offset,
        filterIndex: filterIndex,
        sortOrder: sortOrder,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> locationFilterFromOffline(
      LocationFilterEvent event, Emitter<LocationState> emit) async {
    try {
      skip = skip;

      final String? userType = await authUtils.getUserType();
      List<Map<String, dynamic>> results = (userType == 'onshore')
          ? await _dbHelper.getFunctionalAreaDataOnshore()
          : await _dbHelper.getFunctionalAreaData();
      List<Location> locations = results.map((e) {
        dynamic functionalAreaJson = e['functional_area_json'];
        Map<String, dynamic> jsonMap;

        if (functionalAreaJson is String) {
          try {
            jsonMap = jsonDecode(functionalAreaJson);
          } catch (decodeError) {
            throw FormatException(
                "Invalid JSON string in functional_area_json: $functionalAreaJson");
          }
        } else if (functionalAreaJson is Map<String, dynamic>) {
          jsonMap = functionalAreaJson;
        } else {
          throw FormatException(
              "Invalid type for functional_area_json: ${functionalAreaJson.runtimeType}");
        }

        return Location.fromJson(jsonMap['location']);
      }).toList();
      List<Location> filteredLocations =
          _applyFilters(locations, event.filterList);
      List<String> tableHeaders = (userType == 'onshore')
          ? [
              "Location",
              "Sub Location",
              "Area",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ]
          : [
              "Field Name",
              "Platform",
              "Deck Level",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ];

      emit(LocationsLoaded(
        tableHeaders: tableHeaders,
        locations: filteredLocations,
        totalRecords: filteredLocations.length,
        offset: offset,
        filterIndex: filterIndex,
        sortOrder: sortOrder,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> loadLocations(
      LoadLocations event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await loadLocationsFromApi(event, emit);
      } else {
        await loadLocationsFromOffline(event, emit);
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> loadLocationsFromApi(
      LoadLocations event, Emitter<LocationState> emit) async {
    try {
      final String? userType = await authUtils.getUserType();
      final totalRecords = await _fetchTotalRecords();
      offset = max(0, totalRecords - limit);
      final response = await locationService.fetchLocations(
        limit: limit,
        offset: offset,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      List<String> tableHeaders = (userType == 'onshore')
          ? [
              "Location",
              "Sub Location",
              "Area",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ]
          : response['tableHeaders'] as List<String>;

      final List<Location> locations = response['locations'] as List<Location>;
      final int fetchedTotalRecords = response['totalRecords'] as int;

      emit(LocationsLoaded(
        tableHeaders: tableHeaders,
        locations: locations,
        totalRecords: fetchedTotalRecords,
        offset: offset,
        filterIndex: filterIndex,
        sortOrder: sortOrder,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> loadLocationsFromOffline(
      LoadLocations event, Emitter<LocationState> emit) async {
    try {
      skip = 0;

      final String? userType = await authUtils.getUserType();
      List<Map<String, dynamic>> results = (userType == 'onshore')
          ? await _dbHelper.getFunctionalAreaByOffsetOnshore(skip, limit)
          : await _dbHelper.getFunctionalAreaByOffset(skip, limit);

      List<Location> locations = results.map((e) {
        dynamic functionalAreaJson = e['functional_area_json'];
        Map<String, dynamic> jsonMap;

        if (functionalAreaJson is String) {
          try {
            jsonMap = jsonDecode(functionalAreaJson);
          } catch (decodeError) {
            throw FormatException(
                "Invalid JSON string in functional_area_json: $functionalAreaJson");
          }
        } else if (functionalAreaJson is Map<String, dynamic>) {
          jsonMap = functionalAreaJson;
        } else {
          throw FormatException(
              "Invalid type for functional_area_json: ${functionalAreaJson.runtimeType}");
        }

        return Location.fromJson(jsonMap['location']);
      }).toList();
      List<String> tableHeaders = (userType == 'onshore')
          ? [
              "Location",
              "Sub Location",
              "Area",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ]
          : [
              "Field Name",
              "Platform",
              "Deck Level",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ];

      emit(LocationsLoaded(
        tableHeaders: tableHeaders,
        locations: locations,
        totalRecords: locations.length,
        offset: limit,
        filterIndex: filterIndex,
        sortOrder: sortOrder,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> loadMoreLocations(
      LoadMoreLocations event, Emitter<LocationState> emit) async {
    // emit(LocationLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await loadMoreLocationsFromApi(event, emit);
      } else {
        await loadMoreLocationsFromOffline(event, emit);
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> loadMoreLocationsFromApi(
      LoadMoreLocations event, Emitter<LocationState> emit) async {
    try {
      final String? userType = await authUtils.getUserType();
      final newOffset = max(0, offset - limit);
      offset = newOffset;
      final response = await locationService.fetchLocations(
        limit: limit,
        offset: newOffset,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      final List<String> tableHeaders = (userType == 'onshore')
          ? [
              "Location",
              "Sub Location",
              "Area",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ]
          : response['tableHeaders'] as List<String>;

      final List<Location> locations = response['locations'] as List<Location>;
      final int fetchedTotalRecords = response['totalRecords'] as int;

      emit(LocationsLoaded(
        tableHeaders: tableHeaders,
        locations: event.locations + locations,
        totalRecords: fetchedTotalRecords,
        offset: newOffset,
        filterIndex: filterIndex,
        sortOrder: sortOrder,
        isLoadMore: false,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> loadMoreLocationsFromOffline(
      LoadMoreLocations event, Emitter<LocationState> emit) async {
    try {
      // skip = event.locations.length;
      emit(LocationsLoading(
        isLoadMore: true,
      ));
      final String? userType = await authUtils.getUserType();
      offset = event.locations.length;

      List<Map<String, dynamic>> results = [];
      if (event.filterList.isEmpty) {
        results = (userType == 'onshore')
            ? await _dbHelper.getFunctionalAreaByOffsetOnshore(
                offset, loadMoreLimit)
            : await _dbHelper.getFunctionalAreaByOffset(offset, loadMoreLimit);
      } else {
        results = (userType == 'onshore')
            ? await _dbHelper.getFunctionalAreaDataOnshore()
            : await _dbHelper.getFunctionalAreaData();
      }

      if (results.isEmpty) {
        hasMoreData = false;
        emit(LocationsLoaded(
          tableHeaders: event.tableHeaders,
          locations: event.locations,
          totalRecords: event.totalRecords,
          offset: offset,
          filterIndex: filterIndex,
          sortOrder: sortOrder,
          isLoadMore: false,
          hasMoreData: hasMoreData,
        ));
        return;
      }
      await Future.delayed(const Duration(seconds: 2));

      List<Location> newLocations = results.map((e) {
        dynamic functionalAreaJson = e['functional_area_json'];
        Map<String, dynamic> jsonMap;
        if (functionalAreaJson is String) {
          try {
            jsonMap = jsonDecode(functionalAreaJson);
          } catch (decodeError) {
            throw FormatException(
                "Invalid JSON string in functional_area_json: $functionalAreaJson");
          }
        } else if (functionalAreaJson is Map<String, dynamic>) {
          jsonMap = functionalAreaJson;
        } else {
          throw FormatException(
              "Invalid type for functional_area_json: ${functionalAreaJson.runtimeType}");
        }
        return Location.fromJson(jsonMap['location']);
      }).toList();
      List<Location> filteredLocations =
          _applyFilters(newLocations, event.filterList);
      List<Location> updatedLocations = [];
      if (event.filterList.isEmpty) {
        updatedLocations = event.locations + newLocations;
        offset += updatedLocations.length;
      } else {
        offset = filteredLocations.length;
        updatedLocations = filteredLocations;
      }
      emit(LocationsLoaded(
        tableHeaders: event.tableHeaders,
        locations: updatedLocations,
        totalRecords: updatedLocations.length,
        offset: offset,
        filterIndex: filterIndex,
        sortOrder: sortOrder,
        isLoadMore: false,
      ));
      // skip += limit;
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> sortLocations(
      SortLocations event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await sortLocationsFromApi(event, emit);
      } else {
        await sortLocationsFromOffline(event, emit);
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> sortLocationsFromApi(
      SortLocations event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      final String? userType = await authUtils.getUserType();
      sortOrder = event.sortOrder;
      sortField = event.sortField;
      event.sortOrder == "descending"
          ? filterIndex = event.columnIndex
          : filterIndex = null;
      final totalRecords = await _fetchTotalRecords();
      offset = max(0, totalRecords - limit);

      final response = await locationService.fetchLocations(
        limit: limit,
        offset: offset,
        sortField: sortField,
        sortOrder: sortOrder,
      );

      final List<String> tableHeaders = (userType == 'onshore')
          ? [
              "Location",
              "Sub Location",
              "Area",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ]
          : response['tableHeaders'] as List<String>;

      final List<Location> locations = response['locations'] as List<Location>;
      final int fetchedTotalRecords = response['totalRecords'] as int;

      emit(LocationsLoaded(
        tableHeaders: tableHeaders,
        locations: locations,
        totalRecords: fetchedTotalRecords,
        offset: offset,
        filterIndex: event.columnIndex,
        sortOrder: sortOrder,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> sortLocationsFromOffline(
      SortLocations event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      sortOrder = event.sortOrder;
      sortField = event.sortField;
      final String? userType = await authUtils.getUserType();

      List<Map<String, dynamic>> results = (userType == 'onshore')
          ? await _dbHelper.getFunctionalAreaDataOnshore()
          : await _dbHelper.getFunctionalAreaData();

      List<Location> resultLocations = event.locations.isNotEmpty
          ? event.locations
          : results.map((map) {
              final locationJson = map['functional_area_json'];
              final jsonMap = (locationJson is String)
                  ? jsonDecode(locationJson)
                  : locationJson as Map<String, dynamic>?;
              if (jsonMap == null) {
                throw FormatException(
                    "Invalid type for exregister_json: ${locationJson.runtimeType}");
              }

              return Location.fromJson(jsonMap['location']);
            }).toList();
      List<Location> filteredLocations =
          _applyFilters(resultLocations, event.filters);

      filteredLocations = sortOrder.isNotEmpty
          ? (() => LocationFunction.sortList(
              filteredList: filteredLocations,
              columnIndex: event.columnIndex,
              sortOrder: sortOrder))()
          : filteredLocations;

      List<String> tableHeaders = (userType == 'onshore')
          ? [
              "Location",
              "Sub Location",
              "Area",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ]
          : [
              "Field Name",
              "Platform",
              "Deck Level",
              "Sub Area (Nearest Landmark)",
              "Zone",
              "Gas Group",
              "Temperature Class",
              "Area Classification Drawing No:",
            ];
      emit(LocationsLoaded(
          tableHeaders: tableHeaders,
          locations: filteredLocations,
          totalRecords: filteredLocations.length,
          filterIndex: event.columnIndex,
          offset: 0,
          sortOrder: sortOrder));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> locationDownload(
      LocationDownload event, Emitter<LocationState> emit) async {
    emit(LocationDownloadLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await locationDownloadFromApi(event, emit);
      } else {
        await locationDownloadFromOffline(event, emit);
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> locationDownloadFromApi(
      LocationDownload event, Emitter<LocationState> emit) async {
    emit(LocationDownloadLoading());
    try {
      ExcelFunctions excelFunctions = ExcelFunctions();
      PdfGenerator pdfFunctions = PdfGenerator();
      List<Location> locations = [];
      if (event.locationIds.isNotEmpty) {
        for (String assetId in event.locationIds) {
          final response = await locationService.fetchLocationByIdDownload(
              locationId: assetId);

          locations.add(response);
        }
      } else {
        final response = await locationService.fetchLocations(limit: 10);
        locations = response['locations'] as List<Location>;
      }
      Map<String, dynamic> downloadResponse = {};
      event.fileType == "excel"
          ? downloadResponse =
              await excelFunctions.downloadLocationExcel(locations)
          : downloadResponse =
              await pdfFunctions.downloadLocationPdf(locations);
      emit(LocationDownloadSuccess(
          message: 'File Downloaded to ${downloadResponse['location']}',
          location: downloadResponse['location']));
    } catch (e) {
      emit(LocationDownloadError(
          message: 'Getting some error while download a File!!'));
    }
  }

  FutureOr<void> locationDownloadFromOffline(
      LocationDownload event, Emitter<LocationState> emit) async {
    emit(LocationDownloadLoading());
    try {
      ExcelFunctions excelFunctions = ExcelFunctions();
      PdfGenerator pdfFunctions = PdfGenerator();
      List<Location> locations = [];
      final String? userType = await authUtils.getUserType();

      if (event.locationIds.isNotEmpty) {
        for (String assetId in event.locationIds) {
          final functionalAreaData = (userType == 'onshore')
              ? await _dbHelper.getFunctionalAreaByIdOnshore(assetId)
              : await _dbHelper.getFunctionalAreaById(assetId);
          if (functionalAreaData != null) {
            final functionalAreaJson =
                jsonDecode(functionalAreaData['functional_area_json']);
            if (functionalAreaJson.containsKey('location')) {
              final dynamic locationData = functionalAreaJson['location'];
              if (locationData is List) {
                for (var locationJson in locationData) {
                  Location location = Location.fromJson(locationJson);
                  locations.add(location);
                }
              } else if (locationData is Map<String, dynamic>) {
                Location location = Location.fromJson(locationData);
                locations.add(location);
              }
            }
          }
        }
      } else {
        // final functionalAreaList = (userType == 'onshore')
        //     ? await _dbHelper.getFunctionalAreaDataOnshore()
        //     : await _dbHelper.getFunctionalAreaData();
        // final functionalAreaList = (userType == 'onshore')
        //     ? await _dbHelper.getFunctionalAreaByOffsetOnshore(0, 30)
        //     : await _dbHelper.getFunctionalAreaByOffset(0, 30);
        List<Location> filteredLocations = [];
        filteredLocations = _applyFilters(event.locations, event.filters);
        if (event.searchQuery.isNotEmpty) {
          filteredLocations =
              _applySearch(filteredLocations, event.searchQuery);
        }
        // for (var data in functionalAreaList) {
        //   final functionalAreaJson = jsonDecode(data['functional_area_json']);
        //   if (functionalAreaJson.containsKey('location')) {
        //     final dynamic locationData = functionalAreaJson['location'];
        //     if (locationData is List) {
        //       for (var locationJson in locationData) {
        //         Location location = Location.fromJson(locationJson);
        //         locations.add(location);
        //       }
        //     } else if (locationData is Map<String, dynamic>) {
        //       Location location = Location.fromJson(locationData);
        //       locations.add(location);
        //     }
        //   }
        // }
        locations = filteredLocations;
      }

      Map<String, dynamic> downloadResponse = {};

      if (event.fileType == "excel") {
        downloadResponse =
            await excelFunctions.downloadLocationExcel(locations);
      } else {
        downloadResponse = await pdfFunctions.downloadLocationPdf(locations);
      }

      emit(LocationDownloadSuccess(
        message: 'File Downloaded to ${downloadResponse['location']}',
        location: downloadResponse['location'],
      ));
    } catch (e) {
      emit(LocationDownloadError(
        message: 'Getting some error while downloading a file: ${e.toString()}',
      ));
    }
  }

  List<Location> _applyFilters(
      List<Location> locations, Map<String, List<String>> filters) {
    if (filters.isEmpty) return locations;
    return locations.where((location) {
      if ((location.location).isEmpty ||
          (location.area).isEmpty ||
          (location.deckLevel!).isEmpty) {
        return false;
      }
      bool matches = true;
      filters.forEach((key, value) {
        if (value.isNotEmpty) {
          switch (key) {
            case 'Field Name':
              matches &= filters['Field Name']!
                  .any((element) => element.contains(location.location));
              break;
            case 'Platform':
              matches &= filters['Platform']!
                  .any((element) => element.contains(location.area));
              break;
            case 'Deck Level':
              if (location.deckLevel != null) {
                matches &= filters['Deck Level']!.any(
                    (element) => element.contains(location.deckLevel ?? ''));
              }
              break;
            case 'Location':
              matches &= filters['Location']!
                  .any((element) => element.contains(location.location));
              break;
            case 'SubLocation':
              matches &= filters['SubLocation']!
                  .any((element) => element.contains(location.area));
              break;
            case 'Area':
              if (location.deckLevel != null) {
                matches &= filters['Area']!.any(
                    (element) => element.contains(location.deckLevel ?? ''));
              }
              break;
            default:
              break;
          }
        }
      });
      return matches;
    }).toList();
  }

  List<Location> _applySearch(List<Location> locations, String query) {
    if (query.isEmpty) return locations;

    final lowerQuery = query.toLowerCase();
    return locations.where((location) {
      return location.location.toLowerCase().contains(lowerQuery) ||
          location.area.toLowerCase().contains(lowerQuery) ||
          (location.deckLevel?.toLowerCase().contains(lowerQuery) ?? false) ||
          (location.zone?.toLowerCase().contains(lowerQuery) ?? false) ||
          (location.locationGasGroup
              .any((group) => group.toLowerCase().contains(lowerQuery))) ||
          (location.locationTClass
              .any((group) => group.toLowerCase().contains(lowerQuery))) ||
          (location.locationIpRating
              .any((group) => group.toLowerCase().contains(lowerQuery))) ||
          (location.areaClassDrawAttachOrgName
              .any((group) => group.toLowerCase().contains(lowerQuery)));
    }).toList();
  }

  Future<int> _fetchTotalRecords() async {
    try {
      final response = await locationService.fetchLocations(
        limit: 1,
        offset: 0,
        sortField: sortField,
        sortOrder: sortOrder,
      );
      return response['totalRecords'] as int;
    } catch (e) {
      return 0;
    }
  }

  FutureOr<void> locationFilterResetEvent(
      LocationFilterResetEvent event, Emitter<LocationState> emit) async {
    emit(LocationFilterResetState(
        filters: event.filters, timeStamp: DateTime.now()));
  }

  FutureOr<void> locationRowSelected(
      LocationRowSelected event, Emitter<LocationState> emit) async {
    emit(LoadLocation());
    bool showIcon = true;
    emit(ShowLocationMoreOption(
        showIcon: showIcon, selectedAssets: event.selectedAssets));
  }

  FutureOr<void> locationMultipleDeletedList(
      LocationMultipleDeletedList event, Emitter<LocationState> emit) async {
    // emit(ExRegisterLoading());
    try {
      bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (isApiFlag) {
        await locationMultipleDeletedListApi(event, emit);
      } else {
        await locationMultipleDeletedListOffline(event, emit);
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> locationMultipleDeletedListApi(
      LocationMultipleDeletedList event, Emitter<LocationState> emit) async {
    emit(LocationsLoading(
      isLoadMore: true,
    ));
    try {} catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  FutureOr<void> locationMultipleDeletedListOffline(
      LocationMultipleDeletedList event, Emitter<LocationState> emit) async {
    emit(LocationsLoading(
      isLoadMore: true,
    ));
    try {
      final String? userType = await authUtils.getUserType();
      (userType == 'onshore')
          ? await _dbHelper.deleteFunctionalAreaIdOnshore(event.selectedLists)
          : await _dbHelper.deleteFunctionalAreaId(event.selectedLists);
      add(LoadLocations());
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
