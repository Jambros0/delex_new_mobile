import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';

class LocationService {
  Future<Map<String, dynamic>> fetchLocations({
    int limit = 30,
    int offset = 0,
    String? sortField,
    String? sortOrder,
  }) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];

    final response = await HttpUtils.getWithBody(
      "/location",
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

      final List<String> tableHeaders =
          List<String>.from(data['TableHeaders'] ?? []);

      final List<dynamic> dataList = data['data'] ?? [];
      final List<Location> locations =
          dataList.isNotEmpty && dataList[0]['locations'] != null
              ? List<Location>.from((dataList[0]['locations'] as List)
                  .map((location) => Location.fromJson(location)))
              : [];

      final int totalRecords =
          dataList.isNotEmpty && dataList[0]['info'] != null
              ? dataList[0]['info'][0]['total'] ?? 0
              : 0;

      return {
        'tableHeaders': tableHeaders,
        'locations': locations,
        'totalRecords': totalRecords,
      };
    } else {
      throw Exception('Failed to load locations');
    }
  }

  Future<Location> createLocation(Location location) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];

    final response = await HttpUtils.post(
      "/location",
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: {
        'location': location.toJson(),
      },
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Location.fromJson(data['data']);
    } else {
      throw Exception('Failed to create location');
    }
  }

  Future<Map<String, dynamic>> fetchLocationById(
      {required String locationId}) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/location/$locationId";
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
      return {'data': data};
    } else {
      throw Exception('Failed to fetch location with id: $locationId');
    }
  }

  Future<Location> fetchLocationByIdDownload(
      {required String locationId}) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/location/$locationId";
    final response = await HttpUtils.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
    );
    if (response.statusCode == 200) {
      Location collection = Location.fromJson(jsonDecode(response.body));
      // final Map<String, dynamic> data = jsonDecode(response.body);
      // return {'data': data};
      return collection;
    } else {
      throw Exception('Failed to fetch location with id: $locationId');
    }
  }
}
