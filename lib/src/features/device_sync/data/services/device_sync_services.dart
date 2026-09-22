import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/services/ex_inspection_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';
import 'package:http/http.dart' as http;

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

    final targetEndpoint = (currentUserId != null && currentUserId.isNotEmpty)
        ? "/user-work-orders/$currentUserId"
        : "/user-work-orders";

    http.Response response;
    try {
      response = await HttpUtils.get(
        targetEndpoint,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        useInterceptor: true,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final fallbackEndpoint = (currentUserId != null && currentUserId.isNotEmpty)
            ? "/work-order/$currentUserId"
            : "/work-order";
        final fallbackResponse = await HttpUtils.get(
          fallbackEndpoint,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          useInterceptor: true,
        );
        if (fallbackResponse.statusCode == 200) {
          response = fallbackResponse;
        }
      }
    } catch (_) {
      final fallbackEndpoint = (currentUserId != null && currentUserId.isNotEmpty)
          ? "/work-order/$currentUserId"
          : "/work-order";
      response = await HttpUtils.get(
        fallbackEndpoint,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        useInterceptor: true,
      );
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final dynamic innerData = data['data'] ??
          data['result'] ??
          data['work_order'] ??
          data['workOrder'] ??
          data['work_orders'] ??
          data['assets'];

      List<dynamic> collections = [];
      int totalRecords = 0;

      if (innerData is List) {
        collections = innerData;
        totalRecords = innerData.length;
      } else if (innerData is Map) {
        if (innerData.containsKey('data') && innerData['data'] is List) {
          collections = innerData['data'] ?? [];
        } else if (innerData.containsKey('work_order') &&
            innerData['work_order'] is List) {
          collections = innerData['work_order'] ?? [];
        } else if (innerData.containsKey('workOrder') &&
            innerData['workOrder'] is List) {
          collections = innerData['workOrder'] ?? [];
        } else if (innerData.containsKey('work_orders') &&
            innerData['work_orders'] is List) {
          collections = innerData['work_orders'] ?? [];
        } else if (innerData.containsKey('assignedAssets') &&
            innerData['assignedAssets'] is List) {
          collections = [innerData];
        } else if (innerData.containsKey('assets') &&
            innerData['assets'] is List) {
          collections = [innerData];
        } else {
          collections = [innerData];
        }
        totalRecords = innerData['total'] ??
            (innerData['info'] is List && innerData['info'].isNotEmpty
                ? innerData['info'][0]['total']
                : collections.length);
      } else if (data.containsKey('data') && data['data'] is List) {
        collections = data['data'];
        totalRecords = collections.length;
      }

      if (data['total'] != null) {
        totalRecords = int.tryParse(data['total'].toString()) ?? totalRecords;
      } else if (data['totalRecords'] != null) {
        totalRecords =
            int.tryParse(data['totalRecords'].toString()) ?? totalRecords;
      }

      if (collections.isEmpty) {
        return {
          'tableHeaders': <String>[],
          'assets': <ExRegister>[],
          'work_order': <WorkOrderTableJson>[],
          'totalRecords': 0,
        };
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
                if (!a.containsKey('assignedTeam') && collection.containsKey('assigendTeam')) {
                  a['assignedTeam'] = collection['assigendTeam'];
                }
                if (!a.containsKey('assignedTo') && collection.containsKey('assignedTo')) {
                  a['assignedTo'] = collection['assignedTo'];
                }
                if (!a.containsKey('userId') && collection.containsKey('userId')) {
                  a['userId'] = collection['userId'];
                }
                if (!a.containsKey('woNumber') && collection.containsKey('woNumber')) {
                  a['woNumber'] = collection['woNumber'];
                }
                if (!a.containsKey('workOrderId') && collection.containsKey('_id')) {
                  a['workOrderId'] = collection['_id'];
                }
                if ((a['location'] == null || a['location'].toString().isEmpty)) {
                  a['location'] = collection['fieldName'] ?? collection['location'];
                }
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
            }
            assetsData.addAll(rawAssets);
          } else if (rawAssets is Map) {
            if (!rawAssets.containsKey('assignedTeam') && collection.containsKey('assigendTeam')) {
              rawAssets['assignedTeam'] = collection['assigendTeam'];
            }
            if (!rawAssets.containsKey('assignedTo') && collection.containsKey('assignedTo')) {
              rawAssets['assignedTo'] = collection['assignedTo'];
            }
            if (!rawAssets.containsKey('userId') && collection.containsKey('userId')) {
              rawAssets['userId'] = collection['userId'];
            }
            if (!rawAssets.containsKey('woNumber') && collection.containsKey('woNumber')) {
              rawAssets['woNumber'] = collection['woNumber'];
            }
            if (!rawAssets.containsKey('workOrderId') && collection.containsKey('_id')) {
              rawAssets['workOrderId'] = collection['_id'];
            }
            if ((rawAssets['location'] == null || rawAssets['location'].toString().isEmpty)) {
              rawAssets['location'] = collection['fieldName'] ?? collection['location'];
            }
            if ((rawAssets['subLocation'] == null || rawAssets['subLocation'].toString().isEmpty)) {
              rawAssets['subLocation'] = collection['subLocation'] ?? collection['platform'];
            }
            if ((rawAssets['area'] == null || rawAssets['area'].toString().isEmpty)) {
              rawAssets['area'] = collection['platform'] ?? collection['area'] ?? collection['subLocation'];
            }
            if ((rawAssets['deckLevel'] == null || rawAssets['deckLevel'].toString().isEmpty)) {
              rawAssets['deckLevel'] = collection['deckLevel'] ?? collection['area'];
            }
            assetsData.add(rawAssets);
          } else if (collection.containsKey('eqpmtTag') ||
              collection.containsKey('equipmentId') ||
              collection.containsKey('rfidRef') ||
              collection.containsKey('eqpmtCatg') ||
              collection.containsKey('location') ||
              collection.containsKey('description')) {
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
    } else {
      throw Exception('Failed to load assets: HTTP ${response.statusCode}');
    }
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
