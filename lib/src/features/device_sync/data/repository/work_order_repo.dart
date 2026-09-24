import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';

class WorkOrderRepository {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();

  Future<void> insertWorkOrderAsset(Map<String, dynamic> workOrder) async {
    try {
      final String? userType = await authUtils.getUserType();
      (userType?.toLowerCase() == 'onshore')
          ? await _dbHelper.saveWorkOrderAssetOnshore(workOrder)
          : await _dbHelper.saveWorkOrderAsset(workOrder);
    } catch (e) {
      throw Exception("Failed to insert work order asset: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getWorkOrderAssets() async {
    final String? userType = await authUtils.getUserType();
    return (userType?.toLowerCase() == 'onshore')
        ? await _dbHelper.getWorkOrderAssetsOnshore()
        : await _dbHelper.getWorkOrderAssets();
  }
}
