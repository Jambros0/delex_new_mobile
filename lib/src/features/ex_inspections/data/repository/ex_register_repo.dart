import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/assets_duplicate.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';

class ExregisterRepo {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();

  Future<Map<String, dynamic>> insertExRegister(
      Map<String, dynamic> exRegister) async {
    try {
      final String? userType = await authUtils.getUserType();
      String? assetId = (userType == 'onshore')
          ? await _dbHelper.saveExRegisterOnshore(exRegister)
          : await _dbHelper.saveExRegister(exRegister);
      return {
        'status': true,
        'msg': 'Asset Added Successfully',
        'assetId': assetId
      };
    } catch (e) {
      throw Exception("Failed to insert Area Detail: $e");
    }
  }

  Future<void> updateExRegister(Map<String, dynamic> exRegister) async {
    try {
      final String? userType = await authUtils.getUserType();
      (userType == 'onshore')
          ? await _dbHelper.updateExRegisterByIdOnshore(exRegister)
          : await _dbHelper.updateExRegisterById(exRegister);
    } catch (e) {
      throw Exception("Failed to update ex register: $e");
    }
  }

  Future<Map<String, dynamic>?> getExRegisterByJsonId(String assetId) async {
    final String? userType = await authUtils.getUserType();
    return (userType == 'onshore')
        ? await _dbHelper.getExRegisterByIdOnshore(assetId)
        : await _dbHelper.getExRegisterById(assetId);
  }

  Future<Map<String, dynamic>> deleteAssetById(
      {required String assetId, required List<String> assetIds}) async {
    try {
      final String? userType = await authUtils.getUserType();
      final rowsDeleted = (userType == 'onshore')
          ? await _dbHelper.deleteExRegisterCollectionByIdOnshore(
              assetId, assetIds)
          : await _dbHelper.deleteExRegisterCollectionById(assetId, assetIds);
      if (rowsDeleted > 0) {
        return {'status': true, 'message': 'Asset deleted successfully'};
      } else {
        return {'status': false, 'message': 'No asset found with the given ID'};
      }
    } catch (e) {
      return {'status': false, 'message': 'Error deleting asset: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchAssetById(String assetId) async {
    try {
      final String? userType = await authUtils.getUserType();
      final result = (userType == 'onshore')
          ? await _dbHelper.getExRegisterByIdOnshore(assetId)
          : await _dbHelper.getExRegisterById(assetId);
      if (result != null) {
        final dynamic exregisterJson = result['exregister_json'];
        final jsonMap = (exregisterJson is String)
            ? jsonDecode(exregisterJson)
            : exregisterJson as Map<String, dynamic>;

        final assetDetails = (jsonMap['asset'] is Map)
            ? Map<String, dynamic>.from(jsonMap['asset'])
            : Map<String, dynamic>.from(jsonMap);

        final rowId = result['id'];
        if (rowId != null) {
          assetDetails['primaryId'] =
              rowId is int ? rowId : int.tryParse(rowId.toString());
          assetDetails['_id'] = rowId.toString();
        }

        return {
          'status': true,
          'assetDetails': assetDetails,
        };
      } else {
        return {
          'status': false,
          'message': 'No data found for the given ID',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error fetching asset: $e',
      };
    }
  }

  Future<Map<String, dynamic>> postAsset(
      {required DuplicateAsset asset}) async {
    try {
      final String? userType = await authUtils.getUserType();
      final String? locationId = asset.locationId;
      if (locationId != null) {
        asset.locationId = locationId;
        asset.isDuplicate = true;
        Map<String, dynamic> assetMap = asset.toJson();
        assetMap.remove('_id');
        assetMap.remove('primaryId');
        assetMap.remove('id');
        assetMap['isDuplicate'] = true;

        final String? userId = await authUtils.getUserId();
        Map<String, dynamic> exRegisterJson = {
          'exregister_json': jsonEncode({'asset': assetMap}),
          'created_by': userId,
          'updated_by': userId,
          'created_date': DateTime.now().toIso8601String(),
          'updated_date': DateTime.now().toIso8601String(),
        };

        (userType == 'onshore')
            ? await _dbHelper.saveExRegisterOnshore(exRegisterJson)
            : await _dbHelper.saveExRegister(exRegisterJson);

        return {
          'status': true,
          'message': 'Asset saved successfully!',
        };
      } else {
        throw Exception('Failed to save Area Detail: No locationId returned');
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to save asset: $e',
      };
    }
  }
}
