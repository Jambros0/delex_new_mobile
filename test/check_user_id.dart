import 'dart:convert';
import 'dart:io';

void main() async {
  const baseUrl = 'http://94.136.185.87:16000';
  final client = HttpClient();
  final req = await client.postUrl(Uri.parse('$baseUrl/admin/login'));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode({'username': 'mobile_offshore', 'password': 'Test@123'}));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  final token = jsonDecode(body)['accessToken'];
  client.close();

  final client2 = HttpClient();
  final ureq = await client2.getUrl(Uri.parse('$baseUrl/admin/users'));
  ureq.headers.set('Authorization', 'Bearer $token');
  final ures = await ureq.close();
  final ubody = await ures.transform(utf8.decoder).join();
  if (ures.statusCode == 200) {
    final d = jsonDecode(ubody);
    final users = d is List ? d : (d['data'] ?? d['users'] ?? []);
    for (var u in users) {
      if (u['_id'] == '6ab0d81469bbfa6fbed32dac' || u['userName'] == 'mobile_offshore') {
        print('User: ${u['_id']} | ${u['userName']} | ${u['fullName']} | ${u['email']}');
      }
    }
  } else {
    print('Users status: ${ures.statusCode}');
  }
  client2.close();
}
