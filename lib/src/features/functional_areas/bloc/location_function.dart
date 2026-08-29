import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';

class LocationFunction {
  static List<Location> sortList({
    required List<Location> filteredList,
    required int columnIndex,
    required String sortOrder,
  }) {
    final normalizedSortOrder =
        sortOrder.toLowerCase() == "descending" ? "DESC" : "ASC";
    if (columnIndex == 0) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.location.isEmpty;
        bool isBEmpty = b.location.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.location.compareTo(b.location);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 1) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.area.isEmpty;
        bool isBEmpty = b.area.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.area.compareTo(b.area);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 2) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.deckLevel == null || a.deckLevel!.isEmpty;
        bool isBEmpty = b.deckLevel == null || b.deckLevel!.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.deckLevel!.compareTo(b.deckLevel!);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 3) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.zone == null || a.zone!.isEmpty;
        bool isBEmpty = b.zone == null || b.zone!.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.zone!.compareTo(b.zone!);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 4) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.locationGasGroup.isEmpty;
        bool isBEmpty = b.locationGasGroup.isEmpty;

        if (isAEmpty && isBEmpty) return 0;
        if (isAEmpty) return normalizedSortOrder == "ASC" ? -1 : 1;
        if (isBEmpty) return normalizedSortOrder == "ASC" ? 1 : -1;

        // Get the smallest item in each list
        final minA = a.locationGasGroup
            .reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next);
        final minB = b.locationGasGroup
            .reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next);

        final comparison = minA.compareTo(minB);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 5) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.locationTClass.isEmpty;
        bool isBEmpty = b.locationTClass.isEmpty;

        if (isAEmpty && isBEmpty) return 0;
        if (isAEmpty) return normalizedSortOrder == "ASC" ? -1 : 1;
        if (isBEmpty) return normalizedSortOrder == "ASC" ? 1 : -1;

        // Get the smallest item in each list
        final minA = a.locationTClass
            .reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next);
        final minB = b.locationTClass
            .reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next);

        final comparison = minA.compareTo(minB);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 6) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.locationIpRating.isEmpty;
        bool isBEmpty = b.locationIpRating.isEmpty;

        if (isAEmpty && isBEmpty) return 0;
        if (isAEmpty) return normalizedSortOrder == "ASC" ? -1 : 1;
        if (isBEmpty) return normalizedSortOrder == "ASC" ? 1 : -1;

        // Get the smallest item in each list
        final minA = a.locationIpRating
            .reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next);
        final minB = b.locationIpRating
            .reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next);

        final comparison = minA.compareTo(minB);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 7) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.areaClassDrawAttachOrgName.isEmpty;
        bool isBEmpty = b.areaClassDrawAttachOrgName.isEmpty;

        if (isAEmpty && isBEmpty) return 0;
        if (isAEmpty) return normalizedSortOrder == "ASC" ? -1 : 1;
        if (isBEmpty) return normalizedSortOrder == "ASC" ? 1 : -1;

        // Get the smallest item in each list
        final minA = a.areaClassDrawAttachOrgName
            .reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next);
        final minB = b.areaClassDrawAttachOrgName
            .reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next);

        final comparison = minA.compareTo(minB);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    }

    return filteredList;
  }
}
