// ignore_for_file: file_names

class ColumnStyleHelper {
  static double getFunctionalHeaderRightPadding(String header) {
    return (header == "Gas Group" ||
            header == "Temperature Class" ||
            header == "IP Rating" ||
            header == "Location ID" ||
            header == "Area Classification Drawing No:" ||
            header == "Area Classification Drawing No")
        ? 24
        : 8;
  }

  static double getFunctionalHeaderCustomWidth(
      String header, double defaultWidth) {
    if (header == "Temperature Class") {
      return 170;
    } else if (header == "Zone") {
      return 130;
    } else if (header == "Gas Group") {
      return 135;
    } else if (header == "Area Classification Drawing No:" ||
        header == "Area Classification Drawing No") {
      return 256;
    } else if (header == "Location ID") {
      return 150;
    } else if (header == "IP Rating") {
      return 125;
    }
    return defaultWidth;
  }

  static double getFunctionalCellRightPadding(int key, [String? header]) {
    if (header != null && header.isNotEmpty) {
      return getFunctionalHeaderRightPadding(header);
    }
    return (key == 4 || key == 5 || key == 6 || key == 7 || key == 8) ? 24 : 8;
  }

  static double getFunctionalCellCustomWidth(int key, double defaultWidth,
      [String? header]) {
    if (header != null && header.isNotEmpty) {
      return getFunctionalHeaderCustomWidth(header, defaultWidth);
    }
    if (key == 5) {
      return 170;
    } else if (key == 6 || key == 7) {
      return 256;
    } else if (key == 8) {
      return 150;
    } else if (key == 3) {
      return 130;
    } else if (key == 4) {
      return 135;
    }
    return defaultWidth;
  }

  static double getExRegisterHeaderRightPadding(String header) {
    return (header == "Gas Group" ||
            header == "Temperature Class" ||
            header == "IP Rating" ||
            header == "Location ID" ||
            header == "Area Classification Drawing No:")
        ? 24
        : 8;
  }

  static double getExRegisterHeaderLeftPadding(String header) {
    return (header == "RFID Reference") ? 24 : 8;
  }

  static double getExRegisterHeaderCustomWidth(
      String header, double defaultWidth) {
    if (header == "RFID Reference") {
      return defaultWidth;
    } else if (header == "Field Name" || header == "Location") {
      return defaultWidth;
    } else if (header == "Platform" || header == "Sub Location") {
      return defaultWidth;
    } else if (header == "Deck Level" || header == "Area") {
      return defaultWidth;
    } else if (header == "Zone") {
      return 140;
    } else if (header == "Discpline" || header == "Discipline") {
      return 160;
    } else if (header == "Equipment Tag Number") {
      return 160;
    } else if (header == "Equipment Description") {
      return 220;
    } else if (header == "Manufacutrer" ||
        header == "Equipment Manufacturer" ||
        header == "Manufacturer") {
      return defaultWidth;
    } else if (header == "Equipment Protection") {
      return 200;
    } else if (header == "Inspection Faults") {
      return 160;
    } else if (header == "Inspection Status") {
      return 160;
    } else if (header == "Completed Repairs") {
      return 160;
    } else if (header == "Existing Faults") {
      return 160;
    } else if (header == "Current Status") {
      return 160;
    }
    return defaultWidth;
  }

  static double getExRegisterCellRightPadding(int key) {
    return (key == 4 || key == 5 || key == 6 || key == 7 || key == 8) ? 24 : 8;
  }

  static double getExRegisterCellCustomWidth(int key, double defaultWidth) {
    if (key == 1) {
      return 177;
    } else if (key == 2) {
      return defaultWidth;
    } else if (key == 3) {
      return defaultWidth;
    } else if (key == 4) {
      return defaultWidth;
    } else if (key == 5) {
      return 140;
    } else if (key == 6) {
      return 160;
    } else if (key == 7) {
      return 160;
    } else if (key == 8) {
      return 220;
    } else if (key == 9) {
      return defaultWidth;
    } else if (key == 10) {
      return 200;
    } else if (key == 11) {
      return 160;
    } else if (key == 12) {
      return 160;
    } else if (key == 13) {
      return 160;
    } else if (key == 14) {
      return 160;
    } else if (key == 15) {
      return 160;
    } else if (key == 16) {
      return 160;
    }
    return defaultWidth;
  }

  static double getDeviceSyncCellRightPadding(int key) {
    return (key == 4 || key == 5 || key == 6 || key == 7 || key == 8) ? 24 : 8;
  }

  static double getDeviceSyncCellCustomWidth(int key, double defaultWidth) {
    if (key == 1) {
      return 150;
    } else if (key == 2) {
      return defaultWidth;
    } else if (key == 3) {
      return defaultWidth;
    } else if (key == 4) {
      return defaultWidth;
    } else if (key == 5) {
      return 140;
    } else if (key == 6) {
      return 160;
    } else if (key == 7) {
      return 160;
    } else if (key == 8) {
      return 220;
    } else if (key == 9) {
      return defaultWidth;
    } else if (key == 10) {
      return 200;
    } else if (key == 11) {
      return 160;
    } else if (key == 12) {
      return 160;
    } else if (key == 13) {
      return 160;
    } else if (key == 14) {
      return 160;
    } else if (key == 15) {
      return 160;
    } else if (key == 16) {
      return 160;
    }
    return defaultWidth;
  }
}
