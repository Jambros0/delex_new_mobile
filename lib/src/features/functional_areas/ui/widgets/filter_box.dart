import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../ex_inspections/data/repository/dropdown_repo.dart';
import '../../bloc/location_bloc.dart';
import '../../bloc/location_events.dart';
import '../../bloc/location_states.dart';
import '../../data/models/location_model.dart';

class FilterBox extends StatefulWidget {
  final Function(Map<String, List<String>>) onFilterApply;
  final List<Location> locations; // Add this line

  const FilterBox({
    super.key,
    required this.onFilterApply,
    required this.locations, // Add this line
  });

  @override
  FilterBoxState createState() => FilterBoxState();
}

class FilterBoxState extends State<FilterBox> {
  final TextEditingController _fieldNameController = TextEditingController();
  final TextEditingController _platformController = TextEditingController();
  final TextEditingController _deckLevelController = TextEditingController();
  String? fieldName;
  String? platForm;
  String? deckLevel;
  late List<String> _fieldNameSuggestions;
  late List<String> _platformSuggestions;
  late List<String> _deckLevelSuggestions;
  List<String> selectedFields = [];
  List<String> selectedPlatForms = [];
  List<String> selectedDeckLevels = [];
  String? _userType;

  int _selectedFilterCount = 0;
  bool isDropdownOpen = false;
  void toggleDropdownState() {
    setState(() {
      isDropdownOpen = !isDropdownOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _fieldNameSuggestions = [];
    _platformSuggestions = [];
    _deckLevelSuggestions = [];
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final userType = await AuthUtils().getUserType();
    Set<String> fieldNameSet = {};
    Set<String> platformSet = {};
    Set<String> deckLevelSet = {};

    for (var loc in widget.locations) {
      if (loc.location.isNotEmpty) fieldNameSet.add(loc.location);
      if (loc.area.isNotEmpty) platformSet.add(loc.area);
      if (loc.deckLevel != null && loc.deckLevel!.isNotEmpty) {
        deckLevelSet.add(loc.deckLevel!);
      }
    }

    try {
      final dropdownRepo = DropdownRepository();
      final dropDownData = await dropdownRepo.getLocalDropDownData();
      if (dropDownData != null && dropDownData['result'] != null) {
        final locationDropDownMap = dropDownData['result']['locationDropDown'];
        if (locationDropDownMap is List && locationDropDownMap.isNotEmpty) {
          final firstMap = locationDropDownMap[0] as Map<String, dynamic>;

          if (firstMap['locationDropDown'] is List) {
            for (var item in firstMap['locationDropDown']) {
              if (item is Map && item['name'] != null && item['name'].toString().trim().isNotEmpty) {
                fieldNameSet.add(item['name'].toString().trim());
              } else if (item is String && item.trim().isNotEmpty) {
                fieldNameSet.add(item.trim());
              }
            }
          }

          if (firstMap['subArea'] is List) {
            for (var item in firstMap['subArea']) {
              if (item is Map && item['name'] != null && item['name'].toString().trim().isNotEmpty) {
                platformSet.add(item['name'].toString().trim());
              } else if (item is String && item.trim().isNotEmpty) {
                platformSet.add(item.trim());
              }
            }
          }

          if (firstMap['deckLevel'] is List) {
            for (var item in firstMap['deckLevel']) {
              if (item is Map && item['name'] != null && item['name'].toString().trim().isNotEmpty) {
                deckLevelSet.add(item['name'].toString().trim());
              } else if (item is String && item.trim().isNotEmpty) {
                deckLevelSet.add(item.trim());
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching dropdown data in FilterBox: $e');
    }

    if (mounted) {
      setState(() {
        _userType = userType;
        _fieldNameSuggestions = fieldNameSet.toList()..sort();
        _platformSuggestions = platformSet.toList()..sort();
        _deckLevelSuggestions = deckLevelSet.toList()..sort();
      });
    }
  }

  List<String> _getUniqueFieldValues(String fieldName) {
    return [];
  }

  void _applyFilter(String type) {
    final selectedFilters = {
      _userType == 'onshore' ? 'Location' : 'Field Name': selectedFields,
      _userType == 'onshore' ? 'SubLocation' : 'Platform': selectedPlatForms,
      _userType == 'onshore' ? 'Area' : 'Deck Level': selectedDeckLevels,
    };

    int valueCount = 0;
    selectedFilters.forEach((key, value) {
      value.isNotEmpty ? valueCount = valueCount + 1 : null;
    });
    setState(() {
      _selectedFilterCount = valueCount;
    });
    widget.onFilterApply(selectedFilters);
    type == 'submit' ? Navigator.of(context).pop() : null;
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _platformController.dispose();
    _deckLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final Orientation orientation = MediaQuery.of(context).orientation;
    double buttonHeight = (screenWidth + screenHeight) * 0.03;
    double circleSize = screenWidth * 0.02;
    if (orientation == Orientation.portrait) {
      buttonHeight = screenHeight * 0.05;
    }

    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationFilterResetState) {
          final userTypeBasedFieldNames = {
            'Field Name': _userType == 'onshore' ? 'Location' : 'Field Name',
            'Platform': _userType == 'onshore' ? 'SubLocation' : 'Platform',
            'Deck Level': _userType == 'onshore' ? 'Area' : 'Deck Level',
          };

          selectedFields =
              state.filters[userTypeBasedFieldNames['Field Name']!] ?? [];
          selectedPlatForms =
              state.filters[userTypeBasedFieldNames['Platform']!] ?? [];
          selectedDeckLevels =
              state.filters[userTypeBasedFieldNames['Deck Level']!] ?? [];

          _selectedFilterCount =
              state.filters.values.where((value) => value.isNotEmpty).length;
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _showFilterDialog(context),
        child: Container(
          width: 156,
          height: buttonHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF9C9C9C),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.01),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 24 / 17,
                  color: const Color(0xFF353535),
                ),
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_selectedFilterCount > 0) ...[
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A6FB2),
                        shape: BoxShape.circle,
                      ),
                      // padding: EdgeInsets.all(circleSize * 0.01),
                      child: Center(
                        child: Text(
                          '$_selectedFilterCount',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              height: 19 / 12),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    )
                  ],
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _showFilterDialog(context),
                    child: Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(4),
                      child: Center(
                        child: SvgPicture.asset(
                          'lib/src/features/functional_areas/assets/svg/filter.svg',
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownMultiSelect(
      String label,
      double screenWidth,
      bool isPortrait,
      setState,
      TextEditingController controller,
      List<String> suggestions,
      List<String> selectedValues,
      String type) {
    dynamic selectVal;
    List<String> collection = [];
    if (selectedValues.isNotEmpty && suggestions.contains(selectedValues[0])) {
      collection = suggestions.where((e) => e == selectedValues[0]).toList();
    }
    if (type == "field_name") {
      selectVal = selectedValues.isEmpty ? null : collection[0];
    } else if (type == "plat_form") {
      selectVal = selectedValues.isEmpty ? null : collection[0];
    } else {
      selectVal = selectedValues.isEmpty ? null : collection[0];
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Focus(
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    iconStyleData: IconStyleData(
                      icon: isFocused
                          ? SvgPicture.asset(
                              "lib/src/features/functional_areas/assets/svg/up_arrow.svg")
                          : SvgPicture.asset(
                              "lib/src/features/functional_areas/assets/svg/down_arrow.svg"),
                    ),
                    isExpanded: true,
                    hint: Text(
                      'Select $label',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        enabled: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            type == "field_name"
                                ? Text('Selected (${selectedFields.length})',
                                    style:
                                        const TextStyle(color: Colors.black54))
                                : type == "plat_form"
                                    ? Text(
                                        'Selected (${selectedPlatForms.length})',
                                        style: const TextStyle(
                                            color: Colors.black54))
                                    : Text(
                                        'Selected (${selectedDeckLevels.length})',
                                        style: const TextStyle(
                                            color: Colors.black54)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (type == "field_name") {
                                        selectedFields.clear();
                                      }
                                      if (type == "plat_form") {
                                        selectedPlatForms.clear();
                                      }
                                      if (type == "deck_level") {
                                        selectedDeckLevels.clear();
                                      }
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Row(
                                    children: [
                                      Text('Clear',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Apply selected values or any other logic here
                                  },
                                  child: const Row(
                                    children: [
                                      // Icon(Icons.check, color: Colors.green),
                                      // SizedBox(width: 4),
                                      Text('Apply',
                                          style: TextStyle(
                                              color: Color(0xFF002B5C))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ...suggestions.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          enabled: false,
                          child: StatefulBuilder(
                            builder: (context, menuSetState) {
                              final bool isSelected;
                              if (type == "field_name") {
                                isSelected = selectedFields.contains(item);
                              } else if (type == "plat_form") {
                                isSelected = selectedPlatForms.contains(item);
                              } else {
                                isSelected = selectedDeckLevels.contains(item);
                              }
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (type == "field_name") {
                                      isSelected
                                          ? selectedFields.remove(item)
                                          : selectedFields.add(item);
                                    } else if (type == "plat_form") {
                                      isSelected
                                          ? selectedPlatForms.remove(item)
                                          : selectedPlatForms.add(item);
                                    } else {
                                      isSelected
                                          ? selectedDeckLevels.remove(item)
                                          : selectedDeckLevels.add(item);
                                    }
                                  });
                                  menuSetState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      isSelected
                                          ? const Icon(Icons.check_box_outlined)
                                          : const Icon(
                                              Icons.check_box_outline_blank),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                    value: selectVal,
                    onChanged: (value) {
                      setState(() {
                        if (type == "field_name") fieldName = value!;
                        if (type == "plat_form") platForm = value!;
                        if (type == "deck_level") deckLevel = value!;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      width: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          width: 0.1,
                          color: isFocused
                              ? Colors.white
                              : const Color(0xFFD0D3D8),
                        ),

                        // boxShadow: isFocused
                        //     ? [
                        //         const BoxShadow(
                        //           color: Color(0xA3002B5C),
                        //           blurRadius: 0.1,
                        //           offset: Offset(0, 0),
                        //         )
                        //       ]
                        //     : null,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          width: 1.0,
                          color: const Color(0xFFD0D3D8),
                        ),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                    dropdownSearchData: DropdownSearchData(
                      searchController: controller,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: controller,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for an $label...',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toString().toLowerCase());
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        controller.clear();
                      }
                    },
                    selectedItemBuilder: (context) {
                      return suggestions.map(
                        (item) {
                          return Container(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              type == "field_name"
                                  ? selectedFields.join(', ')
                                  : type == "plat_form"
                                      ? selectedPlatForms.join(', ')
                                      : selectedDeckLevels.join(', '),
                              style: const TextStyle(
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          );
                        },
                      ).toList();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      barrierColor: const Color(0x14000000),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = MediaQuery.of(context).size.width;
                final double screenHeight = MediaQuery.of(context).size.height;
                final bool isPortrait =
                    MediaQuery.of(context).orientation == Orientation.portrait;
                final double dialogWidth =
                    isPortrait ? screenWidth * 0.4 : screenWidth * 0.28;
                final double dialogHeight =
                    isPortrait ? screenHeight * 0.4 : screenHeight * 0.8;
                final double offsetX =
                    (constraints.maxWidth - dialogWidth) * 0.62;
                final double offsetY =
                    (constraints.maxHeight - dialogHeight) * 1.2;

                final String fieldNameLabel =
                    _userType == 'onshore' ? 'Location' : 'Field Name';
                final String platformLabel =
                    _userType == 'onshore' ? 'Sub Location' : 'Platform';
                final String deckLevelLabel =
                    _userType == 'onshore' ? 'Area' : 'Deck Level';

                return Stack(
                  children: [
                    Positioned(
                      left: offsetX,
                      top: offsetY,
                      child: Dialog(
                        backgroundColor: Colors.white,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isPortrait
                              ? screenWidth * 0.02
                              : screenWidth * 0.01),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: dialogWidth,
                            maxHeight: dialogHeight,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: screenWidth * 0.01,
                                    bottom: screenWidth * 0.005,
                                    left: screenWidth * 0.02,
                                    right: screenWidth * 0.02),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Filters",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(Icons.close)),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Colors.black12,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: screenHeight * 0.02,
                                    left: screenWidth * 0.02,
                                    right: screenWidth * 0.02,
                                    bottom: screenWidth * 0.02),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dropdownMultiSelect(
                                        fieldNameLabel,
                                        screenWidth,
                                        isPortrait,
                                        setState,
                                        _fieldNameController,
                                        _fieldNameSuggestions,
                                        selectedFields,
                                        'field_name'),
                                    SizedBox(height: screenHeight * 0.027),
                                    _dropdownMultiSelect(
                                        platformLabel,
                                        screenWidth,
                                        isPortrait,
                                        setState,
                                        _platformController,
                                        _platformSuggestions,
                                        selectedPlatForms,
                                        'plat_form'),
                                    SizedBox(height: screenHeight * 0.027),
                                    _dropdownMultiSelect(
                                        deckLevelLabel,
                                        screenWidth,
                                        isPortrait,
                                        setState,
                                        _deckLevelController,
                                        _deckLevelSuggestions,
                                        selectedDeckLevels,
                                        'deck_level'),
                                    SizedBox(height: screenHeight * 0.027),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: ElevatedButton.icon(
                                              icon: SvgPicture.asset(
                                                "lib/src/features/functional_areas/assets/svg/reset.svg",
                                                width: 16,
                                                height: 16,
                                              ),
                                              label: const Text('Reset ',
                                                  style: TextStyle(
                                                      color: Color(0xFF002B5C),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),
                                              onPressed: () {
                                                setState(() {
                                                  selectedFields = [];
                                                  selectedPlatForms = [];
                                                  selectedDeckLevels = [];
                                                });
                                                _applyFilter('reset');
                                                BlocProvider.of<LocationBloc>(
                                                        context)
                                                    .add(
                                                        LocationFilterResetEvent(
                                                            filters: const {},
                                                            locations: widget
                                                                .locations));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ).copyWith(
                                                side: WidgetStateProperty.all(
                                                  const BorderSide(
                                                      color: Color(0xFF002B5C),
                                                      width: 1),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          Expanded(
                                            flex: 10,
                                            child: ElevatedButton.icon(
                                              icon: SvgPicture.asset(
                                                "lib/src/features/functional_areas/assets/svg/search.svg",
                                                width: 16,
                                                height: 16,
                                              ),
                                              label: const Text('Find Results ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15)),
                                              onPressed: () {
                                                _applyFilter('submit');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
