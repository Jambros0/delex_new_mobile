import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class DropdownMultiSelect extends StatefulWidget {
  final String label;
  final double width;
  final bool isPortrait;
  final TextEditingController controller;
  final List<String> suggestions;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;
  final String type;

  const DropdownMultiSelect({
    super.key,
    required this.label,
    required this.width,
    required this.isPortrait,
    required this.controller,
    required this.suggestions,
    required this.selectedItems,
    required this.onSelectionChanged,
    required this.type,
  });
  @override
  _DropdownMultiSelectState createState() => _DropdownMultiSelectState();
}

class _DropdownMultiSelectState extends State<DropdownMultiSelect> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.controller.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField<String>(
          onSelected: (driver) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          controller: widget.controller,
          animationDuration: const Duration(milliseconds: 300),
          debounceDuration: const Duration(milliseconds: 200),
          suggestionsCallback: (query) async {
            return widget.suggestions
                .where(
                    (item) => item.toLowerCase().contains(query.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, suggestion) {
            final isSelected = widget.selectedItems.contains(suggestion);
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              // dense: false,
              title: Text(
                suggestion,
                style: const TextStyle(fontSize: 14),
              ),
              leading: isSelected
                  ? const Icon(Icons.check_box, color: Colors.green)
                  : const Icon(Icons.check_box_outline_blank),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    widget.selectedItems.remove(suggestion);
                  } else {
                    widget.selectedItems.add(suggestion);
                  }
                });
                widget.onSelectionChanged(widget.selectedItems);
                widget.controller.clear();
              },
            );
          },
          builder: (context, controller, focusNode) => TextField(
            readOnly: true,
            controller: controller,
            focusNode: focusNode,
            // autofocus: false,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              // color: Colors.black,
            ),
            decoration: InputDecoration(
              labelText: null,
              hintText: 'Search ${widget.label}...',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              // contentPadding:
              //     EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          decorationBuilder: (context, child) {
            return Material(
              type: MaterialType.card,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: child,
            );
          },
        ),
        // const SizedBox(height: 10),
        // Wrap(
        //   spacing: 8.0,
        //   runSpacing: 4.0,
        //   children: widget.selectedItems.map((item) {
        //     return Chip(
        //       label: Text(item),
        //       onDeleted: () {
        //         setState(() {
        //           widget.selectedItems.remove(item);
        //         });
        //         widget.onSelectionChanged(widget.selectedItems);
        //       },
        //     );
        //   }).toList(),
        // ),
      ],
    );
  }
}
