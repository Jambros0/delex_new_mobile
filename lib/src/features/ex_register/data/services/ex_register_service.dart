import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/assets_duplicate.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';
import 'package:intl/intl.dart';

class ExRegisterService {
  Future<Map<String, dynamic>> fetchAssets({
    int limit = 30,
    int skip = 0,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortField,
    String? sortOrder,
    String? type,
  }) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];

    String? formattedFromDate =
        fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : null;
    String? formattedToDate =
        toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : null;

    String url = "/assets?limit=$limit&skip=$skip";
    if (formattedFromDate != null) {
      url += "&fromDate=$formattedFromDate";
    }
    if (formattedToDate != null) {
      url += "&toDate=$formattedToDate";
    }
    if (sortField != null) {
      url += "&sortBy=$sortField";
    }
    if (sortOrder != null) {
      url += "&order=$sortOrder";
    }
    if (type != null) {
      url += "&showOnly=$type";
    }
    final response = await HttpUtils.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<String> tableHeaders =
          List<String>.from(data['tableHeaders'] ?? []);
      final List<dynamic> assetsData = data['data']['assets'] ?? [];
      int totalRecords = 0;
      data['data']['info'].isEmpty
          ? totalRecords = 0
          : data['data']['info'][0]['total'] ?? 0;

      final List<ExRegister> assets = assetsData
          .where((asset) => asset != null)
          .map((asset) => ExRegister.fromJson(asset))
          .toList();
      return {
        'tableHeaders': tableHeaders,
        'assets': assets,
        'totalRecords': totalRecords,
      };
    } else {
      throw Exception('Failed to load assets');
    }
  }

  Future<Map<String, dynamic>> fetchAssetById({required String assetId}) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/assets/$assetId";

    final response = await HttpUtils.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic> assetDetails =
          data['data']['assetDetails'] ?? {};
      return {
        'status': true,
        'message': 'Asset details fetched successfully',
        'data': {
          'assetDetails': assetDetails,
        },
      };
    } else {
      throw Exception('Failed to load assets');
    }
  }

  Future<Map<String, dynamic>> deleteAssetById(
      {required String assetId}) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/assetsdelete/$assetId";
    final response = await HttpUtils.postWithoutBody(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to delete assets');
    }
  }

  Future<Map<String, dynamic>> postAsset(
      {required DuplicateAsset asset}) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/assets";

    final assetMap = asset.toJson();
    assetMap.remove('_id');
    assetMap.remove('primaryId');
    assetMap.remove('id');
    assetMap['isDuplicate'] = true;

    final response = await HttpUtils.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
      body: {"asset": assetMap},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to Post asset');
    }
  }
}

