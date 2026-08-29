// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationField extends StatefulWidget {
  final Offset position;
  final Function(List<String> selectedFilters)? onFilterApplied;
  final Function(List<String> selectedFilters) resetFilters;
  final List<String> locationDropDown;
  final List<String> selectedFilters;
  const LocationField({
    super.key,
    required this.position,
    this.onFilterApplied,
    required this.locationDropDown,
    required this.selectedFilters,
    required this.resetFilters,
  });

  @override
  LocationFieldState createState() => LocationFieldState();
}

class LocationFieldState extends State<LocationField> {
  late List<String> _selectedFields;
  bool allFieldsChecked = false;

  @override
  void initState() {
    super.initState();
    _selectedFields = List.from(
      widget.selectedFilters,
    ); // Keep previous selections
    allFieldsChecked = _selectedFields.length == widget.locationDropDown.length;
  }

  void _toggleFilter(String filterOption) {
    setState(() {
      if (filterOption == "All Fields") {
        allFieldsChecked = !allFieldsChecked;
        if (allFieldsChecked) {
          _selectedFields
            ..clear()
            ..addAll(widget.locationDropDown);
        } else {
          _selectedFields.clear();
        }
      } else {
        if (_selectedFields.contains(filterOption)) {
          _selectedFields.remove(filterOption);
        } else {
          _selectedFields.add(filterOption);
        }
        allFieldsChecked =
            _selectedFields.length == widget.locationDropDown.length;
      }
    });
  }

  // void _resetFilters() {
  //   setState(() {
  //     _selectedFields.clear();
  //     widget.selectedFilters.clear();
  //   });
  //   Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    const double dialogWidth = 280;
    const double dialogHeight = 495;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double offsetX = (constraints.maxWidth - dialogWidth) * 0.79;
        final double offsetY = (constraints.maxHeight - dialogHeight) * 0.81;
        final double screenHeight = MediaQuery.of(context).size.height;
        final double screenWidth = MediaQuery.of(context).size.width;
        return Stack(
          children: [
            Positioned(
              left: offsetX,
              top: offsetY,
              child: SizedBox(
                width: screenWidth * 0.232,
                height: screenHeight * 0.6,
                child: Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: widget.locationDropDown.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildCheckboxOption("All Fields");
                            } else {
                              return _buildCheckboxOption(
                                widget.locationDropDown[index - 1],
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ).copyWith(bottom: 1),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 45,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFields.clear();
                                      widget.resetFilters(_selectedFields);
                                      widget.selectedFilters.clear();
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFF002B5C),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'lib/src/features/ex_register/assets/refresh.svg',
                                        width: 18,
                                        height: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Reset',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF002B5C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 89,
                                child: ElevatedButton.icon(
                                  label: const Text(
                                    'Go',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  onPressed: () {
                                    widget.onFilterApplied?.call(
                                      _selectedFields,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
  }

  Widget _buildCheckboxOption(String filterText) {
    bool isSelected = filterText == "All Fields"
        ? allFieldsChecked
        : _selectedFields.contains(filterText);

    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 5, left: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: isSelected
              ? const Color(0xFF002B5C).withOpacity(0.1)
              : Colors.white70,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _toggleFilter(filterText),
          child: Row(
            children: [
              Checkbox(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                side: WidgetStateBorderSide.resolveWith(
                  (states) =>
                      const BorderSide(width: 1.0, color: Colors.black54),
                ),
                value: filterText == "All Fields"
                    ? allFieldsChecked
                    : _selectedFields.contains(filterText),
                onChanged: (bool? value) {
                  _toggleFilter(filterText);
                },
                checkColor: const Color(0xFF002B5C),
                activeColor: Colors.white70,
              ),
              Text(
                filterText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF3B475B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
