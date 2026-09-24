import 'dart:convert';
import 'dart:io';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';

void main() async {
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
  final userName = user['userName'] ?? user['username'] ?? 'mobile_offshore';
  final email = user['email'] ?? '';
  final firstName = user['firstName'] ?? '';
  final lastName = user['lastName'] ?? '';

  print('userId: $userId');
  print('userName: $userName');
  print('email: $email');
  print('name: $firstName $lastName');

  final ureq = await client.getUrl(Uri.parse('$baseUrl/offshore/user-work-orders/$userId'));
  ureq.headers.set('Authorization', 'Bearer $token');
  final ures = await ureq.close();
  final ubody = await ures.transform(utf8.decoder).join();
  final udata = jsonDecode(ubody);
  final collections = udata['data'] as List;

  List<ExRegister> rawAssets = [];
  List<WorkOrderTableJson> rawWos = [];
  for (var c in collections) {
    rawWos.add(WorkOrderTableJson.fromJson(Map<String, dynamic>.from(c)));
    for (var a in c['assignedAssets']) {
      rawAssets.add(ExRegister.fromJson(Map<String, dynamic>.from(a)));
    }
  }

  print('\nRaw assets count: ${rawAssets.length}');
  for (var a in rawAssets) {
    print('Raw Asset: id=${a.id} assignedTo="${a.assignedTo}" inspectedId="${a.inspectedId}" inspectedBy="${a.inspectedBy}" createdBy="${a.createdBy}"');
  }

  print('\nRaw WOs count: ${rawWos.length}');
  for (var w in rawWos) {
    print('Raw WO: id=${w.id} woNumber=${w.woNumber} assignedTo="${w.assignedTo}" userId="${w.userId}" assets=${w.assets.length}');
    for (var a in w.assets) {
      print('   WO Asset: id=${a.id} assignedTo="${a.assignedTo}" inspectedId="${a.inspectedId}"');
    }
  }

  client.close();
}
