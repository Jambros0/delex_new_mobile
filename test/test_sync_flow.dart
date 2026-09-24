import 'dart:convert';
import 'dart:io';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('offshore fetch and filter', () async {
    dotenv.testLoad(fileInput: 'API_URL=http://94.136.185.87:16000\n');
    SharedPreferences.setMockInitialValues({});

    final client = HttpClient();
    final req = await client.postUrl(Uri.parse('http://94.136.185.87:16000/admin/login'));
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode({'username': 'mobile_offshore', 'password': 'Test@123'}));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    final data = jsonDecode(body);
    final token = data['accessToken'];
    final user = data['user'];
    final userId = user['_id'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    await prefs.setString('refreshToken', data['refreshToken']);
    await prefs.setString('userId', userId);
    await prefs.setString('userType', 'offshore');
    await prefs.setString('username', 'mobile_offshore');
    client.close();

    final service = DeviceSyncServices();
    final result = await service.fetchWorkOrderAssets(userId: userId);

    final List<ExRegister> rawAssets = result['assets'] as List<ExRegister>;
    final List<WorkOrderTableJson> rawWos = result['work_order'] as List<WorkOrderTableJson>;

    final bloc = DeviceSyncBloc(deviceSyncServices: service, authUtils: AuthUtils());
    // We can test filtering with the bloc
    print('Raw WOs: ${rawWos.length}');
    for (var w in rawWos) {
      print('  WO: ${w.woNumber}, assignedTo="${w.assignedTo}", assets count: ${w.assets.length}');
      for (var a in w.assets) {
        print('    Asset in WO: ${a.id} | ${a.location} | inspectedBy="${a.inspectedBy}" assignedTo="${a.assignedTo}"');
      }
    }
  });
}
