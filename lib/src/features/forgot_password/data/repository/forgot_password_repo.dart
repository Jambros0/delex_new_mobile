import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/data/services/forgot_password_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/network_util.dart';

import '../models/user_forgot_password.dart';
import '../models/user_validate_password.dart';

class ForgotPasswordRepository {
  final ForgotPasswordService forgotPasswordService;
  final DBHelper dbHelper;
  final AuthUtils authUtils;

  ForgotPasswordRepository({
    required this.forgotPasswordService,
    required this.dbHelper,
    required this.authUtils,
  });

  Future<Map<String, dynamic>> sendOtp(UserForgotPassword userLogin) async {
    try {
      if (NetworkUtils().isNetworkAvailable) {
        logger.i('Network available. Using API for authentication.');
        return _apisendOtp(userLogin);
      }
      return {};
    } catch (e) {
      logger.e('Authentication error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resendOtp(UserForgotPassword userLogin) async {
    try {
      if (NetworkUtils().isNetworkAvailable) {
        logger.i('Network available. Using API for authentication.');
        return _apiResendOtp(userLogin);
      }
      return {};
    } catch (e) {
      logger.e('Authentication error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateOtp(
      UserValidatePassword userLogin) async {
    try {
      if (NetworkUtils().isNetworkAvailable) {
        logger.i('Network available. Using API for authentication.');
        return _apivalidateOtp(userLogin);
      }
      return {};
    } catch (e) {
      logger.e('Authentication error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _apisendOtp(UserForgotPassword userLogin) async {
    final response = await forgotPasswordService.sendOtp(userLogin);
    if (response['status'] != true) {
      return response;
    }

    return response;
  }

  Future<Map<String, dynamic>> _apiResendOtp(
      UserForgotPassword userLogin) async {
    final response = await forgotPasswordService.resendOtp(userLogin);
    if (response['status'] != true) {
      return response;
    }

    return response;
  }

  Future<Map<String, dynamic>> _apivalidateOtp(
      UserValidatePassword userLogin) async {
    final response = await forgotPasswordService.validateOtp(userLogin);
    if (response['status'] != true) {
      return response;
    }

    return response;
  }
}
