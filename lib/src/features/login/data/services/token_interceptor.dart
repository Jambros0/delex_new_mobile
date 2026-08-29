import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class TokenInterceptor {
  Future<http.Response> intercept(http.Response response) async {
    if (response.statusCode == 401) {
      final authUtils = AuthUtils();
      final tokens = await authUtils.getSessionTokens();
      final refreshToken = tokens['refreshToken'];
      if (refreshToken != null) {
        final authService = AuthService();
        final newAccessToken = await authService.refreshToken(refreshToken);
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        if (userId != null) {
          await authUtils.saveSessionTokens(
              newAccessToken, refreshToken, userId);
        }
        final request =
            http.Request(response.request!.method, response.request!.url)
              ..headers.addAll({'Authorization': 'Bearer $newAccessToken'});
        final newResponse =
            await http.Response.fromStream(await http.Client().send(request));
        return newResponse;
      }
    }
    return response;
  }
}
