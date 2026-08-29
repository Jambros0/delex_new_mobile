import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

class SortOptions extends StatelessWidget {
  final String sortField;
  final Function(String sortOrder) onSortApplied;
  final List<ExRegister> assets;
  final List<ExRegister> registerCollections;
  const SortOptions(
      {super.key,
      required this.sortField,
      required this.onSortApplied,
      this.assets = const [],
      this.registerCollections = const []});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOption('Sort Ascending', "ascending"),
        _buildOption('Sort Descending', "descending"),
        _buildOption('Remove Sort', ""),
      ],
    );
  }

  Widget _buildOption(String text, String sortOrder) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onSortApplied(sortOrder);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: _textStyle(),
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle() {
    return GoogleFonts.nunitoSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF3B475B),
    );
  }
}
