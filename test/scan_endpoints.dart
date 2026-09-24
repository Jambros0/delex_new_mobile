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
  } catch (e) {
    return {'statusCode': -1, 'body': e.toString()};
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
  final user = jsonDecode(body)['user'] ?? jsonDecode(body)['userDetails'] ?? {};
  final userId = user['_id'] ?? user['id'] ?? user['userId'];
  print('userId: $userId');
  client.close();

  final endpoints = [
    '/offshore/user-work-orders/$userId',
    '/offshore/workorder/assets',
    '/offshore/work-orders',
    '/offshore/workorders',
    '/offshore/assets',
    '/offshore/asset',
    '/offshore/registers',
    '/offshore/ex-register',
    '/offshore/ex-registers',
    '/offshore/exregister',
    '/offshore/work-order-assets',
    '/offshore/workorder-assets',
    '/offshore/workorders/assets',
    '/offshore/assigned-assets',
    '/offshore/user-workorder/$userId',
    '/offshore/work-order/WO-123',
    '/offshore/work-orders/6aacbdabb2bd957ea880ccad',
    '/workorder/assets',
    '/work-orders',
  ];

  for (final ep in endpoints) {
    final r = await httpGet('$baseUrl$ep', token);
    if (r['statusCode'] == 200 || r['statusCode'] == 201) {
      try {
        final d = jsonDecode(r['body']);
        int len = -1;
        if (d is List) len = d.length;
        else if (d is Map) {
          final l = d['data'] ?? d['workOrders'] ?? d['assets'] ?? d['result'];
          if (l is List) len = l.length;
        }
        print('SUCCESS: $ep (len: $len)');
      } catch (_) {
        print('SUCCESS: $ep (raw text)');
      }
    } else {
      print('FAIL ${r['statusCode']}: $ep');
    }
  }
}
