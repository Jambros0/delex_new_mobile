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

  final testPaths = [
    '/onshore/workorders',
    '/onshore/workOrders',
    '/onshore/work-order/all',
    '/onshore/workorder/all',
    '/onshore/work-orders/all',
    '/onshore/workorders/assets',
    '/onshore/work-order-assets',
    '/onshore/workorder-assets',
    '/onshore/assets-to-sync',
    '/onshore/device-sync',
    '/onshore/sync-device',
    '/onshore/sync',
    '/onshore/assets?limit=100',
    '/onshore/exregister?limit=100',
    '/work-order-assets',
    '/workorder/fetchAssets',
    '/onshore/workorder/fetchAssets',
  ];

  for (final p in testPaths) {
    try {
      final res = await http.get(Uri.parse('http://94.136.185.87:16000$p'), headers: headers);
      print('$p => ${res.statusCode}');
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        print('   $p keys: ${d.keys.toList()}, total: ${d['total']}');
      }
    } catch (e) {
      print('$p => err: $e');
    }
  }
}
