import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final bool isMandatory;
  final bool disabled;
  final ValueChanged<List<String>>? onChanged;
  final bool isSubmitting;
  final bool isNotApplicable;
  final String? selectedItemString;
  final String? Function(List<String>?)? validator;
  final bool isInspectionFlag;
  final ValueNotifier<bool>? isEditModeNotifier;
  final ValueNotifier<bool>? isEditAreaModeNotifier;
  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    this.isMandatory = false,
    this.disabled = false,
    this.onChanged,
    required this.isSubmitting,
    this.isNotApplicable = false,
    required this.selectedItemString,
    this.validator,
    this.isInspectionFlag = false,
    this.isEditModeNotifier,
    this.isEditAreaModeNotifier,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  late List<String> selected;
  late LayerLink _layerLink;
  OverlayEntry? _dropdownOverlayEntry;
  // final TextEditingController _controller = TextEditingController();
  bool _lastShowAbove = false;
  final FocusNode _focusNode = FocusNode();
  double _dropdownHeight = 230;
  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedItems);
    _layerLink = LayerLink();
  }

  // void _updateControllerText() {
  //   _controller.text = selected.map((e) => e.split(' ').last).join(', ');
  // }

  void _removeDropdown() {
    if (_dropdownOverlayEntry != null) {
      _dropdownOverlayEntry!.remove();
      _dropdownOverlayEntry = null;
    }
  }

  @override
  void dispose() {
    _removeDropdown();
    _focusNode.dispose();
    // _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.selectedItems, oldWidget.selectedItems)) {
      setState(() {
        selected = List.from(widget.selectedItems);
      });
    }
  }

  void _startOverlayPositionListener(
      FormFieldState<List<String>> field, List<String> items) {
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (!mounted || _dropdownOverlayEntry == null) return;

      final renderBox = context.findRenderObject() as RenderBox?;
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox?;
      if (renderBox == null || overlay == null) return;

      final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
      final screenHeight = MediaQuery.of(context).size.height;
      final spaceBelow = screenHeight - position.dy - renderBox.size.height;
      final spaceAbove = position.dy;
      final dropdownHeight = _dropdownHeight;
      final bool shouldBeAbove =
          spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;

      if (shouldBeAbove != _lastShowAbove) {
        _lastShowAbove = shouldBeAbove;
        _removeDropdown(); // rebuild overlay with updated direction
        _toggleDropdownOverlay(context, field);
      }
    });
  }

  void _toggleDropdownOverlay(
      BuildContext context, FormFieldState<List<String>> field) {
    // if (_dropdownOverlayEntry != null) {
    _removeDropdown();
    // return;
    // }
    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - position.dy - renderBox.size.height;
    final spaceAbove = position.dy;
    _dropdownHeight = widget.items.length == 1
        ? 90
        : widget.items.length == 3
            ? 170
            : 230;

    final dropdownHeight = _dropdownHeight;
    final bool showAbove =
        spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;
    final width = widget.isInspectionFlag
        ? MediaQuery.of(context).size.width * 0.202
        : MediaQuery.of(context).size.width * 0.276;
    final screenWidth = MediaQuery.of(context).size.width;
    final overlayWidth = math.max(width, 280.0).clamp(0.0, screenWidth - 32.0);
    final double dxOffset = (position.dx + overlayWidth > screenWidth - 16)
        ? (screenWidth - 16 - position.dx - overlayWidth)
        : 0.0;

    _dropdownOverlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeDropdown();
              },
              behavior: HitTestBehavior.translucent,
              child: const SizedBox(),
            ),
          ),
          Positioned(
            width: overlayWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: showAbove
                  ? Offset(dxOffset, -dropdownHeight - 8.0)
                  : Offset(dxOffset, 73.5 + 8.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: StatefulBuilder(
                  builder: (context, setOverlayState) {
                    final selectedItemsList = widget.items
                        .where((item) => selected.contains(item))
                        .toList();
                    final unselectedItemsList = widget.items
                        .where((item) => !selected.contains(item))
                        .toList();

                    return Container(
                      // height: 48,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text('Selected(${selected.length})',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF848B98),
                                    )),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setOverlayState(() {
                                        selected.clear();
                                      });
                                      field.didChange(List.from(selected));
                                      widget.onChanged
                                          ?.call(List.from(selected));
                                    },
                                    child: Text('Clear all',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFF43434))),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      field.didChange(List.from(selected));
                                      widget.onChanged?.call(selected);
                                      _removeDropdown();
                                    },
                                    child: Text('Apply',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF002B5C))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: [
                                selectedItemsList.isEmpty
                                    ? const Divider(color: Color(0xFFF1F1F1))
                                    : const SizedBox(),
                                ...selectedItemsList.map((item) =>
                                    _buildItem(item, setOverlayState)),
                                if (selectedItemsList.isNotEmpty &&
                                    unselectedItemsList.isNotEmpty)
                                  const Divider(color: Color(0xFFF1F1F1)),
                                ...unselectedItemsList.map((item) =>
                                    _buildItem(item, setOverlayState)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_dropdownOverlayEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOverlayPositionListener(field, widget.items);
    });
  }

  Widget _buildItem(
      String item, void Function(VoidCallback fn) setOverlayState) {
    final isSelected = selected.contains(item);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: InkWell(
        onTap: () {
          setOverlayState(() {
            isSelected ? selected.remove(item) : selected.add(item);
          });
        },
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEAF1F7) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF002B5C)
                      : const Color(0xFFB0B0B0),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4.5),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF002B5C))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(item,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1D232F))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showErrorColor =
        widget.isSubmitting && widget.isMandatory && selected.isEmpty;
    // final showErrorColor = widget.isMandatory && selected.isEmpty;
    final width = widget.isInspectionFlag
        ? MediaQuery.of(context).size.width * 0.202
        : MediaQuery.of(context).size.width * 0.276;

    return FormField<List<String>>(
      key: ValueKey(selected),
      initialValue: selected,
      validator: widget.validator ??
          (value) {
            if (widget.isMandatory && selected.isEmpty) {
              return '';
            }
            return null;
          },
      builder: (FormFieldState<List<String>> field) {
        // final showErrorColor = field.hasError;
        return CompositedTransformTarget(
          link: _layerLink,
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.label}${widget.isMandatory ? '*' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isNotApplicable
                        ? const Color(0xFFB5B5B5)
                        : showErrorColor
                            ? const Color(0xFFF44336)
                            : widget.disabled
                                ? const Color(0xFF999999)
                                : const Color(0xFF4B4B4B),
                  ),
                ),
                const SizedBox(height: 8),
                Focus(
                  focusNode: _focusNode,
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      _removeDropdown(); // close when focus is lost
                    }
                  },
                  child: ValueListenableBuilder<bool>(
                    valueListenable:
                        widget.isEditModeNotifier ?? ValueNotifier(true),
                    builder: (context, isEditMode, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: widget.isEditAreaModeNotifier ??
                            ValueNotifier(true),
                        builder: (context, isEditAreaMode, _) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: !isEditAreaMode ||
                                    !isEditMode ||
                                    widget.disabled ||
                                    widget.isNotApplicable
                                ? null
                                : () => _toggleDropdownOverlay(context, field),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: !isEditAreaMode ||
                                        !isEditMode ||
                                        widget.disabled ||
                                        widget.isNotApplicable
                                    ? const Color(0xFFFBFBFB)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: showErrorColor
                                      ? const Color(0xFFF44336)
                                      : const Color(0xFFD0D3D8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        selected.isNotEmpty
                                            ? widget.label ==
                                                    'Temperature Class'
                                                ? selected
                                                    .map((e) => e.contains('-')
                                                        ? e.split('-')[0]
                                                        : e)
                                                    .join(', ')
                                                : selected.join(', ')
                                            : "Select items",
                                        style: GoogleFonts.inter(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          color: widget.isNotApplicable
                                              ? const Color(0xFFB5B5B5)
                                              : selected.isEmpty
                                                  ? const Color(0xFF979797)
                                                  : const Color(0xFF3B475B),
                                        ),
                                      ),
                                    ),
                                  ),
                                  !isEditAreaMode
                                      ? const SizedBox()
                                      : !isEditMode
                                          ? const SizedBox()
                                          : Icon(
                                              _dropdownOverlayEntry != null
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: !isEditAreaMode
                                                  ? const Color(0xFFBABABA)
                                                  : !isEditMode
                                                      ? const Color(0xFFBABABA)
                                                      : const Color(0xFF3B475B),
                                            ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
