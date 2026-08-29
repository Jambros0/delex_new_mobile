import 'dart:convert';
import 'dart:io';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/services/token_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'auth_util.dart';

class HttpUtils {
  static const String _contentType = 'application/json; charset=UTF-8';
  static Future<String> getApiUrl() async {
    var baseUrl = dotenv.env['API_URL'] ?? 'https://delex.mazedemo.in/api';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    final userType = await AuthUtils().getUserType();
    if (userType != null && userType.isNotEmpty) {
      return '$baseUrl/$userType';
    }
    return baseUrl;
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required bool useInterceptor,
  }) async {
    final rawUrl = '${await getApiUrl()}$endpoint';
    final url =
        rawUrl.contains('/admin') ? _removeUserTypeFromUrl(rawUrl) : rawUrl;

    // print("rawUrl => ${rawUrl}");
    // print("url => ${url}");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': _contentType},
        body: body is String ? body : jsonEncode(body),
      );
      return TokenInterceptor().intercept(response);
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  static Future<http.Response> postWithoutBody(
    String endpoint, {
    Map<String, String>? headers,
    required bool useInterceptor,
  }) async {
    final url = '${await getApiUrl()}$endpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': _contentType},
      );
      return TokenInterceptor().intercept(response);
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  static String _sanitizeUrl(String url) {
    var cleanUrl = url.replaceAll('/offshore/offshore', '/offshore');
    cleanUrl = cleanUrl.replaceAll('/onshore/onshore', '/onshore');
    cleanUrl = cleanUrl.replaceAll('/offshore/onshore', '/onshore');
    cleanUrl = cleanUrl.replaceAll('/onshore/offshore', '/offshore');
    if (cleanUrl.contains('/admin')) {
      cleanUrl = _removeUserTypeFromUrl(cleanUrl);
    }
    return cleanUrl;
  }

  static Future<http.Response> getWithBody(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required bool useInterceptor,
  }) async {
    final rawUrl = '${await getApiUrl()}$endpoint';
    final url = _sanitizeUrl(rawUrl);
    print('[HTTP_GET_WITH_BODY] Final URL: $url');

    try {
      final request = http.Request('GET', Uri.parse(url))
        ..headers.addAll(headers ?? {'Content-Type': _contentType})
        ..body = body != null ? jsonEncode(body) : '';
      final response = await http.Response.fromStream(await request.send());
      return TokenInterceptor().intercept(response);
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    required bool useInterceptor,
  }) async {
    final url = '${await getApiUrl()}$endpoint';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': _contentType},
      );
      return TokenInterceptor().intercept(response);
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  static Future<http.Response> postMultipart(
    String endpoint, {
    required File file,
    required String fileKey,
    Map<String, String>? headers,
    required bool useInterceptor,
  }) async {
    final url = '${await getApiUrl()}$endpoint';
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers ?? {})
      ..files.add(await http.MultipartFile.fromPath(fileKey, file.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return TokenInterceptor().intercept(response);
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  static Future<http.Response> photoMultipart(
    String endpoint, {
    required List<File> files,
    required String fileKey,
    Map<String, String>? headers,
    required bool useInterceptor,
  }) async {
    final url = '${await getApiUrl()}$endpoint';
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers ?? {});
    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath(fileKey, file.path));
    }
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return TokenInterceptor().intercept(response);
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  static String _removeUserTypeFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments
        .where((s) => s != 'offshore' && s != 'onshore')
        .toList();
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      pathSegments: segments,
      queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
    ).toString();
  }
}
