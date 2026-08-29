// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'auth_util.dart';

// class FileDownloadUtil {
//   Future<Map<String, dynamic>> downloadFiles(url) async {
//     final authUtils = AuthUtils();
//     final tokens = await authUtils.getSessionTokens();
//     final accessToken = tokens['accessToken'];
//     final response = await HttpUtils.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       useInterceptor: true,
//     );
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       final String fileUrl = data['data']['url'] ?? '';
//       final String fileName = data['data']['fileName'] ?? '';
//       return {
//         'fileUrl': fileUrl,
//         'fileName': fileName,
//       };
//     } else {
//       throw Exception('Failed to load files');
//     }
//   }

//   Future<Uint8List> downloadFilesUsingURL(String url) async {
//     final authUtils = AuthUtils();
//     final tokens = await authUtils.getSessionTokens();
//     final accessToken = tokens['accessToken'];
//     final response = await HttpUtils.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       useInterceptor: true,
//     );
//     // final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       return response.bodyBytes;
//     } else {
//       throw Exception('Failed to load files');
//     }
//   }

//   Future<Map<String, dynamic>> removeFile({
//     required String fileName,
//   }) async {
//     final authUtils = AuthUtils();
//     final tokens = await authUtils.getSessionTokens();
//     final accessToken = tokens['accessToken'];
//     String url = "/remove-excel-file/$fileName";

//     final response = await HttpUtils.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       useInterceptor: true,
//     );

//     if (response.statusCode == 200) {
//       return {
//         'data': 'initiated',
//       };
//     } else {
//       throw Exception('Failed to remove file');
//     }
//   }

//   Future<String> getExternalDocumentPath() async {
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       await Permission.storage.request();
//     }
//     Directory directory = Directory("");
//     if (Platform.isAndroid) {
//       directory = Directory("/storage/emulated/0/Download");
//     } else {
//       directory = await getApplicationDocumentsDirectory();
//     }
//     final exPath = directory.path;
//     await Directory(exPath).create(recursive: true);
//     return exPath;
//   }

//   Future<String> get getLocalPath async {
//     final String directory = await getExternalDocumentPath();
//     return directory;
//   }
// }
