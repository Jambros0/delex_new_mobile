import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileUploadRepository {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();
  final RegExp imageFileTypes = RegExp(r'\.(jpg|jpeg|png)$');
  final RegExp generalFileTypes = RegExp(r'\.(pdf|jpeg|xlsx|xls|png|jpg)$');
  static const MethodChannel _platform = MethodChannel('media_scan_channel');
  bool isValidFileType(String fileName, RegExp allowedTypes) {
    return allowedTypes.hasMatch(fileName.toLowerCase());
  }

  Future<Map<String, dynamic>> uploadFile(File file, String fileOf) async {
    try {
      if (!isValidFileType(file.path, generalFileTypes)) {
        throw Exception(
            'Invalid file type. Allowed types: pdf, jpeg, xlsx, xls, png, jpg');
      }
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      final data = {
        'file_path': file.path,
        'file_type': file.path.split('.').last,
        'file_of': fileOf,
        'file_name': path.basename(file.path),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'created_by': userId,
        'updated_by': userId,
      };
      final String? userType = await authUtils.getUserType();
      final int primaryKeyId = (userType == 'onshore')
          ? await _dbHelper.uploadFilesOnshore(data)
          : await _dbHelper.uploadFiles(data);

      return {
        'status': true,
        'message': 'File uploaded successfully',
        'data': {
          'uploadStatus': {
            'file': data['file_path'],
            '_id': primaryKeyId.toString(),
            'createdAt': data['created_at'],
            'updatedAt': data['updated_at'],
            'originalName': data['file_name'],
          },
          'type': data['file_of'],
        }
      };
    } catch (e) {
      throw Exception("Failed to upload file: $e");
    }
  }

  Future<Map<String, dynamic>> uploadImage(File image, String fileOf) async {
    try {
      if (!isValidFileType(image.path, imageFileTypes)) {
        throw Exception(
            'Invalid image file type. Allowed types: jpg, jpeg, png');
      }
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final data = {
        'image_path': image.path,
        'image_type': image.path.split('.').last,
        'file_of': fileOf,
        'image_name': path.basename(image.path),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'created_by': userId,
        'updated_by': userId,
      };
      final String? userType = await authUtils.getUserType();
      final int primaryKeyId = (userType == 'onshore')
          ? await _dbHelper.uploadImageOnshore(data)
          : await _dbHelper.uploadImage(data);
      return {
        'status': true,
        'message': 'Image uploaded successfully',
        'data': {
          'uploadStatus': {
            'file': data['image_path'],
            '_id': primaryKeyId.toString(),
            'createdAt': data['created_at'],
            'updatedAt': data['updated_at'],
            'originalName': data['image_name'],
          },
          'type': data['file_of'],
        }
      };
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  bool _isImageFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(ext);
  }

  Future<File> _compressImageIfNeeded(File file) async {
    final bytes = await file.length();
    final sizeMB = bytes / (1024 * 1024);

    if (sizeMB <= 2.0) {
      return file;
    }

    int quality;
    if (sizeMB > 4.0) {
      quality = 70;
    } else if (sizeMB > 3.0) {
      quality = 75;
    } else {
      quality = 85;
    }

    final dir = file.parent.path;

    /// 🔹 Normalize filename (remove _compressed if present)
    String baseName = path.basenameWithoutExtension(file.path);
    final ext = path.extension(file.path);

    if (baseName.endsWith('_compressed')) {
      baseName = baseName.replaceAll('_compressed', '');
    }

    /// 🔹 Temp compression file
    final tempCompressedPath = '$dir/${baseName}_temp_compress$ext';

    final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tempCompressedPath,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: true,
      minWidth: 1920,
      minHeight: 1080,
    );

    if (compressed == null) {
      return file;
    }

    final compressedFile = File(compressed.path);
    final finalPath = '$dir/$baseName$ext';

    /// 🔹 Replace original safely
    try {
      if (await file.exists()) {
        await file.delete();
      }
      await compressedFile.rename(finalPath);
    } catch (_) {}

    return File(finalPath);
  }

  Future<Map<String, dynamic>> downloadAndCacheFile(
      String serverPath, String fileCategory) async {
    try {
      if (serverPath.isEmpty) {
        throw Exception("Invalid serverPath");
      }

      // Directory directory = Directory('');
      // if (Platform.isAndroid) {
      // directory = Directory('/storage/emulated/0/Download');
      // } else if (Platform.isIOS) {
      // directory = await getApplicationDocumentsDirectory();
      // }
      //  Directory localDir;
      // if (Platform.isAndroid) {
      //   localDir = Directory('/storage/emulated/0/Download/$fileCategory');
      // } else {
      //   localDir = await getApplicationDocumentsDirectory();
      // }
      // // final localDir = Directory('${directory.path}/$fileCategory');
      // if (!await localDir.exists()) {
      //   await localDir.create(recursive: true);
      // }

      final directory = await getTemporaryDirectory();
      final localDir = Directory('${directory.path}/$fileCategory');
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }

      final String? userType = await authUtils.getUserType();
      final String baseUrl = dotenv.env['API_URL'] ?? '';

      final cleanBaseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final Uri url = Uri.parse('$cleanBaseUrl/$userType/$serverPath');

      final fileName = path.basename(serverPath);
      final localFilePath = '${localDir.path}/$fileName';

      final httpClient = HttpClient();
      late File localFile;

      try {
        final request = await httpClient.getUrl(url);
        final response = await request.close();

        if (response.statusCode != 200) {
          throw Exception('Failed to download file');
        }

        localFile = File(localFilePath);
        await response.pipe(localFile.openWrite());
      } finally {
        httpClient.close();
      }

      // 🔹 Compress only image files
      if (_isImageFile(localFile.path)) {
        localFile = await _compressImageIfNeeded(localFile);
      }
      if (Platform.isAndroid) {
        try {
          await _platform.invokeMethod('scanFile', {'path': localFile.path});
        } catch (_) {}
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      final data = {
        'file_path': localFile.path,
        'file_type': path.extension(localFile.path).replaceFirst('.', ''),
        'file_of': fileCategory,
        'file_name': path.basename(localFile.path),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'created_by': userId,
        'updated_by': userId,
      };

      final int primaryKeyId = (userType == 'onshore')
          ? await _dbHelper.uploadFilesOnshore(data)
          : await _dbHelper.uploadFiles(data);
      return {
        'status': true,
        'message': 'File processed successfully',
        'data': {
          'uploadStatus': {
            'file': data['file_path'],
            '_id': primaryKeyId.toString(),
            'createdAt': data['created_at'],
            'updatedAt': data['updated_at'],
          },
          'type': data['file_of'],
        }
      };
    } catch (e) {
      throw Exception("Failed to process file: $e");
    }
  }

  Future<Map<String, dynamic>> downloadAndFullCacheFile(
      String serverPaths, String fileCategory) async {
    try {
      if (serverPaths.isEmpty) throw Exception("Invalid serverPath");
      dynamic serverPath = "media/${serverPaths.split("media/").last}";
      // Directory directory = Directory('');
      // if (Platform.isAndroid) {
      // directory = Directory('/storage/emulated/0/Download');
      // } else if (Platform.isIOS) {
      // directory = await getApplicationDocumentsDirectory();
      // }
      //  Directory localDir;
      // if (Platform.isAndroid) {
      //   localDir = Directory('/storage/emulated/0/Download/$fileCategory');
      // } else {
      //   localDir = await getApplicationDocumentsDirectory();
      // }
      // // final localDir = Directory('${directory.path}/$fileCategory');
      // if (!await localDir.exists()) {
      //   await localDir.create(recursive: true);
      // }
      final directory = await getTemporaryDirectory();
      final localDir = Directory('${directory.path}/$fileCategory');
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }
      // final userType = await AuthUtils().getUserType();
      final String? userType = await authUtils.getUserType();
      final String baseUrl = dotenv.env['API_URL'] ?? '';
      // final url = Uri.parse('$baseUrl').resolve('$userType/$serverPath');
      final cleanBaseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final String fullUrlString = '$cleanBaseUrl/$userType/$serverPath';
      final Uri url = Uri.parse(fullUrlString);

      final fileName = path.basename(serverPath);
      final localFilePath = '${localDir.path}/$fileName';
      final httpClient = HttpClient();
      File localFile;
      try {
        final HttpClientRequest request = await httpClient.getUrl(url);
        final HttpClientResponse response = await request.close();
        if (response.statusCode == 200) {
          localFile = File(localFilePath);
          await response.pipe(localFile.openWrite());
        } else {
          throw Exception('Failed to download file: ${response.statusCode}');
        }
      } finally {
        httpClient.close();
      }
      if (Platform.isAndroid) {
        try {
          await _platform.invokeMethod('scanFile', {
            'path': localFile.path,
          });
        } catch (e) {}
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final data = {
        'file_path': localFile.path,
        'file_type': path.extension(localFile.path).replaceFirst('.', ''),
        'file_of': fileCategory,
        'file_name': fileName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'created_by': userId,
        'updated_by': userId,
      };
      final int primaryKeyId = (userType == 'onshore')
          ? await _dbHelper.uploadFilesOnshore(data)
          : await _dbHelper.uploadFiles(data);
      return {
        'status': true,
        'message': 'File processed successfully',
        'data': {
          'uploadStatus': {
            'file': data['file_path'],
            '_id': primaryKeyId.toString(),
            'createdAt': data['created_at'],
            'updatedAt': data['updated_at'],
          },
          'type': data['file_of'],
        }
      };
    } catch (e) {
      throw Exception("Failed to process file: $e");
    }
  }
}
