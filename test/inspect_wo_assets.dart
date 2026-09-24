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

  final res = await http.get(Uri.parse('http://94.136.185.87:16000/onshore/workorder/assets'), headers: headers);
  print('Status: ${res.statusCode}');
  final data = jsonDecode(res.body);
  print('Keys: ${data.keys.toList()}');
  print('Total: ${data['total']}');
  final list = data['data'];
  if (list is List) {
    print('Work orders in data: ${list.length}');
    int totalAssets = 0;
    for (int i = 0; i < list.length; i++) {
      final wo = list[i];
      final assets = wo['assets'] ?? wo['assignedAssets'];
      final count = assets is List ? assets.length : 0;
      totalAssets += count;
      print('WO #$i: id=${wo['_id']}, woNumber=${wo['woNumber']}, assignedTo=${wo['assignedTo']}, assigendTeam=${wo['assigendTeam']}, assetsCount=$count');
      if (assets is List) {
        for (var a in assets) {
          print('   Asset: id=${a['_id'] ?? a['id']}, tag=${a['eqpmtTag']}, desc=${a['description']}');
        }
      }
    }
    print('TOTAL ASSETS ACROSS ALL WORK ORDERS: $totalAssets');
  }
}
