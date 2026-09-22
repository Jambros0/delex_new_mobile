import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';
import 'dart:convert';
import 'dart:io';

class FileUploadUtil {
  final RegExp imageFileTypes =
      RegExp(r'\.(jpg|jpeg|png|webp|jfif|bmp|heic|gif)$', caseSensitive: false);
  final RegExp generalFileTypes = RegExp(
      r'\.(pdf|jpeg|xlsx|xls|png|jpg|webp|jfif|bmp|heic|gif|doc|docx)$',
      caseSensitive: false);

  bool isValidFileType(String fileName, RegExp allowedTypes) {
    final cleanName = fileName.split('?').first.split('#').first;
    if (!cleanName.contains('.')) return true;
    return allowedTypes.hasMatch(cleanName.toLowerCase());
  }

  void getImageFileSize(File file) {
    // int sizeInBytes = file.lengthSync();
  }

  Future<Map<String, dynamic>> fileUpload(File file, String fileOf) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/file?fileOf=$fileOf";
    getImageFileSize(file);
    if (!isValidFileType(file.path, generalFileTypes)) {
      throw Exception(
          'Invalid file type. Allowed types: pdf, jpeg, xlsx, xls, png, jpg');
    }
    final response = await HttpUtils.postMultipart(
      url,
      file: file,
      fileKey: 'file',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      useInterceptor: true,
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == true) {
        return {
          'status': responseBody['status'],
          'message': responseBody['message'],
          'data': responseBody['data'],
        };
      } else {
        throw Exception(responseBody['msg'] ?? 'Unknown error');
      }
    } else {
      throw Exception('Failed to upload file');
    }
  }

  Future<Map<String, dynamic>> imageUpload(File file, String fileOf) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/Multifile?fileOf=$fileOf";
    if (!isValidFileType(file.path, imageFileTypes)) {
      throw Exception('Invalid image file type. Allowed types: jpg, jpeg, png, webp');
    }
    final response = await HttpUtils.postMultipart(
      url,
      file: file,
      fileKey: 'files',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      useInterceptor: true,
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == true) {
        return {
          'status': responseBody['status'],
          'message': responseBody['message'],
          'data': responseBody['data'],
        };
      } else {
        throw Exception(responseBody['msg'] ?? 'Unknown error');
      }
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<Map<String, dynamic>> photoUpload(
      List<File> files, String fileOf) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/Multifile?fileOf=$fileOf";
    if (files.isEmpty) {
      throw Exception('No files selected for upload');
    }
    for (var file in files) {
      if (!isValidFileType(file.path, imageFileTypes)) {
        throw Exception(
            'Invalid image file type. Allowed types: jpg, jpeg, png, webp');
      }
    }
    final response = await HttpUtils.photoMultipart(
      url,
      files: files,
      fileKey: 'files',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == true) {
        return {
          'status': responseBody['status'],
          'message': responseBody['message'],
          'data': responseBody['data'],
        };
      } else {
        throw Exception(responseBody['msg'] ?? 'Unknown error');
      }
    } else {
      throw Exception('Failed to upload images');
    }
  }

  Future<Map<String, dynamic>> photoFileUpload(
      List<File> files, String fileOf) async {
    final authUtils = AuthUtils();
    final tokens = await authUtils.getSessionTokens();
    final accessToken = tokens['accessToken'];
    String url = "/Multifile?fileOf=$fileOf";
    if (files.isEmpty) {
      throw Exception('No files selected for upload');
    }
    for (var file in files) {
      if (!isValidFileType(file.path, generalFileTypes)) {
        throw Exception(
            'Invalid file type. Allowed types: pdf, jpeg, xlsx, xls, png, jpg');
      }
    }
    final response = await HttpUtils.photoMultipart(
      url,
      files: files,
      fileKey: 'files',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      useInterceptor: true,
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == true) {
        return {
          'status': responseBody['status'],
          'message': responseBody['message'],
          'data': responseBody['data'],
        };
      } else {
        throw Exception(responseBody['msg'] ?? 'Unknown error');
      }
    } else {
      throw Exception('Failed to upload images');
    }
  }
}
