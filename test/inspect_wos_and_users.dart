import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('inspect work orders', () async {
    final loginRes = await http.post(
      Uri.parse('http://94.136.185.87:16000/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': 'mobile_onshore', 'password': 'Test@123'}),
    );
    print('Login body: ${loginRes.body}');
    final loginData = jsonDecode(loginRes.body);
    final token = loginData['accessToken'];
    final userId = loginData['user'] != null ? loginData['user']['_id'] : loginData['id'] ?? '6ab0d7c769bbfa6fbed32d6f';
    print('User id: $userId');
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final usersRes = await http.get(Uri.parse('http://94.136.185.87:16000/admin/users'), headers: headers);
    final uData = jsonDecode(usersRes.body);
    final users = (uData['data'] ?? uData['users'] ?? uData['result']) as List? ?? [];
    print('Users count: ${users.length}');
    for (var u in users) {
      print('User: id=${u['_id']}, name=${u['userName'] ?? u['username']}, email=${u['email']}, org=${u['org']}');
    }

    final uwoRes = await http.get(Uri.parse('http://94.136.185.87:16000/onshore/user-work-orders/$userId'), headers: headers);
    print('\n--- /onshore/user-work-orders/$userId (status: ${uwoRes.statusCode}) ---');
    final uwoData = jsonDecode(uwoRes.body);
    print('uwoData keys: ${uwoData.keys}');
    print('uwoData data: ${uwoData['data']}');
    final uwoList = uwoData['data'] as List? ?? [];
    print('uwo count: ${uwoList.length}');
    for (var w in uwoList) {
      print('UWO: ${w['woNumber']} (${w['_id']}), assignedTo: ${w['assignedTo']}, assets: ${(w['assets'] as List?)?.length}');
      for (var a in (w['assets'] as List? ?? [])) {
        print('  Asset: ${a['_id'] ?? a['id']}, tag: ${a['eqpmtTag']}');
      }
    }

    final woAssetsRes = await http.get(Uri.parse('http://94.136.185.87:16000/onshore/workorder/assets'), headers: headers);
    final data = jsonDecode(woAssetsRes.body);
    final list = data['data'] as List;
    for (var w in list) {
      print('=== WO JSON for ${w['woNumber']} ===');
      final mapCopy = Map<String, dynamic>.from(w);
      mapCopy.remove('assets');
      mapCopy.remove('assignedAssets');
      print(jsonEncode(mapCopy));
    }
  });
}
