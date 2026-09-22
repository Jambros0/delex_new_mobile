import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token =
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2YWFiOTZlOTA2ZGU2YjdiM2RkNmMyZTciLCJlbWFpbCI6ImFkbWluLW9uc2hvcmVAZGVsZXguY29tIiwidXNlcm5hbWUiOiJhZG1pbi1vbnNob3JlIiwidXNlclJvbGUiOiJTeXN0ZW0gQWRtaW5pc3RyYXRvciIsInJvbGUiOiJTeXN0ZW0gQWRtaW5pc3RyYXRvciIsImNhbm9uaWNhbFJvbGUiOiJTeXN0ZW0gQWRtaW5pc3RyYXRvciIsInVzZXJUeXBlIjoib25zaG9yZSIsImlhdCI6MTc5MDA1OTA3NiwiZXhwIjoxNzkyNjUxMDc2fQ.NnhC7v7_oQIZrQFLv4b4HaBdVniFVm4a2ijFatiNWeU9AWKe8dayehuCTEZ6XdRiZk04f_luYJUSvL5JcJOyQ_KyHzyBME8TnqyDUB_AS9wrGvGh5gw_HzF9R_9jE6ruDyZUce-XWm1cOqXoHkeqvrMZ4xyVl5xHsGLJGzf-G7L2ANgKtPKIp7W3QWcdRvPcy4B_sdLCFpVXMfkodBOA7A0_GUAmER5PMSI1bXw6oz6BI_L92OuE-mRXiTuWGp5OwvpW1hNEgs5Pl4gG-E7qx6g3fBighbOHrGe_LeXVW7ilERL_n1yrxp3I03zdCnnzEDyGDs_IxFtkyl0e3J3_lBuORFHlv2gjwbU1qXqMYrBVwLoRpudhOBV4h_tNXmWPrcF4UM7axdH4dlJLWFY5rKs2MBSV2XY30Dr4y613TmZwAEzBJB9N_HnKi3u2bQca0x_0_8Zy4YcEBwAXATS66ab3d6LfIORU8i99xCbE1HE4PyPvINMSLlWNeHcVwMuE628NxhcTUyB0Qq8PUAe-X-lJfIcuCfGpPWcSB-9TOD9lcCh8lZ1XJjCTeqk8G41XAl6P2cUhR9v-zIu9Oul0z-rrfrzR1FSUaDs1rpFRGTpZCSQ-mauH8TIbyFx9E00kQNv9FOLzDBMvK24OUg9UsUzfcWCKNL44nmZ4JUC8t7M';

  // Decode token payload
  final payload = utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1])));
  final tokenPayload = jsonDecode(payload);
  print("=== TOKEN USER INFO ===");
  print("User ID: ${tokenPayload['userId']}");
  print("Username: ${tokenPayload['username']}");
  print("Email: ${tokenPayload['email']}");
  print("Role: ${tokenPayload['role']}");
  print("User Type: ${tokenPayload['userType']}");

  final userId = tokenPayload['userId'];
  final url = 'http://94.136.185.87:16000/onshore/user-work-orders/$userId';
  print("\n=== REQUESTING WORK ORDERS ===");
  print("URL: $url");

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("\n=== RESPONSE STATUS ===");
  print("HTTP Status Code: ${response.statusCode}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    print("\n=== API RESPONSE SUMMARY ===");
    print("Status: ${jsonResponse['status']}");
    print("Message: ${jsonResponse['msg']}");
    print("Total Work Orders: ${jsonResponse['total']}");

    final List<dynamic> data = jsonResponse['data'] ?? [];
    print("Fetched Work Orders Count: ${data.length}");
    final decoded = jsonDecode(response.body);
    print('\n================ API RESPONSE SUMMARY ================');
    print('HTTP Status Code: ${response.statusCode}');
    print('API Status: ${decoded['status']}');
    print('Message: ${decoded['msg']}');
    print('Total Work Orders: ${decoded['total']}');
    print('======================================================\n');

    final List workOrders = decoded['data'] ?? [];
    for (int i = 0; i < workOrders.length; i++) {
      final wo = workOrders[i];
      final assets = (wo['assignedAssets'] as List?) ?? [];
      print('----------------------------------------------------');
      print('WORK ORDER #${i + 1}');
      print('  Work Order Mongo ID: ${wo['_id']}');
      print('  Work Order ID: ${wo['workOrderId'] ?? wo['workorderId'] ?? 'N/A'}');
      print('  Title: ${wo['workOrderTitle'] ?? wo['title'] ?? 'N/A'}');
      print('  Description: ${wo['description'] ?? 'N/A'}');
      print('  Work Order Type: ${wo['workOrderType'] ?? 'N/A'}');
      print('  Status: ${wo['status'] ?? 'N/A'}');
      print('  Total Assigned Assets: ${assets.length}');
      print('----------------------------------------------------');

      for (int j = 0; j < assets.length; j++) {
        final a = assets[j];
        final tag = a['eqpmtTag'] ?? a['equipmentTag'] ?? '(No Tag)';
        final desc = a['description'] ?? '(No Description)';
        final cat = a['equipmentCategory'] ?? 'N/A';
        final rfid = a['rfidRef'] ?? 'N/A';
        final status = a['currentStatus'] ?? a['inspectionStatus'] ?? 'N/A';
        final assetId = a['_id'] ?? 'N/A';
        final locationId = a['locationId'] ?? 'N/A';

        print('  [${j + 1}] Tag: $tag | Cat: $cat | Status: $status | RFID: $rfid');
        print('      Desc: $desc | Asset ID: $assetId | Location ID: $locationId');
      }
      print('');
    }
  } else {
    print("Response Body: ${response.body}");
  }
}
