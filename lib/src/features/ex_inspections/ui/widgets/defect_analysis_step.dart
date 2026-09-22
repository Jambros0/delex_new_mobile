// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/dotted_style.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/multi_select_dropdown.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/ex_inspection_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/camera_page.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/download_file.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/file_download_util.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/searchable_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/ex_inspection_bloc.dart';
import '../../bloc/ex_inspection_event.dart';

enum CustomFileSource { camera, gallery, file }

String formatDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty || rawDate.toLowerCase() == 'null') {
    return '';
  }

  try {
    DateTime? dateTime;
    if (rawDate.endsWith('Z')) {
      dateTime = DateTime.tryParse(rawDate)?.toLocal();
    } else {
      final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      try {
        dateTime = inputFormat.parse(rawDate, false);
      } catch (_) {
        dateTime = DateTime.tryParse(rawDate);
      }
    }
    if (dateTime == null) {
      try {
        dateTime = DateFormat('dd-MM-yyyy hh:mm a').parse(rawDate);
      } catch (_) {
        return rawDate;
      }
    }
    final outputFormat = DateFormat('dd-MM-yyyy hh:mm a');
    return outputFormat.format(dateTime);
  } catch (e) {
    return rawDate;
  }
}

String formatOldDate(String? rawDate) {
  return formatDate(rawDate);
}

class DefectAnalysisStep extends StatefulWidget {
  final ExInspectionRequest exInspectionRequest;
  final bool isUpdate;
  final ValueNotifier<bool> isEditModeNotifier;
  const DefectAnalysisStep({
    super.key,
    required this.exInspectionRequest,
    required this.isUpdate,
    required this.isEditModeNotifier,
  });

  @override
  DefectAnalysisStepState createState() => DefectAnalysisStepState();
}

class DefectAnalysisStepState extends State<DefectAnalysisStep> {
  final TextEditingController _faultyItems = TextEditingController();
  final TextEditingController _repairDuration = TextEditingController();
  final TextEditingController _additionalInfoForRepair =
      TextEditingController();
  final TextEditingController _dataSheetController = TextEditingController();
  final TextEditingController _certification = TextEditingController();
  final TextEditingController _signature = TextEditingController();
  final TextEditingController _inspectedBy = TextEditingController();
  final TextEditingController _inspectedDate = TextEditingController();
  final TextEditingController _inspectionStatusController =
      TextEditingController();
  final TextEditingController _overallConditionController =
      TextEditingController();
  final TextEditingController _defectCertificationController =
      TextEditingController();
  String? _selectedIsolationRequirement;
  String? _selectedOtherRequirement;
  String selectedDefectCategory = '';
  final List<File> _images = [];

  List<String> get unit => [
        'Nos (Number)',
        'Packs',
        'Meters (m)',
        'Grams (g)',
        'Square Meter (m)',
        'Liter (L)',
      ];
  String? _dataSheet;
  String? _dataSheetOrgName;
  String? _dataSheetNo;
  String? _signatureUrl;
  String? _defectivePhoto1 = '';
  String? _defectivePhoto1OrgName = '';
  String? _defectivePhoto2 = '';
  String? _defectivePhoto2OrgName = '';
  String? _defectivePhoto3 = '';
  String? _defectivePhoto3OrgName = '';
  String? _defectivePhoto4 = '';
  String? _defectivePhoto4OrgName = '';
  String? _defectivePhoto5 = '';
  String? _defectivePhoto5OrgName = '';
  String? _defectivePhoto6 = '';
  String? _defectivePhoto6OrgName = '';
  List<String> _filteredDefectCategory = [];
  List<String> selectedotherRequirement = [];
  String? _defectCertificationNo;
  String? _defectCertificationOrgName;
  String? _defectCertificationAttach;
  final List<Map<String, String?>> _materials = [];
  final List<String> _uploadedImageUrls = [];
  final List<String?> _imageNames = [];
  static String? get apiUrl => dotenv.env['API_URL'];
  final ImagePicker _picker = ImagePicker();
  bool clearFlag = false;
  final List<TextEditingController> _partNumberControllers = [];
  final List<TextEditingController> _materialDescriptionControllers = [];
  final List<TextEditingController> _manufacturerControllers = [];
  final List<TextEditingController> _certificationControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<String?> _selectedUnitValues = [];
  bool isRepairsDisable = false;
  bool dropDownEnabled = false;
  bool isEditable = false;
  bool showEditIcon = false;
  final DBHelper _dbHelper = DBHelper();
  UserDetails? loggedInUser;
  String? userName;

  @override
  void initState() {
    super.initState();
    context.read<ExInspectionsBloc>().add(FetchAllDropDwn());
    _loadUserSignature();
    if (widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeInspectionValues();
    }
    _fetchLoggedInUser();
  }

  Future<void> _fetchLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final user = await _dbHelper.getLoggedInUserByUserId(userId!);
    setState(() {
      loggedInUser = user;
      userName = loggedInUser?.userName;
    });
  }

  @override
  void didUpdateWidget(covariant DefectAnalysisStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exInspectionRequest != oldWidget.exInspectionRequest &&
        widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeInspectionValues();
    }
  }

  void _initializeInspectionValues() {
    final request = widget.exInspectionRequest.equipmentTagRequest;
    if (request == null) {
      return;
    }
    setState(() {
      if (request.defectivePhoto1 != null &&
          request.defectivePhoto1!.isNotEmpty) {
        _defectivePhoto1 = request.defectivePhoto1;
        _defectivePhoto1OrgName = request.defectivePhoto1OrgName;
        _uploadedImageUrls.add(_defectivePhoto1!);
        _imageNames.add(request.defectivePhoto1OrgName);
      }
      if (request.defectivePhoto2 != null &&
          request.defectivePhoto2!.isNotEmpty) {
        _defectivePhoto2 = request.defectivePhoto2;
        _defectivePhoto2OrgName = request.defectivePhoto2OrgName;
        _uploadedImageUrls.add(_defectivePhoto2!);
        _imageNames.add(request.defectivePhoto2OrgName);
      }
      if (request.defectivePhoto3 != null &&
          request.defectivePhoto3!.isNotEmpty) {
        _defectivePhoto3 = request.defectivePhoto3;
        _defectivePhoto3OrgName = request.defectivePhoto3OrgName;
        _uploadedImageUrls.add(_defectivePhoto3!);
        _imageNames.add(request.defectivePhoto3OrgName);
      }
      if (request.defectivePhoto4 != null &&
          request.defectivePhoto4!.isNotEmpty) {
        _defectivePhoto4 = request.defectivePhoto4;
        _defectivePhoto4OrgName = request.defectivePhoto4OrgName;
        _uploadedImageUrls.add(_defectivePhoto4!);
        _imageNames.add(request.defectivePhoto4OrgName);
      }
      if (request.defectivePhoto5 != null &&
          request.defectivePhoto5!.isNotEmpty) {
        _defectivePhoto5 = request.defectivePhoto5;
        _defectivePhoto5OrgName = request.defectivePhoto5OrgName;
        _uploadedImageUrls.add(_defectivePhoto5!);
        _imageNames.add(request.defectivePhoto5OrgName);
      }
      if (request.defectivePhoto6 != null &&
          request.defectivePhoto6!.isNotEmpty) {
        _defectivePhoto6 = request.defectivePhoto6;
        _defectivePhoto6OrgName = request.defectivePhoto6OrgName;
        _uploadedImageUrls.add(_defectivePhoto6!);
        _imageNames.add(request.defectivePhoto6OrgName);
      }
      // String formattedDate =
      //     request.inspectedDate != null && request.inspectedDate!.isNotEmpty
      //         ? DateFormat("dd MMM yy HH:mm 'Hrs'")
      //             .format(DateTime.parse(request.inspectedDate!))
      //         : '';
      _inspectedDate.text = formatOldDate(request.inspectedDate);
      _inspectedBy.text = request.inspectedBy ?? '';
      final checklistData = request.checkList ?? [];
      final defectData = _extractAndSortDefectData(checklistData);
      _filterDropdownItems(defectData);
      _faultyItems.text = defectData.length.toString();
      if (request.defectDefectCategory != null &&
          request.defectDefectCategory!.isNotEmpty) {
        if (request.defectDefectCategory == "Not Applicable") {
          selectedDefectCategory = "Not Applicable";
        } else {
          final parsedDefectPriority = int.tryParse(
            request.defectDefectCategory!,
          );

          if (parsedDefectPriority != null &&
              request.inspectionPriority == parsedDefectPriority) {
            selectedDefectCategory = request.defectDefectCategory!;
          } else {
            if (request.inspectionPriority != null &&
                request.inspectionPriority.toString().isNotEmpty &&
                request.inspectionPriority.toString() != 'null') {
              selectedDefectCategory =
                  request.inspectionPriority?.toString() ?? "";
            } else {
              selectedDefectCategory = request.defectDefectCategory!;
            }
          }
        }
      } else {
        if (_filteredDefectCategory.isNotEmpty) {
          final inspectionPriorityStr =
              request.inspectionPriority?.toString() ?? "";
          if (_filteredDefectCategory[0].contains(inspectionPriorityStr)) {
            selectedDefectCategory = _filteredDefectCategory[0];
          } else {
            selectedDefectCategory = inspectionPriorityStr;
          }
        } else {
          selectedDefectCategory = "";
        }
      }
      _selectedIsolationRequirement = request.defectIsolation;
      // _selectedOtherRequirement = request.defectOtherRequirements;
      selectedotherRequirement = request.defectOtherRequirements.isEmpty
          ? []
          : request.defectOtherRequirements;
      _additionalInfoForRepair.text = request.additionalInfoForRepairs ?? '';
      _dataSheetController.text = request.dataSheetOrgName ?? '';
      _repairDuration.text = request.repairDuration ?? '';
      if (request.materials != null && request.materials!.isNotEmpty) {
        _defectCertificationController.text =
            request.materials!.first.certificationOrgName ?? '';
      } else {
        _defectCertificationController.text = '';
      }
      _setDropdownValues(selectedDefectCategory);
      _dataSheet = request.dataSheet;
      _dataSheetOrgName = request.dataSheetOrgName;
      _dataSheetNo = request.dataSheetNo;
      if (request.materials!.isNotEmpty) {
        _materials.addAll(
          request.materials?.map(
                (material) => {
                  'partNumber': material.partNumber ?? '',
                  'description': material.description ?? '',
                  'manufacturer': material.manufacturer ?? '',
                  'certificationOrgName': material.certificationOrgName ?? '',
                  'certificationAttach': material.certificationAttach ?? '',
                  'unit': material.unit,
                  'quantity': material.quantity ?? '',
                },
              ) ??
              [],
        );

        for (var material in _materials) {
          _partNumberControllers.add(
            TextEditingController(text: material['partNumber']),
          );
          _materialDescriptionControllers.add(
            TextEditingController(text: material['description']),
          );
          _manufacturerControllers.add(
            TextEditingController(text: material['manufacturer']),
          );
          _certificationControllers.add(
            TextEditingController(text: material['certificationOrgName']),
          );
          _quantityControllers.add(
            TextEditingController(text: material['quantity']),
          );
          _selectedUnitValues.add(material['unit']);
        }
      }
    });
  }

  void _filterDropdownItems(List<Map<String, dynamic>> defectData) {
    final priorities = defectData
        .map((defect) => int.tryParse(defect['priority'].toString()) ?? 0)
        .where((priority) => priority != 0)
        .toSet()
        .toList();
    priorities.sort();
    setState(() {
      if (priorities.isEmpty) {
        selectedDefectCategory = 'Not Applicable';
      } else {
        selectedDefectCategory = priorities[0].toString();
      }
      _filteredDefectCategory = priorities.isNotEmpty
          ? priorities.map((p) => p.toString()).toList()
          : ['Not Applicable'];
    });
  }

  List<Map<String, dynamic>> _extractAndSortDefectData(
    List<CheckList> checklistData,
  ) {
    List<Map<String, dynamic>> defectData = [];
    for (var checkList in checklistData) {
      for (var defectCodeData in checkList.defectCodes) {
        int priority = defectCodeData.defectPriority['priority'] as int;
        for (var findingAction in defectCodeData.findingsAndActions) {
          defectData.add({
            'defectCode': findingAction.defectCode,
            'finding': findingAction.finding,
            'remedialAction': findingAction.remedialAction,
            'priority': priority,
          });
        }
      }
    }
    defectData.sort((a, b) {
      int priorityComparison = a['priority'].compareTo(b['priority']);
      if (priorityComparison == 0) {
        return a['defectCode'].compareTo(b['defectCode']);
      }
      return priorityComparison;
    });
    return defectData;
  }

  void _setDropdownValues(String? selectedPriority) {
    setState(() {
      if (selectedPriority == null ||
          selectedPriority.isEmpty ||
          selectedPriority == 'Not Applicable') {
        _inspectionStatusController.text = 'Green';
        _overallConditionController.text = 'Good to Use';
        _repairDuration.text = 'Not Applicable';
      } else {
        int priority = int.tryParse(selectedPriority) ?? 0;
        if (priority <= 2) {
          _inspectionStatusController.text = 'Red';
          _overallConditionController.text = 'Major Repair Required';
        } else if (priority <= 5) {
          _inspectionStatusController.text = 'Yellow';
          _overallConditionController.text = 'Minor Repair Required';
        } else {
          _repairDuration.text = 'Not Applicable';
          _inspectionStatusController.text = 'Green';
          _overallConditionController.text = 'Good to Use';
        }
      }
    });
  }

  Future<void> _loadUserSignature() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final dbHelper = DBHelper();
    String? localSignature;
    String? userName;

    if (userId != null && userId.isNotEmpty) {
      final user = await dbHelper.getLoggedInUserByUserId(userId);
      if (user != null) {
        userName = user.userName;
        if (user.signature.isNotEmpty) {
          localSignature = user.signature;
        }
      }
    }
    if (localSignature == null || localSignature.isEmpty) {
      final user = await dbHelper.getLoggedInUser();
      if (user != null) {
        userName ??= user.userName;
        if (user.signature.isNotEmpty) {
          localSignature = user.signature;
        }
      }
    }
    if (localSignature == null || localSignature.isEmpty) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filesToCheck = [
          'signature.jpg',
          'signature.png',
          'signature.jpeg',
          'user_signature.png',
          'user_signature.jpg',
        ];
        for (var name in filesToCheck) {
          final f = File('${directory.path}/$name');
          if (f.existsSync()) {
            localSignature = f.path;
            break;
          }
        }
      } catch (_) {}
    }
    if (localSignature == null || localSignature.isEmpty) {
      localSignature = prefs.getString('userSignature') ?? prefs.getString('signature_${userId ?? ""}');
    }

    final existingSignOff = widget.exInspectionRequest.equipmentTagRequest?.inspectionSignOff;
    final signToUse = (existingSignOff != null && existingSignOff.isNotEmpty && existingSignOff != "null")
        ? existingSignOff
        : localSignature;

    if (signToUse != null && signToUse.isNotEmpty && mounted) {
      setState(() {
        _signatureUrl = signToUse;
        if (_signature.text.isEmpty) {
          _signature.text = userName ?? 'Inspected';
        }
      });
    }
  }

  void clearFields() {
    setState(() {
      _inspectedBy.clear();
      _inspectedDate.clear();
      _selectedIsolationRequirement = null;
      _selectedOtherRequirement = null;
      _dataSheet = null;
      _dataSheetNo = null;
      _dataSheetOrgName = null;
      _partNumberControllers.clear();
      _manufacturerControllers.clear();
      _materials.clear();
      _defectCertificationController.clear();
      _defectCertificationAttach = null;
      _defectCertificationOrgName = null;
      _defectCertificationNo = null;
      _defectivePhoto1 = '';
      _defectivePhoto1OrgName = '';
      _defectivePhoto2 = '';
      _defectivePhoto2OrgName = '';
      _defectivePhoto3 = '';
      _defectivePhoto3OrgName = '';
      _repairDuration.clear();
      _additionalInfoForRepair.clear();
      _dataSheetController.clear();
      _certification.clear();
      _materialDescriptionControllers.clear();
      _quantityControllers.clear();
      _uploadedImageUrls.clear();
      _images.clear();
      _inspectedDate.clear();
      _inspectedBy.clear();
      selectedotherRequirement.clear();
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto1 = '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto1OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto2 = '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto2OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto3 = '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto3OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto4 = '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto4OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto5 = '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto5OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto6 = '';
      widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto6OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.dataSheetNo = '';
      widget.exInspectionRequest.equipmentTagRequest?.dataSheet = '';
      widget.exInspectionRequest.equipmentTagRequest?.dataSheetOrgName = '';
      widget.exInspectionRequest.equipmentTagRequest?.inspectedDate = '';
      widget.exInspectionRequest.equipmentTagRequest?.inspectedBy = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairedDate = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairedBy = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto1 = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto1OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto2 = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto2OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto3 = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto3OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto4 = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto4OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto5 = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto5OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto6 = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto6OrgName =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.defectDefectCategory ==
          null;
      widget.exInspectionRequest.equipmentTagRequest?.defectCertificationNo =
          '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.defectCertificationOrgName = '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.defectCertificationAttach = '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveCertificationAttach = '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveCertificationOrgName = '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveCertificationNo = '';
      widget.exInspectionRequest.equipmentTagRequest?.materials = [];
      widget.exInspectionRequest.equipmentTagRequest?.defectIsolation = '';
      widget.exInspectionRequest.equipmentTagRequest?.defectOtherRequirements =
          [];
      widget.exInspectionRequest.equipmentTagRequest?.rbiStrategy = null;
      widget.exInspectionRequest.equipmentTagRequest?.supplementaryMaterialReq =
          [];
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveOtherRequirements = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctiveisolation = '';
      _selectedUnitValues.clear();
      _certificationControllers.clear();
      _certification.clear();
    });
    onSubmitDefectAnalysis(clearFlag: true);
  }

  Future<void> _pickImageFromGallery() async {
    int totalImages = _images.length + _uploadedImageUrls.length;

    int remainingImages = 6 - totalImages;
    if (remainingImages <= 0) {
      Fluttertoast.showToast(
        msg: "You can only upload up to 6 images.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0,
      );
      return;
    }
    final result = await _picker.pickMultiImage();
    if (result.length > remainingImages) {
      Fluttertoast.showToast(
        msg: "You can only select up to $remainingImages more images.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 15.0,
      );
      return;
    }
    setState(() {
      _images.clear();
      _images.addAll(result.map((file) => File(file.path)));
    });
    for (var image in _images) {
      final ext = image.path.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        image = await _compressImage(image);
      }
      _uploadImage(image, 'DefectUpload');
    }
    _images.clear();
  }

  Future<void> _captureImageFromCamera() async {
    // final result = await _picker.pickImage(source: ImageSource.camera);

    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (context) => const CustomCameraScreen()),
    );
    if (result != null) {
      setState(() {
        _images.add(File(result.path));
      });
      for (var image in _images) {
        final ext = image.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png'].contains(ext)) {
          image = await _compressImage(image);
        }
        _uploadImage(image, 'DefectUpload');
      }
      _images.clear();
    }
  }

  Future<void> _processAndUploadFile(
    File file,
    TextEditingController controller,
    String fileOf,
  ) async {
    String originalFileName = file.path.split('/').last;
    String fileExtension = originalFileName.split('.').last;
    String customFileNameBase = generateCustomFileName(fileOf);
    String customFileName = '$customFileNameBase.$fileExtension';
    controller.text = originalFileName.split('.').first;
    final customFilePath = '${file.parent.path}/$customFileName';
    await file.rename(customFilePath);
    setState(() {
      int index = _certificationControllers.indexOf(controller);
      if (index != -1) {
        _materials[index]['certificationAttach'] = customFilePath;
        _materials[index]['certificationOrgName'] = customFileNameBase;
        controller.text = customFileNameBase;
      }
    });
    File data = File(customFilePath);
    final ext = data.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      data = await _compressImage(data);
    }
    _uploadFile(data, fileOf);
  }

  void _uploadFile(File file, String fileOf) {
    context.read<ExInspectionsBloc>().add(UploadFile(file, fileOf));
  }

  Future<File> _compressImage(File xfile) async {
    final File file = File(xfile.path);

    final fileSizeInBytes = await file.length();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (fileSizeInMB <= 2.0) {
      return file;
    }

    // Original name
    final String originalFileName = path.basename(file.path);
    final String parentDir = file.parent.path;

    final String baseName = originalFileName.split('.').first;
    // Temporary compressed path must end in .jpg for CompressFormat.jpeg
    final String tempCompressedPath = '$parentDir/compressed_$baseName.jpg';

    int quality = 90;
    if (fileSizeInMB > 4.0) {
      quality = 70;
    } else if (fileSizeInMB > 3.0) {
      quality = 75;
    } else if (fileSizeInMB > 2.5) {
      quality = 80;
    } else {
      quality = 85;
    }
    final XFile? compressedXFile =
        await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tempCompressedPath,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (compressedXFile == null) {
      return file;
    }

    final File compressedFile = File(compressedXFile.path);

    // final compressedSizeMB = (await compressedFile.length()) / (1024 * 1024);
    final String finalPath = '$parentDir/$originalFileName';

    // Delete original file before overwrite
    if (await File(finalPath).exists()) {
      await File(finalPath).delete();
    }

    final File finalFile = await compressedFile.rename(finalPath);

    return finalFile;
  }

  void _uploadImage(File image, String fileOf) {
    context.read<ExInspectionsBloc>().add(UploadFile(image, fileOf));
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      barrierColor: const Color(0x14000000),
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            height: 150,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Select Image Source',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF1C232E),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 0.07,
                                    letterSpacing: 0.90,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Camera Button
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _captureImageFromCamera();
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
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(
                            'Camera',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFFAFBFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                              letterSpacing: 0.80,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Gallery Button
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _pickImageFromGallery();
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
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(
                            'Gallery',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFFAFBFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                              letterSpacing: 0.80,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFile(
    BuildContext context,
    TextEditingController controller,
    String fileOf,
  ) async {
    final picker = ImagePicker();
    final CustomFileSource? selection = await _showAttachmentSourceDialog(
      context,
    );

    File? file;

    if (selection == CustomFileSource.camera) {
      // final pickedImage = await picker.pickImage(source: ImageSource.camera);

      final pickedImage = await Navigator.push<File>(
        context,
        MaterialPageRoute(builder: (context) => const CustomCameraScreen()),
      );
      if (pickedImage != null) {
        file = File(pickedImage.path);
      }
    } else if (selection == CustomFileSource.gallery) {
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        file = File(pickedImage.path);
      }
    } else if (selection == CustomFileSource.file) {
      file = await _pickCustomFile();
    } else {
      // User tapped outside the dialog or pressed back
      return;
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (file != null) {
      await _processAndUploadFile(file, controller, fileOf);
    }
  }

  Future<CustomFileSource?> _showAttachmentSourceDialog(BuildContext context) {
    return showDialog<CustomFileSource>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            height: 150,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select Attachment Source',
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF1C232E),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 0.07,
                                letterSpacing: 0.90,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pop(context, CustomFileSource.camera),
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
                            'Camera',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFFAFBFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                              letterSpacing: 0.80,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pop(context, CustomFileSource.gallery),
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
                            'Gallery',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFFAFBFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                              letterSpacing: 0.80,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pop(context, CustomFileSource.file),
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
                            'File',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFFAFBFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 0.08,
                              letterSpacing: 0.80,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<File?> _pickCustomFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xlsx', 'xls'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  String generateCustomFileName(String fileOf) {
    String prefix = fileOf == 'datasheet' ? 'EDS' : 'DC';
    List<String> descriptionWords =
        widget.exInspectionRequest.equipmentTagRequest!.description.split(' ');
    String descriptionPart = descriptionWords.take(3).map((word) {
      return word.substring(0, min(word.length, 1)).toUpperCase();
    }).join();
    String? manufacturer =
        widget.exInspectionRequest.equipmentTagRequest!.manufacturer
            ?.toString()
            .substring(
              0,
              min(
                widget.exInspectionRequest.equipmentTagRequest!.manufacturer!
                    .length,
                3,
              ),
            )
            .toUpperCase();
    String? model = widget.exInspectionRequest.equipmentTagRequest!.type
        ?.toString()
        .substring(
          0,
          min(widget.exInspectionRequest.equipmentTagRequest!.type!.length, 3),
        )
        .toUpperCase();
    return '$prefix-$descriptionPart-$manufacturer-$model';
  }

  Future<void> updateInspectedUser({bool? clearCollection = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final loggedInUser = await _dbHelper.getLoggedInUserByUserId(userId!);
    DateTime now = DateTime.now();
    // String formattedDate = DateFormat('dd/MM/yyyy hh:mma').format(now);
    // String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(now);
    // String formattedDate = DateFormat("dd MMM yy HH:mm 'Hrs'").format(now);
    String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss",
    ).format(now); //DateFormat("dd-MM-yyyy hh:mm a")
    if (clearCollection == false) {
      setState(() {
        _inspectedBy.text = loggedInUser!.userName;
        _inspectedDate.text = formatDate(formattedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocListener<ExInspectionsBloc, ExInspectionsState>(
        listener: (context, state) {
          if (state is FileUploadSuccess) {
            dynamic uploadData = state.uploadData;
            if (uploadData is List<dynamic>) {
              for (var fileData in uploadData) {
                _handleFileData(fileData);
              }
            } else if (uploadData is Map<String, dynamic> &&
                uploadData.containsKey('data')) {
              for (var fileData in uploadData['data']) {
                _handleFileData(fileData);
              }
            } else {
              _handleFileData(uploadData);
            }
          } else if (state is ExInspectionSuccess) {
            updateInspectedUser(clearCollection: state.clearFlag);
            if (widget.isEditModeNotifier.value) {
              Fluttertoast.showToast(
                msg: state.message,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
            context.read<ExInspectionsBloc>().add(FetchAllDropDwn());
          } else if (state is ExInspectionError) {
            Fluttertoast.showToast(
              msg: 'Error: ${state.error}',
              toastLength: Toast.LENGTH_LONG,
            );
          }
        },
        child: BlocBuilder<ExInspectionsBloc, ExInspectionsState>(
          builder: (context, state) {
            if (state is ExInspectionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExInspectionLoaded) {
              final checklistData =
                  widget.exInspectionRequest.equipmentTagRequest?.checkList ??
                      [];
              final List<dynamic> defectData = _extractAndSortDefectData(
                checklistData,
              );
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTableSection(defectData),
                    _buildImageUploadSection(),
                    _buildForm(state.allDropDowns ?? {}),
                    if (_inspectionStatusController.text != 'Green')
                      _buildInspectionMaterialRequirements(),
                    _buildInspectionSignOff(),
                  ],
                ),
              );
            } else if (state is ExInspectionError) {
              return Center(child: Text('Error: ${state.error}'));
            } else {
              return const Center(child: Text('Loading..'));
            }
          },
        ),
      ),
    );
  }

  void _handleFileData(dynamic fileData) {
    final fileType = fileData['type'];
    final fileMetadata = fileData['uploadStatus'];
    if (fileType == 'datasheet') {
      setState(() {
        _dataSheetNo = fileMetadata['originalName'];
        _dataSheet = fileMetadata['file'];
        _dataSheetOrgName = _dataSheetNo!.split('.').first;
        _dataSheetController.text = _dataSheetOrgName!;
      });
      Fluttertoast.showToast(
        msg: "Equipment Nameplate/Data Sheet uploaded successfully",
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (fileType == 'defectCertificationAttach') {
      setState(() {
        _defectCertificationNo = fileMetadata['originalName'];
        _defectCertificationAttach = fileMetadata['file'];
        _defectCertificationOrgName = _defectCertificationNo!.split('.').first;
        _defectCertificationController.text = _defectCertificationOrgName!;
      });
      Fluttertoast.showToast(
        msg: "Certification uploaded successfully",
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (fileType.startsWith('DefectUpload')) {
      final newImage = {
        'name': fileMetadata['originalName'],
        'file': fileMetadata['file'],
      };
      for (int i = 0; i < 6; i++) {
        if ((i == 0 && _defectivePhoto1!.isEmpty) ||
            (i == 1 && _defectivePhoto2!.isEmpty) ||
            (i == 2 && _defectivePhoto3!.isEmpty) ||
            (i == 3 && _defectivePhoto4!.isEmpty) ||
            (i == 4 && _defectivePhoto5!.isEmpty) ||
            (i == 5 && _defectivePhoto6!.isEmpty)) {
          setState(() {
            String customImageName = _generateCustomImageName(
              'DefectUpload',
              i + 1,
            );
            if (i == 0) {
              _defectivePhoto1OrgName = customImageName;
              _defectivePhoto1 = newImage['file'];
            } else if (i == 1) {
              _defectivePhoto2OrgName = customImageName;
              _defectivePhoto2 = newImage['file'];
            } else if (i == 2) {
              _defectivePhoto3OrgName = customImageName;
              _defectivePhoto3 = newImage['file'];
            } else if (i == 3) {
              _defectivePhoto4OrgName = customImageName;
              _defectivePhoto4 = newImage['file'];
            } else if (i == 4) {
              _defectivePhoto5OrgName = customImageName;
              _defectivePhoto5 = newImage['file'];
            } else if (i == 5) {
              _defectivePhoto6OrgName = customImageName;
              _defectivePhoto6 = newImage['file'];
            }
            _uploadedImageUrls.add(newImage['file']);
            _imageNames.add(customImageName);
          });
          break;
        }
      }
    }
  }

  String _generateCustomImageName(String fileOf, int imageSlot) {
    String equipmentDescription = widget
        .exInspectionRequest.equipmentTagRequest!.description
        .toUpperCase();
    return '$equipmentDescription-Image$imageSlot';
  }

  Widget _buildTableSection(List<dynamic> defectData) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 25, right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Table(
            border: const TableBorder(
              left: BorderSide(color: Color(0xFFF2F2F7), width: 1),
              right: BorderSide(color: Color(0xFFF2F2F7), width: 1),
              horizontalInside: BorderSide(color: Color(0xFFF2F2F7), width: 1),
              bottom: BorderSide(color: Color(0xFFF2F2F7), width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              _buildTableRow([
                'Defect Code',
                'Findings',
                'Remedial Actions',
              ], isHeader: true),
              if (defectData.isEmpty)
                TableRow(
                  children: [
                    const SizedBox(),
                    TableCell(
                      child: Container(
                        height: 50.0,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          'No defects to show',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 13.0,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    const SizedBox(),
                  ],
                )
              else
                ...defectData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final defect = entry.value;
                  final isLastRow = index == defectData.length - 1;
                  return _buildTableRow([
                    defect['defectCode'],
                    defect['finding'],
                    defect['remedialAction'],
                  ], isLastRow: isLastRow);
                }),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(
    List<String> cells, {
    bool isHeader = false,
    bool isLastRow = false,
  }) {
    final cellColor = isHeader ? const Color(0xFF002B5C) : Colors.white;
    final textColor = isHeader ? Colors.white : const Color(0xFF353535);
    return TableRow(
      children: cells.asMap().entries.map((entry) {
        final index = entry.key;
        final cell = entry.value;
        BorderRadius? borderRadius;
        if (isHeader) {
          if (index == 0) {
            borderRadius = const BorderRadius.only(topLeft: Radius.circular(8));
          } else if (index == cells.length - 1) {
            borderRadius = isHeader
                ? const BorderRadius.only(topRight: Radius.circular(8))
                : const BorderRadius.only(bottomRight: Radius.circular(8));
          }
        } else if (isLastRow) {
          if (index == 0) {
            borderRadius = const BorderRadius.only(
              bottomLeft: Radius.circular(8),
            );
          } else if (index == cells.length - 1) {
            borderRadius = const BorderRadius.only(
              bottomRight: Radius.circular(8),
            );
          }
        }

        return TableCell(
          child: Container(
            height: isHeader ? 48 : 58,
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: borderRadius,
              border: const Border(
                  // left: BorderSide(color: Color(0xFFF2F2F7), width: 1),
                  // right:
                  //     BorderSide(color: Color(0xFFF2F2F7), width: 1),
                  // bottom: BorderSide(color: Color(0xFFF2F2F7), width: 1),
                  ),
            ),
            child: Align(
              alignment: index == 0 ? Alignment.center : Alignment.centerLeft,
              child: Padding(
                padding: isHeader
                    ? index == 2
                        ? const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10,
                            left: 8,
                            right: 24,
                          )
                        : const EdgeInsets.all(8.0)
                    : index == 0
                        ? const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10,
                            left: 24,
                            right: 8,
                          )
                        : index == 2
                            ? const EdgeInsets.only(
                                top: 10.0,
                                bottom: 10,
                                left: 8,
                                right: 24,
                              )
                            : const EdgeInsets.all(8.0),
                child: isHeader
                    ? Text(
                        cell,
                        style: isHeader
                            ? GoogleFonts.inter(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.0,
                                height: 14 / 12,
                              )
                            : GoogleFonts.inter(
                                color: textColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                                height: 16 / 12,
                              ),
                        textAlign:
                            index == 0 ? TextAlign.center : TextAlign.left,
                        overflow: index == 0 ? TextOverflow.ellipsis : null,
                        maxLines: index == 0 ? 1 : null,
                      )
                    : index == 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 24.0,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDF3F8),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                            ),
                            child: Text(
                              cell,
                              style: GoogleFonts.inter(
                                color: textColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 13.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Text(
                            cell,
                            style: GoogleFonts.inter(
                              color: textColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 13.0,
                            ),
                            textAlign: TextAlign.left,
                          ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageUploadSection() {
    int totalImages = _images.length + _uploadedImageUrls.length;
    int remainingImages = 6 - totalImages;
    String imagesMessage = totalImages == 0
        ? 'You can add up to 6 images.'
        : remainingImages == 0
            ? 'No more images can be added.'
            : remainingImages == 1
                ? 'You can add 1 more image.'
                : 'You can add $remainingImages more images.';

    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 24,
        right: 24,
        bottom: 24.0,
      ),
      child: CustomPaint(
        painter: DottedBorderPainter(),
        child: Container(
          height: 76,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            // border: Border.all(color: const Color(0xFFD0D3D8), width: 1.0),
            // boxShadow: const [
            //   BoxShadow(
            //     color: Color.fromRGBO(0, 43, 92, 0.64),
            //     blurRadius: 2,
            //     spreadRadius: 0,
            //     offset: Offset(0, 0),
            //   ),
            // ],
            boxShadow: [
              BoxShadow(
                color: Color(0xFFB3CCE0),
                blurRadius: 4.0,
                spreadRadius: 0.0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (totalImages > 0)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var i = 0;
                                    i < _uploadedImageUrls.length;
                                    i++)
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      if (i < _uploadedImageUrls.length &&
                                          i < _imageNames.length) {
                                        final imagePath = _uploadedImageUrls[i];
                                        final isLocal = imagePath.startsWith(
                                          '/data/user/',
                                        );
                                        _showImageDialog(
                                          isLocal
                                              ? imagePath
                                              : "$apiUrl/$imagePath",
                                          _imageNames[i] ?? 'Unknown',
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12.0,
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          final imagePath =
                                              _uploadedImageUrls[i];
                                          final isLocal = imagePath.startsWith(
                                            '/data/user/',
                                          );
                                          final imageWidget = isLocal
                                              ? Image.file(
                                                  File(imagePath),
                                                  width: 71.86,
                                                  height: 52,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  "$apiUrl/$imagePath",
                                                  width: 71.86,
                                                  height: 52,
                                                  fit: BoxFit.cover,
                                                );

                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              imageWidget,
                                              SvgPicture.asset(
                                                "lib/src/features/ex_inspections/assets/image_watermark.svg",
                                                height: 24,
                                                width: 24,
                                                color: Colors.white.withValues(
                                                  alpha: 0.6,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (totalImages == 0 && !widget.isEditModeNotifier.value)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        'No images found',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  if (remainingImages > 0)
                    !widget.isEditModeNotifier.value
                        ? const SizedBox()
                        : Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: !widget.isEditModeNotifier.value
                                          ? null
                                          : _showImageSourceDialog,
                                      child: SvgPicture.asset(
                                        'lib/src/features/ex_inspections/assets/add_circle.svg',
                                        width: 40.0,
                                        height: 40.0,
                                        color: const Color(0xFF115AC0),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Upload Image',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            height: 20 / 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          imagesMessage,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            height: 21 / 14,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF919191),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  if (remainingImages > 0)
                    !widget.isEditModeNotifier.value
                        ? const SizedBox()
                        : ElevatedButton(
                            onPressed: _showImageSourceDialog,
                            style: ButtonStyle(
                              shadowColor: const WidgetStatePropertyAll(
                                Color.fromRGBO(26, 133, 236, 0.24),
                              ),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                              ),
                              backgroundColor: WidgetStateProperty.all<Color>(
                                Colors.white,
                              ),
                              foregroundColor: WidgetStateProperty.all<Color>(
                                const Color(0xFF1769AA),
                              ),
                              side: WidgetStateProperty.all<BorderSide>(
                                const BorderSide(color: Color(0xFF1769AA)),
                              ),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Add',
                                  style: GoogleFonts.inter(
                                    height: 24 / 17,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF002B5C),
                                    fontSize: 17.0,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                const Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Color(0xFF3B475B),
                                ),
                              ],
                            ),
                          ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isRemoteImagePath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return true;
    }
    if (path.startsWith('file://') ||
        path.startsWith('/data/') ||
        path.startsWith('/storage/') ||
        path.startsWith('/sdcard/') ||
        path.startsWith('C:') ||
        path.startsWith('D:')) {
      return false;
    }
    final file = File(path);
    if (file.existsSync()) {
      return false;
    }
    return true;
  }

  String _getResolvedImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final currentApiUrl = apiUrl ?? '';
    final base = currentApiUrl.endsWith('/')
        ? currentApiUrl.substring(0, currentApiUrl.length - 1)
        : currentApiUrl;
    return base.isNotEmpty ? "$base/$cleanPath" : cleanPath;
  }

  Widget _buildImagePreviewWidget(String imagePath,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (_isRemoteImagePath(imagePath)) {
      final url = _getResolvedImageUrl(imagePath);
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: const Color(0xFFF1F5F9),
          alignment: Alignment.center,
          child:
              const Icon(Icons.broken_image, color: Color(0xFF94A3B8), size: 28),
        ),
      );
    } else {
      final cleanPath =
          imagePath.startsWith('file://') ? imagePath.substring(7) : imagePath;
      return Image.file(
        File(cleanPath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: const Color(0xFFF1F5F9),
          alignment: Alignment.center,
          child:
              const Icon(Icons.broken_image, color: Color(0xFF94A3B8), size: 28),
        ),
      );
    }
  }

  void _showImageDialog(String imagePath, String imageName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.5,
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 64,
                  // margin: EdgeInsets.only(bottom: ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFFF2F2F7), width: 1.0),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF002B5C).withValues(alpha: 0.16),
                        offset: const Offset(0, 1),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          imageName,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1B2029),
                            height: 32 / 20,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF3B475B),
                          size: 32,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white60),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: _buildImagePreviewWidget(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 24,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        !widget.isEditModeNotifier.value
                            ? const SizedBox()
                            : _buildStyledButton(
                                text: 'Delete',
                                onPressed: () {
                                  _deleteImage(imagePath, imageName);
                                  Navigator.of(context).pop();
                                },
                                isPrimary: false,
                                width: 110,
                                fontSize: 16,
                                paddingVertical: 12,
                                paddingHorizontal: 24,
                              ),
                        const SizedBox(width: 20),
                        !widget.isEditModeNotifier.value
                            ? const SizedBox()
                            : _buildStyledButton(
                                text: 'Close',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                isPrimary: true,
                                width: 120,
                                fontSize: 16,
                                paddingVertical: 12,
                                paddingHorizontal: 24,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required double width,
    required double fontSize,
    required double paddingVertical,
    required double paddingHorizontal,
  }) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFAB2F26)),
          backgroundColor: isPrimary ? const Color(0xFF1E90FF) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFFAB2F26),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 24 / 17,
          ),
        ),
      ),
    );
  }

  void _deleteImage(String imageUrl, String imageName) {
    setState(() {
      String strippedImageUrl = imageUrl.replaceFirst('$apiUrl/', '');
      _uploadedImageUrls.remove(strippedImageUrl);
      _imageNames.remove(imageName);
      if (_defectivePhoto1 == strippedImageUrl) {
        _defectivePhoto1 = '';
        _defectivePhoto1OrgName = '';
      } else if (_defectivePhoto2 == strippedImageUrl) {
        _defectivePhoto2 = '';
        _defectivePhoto2OrgName = '';
      } else if (_defectivePhoto3 == strippedImageUrl) {
        _defectivePhoto3 = '';
        _defectivePhoto3OrgName = '';
      } else if (_defectivePhoto4 == strippedImageUrl) {
        _defectivePhoto4 = '';
        _defectivePhoto4OrgName = '';
      } else if (_defectivePhoto5 == strippedImageUrl) {
        _defectivePhoto5 = '';
        _defectivePhoto5OrgName = '';
      } else if (_defectivePhoto6 == strippedImageUrl) {
        _defectivePhoto6 = '';
        _defectivePhoto6OrgName = '';
      }
      _updateDefectivePhotoNames();
    });
  }

  void _updateDefectivePhotoNames() {
    _defectivePhoto1OrgName = _defectivePhoto1?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.defectivePhoto1OrgName;
    _defectivePhoto2OrgName = _defectivePhoto2?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.defectivePhoto2OrgName;
    _defectivePhoto3OrgName = _defectivePhoto3?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.defectivePhoto3OrgName;
    _defectivePhoto4OrgName = _defectivePhoto4?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.defectivePhoto4OrgName;
    _defectivePhoto5OrgName = _defectivePhoto5?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.defectivePhoto5OrgName;
    _defectivePhoto6OrgName = _defectivePhoto6?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.defectivePhoto6OrgName;
  }

  Widget _buildForm(Map<String, dynamic> getAllDropDowns) {
    final exRegisterDropDown = getAllDropDowns['result']['exResiterDropDown'][0]
        as Map<String, dynamic>;

    final isolationRequirement =
        (exRegisterDropDown['isolationRepairs'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final otherRequirement =
        (exRegisterDropDown['otherRequirement'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final defectCategory =
        (exRegisterDropDown['defectCategory'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final inspectionStatusList =
        (exRegisterDropDown['inspectionStatus'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ?? ['Red', 'Yellow', 'Green'];

    final overAllConditionList =
        (exRegisterDropDown['overAllCondition'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ?? ['Major Repair Required', 'Minor Repair Required', 'Observation', 'Good to Use'];

    bool isGreenStatus = _inspectionStatusController.text == 'Green';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspection Summary',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24.0,
              runSpacing: 16.0,
              children: [
                _buildLabeledTextField(
                  label: 'Faulty Items',
                  controller: _faultyItems,
                  isReadOnly: true,
                  isNotApplicable: _faultyItems.text == '0' ||
                      selectedDefectCategory == 'Not Applicable',
                ),
                _buildDefectCategoryDropdownField(
                  dropDownEnabled: dropDownEnabled,
                  label: 'Repair Priority (Defect Category)',
                  value: selectedDefectCategory.isEmpty
                      ? 'Not Applicable'
                      : selectedDefectCategory,
                  items: (_faultyItems.text == '0')
                      ? ['Not Applicable']
                      : defectCategory
                          .where((item) => item != 'Not Applicable')
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      dropDownEnabled = false;
                      selectedDefectCategory = value ?? 'Not Applicable';
                      _setDropdownValues(selectedDefectCategory);
                    });
                  },
                  onTap: () async {
                    bool? confirmEdit = await _showEditConfirmationDialog(
                      context,
                    );
                    if (confirmEdit == true) {
                      dropDownEnabled = true;
                    }
                  },
                ),
                _buildLabeledDropdownField(
                  label: 'Inspection Status',
                  value: selectedDefectCategory == 'Not Applicable'
                      ? 'Not Applicable'
                      : (inspectionStatusList.contains(_inspectionStatusController.text)
                          ? _inspectionStatusController.text
                          : null),
                  items: selectedDefectCategory == 'Not Applicable'
                      ? ['Not Applicable']
                      : inspectionStatusList,
                  onChanged: (value) {
                    setState(() {
                      _inspectionStatusController.text = value ?? '';
                    });
                  },
                  isNotApplicable: selectedDefectCategory == 'Not Applicable',
                ),
                _buildLabeledDropdownField(
                  label: 'Overall Condition',
                  value: selectedDefectCategory == 'Not Applicable'
                      ? 'Not Applicable'
                      : (overAllConditionList.contains(_overallConditionController.text)
                          ? _overallConditionController.text
                          : null),
                  items: selectedDefectCategory == 'Not Applicable'
                      ? ['Not Applicable']
                      : overAllConditionList,
                  onChanged: (value) {
                    setState(() {
                      _overallConditionController.text = value ?? '';
                    });
                  },
                  isNotApplicable: selectedDefectCategory == 'Not Applicable',
                ),
                _buildLabeledDropdownField(
                  label: 'Isolations For Repairs',
                  value: isGreenStatus
                      ? 'Not Applicable'
                      : _selectedIsolationRequirement,
                  items: isGreenStatus
                      ? ['Not Applicable']
                      : isolationRequirement.toSet().toList(),
                  onChanged: isGreenStatus
                      ? (_) {}
                      : (value) {
                          setState(() {
                            _selectedIsolationRequirement = value;
                          });
                        },
                  isNotApplicable: selectedDefectCategory == 'Not Applicable',
                ),
                MultiSelectDropdown(
                  label: 'Other Requirements',
                  items: isGreenStatus
                      ? ['Not Applicable']
                      : otherRequirement.toSet().toList(),
                  selectedItems: isGreenStatus
                      ? ['Not Applicable']
                      : selectedotherRequirement,
                  isSubmitting: true,
                  selectedItemString: _selectedOtherRequirement,
                  onChanged: isGreenStatus
                      ? (_) {
                          selectedotherRequirement = ['Not Applicable'];
                        }
                      : (value) {
                          setState(() {
                            selectedotherRequirement = value;
                            _selectedOtherRequirement =
                                value.isEmpty ? '' : value.join(', ');
                          });
                        },
                  isMandatory: false,
                  isNotApplicable: selectedDefectCategory == 'Not Applicable',
                  isEditModeNotifier: widget.isEditModeNotifier,
                ),
                // _buildLabeledDropdownField(
                //   label: 'Other Requirements',
                //   value: isGreenStatus
                //       ? 'Not Applicable'
                //       : _selectedOtherRequirement,
                //   items: isGreenStatus
                //       ? ['Not Applicable']
                //       : otherRequirement.toSet().toList(),
                //   onChanged: isGreenStatus
                //       ? (_) {}
                //       : (value) {
                //           setState(() {
                //             _selectedOtherRequirement = value;
                //           });
                //         },
                //   isNotApplicable: selectedDefectCategory == 'Not Applicable',
                // ),
                _buildLabeledTextField(
                  label: 'Repair Duration (Minutes)',
                  controller: _repairDuration,
                  isReadOnly: isGreenStatus,
                  isNotApplicable: selectedDefectCategory == 'Not Applicable',
                ),
                _buildLabeledTextField(
                  label: 'Any Additional Information For Repairs',
                  controller: _additionalInfoForRepair,
                ),
                _buildFilePickerField(
                  label: 'Equipment Nameplate/Data Sheet',
                  controller: _dataSheetController,
                  fileOf: 'datasheet',
                  filePath: _dataSheet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionMaterialRequirements() {
    if (_materials.isEmpty) {
      _materials.add({
        'partNumber': '',
        'description': '',
        'manufacturer': '',
        'certification': '',
        'unit': null,
        'quantity': '',
        'certificationAttach': null,
        'certificationOrgName': null,
      });
      _partNumberControllers.add(TextEditingController());
      _materialDescriptionControllers.add(TextEditingController());
      _manufacturerControllers.add(TextEditingController());
      _certificationControllers.add(TextEditingController());
      _quantityControllers.add(TextEditingController());
      _selectedUnitValues.add(null);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 32.0, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Material Requirements',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: List.generate(_materials.length, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Material ${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 24.0,
                    runSpacing: 16.0,
                    children: [
                      _buildLabeledTextField(
                        label: 'Part Number',
                        controller: _partNumberControllers[index],
                      ),
                      _buildLabeledTextField(
                        label: 'Material Description',
                        controller: _materialDescriptionControllers[index],
                      ),
                      _buildLabeledTextField(
                        label: 'Equipment Manufacturer',
                        controller: _manufacturerControllers[index],
                      ),
                      _buildFilePickerField(
                        label: 'Certification',
                        controller: _certificationControllers[index],
                        fileOf: 'defectCertificationAttach',
                        filePath: _materials[index]['certificationAttach'],
                      ),
                      _buildLabeledDropdownField(
                        label: 'Unit',
                        value: _selectedUnitValues[index],
                        items: unit,
                        onChanged: (value) {
                          setState(() {
                            _selectedUnitValues[index] = value;
                            _materials[index]['unit'] = value;
                          });
                        },
                      ),
                      _buildLabeledTextField(
                        label: 'Quantity',
                        controller: _quantityControllers[index],
                      ),
                    ],
                  ),
                  if (index != _materials.length - 1) const Divider(),
                ],
              );
            }),
          ),
          const SizedBox(height: 24),
          !widget.isEditModeNotifier.value
              ? const SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 0.0),
                      child: ElevatedButton(
                        onPressed: !widget.isEditModeNotifier.value
                            ? null
                            : () {
                                setState(() {
                                  bool hasValue = false;
                                  for (var material in _materials) {
                                    int index = _materials.indexOf(material);
                                    // if (index == 0) {
                                    if (_partNumberControllers[index]
                                            .text
                                            .isNotEmpty ||
                                        _materialDescriptionControllers[index]
                                            .text
                                            .isNotEmpty ||
                                        _manufacturerControllers[index]
                                            .text
                                            .isNotEmpty ||
                                        _certificationControllers[index]
                                            .text
                                            .isNotEmpty ||
                                        _quantityControllers[index]
                                            .text
                                            .isNotEmpty ||
                                        _selectedUnitValues[index] != null) {
                                      hasValue = true;
                                      // break;
                                    } else {
                                      hasValue = false;
                                      // break;
                                    }
                                    // }
                                  }
                                  if (!hasValue) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Please fill in at least one field before adding materials.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return;
                                  }
                                  _materials.add({
                                    'partNumber': '',
                                    'description': '',
                                    'manufacturer': '',
                                    'certification': '',
                                    'unit': null,
                                    'quantity': '',
                                    'certificationAttach': null,
                                    'certificationOrgName': null,
                                  });
                                  _partNumberControllers.add(
                                    TextEditingController(),
                                  );
                                  _materialDescriptionControllers.add(
                                    TextEditingController(),
                                  );
                                  _manufacturerControllers.add(
                                    TextEditingController(),
                                  );
                                  _certificationControllers.add(
                                    TextEditingController(),
                                  );
                                  _quantityControllers.add(
                                    TextEditingController(),
                                  );
                                  _selectedUnitValues.add(null);

                                  Fluttertoast.showToast(
                                    msg: "Materials added successfully",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                });
                              },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.white,
                          ),
                          foregroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFF002B5C),
                          ),
                          side: WidgetStateProperty.all<BorderSide>(
                            const BorderSide(color: Color(0xFF002B5C)),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Add',
                              style: GoogleFonts.inter(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            const Icon(
                              Icons.keyboard_arrow_right,
                              color: Color(0xFF002B5C),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildInspectionSignOff() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inspection Sign Off',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24.0,
            runSpacing: 16.0,
            children: [
              _buildLabeledTextField(
                label: 'Signature',
                controller: _signature,
                imageUrl: _signatureUrl,
              ),
              _buildLabeledTextField(
                label: 'Inspected By',
                controller: _inspectedBy,
              ),
              _buildLabeledTextField(
                label: 'Inspected Date',
                controller: _inspectedDate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureWidget(String signature) {
    Widget imgWidget;
    if (signature.startsWith('data:image')) {
      try {
        final base64Str = signature.split(',').last;
        imgWidget = Image.memory(base64Decode(base64Str), fit: BoxFit.contain);
      } catch (_) {
        imgWidget = const Icon(Icons.gesture, color: Colors.grey);
      }
    } else if (signature.startsWith('http://') || signature.startsWith('https://')) {
      imgWidget = Image.network(signature, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.gesture, color: Colors.grey));
    } else if (File(signature).existsSync()) {
      imgWidget = Image.file(File(signature), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.gesture, color: Colors.grey));
    } else {
      imgWidget = Image.network(
        "$apiUrl/$signature",
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.file(
          File(signature),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.gesture, color: Colors.grey),
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: 48.0,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFD0D3D8), width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: imgWidget,
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    bool isReadOnly = false,
    bool isNotApplicable = false,
    String? imageUrl,
  }) {
    bool isDisabled = isReadOnly || isNotApplicable;
    TextStyle labelTextStyle = GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 14.0,
      color: isDisabled ? const Color(0xFFB5B5B5) : const Color(0xFF4B4B4B),
    );

    InputDecoration inputDecoration = InputDecoration(
      hintText: 'Enter here',
      hintStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        color: const Color(0xFF979797),
        fontSize: 17.0,
        height: 24 / 17,
      ),
      filled: true,
      fillColor: widget.isEditModeNotifier.value
          ? Colors.white
          : isDisabled
              ? const Color(0xFFFBFBFB)
              : const Color(0xFFFFFFFF),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 12.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFD0D3D8), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: widget.isEditModeNotifier.value
              ? Colors.white
              : isDisabled
                  ? const Color(0xFFD0D3D8)
                  : const Color(0xFF002B5C),
          width: 1.0,
        ),
      ),
    );
    // if (label == "Inspected Date") {
    //   controller.text = formatDate(controller.text);
    // }
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.275,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelTextStyle),
          const SizedBox(height: 8.0),
          if (imageUrl != null && imageUrl.isNotEmpty)
            _buildSignatureWidget(imageUrl)
          else
            ValueListenableBuilder<bool>(
              valueListenable: widget.isEditModeNotifier,
              builder: (context, isEditMode, _) {
                return Focus(
                  child: Builder(
                    builder: (context) {
                      final isFocused = Focus.of(context).hasFocus;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: isFocused
                              ? [
                                  const BoxShadow(
                                    color: Color(0xA3002B5C),
                                    blurRadius: 4,
                                    offset: Offset(0, 0),
                                  ),
                                ]
                              : null,
                        ),
                        child: TextFormField(
                          keyboardType: label == "Repair Duration (Minutes)" ||
                                  label == "Quantity"
                              ? TextInputType.number
                              : TextInputType.text,
                          readOnly: !isEditMode || isReadOnly,
                          controller: controller,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 17.0,
                            height: 24 / 17,
                            color: isDisabled
                                ? const Color(0xFFB5B5B5)
                                : const Color(0xFF212121),
                          ),
                          decoration: inputDecoration,
                          onChanged: (value) {
                            if (!isEditMode) return;
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLabeledDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    bool isNotApplicable = false,
    required ValueChanged<String?>? onChanged,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.275,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: isNotApplicable
                  ? const Color(0xFF999999)
                  : const Color(0xFF4B4B4B),
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 8.0),
          ValueListenableBuilder<bool>(
            valueListenable: widget.isEditModeNotifier,
            builder: (context, isEditMode, _) {
              return SearchableDropdown(
                value: value,
                items: items,
                onChanged: onChanged,
                isEditMode: isEditMode,
                isNotApplicable: isNotApplicable,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefectCategoryDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Function()? onTap,
    required bool dropDownEnabled,
  }) {
    // final TextEditingController _searchController = TextEditingController();
    TextStyle labelTextStyle = GoogleFonts.inter(
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF4B4B4B),
      fontSize: 14.0,
    );
    InputDecoration inputDecoration = InputDecoration(
      filled: true,
      fillColor: widget.isEditModeNotifier.value
          ? Colors.white
          : const Color(0xFFFBFBFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 12.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFD0D3D8), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFD0D3D8), width: 1.0),
      ),
      hintStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        color: const Color(0xFF979797),
        fontSize: 17.0,
        height: 24 / 17,
      ),
    );
    bool isFaultZero = _faultyItems.text == '0';
    TextEditingController controller = TextEditingController();
    controller.text = value.toString();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.275,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelTextStyle),
          const SizedBox(height: 8.0),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: widget.isEditModeNotifier,
                builder: (context, isEditMode, _) {
                  return isEditable
                      ? Focus(
                          child: Builder(
                            builder: (context) {
                              final isFocused = Focus.of(context).hasFocus;

                              return DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  iconStyleData: IconStyleData(
                                    icon: Row(
                                      children: [
                                        !isEditMode
                                            ? const SizedBox()
                                            : Icon(
                                                isFocused
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                                color: !isEditMode
                                                    ? const Color(0xFFBABABA)
                                                    : const Color(0xFF212121),
                                                size: 24,
                                              ),
                                      ],
                                    ),
                                  ),
                                  hint: !isFocused
                                      ? Text(
                                          'Select the option',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w400,
                                            color: !isEditMode
                                                ? const Color(0xFFBABABA)
                                                : const Color(0xFF979797),
                                            fontSize: 14.0,
                                          ),
                                        )
                                      : null,
                                  //        dropdownSearchData: DropdownSearchData(
                                  //   searchController: _searchController,
                                  //   searchInnerWidgetHeight: 50,
                                  //   searchInnerWidget: Padding(
                                  //     padding: const EdgeInsets.only(
                                  //       top: 8,
                                  //       bottom: 4,
                                  //       right: 8,
                                  //       left: 8,
                                  //     ),
                                  //     child: TextFormField(
                                  //       controller: _searchController,
                                  //       decoration: InputDecoration(
                                  //         isDense: true,
                                  //         contentPadding:
                                  //             const EdgeInsets.symmetric(
                                  //           horizontal: 12,
                                  //           vertical: 8,
                                  //         ),
                                  //         hintText: 'Search...',
                                  //         hintStyle: GoogleFonts.inter(
                                  //           fontSize: 14,
                                  //           fontWeight: FontWeight.w400,
                                  //         ),
                                  //         border: OutlineInputBorder(
                                  //           borderRadius:
                                  //               BorderRadius.circular(8),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   searchMatchFn: (item, searchValue) {
                                  //     return item.value!
                                  //         .toLowerCase()
                                  //         .contains(searchValue.toLowerCase());
                                  //   },
                                  // ),
                                  value: items.contains(value) ? value : null,
                                  onChanged: !isEditMode
                                      ? null
                                      : (newValue) {
                                          onChanged(newValue);
                                        },
                                  items: items.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF212121),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  buttonStyleData: ButtonStyleData(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isEditMode
                                          ? const Color(0xFFFBFBFB)
                                          : const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: isFocused
                                            ? const Color(0xFF002B5C)
                                            : const Color(0xFFD0D3D8),
                                      ),
                                      boxShadow: isFocused
                                          ? [
                                              const BoxShadow(
                                                color: Color(0xA3002B5C),
                                                blurRadius: 4,
                                                offset: Offset(0, 0),
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 220,
                                    width: MediaQuery.of(context).size.width *
                                        0.275,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        width: 1.0,
                                        color: const Color(0xFFD0D3D8),
                                      ),
                                    ),
                                    scrollbarTheme: ScrollbarThemeData(
                                      thumbVisibility: WidgetStateProperty.all(
                                        true,
                                      ),
                                      thickness: WidgetStateProperty.all(4),
                                      radius: const Radius.circular(4),
                                      thumbColor: WidgetStateProperty.all(
                                        const Color(0xFFEBEBEB),
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : TextFormField(
                          controller: controller,
                          readOnly: !isEditMode || true,
                          decoration: inputDecoration,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFB5B5B5),
                            height: 24 / 17,
                          ),
                          onChanged: (value) {
                            if (!isEditMode) return;
                          },
                        );
                },
              ),
              if (!isEditable)
                !widget.isEditModeNotifier.value
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            if (selectedDefectCategory == 'Not Applicable') {
                              return;
                            }
                            final isConfirmed =
                                await _showEditConfirmationDialog(context);
                            if (isConfirmed ?? false) {
                              setState(() {
                                isEditable = true;
                                showEditIcon = false;
                              });
                            }
                          },
                          child: isFaultZero
                              ? ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFB5B5B5),
                                    BlendMode.srcIn,
                                  ),
                                  child: SvgPicture.asset(
                                    'lib/src/features/ex_inspections/assets/edit_square.svg',
                                    height: 24,
                                    width: 24,
                                    color: !widget.isEditModeNotifier.value
                                        ? const Color(0xFFBABABA)
                                        : const Color(0xFF3B475B),
                                  ),
                                )
                              : SvgPicture.asset(
                                  'lib/src/features/ex_inspections/assets/edit_square.svg',
                                  height: 24,
                                  width: 24,
                                  color: !widget.isEditModeNotifier.value
                                      ? const Color(0xFFBABABA)
                                      : const Color(0xFF3B475B),
                                ),
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showEditConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x14000000),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            height: 219,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 83,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Edit Confirmation',
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF1C232E),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.90,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Are you sure you want to edit this field?',
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF3B475B),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => Navigator.of(context).pop(false),
                          child: Container(
                            height: 48,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF8C8C8C),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C1B2029),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF1C232E),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.80,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => Navigator.of(context).pop(true),
                          child: Container(
                            height: 48,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1E90FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C1B2029),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Edit',
                              style: GoogleFonts.roboto(
                                color: const Color(0xFFFAFBFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.80,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilePickerField({
    required String label,
    required TextEditingController controller,
    required String fileOf,
    String? filePath,
  }) {
    bool fileAttached = controller.text.isNotEmpty;
    return SizedBox(
      width:
          MediaQuery.of(context).size.width * (fileAttached ? 0.2789 : 0.275),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B4B4B),
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                ValueListenableBuilder<bool>(
                  valueListenable: widget.isEditModeNotifier,
                  builder: (context, isEditMode, _) {
                    return Focus(
                      child: Builder(
                        builder: (context) {
                          final isFocused = Focus.of(context).hasFocus;

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: isFocused
                                  ? [
                                      const BoxShadow(
                                        color: Color(0xA3002B5C),
                                        blurRadius: 4,
                                        offset: Offset(0, 0),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: TextFormField(
                              readOnly: !isEditMode,
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: 'Enter Here',
                                hintStyle: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF979797),
                                  fontSize: 14.0,
                                ),
                                filled: true,
                                fillColor: isEditMode
                                    ? Colors.white
                                    : const Color(0xFFFBFBFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 12.0,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD0D3D8),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF002B5C),
                                    width: 1.0,
                                  ),
                                ),
                                suffixIcon: !isEditMode
                                    ? null
                                    : fileAttached
                                        ? IconButton(
                                            icon: SvgPicture.asset(
                                              'lib/src/features/ex_inspections/assets/cancel_icon.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                            onPressed: () =>
                                                _showDeleteConfirmation(
                                              context,
                                              controller,
                                              fileOf,
                                            ),
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              Icons.attach_file,
                                              color: !isEditMode
                                                  ? const Color(0xFFBABABA)
                                                  : const Color(0xFF3B475B),
                                            ),
                                            onPressed: () => _pickFile(
                                              context,
                                              controller,
                                              fileOf,
                                            ),
                                          ),
                              ),
                              onChanged: !isEditMode ? null : (value) {},
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (fileAttached) ...[
            const SizedBox(width: 8.0),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  await FileHelper.downloadAndOpenFile(
                    context: context,
                    sourceFilePath: filePath ?? controller.text,
                  );
                  // await _downloadAndOpenFile(filePath ?? controller.text);
                },
                child: SvgPicture.asset(
                  'lib/src/features/ex_inspections/assets/file_download_icon.svg',
                  width: 48,
                  height: 48,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _downloadAndOpenFile(String filePath) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "File_$timestamp.${filePath.split('.').last}";
      final downloadPath = await FileDownloadUtil().getExternalDocumentPath();
      final downloadFile = File("$downloadPath/$fileName");
      await downloadFile.writeAsBytes(await File(filePath).readAsBytes());
      if (!await downloadFile.exists()) {
        throw Exception("Failed to create the file.");
      }
      final result = await OpenFilex.open(downloadFile.path);
      if (result.type != ResultType.done) {
        throw Exception("Failed to open file: ${result.message}");
      }
      return {"location": downloadFile.path};
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download or open file: $e')),
      );
      rethrow;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TextEditingController controller,
    String fileOf,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            height: 219,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 83,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Delete Confirmation',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF1C232E),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 0.07,
                                    letterSpacing: 0.90,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Are you sure you want to delete this file?',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF3B475B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 0.11,
                                    letterSpacing: 0.70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF8C8C8C),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C1B2029),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Cancel',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: const Color(0xFF1C232E),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 0.08,
                                          letterSpacing: 0.80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: !widget.isEditModeNotifier.value
                              ? null
                              : () {
                                  _deleteFile(controller, fileOf);
                                  Navigator.of(context).pop();
                                },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1E90FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C1B2029),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Delete',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: const Color(0xFFFAFBFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 0.08,
                                          letterSpacing: 0.80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteFile(TextEditingController controller, String fileOf) {
    setState(() {
      controller.text = '';
      if (fileOf == 'datasheet') {
        _dataSheetNo = null;
        _dataSheet = null;
        _dataSheetOrgName = null;
      } else if (fileOf == 'defectCertificationAttach') {
        _defectCertificationNo = null;
        _defectCertificationAttach = null;
        _defectCertificationAttach = null;
      }
    });
  }

  String? _getTextFieldValue(TextEditingController controller) {
    return controller.text.isEmpty ? null : controller.text;
  }

  void _updateMaterials() {
    for (int i = 0; i < _materials.length; i++) {
      _materials[i] = {
        'partNumber': _partNumberControllers[i].text,
        'description': _materialDescriptionControllers[i].text,
        'manufacturer': _manufacturerControllers[i].text,
        'certification': _certificationControllers[i].text,
        'unit': _selectedUnitValues[i],
        'quantity': _quantityControllers[i].text,
        'certificationAttach': _materials[i]['certificationAttach'],
        'certificationOrgName': _certificationControllers[i]
            .text, //_materials[i]['certificationOrgName'],
      };
    }
    _materials.removeWhere((material) {
      return material['partNumber']!.isEmpty &&
          material['description']!.isEmpty &&
          material['manufacturer']!.isEmpty &&
          material['certification']!.isEmpty &&
          material['unit'] == null &&
          material['quantity']!.isEmpty &&
          material['certificationAttach'] == null;
    });
  }

  void onSubmitDefectAnalysis({required bool clearFlag}) async {
    _updateMaterials();

    List<Materials> materials = _materials
        .map(
          (entry) => Materials(
            partNumber: entry['partNumber'],
            description: entry['description'],
            manufacturer: entry['manufacturer'],
            unit: entry['unit'],
            quantity: entry['quantity'],
            certificationAttach: entry['certificationAttach'],
            certificationOrgName: entry['certificationOrgName'],
          ),
        )
        .toList();
    String? formattedDefectivePhoto1 = _defectivePhoto1!.startsWith('$apiUrl/')
        ? _defectivePhoto1!.replaceFirst('$apiUrl/', '')
        : _defectivePhoto1;
    String? formattedDefectivePhoto2 = _defectivePhoto2!.startsWith('$apiUrl/')
        ? _defectivePhoto2!.replaceFirst('$apiUrl/', '')
        : _defectivePhoto2;
    String? formattedDefectivePhoto3 = _defectivePhoto3!.startsWith('$apiUrl/')
        ? _defectivePhoto3!.replaceFirst('$apiUrl/', '')
        : _defectivePhoto3;
    String? formattedDefectivePhoto4 = _defectivePhoto4!.startsWith('$apiUrl/')
        ? _defectivePhoto4!.replaceFirst('$apiUrl/', '')
        : _defectivePhoto4;
    String? formattedDefectivePhoto5 = _defectivePhoto5!.startsWith('$apiUrl/')
        ? _defectivePhoto5!.replaceFirst('$apiUrl/', '')
        : _defectivePhoto5;
    String? formattedDefectivePhoto6 = _defectivePhoto6!.startsWith('$apiUrl/')
        ? _defectivePhoto6!.replaceFirst('$apiUrl/', '')
        : _defectivePhoto6;
    _dataSheetOrgName = _dataSheetController.text.isNotEmpty
        ? _dataSheetController.text
        : _dataSheetNo?.split('.').first;
    _defectCertificationOrgName = _defectCertificationController.text.isNotEmpty
        ? _defectCertificationController.text
        : _defectCertificationNo?.split('.').first;
    String cuStatus;
    final category = int.tryParse(selectedDefectCategory);
    if (category == 1 || category == 2) {
      cuStatus = int.parse(
                widget.exInspectionRequest.equipmentTagRequest!.existingFaults
                    .toString(),
              ) ==
              0
          ? 'Green'
          : 'Red';
    } else if (category == 3 || category == 4 || category == 5) {
      cuStatus = int.parse(
                widget.exInspectionRequest.equipmentTagRequest!.existingFaults
                    .toString(),
              ) ==
              0
          ? 'Green'
          : 'Yellow';
    } else {
      cuStatus = 'Green';
    }
    dynamic signatureImg;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final dbHelper = DBHelper();
      UserDetails? user = await dbHelper.getLoggedInUserByUserId(userId);
      if (user != null) {
        signatureImg = user.signature;
      } else {
        signatureImg =
            widget.exInspectionRequest.equipmentTagRequest?.inspectionSignOff;
      }
    } else {
      signatureImg =
          widget.exInspectionRequest.equipmentTagRequest?.inspectionSignOff;
    }
    widget.exInspectionRequest.equipmentTagRequest = EquipmentTagRequest(
      location: widget.exInspectionRequest.functionalAreaRequest!.location,
      area: widget.exInspectionRequest.functionalAreaRequest!.area,
      zone: widget.exInspectionRequest.functionalAreaRequest!.zone,
      isActive: widget.exInspectionRequest.functionalAreaRequest!.isActive,
      locationGasGroup:
          widget.exInspectionRequest.functionalAreaRequest!.locationGasGroup,
      locationTClass:
          widget.exInspectionRequest.functionalAreaRequest!.locationTClass,
      locationIpRating:
          widget.exInspectionRequest.functionalAreaRequest!.locationIpRating,
      locationId:
          widget.exInspectionRequest.equipmentTagRequest?.locationId ?? '',
      locationLatitude:
          widget.exInspectionRequest.functionalAreaRequest!.locationLatitude,
      locationLongitude:
          widget.exInspectionRequest.functionalAreaRequest!.locationLongitude,
      locationTAmbient:
          widget.exInspectionRequest.functionalAreaRequest!.tAmbient,
      deckLevel: widget.exInspectionRequest.functionalAreaRequest!.deckLevel,
      rfidRef: widget.exInspectionRequest.equipmentTagRequest?.rfidRef,
      gpsCord: widget.exInspectionRequest.equipmentTagRequest?.gpsCord,
      eqpmtCatg: widget.exInspectionRequest.equipmentTagRequest!.eqpmtCatg,
      eqpmtTag: widget.exInspectionRequest.equipmentTagRequest?.eqpmtTag,
      circuitId: widget.exInspectionRequest.equipmentTagRequest?.circuitId,
      cableId: widget.exInspectionRequest.equipmentTagRequest?.cableId,
      equipmentCategory:
          widget.exInspectionRequest.equipmentTagRequest?.equipmentCategory,
      description: widget.exInspectionRequest.equipmentTagRequest!.description,
      manufacturer:
          widget.exInspectionRequest.equipmentTagRequest?.manufacturer,
      type: widget.exInspectionRequest.equipmentTagRequest?.type,
      serialNumber:
          widget.exInspectionRequest.equipmentTagRequest?.serialNumber,
      atexCatg: widget.exInspectionRequest.equipmentTagRequest!.atexCatg,
      epl: widget.exInspectionRequest.equipmentTagRequest!.epl,
      protectionStd:
          widget.exInspectionRequest.equipmentTagRequest?.protectionStd,
      protectionType:
          widget.exInspectionRequest.equipmentTagRequest!.protectionType,
      equipmentGasGroup:
          widget.exInspectionRequest.equipmentTagRequest!.equipmentGasGroup,
      equipmentTClass:
          widget.exInspectionRequest.equipmentTagRequest!.equipmentTClass,
      equipmentIpRating:
          widget.exInspectionRequest.equipmentTagRequest!.equipmentIpRating,
      certfnBody: widget.exInspectionRequest.equipmentTagRequest?.certfnBody,
      certfnNo: widget.exInspectionRequest.equipmentTagRequest?.certfnNo,
      tAmbient: widget.exInspectionRequest.equipmentTagRequest?.tAmbient,
      tAmbientEquip:
          widget.exInspectionRequest.equipmentTagRequest?.tAmbientEquip,
      inspectionSignOff: signatureImg,
      repairSignOff:
          widget.exInspectionRequest.equipmentTagRequest?.repairSignOff,
      specialCond: widget.exInspectionRequest.equipmentTagRequest?.specialCond,
      oracleId: widget.exInspectionRequest.equipmentTagRequest?.oracleId,
      assetId: widget.exInspectionRequest.equipmentTagRequest?.assetId,
      checkList: widget.exInspectionRequest.equipmentTagRequest?.checkList,
      inspectedBy: userName,
      inspectedDate:
          //DateFormat("dd-MM-yyyy hh:mm a")
          DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now()),
      //  _inspectedDate.text,
      //  DateFormat("dd MMM yy HH:mm 'Hrs'").format(DateTime.now().toLocal()),
      repairedBy: widget.exInspectionRequest.equipmentTagRequest?.repairedBy,
      repairedDate:
          widget.exInspectionRequest.equipmentTagRequest?.repairedDate,
      faultyItems: _getTextFieldValue(_faultyItems),
      defectDefectCategory: selectedDefectCategory,
      repairPriority: int.tryParse(selectedDefectCategory) ?? 0,
      inspectionStatus: _getTextFieldValue(_inspectionStatusController),
      defectOverallCondition: _getTextFieldValue(_overallConditionController),
      defectIsolation: _selectedIsolationRequirement,
      defectOtherRequirements: selectedotherRequirement,
      additionalInfoForRepairs: _getTextFieldValue(_additionalInfoForRepair),
      dataSheet: _dataSheet,
      dataSheetOrgName: _dataSheetOrgName,
      dataSheetNo: _dataSheetNo,
      defectCertificationNo: _defectCertificationNo,
      defectCertificationOrgName: _defectCertificationOrgName,
      defectCertificationAttach: _defectCertificationAttach,
      defectivePhoto1: formattedDefectivePhoto1,
      repairDuration: _getTextFieldValue(_repairDuration),
      defectivePhoto1OrgName: (_defectivePhoto1OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.defectivePhoto1OrgName) ??
          '',
      defectivePhoto2: formattedDefectivePhoto2,
      defectivePhoto2OrgName: (_defectivePhoto2OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.defectivePhoto2OrgName) ??
          '',
      defectivePhoto3: formattedDefectivePhoto3,
      defectivePhoto3OrgName: (_defectivePhoto3OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.defectivePhoto3OrgName) ??
          '',
      defectivePhoto4: formattedDefectivePhoto4,
      defectivePhoto4OrgName: (_defectivePhoto4OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.defectivePhoto4OrgName) ??
          '',
      defectivePhoto5: formattedDefectivePhoto5,
      defectivePhoto5OrgName: (_defectivePhoto5OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.defectivePhoto5OrgName) ??
          '',
      defectivePhoto6: formattedDefectivePhoto6,
      defectivePhoto6OrgName: (_defectivePhoto6OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.defectivePhoto6OrgName) ??
          '',
      materials: materials,
      existingFaults:
          widget.exInspectionRequest.equipmentTagRequest?.existingFaults,
      correctiveDefectCategory: (int.tryParse(
                widget.exInspectionRequest.equipmentTagRequest?.repairsDone
                    ?.toString() ?? '',
              ) ?? -1) ==
              0
          ? selectedDefectCategory
          : widget.exInspectionRequest.equipmentTagRequest
              ?.correctiveDefectCategory,
      yesNoSelection:
          widget.exInspectionRequest.equipmentTagRequest!.yesNoSelection,
      //widget
      //  .exInspectionRequest.equipmentTagRequest?.correctiveDefectCategory,
      currentStatus: cuStatus,
      correctiveOverallCondition: widget
          .exInspectionRequest.equipmentTagRequest?.correctiveOverallCondition,
      correctiveisolation:
          widget.exInspectionRequest.equipmentTagRequest?.correctiveisolation,
      correctiveOtherRequirements: widget
          .exInspectionRequest.equipmentTagRequest?.correctiveOtherRequirements,
      repairsDone: widget.exInspectionRequest.equipmentTagRequest?.repairsDone,
      remarksIfAny:
          widget.exInspectionRequest.equipmentTagRequest?.remarksIfAny,
      correctiveCertificationOrgName: widget.exInspectionRequest
          .equipmentTagRequest?.correctiveCertificationOrgName,
      correctiveCertificationNo: widget
          .exInspectionRequest.equipmentTagRequest?.correctiveCertificationNo,
      correctivePhoto1:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto1,
      correctivePhoto1OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.correctivePhoto1OrgName,
      correctivePhoto2:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto2,
      correctivePhoto2OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.correctivePhoto2OrgName,
      correctivePhoto3:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto3,
      correctivePhoto3OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.correctivePhoto3OrgName,
      correctivePhoto4:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto4,
      correctivePhoto4OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.correctivePhoto4OrgName,
      correctivePhoto5:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto5,
      correctivePhoto5OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.correctivePhoto5OrgName,
      correctivePhoto6:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto6,
      correctivePhoto6OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.correctivePhoto6OrgName,
      supplementaryMaterialReq: widget
          .exInspectionRequest.equipmentTagRequest?.supplementaryMaterialReq,
      rbiStrategy: widget.exInspectionRequest.equipmentTagRequest?.rbiStrategy,
      inspectionChecklistType: widget
          .exInspectionRequest.equipmentTagRequest!.inspectionChecklistType,
      inspectionGrade:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionGrade,
      inspectionType:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionType,
      equipmentEquipmentType: widget
          .exInspectionRequest.equipmentTagRequest?.equipmentEquipmentType,
      areaClassDrawAttach:
          widget.exInspectionRequest.functionalAreaRequest!.areaClassDrawAttach,
      areaClassDrawNo:
          widget.exInspectionRequest.functionalAreaRequest!.areaClassDrawNo,
      eqpmtLytDrawAttach:
          widget.exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawAttach,
      subArea: widget.exInspectionRequest.equipmentTagRequest?.subArea,
      eqpmtLytDrawNo:
          widget.exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawNo,
      repairTimeEstimate:
          widget.exInspectionRequest.equipmentTagRequest?.repairTimeEstimate,
      remarks: widget.exInspectionRequest.equipmentTagRequest?.remarks,
      eqpmtLytDrawAttachOrgName: widget
          .exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawAttachOrgName,
      areaClassDrawAttachOrgName: widget.exInspectionRequest
          .functionalAreaRequest!.areaClassDrawAttachOrgName,
      correctiveCertificationAttach: widget.exInspectionRequest
          .equipmentTagRequest!.correctiveCertificationAttach,
      primaryId: widget.exInspectionRequest.equipmentTagRequest?.primaryId,
      inspectionPriority: int.tryParse(selectedDefectCategory),
    );
    if (!mounted) return;
    context.read<ExInspectionsBloc>().add(
          SubmitEquipmentTag(
            widget.exInspectionRequest,
            clearFlag: clearFlag,
            screenType: 'Defect Analysis',
            userUpdateSign: true,
          ),
        );
    setState(() {
      isEditable = false;
      showEditIcon = true;
    });
  }
}
