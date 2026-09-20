import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
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
  }) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];

    final response = await HttpUtils.getWithBody(
      "/workorder/assets",
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: {
        'filter': {
          'offset': offset,
          'limit': limit,
          if (sortField != null && sortOrder != null)
            'sort': {
              'fieldName': sortField,
              'order': sortOrder,
            }
        }
      },
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final dynamic innerData = data['data'] ?? data['result'];
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
        } else if (innerData.containsKey('assets') &&
            innerData['assets'] is List) {
          collections = [innerData];
        } else {
          collections = [innerData];
        }
        totalRecords = innerData['total'] ?? collections.length;
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
          final rawAssets = collection['assets'];
          if (rawAssets is List) {
            assetsData.addAll(rawAssets);
          } else if (rawAssets is Map) {
            assetsData.add(rawAssets);
          } else if (collection.containsKey('eqpmtTag') ||
              collection.containsKey('equipmentId')) {
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
            workOrderCollection.add(
                WorkOrderTableJson.fromJson(Map<String, dynamic>.from(collection)));
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
      throw Exception('Failed to load assets');
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
      // Debug: print the full JSON collection if possible
      // final requestJson = equipmentTagRequest.toJson();
      // return {};
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
          return {
            'status': responseBody['status'],
            'msg': responseBody['msg'],
            'data': responseBody['data']['asset']['_id'],
          };
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
