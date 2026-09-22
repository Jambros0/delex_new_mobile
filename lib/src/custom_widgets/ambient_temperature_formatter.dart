import 'package:flutter/services.dart';

class AmbientTemperatureInputFormatter extends TextInputFormatter {
  static final RegExp _singleNumberPattern = RegExp(r'^([+-]?\d{1,3})$');
  static final RegExp _firstTempPattern = RegExp(r'^([+-]?\d{1,3}°C)$');
  static final RegExp _secondNumberPattern =
      RegExp(r'^([+-]?\d{1,3}°C to )([+-]?\d{1,3})$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    // If deleting, allow clean deletion without interference
    if (newText.length < oldText.length) {
      // If user is deleting 'C' from '°C', delete both '°C'
      if (oldText.endsWith('°C') && newText.endsWith('°')) {
        final updatedText = newText.substring(0, newText.length - 1);
        return TextEditingValue(
          text: updatedText,
          selection: TextSelection.collapsed(offset: updatedText.length),
        );
      }
      // If user is deleting from ' to ', delete the whole ' to '
      if (oldText.endsWith(' to ') && newText.endsWith(' to')) {
        final updatedText = newText.substring(0, newText.length - 3);
        return TextEditingValue(
          text: updatedText,
          selection: TextSelection.collapsed(offset: updatedText.length),
        );
      }
      return newValue;
    }

    // Check if user typed a space at the end
    if (newText.endsWith(' ')) {
      final trimmedNew = newText.trimRight();

      // Case 1: First number typed (e.g. '40', '-40', '+55') followed by space -> '40°C'
      if (_singleNumberPattern.hasMatch(trimmedNew)) {
        final formatted = '$trimmedNew°C';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      // Case 2: User has '40°C' and presses space -> '40°C to '
      if (_firstTempPattern.hasMatch(trimmedNew)) {
        final formatted = '$trimmedNew to ';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      // Case 3: User has '40°C to 55' and presses space -> '40°C to 55°C'
      final secondMatch = _secondNumberPattern.firstMatch(trimmedNew);
      if (secondMatch != null) {
        final formatted = '$trimmedNew°C';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      // Case 4: User typed 'to ' after '°C' -> '...°C to '
      if (trimmedNew.endsWith('to') && trimmedNew.contains('°C')) {
        final prefix =
            trimmedNew.substring(0, trimmedNew.length - 2).trimRight();
        final formatted = '$prefix to ';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      // If already ends with ' to ' and pressed another space, ignore redundant space
      if (oldText.endsWith(' to ')) {
        return oldValue;
      }

      // If already ends with '°C' and second temp is complete (e.g. '40°C to 55°C '), ignore extra space
      if (RegExp(r'^([+-]?\d{1,3}°C to [+-]?\d{1,3}°C)$')
          .hasMatch(trimmedNew)) {
        return oldValue;
      }
    }

    return newValue;
  }
}
