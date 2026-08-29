import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DropdownRepository {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();

  Future<void> checkDailySync(
      Future<Map<String, dynamic>> Function() apiCall) async {
    try {
      final String? userType = await authUtils.getUserType();
      final localData = (userType == 'onshore')
          ? await _dbHelper.getDropDownDataOnShore()
          : await _dbHelper.getDropDownData();
      if (localData == null) {
        await _syncWithAPI(apiCall);
      } else {
        if (kIsWeb) {
          // Force update local mock data on Web to keep it fresh
          await _syncWithAPI(apiCall);
        } else {
          final apiData = await apiCall();
          final latestLocationUpdatedAt =
              apiData['result']['locationDropDown'][0]['updatedAt'] ?? '';
          final latestExRegisterUpdatedAt =
              apiData['result']['exResiterDropDown'][0]['updatedAt'] ?? '';
          final localUpdatedAt = localData['updated_at'] ?? '';
          if (_isNewer(latestLocationUpdatedAt, localUpdatedAt) ||
              _isNewer(latestExRegisterUpdatedAt, localUpdatedAt)) {
            await _syncWithAPI(apiCall);
          }
        }
      }
    } catch (e) {
      // Ignored: silently handle token refresh failures or network errors during background sync
      print('Background sync failed: $e');
    }
  }

  Future<Map<String, dynamic>?> getLocalDropDownData() async {
    final String? userType = await authUtils.getUserType();
    final localData = (userType == 'onshore')
        ? await _dbHelper.getDropDownDataOnShore()
        : await _dbHelper.getDropDownData();
    if (localData == null) {
      throw Exception(
          'No local data found. Please connect to the network to sync data.');
    }
    return localData;
  }

  Future<void> _syncWithAPI(
      Future<Map<String, dynamic>> Function() apiCall) async {
    Map<String, dynamic> apiData;
    if (kIsWeb) {
      apiData = {
        'status': true,
        'message': 'Success',
        'result': {
          'locationDropDown': [
            {
              'locationDropDown': [
                {
                  'name': 'Abu Al Bukhoosh',
                  'platforms': [
                    {
                      'platformName': 'AB-Platform-1',
                      'area': ['Main Deck', 'Cellar Deck', 'Mezzanine Deck']
                    },
                    {
                      'platformName': 'AB-Platform-2',
                      'area': ['Main Deck']
                    }
                  ]
                },
                {
                  'name': 'Fateh Field',
                  'platforms': [
                    {
                      'platformName': 'FF-Platform-A',
                      'area': ['Upper Deck', 'Lower Deck']
                    }
                  ]
                }
              ]
            }
          ],
          'exResiterDropDown': [
            {
              'zone': ['Zone 1', 'Zone 2', 'Zone 21', 'Zone 22'],
              'gasGroup': ['IIA', 'IIB', 'IIC'],
              'temperatureClass': ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
              'ipRating': ['IP54', 'IP55', 'IP65', 'IP66', 'IP67']
            }
          ]
        }
      };
    } else {
      apiData = await apiCall();
    }
    final locationDropDown =
        apiData['result']['locationDropDown'] as List<dynamic>;
    final exResiterDropDown =
        apiData['result']['exResiterDropDown'] as List<dynamic>;

    String latestCreatedBy = '';
    String latestUpdatedBy = '';
    String latestUpdatedAt = '';

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (locationDropDown.isNotEmpty) {
      final firstLocation = locationDropDown[0];
      latestCreatedBy = firstLocation['createdBy'] ?? userId;
      latestUpdatedBy = (firstLocation['updatedBy']?.isNotEmpty == true
              ? firstLocation['updatedBy']
              : firstLocation['createdBy']) ??
          userId;
      latestUpdatedAt = firstLocation['updatedAt'] ?? '';
    }
    if (exResiterDropDown.isNotEmpty) {
      final firstExRegister = exResiterDropDown[0];
      if (_isNewer(firstExRegister['updatedAt'], latestUpdatedAt)) {
        latestCreatedBy = firstExRegister['createdBy']?.isNotEmpty == true
            ? firstExRegister['createdBy']
            : userId;
        latestUpdatedBy = (firstExRegister['updatedBy']?.isNotEmpty == true
                ? firstExRegister['updatedBy']
                : firstExRegister['createdBy']) ??
            userId;
        latestUpdatedAt = firstExRegister['updatedAt'] ?? '';
      }
    }

    final dataToSave = {
      'locationDropDown': locationDropDown,
      'exResiterDropDown': exResiterDropDown,
      'created_by': latestCreatedBy,
      'updated_by': latestUpdatedBy,
      'updated_at': latestUpdatedAt,
    };

    final String? userType = await authUtils.getUserType();
    (userType == 'onshore')
        ? await _dbHelper.saveOnshoreDropDownData(dataToSave, isSynced: true)
        : await _dbHelper.saveDropDownData(dataToSave, isSynced: true);
  }

  bool _isNewer(String? apiDate, String? localDate) {
    if (apiDate == null || localDate == null) return false;
    return DateTime.parse(apiDate).isAfter(DateTime.parse(localDate));
  }
}
