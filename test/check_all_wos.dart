import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final loginRes = await http.post(
    Uri.parse('http://94.136.185.87:16000/admin/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': 'mobile_onshore', 'password': 'Test@123'}),
  );
  final token = jsonDecode(loginRes.body)['accessToken'];
  final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

  // Query /onshore/workorder/assets with limit=100
  final res = await http.get(Uri.parse('http://94.136.185.87:16000/onshore/workorder/assets?limit=100'), headers: headers);
  final data = jsonDecode(res.body);
  print('Total in /onshore/workorder/assets?limit=100: ${data['total']}');
  final list = data['data'];
  if (list is List) {
    print('Work order count: ${list.length}');
    for (var wo in list) {
      final assets = wo['assets'] ?? wo['assignedAssets'];
      print('WO: ${wo['woNumber']} (${wo['_id']}) - ${assets is List ? assets.length : 0} assets');
    }
  }
}
