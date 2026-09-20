import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';
import '../models/user_login.dart';

class AuthService {
  Future<Map<String, dynamic>> login(UserLogin userLogin) async {
    final response = await HttpUtils.post(
      '/admin/login',
      body: userLogin.toJson(),
      useInterceptor: false,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == false) {
        throw Exception(data['message'] ?? 'Invalid credentials');
      }
      final user = data['user'] ?? data['data'] ?? data['userDetails'] ?? {};

      final dynamic statusRaw = user['status'] ?? user['userStatus'] ?? user['isActive'] ?? data['userStatus'];
      final String statusStr = statusRaw?.toString().toLowerCase().trim() ?? 'active';

      if (statusStr == 'inactive' || statusStr == '0' || statusStr == 'disabled' || statusStr == 'deactivated') {
        throw Exception('Account is inactive. Access has been removed.');
      }

      return {
        'accessToken': data['accessToken'],
        'refreshToken': data['refreshToken'],
        'userDetails': user,
        'status': statusStr,
      };
    } else if (response.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> logout(String accessToken, String refreshToken) async {
    final response = await HttpUtils.getWithBody(
      '/admin/logout',
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: {'refreshToken': refreshToken},
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (!data['status']) {
        throw Exception(data['message'] ?? 'Failed to logout');
      }
    } else {
      throw Exception('Failed to logout');
    }
  }

  Future<String> refreshToken(String refreshToken) async {
    final response = await HttpUtils.post(
      '/refreshToken',
      body: {'refreshToken': refreshToken},
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status']) {
        return data['accessToken'];
      } else {
        throw Exception('Invalid refresh token');
      }
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
