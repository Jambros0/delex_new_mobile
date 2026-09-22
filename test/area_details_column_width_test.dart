import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/columStyle.dart';

void main() {
  group('Area Details / Functional Areas Column Style Tests', () {
    test('Header and cell widths and paddings match for Area Classification Drawing No:', () {
      const defaultWidth = 100.0;
      final headerWidth = ColumnStyleHelper.getFunctionalHeaderCustomWidth('Area Classification Drawing No:', defaultWidth);
      final cellWidth = ColumnStyleHelper.getFunctionalCellCustomWidth(6, defaultWidth, 'Area Classification Drawing No:');
      expect(headerWidth, 256.0);
      expect(cellWidth, 256.0);

      final headerPadding = ColumnStyleHelper.getFunctionalHeaderRightPadding('Area Classification Drawing No:');
      final cellPadding = ColumnStyleHelper.getFunctionalCellRightPadding(6, 'Area Classification Drawing No:');
      expect(headerPadding, 24.0);
      expect(cellPadding, 24.0);
    });

    test('Header and cell widths and paddings match for all standard functional area headers', () {
      const defaultWidth = 120.0;
      final headers = [
        'Location',
        'Sub Location',
        'Area',
        'Zone',
        'Gas Group',
        'Temperature Class',
        'Area Classification Drawing No:',
      ];

      for (int i = 0; i < headers.length; i++) {
        final header = headers[i];
        final hWidth = ColumnStyleHelper.getFunctionalHeaderCustomWidth(header, defaultWidth);
        final cWidth = ColumnStyleHelper.getFunctionalCellCustomWidth(i, defaultWidth, header);
        expect(cWidth, equals(hWidth), reason: 'Width mismatch for column "$header"');

        final hPad = ColumnStyleHelper.getFunctionalHeaderRightPadding(header);
        final cPad = ColumnStyleHelper.getFunctionalCellRightPadding(i, header);
        expect(cPad, equals(hPad), reason: 'Padding mismatch for column "$header"');
      }
    });

    test('Header variants without trailing colon are supported', () {
      const defaultWidth = 100.0;
      expect(
        ColumnStyleHelper.getFunctionalHeaderCustomWidth('Area Classification Drawing No', defaultWidth),
        256.0,
      );
      expect(
        ColumnStyleHelper.getFunctionalHeaderRightPadding('Area Classification Drawing No'),
        24.0,
      );
    });

    test('Fallback by column index returns matching widths', () {
      const defaultWidth = 100.0;
      expect(ColumnStyleHelper.getFunctionalCellCustomWidth(3, defaultWidth), 130.0); // Zone
      expect(ColumnStyleHelper.getFunctionalCellCustomWidth(4, defaultWidth), 135.0); // Gas Group
      expect(ColumnStyleHelper.getFunctionalCellCustomWidth(5, defaultWidth), 170.0); // Temperature Class
      expect(ColumnStyleHelper.getFunctionalCellCustomWidth(6, defaultWidth), 256.0); // Area Classification Drawing No
      expect(ColumnStyleHelper.getFunctionalCellCustomWidth(7, defaultWidth), 256.0); // Area Classification Drawing No (8-col)
    });
  });
}
