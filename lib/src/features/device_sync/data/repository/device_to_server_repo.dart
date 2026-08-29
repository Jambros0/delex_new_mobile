import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';

class DeviceToServerRepo {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();

  Future<void> insertOrUpdateDeviceToServer(Map<String, dynamic> data) async {
    try {
      final assetId = data['assetId'];
      final functionality = data['functionality'];
      final String? userType = await authUtils.getUserType();
      final existingRecord = (userType == 'onshore')
          ? await _dbHelper.getMobileSyncServerOnshore(assetId, functionality)
          : await _dbHelper.getMobileSyncServer(assetId, functionality);
      if (existingRecord != null) {
        (userType == 'onshore')
            ? await _dbHelper.updateMobileSyncServerOnshore(
                data, assetId, functionality)
            : await _dbHelper.updateMobileSyncServer(
                data, assetId, functionality);
      } else {
        (userType == 'onshore')
            ? await _dbHelper.saveMobileSyncServerOnshore(data)
            : await _dbHelper.saveMobileSyncServer(data);
      }
    } catch (e) {
    
      throw Exception("Failed to sync assets to server: $e");
    }
  }
}
