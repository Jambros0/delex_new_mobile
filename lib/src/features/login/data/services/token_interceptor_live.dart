// import 'dart:io';

// import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/io_client.dart'; // IOClient is defined here
// import 'package:shared_preferences/shared_preferences.dart';

// import '../services/auth_service.dart';

// class ProxyHttpClient extends http.BaseClient {
//   final http.Client _inner;

//   ProxyHttpClient(this._inner);

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     // Set up proxy using dart:io HttpClient
//     final httpClient = HttpClient();

//     httpClient.findProxy = (uri) {
//       return "PROXY 127.0.0.1:9090"; // Replace with your proxy port if needed
//     };

//     httpClient.badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;

//     final ioClient = IOClient(httpClient);
//     return ioClient.send(request);
//   }
// }

// class TokenInterceptor {
//   Future<http.Response> intercept(http.Response response) async {
//     if (response.statusCode == 401) {
//       final authUtils = AuthUtils();
//       final tokens = await authUtils.getSessionTokens();
//       final refreshToken = tokens['refreshToken'];
//       if (refreshToken != null) {
//         final authService = AuthService();
//         final newAccessToken = await authService.refreshToken(refreshToken);

//         final prefs = await SharedPreferences.getInstance();
//         final userId = prefs.getString('userId');
//         if (userId != null) {
//           await authUtils.saveSessionTokens(
//               newAccessToken, refreshToken, userId);
//         }

//         final request = http.Request(
//           response.request!.method,
//           response.request!.url,
//         )..headers.addAll({
//             'Authorization': 'Bearer $newAccessToken',
//           });
//         final proxyClient = ProxyHttpClient(http.Client());
//         final newResponse =
//             await http.Response.fromStream(await proxyClient.send(request));
//         return newResponse;
//       }
//     }
//     return response;
//   }
// }
