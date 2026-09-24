import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> httpGet(String url, String token) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('Authorization', 'Bearer $token');
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    return {'statusCode': response.statusCode, 'body': responseBody};
  } finally {
    client.close();
  }
}

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

  final r = await httpGet('$baseUrl/offshore/assets?limit=10', token);
  final d = jsonDecode(r['body']);
  final assets = d['data']['assets'] as List;
  for (int i = 0; i < assets.length; i++) {
    final a = assets[i];
    print('$i: id=${a['_id']} desc=${a['description']} loc=${a['location']} area=${a['area']} woNumber=${a['woNumber']} assignedTo=${a['assignedTo']} createdBy=${a['createdBy']}');
  }
}
