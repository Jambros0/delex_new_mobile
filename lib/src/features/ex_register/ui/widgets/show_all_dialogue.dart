// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowAllDialog extends StatelessWidget {
  final String? alreadySelected;
  final void Function(String?)? onFilterSelected;
  const ShowAllDialog({super.key, this.onFilterSelected, this.alreadySelected});

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // final double buttonHeight = isPortrait
    //     ? (screenWidth + screenHeight) * 0.018
    final double buttonWidth =
        isPortrait ? screenWidth * 0.18 : screenWidth * 0.16;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showCustomPositionedDialog(context, buttonWidth);
      },
      child: Container(
        width: buttonWidth,
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFD0D3D8),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                alreadySelected ?? 'Show All',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF212121),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Color(0xFF3B475B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomPositionedDialog(BuildContext context, double buttonWidth) {
    const double dialogFontSize = 14;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x14000000),
      barrierLabel: 'Dismiss',
      pageBuilder: (context, anim1, anim2) {
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
            final double offsetX = (constraints.maxWidth - dialogWidth) * 0.627;
            final double offsetY =
                (constraints.maxHeight - dialogHeight) * 1.30;

            return Stack(
              children: [
                Positioned(
                  // top: screenHeight * (isPortrait ? 0.14 : 0.2),
                  // left: MediaQuery.of(context).size.width * 0.4,
                  left: offsetX,
                  top: offsetY,
                  child: Container(
                    width: buttonWidth,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF002B5C).withValues(alpha: 0.05),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: const Color(0xFF002B5C).withValues(alpha: 0.05),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildOption(context, 'Show All', dialogFontSize,
                            alreadySelected == 'Show All' ? true : false),
                        _buildOption(context, 'Uninspected', dialogFontSize,
                            alreadySelected == 'Uninspected' ? true : false),
                        _buildOption(context, 'Inspected', dialogFontSize,
                            alreadySelected == 'Inspected' ? true : false),
                        _buildOption(
                            context,
                            'Corrective Actions',
                            dialogFontSize,
                            alreadySelected == 'Corrective Actions'
                                ? true
                                : false),
                        _buildOption(
                            context,
                            'Repaired Partially',
                            dialogFontSize,
                            alreadySelected == 'Repaired Partially'
                                ? true
                                : false),
                        _buildOption(
                            context,
                            'Repaired Completely',
                            dialogFontSize,
                            alreadySelected == 'Repaired Completely'
                                ? true
                                : false),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOption(
      BuildContext context, String option, double fontSize, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDF3F8) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        selected: isSelected,
        selectedColor: const Color(0xFF3B475B),
        tileColor: const Color(0xFF3B475B),
        // trailing:
        //     isSelected ? const Icon(Icons.check, color: Colors.green) : null,
        title: Text(
          option,
          style: GoogleFonts.inter(
              fontSize: 17,
              color: const Color(0xFF3B475B),
              fontWeight: FontWeight.w400,
              height: 24 / 17),
        ),
        onTap: () {
          onFilterSelected!(option);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
