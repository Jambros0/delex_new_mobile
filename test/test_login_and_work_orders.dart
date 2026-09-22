import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== STEP 1: Attempting Login with mobile_offshore / Test@123 ===');
  final loginUrl = 'http://94.136.185.87:16000/admin/login';
  try {
    final loginRes = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': 'mobile_offshore', 'password': 'Test@123'}),
    );
    print('Login Response Code: ${loginRes.statusCode}');
    print('Login Response Body: ${loginRes.body}');

    if (loginRes.statusCode == 200) {
      final loginData = jsonDecode(loginRes.body);
      final token = loginData['accessToken'];
      final user = loginData['user'] ?? loginData['data'] ?? loginData['userDetails'];
      final userId = user?['_id'] ?? user?['userId'] ?? user?['id'];
      print('Logged in user ID: $userId');

      final targetUserId = '6ab0d7c769bbfa6fbed32d6f';
      for (final endpoint in ['onshore', 'offshore']) {
        print('\n=== STEP 2: Fetching Work Orders ($endpoint) for user: $targetUserId ===');
        final woUrl = 'http://94.136.185.87:16000/$endpoint/user-work-orders/$targetUserId';
        final woRes = await http.get(
          Uri.parse(woUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        print('Work Order Response Code: ${woRes.statusCode}');
        if (woRes.statusCode == 200) {
          final decoded = jsonDecode(woRes.body);
          print('Total: ${decoded['total']}');
          final list = decoded['data'] as List?;
          if (list != null && list.isNotEmpty) {
            for (var wo in list) {
              print('WO KEYS: ${wo.keys.toList()}');
              print('WO assignedTo: ${wo['assignedTo']}, assigendTeam: ${wo['assigendTeam']}, userId: ${wo['userId']}, assignedUserId: ${wo['assignedUserId']}, inspectorId: ${wo['inspectorId']}, createdBy: ${wo['createdBy']}');
              print('WO: ${wo['workOrderId']} | Assets count: ${(wo['assignedAssets'] as List?)?.length}');
              final assets = wo['assignedAssets'] as List?;
              if (assets != null && assets.isNotEmpty) {
                final a = assets.first;
                print('dataSheet: ${a['dataSheet']}');
                print('dataSheetOrgName: ${a['dataSheetOrgName']}');
                print('dataSheetNo: ${a['dataSheetNo']}');
                final testFiles = {
                  'dataSheet': a['dataSheet'],
                  'correctivePhoto1': a['correctivePhoto1'],
                  'defectivePhoto1': a['defectivePhoto1'],
                  'inspectionSignOff': a['inspectionSignOff'],
                  'repairSignOff': a['repairSignOff'],
                };
                print('\n--- TESTING ASSET FILE PATHS ---');
                for (var entry in testFiles.entries) {
                  final field = entry.key;
                  final filePath = entry.value;
                  print('Field: $field => $filePath');
                  if (filePath != null && filePath.toString().isNotEmpty && filePath != "null") {
                    final baseUrl = 'http://94.136.185.87:16000';
                    final userType = endpoint;
                    final url = Uri.parse('$baseUrl/$userType/$filePath');
                    print('  Downloading $field from: $url');
                    try {
                      final client = http.Client();
                      final req = await client.get(url);
                      print('  Status: ${req.statusCode}, Bytes: ${req.bodyBytes.length}');
                    } catch (err) {
                      print('  ERROR downloading $field: $err');
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  } catch (e) {
    print('Error during login: $e');
  }
}
