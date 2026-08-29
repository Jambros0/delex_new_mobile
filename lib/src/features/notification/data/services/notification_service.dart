import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';

class NotificationService {
  Future<Map<String, dynamic>> fetchNotification({
    UserDetails? loggedInUser,
  }) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    // String url = "/notifications";
    // final baseUrl = dotenv.env['API_URL'] ?? 'http://192.168.29.41:5600';
    // final userType = await AuthUtils().getUserType();
    final userId = loggedInUser == null ? "" : loggedInUser.userId;
    String url = "/api/notifications/user/$userId?page=1&limit=15&type=";
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
      return {
        'status': data['success'] == true || data['success'] == 'true' || data['status'] == true || response.statusCode == 200,
        'message': data['message'] ?? '',
        'data': response.body,
      };
    } else {
      throw Exception('Failed to load Notification');
    }
  }

  Future<Map<String, dynamic>> postNotifcationToken({required token}) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/syncToken";
    final response = await HttpUtils.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
      body: {"token": token},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to Post asset');
    }
  }
}
