import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/services/ex_inspection_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';

class DeviceSyncServices {
  Future<Map<String, dynamic>> fetchWorkOrderAssets({
    int limit = 30,
    int offset = 0,
    String? sortField,
    String? sortOrder,
    String? userId,
  }) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    final currentUserId = userId ?? await authUtils.getUserId();

    List<dynamic> extractCollections(Map<String, dynamic> data) {
      final dynamic inner = data['workOrders'] ??
          data['work_orders'] ??
          data['workOrder'] ??
          data['work_order'] ??
          data['data'] ??
          data['result'] ??
          data['assets'];
      if (inner is List) {
        return inner;
      } else if (inner is Map) {
        if (inner['workOrders'] is List) return inner['workOrders'];
        if (inner['work_orders'] is List) return inner['work_orders'];
        if (inner['workOrder'] is List) return inner['workOrder'];
        if (inner['work_order'] is List) return inner['work_order'];
        if (inner['data'] is List) return inner['data'];
        if (inner['assignedAssets'] is List || inner['assets'] is List) return [inner];
        return [inner];
      } else if (data['data'] is List) {
        return data['data'];
      }
      return [];
    }

    Map<String, dynamic>? successfulData;
    List<dynamic> collections = [];
    final String? userType = await authUtils.getUserType();
    final bool isOffshore = userType?.toLowerCase() == 'offshore';

    void mergeIntoCollections(List<dynamic> source) {
      for (var item in source) {
        if (item is Map) {
          final id = (item['_id'] ?? item['id'] ?? item['woNumber'])?.toString().trim();
          if (id != null && id.isNotEmpty) {
            final existingIdx = collections.indexWhere((c) {
              if (c is Map) {
                final cId = (c['_id'] ?? c['id'] ?? c['woNumber'])?.toString().trim();
                return cId == id;
              }
              return false;
            });
            if (existingIdx >= 0) {
              final existingMap = collections[existingIdx] as Map;
              final existingAssets = existingMap['assignedAssets'] ?? existingMap['assets'];
              final newAssets = item['assignedAssets'] ?? item['assets'];
              if (newAssets is List && existingAssets is List) {
                final Set<String> existingAssetIds = existingAssets
                    .whereType<Map>()
                    .map((a) => (a['_id'] ?? a['id'])?.toString().trim() ?? '')
                    .where((s) => s.isNotEmpty)
                    .toSet();
                for (var a in newAssets) {
                  if (a is Map) {
                    final aId = (a['_id'] ?? a['id'])?.toString().trim() ?? '';
                    if (aId.isEmpty || !existingAssetIds.contains(aId)) {
                      existingAssets.add(a);
                    }
                  }
                }
              }
            } else {
              collections.add(item);
            }
          } else {
            collections.add(item);
          }
        } else {
          collections.add(item);
        }
      }
    }

    // 1. Try user-specific work orders if userId is available
    if (currentUserId != null && currentUserId.isNotEmpty) {
      try {
        final res = await HttpUtils.get(
          "/user-work-orders/$currentUserId",
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          useInterceptor: true,
        );
        if (res.statusCode == 200 || res.statusCode == 201) {
          final Map<String, dynamic> d = jsonDecode(res.body);
          final extracted = extractCollections(d);
          if (extracted.isNotEmpty) {
            successfulData = d;
            if (isOffshore) {
              mergeIntoCollections(extracted);
            } else {
              collections = extracted;
            }
          }
        }
      } catch (_) {}
    }

    // 2. Fetch /workorder/assets (always merged for offshore, or fallback for onshore)
    if (isOffshore || collections.isEmpty) {
      try {
        final res = await HttpUtils.get(
          "/workorder/assets",
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          useInterceptor: true,
        );
        if (res.statusCode == 200 || res.statusCode == 201) {
          final Map<String, dynamic> d = jsonDecode(res.body);
          final extracted = extractCollections(d);
          if (extracted.isNotEmpty) {
            successfulData ??= d;
            if (isOffshore) {
              mergeIntoCollections(extracted);
            } else {
              collections = extracted;
            }
          }
        }
      } catch (_) {}
    }

    // 3. Fetch /work-orders (always merged for offshore, or fallback for onshore)
    if (isOffshore || collections.isEmpty) {
      try {
        final res = await HttpUtils.get(
          "/work-orders",
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          useInterceptor: true,
        );
        if (res.statusCode == 200 || res.statusCode == 201) {
          final Map<String, dynamic> d = jsonDecode(res.body);
          final extracted = extractCollections(d);
          if (extracted.isNotEmpty) {
            successfulData ??= d;
            if (isOffshore) {
              mergeIntoCollections(extracted);
            } else {
              collections = extracted;
            }
          }
        }
      } catch (_) {}
    }

    if (collections.isEmpty) {
      return {
        'tableHeaders': <String>[],
        'assets': <ExRegister>[],
        'work_order': <WorkOrderTableJson>[],
        'totalRecords': 0,
      };
    }

    int totalRecords = collections.length;
    if (successfulData != null) {
      if (successfulData['total'] != null) {
        totalRecords = int.tryParse(successfulData['total'].toString()) ?? totalRecords;
      } else if (successfulData['totalRecords'] != null) {
        totalRecords = int.tryParse(successfulData['totalRecords'].toString()) ?? totalRecords;
      }
    }

      final Map<String, Map<String, dynamic>> locationCache = {};

      Future<Map<String, dynamic>?> fetchLocationDataCached(String? locId) async {
        if (locId == null || locId.isEmpty || locId == 'null') return null;
        if (locationCache.containsKey(locId)) return locationCache[locId];
        try {
          final locResponse = await HttpUtils.get(
            "/location/$locId",
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            useInterceptor: true,
          );
          if (locResponse.statusCode == 200) {
            final Map<String, dynamic> locJson = jsonDecode(locResponse.body);
            final locData = (locJson['data'] is Map)
                ? Map<String, dynamic>.from(locJson['data'])
                : (locJson['location'] is Map
                    ? Map<String, dynamic>.from(locJson['location'])
                    : Map<String, dynamic>.from(locJson));
            locationCache[locId] = locData;
            return locData;
          }
        } catch (_) {}
        return null;
      }

      // Extract all assets from all collections
      final List<dynamic> assetsData = [];
      for (final collection in collections) {
        if (collection is Map) {
          final rawAssets = collection['assignedAssets'] ??
              collection['assets'] ??
              collection['asset'] ??
              collection['work_order_assets'] ??
              collection['workOrder_assets'];
          if (rawAssets is List) {
            for (var a in rawAssets) {
              if (a is Map) {
                if ((a['assignedTeam'] == null || a['assignedTeam'].toString().isEmpty || a['assignedTeam'].toString() == 'null') &&
                    (collection['assigendTeam'] ?? collection['assignedTeam']) != null) {
                  a['assignedTeam'] = collection['assigendTeam'] ?? collection['assignedTeam'];
                }
                if ((a['assignedTo'] == null || a['assignedTo'].toString().isEmpty || a['assignedTo'].toString() == 'null') &&
                    (collection['assignedTo'] ?? collection['assigned_to']) != null) {
                  a['assignedTo'] = collection['assignedTo'] ?? collection['assigned_to'];
                }
                if ((a['userId'] == null || a['userId'].toString().isEmpty || a['userId'].toString() == 'null') &&
                    (collection['userId'] ?? collection['user_id']) != null) {
                  a['userId'] = collection['userId'] ?? collection['user_id'];
                }
                if ((a['woNumber'] == null || a['woNumber'].toString().isEmpty || a['woNumber'].toString() == 'null') &&
                    (collection['woNumber'] ?? collection['workOrderNumber']) != null) {
                  a['woNumber'] = collection['woNumber'] ?? collection['workOrderNumber'];
                }
                if ((a['workOrderId'] == null || a['workOrderId'].toString().isEmpty || a['workOrderId'].toString() == 'null') &&
                    collection['_id'] != null) {
                  a['workOrderId'] = collection['_id'];
                }
                if ((a['location'] == null || a['location'].toString().isEmpty)) {
                  a['location'] = collection['fieldName'] ?? collection['location'];
                }
                final subLoc = collection['subLocation'] ?? collection['platform'];
                if (subLoc != null && subLoc.toString().isNotEmpty) {
                  if (a['subLocation'] == null || a['subLocation'].toString().isEmpty) {
                    a['subLocation'] = subLoc;
                  }
                  if (a['platform'] == null || a['platform'].toString().isEmpty) {
                    a['platform'] = subLoc;
                  }
                  if (a['area'] == null || a['area'].toString().isEmpty) {
                    a['area'] = subLoc;
                  }
                  if (a['deckLevel'] == null || a['deckLevel'].toString().isEmpty) {
                    a['deckLevel'] = collection['deckLevel'] ?? collection['area'];
                  }
                } else {
                  if ((a['subLocation'] == null || a['subLocation'].toString().isEmpty)) {
                    a['subLocation'] = collection['subLocation'] ?? collection['platform'];
                  }
                  if ((a['area'] == null || a['area'].toString().isEmpty)) {
                    a['area'] = collection['platform'] ?? collection['area'] ?? collection['subLocation'];
                  }
                  if ((a['deckLevel'] == null || a['deckLevel'].toString().isEmpty)) {
                    a['deckLevel'] = collection['deckLevel'] ?? collection['area'];
                  }
                }
                // Area details inheritance from work order collection
                if (!a.containsKey('locationId') || a['locationId'] == null || a['locationId'].toString().isEmpty) {
                  a['locationId'] = collection['locationId'] ?? collection['functionalAreaId'];
                }
                if (!a.containsKey('subArea') || a['subArea'] == null || a['subArea'].toString().isEmpty) {
                  a['subArea'] = collection['subArea'] ?? collection['nearestLandmark'];
                }
                if (!a.containsKey('locationGasGroup') || a['locationGasGroup'] == null || (a['locationGasGroup'] is List && (a['locationGasGroup'] as List).isEmpty)) {
                  a['locationGasGroup'] = collection['locationGasGroup'] ?? collection['gasGroup'] ?? collection['areaGasGroup'];
                }
                if (!a.containsKey('locationTClass') || a['locationTClass'] == null || (a['locationTClass'] is List && (a['locationTClass'] as List).isEmpty)) {
                  a['locationTClass'] = collection['locationTClass'] ?? collection['tClass'] ?? collection['temperatureClass'];
                }
                if (!a.containsKey('locationIpRating') || a['locationIpRating'] == null || (a['locationIpRating'] is List && (a['locationIpRating'] as List).isEmpty)) {
                  a['locationIpRating'] = collection['locationIpRating'] ?? collection['ipRating'];
                }
                if (!a.containsKey('locationTAmbient') || a['locationTAmbient'] == null || a['locationTAmbient'].toString().isEmpty) {
                  a['locationTAmbient'] = collection['locationTAmbient'] ?? collection['tAmbient'];
                }
                if (!a.containsKey('tAmbient') || a['tAmbient'] == null || a['tAmbient'].toString().isEmpty) {
                  a['tAmbient'] = collection['tAmbient'] ?? collection['locationTAmbient'];
                }
                if (!a.containsKey('locationLatitude') || a['locationLatitude'] == null || a['locationLatitude'].toString().isEmpty) {
                  a['locationLatitude'] = collection['locationLatitude'] ?? collection['latitude'];
                }
                if (!a.containsKey('locationLongitude') || a['locationLongitude'] == null || a['locationLongitude'].toString().isEmpty) {
                  a['locationLongitude'] = collection['locationLongitude'] ?? collection['longitude'];
                }
                if (!a.containsKey('gpsCord') || a['gpsCord'] == null || a['gpsCord'].toString().isEmpty) {
                  a['gpsCord'] = collection['gpsCord'] ?? collection['gpsCoordinates'] ?? collection['gps'];
                }
                if (!a.containsKey('zone') || a['zone'] == null || a['zone'].toString().isEmpty) {
                  a['zone'] = collection['zone'];
                }
                if (!a.containsKey('areaClassDrawNo') || a['areaClassDrawNo'] == null || (a['areaClassDrawNo'] is List && (a['areaClassDrawNo'] as List).isEmpty)) {
                  a['areaClassDrawNo'] = collection['areaClassDrawNo'];
                }
                if (!a.containsKey('areaClassDrawAttach') || a['areaClassDrawAttach'] == null || (a['areaClassDrawAttach'] is List && (a['areaClassDrawAttach'] as List).isEmpty)) {
                  a['areaClassDrawAttach'] = collection['areaClassDrawAttach'];
                }
                if (!a.containsKey('areaClassDrawAttachOrgName') || a['areaClassDrawAttachOrgName'] == null || (a['areaClassDrawAttachOrgName'] is List && (a['areaClassDrawAttachOrgName'] as List).isEmpty)) {
                  a['areaClassDrawAttachOrgName'] = collection['areaClassDrawAttachOrgName'];
                }
                if (!a.containsKey('eqpmtLytDrawNo') || a['eqpmtLytDrawNo'] == null || (a['eqpmtLytDrawNo'] is List && (a['eqpmtLytDrawNo'] as List).isEmpty)) {
                  a['eqpmtLytDrawNo'] = collection['eqpmtLytDrawNo'];
                }
                if (!a.containsKey('eqpmtLytDrawAttach') || a['eqpmtLytDrawAttach'] == null || (a['eqpmtLytDrawAttach'] is List && (a['eqpmtLytDrawAttach'] as List).isEmpty)) {
                  a['eqpmtLytDrawAttach'] = collection['eqpmtLytDrawAttach'];
                }
                if (!a.containsKey('eqpmtLytDrawAttachOrgName') || a['eqpmtLytDrawAttachOrgName'] == null || (a['eqpmtLytDrawAttachOrgName'] is List && (a['eqpmtLytDrawAttachOrgName'] as List).isEmpty)) {
                  a['eqpmtLytDrawAttachOrgName'] = collection['eqpmtLytDrawAttachOrgName'];
                }

                // If location area details are still missing, fetch location from server API
                final locId = a['locationId']?.toString() ??
                    collection['locationId']?.toString() ??
                    collection['functionalAreaId']?.toString();
                final locData = await fetchLocationDataCached(locId);
                if (locData != null) {
                  if (a['subArea'] == null || a['subArea'].toString().isEmpty) {
                    a['subArea'] = locData['subArea'];
                  }
                  if (a['locationGasGroup'] == null || (a['locationGasGroup'] is List && (a['locationGasGroup'] as List).isEmpty)) {
                    a['locationGasGroup'] = locData['locationGasGroup'];
                  }
                  if (a['locationTClass'] == null || (a['locationTClass'] is List && (a['locationTClass'] as List).isEmpty)) {
                    a['locationTClass'] = locData['locationTClass'];
                  }
                  if (a['locationIpRating'] == null || (a['locationIpRating'] is List && (a['locationIpRating'] as List).isEmpty)) {
                    a['locationIpRating'] = locData['locationIpRating'];
                  }
                  if (a['tAmbient'] == null || a['tAmbient'].toString().isEmpty) {
                    a['tAmbient'] = locData['tAmbient'] ?? locData['locationTAmbient'];
                    a['locationTAmbient'] = locData['tAmbient'] ?? locData['locationTAmbient'];
                  }
                  if (a['locationLatitude'] == null || a['locationLatitude'].toString().isEmpty) {
                    a['locationLatitude'] = locData['locationLatitude'];
                  }
                  if (a['locationLongitude'] == null || a['locationLongitude'].toString().isEmpty) {
                    a['locationLongitude'] = locData['locationLongitude'];
                  }
                  if (a['gpsCord'] == null || a['gpsCord'].toString().isEmpty) {
                    a['gpsCord'] = locData['gpsCoordinates'] ?? locData['gpsCord'] ?? locData['gps'];
                  }
                  if (a['areaClassDrawNo'] == null || (a['areaClassDrawNo'] is List && (a['areaClassDrawNo'] as List).isEmpty)) {
                    a['areaClassDrawNo'] = locData['areaClassDrawNo'];
                  }
                  if (a['areaClassDrawAttach'] == null || (a['areaClassDrawAttach'] is List && (a['areaClassDrawAttach'] as List).isEmpty)) {
                    a['areaClassDrawAttach'] = locData['areaClassDrawAttach'];
                  }
                  if (a['areaClassDrawAttachOrgName'] == null || (a['areaClassDrawAttachOrgName'] is List && (a['areaClassDrawAttachOrgName'] as List).isEmpty)) {
                    a['areaClassDrawAttachOrgName'] = locData['areaClassDrawAttachOrgName'] ?? locData['areaClassDrawNo'];
                  }
                  if (a['eqpmtLytDrawNo'] == null || (a['eqpmtLytDrawNo'] is List && (a['eqpmtLytDrawNo'] as List).isEmpty)) {
                    a['eqpmtLytDrawNo'] = locData['eqpmtLytDrawNo'];
                  }
                  if (a['eqpmtLytDrawAttach'] == null || (a['eqpmtLytDrawAttach'] is List && (a['eqpmtLytDrawAttach'] as List).isEmpty)) {
                    a['eqpmtLytDrawAttach'] = locData['eqpmtLytDrawAttach'];
                  }
                  if (a['eqpmtLytDrawAttachOrgName'] == null || (a['eqpmtLytDrawAttachOrgName'] is List && (a['eqpmtLytDrawAttachOrgName'] as List).isEmpty)) {
                    a['eqpmtLytDrawAttachOrgName'] = locData['eqpmtLytDrawAttachOrgName'] ?? locData['eqpmtLytDrawNo'];
                  }
                  if (a['areaStatus'] == null || a['areaStatus'].toString().isEmpty) {
                    a['areaStatus'] = locData['areaStatus'];
                  }
                  collection['subArea'] ??= locData['subArea'];
                  collection['locationGasGroup'] ??= locData['locationGasGroup'];
                  collection['locationTClass'] ??= locData['locationTClass'];
                  collection['locationIpRating'] ??= locData['locationIpRating'];
                  collection['tAmbient'] ??= locData['tAmbient'] ?? locData['locationTAmbient'];
                  collection['locationLatitude'] ??= locData['locationLatitude'];
                  collection['locationLongitude'] ??= locData['locationLongitude'];
                  collection['gpsCoordinates'] ??= locData['gpsCoordinates'] ?? locData['gpsCord'] ?? locData['gps'];
                  collection['areaClassDrawNo'] ??= locData['areaClassDrawNo'];
                  collection['areaClassDrawAttach'] ??= locData['areaClassDrawAttach'];
                  collection['areaClassDrawAttachOrgName'] ??= locData['areaClassDrawAttachOrgName'] ?? locData['areaClassDrawNo'];
                  collection['eqpmtLytDrawNo'] ??= locData['eqpmtLytDrawNo'];
                  collection['eqpmtLytDrawAttach'] ??= locData['eqpmtLytDrawAttach'];
                  collection['eqpmtLytDrawAttachOrgName'] ??= locData['eqpmtLytDrawAttachOrgName'] ?? locData['eqpmtLytDrawNo'];
                }
              }
            }
            assetsData.addAll(rawAssets);
          } else if (rawAssets is Map) {
            if ((rawAssets['assignedTeam'] == null || rawAssets['assignedTeam'].toString().isEmpty || rawAssets['assignedTeam'].toString() == 'null') &&
                (collection['assigendTeam'] ?? collection['assignedTeam']) != null) {
              rawAssets['assignedTeam'] = collection['assigendTeam'] ?? collection['assignedTeam'];
            }
            if ((rawAssets['assignedTo'] == null || rawAssets['assignedTo'].toString().isEmpty || rawAssets['assignedTo'].toString() == 'null') &&
                (collection['assignedTo'] ?? collection['assigned_to']) != null) {
              rawAssets['assignedTo'] = collection['assignedTo'] ?? collection['assigned_to'];
            }
            if ((rawAssets['userId'] == null || rawAssets['userId'].toString().isEmpty || rawAssets['userId'].toString() == 'null') &&
                (collection['userId'] ?? collection['user_id']) != null) {
              rawAssets['userId'] = collection['userId'] ?? collection['user_id'];
            }
            if ((rawAssets['woNumber'] == null || rawAssets['woNumber'].toString().isEmpty || rawAssets['woNumber'].toString() == 'null') &&
                (collection['woNumber'] ?? collection['workOrderNumber']) != null) {
              rawAssets['woNumber'] = collection['woNumber'] ?? collection['workOrderNumber'];
            }
            if ((rawAssets['workOrderId'] == null || rawAssets['workOrderId'].toString().isEmpty || rawAssets['workOrderId'].toString() == 'null') &&
                collection['_id'] != null) {
              rawAssets['workOrderId'] = collection['_id'];
            }
            if ((rawAssets['location'] == null || rawAssets['location'].toString().isEmpty)) {
              rawAssets['location'] = collection['fieldName'] ?? collection['location'];
            }
            final subLoc = collection['subLocation'] ?? collection['platform'];
            if (subLoc != null && subLoc.toString().isNotEmpty) {
              if (rawAssets['subLocation'] == null || rawAssets['subLocation'].toString().isEmpty) {
                rawAssets['subLocation'] = subLoc;
              }
              if (rawAssets['platform'] == null || rawAssets['platform'].toString().isEmpty) {
                rawAssets['platform'] = subLoc;
              }
              if (rawAssets['area'] == null || rawAssets['area'].toString().isEmpty) {
                rawAssets['area'] = subLoc;
              }
              if (rawAssets['deckLevel'] == null || rawAssets['deckLevel'].toString().isEmpty) {
                rawAssets['deckLevel'] = collection['deckLevel'] ?? collection['area'];
              }
            } else {
              if ((rawAssets['subLocation'] == null || rawAssets['subLocation'].toString().isEmpty)) {
                rawAssets['subLocation'] = collection['subLocation'] ?? collection['platform'];
              }
              if ((rawAssets['area'] == null || rawAssets['area'].toString().isEmpty)) {
                rawAssets['area'] = collection['platform'] ?? collection['area'] ?? collection['subLocation'];
              }
              if ((rawAssets['deckLevel'] == null || rawAssets['deckLevel'].toString().isEmpty)) {
                rawAssets['deckLevel'] = collection['deckLevel'] ?? collection['area'];
              }
            }
            if (!rawAssets.containsKey('locationId') || rawAssets['locationId'] == null || rawAssets['locationId'].toString().isEmpty) {
              rawAssets['locationId'] = collection['locationId'] ?? collection['functionalAreaId'];
            }
            if (!rawAssets.containsKey('subArea') || rawAssets['subArea'] == null || rawAssets['subArea'].toString().isEmpty) {
              rawAssets['subArea'] = collection['subArea'] ?? collection['nearestLandmark'];
            }
            if (!rawAssets.containsKey('locationGasGroup') || rawAssets['locationGasGroup'] == null || (rawAssets['locationGasGroup'] is List && (rawAssets['locationGasGroup'] as List).isEmpty)) {
              rawAssets['locationGasGroup'] = collection['locationGasGroup'] ?? collection['gasGroup'] ?? collection['areaGasGroup'];
            }
            if (!rawAssets.containsKey('locationTClass') || rawAssets['locationTClass'] == null || (rawAssets['locationTClass'] is List && (rawAssets['locationTClass'] as List).isEmpty)) {
              rawAssets['locationTClass'] = collection['locationTClass'] ?? collection['tClass'] ?? collection['temperatureClass'];
            }
            if (!rawAssets.containsKey('locationIpRating') || rawAssets['locationIpRating'] == null || (rawAssets['locationIpRating'] is List && (rawAssets['locationIpRating'] as List).isEmpty)) {
              rawAssets['locationIpRating'] = collection['locationIpRating'] ?? collection['ipRating'];
            }
            if (!rawAssets.containsKey('locationTAmbient') || rawAssets['locationTAmbient'] == null || rawAssets['locationTAmbient'].toString().isEmpty) {
              rawAssets['locationTAmbient'] = collection['locationTAmbient'] ?? collection['tAmbient'];
            }
            if (!rawAssets.containsKey('tAmbient') || rawAssets['tAmbient'] == null || rawAssets['tAmbient'].toString().isEmpty) {
              rawAssets['tAmbient'] = collection['tAmbient'] ?? collection['locationTAmbient'];
            }
            if (!rawAssets.containsKey('locationLatitude') || rawAssets['locationLatitude'] == null || rawAssets['locationLatitude'].toString().isEmpty) {
              rawAssets['locationLatitude'] = collection['locationLatitude'] ?? collection['latitude'];
            }
            if (!rawAssets.containsKey('locationLongitude') || rawAssets['locationLongitude'] == null || rawAssets['locationLongitude'].toString().isEmpty) {
              rawAssets['locationLongitude'] = collection['locationLongitude'] ?? collection['longitude'];
            }
            if (!rawAssets.containsKey('gpsCord') || rawAssets['gpsCord'] == null || rawAssets['gpsCord'].toString().isEmpty) {
              rawAssets['gpsCord'] = collection['gpsCord'] ?? collection['gpsCoordinates'] ?? collection['gps'];
            }
            if (!rawAssets.containsKey('zone') || rawAssets['zone'] == null || rawAssets['zone'].toString().isEmpty) {
              rawAssets['zone'] = collection['zone'];
            }
            if (!rawAssets.containsKey('areaClassDrawNo') || rawAssets['areaClassDrawNo'] == null || (rawAssets['areaClassDrawNo'] is List && (rawAssets['areaClassDrawNo'] as List).isEmpty)) {
              rawAssets['areaClassDrawNo'] = collection['areaClassDrawNo'];
            }
            if (!rawAssets.containsKey('areaClassDrawAttach') || rawAssets['areaClassDrawAttach'] == null || (rawAssets['areaClassDrawAttach'] is List && (rawAssets['areaClassDrawAttach'] as List).isEmpty)) {
              rawAssets['areaClassDrawAttach'] = collection['areaClassDrawAttach'];
            }
            if (!rawAssets.containsKey('areaClassDrawAttachOrgName') || rawAssets['areaClassDrawAttachOrgName'] == null || (rawAssets['areaClassDrawAttachOrgName'] is List && (rawAssets['areaClassDrawAttachOrgName'] as List).isEmpty)) {
              rawAssets['areaClassDrawAttachOrgName'] = collection['areaClassDrawAttachOrgName'];
            }
            if (!rawAssets.containsKey('eqpmtLytDrawNo') || rawAssets['eqpmtLytDrawNo'] == null || (rawAssets['eqpmtLytDrawNo'] is List && (rawAssets['eqpmtLytDrawNo'] as List).isEmpty)) {
              rawAssets['eqpmtLytDrawNo'] = collection['eqpmtLytDrawNo'];
            }
            if (!rawAssets.containsKey('eqpmtLytDrawAttach') || rawAssets['eqpmtLytDrawAttach'] == null || (rawAssets['eqpmtLytDrawAttach'] is List && (rawAssets['eqpmtLytDrawAttach'] as List).isEmpty)) {
              rawAssets['eqpmtLytDrawAttach'] = collection['eqpmtLytDrawAttach'];
            }
            if (!rawAssets.containsKey('eqpmtLytDrawAttachOrgName') || rawAssets['eqpmtLytDrawAttachOrgName'] == null || (rawAssets['eqpmtLytDrawAttachOrgName'] is List && (rawAssets['eqpmtLytDrawAttachOrgName'] as List).isEmpty)) {
              rawAssets['eqpmtLytDrawAttachOrgName'] = collection['eqpmtLytDrawAttachOrgName'];
            }

            // Fetch location API data for map asset
            final locId = rawAssets['locationId']?.toString() ??
                collection['locationId']?.toString() ??
                collection['functionalAreaId']?.toString();
            final locData = await fetchLocationDataCached(locId);
            if (locData != null) {
              if (rawAssets['subArea'] == null || rawAssets['subArea'].toString().isEmpty) {
                rawAssets['subArea'] = locData['subArea'];
              }
              if (rawAssets['locationGasGroup'] == null || (rawAssets['locationGasGroup'] is List && (rawAssets['locationGasGroup'] as List).isEmpty)) {
                rawAssets['locationGasGroup'] = locData['locationGasGroup'];
              }
              if (rawAssets['locationTClass'] == null || (rawAssets['locationTClass'] is List && (rawAssets['locationTClass'] as List).isEmpty)) {
                rawAssets['locationTClass'] = locData['locationTClass'];
              }
              if (rawAssets['locationIpRating'] == null || (rawAssets['locationIpRating'] is List && (rawAssets['locationIpRating'] as List).isEmpty)) {
                rawAssets['locationIpRating'] = locData['locationIpRating'];
              }
              if (rawAssets['tAmbient'] == null || rawAssets['tAmbient'].toString().isEmpty) {
                rawAssets['tAmbient'] = locData['tAmbient'] ?? locData['locationTAmbient'];
                rawAssets['locationTAmbient'] = locData['tAmbient'] ?? locData['locationTAmbient'];
              }
              if (rawAssets['locationLatitude'] == null || rawAssets['locationLatitude'].toString().isEmpty) {
                rawAssets['locationLatitude'] = locData['locationLatitude'];
              }
              if (rawAssets['locationLongitude'] == null || rawAssets['locationLongitude'].toString().isEmpty) {
                rawAssets['locationLongitude'] = locData['locationLongitude'];
              }
              if (rawAssets['gpsCord'] == null || rawAssets['gpsCord'].toString().isEmpty) {
                rawAssets['gpsCord'] = locData['gpsCoordinates'] ?? locData['gpsCord'] ?? locData['gps'];
              }
              if (rawAssets['areaClassDrawNo'] == null || (rawAssets['areaClassDrawNo'] is List && (rawAssets['areaClassDrawNo'] as List).isEmpty)) {
                rawAssets['areaClassDrawNo'] = locData['areaClassDrawNo'];
              }
              if (rawAssets['areaClassDrawAttach'] == null || (rawAssets['areaClassDrawAttach'] is List && (rawAssets['areaClassDrawAttach'] as List).isEmpty)) {
                rawAssets['areaClassDrawAttach'] = locData['areaClassDrawAttach'];
              }
              if (rawAssets['areaClassDrawAttachOrgName'] == null || (rawAssets['areaClassDrawAttachOrgName'] is List && (rawAssets['areaClassDrawAttachOrgName'] as List).isEmpty)) {
                rawAssets['areaClassDrawAttachOrgName'] = locData['areaClassDrawAttachOrgName'] ?? locData['areaClassDrawNo'];
              }
              if (rawAssets['eqpmtLytDrawNo'] == null || (rawAssets['eqpmtLytDrawNo'] is List && (rawAssets['eqpmtLytDrawNo'] as List).isEmpty)) {
                rawAssets['eqpmtLytDrawNo'] = locData['eqpmtLytDrawNo'];
              }
              if (rawAssets['eqpmtLytDrawAttach'] == null || (rawAssets['eqpmtLytDrawAttach'] is List && (rawAssets['eqpmtLytDrawAttach'] as List).isEmpty)) {
                rawAssets['eqpmtLytDrawAttach'] = locData['eqpmtLytDrawAttach'];
              }
              if (rawAssets['eqpmtLytDrawAttachOrgName'] == null || (rawAssets['eqpmtLytDrawAttachOrgName'] is List && (rawAssets['eqpmtLytDrawAttachOrgName'] as List).isEmpty)) {
                rawAssets['eqpmtLytDrawAttachOrgName'] = locData['eqpmtLytDrawAttachOrgName'] ?? locData['eqpmtLytDrawNo'];
              }
              if (rawAssets['areaStatus'] == null || rawAssets['areaStatus'].toString().isEmpty) {
                rawAssets['areaStatus'] = locData['areaStatus'];
              }

              collection['subArea'] ??= locData['subArea'];
              collection['locationGasGroup'] ??= locData['locationGasGroup'];
              collection['locationTClass'] ??= locData['locationTClass'];
              collection['locationIpRating'] ??= locData['locationIpRating'];
              collection['tAmbient'] ??= locData['tAmbient'] ?? locData['locationTAmbient'];
              collection['locationLatitude'] ??= locData['locationLatitude'];
              collection['locationLongitude'] ??= locData['locationLongitude'];
              collection['gpsCoordinates'] ??= locData['gpsCoordinates'] ?? locData['gpsCord'] ?? locData['gps'];
              collection['areaClassDrawNo'] ??= locData['areaClassDrawNo'];
              collection['areaClassDrawAttach'] ??= locData['areaClassDrawAttach'];
              collection['areaClassDrawAttachOrgName'] ??= locData['areaClassDrawAttachOrgName'] ?? locData['areaClassDrawNo'];
              collection['eqpmtLytDrawNo'] ??= locData['eqpmtLytDrawNo'];
              collection['eqpmtLytDrawAttach'] ??= locData['eqpmtLytDrawAttach'];
              collection['eqpmtLytDrawAttachOrgName'] ??= locData['eqpmtLytDrawAttachOrgName'] ?? locData['eqpmtLytDrawNo'];
            }

            assetsData.add(rawAssets);
          } else if (collection.containsKey('eqpmtTag') ||
              collection.containsKey('equipmentId') ||
              collection.containsKey('rfidRef') ||
              collection.containsKey('eqpmtCatg') ||
              collection.containsKey('location') ||
              collection.containsKey('description')) {
            final locId = collection['locationId']?.toString() ?? collection['functionalAreaId']?.toString();
            final locData = await fetchLocationDataCached(locId);
            if (locData != null) {
              collection['subArea'] ??= locData['subArea'];
              collection['locationGasGroup'] ??= locData['locationGasGroup'];
              collection['locationTClass'] ??= locData['locationTClass'];
              collection['locationIpRating'] ??= locData['locationIpRating'];
              collection['tAmbient'] ??= locData['tAmbient'] ?? locData['locationTAmbient'];
              collection['locationLatitude'] ??= locData['locationLatitude'];
              collection['locationLongitude'] ??= locData['locationLongitude'];
              collection['gpsCoordinates'] ??= locData['gpsCoordinates'] ?? locData['gpsCord'] ?? locData['gps'];
              collection['areaClassDrawNo'] ??= locData['areaClassDrawNo'];
              collection['areaClassDrawAttach'] ??= locData['areaClassDrawAttach'];
              collection['areaClassDrawAttachOrgName'] ??= locData['areaClassDrawAttachOrgName'] ?? locData['areaClassDrawNo'];
              collection['eqpmtLytDrawNo'] ??= locData['eqpmtLytDrawNo'];
              collection['eqpmtLytDrawAttach'] ??= locData['eqpmtLytDrawAttach'];
              collection['eqpmtLytDrawAttachOrgName'] ??= locData['eqpmtLytDrawAttachOrgName'] ?? locData['eqpmtLytDrawNo'];
            }
            assetsData.add(collection);
          }
        }
      }

      // Convert to model
      final List<ExRegister> assets = [];
      for (final asset in assetsData) {
        if (asset != null && asset is Map<String, dynamic>) {
          try {
            assets.add(ExRegister.fromJson(asset));
          } catch (e) {
            // Safe skip invalid item
          }
        } else if (asset != null && asset is Map) {
          try {
            assets.add(ExRegister.fromJson(Map<String, dynamic>.from(asset)));
          } catch (e) {
            // Safe skip invalid item
          }
        }
      }

      final List<WorkOrderTableJson> workOrderCollection = [];
      for (final collection in collections) {
        if (collection != null && collection is Map<String, dynamic>) {
          try {
            workOrderCollection.add(WorkOrderTableJson.fromJson(collection));
          } catch (e) {
            // Safe skip invalid item
          }
        } else if (collection != null && collection is Map) {
          try {
            workOrderCollection.add(WorkOrderTableJson.fromJson(
                Map<String, dynamic>.from(collection)));
          } catch (e) {
            // Safe skip invalid item
          }
        }
      }

      return {
        'tableHeaders': <String>[],
        'assets': assets,
        'work_order': workOrderCollection,
        'totalRecords': totalRecords > 0 ? totalRecords : assets.length,
      };
  }

  Future<Map<String, dynamic>> syncAssetsToServer(
      EquipmentTagRequest equipmentTagRequest,
      {String? assetId}) async {
    try {
      final authUtils = AuthUtils();
      final tokens = await authUtils.getSessionTokens();
      final accessToken = tokens['accessToken'];
      String url = "/syncAssets";

      final response = await HttpUtils.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        useInterceptor: true,
        body: equipmentTagRequest.toJson(),
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == true) {
          final dynamic data = responseBody['data'];
          String? parsedId;
          if (data is Map) {
            parsedId = (data['asset'] is Map ? data['asset']['_id'] : null) ??
                data['_id'] ??
                data['assetId'] ??
                data['id'];
          } else if (data is String && data.isNotEmpty) {
            parsedId = data;
          }
          parsedId ??= responseBody['assetId']?.toString() ??
              responseBody['_id']?.toString();
          return {
            'status': responseBody['status'],
            'msg': responseBody['msg'],
            'data': parsedId ?? (assetId ?? ''),
          };
        } else {
          try {
            final isObjectId = assetId != null && RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(assetId);
            final fallbackResult = await ExInspectionService().equipmentTagPost(
              equipmentTagRequest,
              assetId: isObjectId ? assetId : null,
            );
            if (fallbackResult['status'] == true) {
              return {
                'status': true,
                'msg': fallbackResult['msg'] ?? 'Asset synced successfully',
                'data': fallbackResult['assetId']?.toString() ?? (assetId ?? ''),
              };
            }
          } catch (_) {}
          throw Exception(responseBody['msg'] ?? 'Unknown error');
        }
      } else {
        // Fallback to equipmentTagPost if /syncAssets returned 404 or non-200
        try {
          final isObjectId = assetId != null && RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(assetId);
          final fallbackResult = await ExInspectionService().equipmentTagPost(
            equipmentTagRequest,
            assetId: isObjectId ? assetId : null,
          );
          if (fallbackResult['status'] == true) {
            return {
              'status': true,
              'msg': fallbackResult['msg'] ?? 'Asset synced successfully',
              'data': fallbackResult['assetId']?.toString() ?? (assetId ?? ''),
            };
          }
        } catch (_) {}
        throw Exception('Failed to Sync Asset: HTTP ${response.statusCode}');
      }
    } on Exception catch (e) {
      // Fallback to equipmentTagPost on network or routing exception
      try {
        final isObjectId = assetId != null && RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(assetId);
        final fallbackResult = await ExInspectionService().equipmentTagPost(
          equipmentTagRequest,
          assetId: isObjectId ? assetId : null,
        );
        if (fallbackResult['status'] == true) {
          return {
            'status': true,
            'msg': fallbackResult['msg'] ?? 'Asset synced successfully',
            'data': fallbackResult['assetId']?.toString() ?? (assetId ?? ''),
          };
        }
      } catch (_) {}
      throw Exception('Failed to Sync Asset $e');
    }
  }

  Future<Map<String, dynamic>> syncServertoDeviceStatus(
      List<String> selectedAssetsSync) async {
    try {
      final authUtils = AuthUtils();
      final tokens = await authUtils.getSessionTokens();
      final accessToken = tokens['accessToken'];
      String url = "/work-order-assets-statuses";
      final data = {"assetIds": selectedAssetsSync};
      print("data => ${jsonEncode(data)}");
      final response = await HttpUtils.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        useInterceptor: true,
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == true) {
          return {'status': responseBody['status']};
        } else {
          throw Exception(responseBody['msg'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to Sync Asset');
      }
    } on Exception catch (e) {
      throw Exception('Failed to Sync Asset $e');
    }
  }
}
