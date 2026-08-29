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
    if (filePath?.isNotEmpty == true) {
      final file = File(filePath!);
      await Future.delayed(const Duration(milliseconds: 500));
      if (await file.exists()) {
        // final resultfileSizeInBytes = await file.length();
        // final resultfileSizeInMB = resultfileSizeInBytes / (1024 * 1024);
        try {
          final fileService = FileUploadUtil();
          final uploadedFile = await fileService.fileUpload(file, fileOf);
          return uploadedFile['data']?['uploadStatus']['file'] ?? '';
        } catch (e) {
          _showToast(
            'Failed to upload file: ${e.toString()}',
            Colors.red,
            scaffoldMessenger,
          );
          return null;
        }
      } else {
        _showToast(
          'File not found at path: $filePath',
          Colors.red,
          scaffoldMessenger,
        );
        return null;
      }
    } else {
      _showToast('No file path provided', Colors.red, scaffoldMessenger);
      return null;
    }
  }

  Future<List<String?>?> _uploadFileImages({
    required List<String> filePaths,
    required String fileOf,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    if (filePaths.isNotEmpty) {
      try {
        final List<File> imageFiles =
            filePaths.map((filePath) => File(filePath)).toList();

        await Future.delayed(const Duration(milliseconds: 500));

        bool allExist = true;
        for (var file in imageFiles) {
          // final resultfileSizeInBytes = await file.length();
          // final resultfileSizeInMB = resultfileSizeInBytes / (1024 * 1024);
          if (!await file.exists()) {
            allExist = false;
            break;
          }
        }

        if (allExist) {
          final fileService = FileUploadUtil();
          final uploadedFiles = await fileService.photoFileUpload(
            imageFiles,
            fileOf,
          );
          final List<dynamic>? dataList = uploadedFiles['data'];

          if (dataList != null && dataList.isNotEmpty) {
            List<String?> uploadedFileUrls = [];
            for (var data in dataList) {
              var fileStatus = data['uploadStatus'];
              if (fileStatus != null && fileStatus is Map<String, dynamic>) {
                uploadedFileUrls.add(fileStatus['file']?.toString());
              } else {
                _showToast(
                  'Malformed upload response for one of the files',
                  Colors.red,
                  scaffoldMessenger,
                );
              }
            }
            return uploadedFileUrls;
          } else {
            _showToast(
              'No data returned from upload',
              Colors.red,
              scaffoldMessenger,
            );
            return null;
          }
        } else {
          _showToast(
            'One or more images not found at specified paths',
            Colors.red,
            scaffoldMessenger,
          );
          return null;
        }
      } catch (e) {
        _showToast(
          'Failed to upload images: ${e.toString()}',
          Colors.red,
          scaffoldMessenger,
        );
        return null;
      }
    } else {
      _showToast('No image paths provided', Colors.red, scaffoldMessenger);
      return null;
    }
  }

  Future<List<String?>?> _uploadImages({
    required List<String> filePaths,
    required String fileOf,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    if (filePaths.isNotEmpty) {
      try {
        final List<File> imageFiles =
            filePaths.map((filePath) => File(filePath)).toList();
        await Future.delayed(const Duration(milliseconds: 500));

        bool allExist = true;
        for (var file in imageFiles) {
          if (!await file.exists()) {
            allExist = false;
            break;
          }
        }

        if (allExist) {
          final fileService = FileUploadUtil();
          final uploadedFiles = await fileService.photoUpload(
            imageFiles,
            fileOf,
          );
          final List<dynamic>? dataList = uploadedFiles['data'];

          if (dataList != null && dataList.isNotEmpty) {
            List<String?> uploadedFileUrls = [];
            for (var data in dataList) {
              var fileStatus = data['uploadStatus'];
              if (fileStatus != null && fileStatus is Map<String, dynamic>) {
                uploadedFileUrls.add(fileStatus['file']?.toString());
              } else {
                _showToast(
                  'Malformed upload response for one of the files',
                  Colors.red,
                  scaffoldMessenger,
                );
              }
            }
            return uploadedFileUrls;
          } else {
            _showToast(
              'No data returned from upload',
              Colors.red,
              scaffoldMessenger,
            );
            return null;
          }
        } else {
          _showToast(
            'One or more images not found at specified paths',
            Colors.red,
            scaffoldMessenger,
          );
          return null;
        }
      } catch (e) {
        _showToast(
          'Failed to upload images: ${e.toString()}',
          Colors.red,
          scaffoldMessenger,
        );
        return null;
      }
    } else {
      _showToast('No image paths provided', Colors.red, scaffoldMessenger);
      return null;
    }
  }

  Future<void> insertAssetsIntoServer(
    BuildContext context,
    ProgressNotifier progressNotifier,
  ) async {
    //  ExRegister selectedAsset
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
      context,
    );
    final repository = DeviceToServerRepo();
    final assetService = ExInspectionService();
    final deviceSyncService = DeviceSyncServices();
    final userId = loggedInUser;

    final totalAssets = assets.length;
    int processedAssets = 0;
    int lastReportedProgress = 0;
    for (var asset in assets) {
      final localFiles = collectLocalFiles(asset);
      final dbHelper = DBHelper();
      // print("asset before => ${asset.id}");
      // final data = await dbHelper.getExRegisterByIdOnshore(asset.id);
      // print("asset after => ${jsonEncode(data)}");
      // print("location before => ${asset.locationId}");
      // final location =
      //     await dbHelper.getFunctionalAreaByIdOnshore(asset.locationId);
      // print("location after => ${jsonEncode(location)}");
      // ExRegister asset = selectedAsset;
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
      };

      if (asset.areaClassDrawAttach.isNotEmpty == true) {
        final uploadedAreaClassDrawAttach = await _uploadFileImages(
          filePaths: asset.areaClassDrawAttach,
          fileOf: 'areaClassDrawAttach',
          scaffoldMessenger: scaffoldMessenger,
        );
        asset.areaClassDrawAttach =
            uploadedAreaClassDrawAttach?.whereType<String>().toList() ??
                asset.areaClassDrawAttach;
        locationJson['areaClassDrawAttach'] = asset.areaClassDrawAttach;
      }
      if (asset.eqpmtLytDrawAttach.isNotEmpty == true) {
        final uploadedEqpmtLytDrawAttach = await _uploadFileImages(
          filePaths: asset.eqpmtLytDrawAttach,
          fileOf: 'eqpmtLytDrawAttach',
          scaffoldMessenger: scaffoldMessenger,
        );
        asset.eqpmtLytDrawAttach =
            uploadedEqpmtLytDrawAttach?.whereType<String>().toList() ??
                asset.eqpmtLytDrawAttach;
        locationJson['eqpmtLytDrawAttach'] = asset.eqpmtLytDrawAttach;
      }
      // if (asset.areaClassDrawAttach?.isNotEmpty == true) {
      //   final List<String>? uploadedAreaClassDrawAttach = await _uploadImages(
      //     filePaths: asset.areaClassDrawAttach,
      //     fileOf: 'areaClassDrawAttach',
      //     scaffoldMessenger: scaffoldMessenger,
      //   ) as List<String>?;
      //   asset.areaClassDrawAttach =
      //       uploadedAreaClassDrawAttach ?? asset.areaClassDrawAttach;
      //   locationJson['areaClassDrawAttach'] = asset.areaClassDrawAttach;
      // }

      // if (asset.eqpmtLytDrawAttach?.isNotEmpty == true) {
      //   final List<String>? uploadedEqpmtLytDrawAttach = await _uploadImages(
      //     filePaths: asset.eqpmtLytDrawAttach,
      //     fileOf: 'eqpmtLytDrawAttach',
      //     scaffoldMessenger: scaffoldMessenger,
      //   ) as List<String>?;
      //   asset.eqpmtLytDrawAttach =
      //       uploadedEqpmtLytDrawAttach ?? asset.eqpmtLytDrawAttach;
      //   locationJson['eqpmtLytDrawAttach'] = asset.eqpmtLytDrawAttach;
      // }
      final location = FunctionalAreaRequest.fromJson(locationJson);
      final isObjectId = RegExp(
        r'^[a-fA-F0-9]{24}$',
      ).hasMatch(asset.locationId);
      final locationIdToPass = isObjectId ? asset.locationId : null;
      final createdLocation = await assetService.functionalAreaPost(
        location,
        locationId: locationIdToPass,
      );

      final locationId = createdLocation['data']?['locationId'] ?? '';
      asset.locationId = locationId.isNotEmpty ? locationId : asset.locationId;
      final activity = Activity(
        assetId: primaryId.toString(),
        functionality: FunctionalityType.location,
        functionalityApiResponseId:
            locationId.isNotEmpty ? locationId : asset.locationId,
        status: true,
        lastSync: DateTime.now().toIso8601String(),
        createdBy: userId,
        updatedBy: userId,
      );
      await repository.insertOrUpdateDeviceToServer(activity.toMap());

      final usersign = await dbHelper.getLoggedInUserByUserId(userId);
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
        'checkList': asset.checkList,
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
        'inspectedBy': asset.inspectedBy,
        'repairsDone': asset.repairsDone,
        'defectDefectCategory': asset.defectDefectCategory,
        'correctiveOverallCondition': asset.correctiveOverallCondition,
        // 'remarks': asset.remarks,
        'repairedBy': asset.repairedBy,
        'inspectedDate': (asset.inspectedDate == null ||
                asset.inspectedDate.toString().isEmpty ||
                asset.inspectedDate == "null")
            ? ''
            : DateTime.parse(asset.inspectedDate.toString()).toUtc().toString(),
        'repairedDate': (asset.repairedDate == null ||
                asset.repairedDate.toString().isEmpty ||
                asset.repairedDate == "null")
            ? ''
            : DateTime.parse(asset.repairedDate.toString()).toUtc().toString(),
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
        'materials': asset.materials?.map((x) => x.toJson()).toList(),
        'supplementaryMaterialReq':
            asset.supplementaryMaterialReq?.map((x) => x.toJson()).toList(),
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
        'signature': usersign!.signature,
        'areaStatus': asset.areaStatus,
        'inspectedId': userId,
      };
      if (asset.dataSheet != null &&
          asset.dataSheet!.isNotEmpty &&
          asset.dataSheet != "null") {
        final uploadedDataSheet = await _uploadFile(
          filePath: asset.dataSheet!,
          fileOf: 'datasheet',
          scaffoldMessenger: scaffoldMessenger,
        );
        asset.dataSheet = uploadedDataSheet ?? asset.dataSheet;
        assetJson['dataSheet'] = asset.dataSheet;
      }

      if (asset.inspectionSignOff != null &&
          asset.inspectionSignOff.toString().isNotEmpty &&
          asset.inspectionSignOff.toString() != "null") {
        final uploadedSignOff = await _uploadFile(
          filePath: asset.inspectionSignOff.toString(),
          fileOf: 'inspectionSignOff',
          scaffoldMessenger: scaffoldMessenger,
        );
        asset.inspectionSignOff = uploadedSignOff ?? asset.inspectionSignOff;
        assetJson['inspectionSignOff'] = asset.inspectionSignOff;
      }

      if (asset.repairSignOff != null &&
          asset.repairSignOff.toString().isNotEmpty &&
          asset.repairSignOff.toString() != "null") {
        final uploadedSignOff = await _uploadFile(
          filePath: asset.repairSignOff.toString(),
          fileOf: 'repairSignOff',
          scaffoldMessenger: scaffoldMessenger,
        );
        asset.repairSignOff = uploadedSignOff ?? asset.repairSignOff;
        assetJson['repairSignOff'] = asset.repairSignOff;
      }

      if (asset.materials?.isNotEmpty == true) {
        for (final material in asset.materials!) {
          if (material.certificationAttach?.isNotEmpty == true) {
            final uploadedCertificationAttach = await _uploadFile(
              filePath: material.certificationAttach,
              fileOf: 'defectCertificationAttach',
              scaffoldMessenger: scaffoldMessenger,
            );
            material.certificationAttach =
                uploadedCertificationAttach ?? material.certificationAttach;
          }
        }
        assetJson['materials'] =
            asset.materials!.map((material) => material.toJson()).toList();
      }
      // if (asset.supplementaryMaterialReq?.isNotEmpty == true) {
      //   for (final supplementMaterial in asset.supplementaryMaterialReq!) {
      //     if (supplementMaterial.certificationAttach?.isNotEmpty == true) {
      //       final uploadedCertificationAttach = await _uploadFile(
      //         filePath: supplementMaterial.certificationAttach,
      //         fileOf: 'correctiveCertificationAttach',
      //         scaffoldMessenger: scaffoldMessenger,
      //       );
      //       supplementMaterial.certificationAttach =
      //           uploadedCertificationAttach ??
      //               supplementMaterial.certificationAttach;
      //     }
      //   }
      //   assetJson['supplementaryMaterialReq'] = asset.supplementaryMaterialReq!
      //       .map((material) => material.toJson())
      //       .toList();
      // }
      List<String> defectivePhotos = [
        asset.defectivePhoto1,
        asset.defectivePhoto2,
        asset.defectivePhoto3,
        asset.defectivePhoto4,
        asset.defectivePhoto5,
        asset.defectivePhoto6,
      ].whereType<String>().where((path) => path.isNotEmpty).toList();
      List<String> correctivePhotos = [
        asset.correctivePhoto1 == null || asset.correctivePhoto1 == "null"
            ? ""
            : asset.correctivePhoto1 ?? "",
        asset.correctivePhoto2 == null || asset.correctivePhoto2 == "null"
            ? ""
            : asset.correctivePhoto2 ?? "",
        asset.correctivePhoto3 == null || asset.correctivePhoto3 == "null"
            ? ""
            : asset.correctivePhoto3 ?? "",
        asset.correctivePhoto4 == null || asset.correctivePhoto4 == "null"
            ? ""
            : asset.correctivePhoto4 ?? "",
        asset.correctivePhoto5 == null || asset.correctivePhoto5 == "null"
            ? ""
            : asset.correctivePhoto5 ?? "",
        asset.correctivePhoto6 == null || asset.correctivePhoto6 == "null"
            ? ""
            : asset.correctivePhoto6 ?? "",
      ].whereType<String>().where((path) => path.isNotEmpty).toList();

      if (defectivePhotos.isNotEmpty) {
        final uploadedDefectiveImageUrls = await _uploadImages(
          filePaths: defectivePhotos.cast<String>(),
          fileOf: 'DefectUpload',
          scaffoldMessenger: scaffoldMessenger,
        );
        if (uploadedDefectiveImageUrls != null) {
          for (int i = 0; i < defectivePhotos.length; i++) {
            if (i < uploadedDefectiveImageUrls.length) {
              assetJson['defectivePhoto${i + 1}'] =
                  uploadedDefectiveImageUrls[i];
            }
          }
        }
      }

      if (correctivePhotos.isNotEmpty) {
        final uploadedCorrectiveImageUrls = await _uploadImages(
          filePaths: correctivePhotos.cast<String>(),
          fileOf: 'CorrectiveUpload',
          scaffoldMessenger: scaffoldMessenger,
        );
        if (uploadedCorrectiveImageUrls != null) {
          for (int i = 0; i < correctivePhotos.length; i++) {
            if (i < uploadedCorrectiveImageUrls.length) {
              assetJson['correctivePhoto${i + 1}'] =
                  uploadedCorrectiveImageUrls[i];
            }
          }
        }
      }
      final assetRequest = EquipmentTagRequest.fromJson(assetJson);

      // const encoder = JsonEncoder.withIndent('  ');
      // void printFullText(String text) {
      //   final pattern = RegExp('.{1,800}');
      //   pattern.allMatches(text).forEach((match) => print(match.group(0)));
      // }
      // printFullText(jsonEncode(assetRequest.toJson()));
      final createdAssets = await deviceSyncService.syncAssetsToServer(
        assetRequest,
      );
      final assetId = createdAssets['data'] ?? '';
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

      await repository.insertOrUpdateDeviceToServer(assetActivity.toMap());
      // final dbHelper = DBHelper();
      final authUtils = AuthUtils();
      final String? userType = await authUtils.getUserType();
      final existingAsset = (userType == 'onshore')
          ? await dbHelper.getExRegisterByIdOnshore(primaryId.toString())
          : await dbHelper.getExRegisterById(primaryId.toString());
      // final exregisterJsonString = existingAsset!['exregister_json'] as String;
      // dynamic localAssetIdCheck;
      // if (exregisterJsonString.toString().isNotEmpty) {
      //   final exregisterJson = jsonDecode(exregisterJsonString);
      //   localAssetIdCheck = exregisterJson['asset']['_id'];
      // } else {
      //   localAssetIdCheck = '';
      // }
      final localAssetIdStr =
          existingAsset?['id']?.toString() ?? asset.id.toString();
      final localAssetId = int.tryParse(localAssetIdStr) ?? 0;

      (userType == 'onshore')
          ? await dbHelper.deleteExRegisterByIdOnshore(
              localAssetId.toString(),
              asset.id,
            )
          : await dbHelper.deleteExRegisterById(
              localAssetId.toString(),
              asset.id,
            );
      if (userType == 'onshore') {
        await dbHelper.getExRegisterByIdOnshore(asset.id);
        await dbHelper.deleteFunctionalAreaOnshore(asset.locationId);
      } else {
        await dbHelper.deleteExRegister(asset.id);
        await dbHelper.deleteFunctionalArea(asset.locationId);
      }
      await deleteLocalFiles(localFiles);

      // await clearTempCache();
      processedAssets++;

      int progress = ((processedAssets / totalAssets) * 100).round();

      if (progress > lastReportedProgress) {
        lastReportedProgress = progress;
        progressNotifier.updateProgress(progress);
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
