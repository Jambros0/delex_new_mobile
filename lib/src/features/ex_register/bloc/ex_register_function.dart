import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

class ExRegisterFunction {
  static List<ExRegister> sortList({
    required List<ExRegister> filteredList,
    required int columnIndex,
    required String sortOrder,
  }) {
    final normalizedSortOrder =
        sortOrder.toLowerCase() == "descending" ? "DESC" : "ASC";

    if (columnIndex == 0) {
      // filteredList =
      //     filteredList.where((filter) => filter.rfidRef.isNotEmpty).toList();
      filteredList.sort((a, b) {
        bool isAEmpty = a.rfidRef.isEmpty;
        bool isBEmpty = b.rfidRef.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.rfidRef.compareTo(b.rfidRef);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 1) {
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
    } else if (columnIndex == 2) {
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
    } else if (columnIndex == 3) {
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
    } else if (columnIndex == 4) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.zone.isEmpty;
        bool isBEmpty = b.zone.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.zone.compareTo(b.zone);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 5) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.eqpmtCatg.isEmpty;
        bool isBEmpty = b.eqpmtCatg.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.eqpmtCatg.compareTo(b.eqpmtCatg);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 6) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.eqpmtTag == null || a.eqpmtTag!.isEmpty;
        bool isBEmpty = b.eqpmtTag == null || b.eqpmtTag!.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.eqpmtTag!.compareTo(b.eqpmtTag!);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 7) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.description.isEmpty;
        bool isBEmpty = b.description.isEmpty;

        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.description.compareTo(b.description);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 8) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.manufacturer.isEmpty;
        bool isBEmpty = b.manufacturer.isEmpty;
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison = a.manufacturer.compareTo(b.manufacturer);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 9) {
      filteredList.sort((a, b) {
        final strA = _formatEquipmentProtection(a);
        final strB = _formatEquipmentProtection(b);
        bool isAEmpty = strA.isEmpty;
        bool isBEmpty = strB.isEmpty;

        if (isAEmpty && isBEmpty) return 0;
        if (isAEmpty) return normalizedSortOrder == "ASC" ? -1 : 1;
        if (isBEmpty) return normalizedSortOrder == "ASC" ? 1 : -1;

        final comparison = strA.compareTo(strB);
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 10) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.faultyItems == null || a.faultyItems == "";
        bool isBEmpty = b.faultyItems == null || b.faultyItems == "";
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison =
            a.faultyItems.toString().compareTo(b.faultyItems.toString());
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 12) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.repairsDone == null || a.repairsDone == "";
        bool isBEmpty = b.repairsDone == null || b.repairsDone == "";
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison =
            a.repairsDone.toString().compareTo(b.repairsDone.toString());
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    } else if (columnIndex == 13) {
      filteredList.sort((a, b) {
        bool isAEmpty = a.existingFaults == null || a.existingFaults == "";
        bool isBEmpty = b.existingFaults == null || b.existingFaults == "";
        if (isAEmpty && isBEmpty) {
          return 0;
        }
        if (isAEmpty) {
          return normalizedSortOrder == "ASC" ? -1 : 1;
        }
        if (isBEmpty) {
          return normalizedSortOrder == "ASC" ? 1 : -1;
        }
        final comparison =
            a.existingFaults.toString().compareTo(b.existingFaults.toString());
        return normalizedSortOrder == "DESC" ? -comparison : comparison;
      });
    }

    return filteredList;
  }

  static String _formatEquipmentProtection(ExRegister asset) {
    List<String> parts = [];
    String getCleanString(List<String>? items) {
      if (items == null || items.isEmpty) return '';
      final filtered = items.where((e) {
        final val = e.trim().toLowerCase();
        return val.isNotEmpty &&
            val != 'not available' &&
            val != 'n/a' &&
            val != 'na' &&
            val != 'null';
      }).toList();
      return filtered.join(', ');
    }

    final protType = getCleanString(asset.protectionType);
    final gasGroup = getCleanString(asset.equipmentGasGroup);
    final tempClass = getCleanString(asset.equipmentTClass);

    if (protType.isNotEmpty) parts.add(protType);
    if (gasGroup.isNotEmpty) parts.add(gasGroup);
    if (tempClass.isNotEmpty) parts.add(tempClass);

    return parts.join(' ');
  }
}
