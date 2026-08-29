import 'dart:convert';
import 'dart:io';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'auth_util.dart';

class FileDownloadUtil {
  static const MethodChannel _platform = MethodChannel('media_scan_channel');

  Future<String> _getAccessToken() async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    return tokens['accessToken']!;
  }

  Future<Map<String, dynamic>> downloadFiles(String url) async {
    final accessToken = await _getAccessToken();
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
      final String fileUrl = data['data']['url'] ?? '';
      final String fileName = data['data']['fileName'] ?? '';
      return {
        'fileUrl': fileUrl,
        'fileName': fileName,
      };
    } else {
      throw Exception('Failed to load files');
    }
  }

  Future<Uint8List> downloadFilesUsingURL(String url) async {
    final accessToken = await _getAccessToken();
    final response = await HttpUtils.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load files');
    }
  }

  Future<Map<String, dynamic>> removeFile({
    required String fileName,
  }) async {
    final accessToken = await _getAccessToken();
    String url = "/remove-excel-file/$fileName";

    final response = await HttpUtils.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      return {
        'data': 'initiated',
      };
    } else {
      throw Exception('Failed to remove file');
    }
  }

  Future<String> getExternalDocumentPath() async {
    try {
      // Directory directory;
      if (Platform.isAndroid) {
        if (await _isAndroid11orHigher()) {
          var status = await Permission.manageExternalStorage.status;
          if (!status.isGranted) {
            status = await Permission.manageExternalStorage.request();
            if (!status.isGranted) {
              throw Exception("Manage External Storage permission denied.");
            }
          }
          // directory =
          // await getExternalStorageDirectory() ??
          // await getApplicationDocumentsDirectory();
        } else {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              throw Exception("Storage permission denied.");
            }
          }
          // directory = Directory("/storage/emulated/0/Download");
        }
      } else {
        // directory = await getApplicationDocumentsDirectory();
      }
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      final exPath = directory!.path;
      await Directory(exPath).create(recursive: true);
      return exPath;
    } catch (error) {
      return '';
    }
  }

  Future<String> get getLocalPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  Future<bool> _isAndroid11orHigher() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 30;
    }
    return false;
  }

  Future<void> scanFile(String filePath) async {
    if (Platform.isAndroid) {
      try {
        await _platform.invokeMethod('scanFile', {'path': filePath});
      } catch (e) {}
    }
  }

  Future<String> downloadAndSaveFile(String url, String fileName) async {
    final bytes = await downloadFilesUsingURL(url);
    final directory = await getExternalDocumentPath();
    final filePath = '$directory/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await scanFile(filePath); // Initiate scan

    return filePath;
  }
}
