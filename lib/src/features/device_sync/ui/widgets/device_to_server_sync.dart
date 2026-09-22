import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/models/mobile_sync_server_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/repository/device_to_server_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/services/ex_inspection_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/file_upload_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/progress_notifier.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceToServerSync {
  final List<ExRegister> assets;
  final String loggedInUser;

  DeviceToServerSync({required this.assets, required this.loggedInUser});

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

  Future<String?> _uploadFile({
    required String? filePath,
    required String fileOf,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    if (filePath != null && filePath.isNotEmpty && filePath != "null") {
      if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
        return filePath;
      }
      final file = File(filePath);
      await Future.delayed(const Duration(milliseconds: 50));
      if (await file.exists()) {
        try {
          final fileService = FileUploadUtil();
          Map<String, dynamic> uploadedFile;
          if (fileOf == 'DefectUpload' || fileOf == 'CorrectiveUpload') {
            uploadedFile = await fileService.imageUpload(file, fileOf);
          } else {
            uploadedFile = await fileService.fileUpload(file, fileOf);
          }

          final dynamic data = uploadedFile['data'];
          if (data is Map) {
            final uploadStatus = data['uploadStatus'];
            if (uploadStatus is Map) {
              return uploadStatus['file']?.toString() ??
                  data['file']?.toString() ??
                  filePath;
            }
            return data['file']?.toString() ?? filePath;
          } else if (data is List && data.isNotEmpty) {
            final first = data[0];
            if (first is Map) {
              final uploadStatus = first['uploadStatus'];
              if (uploadStatus is Map) {
                return uploadStatus['file']?.toString() ??
                    first['file']?.toString() ??
                    filePath;
              }
              return first['file']?.toString() ?? filePath;
            }
            return first?.toString() ?? filePath;
          } else if (data is String && data.isNotEmpty) {
            return data;
          }
          return filePath;
        } catch (e) {
          debugPrint('Failed to upload $fileOf ($filePath): $e');
          _showToast(
            'Failed to upload file: ${e.toString()}',
            Colors.red,
            scaffoldMessenger,
          );
          return filePath;
        }
      } else {
        return filePath;
      }
    } else {
      return null;
    }
  }

  Future<List<String?>?> _uploadFileImages({
    required List<String> filePaths,
    required String fileOf,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    if (filePaths.isEmpty) return [];
    try {
      final List<String?> results = List<String?>.from(filePaths);
      final List<File> localFilesToUpload = [];
      final List<int> localFileIndices = [];

      for (int i = 0; i < filePaths.length; i++) {
        final p = filePaths[i];
        if (p.isEmpty || p == 'null') continue;
        if (p.startsWith('http://') || p.startsWith('https://')) {
          results[i] = p;
        } else {
          final file = File(p);
          if (await file.exists()) {
            localFilesToUpload.add(file);
            localFileIndices.add(i);
          }
        }
      }

      if (localFilesToUpload.isNotEmpty) {
        final fileService = FileUploadUtil();
        final uploadedFiles = await fileService.photoFileUpload(
          localFilesToUpload,
          fileOf,
        );
        final List<dynamic>? dataList = uploadedFiles['data'];

        if (dataList != null && dataList.isNotEmpty) {
          for (int j = 0; j < dataList.length && j < localFileIndices.length; j++) {
            var fileStatus = dataList[j]['uploadStatus'];
            if (fileStatus != null && fileStatus is Map<String, dynamic>) {
              results[localFileIndices[j]] = fileStatus['file']?.toString();
            } else if (dataList[j]['file'] != null) {
              results[localFileIndices[j]] = dataList[j]['file']?.toString();
            }
          }
        }
      }
      return results;
    } catch (e) {
      _showToast(
        'Failed to upload images: ${e.toString()}',
        Colors.red,
        scaffoldMessenger,
      );
      return filePaths;
    }
  }

  Future<List<String?>?> _uploadImages({
    required List<String> filePaths,
    required String fileOf,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    if (filePaths.isEmpty) return [];
    try {
      final List<String?> results = List<String?>.from(filePaths);
      final List<File> localFilesToUpload = [];
      final List<int> localFileIndices = [];

      for (int i = 0; i < filePaths.length; i++) {
        final p = filePaths[i];
        if (p.isEmpty || p == 'null') continue;
        if (p.startsWith('http://') || p.startsWith('https://')) {
          results[i] = p;
        } else {
          final file = File(p);
          if (await file.exists()) {
            localFilesToUpload.add(file);
            localFileIndices.add(i);
          }
        }
      }

      if (localFilesToUpload.isNotEmpty) {
        final fileService = FileUploadUtil();
        final uploadedFiles = await fileService.photoUpload(
          localFilesToUpload,
          fileOf,
        );
        final List<dynamic>? dataList = uploadedFiles['data'];

        if (dataList != null && dataList.isNotEmpty) {
          for (int j = 0; j < dataList.length && j < localFileIndices.length; j++) {
            var fileStatus = dataList[j]['uploadStatus'];
            if (fileStatus != null && fileStatus is Map<String, dynamic>) {
              results[localFileIndices[j]] = fileStatus['file']?.toString();
            } else if (dataList[j]['file'] != null) {
              results[localFileIndices[j]] = dataList[j]['file']?.toString();
            }
          }
        }
      }
      return results;
    } catch (e) {
      _showToast(
        'Failed to upload images: ${e.toString()}',
        Colors.red,
        scaffoldMessenger,
      );
      return filePaths;
    }
  }

  Future<void> insertAssetsIntoServer(
    BuildContext context,
    ProgressNotifier progressNotifier,
  ) async {
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
      context,
    );
    final repository = DeviceToServerRepo();
    final assetService = ExInspectionService();
    final deviceSyncService = DeviceSyncServices();
    final userId = loggedInUser;

    final totalAssets = assets.length;
    int lastReportedProgress = 0;

    void updateSubProgress(int newProgress) {
      final clamped = newProgress.clamp(0, 100);
      if (clamped > lastReportedProgress) {
        lastReportedProgress = clamped;
        progressNotifier.updateProgress(clamped);
      }
    }

    updateSubProgress(5);

    for (int assetIndex = 0; assetIndex < totalAssets; assetIndex++) {
      final double assetBase = (assetIndex / totalAssets) * 100;
      final double assetWeight = 100 / totalAssets;

      try {
        final asset = assets[assetIndex];
        final localFiles = collectLocalFiles(asset);
        final dbHelper = DBHelper();
        final primaryId = asset.id;
        final locationJson = {
          'location': asset.location.toString(),
          'area': asset.area.toString(),
          'deckLevel': asset.deckLevel.toString(),
          'subArea': asset.subArea.toString(),
          'zone': asset.zone.toString(),
          'tAmbient': asset.locationTAmbient.toString(),
          'locationLatitude': asset.locationLatitude.toString(),
          'locationLongitude': asset.locationLongitude.toString(),
          'locationId': asset.locationId,
          'isActive': asset.isActive,
          'locationGasGroup': asset.locationGasGroup,
          'locationTClass': asset.locationTClass,
          'locationIpRating': asset.locationIpRating,
          'areaClassDrawAttachOrgName': asset.areaClassDrawAttachOrgName,
          'areaClassDrawAttach': asset.areaClassDrawAttach,
          'areaClassDrawNo': asset.areaClassDrawNo,
          'eqpmtLytDrawAttach': asset.eqpmtLytDrawAttach,
          'eqpmtLytDrawAttachOrgName': asset.eqpmtLytDrawAttachOrgName,
          'eqpmtLytDrawNo': asset.eqpmtLytDrawNo,
          'areaStatus': asset.areaStatus ?? 'Active',
        };

        // Stage 1: Drawings uploaded (15%)
        if (asset.areaClassDrawAttach.isNotEmpty == true) {
          try {
            final uploadedAreaClassDrawAttach = await _uploadFileImages(
              filePaths: asset.areaClassDrawAttach,
              fileOf: 'areaClassDrawAttach',
              scaffoldMessenger: scaffoldMessenger,
            );
            asset.areaClassDrawAttach =
                uploadedAreaClassDrawAttach?.whereType<String>().toList() ??
                    asset.areaClassDrawAttach;
            locationJson['areaClassDrawAttach'] = asset.areaClassDrawAttach;
          } catch (_) {}
        }
        if (asset.eqpmtLytDrawAttach.isNotEmpty == true) {
          try {
            final uploadedEqpmtLytDrawAttach = await _uploadFileImages(
              filePaths: asset.eqpmtLytDrawAttach,
              fileOf: 'eqpmtLytDrawAttach',
              scaffoldMessenger: scaffoldMessenger,
            );
            asset.eqpmtLytDrawAttach =
                uploadedEqpmtLytDrawAttach?.whereType<String>().toList() ??
                    asset.eqpmtLytDrawAttach;
            locationJson['eqpmtLytDrawAttach'] = asset.eqpmtLytDrawAttach;
          } catch (_) {}
        }
        updateSubProgress((assetBase + assetWeight * 0.15).round());

        // Stage 2: Functional area submitted (30%)
        final location = FunctionalAreaRequest.fromJson(locationJson);
        final isObjectId = RegExp(
          r'^[a-fA-F0-9]{24}$',
        ).hasMatch(asset.locationId);
        final locationIdToPass = isObjectId ? asset.locationId : null;
        String? createdLocationId;
        try {
          final createdLocation = await assetService.functionalAreaPost(
            location,
            locationId: locationIdToPass,
          );
          final locData = createdLocation['data'];
          if (locData is Map) {
            createdLocationId = (locData['locationId'] ??
                    locData['_id'] ??
                    locData['id'] ??
                    (locData['location'] is Map ? locData['location']['_id'] : null))
                ?.toString();
          } else if (locData is String && locData.isNotEmpty) {
            createdLocationId = locData;
          }
          if (createdLocationId == null || createdLocationId.isEmpty) {
            createdLocationId = (createdLocation['locationId'] ??
                    createdLocation['_id'] ??
                    createdLocation['id'])
                ?.toString();
          }
        } catch (e) {
          debugPrint('functionalAreaPost error: $e');
        }

        final effectiveLocationId = (createdLocationId != null && createdLocationId.isNotEmpty)
            ? createdLocationId
            : asset.locationId;
        asset.locationId = effectiveLocationId;
        final activity = Activity(
          assetId: primaryId.toString(),
          functionality: FunctionalityType.location,
          functionalityApiResponseId: effectiveLocationId,
          status: true,
          lastSync: DateTime.now().toIso8601String(),
          createdBy: userId,
          updatedBy: userId,
        );
        try {
          await repository.insertOrUpdateDeviceToServer(activity.toMap());
        } catch (_) {}
        updateSubProgress((assetBase + assetWeight * 0.30).round());

        // Stage 3: Signatures & documents uploaded (45%)
        final prefs = await SharedPreferences.getInstance();
        var usersign = await dbHelper.getLoggedInUserByUserId(userId);
        usersign ??= await dbHelper.getLoggedInUser();
        String userSignature = (usersign?.signature ?? '').trim();

        if (userSignature.isEmpty) {
          try {
            final directory = await getApplicationDocumentsDirectory();
            final candidateNames = [
              'signature.jpg',
              'signature.png',
              'signature.jpeg',
              'user_signature.png',
              'user_signature.jpg',
            ];
            for (final name in candidateNames) {
              final f = File('${directory.path}/$name');
              if (f.existsSync()) {
                userSignature = f.path;
                break;
              }
            }
          } catch (_) {}
        }

        if (userSignature.isEmpty) {
          userSignature = (prefs.getString('userSignature') ??
                  prefs.getString('signature_$userId') ??
                  '')
              .trim();
        }

        if (userSignature.isEmpty) {
          if (asset.signature != null &&
              asset.signature.toString().isNotEmpty &&
              asset.signature.toString() != "null") {
            userSignature = asset.signature.toString().trim();
          } else if (asset.inspectionSignOff != null &&
              asset.inspectionSignOff.toString().isNotEmpty &&
              asset.inspectionSignOff.toString() != "null") {
            userSignature = asset.inspectionSignOff.toString().trim();
          } else if (asset.repairSignOff != null &&
              asset.repairSignOff.toString().isNotEmpty &&
              asset.repairSignOff.toString() != "null") {
            userSignature = asset.repairSignOff.toString().trim();
          }
        }

        if (userSignature.isNotEmpty &&
            !userSignature.startsWith('http') &&
            !userSignature.startsWith('data:')) {
          try {
            final sigFile = File(userSignature);
            if (await sigFile.exists()) {
              final uploadedSig = await _uploadFile(
                filePath: userSignature,
                fileOf: 'userSignature',
                scaffoldMessenger: scaffoldMessenger,
              );
              if (uploadedSig != null && uploadedSig.isNotEmpty) {
                userSignature = uploadedSig;
              }
            }
          } catch (_) {}
        }

        if (asset.dataSheet != null &&
            asset.dataSheet!.isNotEmpty &&
            asset.dataSheet != "null") {
          try {
            final uploadedDataSheet = await _uploadFile(
              filePath: asset.dataSheet!,
              fileOf: 'datasheet',
              scaffoldMessenger: scaffoldMessenger,
            );
            asset.dataSheet = uploadedDataSheet ?? asset.dataSheet;
          } catch (_) {}
        }

        if (asset.inspectionSignOff != null &&
            asset.inspectionSignOff.toString().isNotEmpty &&
            asset.inspectionSignOff.toString() != "null") {
          try {
            final uploadedSignOff = await _uploadFile(
              filePath: asset.inspectionSignOff.toString(),
              fileOf: 'inspectionSignOff',
              scaffoldMessenger: scaffoldMessenger,
            );
            asset.inspectionSignOff = uploadedSignOff ?? asset.inspectionSignOff;
          } catch (_) {}
        }

        if (asset.repairSignOff != null &&
            asset.repairSignOff.toString().isNotEmpty &&
            asset.repairSignOff.toString() != "null") {
          try {
            final uploadedSignOff = await _uploadFile(
              filePath: asset.repairSignOff.toString(),
              fileOf: 'repairSignOff',
              scaffoldMessenger: scaffoldMessenger,
            );
            asset.repairSignOff = uploadedSignOff ?? asset.repairSignOff;
          } catch (_) {}
        }

        if (asset.materials?.isNotEmpty == true) {
          for (final material in asset.materials!) {
            if (material.certificationAttach?.isNotEmpty == true) {
              try {
                final uploadedCertificationAttach = await _uploadFile(
                  filePath: material.certificationAttach,
                  fileOf: 'defectCertificationAttach',
                  scaffoldMessenger: scaffoldMessenger,
                );
                material.certificationAttach =
                    uploadedCertificationAttach ?? material.certificationAttach;
              } catch (_) {}
            }
          }
        }
        updateSubProgress((assetBase + assetWeight * 0.45).round());

        // Stage 4: Defect photos uploaded (65%)
        final defectivePhotoList = [
          asset.defectivePhoto1,
          asset.defectivePhoto2,
          asset.defectivePhoto3,
          asset.defectivePhoto4,
          asset.defectivePhoto5,
          asset.defectivePhoto6,
        ];
        final List<String?> uploadedDefectPhotos = List<String?>.from(defectivePhotoList);
        for (int i = 0; i < 6; i++) {
          final p = defectivePhotoList[i];
          if (p != null && p.isNotEmpty && p != "null") {
            if (p.startsWith('http://') || p.startsWith('https://')) {
              uploadedDefectPhotos[i] = p;
            } else {
              try {
                final uploaded = await _uploadFile(
                  filePath: p,
                  fileOf: 'DefectUpload',
                  scaffoldMessenger: scaffoldMessenger,
                );
                if (uploaded != null && uploaded.isNotEmpty) {
                  uploadedDefectPhotos[i] = uploaded;
                }
              } catch (_) {}
            }
          }
        }
        asset.defectivePhoto1 = uploadedDefectPhotos[0];
        asset.defectivePhoto2 = uploadedDefectPhotos[1];
        asset.defectivePhoto3 = uploadedDefectPhotos[2];
        asset.defectivePhoto4 = uploadedDefectPhotos[3];
        asset.defectivePhoto5 = uploadedDefectPhotos[4];
        asset.defectivePhoto6 = uploadedDefectPhotos[5];
        updateSubProgress((assetBase + assetWeight * 0.65).round());

        // Stage 5: Corrective photos uploaded (80%)
        final correctivePhotoList = [
          asset.correctivePhoto1,
          asset.correctivePhoto2,
          asset.correctivePhoto3,
          asset.correctivePhoto4,
          asset.correctivePhoto5,
          asset.correctivePhoto6,
        ];
        final List<String?> uploadedCorrectivePhotos = List<String?>.from(correctivePhotoList);
        for (int i = 0; i < 6; i++) {
          final p = correctivePhotoList[i];
          if (p != null && p.isNotEmpty && p != "null") {
            if (p.startsWith('http://') || p.startsWith('https://')) {
              uploadedCorrectivePhotos[i] = p;
            } else {
              try {
                final uploaded = await _uploadFile(
                  filePath: p,
                  fileOf: 'CorrectiveUpload',
                  scaffoldMessenger: scaffoldMessenger,
                );
                if (uploaded != null && uploaded.isNotEmpty) {
                  uploadedCorrectivePhotos[i] = uploaded;
                }
              } catch (_) {}
            }
          }
        }
        asset.correctivePhoto1 = uploadedCorrectivePhotos[0];
        asset.correctivePhoto2 = uploadedCorrectivePhotos[1];
        asset.correctivePhoto3 = uploadedCorrectivePhotos[2];
        asset.correctivePhoto4 = uploadedCorrectivePhotos[3];
        asset.correctivePhoto5 = uploadedCorrectivePhotos[4];
        asset.correctivePhoto6 = uploadedCorrectivePhotos[5];
        updateSubProgress((assetBase + assetWeight * 0.80).round());

        // Stage 6: Equipment tag synced to server (95%)
        final inspectedByValue = (asset.inspectedBy != null &&
                asset.inspectedBy.toString().isNotEmpty &&
                asset.inspectedBy.toString() != "null")
            ? asset.inspectedBy
            : (usersign != null
                ? ('${usersign.firstName} ${usersign.lastName}'.trim().isNotEmpty
                    ? '${usersign.firstName} ${usersign.lastName}'.trim()
                    : usersign.userName)
                : '');

        final assetJson = {
          '_id': asset.id,
          'rfidRef': asset.rfidRef,
          'location': asset.location,
          'area': asset.area,
          'deckLevel': asset.deckLevel,
          'zone': asset.zone,
          'eqpmtTag': asset.eqpmtTag,
          'description': asset.description,
          'manufacturer': asset.manufacturer,
          'epl': asset.epl,
          'inspectionStatus': asset.inspectionStatus,
          'existingFaults': asset.existingFaults,
          'currentStatus': asset.currentStatus,
          'checkList': asset.checkList?.map((item) => item.toJson()).toList() ?? [],
          'inspectionReferenceNumber': asset.inspectionReferenceNumber,
          'subArea': asset.subArea,
          'isActive': asset.isActive,
          'locationGasGroup': asset.locationGasGroup,
          'locationIpRating': asset.locationIpRating,
          'locationTClass': asset.locationTClass,
          'tAmbient': asset.tAmbient,
          'tAmbientEquip': asset.tAmbientEquip,
          'inspectionSignOff': asset.inspectionSignOff,
          'repairSignOff': asset.repairSignOff,
          'areaClassDrawNo': asset.areaClassDrawNo,
          'eqpmtLytDrawNo': asset.eqpmtLytDrawNo,
          'locationTAmbient': asset.locationTAmbient,
          'status': asset.status,
          'eqpmtCatg': asset.eqpmtCatg,
          'oracleId': asset.oracleId,
          'equipmentEquipmentType': asset.equipmentEquipmentType,
          'serialNumber': asset.serialNumber,
          'atexCatg': asset.atexCatg,
          'equipmentGasGroup': asset.equipmentGasGroup,
          'equipmentTClass': asset.equipmentTClass,
          'equipmentIpRating': asset.equipmentIpRating,
          'specialCond': asset.specialCond,
          'inspectionType': asset.inspectionType,
          'inspectionChecklistType': asset.inspectionChecklistType,
          'inspectionGrade': asset.inspectionGrade,
          'faultyItems': asset.faultyItems,
          'repairPriority': asset.repairPriority,
          'defectOverallCondition': asset.defectOverallCondition,
          'defectIsolation': asset.defectIsolation,
          'defectOtherRequirements': asset.defectOtherRequirements,
          'remarks': asset.remarks,
          'dataSheet': asset.dataSheet,
          'dataSheetNo': asset.dataSheetNo,
          'dataSheetOrgName': asset.dataSheetOrgName,
          'inspectedBy': inspectedByValue,
          'repairsDone': asset.repairsDone,
          'defectDefectCategory': asset.defectDefectCategory,
          'correctiveOverallCondition': asset.correctiveOverallCondition,
          'repairedBy': asset.repairedBy,
          'inspectedDate': (asset.inspectedDate == null ||
                  asset.inspectedDate.toString().isEmpty ||
                  asset.inspectedDate == "null")
              ? ''
              : (DateTime.tryParse(asset.inspectedDate.toString())
                      ?.toUtc()
                      .toIso8601String() ??
                  asset.inspectedDate.toString()),
          'repairedDate': (asset.repairedDate == null ||
                  asset.repairedDate.toString().isEmpty ||
                  asset.repairedDate == "null")
              ? ''
              : (DateTime.tryParse(asset.repairedDate.toString())
                      ?.toUtc()
                      .toIso8601String() ??
                  asset.repairedDate.toString()),
          'yesNoSelection': asset.yesNoSelection,
          'gpsCord': asset.gpsCord,
          'protectionStd': asset.protectionStd,
          'protectionType': asset.protectionType,
          'correctiveisolation': asset.correctiveisolation,
          'correctiveOtherRequirements': asset.correctiveOtherRequirements,
          'defectivePhoto1': asset.defectivePhoto1,
          'defectivePhoto1OrgName': asset.defectivePhoto1OrgName,
          'defectivePhoto2': asset.defectivePhoto2,
          'defectivePhoto2OrgName': asset.defectivePhoto2OrgName,
          'defectivePhoto3': asset.defectivePhoto3,
          'defectivePhoto3OrgName': asset.defectivePhoto3OrgName,
          'defectivePhoto4': asset.defectivePhoto4,
          'defectivePhoto4OrgName': asset.defectivePhoto4OrgName,
          'defectivePhoto5': asset.defectivePhoto5,
          'defectivePhoto5OrgName': asset.defectivePhoto5OrgName,
          'defectivePhoto6': asset.defectivePhoto6,
          'defectivePhoto6OrgName': asset.defectivePhoto6OrgName,
          'materials': asset.materials?.map((x) => x.toJson()).toList() ?? [],
          'supplementaryMaterialReq':
              asset.supplementaryMaterialReq?.map((x) => x.toJson()).toList() ?? [],
          'defectCertificationNo': asset.defectCertificationNo,
          'defectCertificationOrgName': asset.defectCertificationOrgName,
          'defectCertificationAttach': asset.defectCertificationAttach,
          'correctiveCertificationNo': asset.correctiveCertificationNo,
          'correctiveCertificationOrgName': asset.correctiveCertificationOrgName,
          'correctiveCertificationAttach': asset.correctiveCertificationAttach,
          'correctivePhoto1': asset.correctivePhoto1,
          'correctivePhoto1OrgName': asset.correctivePhoto1OrgName,
          'correctivePhoto2': asset.correctivePhoto2,
          'correctivePhoto2OrgName': asset.correctivePhoto2OrgName,
          'correctivePhoto3': asset.correctivePhoto3,
          'correctivePhoto3OrgName': asset.correctivePhoto3OrgName,
          'correctivePhoto4': asset.correctivePhoto4,
          'correctivePhoto4OrgName': asset.correctivePhoto4OrgName,
          'correctivePhoto5': asset.correctivePhoto5,
          'correctivePhoto5OrgName': asset.correctivePhoto5OrgName,
          'correctivePhoto6': asset.correctivePhoto6,
          'correctivePhoto6OrgName': asset.correctivePhoto6OrgName,
          'rbiStrategy': asset.rbiStrategy?.toJson(),
          'additionalInfoForRepairs': asset.additionalInfoForRepairs,
          'areaClassDrawAttach': asset.areaClassDrawAttach,
          'areaClassDrawAttachOrgName': asset.areaClassDrawAttachOrgName,
          'eqpmtLytDrawAttachOrgName': asset.eqpmtLytDrawAttachOrgName,
          'eqpmtLytDrawAttach': asset.eqpmtLytDrawAttach,
          'locationId': asset.locationId,
          'locationLatitude': asset.locationLatitude,
          'locationLongitude': asset.locationLongitude,
          'eqpmtLatitude': asset.locationLatitude,
          'eqpmtLongitude': asset.locationLongitude,
          'circuitId': asset.circuitId,
          'cableId': asset.cableId,
          'equipmentCategory': asset.equipmentCategory,
          'type': asset.type,
          'certfnBody': asset.certfnBody,
          'certfnNo': asset.certfnNo,
          'correctiveDefectCategory': asset.correctiveDefectCategory,
          'repairDuration': asset.repairDuration,
          'repairTimeEstimate': asset.repairTimeEstimate,
          'remarksIfAny': asset.remarksIfAny,
          'signature': userSignature,
          'areaStatus': asset.areaStatus,
          'inspectedId': userId,
        };

        final assetRequest = EquipmentTagRequest.fromJson(assetJson);
        final isAssetObjectId = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(asset.id);
        final createdAssets = await deviceSyncService.syncAssetsToServer(
          assetRequest,
          assetId: isAssetObjectId ? asset.id : null,
        );
        final assetId = createdAssets['data']?.toString() ?? '';
        asset.id = assetId.isNotEmpty ? assetId : asset.id;
        final assetActivity = Activity(
          assetId: primaryId.toString(),
          functionality: FunctionalityType.asset,
          functionalityApiResponseId: assetId.isNotEmpty ? assetId : asset.id,
          status: true,
          lastSync: DateTime.now().toIso8601String(),
          createdBy: userId,
          updatedBy: userId,
        );

        try {
          await repository.insertOrUpdateDeviceToServer(assetActivity.toMap());
        } catch (_) {}
        updateSubProgress((assetBase + assetWeight * 0.95).round());

        // Stage 7: Local cleanup (100%)
        final authUtils = AuthUtils();
        final String? userType = await authUtils.getUserType();
        final isOnshore = userType == 'onshore';

        final originalLocalId = primaryId.toString();
        final assetPrimaryIdStr = asset.primaryId?.toString() ?? '';
        final currentAssetId = asset.id.toString();

        try {
          if (isOnshore) {
            await dbHelper.deleteExRegisterByIdOnshore(originalLocalId, assetPrimaryIdStr);
            if (currentAssetId.isNotEmpty && currentAssetId != originalLocalId) {
              await dbHelper.deleteExRegisterByIdOnshore(currentAssetId, '');
            }
            if (asset.locationId != null && asset.locationId.toString().isNotEmpty) {
              await dbHelper.deleteFunctionalAreaOnshore(asset.locationId);
            }
          } else {
            await dbHelper.deleteExRegisterById(originalLocalId, assetPrimaryIdStr);
            if (currentAssetId.isNotEmpty && currentAssetId != originalLocalId) {
              await dbHelper.deleteExRegisterById(currentAssetId, '');
            }
            if (asset.locationId != null && asset.locationId.toString().isNotEmpty) {
              await dbHelper.deleteFunctionalArea(asset.locationId);
            }
          }
        } catch (e) {
          debugPrint('Local cleanup error: $e');
        }

        try {
          await deleteLocalFiles(localFiles);
        } catch (_) {}
      } catch (e, stack) {
        debugPrint('Error syncing asset $assetIndex: $e\n$stack');
      } finally {
        updateSubProgress((((assetIndex + 1) / totalAssets) * 100).round());
      }
    }
  }

  List<String> collectLocalFiles(ExRegister asset) {
    final List<String?> files = [
      asset.dataSheet,
      asset.inspectionSignOff,
      asset.repairSignOff,
      asset.defectivePhoto1,
      asset.defectivePhoto2,
      asset.defectivePhoto3,
      asset.defectivePhoto4,
      asset.defectivePhoto5,
      asset.defectivePhoto6,
      asset.correctivePhoto1,
      asset.correctivePhoto2,
      asset.correctivePhoto3,
      asset.correctivePhoto4,
      asset.correctivePhoto5,
      asset.correctivePhoto6,
    ];

    final List<String> allFiles = [];

    allFiles.addAll(
      files
          .whereType<String>()
          .where((p) => p.isNotEmpty && !p.startsWith('http')),
    );

    allFiles.addAll(
      asset.areaClassDrawAttach
          .where((p) => p.isNotEmpty && !p.startsWith('http')),
    );

    allFiles.addAll(
      asset.eqpmtLytDrawAttach
          .where((p) => p.isNotEmpty && !p.startsWith('http')),
    );

    if (asset.materials != null) {
      for (final m in asset.materials!) {
        if (m.certificationAttach != null &&
            m.certificationAttach!.isNotEmpty &&
            !m.certificationAttach!.startsWith('http')) {
          allFiles.add(m.certificationAttach!);
        }
      }
    }

    return allFiles;
  }

  Future<void> deleteLocalFiles(List<String> paths) async {
    for (final path in paths) {
      try {
        if (path.startsWith('http')) continue;

        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Failed to delete file: $path → $e');
      }
    }
  }

  Future<void> clearTempCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Temp cache cleanup failed: $e');
    }
  }
}
