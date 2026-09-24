import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('check users and companies', () async {
    final loginRes = await http.post(
      Uri.parse('http://94.136.185.87:16000/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': 'mobile_onshore', 'password': 'Test@123'}),
    );
    final token = jsonDecode(loginRes.body)['accessToken'];
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

    final usersRes = await http.get(Uri.parse('http://94.136.185.87:16000/admin/users'), headers: headers);
    print('Users status: ${usersRes.statusCode}');
    final dynamic uData = jsonDecode(usersRes.body);
    print('uData type: ${uData.runtimeType}');
    if (uData is Map) {
      print('uData keys: ${uData.keys}');
      for (var k in uData.keys) {
        if (uData[k] is List) {
          print('Key $k has ${(uData[k] as List).length} items');
          for (var item in (uData[k] as List)) {
            if (item is Map) {
              print('  User: id=${item['_id']}, name=${item['userName'] ?? item['username']}, email=${item['email']}, role=${item['role']}');
            }
          }
        }
      }
    }
  });
}
