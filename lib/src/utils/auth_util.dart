import 'package:flutter/material.dart';

import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/repository/auth_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final logger = Logger();

class AuthUtils {
  static final AuthUtils _instance = AuthUtils._internal();
  factory AuthUtils() => _instance;
  AuthUtils._internal();
  final DBHelper dbHelper = DBHelper();

  Future<void> saveSessionTokens(
      String accessToken, String refreshToken, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userId', userId);

    final userType = extractUserType(accessToken);
    if (userType != null) {
      await prefs.setString('userType', userType);
    }
  }

  bool isTokenValid(String token) {
    final payload = JwtDecoder.decode(token);
    final expiry = payload['exp'] * 1000;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  Future<Map<String, String?>> getSessionTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      try {
        final user = await dbHelper.getLoggedInUserByUserId(userId);
        if (user != null && user.accessToken.isNotEmpty) {
          return {
            'accessToken': user.accessToken,
            'refreshToken': user.refreshToken,
          };
        }
      } catch (_) {}
    }
    return {
      'accessToken': prefs.getString('accessToken'),
      'refreshToken': prefs.getString('refreshToken'),
    };
  }

  Future<void> clearSessionTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
  }

  Future<bool> isSessionActive() async {
    final tokens = await getSessionTokens();
    return tokens['accessToken'] != null && tokens['refreshToken'] != null;
  }

  String? extractUserType(String token) {
    try {
      final payload = JwtDecoder.decode(token);
      final raw = payload['userType'] ??
          payload['user_type'] ??
          payload['role'] ??
          payload['accountType'];
      return raw?.toString().toLowerCase();
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    String? type = prefs.getString('userType');
    if (type != null && type.isNotEmpty) {
      return type.toLowerCase();
    }
    final tokens = await getSessionTokens();
    final accessToken = tokens['accessToken'];
    if (accessToken != null && accessToken.isNotEmpty) {
      type = extractUserType(accessToken);
      if (type != null && type.isNotEmpty) {
        await prefs.setString('userType', type);
        return type.toLowerCase();
      }
    }
    return null;
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<void> handleLogout([BuildContext? context]) async {
    final authRepository = AuthRepository(
      authService: AuthService(),
      authUtils: AuthUtils(),
      dbHelper: DBHelper(),
    );

    try {
      final user = await authRepository.dbHelper.getLoggedInUser();
      if (user != null) {
        try {
          await authRepository.logout(user.userId);
        } catch (e) {
          logger.e('Error during server logout: $e');
        }
      }
    } catch (e) {
      logger.e('Error getting user for logout: $e');
    } finally {
      await AuthUtils().clearSessionTokens();
      await AuthUtils().clearUsername();
      if (context != null && context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        try {
          Get.offAllNamed('/login');
        } catch (e) {
          logger.e('Get.offAllNamed error: $e');
        }
      }
    }
  }

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> clearUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  Future<void> setExDateFilter(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exDateFilter', data);
  }

  Future<String?> getExDateFilter(String data) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('exDateFilter');
  }

  Future<void> removeExDateFilter(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exDateFilter');
  }

  Future<void> setExShowAllFilter(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exShowAllFilter', data);
  }

  Future<String?> getExShowAllFilter(String data) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('exShowAllFilter');
  }

  Future<void> removeExShowAllFilter(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exShowAllFilter');
  }

  Future<void> saveLicenseValidationStatus(bool isValid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLicenseValidated', isValid);
  }

  Future<bool> isLicenseValidated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLicenseValidated') ?? false;
  }

  Future<void> setDashboardFilter(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dashboardFilter', data);
  }
}
