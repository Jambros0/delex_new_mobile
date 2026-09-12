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

  Map<String, dynamic> sortDropdownData(Map<String, dynamic> data) {
    final Map<String, dynamic> sorted = {};
    data.forEach((key, value) {
      if (value is List) {
        if (value.isNotEmpty && value.first is String) {
          final stringList = List<String>.from(value.map((e) => e.toString()));
          stringList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          sorted[key] = stringList;
        } else if (value.isNotEmpty && value.first is Map) {
          final sortedMapList = value.map((item) {
            if (item is Map<String, dynamic>) {
              return sortDropdownData(item);
            } else if (item is Map) {
              return sortDropdownData(Map<String, dynamic>.from(item));
            }
            return item;
          }).toList();

          if (key == 'locationDropDown') {
            sortedMapList.sort((a, b) {
              final nameA = (a is Map ? (a['name'] ?? a['location'] ?? '') : '').toString().toLowerCase();
              final nameB = (b is Map ? (b['name'] ?? b['location'] ?? '') : '').toString().toLowerCase();
              return nameA.compareTo(nameB);
            });
          } else if (key == 'platforms') {
            sortedMapList.sort((a, b) {
              final nameA = (a is Map ? (a['platformName'] ?? a['subLocation'] ?? '') : '').toString().toLowerCase();
              final nameB = (b is Map ? (b['platformName'] ?? b['subLocation'] ?? '') : '').toString().toLowerCase();
              return nameA.compareTo(nameB);
            });
          }
          sorted[key] = sortedMapList;
        } else {
          sorted[key] = value;
        }
      } else if (value is Map<String, dynamic>) {
        sorted[key] = sortDropdownData(value);
      } else if (value is Map) {
        sorted[key] = sortDropdownData(Map<String, dynamic>.from(value));
      } else {
        sorted[key] = value;
      }
    });
    return sorted;
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
    return sortDropdownData(localData);
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
              'zone': [
                'Zone 0',
                'Zone 1',
                'Zone 2',
                'Zone 20',
                'Zone 21',
                'Zone 22',
                'Class 1 Div 1',
                'Class 1 Div 2',
                'Class 2 Div 1',
                'Class 2 Div 2',
                'Class 3 Div 1',
                'Class 3 Div 2',
                'Safe Area',
                'Unclassified'
              ],
              'gasGroup': [
                'I',
                'IIA',
                'IIB',
                'IIC',
                'IIIA',
                'IIIB',
                'IIIC',
                'Group A',
                'Group B',
                'Group C',
                'Group D',
                'Group E',
                'Group F',
                'Group G',
                'Not Applicable'
              ],
              'temperatureClass': [
                'T1',
                'T2',
                'T2A',
                'T2B',
                'T2C',
                'T2D',
                'T3',
                'T3A',
                'T3B',
                'T3C',
                'T4',
                'T4A',
                'T5',
                'T6',
                'Not Applicable'
              ],
              'ipRating': [
                'IP54',
                'IP55',
                'IP56',
                'IP65',
                'IP66',
                'IP67',
                'IP68',
                'Not Applicable'
              ],
              'areaStatus': ['Active', 'In Active'],
              'discipline': ['Electrical', 'Instrumentation', 'Mechanical'],
              'equipementDescription': [
                'Others',
                'Junction Box',
                'Motor',
                'Control Station',
                'Luminaire / Light Fitting',
                'Socket Outlet',
                'Switch / Disconnector',
                'Transmitter / Sensor',
                'Solenoid Valve',
                'Cable Gland',
                'Enclosure',
                'Panel / DB'
              ],
              'equipmentCategory': [
                'Others',
                'Category 1',
                'Category 2',
                'Category 3',
                'M1',
                'M2',
                'Not Applicable'
              ],
              'atexCategory': [
                '1G',
                '2G',
                '3G',
                '1D',
                '2D',
                '3D',
                'M1',
                'M2',
                'Not Applicable'
              ],
              'epl': [
                'Ga',
                'Gb',
                'Gc',
                'Da',
                'Db',
                'Dc',
                'Ma',
                'Mb',
                'Class I, Div 1',
                'Class I, Div 2',
                'Class II, Div 1',
                'Class II, Div 2',
                'Class III, Div 1',
                'Class III, Div 2',
                'Not Applicable'
              ],
              'protectionType': [
                'Ex d',
                'Ex db',
                'Ex e',
                'Ex eb',
                'Ex ec',
                'Ex ia',
                'Ex ib',
                'Ex ic',
                'Ex m',
                'Ex ma',
                'Ex mb',
                'Ex mc',
                'Ex nA',
                'Ex nC',
                'Ex nR',
                'Ex o',
                'Ex ob',
                'Ex oc',
                'Ex p',
                'Ex px',
                'Ex py',
                'Ex pz',
                'Ex pxb',
                'Ex pyb',
                'Ex pzc',
                'Ex q',
                'Ex qb',
                'Ex s',
                'Ex op is',
                'Ex op pr',
                'Ex op sh',
                'Ex ta',
                'Ex tb',
                'Ex tc',
                'Ex ia D',
                'Ex ib D',
                'Ex ma D',
                'Ex mb D',
                'Ex pD',
                'Ex tD',
                'Explosionproof (XP)',
                'Dust-Ignitionproof (DIP)',
                'Intrinsically Safe (IS)',
                'Non-Incendive (NI)',
                'Purged/Pressurized (Type X)',
                'Purged/Pressurized (Type Y)',
                'Purged/Pressurized (Type Z)',
                'Not Applicable',
                'Others'
              ],
              'specialCondition': [
                'None',
                'X - Specific Condition',
                'U - Ex Component',
                'Not Applicable'
              ],
              'protectionStandard': [
                {
                  'IEC / ATEX': {
                    'atexCategory': [
                      '1G',
                      '2G',
                      '3G',
                      '1D',
                      '2D',
                      '3D',
                      'M1',
                      'M2',
                      'Not Applicable'
                    ],
                    'epl': [
                      'Ga',
                      'Gb',
                      'Gc',
                      'Da',
                      'Db',
                      'Dc',
                      'Ma',
                      'Mb',
                      'Not Applicable'
                    ],
                    'protectionType': [
                      'Ex d',
                      'Ex db',
                      'Ex e',
                      'Ex eb',
                      'Ex ec',
                      'Ex ia',
                      'Ex ib',
                      'Ex ic',
                      'Ex m',
                      'Ex ma',
                      'Ex mb',
                      'Ex mc',
                      'Ex nA',
                      'Ex nC',
                      'Ex nR',
                      'Ex o',
                      'Ex ob',
                      'Ex oc',
                      'Ex p',
                      'Ex px',
                      'Ex py',
                      'Ex pz',
                      'Ex pxb',
                      'Ex pyb',
                      'Ex pzc',
                      'Ex q',
                      'Ex qb',
                      'Ex s',
                      'Ex op is',
                      'Ex op pr',
                      'Ex op sh',
                      'Ex ta',
                      'Ex tb',
                      'Ex tc',
                      'Ex ia D',
                      'Ex ib D',
                      'Ex ma D',
                      'Ex mb D',
                      'Ex pD',
                      'Ex tD',
                      'Not Applicable',
                      'Others'
                    ],
                    'gasGroup': [
                      'I',
                      'IIA',
                      'IIB',
                      'IIC',
                      'IIIA',
                      'IIIB',
                      'IIIC',
                      'Not Applicable'
                    ],
                    'temperatureClass': [
                      'T1',
                      'T2',
                      'T3',
                      'T4',
                      'T5',
                      'T6',
                      'Not Applicable'
                    ]
                  },
                  'NEC / CEC': {
                    'atexCategory': ['Not Applicable'],
                    'epl': [
                      'Class I, Div 1',
                      'Class I, Div 2',
                      'Class II, Div 1',
                      'Class II, Div 2',
                      'Class III, Div 1',
                      'Class III, Div 2',
                      'Zone 0',
                      'Zone 1',
                      'Zone 2',
                      'Zone 20',
                      'Zone 21',
                      'Zone 22',
                      'Ga',
                      'Gb',
                      'Gc',
                      'Da',
                      'Db',
                      'Dc',
                      'Not Applicable'
                    ],
                    'protectionType': [
                      'Explosionproof (XP)',
                      'Dust-Ignitionproof (DIP)',
                      'Intrinsically Safe (IS)',
                      'Non-Incendive (NI)',
                      'Purged/Pressurized (Type X)',
                      'Purged/Pressurized (Type Y)',
                      'Purged/Pressurized (Type Z)',
                      'Oil-Immersed',
                      'Hermetically Sealed',
                      'Encapsulated',
                      'Class I, Div 1',
                      'Class I, Div 2',
                      'Class II, Div 1',
                      'Class II, Div 2',
                      'Class III',
                      'Not Applicable',
                      'Others'
                    ],
                    'gasGroup': [
                      'Group A',
                      'Group B',
                      'Group C',
                      'Group D',
                      'Group E',
                      'Group F',
                      'Group G',
                      'Class I (A, B, C, D)',
                      'Class II (E, F, G)',
                      'Class III',
                      'Not Applicable'
                    ],
                    'temperatureClass': [
                      'T1',
                      'T2',
                      'T2A',
                      'T2B',
                      'T2C',
                      'T2D',
                      'T3',
                      'T3A',
                      'T3B',
                      'T3C',
                      'T4',
                      'T4A',
                      'T5',
                      'T6',
                      'Not Applicable'
                    ]
                  },
                  'Not Applicable': {
                    'atexCategory': ['Not Applicable'],
                    'epl': ['Not Applicable'],
                    'protectionType': ['Not Applicable'],
                    'gasGroup': ['Not Applicable'],
                    'temperatureClass': ['Not Applicable']
                  },
                  'Not Available': {
                    'atexCategory': ['Not Available', 'Not Applicable'],
                    'epl': ['Not Available', 'Not Applicable'],
                    'protectionType': ['Not Available', 'Not Applicable'],
                    'gasGroup': ['Not Available', 'Not Applicable'],
                    'temperatureClass': ['Not Available', 'Not Applicable']
                  }
                }
              ]
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
