import 'dart:convert';
import 'dart:io';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  dotenv.testLoad(fileInput: 'API_URL=http://94.136.185.87:16000\n');
  const baseUrl = 'http://94.136.185.87:16000';
  final client = HttpClient();
  final req = await client.postUrl(Uri.parse('$baseUrl/admin/login'));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode({'username': 'mobile_offshore', 'password': 'Test@123'}));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  final data = jsonDecode(body);
  final token = data['accessToken'];
  final user = data['user'] ?? data['userDetails'] ?? {};
  final userId = user['_id'] ?? user['id'] ?? user['userId'];
  final userType = user['userType'] ?? 'offshore';

  print('Logged in user: $userId, type: $userType');
  client.close();

  // Test what authUtils or SharedPreferences has if any
  // But let's check fetchWorkOrderAssets
}
