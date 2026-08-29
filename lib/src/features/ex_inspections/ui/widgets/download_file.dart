import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class FileHelper {
  static const MethodChannel _platform = MethodChannel('media_scan_channel');

  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 30) {
      // Android 11+
      if (await Permission.manageExternalStorage.isDenied) {
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          return await _showPermissionDialog(context);
        }
      }
    } else {
      // Android 10 and below
      if (await Permission.storage.isDenied) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission denied.")),
          );
          return false;
        }
      }
    }
    return true;
  }

  /// Show permission dialog
  static Future<bool> _showPermissionDialog(BuildContext context) async {
    bool openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
              "This app needs 'Manage External Storage' permission to proceed. Please allow it in settings.",
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text("Open Settings"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
    if (openSettings) {
      await openAppSettings();
    }
    return openSettings;
  }

  /// Download and open file
  static Future<Map<String, dynamic>> downloadAndOpenFile({
    required BuildContext context,
    required String sourceFilePath,
    // String? customFileName,
  }) async {
    try {
      final hasPermission = await requestStoragePermission(context);
      if (!hasPermission) {
        return {"error": "Required storage permission denied"};
      }

      // Determine directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        return {"error": "Unable to access downloads directory"};
      }

      // File handling
      final fileExtension = sourceFilePath.split('.').last;
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}.$fileExtension";
      final downloadFile = File("${downloadsDir.path}/$fileName");
      await downloadFile.writeAsBytes(await File(sourceFilePath).readAsBytes());

      if (!await downloadFile.exists()) {
        return {"error": "Failed to create the file"};
      }

      // Media scanner (Android only)
      if (Platform.isAndroid) {
        await _platform.invokeMethod('scanFile', {'path': downloadFile.path});
      }

      // Open file
      await Future.delayed(const Duration(seconds: 1));
      await OpenFilex.open(downloadFile.path);

      // if (result.type != ResultType.done) {
      //   return {"error": "Failed to open file: ${result.message}"};
      // }

      return {"location": downloadFile.path};
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download unavailable. File attachment is missing.'),
        ),
      );
      return {"error": e.toString()};
    }
  }
}
