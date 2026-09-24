import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify growable list can be cleared and modified', () {
    List<bool> selectedRows = List<bool>.filled(10, false, growable: true);
    expect(selectedRows.length, 10);
    
    // Testing clear on growable list
    expect(() => selectedRows.clear(), returnsNormally);
    expect(selectedRows.isEmpty, true);

    // Testing reassignment to empty list
    selectedRows = [];
    expect(() => selectedRows.clear(), returnsNormally);

    // Testing List.from preserves growable property
    final rowSelection = List<bool>.filled(5, false, growable: true);
    selectedRows = List<bool>.from(rowSelection);
    expect(selectedRows.length, 5);
    expect(() => selectedRows.clear(), returnsNormally);
  });

  test('Verify fixed-length list throws on clear and growable does not', () {
    final fixedList = List<bool>.filled(5, false);
    expect(() => fixedList.clear(), throwsUnsupportedError);

    final growableList = List<bool>.filled(5, false, growable: true);
    expect(() => growableList.clear(), returnsNormally);
  });
}
