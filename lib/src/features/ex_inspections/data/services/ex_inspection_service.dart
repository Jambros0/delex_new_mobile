import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';

class ExInspectionService {
  Future<Map<String, dynamic>> getAllDropDwn() async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/getAllDropDwn";

    final response = await HttpUtils.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      final extractedData = {
        'status': result['status'],
        'message': result['message'],
        'result': {
          'locationDropDown': result['result']['locationDropDown'],
          'exResiterDropDown': result['result']['exResiterDropDown'],
        }
      };
      return extractedData;
    } else {
      throw Exception('Failed to fetch all dropdowns');
    }
  }

  Future<Map<String, dynamic>> functionalAreaPost(
      FunctionalAreaRequest functionalAreaRequest,
      {String? locationId}) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = locationId != null ? "/location/$locationId" : "/location";
    // return {};
    final response = await HttpUtils.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
      body: functionalAreaRequest.toJson(),
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == true) {
        return {
          'status': responseBody['status'],
          'msg': responseBody['msg'],
          'data': responseBody['data'],
        };
      } else {
        throw Exception(responseBody['msg'] ?? 'Unknown error');
      }
    } else {
      throw Exception('Failed to add location');
    }
  }

  Future<Map<String, dynamic>> equipmentTagPost(
      EquipmentTagRequest equipmentTagRequest,
      {String? assetId}) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = (assetId != null && assetId.isNotEmpty)
        ? "/assets/$assetId"
        : "/assets";
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
          'assetId': responseBody['assetId'],
        };
      } else {
        throw Exception(responseBody['msg'] ?? 'Unknown error');
      }
    } else {
      throw Exception('Failed to add equipment Tags');
    }
  }

  Future<Map<String, dynamic>> fetchInspectionChecklist() async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/inspectionChecklist";
    final response = await HttpUtils.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      final extractedData = {
        'checkLists': result['checkLists'],
        'checkListDetails': result['checkListDetails']
      };
      return extractedData;
    } else {
      throw Exception('Failed to fetch checklist data');
    }
  }
}
