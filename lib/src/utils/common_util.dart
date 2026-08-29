import 'dart:convert';

class CommonFunctions {
  Future<String> reversedRFIDString(String value) async {
    if (value.length % 2 != 0) {
      throw ArgumentError("Input length must be even");
    }
    List<String> bytePairs = [];
    for (int i = 0; i < value.length; i += 2) {
      bytePairs.add(value.substring(i, i + 2));
    }
    return bytePairs.reversed.join();
  }

  Map<String, dynamic> decodeJson(dynamic json) {
    Map<String, dynamic> jsonMap = {};
    if (json is String) {
      try {
        jsonMap = jsonDecode(json);
      } catch (e) {
        throw FormatException("Invalid JSON string: $json");
      }
    } else if (json is Map<String, dynamic>) {
      jsonMap = json;
    } else {
      throw FormatException("Invalid type for JSON: ${json.runtimeType}");
    }

    return jsonMap;
  }
}
