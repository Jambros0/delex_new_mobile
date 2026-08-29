import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter/foundation.dart';

class InspectionChecklistRepo {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();

  Future<void> checkDailyChecklistSync(
      Future<Map<String, dynamic>> Function() apiCall) async {
    final String? userType = await authUtils.getUserType();
    final localData = (userType == 'onshore')
        ? await _dbHelper.getChecklistDataOnshore()
        : await _dbHelper.getChecklistData();
    if (localData == null || kIsWeb) {
      await _syncChecklistWithAPI(apiCall);
    } else {
      await _syncChecklistWithAPI(apiCall);
    }
  }

  Future<Map<String, dynamic>?> getLocalChecklistData() async {
    final String? userType = await authUtils.getUserType();
    final localData = (userType == 'onshore')
        ? await _dbHelper.getChecklistDataOnshore()
        : await _dbHelper.getChecklistData();
    if (localData == null) {
      throw Exception(
          'No local checklist data found. Please connect to the network to sync data.');
    }
    return {
      'checkLists': localData['checkLists'],
      'checkListDetails': localData['checkListDetails'],
    };
  }

  Future<void> _syncChecklistWithAPI(
      Future<Map<String, dynamic>> Function() apiCall) async {
    Map<String, dynamic> apiData;
    if (kIsWeb) {
      apiData = {
        'checkLists': [
          {
            'defectCategory': '1',
            'checklistName': 'Equipment Approved Type'
          },
          {
            'defectCategory': '2',
            'checklistName': 'Installation & Seals'
          }
        ],
        'checkListDetails': [
          {
            'defectCategory': '1',
            'defectCode': 'A1',
            'checkListGroup': 'Is equipment of approved type?'
          },
          {
            'defectCategory': '1',
            'defectCode': 'A2',
            'checkListGroup': 'Are certification labels intact and legible?'
          },
          {
            'defectCategory': '2',
            'defectCode': 'B1',
            'checkListGroup': 'Are cable entries and seals tight?'
          }
        ]
      };
    } else {
      apiData = await apiCall();
    }
    final UserDetails? loggedInUser = await _dbHelper.getLoggedInUser();
    final userId = loggedInUser?.userId;
    final dataToSave = {
      'checkLists': apiData['checkLists'],
      'checkListDetails': apiData['checkListDetails'],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'created_by': userId,
      'updated_by': userId,
    };
    final String? userType = await authUtils.getUserType();
    (userType == 'onshore')
        ? await _dbHelper.saveInspectionChecklistOnshore(dataToSave)
        : await _dbHelper.saveInspectionChecklist(dataToSave);
  }
}
