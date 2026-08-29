import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/data/models/user_forgot_password.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';

import '../models/user_validate_password.dart';

class ForgotPasswordService {
  Future<Map<String, dynamic>> sendOtp(UserForgotPassword userLogin) async {
    final response = await HttpUtils.post(
      '/admin/user/sendotp',
      body: userLogin.toJson(),
      useInterceptor: false,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> resendOtp(UserForgotPassword userLogin) async {
    final response = await HttpUtils.post(
      '/admin/user/resendotp',
      body: userLogin.toJson(),
      useInterceptor: false,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> validateOtp(
      UserValidatePassword userLogin) async {
    final response = await HttpUtils.post(
      '/admin/user/validateotp',
      body: userLogin.toJson(),
      useInterceptor: false,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }
}
