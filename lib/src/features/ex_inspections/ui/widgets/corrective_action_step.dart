// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/dotted_style.dart';
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
  if (rawDate == null || rawDate.isEmpty) return '';

  try {
    final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    final dateTime = inputFormat.parse(rawDate);
    final outputFormat = DateFormat('dd-MM-yyyy hh:mm a');
    return outputFormat.format(dateTime);
  } catch (e) {
    return '';
  }
}

String formatOldDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty || rawDate.toLowerCase() == 'null') {
    return '';
  }
  try {
    DateTime dateTime;
    if (rawDate.endsWith('Z')) {
      // Format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      dateTime = inputFormat.parseUtc(rawDate).toLocal();
    } else {
      // Format: "yyyy-MM-dd'T'HH:mm:ss"
      final inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      dateTime = inputFormat.parse(rawDate, true).toLocal();
    }

    final outputFormat = DateFormat('dd-MM-yyyy hh:mm a');
    return outputFormat.format(dateTime);
  } catch (e) {
    return '';
  }
}

class CorrectiveActionsStep extends StatefulWidget {
  final ExInspectionRequest exInspectionRequest;
  final bool isUpdate;
  final ValueNotifier<bool> isEditModeNotifier;
  const CorrectiveActionsStep({
    super.key,
    required this.exInspectionRequest,
    required this.isUpdate,
    required this.isEditModeNotifier,
  });

  @override
  CorrectiveActionsStepState createState() => CorrectiveActionsStepState();
}

class CorrectiveActionsStepState extends State<CorrectiveActionsStep> {
  final TextEditingController _existingFaults = TextEditingController();
  final TextEditingController _repairDuration = TextEditingController();
  final TextEditingController _remarksIfAny = TextEditingController();
  final TextEditingController _certification = TextEditingController();
  final TextEditingController _signature = TextEditingController();
  final TextEditingController _completedRepairs = TextEditingController();
  final TextEditingController _repairedBy = TextEditingController();
  final TextEditingController _repairedDate = TextEditingController();
  final TextEditingController _currentStatus = TextEditingController();
  final TextEditingController _currentCondition = TextEditingController();
  final TextEditingController _correctiveCertificationController =
      TextEditingController();

  String _selectedRepairPriority = '';
  String? _selectedIsolationRequirement;
  String? _selectedOtherRequirement;
  String? _correctiveCertificationNo;
  String? _correctiveCertificationOrgName;
  String? _correctiveCertificationAttach;
  final List<File> _images = [];
  List<String> unit = [
    'Nos (Number)',
    'Packs',
    'Meters (m)',
    'Grams (g)',
    'Square Meter (m)',
    'Liter (L)',
  ];
  String? _signatureUrl;
  String? _correctivePhoto1 = '';
  String? _correctivePhoto1OrgName = '';
  String? _correctivePhoto2 = '';
  String? _correctivePhoto2OrgName = '';
  String? _correctivePhoto3 = '';
  String? _correctivePhoto3OrgName = '';
  String? _correctivePhoto4 = '';
  String? _correctivePhoto4OrgName = '';
  String? _correctivePhoto5 = '';
  String? _correctivePhoto5OrgName = '';
  String? _correctivePhoto6 = '';
  String? _correctivePhoto6OrgName = '';
  final List<Map<String, String?>> _materials = [];
  final List<String> _uploadedImageUrls = [];
  final List<String?> _imageNames = [];
  static String? get apiUrl => dotenv.env['API_URL'];
  final ImagePicker _picker = ImagePicker();
  final List<TextEditingController> _partNumberControllers = [];
  final List<TextEditingController> _materialDescriptionControllers = [];
  final List<TextEditingController> _manufacturerControllers = [];
  final List<TextEditingController> _certificationControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<String?> _selectedUnitValues = [];
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateRepairCounts();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CorrectiveActionsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exInspectionRequest != oldWidget.exInspectionRequest &&
        widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeInspectionValues();
    }
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

  int _getCompletedRepairsCount() {
    int completedCount = 0;

    for (var checkList
        in widget.exInspectionRequest.equipmentTagRequest?.checkList ?? []) {
      for (var defectCode in checkList.defectCodes) {
        for (var finding in defectCode.findingsAndActions) {
          if (finding.isDone) {
            completedCount++;
          }
        }
      }
    }

    return completedCount;
  }

  void _updateRepairCounts([List<dynamic>? defectDataList]) {
    final checkLists = widget.exInspectionRequest.equipmentTagRequest?.checkList ?? [];
    final List<dynamic> defectList = defectDataList ?? _extractDefectData(checkLists);

    int completed = 0;
    int total = defectList.length;

    for (var defect in defectList) {
      if (defect['isDone'] == true || defect['isDone'] == 'true') {
        completed++;
      }
    }

    if (total == 0) {
      final reqFaultsStr = widget.exInspectionRequest.equipmentTagRequest?.faultyItems ?? '0';
      total = int.tryParse(reqFaultsStr.toString()) ?? 0;
    }

    final remaining = (total - completed) < 0 ? 0 : (total - completed);

    _existingFaults.text = remaining.toString();
    _completedRepairs.text = completed.toString();
  }

  void _initializeInspectionValues() {
    final request = widget.exInspectionRequest.equipmentTagRequest;
    if (request == null) {
      return;
    }
    setState(() {
      if (request.correctivePhoto1 != null &&
          request.correctivePhoto1!.isNotEmpty) {
        _correctivePhoto1 = request.correctivePhoto1;
        _correctivePhoto1OrgName = request.correctivePhoto1OrgName;
        _uploadedImageUrls.add(_correctivePhoto1!);
        _imageNames.add(request.correctivePhoto1OrgName);
      }
      if (request.correctivePhoto2 != null &&
          request.correctivePhoto2!.isNotEmpty) {
        _correctivePhoto2 = request.correctivePhoto2;
        _correctivePhoto2OrgName = request.correctivePhoto2OrgName;
        _uploadedImageUrls.add(_correctivePhoto2!);
        _imageNames.add(request.correctivePhoto2OrgName);
      }
      if (request.correctivePhoto3 != null &&
          request.correctivePhoto3!.isNotEmpty) {
        _correctivePhoto3 = request.correctivePhoto3;
        _correctivePhoto3OrgName = request.correctivePhoto3OrgName;
        _uploadedImageUrls.add(_correctivePhoto3!);
        _imageNames.add(request.correctivePhoto3OrgName);
      }
      if (request.correctivePhoto4 != null &&
          request.correctivePhoto4!.isNotEmpty) {
        _correctivePhoto4 = request.correctivePhoto4;
        _correctivePhoto4OrgName = request.correctivePhoto4OrgName;
        _uploadedImageUrls.add(_correctivePhoto4!);
        _imageNames.add(request.correctivePhoto4OrgName);
      }
      if (request.correctivePhoto5 != null &&
          request.correctivePhoto5!.isNotEmpty) {
        _correctivePhoto5 = request.correctivePhoto5;
        _correctivePhoto5OrgName = request.correctivePhoto5OrgName;
        _uploadedImageUrls.add(_correctivePhoto5!);
        _imageNames.add(request.correctivePhoto5OrgName);
      }
      if (request.correctivePhoto6 != null &&
          request.correctivePhoto6!.isNotEmpty) {
        _correctivePhoto6 = request.correctivePhoto6;
        _correctivePhoto6OrgName = request.correctivePhoto6OrgName;
        _uploadedImageUrls.add(_correctivePhoto6!);
        _imageNames.add(request.correctivePhoto6OrgName);
      }

      final int existingFaults =
          int.tryParse(request.existingFaults?.toString() ?? '0') ?? 0;

      final int repairsDone =
          int.tryParse(request.repairsDone?.toString() ?? '0') ?? 0;

      if (existingFaults != 0) {
        if (repairsDone == 0) {
          _selectedRepairPriority =
              request.correctiveDefectCategory.toString().trim().isEmpty
                  ? request.defectDefectCategory.toString()
                  : request.correctiveDefectCategory.toString();
        } else {
          _selectedRepairPriority =
              request.correctiveDefectCategory.toString().trim();
        }
      } else {
        _selectedRepairPriority =
            request.correctiveDefectCategory.toString().trim().isEmpty
                ? request.defectDefectCategory.toString()
                : request.correctiveDefectCategory.toString();
      }
      _existingFaults.text = request.existingFaults ?? '';
      _currentStatus.text = request.currentStatus ?? '';
      _currentCondition.text = request.correctiveOverallCondition ?? '';

      _repairedBy.text = request.repairedBy ?? '';
      _repairedDate.text = formatOldDate(request.repairedDate);
      _selectedIsolationRequirement = request.correctiveisolation;
      _selectedOtherRequirement = request.correctiveOtherRequirements;
      _completedRepairs.text = request.repairsDone ?? '';
      _updateRepairCounts();
      _correctiveCertificationAttach = request.correctiveCertificationAttach;
      _correctiveCertificationOrgName = request.correctiveCertificationOrgName;
      _correctiveCertificationNo = request.correctiveCertificationNo;
      _repairDuration.text = request.repairTimeEstimate ?? '';
      if (request.supplementaryMaterialReq != null &&
          request.materials!.isNotEmpty) {
        _correctiveCertificationController.text =
            request.materials!.first.certificationOrgName ?? '';
      } else {
        _correctiveCertificationController.text = '';
      }
      final checklistData = request.checkList ?? [];
      final defectData = _extractDefectData(checklistData);
      _filterDropdownItems(defectData, request.correctiveDefectCategory);
      if (_selectedRepairPriority.isNotEmpty) {
        _setDropdownValues(_selectedRepairPriority);
      }
      _remarksIfAny.text = request.remarksIfAny ?? '';
      _materials.addAll(
        request.supplementaryMaterialReq?.map(
              (supplementaryMaterialReq) => {
                'partNumber': supplementaryMaterialReq.partNumber ?? '',
                'description': supplementaryMaterialReq.description ?? '',
                'manufacturer': supplementaryMaterialReq.manufacturer ?? '',
                'certificationOrgName':
                    supplementaryMaterialReq.certificationOrgName ?? '',
                'certificationAttach':
                    supplementaryMaterialReq.certificationAttach ?? '',
                'unit': supplementaryMaterialReq.unit,
                'quantity': supplementaryMaterialReq.quantity ?? '',
              },
            ) ??
            [],
      );

      for (var supplementaryMaterialReq in _materials) {
        _partNumberControllers.add(
          TextEditingController(text: supplementaryMaterialReq['partNumber']),
        );
        _materialDescriptionControllers.add(
          TextEditingController(text: supplementaryMaterialReq['description']),
        );
        _manufacturerControllers.add(
          TextEditingController(text: supplementaryMaterialReq['manufacturer']),
        );
        _certificationControllers.add(
          TextEditingController(
            text: supplementaryMaterialReq['certificationOrgName'],
          ),
        );
        _quantityControllers.add(
          TextEditingController(text: supplementaryMaterialReq['quantity']),
        );
        _selectedUnitValues.add(supplementaryMaterialReq['unit']);
      }
    });
  }

  List<Map<String, dynamic>> _extractDefectData(List<CheckList> checklistData) {
    final List<Map<String, dynamic>> defectData = [];

    for (var checkList in checklistData) {
      final List<DefectCode> defectCodes = checkList.defectCodes;
      for (var defectCodeData in defectCodes) {
        int priority = 1;
        if (defectCodeData.defectPriority is Map && defectCodeData.defectPriority.containsKey('priority')) {
          priority = (defectCodeData.defectPriority['priority'] as int? ?? 1);
        }
        final List<FindingAndAction> findingsAndActions =
            defectCodeData.findingsAndActions;
        for (var findingAction in findingsAndActions) {
          bool done = findingAction.isDone == true;
          String repBy = done ? (findingAction.repairedBy?.toString() ?? '') : '';
          String repAt = done ? (findingAction.repairedAt?.toString() ?? '') : '';

          defectData.add({
            '_id': findingAction.id,
            'defectCode': findingAction.defectCode,
            'remedialAction': findingAction.remedialAction,
            'isDone': done,
            'repairedBy': repBy,
            'repairedAt': repAt,
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

  void _updateRepairPriority() {
    List<int> priorities = [];
    for (var checkList
        in widget.exInspectionRequest.equipmentTagRequest?.checkList ?? []) {
      for (var defectCode in checkList.defectCodes) {
        int priority = defectCode.defectPriority['priority'] as int;
        for (var finding in defectCode.findingsAndActions) {
          if (!finding.isDone) {
            priorities.add(priority);
            break;
          }
        }
      }
    }

    if (priorities.isNotEmpty) {
      priorities.sort();
      setState(() {
        _selectedRepairPriority = priorities.first.toString();
        _setDropdownValues(_selectedRepairPriority);
      });
    } else {
      setState(() {
        _selectedRepairPriority = "Not Applicable";
        _setDropdownValues(_selectedRepairPriority);
      });
    }
  }

  void _setDropdownValues(String? selectedPriority) {
    setState(() {
      if (selectedPriority == null ||
          selectedPriority.isEmpty ||
          selectedPriority == 'Not Applicable') {
        _currentStatus.text = 'Green';
        _currentCondition.text = 'Good to Use';
        _repairDuration.text = 'Not Applicable';
      } else {
        int priority = int.tryParse(selectedPriority) ?? 0;
        if (priority <= 2) {
          _currentStatus.text = 'Red';
          _currentCondition.text = 'Major Repair Required';
        } else if (priority <= 5) {
          _currentStatus.text = 'Yellow';
          _currentCondition.text = 'Minor Repair Required';
        } else {
          _repairDuration.text = 'Not Applicable';
          _currentStatus.text = 'Green';
          _currentCondition.text = 'Good to Use';
        }
      }
    });
  }

  void _filterDropdownItems(
    List<Map<String, dynamic>> defectData,
    String? correctiveDefectCategory,
  ) {
    List<String> priorities = defectData
        .where((defect) => !defect['isDone'])
        .map((defect) => defect['priority'].toString())
        .toSet()
        .toList();
    priorities.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    setState(() {
      if (_selectedRepairPriority.isNotEmpty &&
          !priorities.contains(_selectedRepairPriority)) {
        if (correctiveDefectCategory != null ||
            correctiveDefectCategory!.isNotEmpty) {
          if (priorities.isNotEmpty) {
            if (priorities[0].contains(correctiveDefectCategory.toString())) {
              _selectedRepairPriority = priorities.isNotEmpty
                  ? _selectedRepairPriority
                  : "Not Applicable";
            } else {
              _selectedRepairPriority = correctiveDefectCategory.toString();
            }
          } else {
            _selectedRepairPriority =
                priorities.isNotEmpty ? priorities[0] : "Not Applicable";
          }
        } else {
          _selectedRepairPriority =
              priorities.isNotEmpty ? priorities[0] : "Not Applicable";
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
        if (user.signature != null && user.signature.isNotEmpty) {
          localSignature = user.signature;
        }
      }
    }
    if (localSignature == null || localSignature.isEmpty) {
      final user = await dbHelper.getLoggedInUser();
      if (user != null) {
        userName ??= user.userName;
        if (user.signature != null && user.signature.isNotEmpty) {
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

    final existingSignOff = widget.exInspectionRequest.equipmentTagRequest?.repairSignOff;
    final signToUse = (existingSignOff != null && existingSignOff.isNotEmpty && existingSignOff != "null")
        ? existingSignOff
        : localSignature;

    if (signToUse != null && signToUse.isNotEmpty && mounted) {
      setState(() {
        _signatureUrl = signToUse;
        if (_signature.text.isEmpty) {
          _signature.text = userName ?? 'Repaired';
        }
      });
    }
  }

  void clearFields() {
    setState(() {
      _repairedBy.clear();
      _repairedDate.clear();
      _selectedIsolationRequirement = '';
      _selectedOtherRequirement = '';
      _selectedOtherRequirement = '';
      _completedRepairs.clear();
      _remarksIfAny.clear();
      _partNumberControllers.clear();
      _manufacturerControllers.clear();
      _materials.clear();
      _correctiveCertificationController.clear();
      _correctiveCertificationAttach = '';
      _correctiveCertificationOrgName = '';
      _correctiveCertificationNo = '';
      _correctivePhoto1 = '';
      _correctivePhoto1OrgName = '';
      _correctivePhoto2 = '';
      _correctivePhoto2OrgName = '';
      _correctivePhoto3 = '';
      _correctivePhoto3OrgName = '';
      _repairDuration.clear();
      _certification.clear();
      _certification.clear();
      _uploadedImageUrls.clear();
      _images.clear();
      _certificationControllers.clear();
      _materialDescriptionControllers.clear();
      _quantityControllers.clear();
      _quantityControllers.clear();
      _selectedUnitValues.clear();
      widget.exInspectionRequest.equipmentTagRequest?.rbiStrategy = null;
      widget.exInspectionRequest.equipmentTagRequest?.supplementaryMaterialReq =
          [];
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveOtherRequirements = '';
      widget.exInspectionRequest.equipmentTagRequest?.correctiveisolation = '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveCertificationAttach = '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveCertificationOrgName = '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveCertificationNo = '';
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
      widget.exInspectionRequest.equipmentTagRequest?.repairedDate = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairedBy = '';
    });
    onSubmitCorrectiveActions(clearFlag: true);
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
      _uploadImage(image, 'CorrectiveUpload');
    }
    _images.clear();
  }

  Future<void> _captureImageFromCamera() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (context) => const CustomCameraScreen()),
    );
    // final result = await _picker.pickImage(source: ImageSource.camera);
    if (result != null) {
      setState(() {
        _images.add(File(result.path));
      });
      for (var image in _images) {
        final ext = image.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png'].contains(ext)) {
          image = await _compressImage(image);
        }
        _uploadImage(image, 'CorrectiveUpload');
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
    _uploadFile(File(customFilePath), fileOf);
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

    // Temporary compressed path
    final String tempCompressedPath = '$parentDir/compressed_$originalFileName';

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

      // final image = await Navigator.push<File>(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const CustomCameraScreen(),
      //   ),
      // );
      // if (image != null) {
      //   file = File(image.path);
      // }
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
    String prefix = fileOf == 'correctiveCertificationAttach' ? 'CC' : '';
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

  void _uploadFile(File file, String fileOf) {
    context.read<ExInspectionsBloc>().add(UploadFile(file, fileOf));
  }

  Future<void> updateRepairsUser({bool? clearCollection}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final loggedInUser = await _dbHelper.getLoggedInUserByUserId(userId!);
    DateTime now = DateTime.now();
    // String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(now);

    // String formattedDate = DateFormat("dd MMM yy HH:mm 'Hrs'").format(now);
    String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss",
    ).format(now); //DateFormat("dd-MM-yyyy hh:mm a")
    if (!clearCollection! && mounted) {
      setState(() {
        _repairedBy.text = loggedInUser!.userName;
        _repairedDate.text = formatDate(formattedDate);
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
            if (!state.userUpdateSign) {
              updateRepairsUser(clearCollection: state.clearFlag);
            }
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
              final List<dynamic> defectData = _extractDefectData(
                checklistData,
              );
              _updateRepairCounts(defectData);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTableSection(defectData),
                    _buildImageUploadSection(),
                    _buildForm(state.allDropDowns ?? {}),
                    // if (_currentStatus.text != 'Green')
                    //   _buildSuplementaryMaterialRequirements(),
                    _buildRepairSignOff(),
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
    if (fileType == 'correctiveCertificationAttach') {
      setState(() {
        _correctiveCertificationNo = fileMetadata['originalName'];
        _correctiveCertificationAttach = fileMetadata['file'];
        _correctiveCertificationOrgName =
            _correctiveCertificationNo!.split('.').first;
        _correctiveCertificationController.text =
            _correctiveCertificationOrgName!;
      });
    } else if (fileType.startsWith('CorrectiveUpload')) {
      final newImage = {
        'name': fileMetadata['originalName'],
        'file': fileMetadata['file'],
      };

      for (int i = 0; i < 6; i++) {
        if ((i == 0 && _correctivePhoto1!.isEmpty) ||
            (i == 1 && _correctivePhoto2!.isEmpty) ||
            (i == 2 && _correctivePhoto3!.isEmpty) ||
            (i == 3 && _correctivePhoto4!.isEmpty) ||
            (i == 4 && _correctivePhoto5!.isEmpty) ||
            (i == 5 && _correctivePhoto6!.isEmpty)) {
          setState(() {
            String customImageName = _generateCustomImageName(
              'CorrectiveUpload',
              i + 1,
            );
            if (i == 0) {
              _correctivePhoto1OrgName = customImageName;
              _correctivePhoto1 = newImage['file'];
            } else if (i == 1) {
              _correctivePhoto2OrgName = customImageName;
              _correctivePhoto2 = newImage['file'];
            } else if (i == 2) {
              _correctivePhoto3OrgName = customImageName;
              _correctivePhoto3 = newImage['file'];
            } else if (i == 3) {
              _correctivePhoto4OrgName = customImageName;
              _correctivePhoto4 = newImage['file'];
            } else if (i == 4) {
              _correctivePhoto5OrgName = customImageName;
              _correctivePhoto5 = newImage['file'];
            } else if (i == 5) {
              _correctivePhoto6OrgName = customImageName;
              _correctivePhoto6 = newImage['file'];
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
              0: FlexColumnWidth(0.7),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(0.8),
              3: FlexColumnWidth(0.9),
              4: FlexColumnWidth(0.9),
            },
            children: [
              _buildTableRow([
                'Defect Code',
                'Remedial Actions',
                'Repairs Done',
                'Repaired By',
                'Repaired Date',
              ], isHeader: true),
              ...defectData.map((defect) {
                return _buildTableRow(
                  [
                    defect['defectCode'],
                    defect['remedialAction'],
                    defect['isDone'] ? '✅' : '❌',
                    defect['repairedBy'] ?? '',
                    // defect['repairedAt'] != null &&
                    //         defect['repairedAt'].isNotEmpty
                    //     ? DateFormat("dd MMM yy HH:mm 'Hrs'")
                    //         .format(DateTime.parse(defect['repairedAt']!))
                    //     : '',
                    formatDate(defect['repairedAt']),
                  ],
                  defect: defect,
                  isLastRow: defectData.last == defect,
                );
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
    Map<String, dynamic>? defect,
    bool isLastRow = false,
  }) {
    final cellColor = isHeader ? const Color(0xFF002B5C) : Colors.white;
    final textColor = isHeader ? Colors.white : const Color(0xFF353535);
    // final height = isHeader ? 50.0 : 50.0;

    return TableRow(
      children: cells.asMap().entries.map((entry) {
        final index = entry.key;
        final cell = entry.value;
        Alignment alignment = Alignment.centerLeft;
        TextAlign textAlign = TextAlign.left;

        if (index == 0 || index == 2) {
          alignment = Alignment.center;
          textAlign = TextAlign.center;
        } else if (index == 4) {
          alignment = Alignment.centerRight;
          textAlign = TextAlign.right;
        }

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
            borderRadius = isHeader
                ? const BorderRadius.only(topRight: Radius.circular(8))
                : const BorderRadius.only(bottomRight: Radius.circular(8));
          }
        }

        Widget cellContent;
        if (!isHeader && index == 2 && defect != null) {
          cellContent = !widget.isEditModeNotifier.value
              ? const SizedBox()
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      defect['isDone'] = !defect['isDone'];
                      if (defect['isDone']) {
                        defect['repairedBy'] = userName ?? '';
                        defect['repairedAt'] =
                            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(
                          DateTime.now(),
                        ); //DateFormat("dd-MM-yyyy hh:mm a") //DateFormat("dd MMM yy HH:mm 'Hrs'")
                      } else {
                        defect['repairedBy'] = '';
                        defect['repairedAt'] = '';
                      }
                      _updateCheckList(defect['_id'], defect['isDone']);
                    });
                  },
                  child: SvgPicture.asset(
                    defect['isDone']
                        ? 'lib/src/features/ex_inspections/assets/check_icon.svg'
                        : 'lib/src/features/ex_inspections/assets/cancel_icon.svg',
                    width: 20,
                    height: 20,
                  ),
                );
        } else if (index == 0 && !isHeader) {
          cellContent = Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 24.0,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFEDF3F8),
              borderRadius: BorderRadius.all(Radius.circular(6)),
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
          );
        } else {
          cellContent = Text(
            cell,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: textAlign,
          );
        }

        return Container(
          height: isHeader ? 48 : 58,
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: isHeader
                ? index == 4
                    ? const EdgeInsets.only(
                        top: 10.0,
                        bottom: 10,
                        left: 8,
                        right: 16,
                      )
                    : index == 3
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
                        left: 20,
                        right: 8,
                      )
                    : index == 4
                        ? const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10,
                            left: 8,
                            right: 16,
                          )
                        : index == 3
                            ? const EdgeInsets.only(
                                top: 10.0,
                                bottom: 10,
                                left: 8,
                                right: 24,
                              )
                            : const EdgeInsets.all(8.0),
            child: Align(alignment: alignment, child: cellContent),
          ),
        );
      }).toList(),
    );
  }

  void _updateCheckList(String findingId, bool isDone) {
    setState(() {
      for (var defectCategory
          in widget.exInspectionRequest.equipmentTagRequest?.checkList ?? []) {
        for (var defectCode in defectCategory.defectCodes) {
          for (var finding in defectCode.findingsAndActions) {
            if (finding.id == findingId) {
              finding.isDone = isDone;
              if (isDone) {
                finding.repairedBy = userName ?? '';
                finding.repairedAt = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(
                  DateTime.now(),
                ); // DateFormat("dd-MM-yyyy hh:mm a") DateFormat("dd MMM yy HH:mm 'Hrs'").format(DateTime.now());
              } else {
                finding.repairedBy = '';
                finding.repairedAt = '';
              }
            }
          }
        }
      }
      _updateRepairCounts();
      _updateRepairPriority();
    });
    onSubmitCorrectiveActions(clearFlag: false);
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
                                        right: 8.0,
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
                                                color: Colors.white.withOpacity(
                                                  0.6,
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
                                      ],
                                    ),
                                    const SizedBox(width: 24),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  if (remainingImages > 0)
                    !widget.isEditModeNotifier.value
                        ? const SizedBox()
                        : ElevatedButton(
                            onPressed: !widget.isEditModeNotifier.value
                                ? null
                                : _showImageSourceDialog,
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

  void _showImageDialog(String imagePath, String imageName) {
    final isLocal =
        imagePath.startsWith('/data/user/') || imagePath.startsWith('file://');

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
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          imageName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: isLocal
                          ? Image.file(
                              File(
                                imagePath.startsWith('file://')
                                    ? imagePath.substring(7)
                                    : imagePath,
                              ),
                              fit: BoxFit.fill,
                            )
                          : Image.network(imagePath, fit: BoxFit.fill),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 20,
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
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFFAB2F26),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
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
      if (_correctivePhoto1 == strippedImageUrl) {
        _correctivePhoto1 = '';
        _correctivePhoto1OrgName = '';
      } else if (_correctivePhoto2 == strippedImageUrl) {
        _correctivePhoto2 = '';
        _correctivePhoto2OrgName = '';
      } else if (_correctivePhoto3 == strippedImageUrl) {
        _correctivePhoto3 = '';
        _correctivePhoto3OrgName = '';
      } else if (_correctivePhoto4 == strippedImageUrl) {
        _correctivePhoto4 = '';
        _correctivePhoto4OrgName = '';
      } else if (_correctivePhoto5 == strippedImageUrl) {
        _correctivePhoto5 = '';
        _correctivePhoto5OrgName = '';
      } else if (_correctivePhoto6 == strippedImageUrl) {
        _correctivePhoto6 = '';
        _correctivePhoto6OrgName = '';
      }
      _updateDefectivePhotoNames();
    });
  }

  void _updateDefectivePhotoNames() {
    _correctivePhoto1OrgName = _correctivePhoto1?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.correctivePhoto1OrgName;
    _correctivePhoto2OrgName = _correctivePhoto2?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.correctivePhoto2OrgName;
    _correctivePhoto3OrgName = _correctivePhoto3?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.correctivePhoto3OrgName;
    _correctivePhoto4OrgName = _correctivePhoto4?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.correctivePhoto4OrgName;
    _correctivePhoto5OrgName = _correctivePhoto5?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.correctivePhoto5OrgName;
    _correctivePhoto6OrgName = _correctivePhoto6?.isEmpty ?? true
        ? ''
        : widget
            .exInspectionRequest.equipmentTagRequest?.correctivePhoto6OrgName;
  }

  Widget _buildForm(Map<String, dynamic> getAllDropDowns) {
    final exRegisterDropDown = getAllDropDowns['result']['exResiterDropDown'][0]
        as Map<String, dynamic>;
    final isolationRequirement =
        (exRegisterDropDown['isolationRequirement'] as List<dynamic>)
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

    final currentConditionList =
        (exRegisterDropDown['currentCondition'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ?? ['Major Repair Required', 'Minor Repair Required', 'Good to Use'];

    bool isGreenStatus = _currentStatus.text == 'Green';

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Repair Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24.0,
            runSpacing: 16.0,
            children: [
              _buildLabeledTextField(
                label: 'Existing Faults',
                controller: _existingFaults,
                isReadOnly: true,
                isNotApplicable: _existingFaults.text == '0' ||
                    _selectedRepairPriority == 'Not Applicable',
              ),
              _buildDefectCategoryDropdownField(
                dropDownEnabled: dropDownEnabled,
                label: 'Defect Category (Repair Priority)',
                value: _selectedRepairPriority.isEmpty
                    ? 'Not Applicable'
                    : _selectedRepairPriority,
                items: defectCategory.contains('Not Applicable')
                    ? defectCategory
                    : [...defectCategory, 'Not Applicable'],
                onChanged: (value) {
                  setState(() {
                    dropDownEnabled = false;
                    _selectedRepairPriority = value ?? 'Not Applicable';
                    _setDropdownValues(_selectedRepairPriority);
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
                label: 'Current Status',
                value: _selectedRepairPriority == 'Not Applicable'
                    ? 'Not Applicable'
                    : (inspectionStatusList.contains(_currentStatus.text)
                        ? _currentStatus.text
                        : null),
                items: _selectedRepairPriority == 'Not Applicable'
                    ? ['Not Applicable']
                    : inspectionStatusList,
                onChanged: (value) {
                  setState(() {
                    _currentStatus.text = value ?? '';
                  });
                },
                isNotApplicable: _selectedRepairPriority == 'Not Applicable',
              ),
              _buildLabeledDropdownField(
                label: 'Current Condition',
                value: _selectedRepairPriority == 'Not Applicable'
                    ? 'Not Applicable'
                    : (currentConditionList.contains(_currentCondition.text)
                        ? _currentCondition.text
                        : null),
                items: _selectedRepairPriority == 'Not Applicable'
                    ? ['Not Applicable']
                    : currentConditionList,
                onChanged: (value) {
                  setState(() {
                    _currentCondition.text = value ?? '';
                  });
                },
                isNotApplicable: _selectedRepairPriority == 'Not Applicable',
              ),
              _buildLabeledDropdownField(
                label: 'Isolation For Requirements',
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
                isNotApplicable: _selectedRepairPriority == 'Not Applicable',
              ),
              _buildLabeledDropdownField(
                label: 'Additional Requirements',
                value: isGreenStatus
                    ? 'Not Applicable'
                    : _selectedOtherRequirement,
                items: isGreenStatus
                    ? ['Not Applicable']
                    : otherRequirement.toSet().toList(),
                onChanged: isGreenStatus
                    ? (_) {}
                    : (value) {
                        setState(() {
                          _selectedOtherRequirement = value;
                        });
                      },
                isNotApplicable: _selectedRepairPriority == 'Not Applicable',
              ),
              _buildLabeledTextField(
                label: 'Completed Repairs',
                controller: _completedRepairs,
                isReadOnly: true,
                isNotApplicable: _selectedRepairPriority == 'Not Applicable',
              ),
              _buildLabeledTextField(
                label: 'Repair Time Estimate (Minutes)',
                controller: _repairDuration,
                isNotApplicable: _selectedRepairPriority == 'Not Applicable',
              ),
              _buildLabeledTextField(
                label: 'Remarks if any',
                controller: _remarksIfAny,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuplementaryMaterialRequirements() {
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
            'Supplementary Material Requirements',
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
                        fileOf: 'correctiveCertificationAttach',
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
                                  for (int i = 0; i < _materials.length; i++) {
                                    if (_partNumberControllers[i]
                                            .text
                                            .isNotEmpty ||
                                        _materialDescriptionControllers[i]
                                            .text
                                            .isNotEmpty ||
                                        _manufacturerControllers[i]
                                            .text
                                            .isNotEmpty ||
                                        _certificationControllers[i]
                                            .text
                                            .isNotEmpty ||
                                        _quantityControllers[i]
                                            .text
                                            .isNotEmpty ||
                                        _selectedUnitValues[i] != null) {
                                      hasValue = true;
                                      // break;
                                    } else {
                                      hasValue = false;
                                      // break;
                                    }
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

  Widget _buildRepairSignOff() {
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
          const Text(
            'Repair Sign Off',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                label: 'Repaired By',
                controller: _repairedBy,
              ),
              _buildLabeledTextField(
                label: 'Repaired Date',
                controller: _repairedDate,
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
          color: isDisabled ? const Color(0xFFD0D3D8) : const Color(0xFF002B5C),
          width: 1.0,
        ),
      ),
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.275,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelTextStyle),
          const SizedBox(height: 8.0),
          if (label == 'Completed Repairs')
            ValueListenableBuilder<bool>(
              valueListenable: widget.isEditModeNotifier,
              builder: (context, isEditMode, _) {
                return TextFormField(
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF212121),
                    height: 24 / 17,
                  ),
                  readOnly: !isEditMode || true,
                  controller: controller,
                  decoration: inputDecoration.copyWith(
                    prefixIconConstraints: const BoxConstraints(minWidth: 40),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _getCompletedRepairsCount().toString(),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 17.0,
                            color: isDisabled
                                ? const Color(0xFFB5B5B5)
                                : const Color(0xFF212121),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else if (imageUrl != null && imageUrl.isNotEmpty)
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
                          keyboardType:
                              label == "Repair Time Estimate (Minutes)" ||
                                      label == "Quantity"
                                  ? TextInputType.number
                                  : TextInputType.text,
                          readOnly: !isEditMode || isReadOnly,
                          controller: controller,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 17.0,
                            color: isDisabled
                                ? const Color(0xFFB5B5B5)
                                : const Color(0xFF212121),
                          ),
                          decoration: inputDecoration,
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
      fontWeight: FontWeight.w500,
      color: const Color(0xFFB5B5B5),
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
    );
    bool isFaultZero = _existingFaults.text == '0' &&
        widget.exInspectionRequest.equipmentTagRequest?.faultyItems != 0;
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
                      : ValueListenableBuilder<bool>(
                          valueListenable: widget.isEditModeNotifier,
                          builder: (context, isEditMode, _) {
                            return TextFormField(
                              controller: controller,
                              readOnly: !isEditMode || true,
                              decoration: inputDecoration,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFB5B5B5),
                                height: 24 / 17,
                              ),
                            );
                          },
                        );
                },
              ),
              if (!isEditable)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      if (_selectedRepairPriority == 'Not Applicable') {
                        return;
                      }
                      final isConfirmed = await _showEditConfirmationDialog(
                        context,
                      );
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
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: 'Enter here',
                                hintStyle: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF979797),
                                  fontSize: 14.0,
                                ),
                                filled: true,
                                fillColor: !isEditMode
                                    ? Colors.white
                                    : const Color(0xFFFFFFFF),
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
                                            onPressed: !isEditMode
                                                ? null
                                                : () => _showDeleteConfirmation(
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
                                            onPressed: !isEditMode
                                                ? null
                                                : () => _pickFile(
                                                      context,
                                                      controller,
                                                      fileOf,
                                                    ),
                                          ),
                              ),
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
                          onTap: () {
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
      if (fileOf == 'correctiveCertificationAttach') {
        _correctiveCertificationNo = null;
        _correctiveCertificationAttach = null;
        _correctiveCertificationOrgName = null;
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

  void onSubmitCorrectiveActions({required bool clearFlag}) async {
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
    String? formattedCorrectivePhoto1 =
        _correctivePhoto1!.startsWith('$apiUrl/')
            ? _correctivePhoto1!.replaceFirst('$apiUrl/', '')
            : _correctivePhoto1;
    String? formattedCorrectivePhoto2 =
        _correctivePhoto2!.startsWith('$apiUrl/')
            ? _correctivePhoto2!.replaceFirst('$apiUrl/', '')
            : _correctivePhoto2;
    String? formattedCorrectivePhoto3 =
        _correctivePhoto3!.startsWith('$apiUrl/')
            ? _correctivePhoto3!.replaceFirst('$apiUrl/', '')
            : _correctivePhoto3;
    String? formattedCorrectivePhoto4 =
        _correctivePhoto4!.startsWith('$apiUrl/')
            ? _correctivePhoto4!.replaceFirst('$apiUrl/', '')
            : _correctivePhoto4;
    String? formattedCorrectivePhoto5 =
        _correctivePhoto5!.startsWith('$apiUrl/')
            ? _correctivePhoto5!.replaceFirst('$apiUrl/', '')
            : _correctivePhoto5;
    String? formattedCorrectivePhoto6 =
        _correctivePhoto6!.startsWith('$apiUrl/')
            ? _correctivePhoto6!.replaceFirst('$apiUrl/', '')
            : _correctivePhoto6;

    if (_getTextFieldValue(_existingFaults) == "0") {
      _selectedIsolationRequirement = _getTextFieldValue(_existingFaults) == "0"
          ? 'Not Applicable'
          : _selectedIsolationRequirement;
      _selectedOtherRequirement = _getTextFieldValue(_existingFaults) == "0"
          ? 'Not Applicable'
          : _selectedOtherRequirement;
    }
    _correctiveCertificationOrgName =
        _correctiveCertificationController.text.isNotEmpty
            ? _correctiveCertificationController.text
            : _correctiveCertificationNo?.split('.').first;
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
            widget.exInspectionRequest.equipmentTagRequest?.repairSignOff;
      }
    } else {
      signatureImg =
          widget.exInspectionRequest.equipmentTagRequest?.repairSignOff;
    }
    widget.exInspectionRequest.equipmentTagRequest = EquipmentTagRequest(
      location: widget.exInspectionRequest.functionalAreaRequest!.location,
      locationLatitude:
          widget.exInspectionRequest.functionalAreaRequest!.locationLatitude,
      locationLongitude:
          widget.exInspectionRequest.functionalAreaRequest!.locationLongitude,
      area: widget.exInspectionRequest.functionalAreaRequest!.area,
      zone: widget.exInspectionRequest.functionalAreaRequest!.zone,
      isActive: widget.exInspectionRequest.functionalAreaRequest!.isActive,
      locationGasGroup:
          widget.exInspectionRequest.functionalAreaRequest!.locationGasGroup,
      locationTClass:
          widget.exInspectionRequest.functionalAreaRequest!.locationTClass,
      locationIpRating:
          widget.exInspectionRequest.functionalAreaRequest!.locationIpRating,
      locationTAmbient:
          widget.exInspectionRequest.functionalAreaRequest!.tAmbient,
      locationId:
          widget.exInspectionRequest.equipmentTagRequest?.locationId ?? '',
      deckLevel: widget.exInspectionRequest.functionalAreaRequest!.deckLevel,
      areaClassDrawAttach:
          widget.exInspectionRequest.functionalAreaRequest!.areaClassDrawAttach,
      areaClassDrawNo:
          widget.exInspectionRequest.functionalAreaRequest!.areaClassDrawNo,
      eqpmtLytDrawAttach:
          widget.exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawAttach,
      eqpmtLytDrawNo:
          widget.exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawNo,
      yesNoSelection:
          widget.exInspectionRequest.equipmentTagRequest!.yesNoSelection,
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
      areaStatus: widget.exInspectionRequest.equipmentTagRequest?.areaStatus,
      tAmbientEquip:
          widget.exInspectionRequest.equipmentTagRequest?.tAmbientEquip,
      inspectionSignOff:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionSignOff,
      repairSignOff: signatureImg,
      specialCond: widget.exInspectionRequest.equipmentTagRequest?.specialCond,
      oracleId: widget.exInspectionRequest.equipmentTagRequest?.oracleId,
      assetId: widget.exInspectionRequest.equipmentTagRequest?.assetId,
      checkList: widget.exInspectionRequest.equipmentTagRequest?.checkList,
      inspectedBy: widget.exInspectionRequest.equipmentTagRequest?.inspectedBy,
      inspectedDate:
          widget.exInspectionRequest.equipmentTagRequest?.inspectedDate,
      faultyItems: widget.exInspectionRequest.equipmentTagRequest?.faultyItems,
      inspectionStatus:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionStatus,
      defectOverallCondition: widget
          .exInspectionRequest.equipmentTagRequest?.defectOverallCondition,
      defectIsolation:
          widget.exInspectionRequest.equipmentTagRequest?.defectIsolation,
      defectOtherRequirements: widget
          .exInspectionRequest.equipmentTagRequest!.defectOtherRequirements,
      dataSheet: widget.exInspectionRequest.equipmentTagRequest?.dataSheet,
      dataSheetOrgName:
          widget.exInspectionRequest.equipmentTagRequest?.dataSheetOrgName,
      dataSheetNo: widget.exInspectionRequest.equipmentTagRequest?.dataSheetNo,
      defectCertificationAttach: widget
          .exInspectionRequest.equipmentTagRequest?.defectCertificationAttach,
      defectCertificationOrgName: widget
          .exInspectionRequest.equipmentTagRequest?.defectCertificationOrgName,
      defectCertificationNo:
          widget.exInspectionRequest.equipmentTagRequest?.defectCertificationNo,
      defectivePhoto1:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto1,
      defectivePhoto1OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.defectivePhoto1OrgName,
      defectivePhoto2:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto2,
      defectivePhoto2OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.defectivePhoto2OrgName,
      defectivePhoto3:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto3,
      defectivePhoto3OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.defectivePhoto3OrgName,
      defectivePhoto4:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto4,
      defectivePhoto4OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.defectivePhoto4OrgName,
      defectivePhoto5:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto5,
      defectivePhoto5OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.defectivePhoto5OrgName,
      defectivePhoto6:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto6,
      defectivePhoto6OrgName: widget
          .exInspectionRequest.equipmentTagRequest?.defectivePhoto6OrgName,
      additionalInfoForRepairs: widget
          .exInspectionRequest.equipmentTagRequest?.additionalInfoForRepairs,
      existingFaults: _getTextFieldValue(_existingFaults),
      correctiveDefectCategory: _selectedRepairPriority,
      repairPriority:
          widget.exInspectionRequest.equipmentTagRequest?.repairPriority,
      currentStatus: _getTextFieldValue(_currentStatus),
      correctiveOverallCondition: _getTextFieldValue(_currentCondition),
      correctiveisolation: _selectedIsolationRequirement,
      correctiveOtherRequirements: _selectedOtherRequirement,
      repairsDone: _getTextFieldValue(_completedRepairs),
      remarksIfAny: _getTextFieldValue(_remarksIfAny),
      correctiveCertificationOrgName: _correctiveCertificationOrgName,
      correctiveCertificationNo: _correctiveCertificationNo,
      correctiveCertificationAttach: _correctiveCertificationAttach,
      repairTimeEstimate: _repairDuration.text,
      repairDuration:
          widget.exInspectionRequest.equipmentTagRequest?.repairDuration,
      correctivePhoto1: formattedCorrectivePhoto1,
      correctivePhoto1OrgName: (_correctivePhoto1OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.correctivePhoto1OrgName) ??
          '',
      correctivePhoto2: formattedCorrectivePhoto2,
      correctivePhoto2OrgName: (_correctivePhoto2OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.correctivePhoto2OrgName) ??
          '',
      correctivePhoto3: formattedCorrectivePhoto3,
      correctivePhoto3OrgName: (_correctivePhoto3OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.correctivePhoto3OrgName) ??
          '',
      correctivePhoto4: formattedCorrectivePhoto4,
      correctivePhoto4OrgName: (_correctivePhoto4OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.correctivePhoto4OrgName) ??
          '',
      correctivePhoto5: formattedCorrectivePhoto5,
      correctivePhoto5OrgName: (_correctivePhoto5OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.correctivePhoto5OrgName) ??
          '',
      correctivePhoto6: formattedCorrectivePhoto6,
      correctivePhoto6OrgName: (_correctivePhoto6OrgName ??
              widget.exInspectionRequest.equipmentTagRequest
                  ?.correctivePhoto6OrgName) ??
          '',
      supplementaryMaterialReq: materials,
      repairedBy: userName,
      inspectionChecklistType: widget
          .exInspectionRequest.equipmentTagRequest!.inspectionChecklistType,
      inspectionGrade:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionGrade,
      inspectionType:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionType,
      defectDefectCategory:
          widget.exInspectionRequest.equipmentTagRequest?.defectDefectCategory,
      remarks: widget.exInspectionRequest.equipmentTagRequest?.remarks,
      subArea: widget.exInspectionRequest.equipmentTagRequest?.subArea,
      equipmentEquipmentType: widget
          .exInspectionRequest.equipmentTagRequest?.equipmentEquipmentType,
      rbiStrategy: widget.exInspectionRequest.equipmentTagRequest?.rbiStrategy,
      materials: widget.exInspectionRequest.equipmentTagRequest?.materials,
      repairedDate: DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(
        DateTime.now(),
      ), //DateFormat("dd-MM-yyyy hh:mm a") DateFormat("dd MMM yy HH:mm 'Hrs'").format(DateTime.now()),
      eqpmtLytDrawAttachOrgName: widget
          .exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawAttachOrgName,
      areaClassDrawAttachOrgName: widget.exInspectionRequest
          .functionalAreaRequest!.areaClassDrawAttachOrgName,
      primaryId: widget.exInspectionRequest.equipmentTagRequest?.primaryId,
      inspectionPriority:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionPriority,
      inspectedId: loggedInUser?.userId.toString(),
    );
    if (!mounted) return;
    context.read<ExInspectionsBloc>().add(
          SubmitEquipmentTag(
            widget.exInspectionRequest,
            clearFlag: clearFlag,
            screenType: 'Corrective Actions',
            userUpdateSign: false,
          ),
        );
    setState(() {
      isEditable = false;
      showEditIcon = true;
    });
  }
}
