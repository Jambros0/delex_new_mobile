import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomRoundCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isHeader;
  final double checkboxWidth;
  final double leftPadding;

  static const Color nonHeaderBorderColor = Color(0xFF9C9C9C);
  static const Color checkedColor = Color(0xFF002B5C);

  const CustomRoundCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.isHeader = false,
    required this.checkboxWidth,
    required this.leftPadding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Transform.scale(
          scale: 1,
          child:
              // Checkbox(
              //     shape: const RoundedRectangleBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(5.0))),
              //     side: WidgetStateBorderSide.resolveWith(
              //       (states) => BorderSide(
              //           width: 1.0, color: isHeader ? Colors.white : Colors.black54),
              //     ),
              //     value: value,
              //     onChanged: (bool? value) {
              //       onChanged(value!);
              //     },
              //     checkColor: const Color(0xFF002B5C),
              //     activeColor: Color(0xFFEDF3F8)),
              Container(
            decoration: BoxDecoration(
              color: value ? const Color(0xFFEDF3F8) : Colors.transparent,
              border: Border.all(
                color: value
                    ? isHeader
                        ? Colors.white
                        : const Color(0xFF3B475B)
                    : isHeader
                        ? const Color(0xFF9C9C9C)
                        : const Color(0xFF9C9C9C),
                width: 1.25,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            width: 19,
            height: 19,
            child: Center(
              child: value
                  ? SvgPicture.asset(
                      "lib/src/features/ex_register/assets/checkbox.svg",
                      color: value ? const Color(0xFF002B5C) : Colors.black54,
                      // size: 16,
                    )
                  : const SizedBox(),
            ),
          ),
        ),
      ),
    );

    //   GestureDetector(
    //   onTap: () => onChanged(!value),
    //   child: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: SizedBox(
    //       width: checkboxWidth,
    //       child: Align(
    //         alignment: Alignment.centerLeft,
    //         child: Padding(
    //           padding: EdgeInsets.only(left: leftPadding),
    //           child: Container(
    //             width: 22,
    //             height: 22,
    //             decoration: BoxDecoration(
    //               shape: BoxShape.rectangle,
    //               color: isHeader ? const Color(0xFF333E51) : Colors.white,
    //               border: Border.all(
    //                 color: isHeader
    //                     ? Colors.white
    //                     : value
    //                         ? checkedColor
    //                         : nonHeaderBorderColor,
    //                 width: 2,
    //               ),
    //               borderRadius: BorderRadius.circular(5),
    //             ),
    //             child: value
    //                 ? Icon(
    //                     Icons.check,
    //                     size: 14,
    //                     color: isHeader ? Colors.white : checkedColor,
    //                   )
    //                 : null,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
