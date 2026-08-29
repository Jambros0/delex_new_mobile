import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/custom_table_grid.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationTable extends StatefulWidget {
  final List<Location> locations;
  final List<String> headers;
  final String searchQuery;
  // final Map<String, String> filters;
  final Map<String, List<String>> filters;
  final int? filterIndex;
  final dynamic sortOrder;
  final Function(int, List<Location>) onRowSelectionCountChanged;
  const LocationTable({
    super.key,
    required this.locations,
    required this.headers,
    required this.searchQuery,
    required this.filters,
    this.filterIndex,
    required this.sortOrder,
    required this.onRowSelectionCountChanged,
  });

  @override
  LocationTableState createState() => LocationTableState();
}

class LocationTableState extends State<LocationTable> {
  late List<Location> _displayedLocations;
  late List<bool> _rowSelection;

  @override
  void initState() {
    super.initState();
    _filterAndSearch();
  }

  @override
  void didUpdateWidget(covariant LocationTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery ||
        widget.locations != oldWidget.locations ||
        widget.filters != oldWidget.filters) {
      _filterAndSearch();
    }
  }

  void _filterAndSearch() {
    final filteredLocations = _applyFilters(widget.locations, widget.filters);
    final searchedLocations = _applySearch(
      filteredLocations,
      widget.searchQuery,
    );
    setState(() {
      _displayedLocations = searchedLocations;
      _rowSelection = List.generate(
        _displayedLocations.length,
        (index) => false,
      );
    });
    _notifyRowSelectionCount();
  }

  void _notifyRowSelectionCount() {
    widget.onRowSelectionCountChanged(
      _rowSelection.length,
      _displayedLocations,
    );
  }

  // void _toggleRowSelection(int index) {
  //   setState(() {
  //     _rowSelection[index] = !_rowSelection[index];
  //     _notifyRowSelectionCount();
  //   });
  // }

  List<Location> _applyFilters(
    List<Location> locations,
    Map<String, List<String>> filters,
  ) {
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
              matches &= filters['Field Name']!.any(
                (element) => element.contains(location.location),
              );
              break;
            case 'Platform':
              matches &= filters['Platform']!.any(
                (element) => element.contains(location.area),
              );
              break;
            case 'Deck Level':
              if (location.deckLevel != null) {
                matches &= filters['Deck Level']!.any(
                  (element) => element.contains(location.deckLevel ?? ''),
                );
              }
              break;
            case 'Location':
              matches &= filters['Location']!.any(
                (element) => element.contains(location.location),
              );
              break;
            case 'SubLocation':
              matches &= filters['SubLocation']!.any(
                (element) => element.contains(location.area),
              );
              break;
            case 'Area':
              if (location.deckLevel != null) {
                matches &= filters['Area']!.any(
                  (element) => element.contains(location.deckLevel ?? ''),
                );
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
          (location.locationGasGroup.any(
            (group) => group.toLowerCase().contains(lowerQuery),
          )) ||
          (location.locationTClass.any(
            (group) => group.toLowerCase().contains(lowerQuery),
          )) ||
          (location.locationIpRating.any(
            (group) => group.toLowerCase().contains(lowerQuery),
          )) ||
          (location.areaClassDrawAttachOrgName.any(
            (group) => group.toLowerCase().contains(lowerQuery),
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _displayedLocations.map((location) {
      return [
        location.location,
        location.area,
        location.deckLevel ?? '',
        location.zone ?? '',
        location.locationGasGroup.join(', '),
        location.locationTClass.join(', '),
        location.areaClassDrawAttachOrgName.join('\n'),
      ];
    }).toList();

    final columnKeys = [
      'location',
      'area',
      'deckLevel',
      'zone',
      'locationGasGroup',
      'locationTClass',
      'areaClassDrawAttachOrgName',
    ];

    return CustomTableGrid(
      filterIndex: widget.filterIndex,
      headers: widget.headers
          .where((header) => header != 'Sub Area (Nearest Landmark)' && header != 'IP Rating')
          .toList(),
      rows: rows,
      columnKeys: columnKeys,
      sortOrder: widget.sortOrder,
      initialSelection: _rowSelection,
      tableType: 'Area Detail',
      locations: _displayedLocations,
      onRowSelected: (index) {
        setState(() {
          _rowSelection[index] = !_rowSelection[index];
        });
      },
      onSortChanged:
          (
            sortField,
            sortOrder,
            columnIndex,
            selectedFilters,
            collectionSelectedFilter,
          ) {
            context.read<LocationBloc>().add(
              SortLocations(
                sortField: sortField,
                sortOrder: sortOrder,
                columnIndex: columnIndex,
                filters: widget.filters,
                locations: widget.locations,
              ),
            );
          },
      datetype: '',
      searchQuery: widget.searchQuery,
      showFilterType: '',
      selectedFilters: const [],
      alreadycollectionSelectedFilter: const {},
    );
  }
}
