import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownMultiSelect extends StatefulWidget {
  final String label;
  final double screenWidth;
  final bool isPortrait;
  final void Function(void Function()) setState;
  final TextEditingController controller;
  final List<String> suggestions;
  final List<String> selectedValues;
  final String type;
  final Function(String?) onValueChange;

  const DropdownMultiSelect({
    required this.label,
    required this.screenWidth,
    required this.isPortrait,
    required this.setState,
    required this.controller,
    required this.suggestions,
    required this.selectedValues,
    required this.type,
    required this.onValueChange,
    super.key,
  });

  @override
  State<DropdownMultiSelect> createState() => _DropdownMultiSelectState();
}

class _DropdownMultiSelectState extends State<DropdownMultiSelect> {
  @override
  Widget build(BuildContext context) {
    final selectVal = widget.selectedValues.isEmpty
        ? null
        : widget.suggestions.contains(widget.selectedValues[0])
            ? widget.selectedValues[0]
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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
                    iconStyleData: _buildIconStyle(isFocused),
                    isExpanded: true,
                    hint: _buildHintText(context),
                    items: _buildDropdownItems(context),
                    value: selectVal,
                    onChanged: (value) => _handleValueChange(value),
                    buttonStyleData: _buildButtonStyle(isFocused),
                    dropdownStyleData: _buildDropdownStyle(),
                    menuItemStyleData: const MenuItemStyleData(height: 40),
                    dropdownSearchData: _buildSearchData(),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        // Ensure the controller is cleared
                        widget.controller.clear();
                      }
                    },
                    selectedItemBuilder: (context) {
                      return [
                        _buildSelectedText(), // Ensure this is an actual widget
                      ];
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

  /// Build Icon Style
  IconStyleData _buildIconStyle(bool isFocused) {
    return IconStyleData(
      icon: isFocused
          ? SvgPicture.asset(
              "lib/src/features/functional_areas/assets/svg/up_arrow.svg")
          : SvgPicture.asset(
              "lib/src/features/functional_areas/assets/svg/down_arrow.svg"),
    );
  }

  /// Build Hint Text
  Widget _buildHintText(BuildContext context) {
    return Text(
      'Select ${widget.label}',
      style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
    );
  }

  /// Build Dropdown Items
  List<DropdownMenuItem<String>> _buildDropdownItems(BuildContext context) {
    return [
      _buildHeaderItem(context),
      ...widget.suggestions.map((item) => _buildSelectableItem(context, item)),
    ];
  }

  /// Build Header with Clear / Apply
  DropdownMenuItem<String> _buildHeaderItem(BuildContext context) {
    return DropdownMenuItem<String>(
      enabled: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Selected (${widget.selectedValues.length})',
            style: const TextStyle(color: Colors.black54),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  widget.setState(() {
                    widget.selectedValues.clear();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Apply',
                    style: TextStyle(color: Color(0xFF002B5C))),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Build Selectable Item
  DropdownMenuItem<String> _buildSelectableItem(
      BuildContext context, String item) {
    return DropdownMenuItem<String>(
      value: item,
      enabled: false,
      child: StatefulBuilder(
        builder: (context, menuSetState) {
          final bool isSelected = widget.selectedValues.contains(item);

          return InkWell(
            onTap: () {
              widget.setState(() {
                if (isSelected) {
                  widget.selectedValues.remove(item);
                } else {
                  widget.selectedValues.add(item);
                }
              });
              menuSetState(() {});
            },
            child: Row(
              children: [
                Icon(isSelected
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank),
                const SizedBox(width: 16),
                Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 14))),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Handle selection change
  void _handleValueChange(String? value) {
    if (value == null) return;
    widget.onValueChange(value); // Use the passed callback
  }

  /// Build Button Style
  ButtonStyleData _buildButtonStyle(bool isFocused) {
    return ButtonStyleData(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 0.1,
          color: isFocused ? Colors.white : const Color(0xFFD0D3D8),
        ),
      ),
    );
  }

  /// Build Dropdown Style
  DropdownStyleData _buildDropdownStyle() {
    return DropdownStyleData(
      maxHeight: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFD0D3D8), width: 1.0),
      ),
    );
  }

  /// Build Search Box
  DropdownSearchData<String> _buildSearchData() {
    return DropdownSearchData(
      searchController: widget.controller,
      searchInnerWidgetHeight: 50,
      searchInnerWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            hintText: 'Search for a ${widget.label}...',
            hintStyle: const TextStyle(fontSize: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      searchMatchFn: (item, searchValue) {
        return item.value
            .toString()
            .toLowerCase()
            .contains(searchValue.toLowerCase());
      },
    );
  }

  /// Selected Text Display
  Widget _buildSelectedText() {
    return Text(
      widget.selectedValues.join(', '),
      style: const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis),
      maxLines: 1,
    );
  }
}
