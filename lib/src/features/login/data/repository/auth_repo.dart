import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_login.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/services/auth_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/network_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final AuthService authService;
  final DBHelper dbHelper;
  final AuthUtils authUtils;

  AuthRepository({
    required this.authService,
    required this.dbHelper,
    required this.authUtils,
  });

  Future<Map<String, String>> authenticate(UserLogin userLogin) async {
    try {
      if (kIsWeb) {
        final userDetails = UserDetails(
          userId: 'web_user',
          firstName: 'Web',
          lastName: 'User',
          email: 'webuser@delex.com',
          userRole: 'offshore',
          signature: '',
          userName: userLogin.username,
          password: userLogin.password,
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', 'mock_access_token');
        await prefs.setString('refreshToken', 'mock_refresh_token');
        await prefs.setString('userId', 'web_user');
        await prefs.setString('userType', 'offshore');
        await prefs.setString('username', userLogin.username);
        
        await dbHelper.saveUser(userDetails);
        
        return {
          'accessToken': 'mock_access_token',
          'refreshToken': 'mock_refresh_token',
          'userId': 'web_user',
        };
      }
      if (NetworkUtils().isNetworkAvailable) {
        logger.i('Network available. Using API for authentication.');
        final tokens = await _apiLogin(userLogin);
        await authUtils.saveCredentials(userLogin.username, userLogin.password);
        return tokens;
      } else {
        logger.i('Network not available. Using local authentication.');
        final tokens = await _localLogin(userLogin);
        await authUtils.saveCredentials(userLogin.username, userLogin.password);
        return tokens;
      }
    } catch (e) {
      logger.e('Authentication error: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> _apiLogin(UserLogin userLogin) async {
    final response = await authService.login(userLogin);

    final userMap = response['userDetails'] ?? {};
    final dynamic statusRaw = userMap['status'] ?? userMap['userStatus'] ?? userMap['isActive'] ?? response['status'];
    final String statusStr = statusRaw?.toString().toLowerCase().trim() ?? 'active';

    if (statusStr == 'inactive' || statusStr == 'false' || statusStr == '0' || statusStr == 'disabled' || statusStr == 'deactivated') {
      throw Exception('Your account is inactive. Access has been removed.');
    }

    if (response['accessToken'] == null || response['refreshToken'] == null) {
      throw Exception(
          'Login failed. Please verify your username and password..!');
    }
    final userDetails = UserDetails(
      userId: response['userDetails']['userId'] ?? '',
      firstName: response['userDetails']['firstName'] ?? '',
      lastName: response['userDetails']['lastName'] ?? '',
      email: response['userDetails']['email'] ?? '',
      userRole: response['userDetails']['userRole'] ?? '',
      signature: response['userDetails']['signature'] ?? '',
      userName: (response['userDetails']?['userName'] != null &&
              response['userDetails']['userName'].toString().isNotEmpty)
          ? response['userDetails']['userName'].toString()
          : userLogin.username,
      password: userLogin.password,
      accessToken: response['accessToken'] ?? '',
      refreshToken: response['refreshToken'] ?? '',
    );

    final String rawUserType = (response['userDetails']?['userType'] ??
            response['userDetails']?['userRole'] ??
            response['userType'] ??
            response['userDetails']?['role'] ??
            '')
        .toString();
    final String? resolvedType = rawUserType.isNotEmpty ? rawUserType : null;

    await authUtils.saveSessionTokens(
        userDetails.accessToken, userDetails.refreshToken, userDetails.userId,
        userType: resolvedType);
    if (userDetails.userName.isNotEmpty) {
      await authUtils.saveUsername(userDetails.userName);
    }
    final userType = resolvedType ?? await AuthUtils().getUserType();
    final apiUrl = dotenv.env['API_URL'];
    if (userDetails.signature.isNotEmpty) {
      final signatureUrl =
          '$apiUrl/$userType/${response['userDetails']['signature']}';
      final localPath = await _downloadSignatureImage(
          signatureUrl, userDetails.accessToken, userDetails.refreshToken);
      userDetails.signature = localPath;
      if (localPath.isNotEmpty && File(localPath).existsSync()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_completed_signature_${userDetails.userId}', true);
      }
    }
    await dbHelper.saveUser(userDetails);
    return {
      'accessToken': userDetails.accessToken,
      'refreshToken': userDetails.refreshToken,
      'userId': userDetails.userId,
    };
  }

  Future<Map<String, String>> _localLogin(UserLogin userLogin) async {
    final localUser = await dbHelper.getLoggedInUserByCredentials(userLogin);

    if (localUser == null) {
      throw Exception(
          'No saved user data available. Connect to network and login again.');
    }

    if (!authUtils.isTokenValid(localUser.accessToken)) {
      throw Exception('Local session expired. Connect to network and login.');
    }
    await authUtils.saveSessionTokens(
      localUser.accessToken,
      localUser.refreshToken,
      localUser.userId,
    );
    return {
      'accessToken': localUser.accessToken,
      'refreshToken': localUser.refreshToken,
      'userId': localUser.userId,
    };
  }

  Future<void> logout(String userId) async {
    final user = await dbHelper.getLoggedInUserByUserId(userId);
    if (NetworkUtils().isNetworkAvailable && user != null) {
      await authService.logout(user.accessToken, user.refreshToken);
    }
    await authUtils.clearSessionTokens();
  }

  Future<String> refreshToken(String userId) async {
    final user = await dbHelper.getLoggedInUserByUserId(userId);
    if (user != null) {
      final newAccessToken = await authService.refreshToken(user.refreshToken);
      await dbHelper.updateSessionTokens(
        userId,
        newAccessToken,
        user.refreshToken,
      );
      return newAccessToken;
    } else {
      throw Exception('User not found');
    }
  }

  Future<String> _downloadSignatureImage(
      String url, String accessToken, String refreshToken) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');
      final response = await request.close();
      // return '';
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final String extension = _getFileExtension(url);
        final String filePath = '${tempDir.path}/signature.$extension';
        final file = File(filePath);
        await response.pipe(file.openWrite());
        return filePath;
      } else {
        return '';
        // throw Exception(
        //     'Failed to download signature image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // return '';
      throw Exception('Error downloading signature: $e');
    }
  }

  String _getFileExtension(String url) {
    final RegExp extensionRegExp =
        RegExp(r'\.(png|jpg|jpeg)$', caseSensitive: false);
    final match = extensionRegExp.firstMatch(url);
    if (match != null) {
      return match.group(1) ?? 'jpg';
    }
    return 'jpg';
  }
}
