import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';

class FunctionalAreaRepository {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();

  Future<Map<String, dynamic>> insertFunctionalArea(
      Map<String, dynamic> functionalArea) async {
    try {
      final String? userType = await authUtils.getUserType();
      String? locationId = (userType == 'onshore')
          ? await _dbHelper.saveFunctionalAreaOnshore(functionalArea)
          : await _dbHelper.saveFunctionalArea(functionalArea);
      return {
        'status': true,
        'msg': 'Location Added Successfully',
        'data': {'locationId': locationId ?? ''}
      };
    } catch (e) {
      throw Exception("Failed to insert Area Detail: $e");
    }
  }

  Future<void> updateFunctionalArea(Map<String, dynamic> functionalArea) async {
    try {
      final String? userType = await authUtils.getUserType();
      (userType == 'onshore')
          ? await _dbHelper
              .updateFunctionalAreaAndExRegistersOnshore(functionalArea)
          : await _dbHelper.updateFunctionalAreaAndExRegisters(functionalArea);
    } catch (e) {
      throw Exception("Failed to update Area Detail: $e");
    }
  }
}
