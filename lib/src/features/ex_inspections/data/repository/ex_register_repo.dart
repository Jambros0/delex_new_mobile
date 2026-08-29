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
    final List<Map<String, dynamic>> allRegisters = (userType == 'onshore')
        ? await _dbHelper.getExRegisterOnshore()
        : await _dbHelper.getExRegister();
    for (var reg in allRegisters) {
      Map<String, dynamic> jsonData = jsonDecode(reg['exregister_json']);
      if (jsonData['asset'] != null && jsonData['asset']['_id'] == assetId) {
        return reg;
      }
    }
    return null;
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
        final exregisterJson = result['exregister_json'] as String;
        final jsonMap = jsonDecode(exregisterJson);

        if (jsonMap.containsKey('asset')) {
          final assetDetails = jsonMap['asset'];
          return {
            'status': true,
            'assetDetails': assetDetails,
          };
        } else {
          return {
            'status': false,
            'message': 'Asset data not found',
          };
        }
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
      // Map<String, dynamic> functionalAreaMap = {
      //   'location': asset.location,
      //   'area': asset.area,
      //   'deckLevel': asset.deckLevel,
      //   'subArea': asset.subArea,
      //   'zone': asset.zone,
      //   'locationGasGroup': asset.locationGasGroup,
      //   'locationTClass': asset.locationTClass,
      //   'locationIpRating': asset.locationIpRating,
      //   'tAmbient': asset.locationTAmbient,
      //   'areaClassDrawAttach': asset.areaClassDrawAttach,
      //   'areaClassDrawNo': asset.areaClassDrawNo,
      //   'areaClassDrawAttachOrgName': asset.areaClassDrawAttachOrgName,
      //   'eqpmtLytDrawAttach': asset.eqpmtLytDrawAttach,
      //   'eqpmtLytDrawNo': asset.eqpmtLytDrawNo,
      //   'eqpmtLytDrawAttachOrgName': asset.eqpmtLytDrawAttachOrgName,
      //   'locationLatitude': asset.locationLatitude,
      //   'locationLongitude': asset.locationLongitude,
      //   'isActive': asset.isActive,
      // };

      // Map<String, dynamic> functionalAreaJson = {
      //   'functional_area_json': jsonEncode({'location': functionalAreaMap}),
      // };
      final String? userType = await authUtils.getUserType();
      // final String? locationId = (userType == 'onshore')
      //     ? await _dbHelper.saveFunctionalAreaOnshore(functionalAreaJson)
      //     : await _dbHelper.saveFunctionalArea(functionalAreaJson);
      final String? locationId =
          (userType == 'onshore') ? asset.locationId : asset.locationId;
      if (locationId != null) {
        asset.locationId = locationId;
        asset.isDuplicate = true;
        Map<String, dynamic> assetMap = asset.toJson();
        Map<String, dynamic> exRegisterJson = {
          'exregister_json': jsonEncode({'asset': assetMap})
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
