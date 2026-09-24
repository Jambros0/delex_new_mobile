

// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/repository/work_order_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/widgets/device_to_server_sync.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/widgets/device_to_server_table.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/widgets/server_to_device_table.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/progress_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncPopupScreen extends StatefulWidget {
  final String title;
  final String buttonText;

  const SyncPopupScreen({
    super.key,
    required this.title,
    required this.buttonText,
  });

  @override
  DeviceSyncScreenState createState() => DeviceSyncScreenState();
}

class DeviceSyncScreenState extends State<SyncPopupScreen> {
  List<bool> _selectedRows = [];
  late DeviceToServerSync deviceToServerSync;
  bool _isLoading = false;
  double _syncProgress = 0.0;
  List<ExRegister> getAssets = [];
  // List<ExRegister> selectedAssets = [];
  Map<String, List<String>> collectionSelectedFilter = {};
  List<String> selectedFilters = [];
  List<ExRegister> registerCollections = [];
  List<String> selectedAssetsSync = [];
  final deviceSyncService = DeviceSyncServices();
  void _updateSyncProgress(double progress) {
    setState(() {
      _syncProgress = progress;
    });
  }

  void _setLoadingState(bool value) {
    setState(() {
      _isLoading = value;
      if (!value) _syncProgress = 0.0;
    });
  }

  @override
  void initState() {
    collectionSelectedFilter = {};
    super.initState();
    _initializeBloc();
    getAssets = [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeBloc() {
    if (widget.title == 'Data Transfer To Device') {
      BlocProvider.of<DeviceSyncBloc>(context).add(LoadWorkOrder());
    } else if (widget.title == 'Data Transfer To Server') {
      BlocProvider.of<ToServerBloc>(context).add(WorkOrderToServerLoad());
    }
  }

  void _onRowSelected(int index, List<bool> rowSelection) {
    setState(() {
      if (widget.title == 'Data Transfer To Device') {
        _selectedRows[index] = !_selectedRows[index];
      } else {
        _selectedRows = List<bool>.from(rowSelection);
      }
    });
  }

  void _insertSelectedRowsIntoDatabase(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
      context,
    );

    _setLoadingState(true);
    try {
      final state = BlocProvider.of<DeviceSyncBloc>(context).state;
      List<ExRegister> selectedAssets = [];
      List<WorkOrderTableJson> workOrderCollection = [];
      List<ExRegister> stateAssets = [];
      if (state is WorkOrderLoaded) {
        stateAssets = state.assets;
        workOrderCollection = state.workOrderCollection;
      } else if (state is WorkOrderNewLoaded) {
        stateAssets = state.assets;
        workOrderCollection = state.workOrderCollection;
      }

      if (stateAssets.isNotEmpty) {
        if (_selectedRows.length != stateAssets.length) {
          _selectedRows = List<bool>.filled(stateAssets.length, false, growable: true);
        }
        for (int i = 0; i < _selectedRows.length; i++) {
          if (_selectedRows[i]) {
            selectedAssets.add(stateAssets[i]);
          }
        }
        if (selectedAssets.isNotEmpty) {
          await _insertIntoLocalDB(
            context,
            selectedAssets,
            navigator,
            scaffoldMessenger,
            workOrderCollection,
          );
        } else {
          _closeDialogIfOpen(navigator);
          _showToast("No items selected.", Colors.red, scaffoldMessenger);
        }
      } else {
        _closeDialogIfOpen(navigator);
        _showToast("No items selected.", Colors.red, scaffoldMessenger);
      }
    } finally {
      _setLoadingState(false);
    }
  }

  /// Downloads a remote server file and saves it permanently to app documents directory
  Future<String?> _downloadAndSaveFile({
    required String remotePath,
    required String category,
    required String? defaultUserType,
    required String? token,
    required String userId,
    required DBHelper dbHelper,
  }) async {
    final trimmed = remotePath.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;

    // If already exists as a local file, reuse it
    if (File(trimmed).existsSync()) {
      return trimmed;
    }

    final rawBaseUrl =
        (dotenv.env['API_URL'] ?? 'http://94.136.185.87:16000/').trim();
    final cleanBaseUrl = rawBaseUrl.endsWith('/')
        ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
        : rawBaseUrl;

    final List<String> candidateUrls = [];

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      candidateUrls.add(trimmed);
    } else {
      String cleanPath = trimmed;
      while (cleanPath.startsWith('/')) {
        cleanPath = cleanPath.substring(1);
      }

      if (cleanPath.startsWith('onshore/') ||
          cleanPath.startsWith('offshore/')) {
        candidateUrls.add('$cleanBaseUrl/$cleanPath');
      } else {
        final userType = (defaultUserType != null && defaultUserType.isNotEmpty)
            ? defaultUserType.toLowerCase()
            : 'onshore';
        candidateUrls.add('$cleanBaseUrl/$userType/$cleanPath');

        final altUserType = (userType == 'onshore') ? 'offshore' : 'onshore';
        candidateUrls.add('$cleanBaseUrl/$altUserType/$cleanPath');

        candidateUrls.add('$cleanBaseUrl/$cleanPath');
      }
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${appDocDir.path}/$category');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final originalName = path.basename(trimmed.split('?').first);
    final sanitizedName = originalName.isEmpty
        ? 'file_${DateTime.now().millisecondsSinceEpoch}'
        : originalName;
    final localFilePath = '${targetDir.path}/$sanitizedName';
    final localFile = File(localFilePath);

    if (await localFile.exists() && await localFile.length() > 0) {
      return localFile.path;
    }

    final client = http.Client();
    try {
      for (final urlStr in candidateUrls) {
        try {
          final uri = Uri.parse(urlStr);
          final headers = <String, String>{};
          if (token != null && token.isNotEmpty) {
            headers['Authorization'] = 'Bearer $token';
          }
          final res = await client.get(uri, headers: headers).timeout(
            const Duration(seconds: 15),
          );
          if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
            await localFile.writeAsBytes(res.bodyBytes);

            if (Platform.isAndroid) {
              try {
                const MethodChannel('media_scan_channel')
                    .invokeMethod('scanFile', {'path': localFile.path});
              } catch (_) {}
            }

            try {
              final dbData = {
                'file_path': localFile.path,
                'file_type':
                    path.extension(localFile.path).replaceFirst('.', ''),
                'file_of': category,
                'file_name': path.basename(localFile.path),
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
                'created_by': userId,
                'updated_by': userId,
              };
              if (defaultUserType == 'onshore') {
                await dbHelper.uploadFilesOnshore(dbData);
              } else {
                await dbHelper.uploadFiles(dbData);
              }
            } catch (_) {}

            return localFile.path;
          }
        } catch (_) {
          // Try next candidate URL
        }
      }
    } finally {
      client.close();
    }

    return null;
  }

  /// Safely converts an asset object (whether ExRegister, Map, or other) to a Map
  Map<String, dynamic> _safeAssetToJson(dynamic asset) {
    if (asset == null) return {};
    if (asset is Map<String, dynamic>) {
      return Map<String, dynamic>.from(asset);
    }
    if (asset is Map) {
      return Map<String, dynamic>.from(asset);
    }
    try {
      if (asset is ExRegister) {
        return asset.toJson();
      }
      return Map<String, dynamic>.from((asset as dynamic).toJson());
    } catch (_) {
      try {
        return jsonDecode(jsonEncode(asset));
      } catch (_) {
        return {};
      }
    }
  }

  /// Processes and downloads all media files (photos, signatures, datasheets, certs, drawings)
  /// and updates paths in the asset JSON to local persistent paths
  Future<Map<String, dynamic>> _processAssetMediaFiles(
    Map<String, dynamic> assetJson,
    String userId,
    String? userType,
    String? token,
    DBHelper dbHelper,
  ) async {
    final updated = Map<String, dynamic>.from(assetJson);

    // 1. Defective and Corrective Photos (1 to 6)
    for (int p = 1; p <= 6; p++) {
      final dKey = 'defectivePhoto$p';
      final dVal = updated[dKey]?.toString();
      if (dVal != null && dVal.isNotEmpty && dVal != 'null') {
        final localPath = await _downloadAndSaveFile(
          remotePath: dVal,
          category: 'defectivePhotos',
          defaultUserType: userType,
          token: token,
          userId: userId,
          dbHelper: dbHelper,
        );
        if (localPath != null) {
          updated[dKey] = localPath;
        }
      }
      final dOrgKey = 'defectivePhoto${p}OrgName';
      if ((updated[dOrgKey] == null ||
              updated[dOrgKey].toString().trim().isEmpty ||
              updated[dOrgKey].toString() == 'null') &&
          updated[dKey] != null &&
          updated[dKey].toString().isNotEmpty &&
          updated[dKey].toString() != 'null') {
        updated[dOrgKey] = path.basename(updated[dKey].toString());
      }

      final cKey = 'correctivePhoto$p';
      final cVal = updated[cKey]?.toString();
      if (cVal != null && cVal.isNotEmpty && cVal != 'null') {
        final localPath = await _downloadAndSaveFile(
          remotePath: cVal,
          category: 'correctivePhotos',
          defaultUserType: userType,
          token: token,
          userId: userId,
          dbHelper: dbHelper,
        );
        if (localPath != null) {
          updated[cKey] = localPath;
        }
      }
      final cOrgKey = 'correctivePhoto${p}OrgName';
      if ((updated[cOrgKey] == null ||
              updated[cOrgKey].toString().trim().isEmpty ||
              updated[cOrgKey].toString() == 'null') &&
          updated[cKey] != null &&
          updated[cKey].toString().isNotEmpty &&
          updated[cKey].toString() != 'null') {
        updated[cOrgKey] = path.basename(updated[cKey].toString());
      }
    }

    // 2. Datasheet (and populate OrgName & No so Download button appears)
    final dsVal = updated['dataSheet']?.toString();
    if (dsVal != null && dsVal.isNotEmpty && dsVal != 'null') {
      final localPath = await _downloadAndSaveFile(
        remotePath: dsVal,
        category: 'attachments',
        defaultUserType: userType,
        token: token,
        userId: userId,
        dbHelper: dbHelper,
      );
      if (localPath != null) {
        updated['dataSheet'] = localPath;
      }
    }
    if ((updated['dataSheetOrgName'] == null ||
            updated['dataSheetOrgName'].toString().trim().isEmpty ||
            updated['dataSheetOrgName'].toString() == 'null') &&
        updated['dataSheet'] != null &&
        updated['dataSheet'].toString().isNotEmpty &&
        updated['dataSheet'].toString() != 'null') {
      updated['dataSheetOrgName'] =
          path.basename(updated['dataSheet'].toString());
    }
    if ((updated['dataSheetNo'] == null ||
            updated['dataSheetNo'].toString().trim().isEmpty ||
            updated['dataSheetNo'].toString() == 'null') &&
        updated['dataSheet'] != null &&
        updated['dataSheet'].toString().isNotEmpty &&
        updated['dataSheet'].toString() != 'null') {
      updated['dataSheetNo'] = path.basename(updated['dataSheet'].toString());
    }

    // 3. Signatures (inspectionSignOff, repairSignOff, signature)
    final sigFields = ['inspectionSignOff', 'repairSignOff', 'signature'];
    for (final sigField in sigFields) {
      final sigVal = updated[sigField]?.toString();
      if (sigVal != null && sigVal.isNotEmpty && sigVal != 'null') {
        final localPath = await _downloadAndSaveFile(
          remotePath: sigVal,
          category: 'signatures',
          defaultUserType: userType,
          token: token,
          userId: userId,
          dbHelper: dbHelper,
        );
        if (localPath != null) {
          updated[sigField] = localPath;
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(sigField, localPath);
            await prefs.setString('userSignature', localPath);
            final appDocDir = await getApplicationDocumentsDirectory();
            final fallbackFile = File('${appDocDir.path}/user_signature.jpg');
            await File(localPath).copy(fallbackFile.path);
          } catch (_) {}
        }
      }
    }

    // 4. Certifications (defectCertificationAttach, correctiveCertificationAttach)
    for (final certField in [
      'defectCertificationAttach',
      'correctiveCertificationAttach',
    ]) {
      final certVal = updated[certField]?.toString();
      if (certVal != null && certVal.isNotEmpty && certVal != 'null') {
        final localPath = await _downloadAndSaveFile(
          remotePath: certVal,
          category: 'certifications',
          defaultUserType: userType,
          token: token,
          userId: userId,
          dbHelper: dbHelper,
        );
        if (localPath != null) {
          updated[certField] = localPath;
        }
      }
      final orgField = certField.replaceFirst('Attach', 'OrgName');
      if ((updated[orgField] == null ||
              updated[orgField].toString().trim().isEmpty ||
              updated[orgField].toString() == 'null') &&
          updated[certField] != null &&
          updated[certField].toString().isNotEmpty &&
          updated[certField].toString() != 'null') {
        updated[orgField] = path.basename(updated[certField].toString());
      }
    }

    // 5. Materials & Supplementary Material Requirements
    for (final matKey in ['materials', 'supplementaryMaterialReq']) {
      if (updated[matKey] != null && updated[matKey] is List) {
        final List list = updated[matKey];
        for (var item in list) {
          if (item is Map) {
            final certPath = item['certificationAttach']?.toString();
            if (certPath != null && certPath.isNotEmpty && certPath != 'null') {
              final localPath = await _downloadAndSaveFile(
                remotePath: certPath,
                category: 'certifications',
                defaultUserType: userType,
                token: token,
                userId: userId,
                dbHelper: dbHelper,
              );
              if (localPath != null) {
                item['certificationAttach'] = localPath;
              }
            }
            if ((item['certificationOrgName'] == null ||
                    item['certificationOrgName'].toString().trim().isEmpty ||
                    item['certificationOrgName'].toString() == 'null') &&
                item['certificationAttach'] != null &&
                item['certificationAttach'].toString().isNotEmpty &&
                item['certificationAttach'].toString() != 'null') {
              item['certificationOrgName'] =
                  path.basename(item['certificationAttach'].toString());
            }
          }
        }
      }
    }

    // 6. Drawings (areaClassDrawAttach and eqpmtLytDrawAttach)
    for (final drawKey in ['areaClassDrawAttach', 'eqpmtLytDrawAttach']) {
      if (updated[drawKey] != null) {
        if (updated[drawKey] is List) {
          final List list = updated[drawKey];
          final List<String> updatedDrawings = [];
          for (var item in list) {
            final str = item?.toString() ?? '';
            if (str.isNotEmpty && str != 'null') {
              final localPath = await _downloadAndSaveFile(
                remotePath: str,
                category: 'drawings',
                defaultUserType: userType,
                token: token,
                userId: userId,
                dbHelper: dbHelper,
              );
              updatedDrawings.add(localPath ?? str);
            }
          }
          updated[drawKey] = updatedDrawings;
        } else if (updated[drawKey] is String) {
          final str = updated[drawKey].toString();
          if (str.isNotEmpty && str != 'null') {
            final localPath = await _downloadAndSaveFile(
              remotePath: str,
              category: 'drawings',
              defaultUserType: userType,
              token: token,
              userId: userId,
              dbHelper: dbHelper,
            );
            if (localPath != null) {
              updated[drawKey] = localPath;
            }
          }
        }
      }
    }

    return updated;
  }

  Future<void> _insertIntoLocalDB(
    BuildContext context,
    List<ExRegister> assets,
    NavigatorState navigator,
    ScaffoldMessengerState scaffoldMessenger,
    List<WorkOrderTableJson> workOrderCollection,
  ) async {
    final repository = WorkOrderRepository();
    final dbHelper = DBHelper();
    final authUtils = AuthUtils();
    final userType = await authUtils.getUserType();
    final tokens = await authUtils.getSessionTokens();
    final token = tokens['accessToken'];

    final UserDetails? loggedInUser = await dbHelper.getLoggedInUser();
    final currentUserId = await authUtils.getUserId();
    final userId = (currentUserId != null && currentUserId.isNotEmpty)
        ? currentUserId
        : (loggedInUser?.userId ?? '');
    if (userId.isEmpty) {
      _closeDialogIfOpen(navigator);
      _showToast(
        "Failed to fetch logged-in user.",
        Colors.red,
        scaffoldMessenger,
      );
      return;
    }
    try {
      // Clear stale state from any previous transfer call
      selectedAssetsSync.clear();

      // Use unique asset IDs for accurate progress tracking
      final uniqueAssetIds = assets.map((a) => a.id).where((id) => id.isNotEmpty).toSet();
      int totalAssetsToSync = uniqueAssetIds.length;
      if (totalAssetsToSync == 0) totalAssetsToSync = assets.length;
      int syncedCount = 0;
      final List<String> failedAssetIds = [];

      for (int j = 0; j < workOrderCollection.length; j++) {
        final json = workOrderCollection[j].toJson();
        for (int i = 0; i < workOrderCollection[j].assets.length; i++) {
          // Only process assets that are in the selectedAssets list
          var asset = workOrderCollection[j].assets[i];
          if (!assets.any((ass) => ass.id == asset.id)) {
            continue;
          }
          selectedAssetsSync.add(asset.id);
          var assetMap = _safeAssetToJson(asset);

          // Checklist processing
          if (assetMap['checkList'] is List) {
            final List clList = assetMap['checkList'];
            final List<Map<String, dynamic>> processedCheckList = [];
            for (var item in clList) {
              if (item is Map) {
                processedCheckList.add(Map<String, dynamic>.from(item));
              } else {
                try {
                  processedCheckList.add(
                      Map<String, dynamic>.from((item as dynamic).toJson()));
                } catch (_) {}
              }
            }
            assetMap['checkList'] = processedCheckList;
            if (assetMap['checkList'].isNotEmpty &&
                (assetMap['yesNoSelection'] == null ||
                    assetMap['yesNoSelection'].isEmpty)) {
              assetMap['yesNoSelection'] ??= <String, dynamic>{};
              for (var checklist in assetMap['checkList']) {
                if (checklist is Map && checklist['defectCodes'] is List) {
                  for (var defectCodes in checklist['defectCodes']) {
                    if (defectCodes is Map &&
                        defectCodes['defectCode'] != null) {
                      assetMap['yesNoSelection'][defectCodes['defectCode']] =
                          "no";
                    }
                  }
                }
              }
            }
          }

          // Download and persist all media files locally
          assetMap = await _processAssetMediaFiles(
            assetMap,
            userId,
            userType,
            token,
            dbHelper,
          );

          final matchingAsset = assets.firstWhere((ass) => ass.id == asset.id, orElse: () => asset);
          assetMap['subLocation'] = matchingAsset.area.isNotEmpty ? matchingAsset.area : asset.area;
          assetMap['platform'] = assetMap['subLocation'];
          assetMap['area'] = assetMap['subLocation'];
          assetMap['deckLevel'] = matchingAsset.deckLevel ?? asset.deckLevel ?? json['deckLevel'] ?? '';
          assetMap['subArea'] = (matchingAsset.subArea != null && matchingAsset.subArea.toString().isNotEmpty)
              ? matchingAsset.subArea
              : (asset.subArea ?? json['subArea'] ?? '');
          assetMap['locationGasGroup'] = matchingAsset.locationGasGroup.isNotEmpty
              ? matchingAsset.locationGasGroup
              : (asset.locationGasGroup.isNotEmpty ? asset.locationGasGroup : (json['locationGasGroup'] ?? []));
          assetMap['locationTClass'] = matchingAsset.locationTClass.isNotEmpty
              ? matchingAsset.locationTClass
              : (asset.locationTClass.isNotEmpty ? asset.locationTClass : (json['locationTClass'] ?? []));
          assetMap['locationIpRating'] = matchingAsset.locationIpRating.isNotEmpty
              ? matchingAsset.locationIpRating
              : (asset.locationIpRating.isNotEmpty ? asset.locationIpRating : (json['locationIpRating'] ?? []));
          assetMap['locationTAmbient'] = matchingAsset.locationTAmbient.isNotEmpty
              ? matchingAsset.locationTAmbient
              : (asset.locationTAmbient.isNotEmpty ? asset.locationTAmbient : (json['tAmbient'] ?? json['locationTAmbient'] ?? ''));
          assetMap['tAmbient'] = assetMap['locationTAmbient'];
          assetMap['locationLatitude'] = matchingAsset.locationLatitude ?? asset.locationLatitude ?? json['locationLatitude'] ?? '';
          assetMap['locationLongitude'] = matchingAsset.locationLongitude ?? asset.locationLongitude ?? json['locationLongitude'] ?? '';
          assetMap['gpsCord'] = matchingAsset.gpsCord ?? asset.gpsCord ?? json['gpsCoordinates'] ?? json['gpsCord'] ?? '';
          assetMap['areaClassDrawNo'] = matchingAsset.areaClassDrawNo.isNotEmpty
              ? matchingAsset.areaClassDrawNo
              : (asset.areaClassDrawNo.isNotEmpty ? asset.areaClassDrawNo : (json['areaClassDrawNo'] ?? []));
          assetMap['areaClassDrawAttachOrgName'] = matchingAsset.areaClassDrawAttachOrgName.isNotEmpty
              ? matchingAsset.areaClassDrawAttachOrgName
              : (asset.areaClassDrawAttachOrgName.isNotEmpty ? asset.areaClassDrawAttachOrgName : (json['areaClassDrawAttachOrgName'] ?? assetMap['areaClassDrawNo']));
          assetMap['areaClassDrawAttach'] = matchingAsset.areaClassDrawAttach.isNotEmpty
              ? matchingAsset.areaClassDrawAttach
              : (asset.areaClassDrawAttach.isNotEmpty ? asset.areaClassDrawAttach : (json['areaClassDrawAttach'] ?? []));
          assetMap['eqpmtLytDrawNo'] = matchingAsset.eqpmtLytDrawNo.isNotEmpty
              ? matchingAsset.eqpmtLytDrawNo
              : (asset.eqpmtLytDrawNo.isNotEmpty ? asset.eqpmtLytDrawNo : (json['eqpmtLytDrawNo'] ?? []));
          assetMap['eqpmtLytDrawAttachOrgName'] = matchingAsset.eqpmtLytDrawAttachOrgName.isNotEmpty
              ? matchingAsset.eqpmtLytDrawAttachOrgName
              : (asset.eqpmtLytDrawAttachOrgName.isNotEmpty ? asset.eqpmtLytDrawAttachOrgName : (json['eqpmtLytDrawAttachOrgName'] ?? assetMap['eqpmtLytDrawNo']));
          assetMap['eqpmtLytDrawAttach'] = matchingAsset.eqpmtLytDrawAttach.isNotEmpty
              ? matchingAsset.eqpmtLytDrawAttach
              : (asset.eqpmtLytDrawAttach.isNotEmpty ? asset.eqpmtLytDrawAttach : (json['eqpmtLytDrawAttach'] ?? []));
          assetMap['areaStatus'] = matchingAsset.areaStatus ?? asset.areaStatus ?? json['areaStatus'] ?? 'Active';
          assetMap['locationId'] = matchingAsset.locationId.isNotEmpty
              ? matchingAsset.locationId
              : (asset.locationId.isNotEmpty ? asset.locationId : (json['locationId'] ?? ''));

          json['subLocation'] = assetMap['subLocation'];
          json['platform'] = assetMap['platform'];
          json['area'] = assetMap['area'];
          json['deckLevel'] = assetMap['deckLevel'];
          json['subArea'] = assetMap['subArea'];
          json['locationGasGroup'] = assetMap['locationGasGroup'];
          json['locationTClass'] = assetMap['locationTClass'];
          json['locationIpRating'] = assetMap['locationIpRating'];
          json['tAmbient'] = assetMap['tAmbient'];
          json['locationLatitude'] = assetMap['locationLatitude'];
          json['locationLongitude'] = assetMap['locationLongitude'];
          json['gpsCoordinates'] = assetMap['gpsCord'];
          json['areaClassDrawNo'] = assetMap['areaClassDrawNo'];
          json['areaClassDrawAttach'] = assetMap['areaClassDrawAttach'];
          json['areaClassDrawAttachOrgName'] = assetMap['areaClassDrawAttachOrgName'];
          json['eqpmtLytDrawNo'] = assetMap['eqpmtLytDrawNo'];
          json['eqpmtLytDrawAttach'] = assetMap['eqpmtLytDrawAttach'];
          json['eqpmtLytDrawAttachOrgName'] = assetMap['eqpmtLytDrawAttachOrgName'];

          json['assets'] = assetMap;

          final workOrder = {
            'id': json['assets']['_id'] ?? json['assets']['id'] ?? asset.id,
            'work_order_json': json,
            'created_by': userId,
            'updated_by': userId,
            'owner_user_id': userId, // Bind to current user for isolation
          };
          try {
            await repository.insertWorkOrderAsset(workOrder);
          } catch (e) {
            failedAssetIds.add(asset.id);
            debugPrint('⚠️ Transfer failed for asset ${asset.id}: $e');
          }

          syncedCount++;

          double progress = syncedCount / totalAssetsToSync;
          _updateSyncProgress(progress);
        }
      }

      for (final asset in assets) {
        if (!selectedAssetsSync.contains(asset.id)) {
          selectedAssetsSync.add(asset.id);
          var assetJson = _safeAssetToJson(asset);

          // Checklist processing
          if (assetJson['checkList'] is List) {
            final List clList = assetJson['checkList'];
            final List<Map<String, dynamic>> processedCheckList = [];
            for (var item in clList) {
              if (item is Map) {
                processedCheckList.add(Map<String, dynamic>.from(item));
              } else {
                try {
                  processedCheckList.add(
                      Map<String, dynamic>.from((item as dynamic).toJson()));
                } catch (_) {}
              }
            }
            assetJson['checkList'] = processedCheckList;
            if (assetJson['checkList'].isNotEmpty &&
                (assetJson['yesNoSelection'] == null ||
                    assetJson['yesNoSelection'].isEmpty)) {
              assetJson['yesNoSelection'] ??= <String, dynamic>{};
              for (var checklist in assetJson['checkList']) {
                if (checklist is Map && checklist['defectCodes'] is List) {
                  for (var defectCodes in checklist['defectCodes']) {
                    if (defectCodes is Map &&
                        defectCodes['defectCode'] != null) {
                      assetJson['yesNoSelection'][defectCodes['defectCode']] =
                          "no";
                    }
                  }
                }
              }
            }
          }

          // Download and persist all media files locally for fallback assets
          assetJson = await _processAssetMediaFiles(
            assetJson,
            userId,
            userType,
            token,
            dbHelper,
          );

          assetJson['subLocation'] = asset.area;
          assetJson['platform'] = asset.area;
          assetJson['area'] = asset.area;
          assetJson['deckLevel'] = asset.deckLevel ?? '';
          assetJson['subArea'] = asset.subArea ?? '';
          assetJson['locationGasGroup'] = asset.locationGasGroup;
          assetJson['locationTClass'] = asset.locationTClass;
          assetJson['locationIpRating'] = asset.locationIpRating;
          assetJson['locationTAmbient'] = asset.locationTAmbient;
          assetJson['tAmbient'] = asset.locationTAmbient;
          assetJson['locationLatitude'] = asset.locationLatitude ?? '';
          assetJson['locationLongitude'] = asset.locationLongitude ?? '';
          assetJson['gpsCord'] = asset.gpsCord ?? '';
          assetJson['areaClassDrawNo'] = asset.areaClassDrawNo;
          assetJson['areaClassDrawAttach'] = asset.areaClassDrawAttach;
          assetJson['areaClassDrawAttachOrgName'] = asset.areaClassDrawAttachOrgName;
          assetJson['eqpmtLytDrawNo'] = asset.eqpmtLytDrawNo;
          assetJson['eqpmtLytDrawAttach'] = asset.eqpmtLytDrawAttach;
          assetJson['eqpmtLytDrawAttachOrgName'] = asset.eqpmtLytDrawAttachOrgName;
          assetJson['areaStatus'] = asset.areaStatus ?? 'Active';
          assetJson['locationId'] = asset.locationId;

          final syntheticJson = {
            '_id': 'wo_${asset.id}',
            'woNumber': 'WO-${asset.id}',
            'woType': 'Inspection',
            'discipline': asset.eqpmtCatg,
            'woDate': DateTime.now().toIso8601String(),
            'department': '',
            'maintanaceType': '',
            'description': asset.description,
            'startDate': DateTime.now().toIso8601String(),
            'endDate': DateTime.now().toIso8601String(),
            'duration': '',
            'permitType': '',
            'priority': '',
            'attachments': '',
            'createdBy': userId,
            'isActive': true,
            'total': '1',
            'completed': '0',
            'status': 'Open',
            'remark': '',
            'attachementUrl': '',
            'fieldName': asset.location,
            'location': asset.location,
            'platform': asset.area,
            'subLocation': asset.area,
            'deckLevel': asset.deckLevel ?? '',
            'area': asset.deckLevel ?? '',
            'subArea': asset.subArea ?? '',
            'locationGasGroup': asset.locationGasGroup,
            'locationTClass': asset.locationTClass,
            'locationIpRating': asset.locationIpRating,
            'tAmbient': asset.locationTAmbient,
            'locationLatitude': asset.locationLatitude ?? '',
            'locationLongitude': asset.locationLongitude ?? '',
            'gpsCoordinates': asset.gpsCord ??
                (asset.locationLatitude != null && asset.locationLongitude != null
                    ? '${asset.locationLatitude}, ${asset.locationLongitude}'
                    : ''),
            'areaClassDrawNo': asset.areaClassDrawNo,
            'areaClassDrawAttach': asset.areaClassDrawAttach,
            'areaClassDrawAttachOrgName': asset.areaClassDrawAttachOrgName,
            'eqpmtLytDrawNo': asset.eqpmtLytDrawNo,
            'eqpmtLytDrawAttach': asset.eqpmtLytDrawAttach,
            'eqpmtLytDrawAttachOrgName': asset.eqpmtLytDrawAttachOrgName,
            'assets': assetJson,
          };
          final workOrder = {
            'id': asset.id,
            'work_order_json': syntheticJson,
            'created_by': userId,
            'updated_by': userId,
            'owner_user_id': userId, // Bind to current user for isolation
          };
          try {
            await repository.insertWorkOrderAsset(workOrder);
          } catch (e) {
            failedAssetIds.add(asset.id);
            debugPrint('⚠️ Transfer failed for asset ${asset.id} (fallback): $e');
          }
          syncedCount++;
          double progress = syncedCount / totalAssetsToSync;
          _updateSyncProgress(progress);
        }
      }
      if (failedAssetIds.isNotEmpty) {
        debugPrint('⚠️ Transfer completed with ${failedAssetIds.length} failed assets: $failedAssetIds');
      }
      final prefs = await SharedPreferences.getInstance();
      final existingIds = (prefs.getStringList('asset_ids') ?? [])
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final selectedIds = selectedAssetsSync
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final updatedIds = List<String>.from(existingIds);
      for (final id in selectedIds) {
        updatedIds.remove(id);
      }
      await prefs.setStringList('asset_ids', updatedIds);
      try {
        await deviceSyncService.syncServertoDeviceStatus(
          selectedIds,
        );
      } catch (e) {
        // Continue if server status update fails; local DB insertion succeeded
      }

      if (context.mounted) {
        BlocProvider.of<DeviceSyncBloc>(context).add(
          RemoveTransferredAssetsFromDeviceSync(selectedIds),
        );
      }

      _closeDialogIfOpen(navigator);
      _showToast(
        "Items inserted into local DB successfully.",
        Colors.green,
        scaffoldMessenger,
      );
    } catch (e) {
      _closeDialogIfOpen(navigator);
      _showToast("Error: ${e.toString()}", Colors.red, scaffoldMessenger);
    }
  }

  Future<void> _insertSelectedRowsIntoServer(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final progressNotifier = ProgressNotifier();

    progressNotifier.addListener(() {
      if (!mounted) return;
      _updateSyncProgress(progressNotifier.progress);
    });

    _setLoadingState(true);
    progressNotifier.reset();

    try {
      final state = BlocProvider.of<ToServerBloc>(context).state;
      if (state is WorkOrderToServerLoaded) {
        List<ExRegister> allAssets = state.assets;
        if (allAssets.isEmpty) {
          _closeDialogIfOpen(navigator);
          _showToast(
            "No assets available to transfer.",
            Colors.red,
            scaffoldMessenger,
          );
          return;
        }
        // selectedAssets.clear();
        List<ExRegister> selectedAssets = [];
        if (_selectedRows.length != allAssets.length) {
          _selectedRows = List<bool>.filled(allAssets.length, false, growable: true);
        }
        for (int i = 0; i < _selectedRows.length; i++) {
          if (_selectedRows[i]) {
            selectedAssets.add(allAssets[i]);
          }
        }
        if (selectedAssets.isEmpty) {
          _closeDialogIfOpen(navigator);
          _showToast("No items selected.", Colors.red, scaffoldMessenger);
          return;
        }
        try {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString('userId');
          if (userId == null) {
            throw Exception("LoggedIn User Not Found");
          }
          final deviceToServerSync = DeviceToServerSync(
            assets: selectedAssets,
            loggedInUser: userId,
          );
          await deviceToServerSync.insertAssetsIntoServer(
            context,
            progressNotifier,
          );
          if (!mounted) return;
          _closeDialogIfOpen(navigator);
          _showToast(
            "Items inserted into server successfully.",
            Colors.green,
            scaffoldMessenger,
          );

          _selectedRows = [];
          BlocProvider.of<ToServerBloc>(context).add(WorkOrderToServerLoad());
        } catch (e) {
          if (!mounted) return;
          _closeDialogIfOpen(navigator);

          if (e.toString().contains(
                "Looking up a deactivated widget's ancestor is unsafe",
              )) {
            // Do not show toast for this specific error
          } else if (e.toString().contains(
                "Null check operator used on a null value",
              )) {
          } else {
            _showToast("Error: ${e.toString()}", Colors.red, scaffoldMessenger);
          }
        }
      }
    } finally {
      _setLoadingState(false);
    }
  }

  void _closeDialogIfOpen(NavigatorState navigator) {
    if (navigator.canPop()) {
      final now = DateTime.now();

      final navigationArguments = {
        'menu': 'Ex Register',
        'filter': 'Show All',
        'fromDatefilter': DateTime(2024, 1, 1),
        'ToDatefilter': DateTime(now.year, now.month, now.day),
        'fltertype': "Year to Date",
        'isCollapsed': true,
        'isSelectedScreen': "Device Sync",
        'isSelectedScreenFlag': false,
      };

      // Pop the dialog
      navigator.pop();

      // Use WidgetsBinding to delay navigation until safely mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.context.mounted) {
          Navigator.pushReplacementNamed(
            navigator.context,
            '/home',
            arguments: navigationArguments,
          );
        }
      });
    }
  }

  void _showToast(
    String message,
    Color backgroundColor,
    ScaffoldMessengerState scaffoldMessenger,
  ) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Center(
        child: Container(
          width: 830,
          height: 580,
          padding: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C002B5C),
                blurRadius: 3,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0x0C002B5C),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 24,
                        right: 24,
                        bottom: 55,
                      ),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.title == 'Data Transfer To Device') {
      return BlocConsumer<DeviceSyncBloc, DeviceSyncState>(
        listenWhen: (previous, current) {
          return current is WorkOrderError || current is WorkOrderLoaded;
        },
        listener: (context, state) {
          if (state is WorkOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load data.')),
            );
          } else if (state is WorkOrderLoaded) {
            setState(() {
              selectedFilters = state.selectedFilters;
              collectionSelectedFilter = state.collectionSelectedFilter;
              getAssets = state.assets;
              _selectedRows = List<bool>.filled(state.assets.length, false, growable: true);
            });
          }
        },
        buildWhen: (previous, current) {
          return current is WorkOrderLoading || current is WorkOrderLoaded;
        },
        builder: (context, state) {
          if (state is WorkOrderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkOrderLoaded) {
            if (state.isupdateAsset) {
              registerCollections = state.assets;
            }
            getAssets = state.assets;
            if (_selectedRows.length != state.assets.length) {
              _selectedRows = List<bool>.filled(state.assets.length, false, growable: true);
            }
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF2F2F7)),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ServerToDeviceTable(
                              key: ValueKey(state.assets.hashCode),
                              assets: state.assets,
                              registerCollections: registerCollections,
                              headers: state.tableHeaders,
                              onRowSelected: (index) {
                                setState(() {
                                  if (index < _selectedRows.length) {
                                    _selectedRows[index] = !_selectedRows[index];
                                  }
                                });
                                this.setState(() {});
                              },
                              sortOrder: state.sortOrder,
                              filterIndex: state.filterIndex,
                              selectedFilters: state.selectedFilters,
                              collectionSelectedFilter:
                                  state.collectionSelectedFilter,
                              rowSelection: _selectedRows,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Failed to load data.'));
          }
        },
      );
    } else if (widget.title == 'Data Transfer To Server') {
      return BlocConsumer<ToServerBloc, ToServerState>(
        listenWhen: (previous, current) =>
            current is WorkOrderToServerError ||
            current is WorkOrderToServerLoaded,
        listener: (context, state) {
          if (state is WorkOrderToServerError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to load data.')),
              );
            });
          } else if (state is WorkOrderToServerLoaded) {
            if (mounted) {
              setState(() {
                selectedFilters = state.selectedFilters;
                collectionSelectedFilter = state.collectionSelectedFilter;
                getAssets = state.assets;
                if (_selectedRows.length != state.assets.length) {
                  _selectedRows = List<bool>.filled(state.assets.length, false, growable: true);
                }
              });
            }
          }
        },
        buildWhen: (previous, current) {
          return current is WorkOrderToServerLoading ||
              current is WorkOrderToServerLoaded;
        },
        builder: (context, state) {
          if (state is WorkOrderToServerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkOrderToServerLoaded) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF2F2F7)),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return DeviceToServerTable(
                              key: ValueKey(state.assets.hashCode),
                              assets: state.assets,
                              headers: state.tableHeaders,
                              onRowSelected: _onRowSelected,
                              sortOrder: state.sortOrder,
                              filterIndex: state.filterIndex,
                              selectedFilters: state.selectedFilters,
                              collectionSelectedFilter:
                                  state.collectionSelectedFilter,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Failed to load data.'));
          }
        },
      );
    } else {
      return const Center(child: Text('Unknown operation'));
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x28002B5C),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.inter(
              color: const Color(0xFF1B2029),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'lib/src/features/device_sync/assets/Close.svg',
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmationPopup(BuildContext context, String tag) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: Color(0xFFF1F1F1),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(2, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirmation',
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF1C232E),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.90,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to proceed with this action?',
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF555555),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE0E0E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.roboto(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.80,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                        tag == "Transfer To Server"
                            ? _insertSelectedRowsIntoServer(context)
                            : _insertSelectedRowsIntoDatabase(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.80,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    final int totalCount = getAssets.length;
    final int selectedCount = _selectedRows.where((e) => e == true).length;

    final int syncedCount = selectedAssetsSync.length;
    final int remainingCount =
        selectedCount - syncedCount < 0 ? 0 : selectedCount - syncedCount;
    return Positioned(
      bottom: 0,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Records: $totalCount",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              // Text(
              //   "Selected: $selectedCount",
              //   style: GoogleFonts.inter(
              //     fontSize: 12,
              //     fontWeight: FontWeight.w500,
              //     color: Colors.blueAccent,
              //   ),
              // ),
              if (_isLoading)
                Text(
                  "Remaining: $remainingCount",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (widget.buttonText == 'Transfer To Device') {
                      _confirmationPopup(context, 'Transfer To Device');
                    } else {
                      _confirmationPopup(context, 'Transfer To Server');
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _syncProgress,
                          strokeWidth: 3.0,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF002B5C),
                          ),
                          backgroundColor:
                              const Color(0xFF002B5C).withValues(alpha: 0.2),
                        ),
                        Text(
                          "${(_syncProgress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002B5C),
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    widget.buttonText,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
