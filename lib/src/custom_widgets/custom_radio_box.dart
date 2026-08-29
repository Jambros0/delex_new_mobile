import 'package:flutter/material.dart';

class CustomRadioButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomRadioButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  CustomRadioButtonState createState() => CustomRadioButtonState();
}

class CustomRadioButtonState extends State<CustomRadioButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: 16.67,
        height: 16.67,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.value
                ? const Color(0xFF3B475B)
                : const Color(0xFF9C9C9C),
            width: 0.83,
          ),
          color: widget.value ? const Color(0xFFEDF3F8) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0x0D1B2029),
              blurRadius: widget.value ? 1.67 : 1,
              spreadRadius: widget.value ? 0.83 : 1,
              offset: widget.value ? const Offset(0, 0.83) : const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: widget.value
              ? Container(
                  width: 6.67,
                  height: 6.67,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3B475B),
                  ),
                )
              : Container(),
        ),
      ),
    );
  }
}
