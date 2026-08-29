import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchableDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final bool isEditMode;
  final bool isNotApplicable;
  final String? hint;
  final bool hasError;

  const SearchableDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isEditMode,
    required this.isNotApplicable,
    this.hint,
    this.hasError = false,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _dropdownFocusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _dropdownFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _dropdownFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dropdownFocusNode.removeListener(_onFocusChange);
    _dropdownFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueItems = widget.items.toSet().toList();
    final isInteractive = widget.isEditMode && !widget.isNotApplicable;

    return Focus(
      focusNode: _dropdownFocusNode,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          iconStyleData: IconStyleData(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isFocused && (widget.value == null || widget.value!.isEmpty))
                  SizedBox(
                    height: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          '|',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF212121),
                            height: 24 / 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.isEditMode)
                  Icon(
                    _isFocused ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: widget.isNotApplicable
                        ? const Color(0xFF969696)
                        : const Color(0xFF3B475B),
                    size: 24,
                  )
                else
                  const SizedBox(),
              ],
            ),
          ),
          hint: !_isFocused
              ? Text(
                  widget.hint ?? 'Select the option',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: !widget.isEditMode
                        ? const Color(0xFFBABABA)
                        : const Color(0xFF979797),
                    height: 24 / 17,
                  ),
                )
              : null,
          value: uniqueItems.contains(widget.value) ? widget.value : null,
          onChanged: isInteractive ? widget.onChanged : null,
          items: uniqueItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: widget.isNotApplicable
                      ? const Color(0xFFB5B5B5)
                      : const Color(0xFF3B475B),
                  height: 24 / 17,
                ),
              ),
            );
          }).toList(),
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isInteractive ? const Color(0xFFFFFFFF) : const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: widget.hasError
                    ? const Color(0xFFF44336)
                    : (_isFocused ? const Color(0xFF002B5C) : const Color(0xFFD0D3D8)),
                width: 1.0,
              ),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: _searchController,
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  hintText: 'Search...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return item.value!
                  .toLowerCase()
                  .contains(searchValue.toLowerCase());
            },
          ),
          onMenuStateChange: (isOpen) {
            if (!isOpen && mounted) {
              _searchController.clear();
            }
          },
        ),
      ),
    );
  }
}
