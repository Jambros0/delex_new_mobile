// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/multi_select_dropdown.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/functional_area_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/camera_page.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/download_file.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/searchable_dropdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/ex_inspection_request.dart';

enum CustomFileSource { camera, gallery, file }

class FunctionalAreaStep extends StatefulWidget {
  final ExInspectionRequest exInspectionRequest;
  final bool isUpdate;
  final ValueNotifier<bool> isEditModeNotifier;
  final ValueNotifier<bool> isEditAreaModeNotifier;
  const FunctionalAreaStep({
    super.key,
    required this.exInspectionRequest,
    required this.isUpdate,
    required this.isEditModeNotifier,
    required this.isEditAreaModeNotifier,
  });

  @override
  FunctionalAreaStepState createState() => FunctionalAreaStepState();
}

class FunctionalAreaStepState extends State<FunctionalAreaStep> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _selectedFieldName = '';
  String _selectedPlatform = '';
  String _selectedDeckLevel = '';
  String _selectedZone = '';
  String _selectedGasGroup = '';
  String _selectedTemperatureClass = '';
  String _selectedIpRating = '';
  List<String> _filteredPlatforms = [];
  List<String> _filteredAreas = [];
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();
  List<String> selectedGasItems = [];
  List<String> selectedTemperatureItems = [];
  List<String> selectedIPRatingItems = [];
  String? _locationId;
  bool _isFieldValid = false;
  final TextEditingController _subAreaController = TextEditingController();
  final TextEditingController _ambientTemperatureController =
      TextEditingController();
  final TextEditingController _gpsCoordinatesController =
      TextEditingController();
  // final TextEditingController _areaClassificationDrawingController =
  //     TextEditingController();
  // final TextEditingController _equipmentLayoutDrawingController =
  //     TextEditingController();
  final TextEditingController _locationLatitude = TextEditingController();
  final TextEditingController _locationLongtitude = TextEditingController();
  final List<TextEditingController> _areaClassificationDrawingController = [];
  final List<TextEditingController> _equipmentLayoutDrawingController = [];

  final List<String?> _areaFilePaths = [];
  final List<String?> _equipmentFilePaths = [];

  late List<String?> _areaClassDrawNo = [];
  late List<String?> _areaClassDrawAttach = [];
  late List<String?> _areaClassDrawAttachOrgName = [];

  late List<String?> _eqpmtLytDrawNo = [];
  late List<String?> _eqpmtLytDrawAttach = [];
  late List<String?> _eqpmntLytDrawAttachOrgName = [];

  // String? _areaClassDrawNo;
  // String? _areaClassDrawAttach;
  // String? _areaClassDrawAttachOrgName;
  // String? _eqpmtLytDrawNo;
  // String? _eqpmtLytDrawAttach;
  // String? _eqpmntLytDrawAttachOrgName;
  bool _isSubmitting = false;
  bool isFieldNameSelected = false;
  bool isShowError = false;
  bool validationAm = false;
  bool controllerCheck = false;
  bool _isActive = false;
  String? _selectedAreaStatus;
  String? _userType;

  void clearFields() {
    setState(() {
      _isSubmitting = false;
      _selectedFieldName = '';
      _selectedPlatform = '';
      _selectedDeckLevel = '';
      _selectedZone = '';
      _selectedGasGroup = '';
      _selectedTemperatureClass = '';
      _selectedIpRating = '';
      _subAreaController.clear();
      _ambientTemperatureController.clear();
      _gpsCoordinatesController.clear();
      _areaClassificationDrawingController.clear();
      _equipmentLayoutDrawingController.clear();
      _areaClassDrawNo.clear();
      _areaClassDrawAttach.clear();
      _areaClassDrawAttachOrgName.clear();
      _areaFilePaths.clear();
      _eqpmntLytDrawAttachOrgName.clear();
      _eqpmtLytDrawNo.clear();
      _eqpmtLytDrawAttach.clear();
      _equipmentFilePaths.clear();
      _locationLongtitude.clear();
      _locationLatitude.clear();

      selectedGasItems.clear();
      selectedTemperatureItems.clear();
      selectedIPRatingItems.clear();
      selectedGasItems = [];
      selectedTemperatureItems = [];
      _selectedAreaStatus = 'Active';
      _isActive = true;
    });
    _addInitialControllers();
    // formKey.currentState?.reset();

    onSubmitFunctionalArea(skipValidation: true);
  }

  @override
  void initState() {
    super.initState();
    context.read<ExInspectionsBloc>().add(FetchAllDropDwn());
    context.read<ExInspectionsBloc>().stream.listen((state) {
      if (state is ExInspectionLoaded) {
        if (widget.exInspectionRequest.functionalAreaRequest != null) {
          _updateDropdownFilters(state.allDropDowns!);
        }
      }
    });

    if (widget.exInspectionRequest.functionalAreaRequest != null) {
      _initializeValues();
    }
    if (widget.isUpdate == false) {
      _addInitialControllers();
    }
    controllerCheck = false;

    context.read<ExInspectionsBloc>().add(FetchAllDropDwn());
    _loadUserType();
  }

  void _updateDropdownFilters(Map<String, dynamic> dropdownData) {
    final locationDropDown =
        dropdownData['result']['locationDropDown'][0] as Map<String, dynamic>;

    if (!mounted) return;
    setState(() {
      _filteredPlatforms = _getPlatformsForFieldName(
        locationDropDown,
        _selectedFieldName,
      );

      _filteredAreas = _getAreasForFieldName(
        locationDropDown,
        _selectedFieldName,
        platformName: _selectedPlatform,
      );

      if (_selectedFieldName != null && _selectedFieldName.isNotEmpty) {
        final allPlatforms = _getPlatformsForFieldName(
          locationDropDown,
          _selectedFieldName,
        );
        _filteredPlatforms = allPlatforms;

        if (_selectedPlatform != null && _selectedPlatform.isNotEmpty) {
          final allAreas = _getAreasForFieldName(
            locationDropDown,
            _selectedFieldName,
            platformName: _selectedPlatform,
          );
          _filteredAreas = allAreas;
        }
      }

      if (_selectedPlatform != null &&
          !_filteredPlatforms.contains(_selectedPlatform)) {
        _filteredPlatforms.add(_selectedPlatform);
      }

      if (_selectedDeckLevel != null &&
          !_filteredAreas.contains(_selectedDeckLevel)) {
        _filteredAreas.add(_selectedDeckLevel);
      }
    });
  }

  void _addInitialControllers() {
    if (_areaClassificationDrawingController.isEmpty) {
      _areaClassificationDrawingController.add(TextEditingController());
      _areaFilePaths.add(null);
    }

    if (_equipmentLayoutDrawingController.isEmpty) {
      _equipmentLayoutDrawingController.add(TextEditingController());
      _equipmentFilePaths.add(null);
    }
  }

  Future<void> _loadUserType() async {
    final userType = await AuthUtils().getUserType();
    setState(() {
      _userType = userType;
    });
  }

  @override
  void didUpdateWidget(covariant FunctionalAreaStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldRequest = oldWidget.exInspectionRequest;
    final newRequest = widget.exInspectionRequest;
    if (oldRequest != newRequest && newRequest.functionalAreaRequest != null) {
      controllerCheck = true;
      _initializeValues();
    }
  }

  void _initializeValues() {
    final request = widget.exInspectionRequest.functionalAreaRequest;
    _selectedFieldName = request!.location;
    _selectedPlatform = request.area;
    _selectedDeckLevel = request.deckLevel;
    _selectedZone = request.zone;

    if (request.locationGasGroup.isNotEmpty) {
      selectedGasItems = request.locationGasGroup;
    }
    if (request.locationTClass.isNotEmpty) {
      selectedTemperatureItems = request.locationTClass;
    }
    if (request.locationIpRating.isNotEmpty) {
      selectedIPRatingItems = request.locationIpRating;
    }
    _subAreaController.text = request.subArea ?? '';
    _ambientTemperatureController.text = request.tAmbient;
    _areaClassDrawNo = List<String?>.from(request.areaClassDrawNo);
    _areaClassDrawAttach = List<String?>.from(request.areaClassDrawAttach);
    _areaClassDrawAttachOrgName = List<String?>.from(
      request.areaClassDrawAttachOrgName,
    );

    for (int i = 0; i < _areaClassDrawAttachOrgName.length; i++) {
      _areaClassificationDrawingController.add(
        TextEditingController(text: _areaClassDrawAttachOrgName[i] ?? ''),
      );
      final path = (i < _areaClassDrawAttach.length)
          ? (_areaClassDrawAttach[i] ?? '')
          : '';
      _areaFilePaths.add(path);
    }

    _eqpmtLytDrawNo = List<String?>.from(request.eqpmtLytDrawNo);
    _eqpmtLytDrawAttach = List<String?>.from(request.eqpmtLytDrawAttach);
    _eqpmntLytDrawAttachOrgName = List<String?>.from(
      request.eqpmtLytDrawAttachOrgName,
    );

    for (int i = 0; i < _eqpmntLytDrawAttachOrgName.length; i++) {
      _equipmentLayoutDrawingController.add(
        TextEditingController(text: _eqpmntLytDrawAttachOrgName[i] ?? ''),
      );
      final path = (i < _eqpmtLytDrawAttach.length)
          ? (_eqpmtLytDrawAttach[i] ?? '')
          : '';
      _equipmentFilePaths.add(path);
    }

    _locationId = request.locationId ?? '';
    _locationLatitude.text = request.locationLatitude ?? '';
    _locationLongtitude.text = request.locationLongitude ?? '';
    _isActive = request.isActive;
    _selectedAreaStatus =
        request.areaStatus ?? (_isActive ? 'Active' : 'In Active');

    if (_locationLatitude.text.isNotEmpty &&
        _locationLongtitude.text.isNotEmpty) {
      _gpsCoordinatesController.text =
          '${_locationLatitude.text}, ${_locationLongtitude.text}';
    }
    if (controllerCheck == true) {
      if (_areaClassificationDrawingController.isEmpty) {
        _addInitialControllers();
      }
      if (_equipmentLayoutDrawingController.isEmpty) {
        _addInitialControllers();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final blocState = context.read<ExInspectionsBloc>().state;
      final dropdownData =
          blocState is ExInspectionLoaded ? blocState.allDropDowns : null;

      if (dropdownData != null) {
        final locationDropDown = dropdownData['result']['locationDropDown'][0]
            as Map<String, dynamic>;

        final allPlatforms = _getPlatformsForFieldName(
          locationDropDown,
          _selectedFieldName,
        );

        if (allPlatforms.isNotEmpty) {
          setState(() {
            _filteredPlatforms = allPlatforms;
            if (!_filteredPlatforms.contains(_selectedPlatform)) {
              _selectedPlatform = '';
            }
          });
        }

        _filteredAreas = _getAreasForFieldName(
          locationDropDown,
          _selectedFieldName,
          platformName: _selectedPlatform,
        );
      }
    });
  }
  // Future<void> _pickFile(BuildContext context, TextEditingController controller,
  //     String fileOf) async {
  //   final picker = ImagePicker();
  //   final CustomFileSource? selection =
  //       await _showAttachmentSourceDialog(context);

  //   File? file;

  //   if (selection == CustomFileSource.camera) {
  //     // final pickedImage = await picker.pickImage(source: ImageSource.camera);
  //     final pickedImage = await Navigator.push<File>(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const CustomCameraScreen(),
  //       ),
  //     );
  //     if (pickedImage != null) {
  //       file = File(pickedImage.path);
  //     }
  //   } else if (selection == CustomFileSource.gallery) {
  //     final pickedImage = await picker.pickImage(source: ImageSource.gallery);
  //     if (pickedImage != null) {
  //       file = File(pickedImage.path);
  //     }
  //   } else if (selection == CustomFileSource.file) {
  //     file = await _pickCustomFile();
  //   } else {
  //     // User tapped outside the dialog or pressed back
  //     return;
  //   }

  //   if (file != null) {
  //     await _processAndUploadFile(file, controller, fileOf);
  //   }
  // }

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

  // Future<void> _processAndUploadFile(
  //     File file, TextEditingController controller, String fileOf) async {
  //   String originalFileName = file.path.split('/').last;
  //   String fileExtension = originalFileName.split('.').last;
  //   String customFileNameBase = generateCustomFileName(fileOf);
  //   String customFileName = '$customFileNameBase.$fileExtension';
  //   controller.text = originalFileName.split('.').first;
  //   final customFilePath = '${file.parent.path}/$customFileName';
  //   await file.rename(customFilePath);
  //   _uploadFile(File(customFilePath), fileOf);
  // }

  // String generateCustomFileName(String fileOf) {
  //   String prefix = fileOf == 'areaClassDrawAttach' ? 'ACDN' : 'ELDN';
  //   String fieldNamePart = _selectedFieldName
  //       .substring(0, min(_selectedFieldName.length, 3))
  //       .toUpperCase();

  //   String platformPart = _selectedPlatform
  //       .substring(0, min(_selectedPlatform.length, 3))
  //       .toUpperCase();
  //   String deckLevelPart;
  //   if (_selectedDeckLevel == 'Main Deck') {
  //     deckLevelPart = 'MAD';
  //   } else if (_selectedDeckLevel == 'Mezzanine Deck') {
  //     deckLevelPart = 'MED';
  //   } else {
  //     List<String> deckLevelWords = _selectedDeckLevel.split(' ');
  //     deckLevelPart = deckLevelWords.length > 1
  //         ? '${deckLevelWords[0].substring(0, 2).toUpperCase()}${deckLevelWords[1][0].toUpperCase()}'
  //         : _selectedDeckLevel.substring(0, 1).toUpperCase();
  //   }
  //   return '$prefix-$fieldNamePart-$platformPart-$deckLevelPart';
  // }

  // void _uploadFile(File file, String fileOf) {
  //   context.read<ExInspectionsBloc>().add(UploadFile(file, fileOf));
  // }
  void _uploadFile(File file, String fileOf, int index) {
    context.read<ExInspectionsBloc>().add(
          UploadFunctionalAreaFile(file, fileOf, index),
        );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    setState(() {
      _locationLatitude.text = position.latitude.toString();
      _locationLongtitude.text = position.longitude.toString();
      _gpsCoordinatesController.text =
          '${position.latitude}, ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExInspectionsBloc, ExInspectionsState>(
      listener: (context, state) {
        if (state is FileUploadFunctionalAreaSuccess) {
          _handleFileData(state.uploadData, state.index);
        } else if (state is ExInspectionSuccess) {
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
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  // if (widget.isUpdate) _areaStatusSection(_isActive),
                  _buildForm(state.allDropDowns ?? {}),
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
    );
  }

  void _ensureListSize<T>(List<T?> list, int index) {
    if (list.length <= index) {
      final extra = List<T?>.filled(index - list.length + 1, null);
      list.addAll(extra);
    }
  }

  /// Ensures a controller list is large enough
  void _ensureControllerListSize(List<TextEditingController> list, int index) {
    if (list.length <= index) {
      final extra = List.generate(
        index - list.length + 1,
        (_) => TextEditingController(),
      );
      list.addAll(extra);
    }
  }

  // int _findAvailableIndex(String fileType) {
  //   List<String?> targetList = [];

  //   if (fileType == 'areaClassDrawAttach') {
  //     targetList = _areaClassDrawAttach;
  //   } else if (fileType == 'eqpmtLytDrawAttach') {
  //     targetList = _eqpmtLytDrawAttach;
  //   }

  //   for (int i = 0; i < targetList.length; i++) {
  //     if (targetList[i] == null || targetList[i]!.isEmpty) {
  //       return i;
  //     }
  //   }

  //   return targetList.length; // Append at the end if no empty spot
  // }

  void _deleteFile(BuildContext context, int index, String fileOf) {
    setState(() {
      if (fileOf == 'areaClassDrawAttach') {
        if (index < _areaClassificationDrawingController.length) {
          _areaClassificationDrawingController[index].clear();
        }
        if (index < _areaClassDrawNo.length) {
          _areaClassDrawNo[index] = null;
        }
        if (index < _areaClassDrawAttach.length) {
          _areaClassDrawAttach[index] = null;
        }
        if (index < _areaClassDrawAttachOrgName.length) {
          _areaClassDrawAttachOrgName[index] = null;
        }
      } else if (fileOf == 'eqpmtLytDrawAttach') {
        if (index < _equipmentLayoutDrawingController.length) {
          _equipmentLayoutDrawingController[index].clear();
        }
        if (index < _eqpmtLytDrawNo.length) {
          _eqpmtLytDrawNo[index] = null;
        }
        if (index < _eqpmtLytDrawAttach.length) {
          _eqpmtLytDrawAttach[index] = null;
        }
        if (index < _eqpmntLytDrawAttachOrgName.length) {
          _eqpmntLytDrawAttachOrgName[index] = null;
        }
      }
    });
  }

  String _extractPrefix(String originalName) {
    final nameWithoutExt = originalName.split('.').first;
    final match = RegExp(r'^(.+?)-\d+$').firstMatch(nameWithoutExt);
    return match != null ? match.group(1)! : nameWithoutExt;
  }

  String _getNextAvailableName(List<String?> names, String prefix) {
    final usedNumbers = names
        .where((name) => name != null && name.startsWith(prefix))
        .map((name) {
          final parts = name!.split('-');
          return int.tryParse(parts.last);
        })
        .whereType<int>()
        .toSet();

    int i = 1;
    while (usedNumbers.contains(i)) {
      i++;
    }
    return '$prefix-$i';
  }

  void _handleFileData(dynamic fileData, int index) {
    final fileType = fileData['type'];
    final fileMetadata = fileData['uploadStatus'];
    final originalName = fileMetadata['originalName'];
    final filePath = fileMetadata['file'];
    // final fileNameWithoutExt = originalName.split('.').first;

    final prefix = _extractPrefix(originalName);
    final List<String?> orgNameList = fileType == 'areaClassDrawAttach'
        ? _areaClassDrawAttachOrgName
        : _eqpmntLytDrawAttachOrgName;

    final fileNameWithoutExts = _getNextAvailableName(orgNameList, prefix);
    setState(() {
      if (fileType == 'areaClassDrawAttach') {
        _ensureListSize<String>(_areaFilePaths, index);
        _ensureControllerListSize(_areaClassificationDrawingController, index);
        _ensureListSize<String>(_areaClassDrawNo, index);
        _ensureListSize<String>(_areaClassDrawAttach, index);
        _ensureListSize<String>(_areaClassDrawAttachOrgName, index);

        _areaFilePaths[index] = filePath;
        _areaClassificationDrawingController[index].text = fileNameWithoutExts;
        _areaClassDrawNo[index] = fileNameWithoutExts;
        _areaClassDrawAttach[index] = filePath;
        _areaClassDrawAttachOrgName[index] = originalName;
      } else if (fileType == 'eqpmtLytDrawAttach') {
        _ensureListSize<String>(_equipmentFilePaths, index);
        _ensureControllerListSize(_equipmentLayoutDrawingController, index);
        _ensureListSize<String>(_eqpmtLytDrawNo, index);
        _ensureListSize<String>(_eqpmtLytDrawAttach, index);
        _ensureListSize<String>(_eqpmntLytDrawAttachOrgName, index);

        _equipmentFilePaths[index] = filePath;
        _equipmentLayoutDrawingController[index].text = fileNameWithoutExts;
        _eqpmtLytDrawNo[index] = fileNameWithoutExts;
        _eqpmtLytDrawAttach[index] = filePath;
        _eqpmntLytDrawAttachOrgName[index] = originalName;
      }
    });

    Fluttertoast.showToast(
      msg:
          '${fileType == 'areaClassDrawAttach' ? 'Area Classification' : 'Equipment Layout'} uploaded successfully',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // void _handleFileData(dynamic fileData) {
  //   final fileType = fileData['type'];
  //   final fileMetadata = fileData['uploadStatus'];
  //   if (fileType == 'areaClassDrawAttach') {
  //     setState(() {
  //       _areaClassDrawNo = fileMetadata['originalName'];
  //       _areaClassDrawAttach = fileMetadata['file'];
  //       _areaClassDrawAttachOrgName = _areaClassDrawNo!.split('.').first;
  //       _areaClassificationDrawingController.text =
  //           _areaClassDrawAttachOrgName!;
  //     });
  //     Fluttertoast.showToast(
  //         msg: "Area Classification uploaded successfully",
  //         toastLength: Toast.LENGTH_SHORT);
  //   } else if (fileType == 'eqpmtLytDrawAttach') {
  //     setState(() {
  //       _eqpmtLytDrawNo = fileMetadata['originalName'];
  //       _eqpmtLytDrawAttach = fileMetadata['file'];
  //       _eqpmntLytDrawAttachOrgName = _eqpmtLytDrawNo!.split('.').first;
  //       _equipmentLayoutDrawingController.text = _eqpmntLytDrawAttachOrgName!;
  //     });
  //     Fluttertoast.showToast(
  //         msg: "Equipement Layout uploaded successfully",
  //         toastLength: Toast.LENGTH_SHORT);
  //   }
  // }

  Widget _areaStatusSection(bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        width: 888,
        height: 48,
        padding: const EdgeInsets.only(top: 0, bottom: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Area Status',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4B4B4B),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: !widget.isEditModeNotifier.value
                              ? null
                              : () {
                                  setState(() {
                                    _isActive = !_isActive;
                                  });
                                },
                          child: SvgPicture.asset(
                            _isActive
                                ? 'lib/src/features/ex_inspections/assets/toggle_on.svg'
                                : 'lib/src/features/ex_inspections/assets/toggle_off.svg',
                            width: 39,
                            height: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isActive ? 'Active' : 'Inactive',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4B4B4B),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Map<String, dynamic> getAllDropDowns) {
    final locationDropDown = getAllDropDowns['result']['locationDropDown'][0]
        as Map<String, dynamic>;
    final exRegisterDropDown = getAllDropDowns['result']['exResiterDropDown'][0]
        as Map<String, dynamic>;

    // Extract lists
    final fieldNames = (locationDropDown['locationDropDown'] as List<dynamic>)
        .map((item) => item['name'].toString())
        .toList();

    // Build a map for platform → location relation
    final platformToLocationMap = <String, String>{};
    for (final loc in (locationDropDown['locationDropDown'] as List<dynamic>)) {
      final locationName = loc['name'].toString();
      for (final p in (loc['platforms'] as List<dynamic>)) {
        platformToLocationMap[p['platformName'].toString()] = locationName;
      }
    }

    // --- Filter logic ---
    // Safe fallback if not selected yet
    _filteredPlatforms = _getPlatformsForFieldName(
      locationDropDown,
      _selectedFieldName,
    );

    _filteredAreas = _getAreasForFieldName(
      locationDropDown,
      _selectedFieldName,
      platformName: _selectedPlatform,
    );

    // Ensure old selected values appear if missing
    if (_selectedFieldName.isNotEmpty &&
        !fieldNames.contains(_selectedFieldName)) {
      fieldNames.add(_selectedFieldName);
    }
    if (_selectedPlatform.isNotEmpty &&
        !_filteredPlatforms.contains(_selectedPlatform)) {
      _filteredPlatforms.add(_selectedPlatform);
    }
    if (_selectedDeckLevel.isNotEmpty &&
        !_filteredAreas.contains(_selectedDeckLevel)) {
      _filteredAreas.add(_selectedDeckLevel);
    }

    // final deckLevel = (locationDropDown['deckLevel'] as List<dynamic>)
    //     .map((item) => item.toString())
    //     .toList();

    final zone = (exRegisterDropDown['zone'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();

    final gasGroup = (exRegisterDropDown['gasGroup'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();

    final temperatureClass =
        (exRegisterDropDown['temperatureClass'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final ipRating = (exRegisterDropDown['ipRating'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: Wrap(
          spacing: 24.0,
          runSpacing: 24.0,
          children: [
            // ----------------------------
            _buildDropdownField(
              label: _userType == 'onshore' ? 'Location' : 'Field Name',
              value: _selectedFieldName,
              items: fieldNames,
              onChanged: (value) {
                setState(() {
                  _selectedFieldName = value ?? '';
                  // clear dependent selections
                  _selectedPlatform = '';
                  _selectedDeckLevel = '';
                  // recalc dependent lists
                  _filteredPlatforms = _getPlatformsForFieldName(
                    locationDropDown,
                    _selectedFieldName,
                  );
                  _filteredAreas = [];
                });
              },
              isMandatory: true,
            ),

            // ----------------------------
            // 2️⃣ Platform Dropdown
            // ----------------------------
            _buildDropdownField(
              label: _userType == 'onshore' ? 'Sub Location' : 'Platform',
              value: _selectedPlatform,
              items: _filteredPlatforms,
              onChanged: (value) {
                setState(() {
                  _selectedPlatform = value ?? '';

                  // Infer Field Name if needed
                  if (_userType != 'onshore') {
                    final inferredLocation =
                        platformToLocationMap[_selectedPlatform];
                    if (inferredLocation != null &&
                        inferredLocation != _selectedFieldName) {
                      _selectedFieldName = inferredLocation;
                    }
                  }
                  // Reset dependent (deck)
                  _selectedDeckLevel = '';

                  _filteredAreas = _getAreasForFieldName(
                    locationDropDown,
                    _selectedFieldName,
                    platformName: _selectedPlatform,
                  );
                });
              },
              isMandatory: true,
            ),

            // ----------------------------
            // 3️⃣ Deck Level Dropdown
            // ----------------------------
            _buildDropdownField(
              label: _userType == 'onshore' ? 'Area' : 'Deck Level',
              value: _selectedDeckLevel,
              items: _filteredAreas,
              onChanged: (value) {
                setState(() {
                  _selectedDeckLevel = value ?? '';

                  // Update platform options for this deck
                  _filteredPlatforms = _getPlatformsByDeckLevel(
                    locationDropDown,
                    _selectedDeckLevel,
                    locationName: _selectedFieldName,
                  );

                  // If selected platform no longer valid, clear it
                  if (!_filteredPlatforms.contains(_selectedPlatform)) {
                    _selectedPlatform = '';
                  }
                });
              },
              isMandatory: true,
            ),
            _buildTextField(
              label: 'Sub Area (Nearest Landmark)',
              controller: _subAreaController,
              isMandatory: false,
            ),
            _buildDropdownField(
              label: 'Zone',
              value: _selectedZone,
              items: zone,
              onChanged: (value) {
                setState(() {
                  _selectedZone = value!;
                });
              },
              isMandatory: true,
            ),
            MultiSelectDropdown(
              label: 'Gas Group',
              items: gasGroup,
              selectedItems: selectedGasItems,
              isSubmitting: _isSubmitting,
              selectedItemString: _selectedGasGroup,
              onChanged: (value) {
                setState(() {
                  selectedGasItems = value;
                  _selectedGasGroup = value.isEmpty ? '' : value.join(',');
                });
              },
              isMandatory: true,
              isEditModeNotifier: widget.isEditModeNotifier,
              isEditAreaModeNotifier: widget.isEditAreaModeNotifier,
            ),
            MultiSelectDropdown(
              label: 'Temperature Class',
              items: temperatureClass,
              selectedItems: selectedTemperatureItems,
              isSubmitting: _isSubmitting,
              selectedItemString: _selectedTemperatureClass,
              onChanged: (value) {
                setState(() {
                  selectedTemperatureItems = value;

                  _selectedTemperatureClass =
                      value.isEmpty ? '' : value.join(',');
                });
              },
              isMandatory: true,
              isEditModeNotifier: widget.isEditModeNotifier,
              isEditAreaModeNotifier: widget.isEditAreaModeNotifier,
            ),
            _buildTextField(
              label: 'GPS Coordinates',
              controller: _gpsCoordinatesController,
              isMandatory: false,
            ),
            _buildDropdownField(
              label: 'Area Status',
              value:
                  _selectedAreaStatus ?? (_isActive ? 'Active' : 'In Active'),
              items: const ['Active', 'In Active'],
              onChanged: (value) {
                setState(() {
                  _selectedAreaStatus = value;
                  _isActive = value == 'Active';
                });
              },
              isMandatory: false,
            ),
            // _buildAmTextField(
            //   label: 'Ambient Temperature',
            //   controller: _ambientTemperatureController,
            //   hintText: 'Min°C to Max°C',
            //   isMandatory: true,
            // ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Expanded(
            //       child: _buildSection(
            //         title: 'Area Classification Drawings',
            //         controllers: _areaClassificationDrawingController,
            //         filePaths: _areaFilePaths,
            //         fileOf: 'areaClassDrawAttach',
            //         onAdd: () {
            //           setState(() {
            //             _areaClassificationDrawingController.add(
            //               TextEditingController(),
            //             );
            //             _areaFilePaths.add(null);
            //           });
            //         },
            //         isEditModeNotifier: widget.isEditModeNotifier,
            //         isEditAreaModeNotifier: widget.isEditAreaModeNotifier,
            //       ),
            //     ),
            //     const SizedBox(width: 4), // spacing between the two columns
            //     Expanded(
            //       child: _buildSection(
            //         title: 'Equipment Layout Drawings',
            //         controllers: _equipmentLayoutDrawingController,
            //         filePaths: _equipmentFilePaths,
            //         fileOf: 'eqpmtLytDrawAttach',
            //         onAdd: () {
            //           setState(() {
            //             _equipmentLayoutDrawingController.add(
            //               TextEditingController(),
            //             );
            //             _equipmentFilePaths.add(null);
            //           });
            //         },
            //         isEditModeNotifier: widget.isEditModeNotifier,
            //         isEditAreaModeNotifier: widget.isEditAreaModeNotifier,
            //       ),
            //     ),
            //   ],
            // ),
            _buildSection(
              title: 'Area Classification Drawings',
              controllers: _areaClassificationDrawingController,
              filePaths: _areaFilePaths,
              fileOf: 'areaClassDrawAttach',
              onAdd: () {
                setState(() {
                  _areaClassificationDrawingController.add(
                    TextEditingController(),
                  );
                  _areaFilePaths.add(null);
                });
              },
              isEditModeNotifier: widget.isEditModeNotifier,
              isEditAreaModeNotifier: widget.isEditAreaModeNotifier,
            ),
            _buildSection(
              title: 'Equipment Layout Drawings',
              controllers: _equipmentLayoutDrawingController,
              filePaths: _equipmentFilePaths,
              fileOf: 'eqpmtLytDrawAttach',
              onAdd: () {
                setState(() {
                  _equipmentLayoutDrawingController.add(
                    TextEditingController(),
                  );
                  _equipmentFilePaths.add(null);
                });
              },
              isEditModeNotifier: widget.isEditModeNotifier,
              isEditAreaModeNotifier: widget.isEditAreaModeNotifier,
            ),
            // _buildFilePickerField(
            //   label: 'Area Classification Drawing Number',
            //   controller: _areaClassificationDrawingController,
            //   fileOf: 'areaClassDrawAttach',
            //   filePath: _areaClassDrawAttach,
            // ),
            // _buildFilePickerField(
            //   label: 'Equipment Layout Drawing Number',
            //   controller: _equipmentLayoutDrawingController,
            //   fileOf: 'eqpmtLytDrawAttach',
            //   filePath: _eqpmtLytDrawAttach,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<TextEditingController> controllers,
    required List<String?> filePaths,
    required String fileOf,
    required VoidCallback onAdd,
    required ValueNotifier<bool> isEditModeNotifier,
    required ValueNotifier<bool> isEditAreaModeNotifier,
  }) {
    bool isLastFieldFilled =
        controllers.isEmpty ? false : controllers.last.text.trim().isNotEmpty;
    bool canAddMore = controllers.length < 3 && isLastFieldFilled;
    final safeLength = controllers.length < filePaths.length
        ? controllers.length
        : filePaths.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B4B4B),
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 8.0),
        ...List.generate(safeLength, (index) {
          // bool fileAttached = controllers[index].text.isNotEmpty;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: _buildMultipleFilePickerField(
              label: '',
              controller: controllers[index],
              fileOf: fileOf,
              filePath: filePaths[index],
              onFilePicked: (String filePath) {
                setState(() {
                  filePaths[index] = filePath;
                });
              },
              onFileDeleted: () {
                setState(() {
                  controllers[index].clear();
                  filePaths[index] = null;
                });
              },
              index: index,
              isEditModeNotifier: isEditModeNotifier,
              isEditAreaModeNotifier: isEditAreaModeNotifier,
            ),
          );
        }),

        // Attach More Button
        controllers.length < 3
            ? !widget.isEditModeNotifier.value
                ? const SizedBox()
                : !widget.isEditAreaModeNotifier.value
                    ? const SizedBox()
                    : GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (controllers.length < 3) {
                            if (canAddMore) {
                              onAdd();
                            } else {
                              Fluttertoast.showToast(
                                msg: controllers.length == 3
                                    ? "Maximum 3 files allowed"
                                    : "Please select a file before adding another",
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: controllers.length == 3
                                  ? "Maximum 3 files allowed"
                                  : "Please select a file before adding another",
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Text(
                            'Attach More files',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E90FF),
                              fontSize: 13.0,
                              height: 13 / 11,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF1E90FF),
                            ),
                          ),
                        ),
                      )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildMultipleFilePickerField({
    required String label,
    required TextEditingController controller,
    required String fileOf,
    required String? filePath,
    required Function(String filePath) onFilePicked,
    required VoidCallback onFileDeleted,
    required int index,
    required ValueNotifier<bool> isEditModeNotifier,
    required ValueNotifier<bool> isEditAreaModeNotifier,
  }) {
    // bool fileAttached = controller.text.isNotEmpty;
    return ValueListenableBuilder<bool>(
      valueListenable: isEditModeNotifier,
      builder: (context, isEditMode, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.isEditAreaModeNotifier,
          builder: (context, isEditAreaMode, _) {
            bool fileAttached = controller.text.isNotEmpty;
            return SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 81.5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final isFocused = Focus.of(context).hasFocus;

                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: isFocused && isEditMode ||
                                          isFocused && isEditAreaMode
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
                                  readOnly: !isEditAreaMode || !isEditMode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter here',
                                    hintStyle: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF979797),
                                      fontSize: 14.0,
                                    ),
                                    filled: true,
                                    fillColor: isEditAreaMode
                                        ? Colors.white
                                        : isEditMode
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
                                    suffixIcon: isEditAreaMode
                                        ? isEditMode
                                            ? IconButton(
                                                icon: fileAttached
                                                    ? SvgPicture.asset(
                                                        'lib/src/features/ex_inspections/assets/cancel_icon.svg',
                                                        width: 20,
                                                        height: 20,
                                                      )
                                                    : Icon(
                                                        Icons.attach_file,
                                                        color: !isEditMode
                                                            ? const Color(
                                                                0xFFBABABA,
                                                              )
                                                            : const Color(
                                                                0xFF3B475B,
                                                              ),
                                                      ),
                                                onPressed: fileAttached
                                                    ? () =>
                                                        _showDeleteConfirmation(
                                                          context,
                                                          controller,
                                                          fileOf,
                                                          index,
                                                        )
                                                    : () => _pickMultipleFile(
                                                          context,
                                                          controller,
                                                          fileOf,
                                                          onFilePicked,
                                                          index,
                                                        ),
                                              )
                                            : null
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
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
          },
        );
      },
    );
  }

  Widget _buildAmTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    required bool isMandatory,
  }) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        bool showErrorColor = false;
        if (!_isSubmitting) {
          showErrorColor =
              _isSubmitting && isMandatory && controller.text.isEmpty;
        } else {
          showErrorColor = isMandatory && controller.text.isEmpty;
        }
        updateError() {
          setState(() {
            if (isMandatory) {
              showErrorColor = isMandatory && controller.text.trim().isEmpty;
            }
          });
        }

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.276,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label${isMandatory ? '*' : ''}',
                style: GoogleFonts.inter(
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: showErrorColor
                      ? const Color(0xFFF44336)
                      : const Color(0xFF4B4B4B),
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Focus(
                child: Builder(
                  builder: (context) {
                    final isFocused = Focus.of(context).hasFocus;

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: label != "Ambient Temperature"
                            ? isFocused
                                ? showErrorColor == false
                                    ? [
                                        const BoxShadow(
                                          color: Color(0xA3002B5C),
                                          blurRadius: 4,
                                          offset: Offset(0, 0),
                                        ),
                                      ]
                                    : null
                                : null
                            : null,
                      ),
                      child: TextFormField(
                        keyboardType: label == "Ambient Temperature"
                            ? const TextInputType.numberWithOptions()
                            : TextInputType.text,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF212121),
                          height: 24 / 17,
                        ),
                        controller: controller,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: hintText ?? 'Enter here',
                          hintStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF979797),
                            fontSize: 17.0,
                            height: 24 / 17,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFFFFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: showErrorColor
                                  ? const Color(0xFFF44336)
                                  : const Color(0xFFD0D3D8),
                              width: 1.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: controller.text.isEmpty
                                  ? showErrorColor
                                      ? const Color(0xFFF44336)
                                      : const Color(0xFFD0D3D8)
                                  : const Color(0xFFD0D3D8),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: showErrorColor
                                  ? const Color(0xFFF44336)
                                  : const Color(0xFF002B5C),
                              width: 1.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFF44336),
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFF44336),
                              width: 1.0,
                            ),
                          ),
                          errorStyle: GoogleFonts.inter(
                            color: const Color(0xFFF44336),
                            fontSize: 12.0,
                            height: 10 / 12,
                          ),
                          suffixIcon: label == 'GPS Coordinates'
                              ? GestureDetector(
                                  onTap: _getCurrentLocation,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SvgPicture.asset(
                                      'lib/src/features/ex_inspections/assets/R-Icon1.svg',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      width: MediaQuery.of(context).size.width *
                                          0.06,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        readOnly: label == 'GPS Coordinates',
                        validator: (value) {
                          if (_isSubmitting &&
                              isMandatory &&
                              (value == null || value.isEmpty)) {
                            return '';
                          }
                          if (label == 'Ambient Temperature' &&
                              value != null &&
                              value.isNotEmpty) {
                            final regExp = RegExp(
                              r'^([-+]?\d{1,3})°C to ([-+]?\d{1,3})°C$',
                            );
                            if (!regExp.hasMatch(value)) {
                              return 'Format: -40°C to +55°C';
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                          updateError();

                          _isFieldValid = controller.text.isNotEmpty;
                          if (_isFieldValid) {
                            showErrorColor = true;
                          }
                          if (label == 'Ambient Temperature') {
                            String formattedValue = value;
                            if (formattedValue.endsWith(' ')) {
                              formattedValue = formattedValue.trimRight();
                              final tempInputPattern = RegExp(
                                r'^([-+]?\d{1,3})$',
                              );
                              isShowError = value.isEmpty ||
                                  !tempInputPattern.hasMatch(value);
                              if (formattedValue.contains('to')) {
                                final parts = formattedValue.split('to');
                                if (parts.length == 2) {
                                  final firstPart = parts[0].trim();
                                  var secondPart = parts[1].trim();
                                  if (tempInputPattern.hasMatch(secondPart) &&
                                      !secondPart.contains('°C')) {
                                    secondPart += '°C';
                                  }
                                  formattedValue = '$firstPart to $secondPart';
                                }
                              } else if (tempInputPattern.hasMatch(
                                    formattedValue,
                                  ) &&
                                  !formattedValue.contains('°C')) {
                                formattedValue += '°C to ';
                              }
                              controller.value = TextEditingValue(
                                text: formattedValue,
                                selection: TextSelection.fromPosition(
                                  TextPosition(offset: formattedValue.length),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMultipleFile(
    BuildContext context,
    TextEditingController controller,
    String fileOf,
    Function(String filePath) onFilePicked,
    int index,
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
      return;
    }
    if (file != null) {
      String path = await _processAndUploadMultipleFile(
        file,
        controller,
        fileOf,
        index,
      );
      onFilePicked(path);
    }
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

  Future<File> _compressImage(File xfile) async {
    File file = File(xfile.path);

    final fileSizeInBytes = await file.length();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    if (fileSizeInMB <= 2.0) {
      return file;
    }
    final targetPath =
        '${file.parent.path}/compressed_${file.path.split('/').last}';
    int quality = 90;
    if (fileSizeInMB > 4.0) {
      quality = 70;
    } else if (fileSizeInMB > 3.0) {
      quality = 75;
    } else if (fileSizeInMB > 2.5) {
      quality = 80;
    } else if (fileSizeInMB > 2.0) {
      quality = 85;
    }

    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    final File result = File(compressedFile!.path);
    return result;
  }

  Future<String> _processAndUploadMultipleFile(
    File file,
    TextEditingController controller,
    String fileOf,
    int index,
  ) async {
    if (index < 0) {
      index = 0;
    }
    final ext = file.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      // Only compress if file > 2MB
      file = await _compressImage(file);
    }

    String originalFileName = file.path.split('/').last;
    String fileExtension = originalFileName.split('.').last;

    String customFileNameBase = generateCustomMultipleFileName(fileOf, index);
    String customFileName = '$customFileNameBase.$fileExtension';

    controller.text = originalFileName.split('.').first;

    String customFilePath = '${file.parent.path}/$customFileName';
    await file.rename(customFilePath);
    _uploadFile(File(customFilePath), fileOf, index);

    return customFilePath;
  }

  String generateCustomMultipleFileName(String fileOf, int index) {
    String safeSubstring(String input, int length) {
      return (input.isNotEmpty)
          ? input
              .substring(0, input.length < length ? input.length : length)
              .toUpperCase()
          : '';
    }

    String prefix = fileOf == 'areaClassDrawAttach' ? 'ACDN' : 'ELDN';

    String fieldNamePart = safeSubstring(_selectedFieldName, 3);
    String platformPart = safeSubstring(_selectedPlatform, 3);
    if (fieldNamePart.isEmpty || platformPart.isEmpty) {
      return '';
    }
    String deckLevelPart;
    if (_selectedDeckLevel == null || _selectedDeckLevel.isEmpty) {
      deckLevelPart = 'ND'; // ND = No Deck
    } else if (_selectedDeckLevel == 'Main Deck') {
      deckLevelPart = 'MAD';
    } else if (_selectedDeckLevel == 'Mezzanine Deck') {
      deckLevelPart = 'MED';
    } else {
      List<String> deckLevelWords = _selectedDeckLevel.trim().split(
            RegExp(r'\s+'),
          );
      deckLevelPart = deckLevelWords.length > 1
          ? safeSubstring(deckLevelWords[0], 2) +
              safeSubstring(deckLevelWords[1], 1)
          : safeSubstring(_selectedDeckLevel, 1);
    }

    String result =
        '$prefix-$fieldNamePart-$platformPart-$deckLevelPart-${index + 1}';
    return result;
  }

  List<String> _getPlatformsByDeckLevel(
    Map<String, dynamic> locationDropDown,
    String deckLevel, {
    String? locationName,
  }) {
    final allLocations =
        (locationDropDown['locationDropDown'] as List<dynamic>);

    Iterable<dynamic> platformsIterable;

    if (locationName != null && locationName.isNotEmpty) {
      final loc = allLocations.firstWhere(
        (l) => l['name'] == locationName,
        orElse: () => null,
      );
      if (loc == null) return [];
      platformsIterable = (loc['platforms'] as List<dynamic>);
    } else {
      platformsIterable = allLocations.expand(
        (loc) => (loc['platforms'] as List<dynamic>),
      );
    }

    final matching = platformsIterable
        .where((p) {
          final areas = (p['area'] as List<dynamic>).map((a) => a.toString());
          return areas.contains(deckLevel);
        })
        .map((p) => p['platformName'].toString())
        .toSet()
        .toList();
    return matching;
  }

  List<String> _getPlatformsForFieldName(
    Map<String, dynamic> locationDropDown,
    String? fieldName,
  ) {
    final allLocations =
        (locationDropDown['locationDropDown'] as List<dynamic>);
    if (fieldName == null || fieldName.isEmpty) {
      return allLocations
          .expand(
            (loc) => (loc['platforms'] as List<dynamic>).map(
              (p) => p['platformName'].toString(),
            ),
          )
          .toSet()
          .toList();
    }
    final selectedLocation = allLocations.firstWhere(
      (loc) => loc['name'] == fieldName,
      orElse: () => null,
    );
    if (selectedLocation != null) {
      return (selectedLocation['platforms'] as List<dynamic>)
          .map((p) => p['platformName'].toString())
          .toList();
    }
    return [];
  }

  List<String> _getAreasForFieldName(
    Map<String, dynamic> locationDropDown,
    String? fieldName, {
    String? platformName,
  }) {
    final allLocations =
        (locationDropDown['locationDropDown'] as List<dynamic>);

    if ((fieldName == null || fieldName.isEmpty) &&
        (platformName == null || platformName.isEmpty)) {
      return allLocations
          .expand(
            (loc) => (loc['platforms'] as List<dynamic>).expand(
              (p) => (p['area'] as List<dynamic>),
            ),
          )
          .map((a) => a.toString())
          .toSet()
          .toList();
    }

    if ((fieldName == null || fieldName.isEmpty) &&
        platformName != null &&
        platformName.isNotEmpty) {
      final platform = allLocations
          .expand((loc) => (loc['platforms'] as List<dynamic>))
          .firstWhere(
            (p) => p['platformName'] == platformName,
            orElse: () => null,
          );
      if (platform != null) {
        return (platform['area'] as List<dynamic>)
            .map((a) => a.toString())
            .toSet()
            .toList();
      }
    }

    final location = allLocations.firstWhere(
      (loc) => loc['name'] == fieldName,
      orElse: () => null,
    );
    if (location != null) {
      if (platformName == null || platformName.isEmpty) {
        return (location['platforms'] as List<dynamic>)
            .expand((p) => (p['area'] as List<dynamic>))
            .map((a) => a.toString())
            .toSet()
            .toList();
      } else {
        final platform = (location['platforms'] as List<dynamic>).firstWhere(
          (p) => p['platformName'] == platformName,
          orElse: () => null,
        );
        if (platform != null) {
          return (platform['area'] as List<dynamic>)
              .map((a) => a.toString())
              .toSet()
              .toList();
        }
      }
    }
    return [];
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    bool isMandatory = false,
    bool disabled = false,
  }) {
    final bool showErrorColor =
        _isSubmitting && isMandatory && (value == null || value.isEmpty);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.276,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label${isMandatory ? '*' : ''}',
            style: GoogleFonts.inter(
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: showErrorColor
                  ? const Color(0xFFF44336)
                  : (disabled
                      ? const Color(0xFF999999)
                      : const Color(0xFF4B4B4B)),
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 8.0),
          ValueListenableBuilder<bool>(
            valueListenable: widget.isEditModeNotifier,
            builder: (context, isEditMode, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: widget.isEditAreaModeNotifier,
                builder: (context, isEditAreaMode, _) {
                  return FormField<String>(
                    key: ValueKey(value),
                    initialValue: value,
                    builder: (FormFieldState<String> state) {
                      String? selectedVal = value;
                      if (selectedVal != null && selectedVal.trim().isEmpty) {
                        selectedVal = null;
                      }
                      return SearchableDropdown(
                        value: selectedVal,
                        items: items,
                        onChanged: (newValue) {
                          state.didChange(newValue);
                          onChanged?.call(newValue);
                        },
                        isEditMode: isEditAreaMode && isEditMode,
                        isNotApplicable: disabled,
                        hasError: showErrorColor,
                      );
                    },
                    validator: (value) {
                      if (_isSubmitting &&
                          isMandatory &&
                          (value == null || value.isEmpty)) {
                        return '';
                      }
                      return null;
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    required bool isMandatory,
  }) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        bool showErrorColor = false;
        if (!_isSubmitting) {
          showErrorColor =
              _isSubmitting && isMandatory && controller.text.isEmpty;
        } else {
          showErrorColor = isMandatory && controller.text.isEmpty;
        }
        updateError() {
          setState(() {
            if (isMandatory) {
              showErrorColor = isMandatory && controller.text.trim().isEmpty;
            }
          });
        }

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.276,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label${isMandatory ? '*' : ''}',
                style: GoogleFonts.inter(
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: showErrorColor
                      ? const Color(0xFFF44336)
                      : const Color(0xFF4B4B4B),
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 8.0),
              ValueListenableBuilder<bool>(
                valueListenable: widget.isEditModeNotifier,
                builder: (context, isEditMode, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: widget.isEditAreaModeNotifier,
                    builder: (context, isEditAreaMode, _) {
                      return Focus(
                        child: Builder(
                          builder: (context) {
                            final isFocused = Focus.of(context).hasFocus;

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: label != "Ambient Temperature"
                                    ? isFocused
                                        ? !showErrorColor
                                            ? [
                                                const BoxShadow(
                                                  color: Color(0xA3002B5C),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 0),
                                                ),
                                              ]
                                            : null
                                        : null
                                    : null,
                              ),
                              child: TextFormField(
                                readOnly: !isEditAreaMode ||
                                    !isEditMode ||
                                    label == 'GPS Coordinates',
                                keyboardType: label == "Ambient Temperature"
                                    ? const TextInputType.numberWithOptions()
                                    : TextInputType.text,
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF212121),
                                  height: 24 / 17,
                                ),
                                controller: controller,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: hintText ?? 'Enter here',
                                  hintStyle: GoogleFonts.inter(
                                    fontWeight: FontWeight.w400,
                                    color: !isEditAreaMode
                                        ? const Color(0xFFBABABA)
                                        : !isEditMode
                                            ? const Color(0xFFBABABA)
                                            : const Color(0xFF979797),
                                    fontSize: 17.0,
                                    height: 24 / 17,
                                  ),
                                  filled: true,
                                  fillColor: !isEditAreaMode
                                      ? Colors.white
                                      : isEditMode
                                          ? Colors.white
                                          : const Color(0xFFFBFBFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: showErrorColor
                                          ? const Color(0xFFF44336)
                                          : const Color(0xFFD0D3D8),
                                      width: 1.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 12.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: controller.text.isEmpty
                                          ? showErrorColor
                                              ? const Color(0xFFF44336)
                                              : const Color(0xFFD0D3D8)
                                          : const Color(0xFFD0D3D8),
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: showErrorColor
                                          ? const Color(0xFFF44336)
                                          : const Color(0xFF002B5C),
                                      width: 1.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFF44336),
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFF44336),
                                      width: 1.0,
                                    ),
                                  ),
                                  errorStyle: GoogleFonts.inter(
                                    color: const Color(0xFFF44336),
                                    fontSize: 12.0,
                                  ),
                                  suffixIcon: label == 'GPS Coordinates'
                                      ? GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: isEditAreaMode
                                              ? _getCurrentLocation
                                              : isEditMode
                                                  ? _getCurrentLocation
                                                  : null,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: SvgPicture.asset(
                                              'lib/src/features/ex_inspections/assets/R-Icon1.svg',
                                              height: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.03,
                                              width: MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.06,
                                              color: !isEditAreaMode
                                                  ? const Color(0xFFBABABA)
                                                  : !isEditMode
                                                      ? const Color(0xFFBABABA)
                                                      : const Color(0xFF3B475B),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                validator: (value) {
                                  if (_isSubmitting &&
                                      isMandatory &&
                                      (value == null || value.isEmpty)) {
                                    return '';
                                  }
                                  if (label == 'Ambient Temperature' &&
                                      value != null &&
                                      value.isNotEmpty) {
                                    final regExp = RegExp(
                                      r'^([-+]?\d{1,3})°C to ([-+]?\d{1,3})°C$',
                                    );
                                    if (!regExp.hasMatch(value)) {
                                      return 'Format: -40°C to +55°C';
                                    }
                                  }
                                  return null;
                                },
                                onChanged: !isEditAreaMode
                                    ? null
                                    : !isEditMode
                                        ? null
                                        : (value) {
                                            setState(() {});
                                            updateError();
                                            _isFieldValid =
                                                controller.text.isNotEmpty;
                                            if (_isFieldValid) {
                                              showErrorColor = true;
                                            }

                                            if (label ==
                                                'Ambient Temperature') {
                                              String formattedValue = value;
                                              if (formattedValue
                                                  .endsWith(' ')) {
                                                formattedValue =
                                                    formattedValue.trimRight();
                                                final tempInputPattern = RegExp(
                                                  r'^([-+]?\d{1,3})$',
                                                );
                                                if (formattedValue
                                                    .contains('to')) {
                                                  final parts = formattedValue
                                                      .split('to');
                                                  if (parts.length == 2) {
                                                    final firstPart =
                                                        parts[0].trim();
                                                    var secondPart =
                                                        parts[1].trim();
                                                    if (tempInputPattern
                                                            .hasMatch(
                                                          secondPart,
                                                        ) &&
                                                        !secondPart.contains(
                                                          '°C',
                                                        )) {
                                                      secondPart += '°C';
                                                    }
                                                    formattedValue =
                                                        '$firstPart to $secondPart';
                                                  }
                                                } else if (tempInputPattern
                                                        .hasMatch(
                                                            formattedValue) &&
                                                    !formattedValue.contains(
                                                      '°C',
                                                    )) {
                                                  formattedValue += '°C to ';
                                                }
                                                controller.value =
                                                    TextEditingValue(
                                                  text: formattedValue,
                                                  selection: TextSelection
                                                      .fromPosition(
                                                    TextPosition(
                                                      offset:
                                                          formattedValue.length,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TextEditingController controller,
    String fileOf,
    int index,
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
                            _deleteFile(context, index, fileOf);
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

  String _getTextFieldValue(TextEditingController controller) {
    return controller.text.isEmpty ? '' : controller.text;
  }

  Future<String?> postAsset() async {
    Map<String, dynamic> functionalAreaMap = {
      'location': _selectedFieldName,
      'area': _selectedPlatform,
      'deckLevel': _selectedDeckLevel,
      'subArea': _getTextFieldValue(_subAreaController),
      'zone': _selectedZone,
      'locationGasGroup': selectedGasItems,
      'locationTClass': selectedTemperatureItems,
      'locationIpRating': selectedIPRatingItems,
      'locationLatitude': (_gpsCoordinatesController.text.contains(',')
          ? _gpsCoordinatesController.text.split(',')[0].trim()
          : ''), //_getTextFieldValue(_locationLatitude),
      'locationLongitude': (_gpsCoordinatesController.text.contains(',')
          ? _gpsCoordinatesController.text.split(',')[1].trim()
          : ''), //_getTextFieldValue(_locationLongtitude),
      'tAmbient': _getTextFieldValue(_ambientTemperatureController),
      'areaClassDrawNo': _areaClassDrawNo.whereType<String>().toList(),
      'areaClassDrawAttach': _areaClassDrawAttach.whereType<String>().toList(),
      'areaClassDrawAttachOrgName':
          _areaClassDrawAttachOrgName.whereType<String>().toList(),
      'eqpmtLytDrawNo': _eqpmtLytDrawNo.whereType<String>().toList(),
      'eqpmtLytDrawAttach': _eqpmtLytDrawAttach.whereType<String>().toList(),
      'eqpmtLytDrawAttachOrgName':
          _eqpmntLytDrawAttachOrgName.whereType<String>().toList(),
      'isActive': _isActive,
    };

    Map<String, dynamic> functionalAreaJson = {
      'functional_area_json': jsonEncode({'location': functionalAreaMap}),
    };
    final String? userType = await authUtils.getUserType();
    final String? locationId = (userType == 'onshore')
        ? await _dbHelper.saveFunctionalAreaOnshore(functionalAreaJson)
        : await _dbHelper.saveFunctionalArea(functionalAreaJson);
    // Map<String, dynamic> assetMap = asset.toJson();
    //       Map<String, dynamic> exRegisterJson = {
    //         'exregister_json': jsonEncode({'asset': assetMap})
    //       };

    (userType == 'onshore')
        ? await _dbHelper.updateExRegisterJsonLocationIdOnshore(
            int.parse(
              widget.exInspectionRequest.equipmentTagRequest?.assetId ?? '0',
            ),
            locationId!,
            functionalAreaMap,
          )
        : await _dbHelper.updateExRegisterJsonLocationId(
            int.parse(
              widget.exInspectionRequest.equipmentTagRequest?.assetId ?? '0',
            ),
            locationId!,
            functionalAreaMap,
          );

    return locationId;
  }

  // bool hasFunctionalAreaChanged(
  //   String? selectedFieldName,
  //   String? selectedPlatform,
  //   String? selectedDeckLevel,
  //   String subAreaValue,
  //   String? selectedZone,
  //   List<String> selectedGasItems,
  //   List<String> selectedTemperatureItems,
  //   List<String> selectedIPRatingItems,
  //   EquipmentTagRequest? equipmentTagRequest,
  // ) {
  //   // Get current latitude and longitude
  //   final currentLatitude = _gpsCoordinatesController.text.contains(',')
  //       ? _gpsCoordinatesController.text.split(',')[0].trim()
  //       : '';

  //   final currentLongitude = _gpsCoordinatesController.text.contains(',')
  //       ? _gpsCoordinatesController.text.split(',')[1].trim()
  //       : '';

  //   return selectedFieldName != equipmentTagRequest?.location ||
  //       selectedPlatform != equipmentTagRequest?.area ||
  //       selectedDeckLevel != equipmentTagRequest?.deckLevel ||
  //       subAreaValue != equipmentTagRequest?.subArea ||
  //       selectedZone != equipmentTagRequest?.zone ||
  //       !areListsEqual(
  //           selectedGasItems, equipmentTagRequest?.locationGasGroup ?? []) ||
  //       !areListsEqual(selectedTemperatureItems,
  //           equipmentTagRequest?.locationTClass ?? []) ||
  //       !areListsEqual(selectedIPRatingItems,
  //           equipmentTagRequest?.locationIpRating ?? []) ||
  //       currentLatitude != (equipmentTagRequest?.locationLatitude ?? '') ||
  //       currentLongitude != (equipmentTagRequest?.locationLongitude ?? '');
  // }

  bool areListsEqual(List<String?>? a, List<String?>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void onSubmitFunctionalArea({bool skipValidation = false}) async {
    setState(() {
      _isSubmitting = !skipValidation;
    });

    if (!skipValidation && !formKey.currentState!.validate()) {
      return;
    }
    // if (skipValidation) {
    //   return;
    // }
    // _areaClassDrawAttachOrgName =
    //     _areaClassificationDrawingController.text.isNotEmpty
    //         ? _areaClassificationDrawingController.text
    //         : _areaClassDrawNo?.split('.').first;
    // _eqpmntLytDrawAttachOrgName =
    //     _equipmentLayoutDrawingController.text.isNotEmpty
    //         ? _equipmentLayoutDrawingController.text
    //         : _eqpmtLytDrawNo?.split('.').first;
    _areaClassDrawAttachOrgName = List<String?>.generate(
      _areaClassificationDrawingController.length,
      (i) {
        final text = _areaClassificationDrawingController[i].text;
        if (text.isNotEmpty) {
          return text;
        } else if (_areaClassDrawAttachOrgName.length > i &&
            _areaClassDrawAttachOrgName[i] != null &&
            _areaClassDrawAttachOrgName[i]!.isNotEmpty) {
          return _areaClassDrawAttachOrgName[i]!.split('.').first;
        } else {
          return null;
        }
      },
    );
    _eqpmntLytDrawAttachOrgName = List<String?>.generate(
      _equipmentLayoutDrawingController.length,
      (i) {
        final text = _equipmentLayoutDrawingController[i].text;
        if (text.isNotEmpty) {
          return text;
        } else if (_eqpmntLytDrawAttachOrgName.length > i &&
            _eqpmntLytDrawAttachOrgName[i] != null &&
            _eqpmntLytDrawAttachOrgName[i]!.isNotEmpty) {
          return _eqpmntLytDrawAttachOrgName[i]!.split('.').first;
        } else {
          return null;
        }
      },
    );

    // _eqpmntLytDrawAttachOrgName = _equipmentLayoutDrawingController
    //     .map((controller) => controller.text)
    //     .toList();
    //  ||
    //     _selectedPlatform !=
    //         widget.exInspectionRequest.equipmentTagRequest?.area
    final currentLatitude = _gpsCoordinatesController.text.contains(',')
        ? _gpsCoordinatesController.text.split(',')[0].trim()
        : '';

    final currentLongitude = _gpsCoordinatesController.text.contains(',')
        ? _gpsCoordinatesController.text.split(',')[1].trim()
        : '';
    if (_selectedFieldName !=
            widget.exInspectionRequest.equipmentTagRequest?.location ||
        _selectedPlatform !=
            widget.exInspectionRequest.equipmentTagRequest?.area ||
        _selectedDeckLevel !=
            widget.exInspectionRequest.equipmentTagRequest?.deckLevel ||
        _getTextFieldValue(_subAreaController) !=
            widget.exInspectionRequest.equipmentTagRequest?.subArea ||
        _selectedZone != widget.exInspectionRequest.equipmentTagRequest?.zone ||
        !areListsEqual(
          selectedGasItems,
          widget.exInspectionRequest.equipmentTagRequest?.locationGasGroup ??
              [],
        ) ||
        !areListsEqual(
          selectedTemperatureItems,
          widget.exInspectionRequest.equipmentTagRequest?.locationTClass ?? [],
        ) ||
        !areListsEqual(
          selectedIPRatingItems,
          widget.exInspectionRequest.equipmentTagRequest?.locationIpRating ??
              [],
        ) ||
        !areListsEqual(
          widget.exInspectionRequest.functionalAreaRequest
                  ?.areaClassDrawAttachOrgName ??
              [],
          _areaClassDrawAttachOrgName,
        ) ||
        !areListsEqual(
          widget.exInspectionRequest.functionalAreaRequest
                  ?.eqpmtLytDrawAttachOrgName ??
              [],
          _eqpmntLytDrawAttachOrgName,
        ) ||
        currentLatitude !=
            (widget.exInspectionRequest.equipmentTagRequest?.locationLatitude ??
                '') ||
        currentLongitude !=
            (widget.exInspectionRequest.equipmentTagRequest
                    ?.locationLongitude ??
                '')) {
      if (widget.exInspectionRequest.equipmentTagRequest?.isDuplicate == true) {
        _locationId = await postAsset();
        if (!mounted) return;
        widget.exInspectionRequest.equipmentTagRequest?.locationId =
            _locationId.toString();
      } else {
        _locationId =
            widget.exInspectionRequest.equipmentTagRequest?.locationId ??
                _locationId;
      }
    } else {
      _locationId =
          widget.exInspectionRequest.equipmentTagRequest?.locationId ??
              _locationId;
    }

    if (!mounted) return;

    widget.exInspectionRequest.functionalAreaRequest = FunctionalAreaRequest(
      locationId: _locationId,
      location: _selectedFieldName,
      area: _selectedPlatform,
      deckLevel: _selectedDeckLevel,
      zone: _selectedZone,
      locationGasGroup: selectedGasItems,
      locationTClass: selectedTemperatureItems,
      locationIpRating: selectedIPRatingItems,
      subArea: _getTextFieldValue(_subAreaController),
      tAmbient: _getTextFieldValue(_ambientTemperatureController),
      areaClassDrawNo: _areaClassDrawNo.whereType<String>().toList(),
      areaClassDrawAttach: _areaClassDrawAttach.whereType<String>().toList(),
      areaClassDrawAttachOrgName:
          _areaClassDrawAttachOrgName.whereType<String>().toList(),
      eqpmtLytDrawNo: _eqpmtLytDrawNo.whereType<String>().toList(),
      eqpmtLytDrawAttach: _eqpmtLytDrawAttach.whereType<String>().toList(),
      eqpmtLytDrawAttachOrgName:
          _eqpmntLytDrawAttachOrgName.whereType<String>().toList(),
      locationLatitude: (_gpsCoordinatesController.text.contains(',')
          ? _gpsCoordinatesController.text.split(',')[0].trim()
          : ''),
      locationLongitude: (_gpsCoordinatesController.text.contains(',')
          ? _gpsCoordinatesController.text.split(',')[1].trim()
          : ''),
      isActive: _selectedAreaStatus == 'Active',
      areaStatus: _selectedAreaStatus ?? (_isActive ? 'Active' : 'In Active'),
    );
    if (!mounted) return;
    context.read<ExInspectionsBloc>().add(
          SubmitFunctionalArea(widget.exInspectionRequest),
        );
  }
}
