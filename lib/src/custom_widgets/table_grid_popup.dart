import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/table_grid_sort.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:flutter/material.dart';

class SortPopup extends StatefulWidget {
  final String sortField;
  final Offset position;
  final Function(String sortField, String sortOrder)? onSortApplied;
  final List<ExRegister> assets;
  final List<ExRegister> registerCollections;
  const SortPopup(
      {super.key,
      required this.sortField,
      required this.position,
      this.onSortApplied,
      this.assets = const [],
      this.registerCollections = const []});

  @override
  SortPopupState createState() => SortPopupState();
}

class SortPopupState extends State<SortPopup> {
  @override
  Widget build(BuildContext context) {
    const double dialogWidth = 235;
    const double dialogHeight = 150;

    return Positioned(
      top: widget.position.dy - 0.1,
      left: widget.position.dx - (dialogWidth / 1.3),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SortOptions(
                    key: const ValueKey('SortOptions'),
                    sortField: widget.sortField,
                    onSortApplied: (sortOrder) {
                      widget.onSortApplied?.call(widget.sortField, sortOrder);
                      Navigator.of(context).pop();
                    },
                    assets: widget.assets,
                    registerCollections: widget.registerCollections),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
