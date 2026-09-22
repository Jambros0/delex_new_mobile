import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/ambient_temperature_formatter.dart';

void main() {
  group('AmbientTemperatureInputFormatter Tests', () {
    final formatter = AmbientTemperatureInputFormatter();

    TextEditingValue apply(TextEditingValue oldVal, String newText) {
      return formatter.formatEditUpdate(
        oldVal,
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
    }

    test('Typing number and pressing 1 space autotypes °C', () {
      // User types '40'
      var val = TextEditingValue(text: '40', selection: const TextSelection.collapsed(offset: 2));
      
      // User presses space -> '40 '
      val = apply(val, '40 ');
      expect(val.text, '40°C');
      expect(val.selection.baseOffset, 4);
    });

    test('Negative number and pressing 1 space autotypes °C', () {
      // User types '-40'
      var val = TextEditingValue(text: '-40', selection: const TextSelection.collapsed(offset: 3));
      
      // User presses space -> '-40 '
      val = apply(val, '-40 ');
      expect(val.text, '-40°C');
    });

    test('Positive number with sign and pressing 1 space autotypes °C', () {
      // User types '+55'
      var val = TextEditingValue(text: '+55', selection: const TextSelection.collapsed(offset: 3));
      
      // User presses space -> '+55 '
      val = apply(val, '+55 ');
      expect(val.text, '+55°C');
    });

    test('Pressing space on 40°C (double space step) autotypes " to "', () {
      var val = TextEditingValue(text: '40°C', selection: const TextSelection.collapsed(offset: 4));
      
      // User presses space after 40°C -> '40°C '
      val = apply(val, '40°C ');
      expect(val.text, '40°C to ');
      expect(val.selection.baseOffset, 8);
    });

    test('Full sequence: 40 -> space (°C) -> space (to) -> 55 -> space (°C)', () {
      // 1. Types '4'
      var val = apply(TextEditingValue.empty, '4');
      expect(val.text, '4');

      // 2. Types '0'
      val = apply(val, '40');
      expect(val.text, '40');

      // 3. Presses space -> auto °C
      val = apply(val, '40 ');
      expect(val.text, '40°C');

      // 4. Presses space again -> auto ' to '
      val = apply(val, '40°C ');
      expect(val.text, '40°C to ');

      // 5. Types '5'
      val = apply(val, '40°C to 5');
      expect(val.text, '40°C to 5');

      // 6. Types '5'
      val = apply(val, '40°C to 55');
      expect(val.text, '40°C to 55');

      // 7. Presses space -> auto °C
      val = apply(val, '40°C to 55 ');
      expect(val.text, '40°C to 55°C');
    });

    test('Negative to Positive range sequence: -40 -> space -> space -> +55 -> space', () {
      var val = apply(TextEditingValue.empty, '-40');
      expect(val.text, '-40');

      val = apply(val, '-40 ');
      expect(val.text, '-40°C');

      val = apply(val, '-40°C ');
      expect(val.text, '-40°C to ');

      val = apply(val, '-40°C to +55');
      expect(val.text, '-40°C to +55');

      val = apply(val, '-40°C to +55 ');
      expect(val.text, '-40°C to +55°C');
    });

    test('Deleting characters allows smooth backspacing', () {
      // From '40°C to ' backspacing
      var val = TextEditingValue(text: '40°C to ', selection: const TextSelection.collapsed(offset: 8));
      
      // User deletes trailing space -> '40°C to'
      val = formatter.formatEditUpdate(
        val,
        TextEditingValue(text: '40°C to', selection: const TextSelection.collapsed(offset: 7)),
      );
      // Formatter deletes whole ' to ' cleanly
      expect(val.text, '40°C');

      // User deletes 'C' from '40°C' -> '40°'
      val = formatter.formatEditUpdate(
        val,
        TextEditingValue(text: '40°', selection: const TextSelection.collapsed(offset: 3)),
      );
      // Formatter deletes '°C' cleanly to '40'
      expect(val.text, '40');

      // User deletes '0' -> '4'
      val = formatter.formatEditUpdate(
        val,
        TextEditingValue(text: '4', selection: const TextSelection.collapsed(offset: 1)),
      );
      expect(val.text, '4');
    });
  });
}
