import 'dart:async';

import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/multi_select_dropdown.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/ex_inspection_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/searchable_dropdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../custom_widgets/nfc_tag_widget.dart';
import '../../bloc/ex_inspection_state.dart';

class EquipmentTagsStep extends StatefulWidget {
  final ExInspectionRequest exInspectionRequest;
  final bool isUpdate;
  final ValueNotifier<bool> isEditModeNotifier;
  const EquipmentTagsStep({
    super.key,
    required this.exInspectionRequest,
    required this.isUpdate,
    required this.isEditModeNotifier,
  });

  @override
  EquipmentTagsStepState createState() => EquipmentTagsStepState();
}

class EquipmentTagsStepState extends State<EquipmentTagsStep> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool rfidReadonly = true;
  bool nfcUsed = false;
  final FocusNode _rfidFocusNode = FocusNode();

  String _selectedDicipline = '';
  String _selectedDescription = '';
  String _selectedManufacturer = '';
  String _selectedAtexCategory = '';
  String _selectedEpl = '';
  String? _selectedProtectionStandard;
  String _selectedProtectionType = '';
  String? _selectedGasGroup;
  String? _selectedTClass;
  String? _selectedIpRating;
  String? _selectedSpecialCondition;
  String? _selectedEquipmentCategory;
  dynamic _selectedEquipmentStatus;
  String? _selectedCertificationBody;
  String _lastCustomCertBody = '';
  bool _isSubmitting = false;
  List<String> _filteredProtectionType = [];
  List<String> _filteredGasGroup = [];
  List<String> _filteredAtexCategoey = [];
  List<String> _filteredEPL = [];
  List<String> selectedAtexItems = [];
  List<String> selectedEPLItems = [];
  List<String> selectedProtectionTypeItems = [];
  List<String> selectedGasItems = [];
  List<String> selectedTClassItems = [];
  List<String> selectedIpRatingItems = [];
  List<String> selectedspecialConditionItems = [];

  final TextEditingController _rfidReferenceController =
      TextEditingController();
  final TextEditingController _ambientTemperatureController =
      TextEditingController();
  final TextEditingController _ambientTemperaturePlusController =
      TextEditingController();
  final TextEditingController _gpsCoordinatesController =
      TextEditingController();
  final TextEditingController _equipmentIdController = TextEditingController();
  final TextEditingController _cableIdController = TextEditingController();
  final TextEditingController _equipmentCategoryController =
      TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _certificationBodyController =
      TextEditingController();
  final TextEditingController _certificationNumberController =
      TextEditingController();
  final TextEditingController _oracleIdController = TextEditingController();
  final TextEditingController _locationLatitude = TextEditingController();
  final TextEditingController _locationLongtitude = TextEditingController();
  final TextEditingController _equipmentDescription = TextEditingController();
  ValueNotifier<dynamic> result = ValueNotifier(null);

  void clearFields() {
    setState(() {
      _isSubmitting = false;
      _rfidReferenceController.clear();
      _ambientTemperatureController.clear();
      _ambientTemperaturePlusController.clear();
      _gpsCoordinatesController.clear();
      _equipmentIdController.clear();
      _cableIdController.clear();
      _equipmentCategoryController.clear();
      _manufacturerController.clear();
      _typeController.clear();
      _serialNumberController.clear();
      _certificationBodyController.clear();
      _certificationNumberController.clear();
      _oracleIdController.clear();
      _selectedDicipline = '';
      _selectedDescription = '';
      _selectedManufacturer = '';
      _equipmentDescription.clear();
      _selectedAtexCategory = '';
      _selectedEpl = '';
      _selectedProtectionStandard = '';
      _selectedProtectionType = '';
      _selectedGasGroup = null;
      _selectedTClass = null;
      _selectedIpRating = null;
      _selectedSpecialCondition = null;
      _selectedEquipmentCategory = null;
      _selectedEquipmentStatus = 'Active';
      _selectedCertificationBody = null;
      selectedAtexItems = [];
      selectedEPLItems = [];
      selectedProtectionTypeItems = [];
      selectedGasItems = [];
      selectedTClassItems = [];
      selectedIpRatingItems = [];
      selectedspecialConditionItems = [];
      FocusScope.of(context).unfocus();
    });
    onSubmitEquipmentTag(skipValidation: true);
  }

  @override
  void initState() {
    super.initState();
    if (widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeValues();
    }
    context.read<ExInspectionsBloc>().add(FetchAllDropDwn());
  }

  @override
  void didUpdateWidget(covariant EquipmentTagsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exInspectionRequest != oldWidget.exInspectionRequest &&
        widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeValues();
    }
  }

  void _initializeValues() {
    final request = widget.exInspectionRequest.equipmentTagRequest;
    _rfidReferenceController.text = request?.rfidRef ?? '';
    _gpsCoordinatesController.text = request?.gpsCord ?? '';
    _selectedDicipline = request?.eqpmtCatg ?? '';
    _equipmentIdController.text = request?.eqpmtTag ?? '';
    _cableIdController.text = request?.cableId ?? '';
    _equipmentCategoryController.text = request?.equipmentCategory ?? '';
    _selectedEquipmentCategory = request?.equipmentCategory ?? '';
    _selectedEquipmentStatus = request?.areaStatus ??
        (request?.isActive == true ? 'Active' : 'In Active');
    _equipmentDescription.text = request?.description ?? '';
    _manufacturerController.text = request?.manufacturer ?? '';
    _typeController.text = request?.type ?? '';
    _serialNumberController.text = request?.serialNumber?.toString() ?? '';
    final loadedStd = request?.protectionStd?.toString();
    if (loadedStd != null && loadedStd.isNotEmpty) {
      _selectedProtectionStandard = loadedStd;
    } else {
      _selectedProtectionStandard = 'IEC';
    }
    //
    // _selectedAtexCategory = request?.atexCatg ?? '';
    // _selectedEpl = request?.epl ?? '';
    // _selectedProtectionType = request?.protectionType ?? '';
    // _selectedGasGroup = request?.equipmentGasGroup;
    // _selectedTClass = request?.equipmentTClass;
    // _selectedIpRating = request?.equipmentIpRating;

    selectedAtexItems = (request!.atexCatg.isEmpty ? [] : request.atexCatg);
    selectedEPLItems = (request.epl.isEmpty ? [] : request.epl);
    selectedProtectionTypeItems =
        (request.protectionType.isEmpty ? [] : request.protectionType);
    selectedGasItems =
        (request.equipmentGasGroup.isEmpty ? [] : request.equipmentGasGroup);
    selectedTClassItems =
        (request.equipmentTClass.isEmpty ? [] : request.equipmentTClass);
    selectedIpRatingItems =
        (request.equipmentIpRating.isEmpty ? [] : request.equipmentIpRating);
    //
    _certificationBodyController.text = request.certfnBody ?? '';
    _selectedCertificationBody = request.certfnBody;
    _lastCustomCertBody = request.certfnBody ?? '';
    _certificationNumberController.text = request.certfnNo ?? '';

    // if (request.tAmbient != null && request.tAmbient!.contains('to')) {
    //   final parts = request.tAmbient!.split('to');
    //   _ambientTemperatureController.text = parts[0].trim();
    //   _ambientTemperaturePlusController.text = parts[1].trim();
    // } else if (request.tAmbient == "Not Available") {
    //   _ambientTemperaturePlusController.text = '';
    //   _ambientTemperatureController.text = '';
    // } else {
    //   if (request.tAmbient != null && request.tAmbient!.contains('-')) {
    //     _ambientTemperatureController.text = request.tAmbient?.trim() ?? '';
    //   } else if (request.tAmbient != null && request.tAmbient!.contains('+')) {
    //     _ambientTemperaturePlusController.text = '';
    //   } else {
    //     _ambientTemperaturePlusController.text = '';
    //     _ambientTemperatureController.text = '';
    //   }
    // }
    if (request.tAmbientEquip != null && request.tAmbientEquip != "null") {
      _ambientTemperatureController.text =
          request.tAmbientEquip.toString().trim();
    } else {
      _ambientTemperatureController.text = "Not Available";
    }

    _selectedSpecialCondition = request.specialCond;
    _oracleIdController.text =
        request.oracleId == "null" ? "" : request.oracleId ?? '';
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

  Future<void> updateAmbientTemperature({bool? clearCollection}) async {
    if (clearCollection == true) {
      setState(() {
        _ambientTemperatureController.text = 'Not Available';
        // _ambientTemperatureController.text = '';
        // _ambientTemperaturePlusController.text = '';
      });
    }
    //  else if (_ambientTemperaturePlusController.text.trim().isEmpty &&
    //     _ambientTemperatureController.text.trim().isEmpty &&
    //     _isSubmitting) {
    //   setState(() {
    //     _ambientTemperatureController.text = 'Not Available';
    //     _ambientTemperatureController.text = '';
    //     _ambientTemperaturePlusController.text = '';
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExInspectionsBloc, ExInspectionsState>(
      listener: (context, state) {
        if (state is ExInspectionSuccess) {
          updateAmbientTemperature(clearCollection: state.clearFlag);

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
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Column(
                    children: [_buildForm(state.allDropDowns ?? {})],
                  ),
                ),
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

  Widget _buildForm(Map<String, dynamic> getAllDropDowns) {
    final rawExResiter = getAllDropDowns['result']?['exResiterDropDown'];
    final exRegisterDropDown = (rawExResiter != null &&
            rawExResiter is List &&
            rawExResiter.isNotEmpty &&
            rawExResiter[0] is Map)
        ? rawExResiter[0] as Map<String, dynamic>
        : <String, dynamic>{};

    final discipline = (exRegisterDropDown['discipline'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        ['Electrical', 'Instrumentation', 'Mechanical'];

    Map<String, dynamic> protectionStandardMap = {};
    if (exRegisterDropDown['protectionStandard'] != null &&
        exRegisterDropDown['protectionStandard'] is List &&
        (exRegisterDropDown['protectionStandard'] as List).isNotEmpty &&
        exRegisterDropDown['protectionStandard'][0] is Map) {
      protectionStandardMap = Map<String, dynamic>.from(
          exRegisterDropDown['protectionStandard'][0] as Map);
    }
    if (protectionStandardMap.isEmpty) {
      protectionStandardMap =
          Map<String, dynamic>.from(_defaultProtectionStandardMap);
    }

    final List<String> availableStandards = [];
    for (final key in protectionStandardMap.keys) {
      final strKey = key.toString();
      if (!availableStandards.contains(strKey) && strKey != 'Not Available') {
        availableStandards.add(strKey);
      }
    }
    if (availableStandards.isEmpty) {
      availableStandards.addAll(['IEC', 'NEC', 'ATEX', 'Not Applicable']);
    }

    if (_selectedProtectionStandard == null ||
        _selectedProtectionStandard!.isEmpty) {
      _selectedProtectionStandard =
          availableStandards.contains('IEC') ? 'IEC' : availableStandards.first;
    } else if (!availableStandards.contains(_selectedProtectionStandard)) {
      final match = availableStandards.firstWhere(
        (s) => s.toLowerCase() == _selectedProtectionStandard!.toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        _selectedProtectionStandard = match;
      } else {
        availableStandards.add(_selectedProtectionStandard!);
      }
    }

    _filteredProtectionType = _getProtectionTypeForProtectionStandard(
      protectionStandardMap,
      _selectedProtectionStandard,
      exRegisterDropDown,
    );
    _filteredGasGroup = _getGasGroupForProtectionStandard(
      protectionStandardMap,
      _selectedProtectionStandard,
      exRegisterDropDown,
    );
    _filteredAtexCategoey = _getAtexCategoryProtectionStandard(
      protectionStandardMap,
      _selectedProtectionStandard,
      exRegisterDropDown,
    );
    _filteredEPL = _getEPLProtectionStandard(
      protectionStandardMap,
      _selectedProtectionStandard,
      exRegisterDropDown,
    );
    final ipRating = (exRegisterDropDown['ipRating'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [
          'IP54',
          'IP55',
          'IP56',
          'IP65',
          'IP66',
          'IP67',
          'IP68',
          'Not Applicable'
        ];

    final specialCondition =
        (exRegisterDropDown['specialCondition'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [
              'None',
              'X - Specific Condition',
              'U - Ex Component',
              'Not Applicable'
            ];

    final tClass = (exRegisterDropDown['temperatureClass'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'Not Applicable'];

    final descriptions = (exRegisterDropDown['equipementDescription']
                as List<dynamic>?)
            ?.map((item) => item.toString())
            .where((item) =>
                item != 'Others' && !item.toLowerCase().startsWith('other ('))
            .toList() ??
        [];
    if (!descriptions.contains('Others')) {
      descriptions.insert(0, 'Others');
    }

    final filteredEquipmentCategory = (exRegisterDropDown['equipmentCategory']
                as List<dynamic>?)
            ?.map((item) => item.toString())
            .where((item) =>
                item != 'Others' && !item.toLowerCase().startsWith('other ('))
            .toList() ??
        [];
    if (!filteredEquipmentCategory.contains('Others')) {
      filteredEquipmentCategory.insert(0, 'Others');
    }

    final manufacturers = (exRegisterDropDown['manufacturer'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .where((item) =>
                item != 'Others' && !item.toLowerCase().startsWith('other ('))
            .toList() ??
        [];
    if (!manufacturers.contains('Others')) {
      manufacturers.insert(0, 'Others');
    }

    List<String> certificationBody = (exRegisterDropDown['certificationBody']
                as List<dynamic>?)
            ?.map((item) => item.toString())
            .where((item) => item != 'Others' && !item.startsWith('Other ('))
            .toList() ??
        [];
    if (certificationBody.isEmpty) {
      certificationBody = [
        'Baseefa',
        'CML',
        'DEMKO',
        'FM',
        'INMETRO',
        'ITACS',
        'KEMA',
        'LCIE',
        'NEPSI',
        'PTB',
        'SIRA',
        'TR CU',
        'TUV',
        'UL',
        'UL DEMKO',
      ];
    }
    if (!certificationBody.contains('Others')) {
      certificationBody.insert(0, 'Others');
    }

    final areaStatusList = (exRegisterDropDown['areaStatus'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        ['Active', 'In Active'];

    if (_selectedDescription.isEmpty) {
      final loadedDesc = _equipmentDescription.text;
      if (loadedDesc.isNotEmpty) {
        if (descriptions.contains(loadedDesc)) {
          _selectedDescription = loadedDesc;
        } else {
          _selectedDescription = 'Others';
        }
      }
    } else if (!descriptions.contains(_selectedDescription) &&
        _selectedDescription != 'Others') {
      _equipmentDescription.text = _selectedDescription;
      _selectedDescription = 'Others';
    }

    if (_selectedManufacturer.isEmpty) {
      final loadedMan = _manufacturerController.text;
      if (loadedMan.isNotEmpty) {
        if (manufacturers.contains(loadedMan)) {
          _selectedManufacturer = loadedMan;
        } else {
          _selectedManufacturer = 'Others';
        }
      }
    } else if (!manufacturers.contains(_selectedManufacturer) &&
        _selectedManufacturer != 'Others') {
      _manufacturerController.text = _selectedManufacturer;
      _selectedManufacturer = 'Others';
    }

    if (_selectedEquipmentCategory == null ||
        _selectedEquipmentCategory!.isEmpty) {
      final loadedCat = _equipmentCategoryController.text;
      if (loadedCat.isNotEmpty) {
        if (filteredEquipmentCategory.contains(loadedCat)) {
          _selectedEquipmentCategory = loadedCat;
        } else {
          _selectedEquipmentCategory = 'Others';
        }
      }
    } else if (!filteredEquipmentCategory
            .contains(_selectedEquipmentCategory) &&
        _selectedEquipmentCategory != 'Others') {
      _equipmentCategoryController.text = _selectedEquipmentCategory!;
      _selectedEquipmentCategory = 'Others';
    }

    if (_selectedCertificationBody == null ||
        _selectedCertificationBody!.isEmpty) {
      final loadedCertBody = _certificationBodyController.text;
      if (loadedCertBody.isNotEmpty) {
        if (certificationBody.contains(loadedCertBody)) {
          _selectedCertificationBody = loadedCertBody;
        } else {
          _selectedCertificationBody = 'Others';
        }
      }
    } else if (!certificationBody.contains(_selectedCertificationBody) &&
        _selectedCertificationBody != 'Others') {
      _certificationBodyController.text = _selectedCertificationBody!;
      _selectedCertificationBody = 'Others';
    }

    return Form(
      key: formKey,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Wrap(
            spacing: 24.0,
            runSpacing: 24.0,
            children: [
              // _buildLabeledTextField(
              //   label: 'RFID Reference',
              //   controller: _rfidReferenceController,
              // ),
              _buildRfidTextField(
                label: 'RFID Reference',
                controller: _rfidReferenceController,
              ),
              _buildLabeledTextField(
                label: 'GPS Coordinates',
                controller: _gpsCoordinatesController,
              ),
              _buildLabeledDropdownField(
                label: 'Discipline',
                value: _selectedDicipline,
                items: discipline,
                onChanged: (value) {
                  setState(() {
                    _selectedDicipline = value!;
                  });
                },
                isMandatory: true,
              ),
              _buildLabeledTextField(
                label: 'Equipment Tag Number',
                controller: _equipmentIdController,
              ),

              _selectedDescription == 'Others'
                  ? _buildLabeledTextField(
                      label: 'Equipment Description',
                      controller: _equipmentDescription,
                      isMandatory: true,
                      hintText: 'Type New Description',
                      onSwitchToList: () {
                        setState(() {
                          _selectedDescription = '';
                          _equipmentDescription.clear();
                        });
                      },
                    )
                  : _buildLabeledDropdownField(
                      label: 'Equipment Description',
                      value: _selectedDescription.isEmpty
                          ? null
                          : _selectedDescription,
                      items: descriptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedDescription = value ?? '';
                          if (_selectedDescription == 'Others' ||
                              _selectedDescription ==
                                  'Other (New Description to be added)') {
                            _selectedDescription = 'Others';
                            _equipmentDescription.clear();
                          } else {
                            _equipmentDescription.text = _selectedDescription;
                          }
                        });
                      },
                      isMandatory: true,
                    ),
              _selectedEquipmentCategory == 'Others'
                  ? _buildLabeledTextField(
                      label: 'Equipment Category',
                      controller: _equipmentCategoryController,
                      hintText: 'Type New Category',
                      onSwitchToList: () {
                        setState(() {
                          _selectedEquipmentCategory = null;
                          _equipmentCategoryController.clear();
                        });
                      },
                    )
                  : _buildLabeledDropdownField(
                      label: 'Equipment Category',
                      value: _selectedEquipmentCategory,
                      items: filteredEquipmentCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedEquipmentCategory = value;
                          if (_selectedEquipmentCategory == 'Others') {
                            _equipmentCategoryController.clear();
                          } else {
                            _equipmentCategoryController.text =
                                _selectedEquipmentCategory ?? '';
                          }
                        });
                      },
                    ),
              _selectedManufacturer == 'Others'
                  ? _buildLabeledTextField(
                      label: 'Equipment Manufacturer',
                      controller: _manufacturerController,
                      hintText: 'Type New Manufacturer',
                      onSwitchToList: () {
                        setState(() {
                          _selectedManufacturer = '';
                          _manufacturerController.clear();
                        });
                      },
                    )
                  : _buildLabeledDropdownField(
                      label: 'Equipment Manufacturer',
                      value: _selectedManufacturer.isEmpty
                          ? null
                          : _selectedManufacturer,
                      items: manufacturers,
                      onChanged: (value) {
                        setState(() {
                          _selectedManufacturer = value ?? '';
                          if (_selectedManufacturer == 'Others') {
                            _manufacturerController.clear();
                          } else {
                            _manufacturerController.text =
                                _selectedManufacturer;
                          }
                        });
                      },
                    ),
              _buildLabeledTextField(
                label: 'Equipment Type/Model',
                controller: _typeController,
              ),
              _buildLabeledTextField(
                label: 'Equipment Serial Number',
                controller: _serialNumberController,
              ),

              _buildLabeledDropdownField(
                label: 'Protection Standard',
                value: _selectedProtectionStandard,
                items: availableStandards,
                onChanged: (value) {
                  setState(() {
                    if (value != _selectedProtectionStandard) {
                      selectedAtexItems = [];
                      selectedEPLItems = [];
                      selectedProtectionTypeItems = [];
                      selectedGasItems = [];
                      selectedTClassItems = [];
                      selectedIpRatingItems = [];
                      selectedspecialConditionItems = [];
                      _selectedAtexCategory = '';
                      _selectedEpl = '';
                      _selectedProtectionType = '';
                      _selectedGasGroup = null;
                      _selectedTClass = null;
                      _selectedIpRating = null;
                    }
                    _selectedProtectionStandard = value!;
                    _filteredProtectionType =
                        _getProtectionTypeForProtectionStandard(
                      protectionStandardMap,
                      _selectedProtectionStandard,
                      exRegisterDropDown,
                    );
                    _filteredGasGroup = _getGasGroupForProtectionStandard(
                      protectionStandardMap,
                      _selectedProtectionStandard,
                      exRegisterDropDown,
                    );
                    _filteredAtexCategoey = _getAtexCategoryProtectionStandard(
                      protectionStandardMap,
                      _selectedProtectionStandard,
                      exRegisterDropDown,
                    );
                    _filteredEPL = _getEPLProtectionStandard(
                      protectionStandardMap,
                      _selectedProtectionStandard,
                      exRegisterDropDown,
                    );
                  });
                },
                isMandatory: true,
              ),
              MultiSelectDropdown(
                label: 'Atex Category (if applicable)',
                items: _filteredAtexCategoey,
                selectedItems: selectedAtexItems,
                isSubmitting: _isSubmitting,
                selectedItemString: _selectedAtexCategory,
                onChanged: (value) {
                  setState(() {
                    selectedAtexItems = value;
                    _selectedAtexCategory =
                        value.isEmpty ? '' : value.join(', ');
                  });
                },
                isMandatory: true,
                isEditModeNotifier: widget.isEditModeNotifier,
              ),
              MultiSelectDropdown(
                label: 'EPL',
                items: _filteredEPL,
                selectedItems: selectedEPLItems,
                isSubmitting: _isSubmitting,
                selectedItemString: _selectedEpl,
                onChanged: (value) {
                  setState(() {
                    selectedEPLItems = value;
                    _selectedEpl = value.isEmpty ? '' : value.join(', ');
                  });
                  // Zone validation
                  final zone = (widget.exInspectionRequest.functionalAreaRequest
                              ?.zone.isNotEmpty ==
                          true)
                      ? widget.exInspectionRequest.functionalAreaRequest!.zone
                      : (widget.exInspectionRequest.equipmentTagRequest?.zone ??
                          '');
                  if (zone.isNotEmpty && value.isNotEmpty) {
                    final invalidEPL = _getInvalidEPLForZone(zone, value);
                    if (invalidEPL != null) {
                      Fluttertoast.showToast(
                        msg:
                            'EPL "$invalidEPL" is not suitable for $zone. Please select an appropriate EPL.',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  }
                },
                isMandatory: true,
                isEditModeNotifier: widget.isEditModeNotifier,
              ),
              MultiSelectDropdown(
                label: 'Protection Type',
                items: _filteredProtectionType,
                selectedItems: selectedProtectionTypeItems,
                isSubmitting: _isSubmitting,
                selectedItemString: _selectedProtectionType,
                onChanged: (value) {
                  setState(() {
                    selectedProtectionTypeItems = value;
                    _selectedProtectionType =
                        value.isEmpty ? '' : value.join(', ');
                  });
                  // Zone validation
                  final zone = (widget.exInspectionRequest.functionalAreaRequest
                              ?.zone.isNotEmpty ==
                          true)
                      ? widget.exInspectionRequest.functionalAreaRequest!.zone
                      : (widget.exInspectionRequest.equipmentTagRequest?.zone ??
                          '');
                  if (zone.isNotEmpty && value.isNotEmpty) {
                    final invalidType =
                        _getInvalidProtectionTypeForZone(zone, value);
                    if (invalidType != null) {
                      Fluttertoast.showToast(
                        msg:
                            'Protection Type "$invalidType" is not suitable for $zone.',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  }
                },
                isMandatory: true,
                isEditModeNotifier: widget.isEditModeNotifier,
              ),
              MultiSelectDropdown(
                label: 'Gas Group',
                items: _filteredGasGroup,
                selectedItems: selectedGasItems,
                isSubmitting: _isSubmitting,
                selectedItemString: _selectedGasGroup,
                onChanged: (value) {
                  setState(() {
                    selectedGasItems = value;
                    _selectedGasGroup = value.isEmpty ? null : value.join(', ');
                  });
                  // Gas Group compatibility validation against area gas group
                  final areaGasGroups = (widget
                              .exInspectionRequest
                              .functionalAreaRequest
                              ?.locationGasGroup
                              .isNotEmpty ==
                          true)
                      ? widget.exInspectionRequest.functionalAreaRequest!
                          .locationGasGroup
                      : (widget.exInspectionRequest.equipmentTagRequest
                              ?.locationGasGroup ??
                          []);
                  if (areaGasGroups.isNotEmpty && value.isNotEmpty) {
                    final warning =
                        _getGasGroupValidationWarning(areaGasGroups, value);
                    if (warning != null) {
                      Fluttertoast.showToast(
                        msg: warning,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  }
                },
                isMandatory: true,
                isEditModeNotifier: widget.isEditModeNotifier,
              ),
              MultiSelectDropdown(
                label: 'Temperature Class',
                items: tClass,
                selectedItems: selectedTClassItems,
                isSubmitting: _isSubmitting,
                selectedItemString: _selectedTClass,
                onChanged: (value) {
                  setState(() {
                    selectedTClassItems = value;
                    _selectedTClass = value.isEmpty ? null : value.join(', ');
                  });
                },
                isMandatory: true,
                isEditModeNotifier: widget.isEditModeNotifier,
              ),
              MultiSelectDropdown(
                label: 'IP Rating',
                items: ipRating,
                selectedItems: selectedIpRatingItems,
                isSubmitting: _isSubmitting,
                selectedItemString: _selectedIpRating,
                onChanged: (value) {
                  setState(() {
                    selectedIpRatingItems = value;
                    _selectedIpRating = value.isEmpty ? null : value.join(', ');
                  });
                },
                isMandatory: true,
                isEditModeNotifier: widget.isEditModeNotifier,
              ),

              _selectedCertificationBody == 'Others'
                  ? _buildLabeledTextField(
                      label: 'Certification Body',
                      controller: _certificationBodyController,
                      hintText: 'Type New Certification Body',
                      onSwitchToList: () {
                        setState(() {
                          _selectedCertificationBody = null;
                          _certificationBodyController.clear();
                        });
                      },
                    )
                  : _buildLabeledDropdownField(
                      label: 'Certification Body',
                      value: _selectedCertificationBody,
                      items: certificationBody,
                      onChanged: (value) {
                        setState(() {
                          final String oldPrefixText =
                              _selectedCertificationBody ?? '';
                          _selectedCertificationBody = value;
                          if (_selectedCertificationBody == 'Others') {
                            _certificationBodyController.clear();
                          } else {
                            final String newPrefixText = value ?? '';
                            _certificationBodyController.text = value ?? '';
                            _updateCertificationNumberPrefix(
                                oldPrefixText, newPrefixText);
                          }
                        });
                      },
                    ),
              _buildLabeledTextField(
                label: 'Certification Number',
                controller: _certificationNumberController,
              ),
              // _buildTAmbientLabeledTextField(
              //   label: 'Ambient Temperature',
              //   controllerMinus: _ambientTemperatureController,
              //   controllerPlus: _ambientTemperaturePlusController,
              //   hintText: 'Min°C to Max°C',
              // ),
              _buildLabeledAMTextField(
                label: 'Ambient Temperature',
                controller: _ambientTemperatureController,
                hintText: 'Min°C to Max°C',
              ),

              _buildLabeledTextField(
                label: 'Cable Tag Number',
                controller: _cableIdController,
              ),
              _buildLabeledTextField(
                label: 'Oracle ID',
                controller: _oracleIdController,
              ),
              _buildLabeledDropdownField(
                label: 'Special Condition',
                value: _selectedSpecialCondition,
                items: specialCondition,
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialCondition = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Equipment Status',
                value: _selectedEquipmentStatus,
                items: areaStatusList,
                onChanged: (value) {
                  setState(() {
                    _selectedEquipmentStatus = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const Map<String, Map<String, List<String>>>
      _defaultProtectionStandardMap = {
    'IEC': {
      'atexCategory': [
        '1G',
        '2G',
        '3G',
        '1D',
        '2D',
        '3D',
        'M1',
        'M2',
        'Not Applicable'
      ],
      'epl': ['Ga', 'Gb', 'Gc', 'Da', 'Db', 'Dc', 'Ma', 'Mb', 'Not Applicable'],
      'protectionType': [
        'Ex d',
        'Ex db',
        'Ex e',
        'Ex eb',
        'Ex ec',
        'Ex ia',
        'Ex ib',
        'Ex ic',
        'Ex m',
        'Ex ma',
        'Ex mb',
        'Ex mc',
        'Ex nA',
        'Ex nC',
        'Ex nR',
        'Ex o',
        'Ex ob',
        'Ex oc',
        'Ex p',
        'Ex px',
        'Ex py',
        'Ex pz',
        'Ex pxb',
        'Ex pyb',
        'Ex pzc',
        'Ex q',
        'Ex qb',
        'Ex s',
        'Ex op is',
        'Ex op pr',
        'Ex op sh',
        'Ex ta',
        'Ex tb',
        'Ex tc',
        'Ex ia D',
        'Ex ib D',
        'Ex ma D',
        'Ex mb D',
        'Ex pD',
        'Ex tD',
        'Not Applicable',
        'Others'
      ],
      'gasGroup': [
        'I',
        'IIA',
        'IIB',
        'IIC',
        'IIIA',
        'IIIB',
        'IIIC',
        'Not Applicable'
      ],
      'temperatureClass': ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'Not Applicable']
    },
    'ATEX': {
      'atexCategory': [
        '1G',
        '2G',
        '3G',
        '1D',
        '2D',
        '3D',
        'M1',
        'M2',
        'Not Applicable'
      ],
      'epl': ['Ga', 'Gb', 'Gc', 'Da', 'Db', 'Dc', 'Ma', 'Mb', 'Not Applicable'],
      'protectionType': [
        'Ex d',
        'Ex db',
        'Ex e',
        'Ex eb',
        'Ex ec',
        'Ex ia',
        'Ex ib',
        'Ex ic',
        'Ex m',
        'Ex ma',
        'Ex mb',
        'Ex mc',
        'Ex nA',
        'Ex nC',
        'Ex nR',
        'Ex o',
        'Ex ob',
        'Ex oc',
        'Ex p',
        'Ex px',
        'Ex py',
        'Ex pz',
        'Ex pxb',
        'Ex pyb',
        'Ex pzc',
        'Ex q',
        'Ex qb',
        'Ex s',
        'Ex op is',
        'Ex op pr',
        'Ex op sh',
        'Ex ta',
        'Ex tb',
        'Ex tc',
        'Ex ia D',
        'Ex ib D',
        'Ex ma D',
        'Ex mb D',
        'Ex pD',
        'Ex tD',
        'Not Applicable',
        'Others'
      ],
      'gasGroup': [
        'I',
        'IIA',
        'IIB',
        'IIC',
        'IIIA',
        'IIIB',
        'IIIC',
        'Not Applicable'
      ],
      'temperatureClass': ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'Not Applicable']
    },
    'NEC': {
      'atexCategory': ['Not Applicable'],
      'epl': [
        'Class I, Div 1',
        'Class I, Div 2',
        'Class II, Div 1',
        'Class II, Div 2',
        'Class III, Div 1',
        'Class III, Div 2',
        'Zone 0',
        'Zone 1',
        'Zone 2',
        'Zone 20',
        'Zone 21',
        'Zone 22',
        'Ga',
        'Gb',
        'Gc',
        'Da',
        'Db',
        'Dc',
        'Not Applicable'
      ],
      'protectionType': [
        'Explosionproof (XP)',
        'Dust-Ignitionproof (DIP)',
        'Intrinsically Safe (IS)',
        'Non-Incendive (NI)',
        'Purged/Pressurized (Type X)',
        'Purged/Pressurized (Type Y)',
        'Purged/Pressurized (Type Z)',
        'Oil-Immersed',
        'Hermetically Sealed',
        'Encapsulated',
        'Class I, Div 1',
        'Class I, Div 2',
        'Class II, Div 1',
        'Class II, Div 2',
        'Class III',
        'Not Applicable',
        'Others'
      ],
      'gasGroup': [
        'Group A',
        'Group B',
        'Group C',
        'Group D',
        'Group E',
        'Group F',
        'Group G',
        'Class I (A, B, C, D)',
        'Class II (E, F, G)',
        'Class III',
        'Not Applicable'
      ],
      'temperatureClass': [
        'T1',
        'T2',
        'T2A',
        'T2B',
        'T2C',
        'T2D',
        'T3',
        'T3A',
        'T3B',
        'T3C',
        'T4',
        'T4A',
        'T5',
        'T6',
        'Not Applicable'
      ]
    },
    'Not Applicable': {
      'atexCategory': ['Not Applicable'],
      'epl': ['Not Applicable'],
      'protectionType': ['Not Applicable'],
      'gasGroup': ['Not Applicable'],
      'temperatureClass': ['Not Applicable']
    },
    'Not Available': {
      'atexCategory': ['Not Available', 'Not Applicable'],
      'epl': ['Not Available', 'Not Applicable'],
      'protectionType': ['Not Available', 'Not Applicable'],
      'gasGroup': ['Not Available', 'Not Applicable'],
      'temperatureClass': ['Not Available', 'Not Applicable']
    }
  };

  Map<String, dynamic>? _getStandardData(
    Map<String, dynamic> protectionStandardMap,
    String? standardKey,
  ) {
    if (standardKey == null || standardKey.trim().isEmpty) {
      return (protectionStandardMap['IEC'] as Map<String, dynamic>?) ??
          (protectionStandardMap['IEC / ATEX'] as Map<String, dynamic>?) ??
          _defaultProtectionStandardMap['IEC'];
    }
    final cleanKey = standardKey.trim();
    if (protectionStandardMap.containsKey(cleanKey)) {
      final val = protectionStandardMap[cleanKey];
      if (val is Map<String, dynamic>) return val;
      if (val is Map) return Map<String, dynamic>.from(val);
    }
    final lower = cleanKey.toLowerCase();
    for (final entry in protectionStandardMap.entries) {
      final entryLower = entry.key.toLowerCase();
      if (entryLower == lower) {
        if (entry.value is Map<String, dynamic>) {
          return entry.value as Map<String, dynamic>;
        }
        if (entry.value is Map) {
          return Map<String, dynamic>.from(entry.value as Map);
        }
      }
    }
    for (final entry in _defaultProtectionStandardMap.entries) {
      final entryLower = entry.key.toLowerCase();
      if (entryLower == lower) {
        return entry.value;
      }
    }
    return _defaultProtectionStandardMap['IEC'];
  }

  List<String> _getProtectionTypeForProtectionStandard(
    Map<String, dynamic> protectionStandardMap,
    String? standardKey, [
    Map<String, dynamic>? exRegisterDropDown,
  ]) {
    final standard = _getStandardData(protectionStandardMap, standardKey);
    if (standard != null && standard['protectionType'] != null) {
      final list = (standard['protectionType'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      if (list.isNotEmpty) return list;
    }
    if (exRegisterDropDown != null &&
        exRegisterDropDown['protectionType'] != null) {
      final list = (exRegisterDropDown['protectionType'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      if (list.isNotEmpty) return list;
    }
    return _defaultProtectionStandardMap['IEC']!['protectionType']!;
  }

  List<String> _getGasGroupForProtectionStandard(
    Map<String, dynamic> protectionStandardMap,
    String? standardKey, [
    Map<String, dynamic>? exRegisterDropDown,
  ]) {
    final standard = _getStandardData(protectionStandardMap, standardKey);
    if (standard != null && standard['gasGroup'] != null) {
      final list = (standard['gasGroup'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      if (list.isNotEmpty) return list;
    }
    if (exRegisterDropDown != null && exRegisterDropDown['gasGroup'] != null) {
      final list = (exRegisterDropDown['gasGroup'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      if (list.isNotEmpty) return list;
    }
    return _defaultProtectionStandardMap['IEC']!['gasGroup']!;
  }

  List<String> _getAtexCategoryProtectionStandard(
    Map<String, dynamic> protectionStandardMap,
    String? standardKey, [
    Map<String, dynamic>? exRegisterDropDown,
  ]) {
    final standard = _getStandardData(protectionStandardMap, standardKey);
    if (standard != null && standard['atexCategory'] != null) {
      final list = (standard['atexCategory'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      if (list.isNotEmpty) return list;
    }
    if (exRegisterDropDown != null &&
        exRegisterDropDown['atexCategory'] != null) {
      final list = (exRegisterDropDown['atexCategory'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      if (list.isNotEmpty) return list;
    }
    return _defaultProtectionStandardMap['IEC']!['atexCategory']!;
  }

  List<String> _getEPLProtectionStandard(
    Map<String, dynamic> protectionStandardMap,
    String? standardKey, [
    Map<String, dynamic>? exRegisterDropDown,
  ]) {
    final standard = _getStandardData(protectionStandardMap, standardKey);
    if (standard != null && standard['epl'] != null) {
      final list = (standard['epl'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      if (list.isNotEmpty) return list;
    }
    if (exRegisterDropDown != null && exRegisterDropDown['epl'] != null) {
      final list = (exRegisterDropDown['epl'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      if (list.isNotEmpty) return list;
    }
    return _defaultProtectionStandardMap['IEC']!['epl']!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Zone-based Validation Helpers (IEC 60079 / IECEx standard)
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns true if all selected protection types are valid for the given zone.
  /// Returns the first invalid protection type found, or null if all valid.
  String? _getInvalidProtectionTypeForZone(
      String zone, List<String> selectedTypes) {
    // Zone 0 only allows Ex ia and Ex ma
    const zone0Allowed = [
      'Ex ia',
      'Ex ma',
      'Ex ia (Ga)',
      'Ex ma (Ga)',
    ];
    // Zone 20 only allows Ex ia D and Ex ma D
    const zone20Allowed = [
      'Ex ia D',
      'Ex ma D',
      'Ex iaD',
      'Ex maD',
    ];

    final trimmedZone = zone.trim().toLowerCase();
    for (final type in selectedTypes) {
      if (trimmedZone == 'zone 0' ||
          trimmedZone == 'class 1, div 1' ||
          trimmedZone == 'class 1 div 1') {
        final normalized = type.trim();
        final isAllowed = zone0Allowed.any((allowed) =>
            normalized.toLowerCase().startsWith(allowed.toLowerCase()));
        if (!isAllowed) return type;
      } else if (trimmedZone == 'zone 20' ||
          trimmedZone == 'class 2, div 1' ||
          trimmedZone == 'class 2 div 1') {
        final normalized = type.trim();
        final isAllowed = zone20Allowed.any((allowed) =>
            normalized.toLowerCase().startsWith(allowed.toLowerCase()));
        if (!isAllowed) return type;
      }
      // Zone 1, Zone 2, Zone 21, Zone 22 and others allow all types
    }
    return null;
  }

  /// Returns the first invalid EPL for the given zone, or null if all valid.
  String? _getInvalidEPLForZone(String zone, List<String> selectedEPLs) {
    // Minimum EPL requirements per zone
    const zone0RequiredEPL = ['Ga'];
    const zone1AllowedEPL = ['Ga', 'Gb'];
    const zone20RequiredEPL = ['Da'];
    const zone21AllowedEPL = ['Da', 'Db'];
    // Zone 2, Zone 22 allow all EPL values

    final trimmedZone = zone.trim().toLowerCase();
    List<String>? allowedList;
    if (trimmedZone == 'zone 0' ||
        trimmedZone == 'class 1, div 1' ||
        trimmedZone == 'class 1 div 1') {
      allowedList = zone0RequiredEPL;
    } else if (trimmedZone == 'zone 1') {
      allowedList = zone1AllowedEPL;
    } else if (trimmedZone == 'zone 20' ||
        trimmedZone == 'class 2, div 1' ||
        trimmedZone == 'class 2 div 1') {
      allowedList = zone20RequiredEPL;
    } else if (trimmedZone == 'zone 21') {
      allowedList = zone21AllowedEPL;
    }

    if (allowedList == null) return null;

    for (final epl in selectedEPLs) {
      final normalized = epl.trim();
      if (!allowedList
          .any((a) => a.toLowerCase() == normalized.toLowerCase())) {
        return epl;
      }
    }
    return null;
  }

  /// Returns a warning if equipment gas group doesn't cover the area gas group.
  /// Area IIC → equipment must have IIC
  /// Area IIB → equipment can have IIB or IIC
  /// Area IIA → equipment can have IIA, IIB, or IIC
  String? _getGasGroupValidationWarning(
      List<String> areaGasGroups, List<String> equipmentGasGroups) {
    // Gas group hierarchy:
    // IEC: IIA (1) < IIB (2) < IIC (3)
    // NEC: D (1) < C (2) < B (3) < A (4)
    // Dust: IIIA (1) < IIIB (2) < IIIC (3)
    const gasGroupRank = {
      'IIA': 1,
      'GROUP IIA': 1,
      'GAS GROUP IIA': 1,
      'IIB': 2,
      'GROUP IIB': 2,
      'GAS GROUP IIB': 2,
      'IIC': 3,
      'GROUP IIC': 3,
      'GAS GROUP IIC': 3,
      'IIIA': 1,
      'GROUP IIIA': 1,
      'IIIB': 2,
      'GROUP IIIB': 2,
      'IIIC': 3,
      'GROUP IIIC': 3,
      'D': 1,
      'GROUP D': 1,
      'C': 2,
      'GROUP C': 2,
      'B': 3,
      'GROUP B': 3,
      'A': 4,
      'GROUP A': 4,
    };

    for (final areaGroup in areaGasGroups) {
      final cleanArea = areaGroup.trim().toUpperCase();
      final areaRank = gasGroupRank[cleanArea];
      if (areaRank == null) continue;

      bool covered = false;
      for (final equipGroup in equipmentGasGroups) {
        final cleanEquip = equipGroup.trim().toUpperCase();
        final equipRank = gasGroupRank[cleanEquip];
        if (equipRank != null && equipRank >= areaRank) {
          covered = true;
          break;
        }
      }
      if (!covered && equipmentGasGroups.isNotEmpty) {
        return 'Equipment Gas Group ${equipmentGasGroups.join(", ")} does not cover Area Gas Group $areaGroup. Equipment must have gas group $areaGroup or higher.';
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────

  void _updateCertificationNumberPrefix(
      String oldPrefixText, String newPrefixText) {
    final oldPrefix = oldPrefixText.isNotEmpty ? '$oldPrefixText-' : '';
    final newPrefix = newPrefixText.isNotEmpty ? '$newPrefixText-' : '';
    final currentText = _certificationNumberController.text;
    String suffix = currentText;
    if (oldPrefix.isNotEmpty && currentText.startsWith(oldPrefix)) {
      suffix = currentText.substring(oldPrefix.length);
    } else if (newPrefix.isNotEmpty && currentText.startsWith(newPrefix)) {
      suffix = currentText.substring(newPrefix.length);
    }
    _certificationNumberController.text = '$newPrefix$suffix';
    _certificationNumberController.selection = TextSelection.fromPosition(
      TextPosition(offset: _certificationNumberController.text.length),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    bool isMandatory = false,
    String? hintText,
    ValueChanged<String>? onChanged,
    VoidCallback? onSwitchToList,
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
          width: MediaQuery.of(context).size.width * 0.275,
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
                  return Focus(
                    child: Builder(
                      builder: (context) {
                        final isFocused = Focus.of(context).hasFocus;

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: label != "Ambient Temperature"
                                ? isFocused && isEditMode
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
                            // keyboardType: TextInputType.text, // use text keyboard
                            inputFormatters: label == 'Equipment Tag Number' ||
                                    label == 'Cable Tag Number'
                                ? [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9 \-]'),
                                    ),
                                  ]
                                : null,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF212121),
                              height: 24 / 17,
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: hintText ?? 'Enter here',
                              hintStyle: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF979797),
                                fontSize: 17.0,
                                height: 24 / 17,
                              ),
                              filled: true,
                              fillColor: isEditMode
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
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: controller.text.isEmpty
                                      ? showErrorColor
                                          ? const Color(0xFFF44336)
                                          : const Color(0xFF002B5C)
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
                              errorStyle: label == 'Ambient Temperature'
                                  ? GoogleFonts.inter(
                                      color: const Color(0xFFF44336),
                                      fontSize: 12.0,
                                      height: 10 / 12,
                                    )
                                  : GoogleFonts.inter(
                                      color: const Color(0xFFF44336),
                                      fontSize: 12.0,
                                      height: 0.1,
                                    ),
                              suffixIcon: onSwitchToList != null
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: isEditMode ? onSwitchToList : null,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        child: const Icon(
                                          Icons.format_list_bulleted,
                                          color: Color(0xFF1E90FF),
                                          size: 24,
                                        ),
                                      ),
                                    )
                                  : (label == 'GPS Coordinates' ||
                                          label == 'RFID Reference')
                                      ? GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: !isEditMode
                                              ? null
                                              : label == 'GPS Coordinates'
                                                  ? _getCurrentLocation
                                                  : () async {
                                                      getRFIDTag(controller);
                                                      // bool isAvailable =
                                                      //     await NFCUtility(context)
                                                      //         .isNfcAvailable();
                                                      // if (!isAvailable) {
                                                      //   ScaffoldMessenger.of(context)
                                                      //       .showSnackBar(
                                                      //     const SnackBar(
                                                      //         content: Text(
                                                      //             "NFC is not available.")),
                                                      //   );
                                                      //   return;
                                                      // }
                                                      // await NFCUtility(context)
                                                      //     .startNfcSession(controller);
                                                      // setState(() {
                                                      //   nfcUsed = true;
                                                      // });
                                                    },
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: SvgPicture.asset(
                                              label == 'GPS Coordinates'
                                                  ? 'lib/src/features/ex_inspections/assets/R-Icon1.svg'
                                                  : 'lib/src/features/ex_register/assets/rfid-icon.svg',
                                              height: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.03,
                                              width: MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.06,
                                              color: !isEditMode
                                                  ? const Color(0xFFBABABA)
                                                  : const Color(0xFF3B475B),
                                            ),
                                          ),
                                        )
                                      : null,
                            ),
                            // || label=='RFID Reference'
                            readOnly: !isEditMode || label == 'GPS Coordinates',
                            validator: (value) {
                              if (_isSubmitting &&
                                  isMandatory &&
                                  (value == null || value.isEmpty)) {
                                return '';
                              }
                              if (label == 'Ambient Temperature' &&
                                  value != null &&
                                  value.isNotEmpty) {
                                if (value == 'Not Available') {
                                  return null;
                                }
                                final tempSingleValueRegex = RegExp(
                                  r'^([-+]?\d{1,3})°C$',
                                );
                                final tempRangeRegex = RegExp(
                                  r'^([-+]?\d{1,3})°C to ([-+]?\d{1,3})°C$',
                                );

                                if (!tempSingleValueRegex.hasMatch(value) &&
                                    !tempRangeRegex.hasMatch(value)) {
                                  return 'Format: -40°C to +55°C or +55°C/-40°C';
                                }
                              }
                              return null;
                            },
                            onChanged: !isEditMode
                                ? null
                                : (value) {
                                    updateError();
                                    onChanged?.call(value);
                                    if (label == 'Ambient Temperature') {
                                      String formattedValue = value;
                                      final tempInputPattern = RegExp(
                                        r'^([-+]?\d{1,3})$',
                                      );

                                      if (formattedValue.endsWith(' to ')) {
                                        formattedValue = formattedValue
                                            .substring(
                                              0,
                                              formattedValue.length - 4,
                                            )
                                            .trim();
                                      } else if (formattedValue.endsWith(
                                        '°C to',
                                      )) {
                                        formattedValue =
                                            '${formattedValue.substring(0, formattedValue.length - 5).trim()}°C';
                                      }

                                      if (formattedValue.endsWith(' ')) {
                                        formattedValue =
                                            formattedValue.trimRight();
                                        if (formattedValue.contains('to')) {
                                          final parts = formattedValue.split(
                                            'to',
                                          );
                                          if (parts.length == 2) {
                                            var firstPart = parts[0].trim();
                                            var secondPart = parts[1].trim();
                                            if (!firstPart.endsWith('°C')) {
                                              firstPart += '°C';
                                            }
                                            if (!secondPart.endsWith('°C')) {
                                              secondPart += '°C';
                                            }
                                            formattedValue =
                                                '$firstPart to $secondPart';
                                          }
                                        } else {
                                          if (formattedValue.startsWith('-')) {
                                            if (tempInputPattern.hasMatch(
                                              formattedValue.substring(1),
                                            )) {
                                              formattedValue += '°C to ';
                                            } else if (formattedValue.endsWith(
                                              '°C',
                                            )) {
                                              formattedValue += ' to ';
                                            }
                                          } else if (formattedValue.startsWith(
                                            '+',
                                          )) {
                                            if (tempInputPattern.hasMatch(
                                              formattedValue.substring(1),
                                            )) {
                                              formattedValue += '°C to ';
                                            }
                                          } else {
                                            if (tempInputPattern.hasMatch(
                                              formattedValue,
                                            )) {
                                              formattedValue += '°C';
                                            }
                                          }
                                        }
                                      } else if (formattedValue.endsWith(
                                        '  ',
                                      )) {
                                        formattedValue =
                                            formattedValue.trimRight();
                                        if (formattedValue.contains('to')) {
                                          final parts = formattedValue.split(
                                            'to',
                                          );
                                          if (parts.length == 2) {
                                            var firstPart = parts[0].trim();
                                            var secondPart = parts[1].trim();
                                            if (!firstPart.endsWith('°C')) {
                                              firstPart += '°C';
                                            }
                                            if (!secondPart.endsWith('°C')) {
                                              secondPart += '°C';
                                            }
                                            formattedValue =
                                                '$firstPart to $secondPart';
                                          }
                                        } else {
                                          if (tempInputPattern.hasMatch(
                                            formattedValue,
                                          )) {
                                            formattedValue += '°C';
                                          }
                                        }
                                      }
                                      controller.value = TextEditingValue(
                                        text: formattedValue,
                                        selection: TextSelection.fromPosition(
                                          TextPosition(
                                            offset: formattedValue.length,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            onFieldSubmitted: (value) async {
                              if (label == 'RFID Reference' && !nfcUsed) {
                                CommonFunctions commonFunctions =
                                    CommonFunctions();
                                String rfidValue = await commonFunctions
                                    .reversedRFIDString(value);
                                controller.text = rfidValue;
                                controller.selection = TextSelection.collapsed(
                                  offset: rfidValue.length,
                                );
                              }
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
      },
    );
  }

  Widget _buildLabeledAMTextField({
    required String label,
    required TextEditingController controller,
    bool isMandatory = false,
    String? hintText,
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
          width: MediaQuery.of(context).size.width * 0.275,
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
                  return Focus(
                    child: Builder(
                      builder: (context) {
                        final isFocused = Focus.of(context).hasFocus;

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: label != "Ambient Temperature"
                                ? isFocused && isEditMode
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
                            // keyboardType: label == "Ambient Temperature"
                            //     ? const TextInputType.numberWithOptions()
                            //     : TextInputType.text,
                            keyboardType:
                                TextInputType.text, // use text keyboard
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-°C to]+'),
                              ),
                            ],
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF212121),
                              height: 24 / 17,
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: hintText ?? 'Enter here',
                              hintStyle: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF979797),
                                fontSize: 17.0,
                                height: 24 / 17,
                              ),
                              filled: true,
                              fillColor: isEditMode
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
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: controller.text.isEmpty
                                      ? showErrorColor
                                          ? const Color(0xFFF44336)
                                          : const Color(0xFF002B5C)
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
                              errorStyle: label == 'Ambient Temperature'
                                  ? GoogleFonts.inter(
                                      color: const Color(0xFFF44336),
                                      fontSize: 12.0,
                                      height: 10 / 12,
                                    )
                                  : GoogleFonts.inter(
                                      color: const Color(0xFFF44336),
                                      fontSize: 12.0,
                                      height: 0.1,
                                    ),
                              suffixIcon: (label == 'GPS Coordinates' ||
                                      label == 'RFID Reference')
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: !isEditMode
                                          ? null
                                          : label == 'GPS Coordinates'
                                              ? _getCurrentLocation
                                              : () async {
                                                  getRFIDTag(controller);
                                                  // bool isAvailable =
                                                  //     await NFCUtility(context)
                                                  //         .isNfcAvailable();
                                                  // if (!isAvailable) {
                                                  //   ScaffoldMessenger.of(context)
                                                  //       .showSnackBar(
                                                  //     const SnackBar(
                                                  //         content: Text(
                                                  //             "NFC is not available.")),
                                                  //   );
                                                  //   return;
                                                  // }
                                                  // await NFCUtility(context)
                                                  //     .startNfcSession(controller);
                                                  // setState(() {
                                                  //   nfcUsed = true;
                                                  // });
                                                },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SvgPicture.asset(
                                          label == 'GPS Coordinates'
                                              ? 'lib/src/features/ex_inspections/assets/R-Icon1.svg'
                                              : 'lib/src/features/ex_register/assets/rfid-icon.svg',
                                          height: MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.03,
                                          width: MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.06,
                                          color: !isEditMode
                                              ? const Color(0xFFBABABA)
                                              : const Color(0xFF3B475B),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            // || label=='RFID Reference'
                            readOnly: !isEditMode || label == 'GPS Coordinates',
                            validator: (value) {
                              if (_isSubmitting &&
                                  isMandatory &&
                                  (value == null || value.isEmpty)) {
                                return '';
                              }
                              if (label == 'Ambient Temperature' &&
                                  value != null &&
                                  value.isNotEmpty) {
                                if (value == 'Not Available') {
                                  return null;
                                }
                                final tempSingleValueRegex = RegExp(
                                  r'^([-+]?\d{1,3})°C$',
                                );
                                final tempRangeRegex = RegExp(
                                  r'^([-+]?\d{1,3})°C to ([-+]?\d{1,3})°C$',
                                );

                                if (!tempSingleValueRegex.hasMatch(value) &&
                                    !tempRangeRegex.hasMatch(value)) {
                                  return 'Format: -40°C to +55°C or +55°C/-40°C';
                                }
                              }
                              return null;
                            },
                            onChanged: !isEditMode
                                ? null
                                : (value) {
                                    updateError();
                                    if (label == 'Ambient Temperature') {
                                      String formattedValue = value;
                                      final tempInputPattern = RegExp(
                                        r'^([-+]?\d{1,3})$',
                                      );

                                      if (formattedValue.endsWith(' to ')) {
                                        formattedValue = formattedValue
                                            .substring(
                                              0,
                                              formattedValue.length - 4,
                                            )
                                            .trim();
                                      } else if (formattedValue.endsWith(
                                        '°C to',
                                      )) {
                                        formattedValue =
                                            '${formattedValue.substring(0, formattedValue.length - 5).trim()}°C';
                                      }

                                      if (formattedValue.endsWith(' ')) {
                                        formattedValue =
                                            formattedValue.trimRight();
                                        if (formattedValue.contains('to')) {
                                          final parts = formattedValue.split(
                                            'to',
                                          );
                                          if (parts.length == 2) {
                                            var firstPart = parts[0].trim();
                                            var secondPart = parts[1].trim();
                                            if (!firstPart.endsWith('°C')) {
                                              firstPart += '°C';
                                            }
                                            if (!secondPart.endsWith('°C')) {
                                              secondPart += '°C';
                                            }
                                            formattedValue =
                                                '$firstPart to $secondPart';
                                          }
                                        } else {
                                          if (formattedValue.startsWith('-')) {
                                            if (tempInputPattern.hasMatch(
                                              formattedValue.substring(1),
                                            )) {
                                              formattedValue += '°C to ';
                                            } else if (formattedValue.endsWith(
                                              '°C',
                                            )) {
                                              formattedValue += ' to ';
                                            }
                                          } else if (formattedValue.startsWith(
                                            '+',
                                          )) {
                                            if (tempInputPattern.hasMatch(
                                              formattedValue.substring(1),
                                            )) {
                                              formattedValue += '°C to ';
                                            }
                                          } else {
                                            if (tempInputPattern.hasMatch(
                                              formattedValue,
                                            )) {
                                              formattedValue += '°C';
                                            }
                                          }
                                        }
                                      } else if (formattedValue.endsWith(
                                        '  ',
                                      )) {
                                        formattedValue =
                                            formattedValue.trimRight();
                                        if (formattedValue.contains('to')) {
                                          final parts = formattedValue.split(
                                            'to',
                                          );
                                          if (parts.length == 2) {
                                            var firstPart = parts[0].trim();
                                            var secondPart = parts[1].trim();
                                            if (!firstPart.endsWith('°C')) {
                                              firstPart += '°C';
                                            }
                                            if (!secondPart.endsWith('°C')) {
                                              secondPart += '°C';
                                            }
                                            formattedValue =
                                                '$firstPart to $secondPart';
                                          }
                                        } else {
                                          if (tempInputPattern.hasMatch(
                                            formattedValue,
                                          )) {
                                            formattedValue += '°C';
                                          }
                                        }
                                      }
                                      controller.value = TextEditingValue(
                                        text: formattedValue,
                                        selection: TextSelection.fromPosition(
                                          TextPosition(
                                            offset: formattedValue.length,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            onFieldSubmitted: (value) async {
                              if (label == 'RFID Reference' && !nfcUsed) {
                                CommonFunctions commonFunctions =
                                    CommonFunctions();
                                String rfidValue = await commonFunctions
                                    .reversedRFIDString(value);
                                controller.text = rfidValue;
                                controller.selection = TextSelection.collapsed(
                                  offset: rfidValue.length,
                                );
                              }
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
      },
    );
  }

  // Widget _buildTAmbientLabeledTextField({
  //   required String label,
  //   required TextEditingController controllerMinus,
  //   bool isMandatory = false,
  //   required TextEditingController controllerPlus,
  // }) {
  //   return StatefulBuilder(
  //     builder: (BuildContext context, StateSetter setState) {
  //       bool showErrorColor = false;
  //       if (!_isSubmitting) {
  //         showErrorColor =
  //             _isSubmitting && isMandatory && controllerMinus.text.isEmpty;
  //       } else {
  //         showErrorColor = isMandatory && controllerMinus.text.isEmpty;
  //       }
  //       bool showErrorPlusColor = false;
  //       if (!_isSubmitting) {
  //         showErrorPlusColor =
  //             _isSubmitting && isMandatory && controllerPlus.text.isEmpty;
  //       } else {
  //         showErrorPlusColor = isMandatory && controllerPlus.text.isEmpty;
  //       }
  //       updateError() {
  //         setState(() {
  //           if (isMandatory) {
  //             showErrorColor =
  //                 isMandatory && controllerMinus.text.trim().isEmpty;
  //             showErrorPlusColor =
  //                 isMandatory && controllerPlus.text.trim().isEmpty;
  //           }
  //         });
  //       }

  //       return SizedBox(
  //         width: MediaQuery.of(context).size.width * 0.275,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               '$label${isMandatory ? '*' : ''}',
  //               style: GoogleFonts.inter(
  //                 height: 20 / 14,
  //                 fontWeight: FontWeight.w500,
  //                 color: showErrorColor
  //                     ? const Color(0xFFF44336)
  //                     : const Color(0xFF4B4B4B),
  //                 fontSize: 14.0,
  //               ),
  //             ),
  //             const SizedBox(height: 8.0),
  //             ValueListenableBuilder<bool>(
  //               valueListenable: widget.isEditModeNotifier,
  //               builder: (context, isEditMode, _) {
  //                 return Focus(
  //                   child: Builder(
  //                     builder: (context) {
  //                       final isFocused = Focus.of(context).hasFocus;

  //                       return Container(
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(8.0),
  //                           boxShadow: label != "Ambient Temperature"
  //                               ? isFocused && isEditMode
  //                                     ? showErrorColor == false
  //                                           ? [
  //                                               const BoxShadow(
  //                                                 color: Color(0xA3002B5C),
  //                                                 blurRadius: 4,
  //                                                 offset: Offset(0, 0),
  //                                               ),
  //                                             ]
  //                                           : null
  //                                     : null
  //                               : null,
  //                         ),
  //                         child: Row(
  //                           children: [
  //                             Expanded(
  //                               child: TextFormField(
  //                                 keyboardType: label == "Ambient Temperature"
  //                                     ? const TextInputType.numberWithOptions()
  //                                     : TextInputType.text,
  //                                 style: GoogleFonts.inter(
  //                                   fontSize: 17,
  //                                   fontWeight: FontWeight.w400,
  //                                   color: const Color(0xFF212121),
  //                                   height: 24 / 17,
  //                                 ),
  //                                 autovalidateMode:
  //                                     AutovalidateMode.onUserInteraction,
  //                                 controller: controllerMinus,
  //                                 decoration: InputDecoration(
  //                                   hintText: 'Min°C',
  //                                   hintStyle: GoogleFonts.inter(
  //                                     fontWeight: FontWeight.w400,
  //                                     color: const Color(0xFF979797),
  //                                     fontSize: 17.0,
  //                                     height: 24 / 17,
  //                                   ),
  //                                   filled: true,
  //                                   fillColor: isEditMode
  //                                       ? Colors.white
  //                                       : const Color(0xFFFBFBFB),
  //                                   border: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(8.0),
  //                                     borderSide: BorderSide(
  //                                       color: showErrorColor
  //                                           ? const Color(0xFFF44336)
  //                                           : const Color(0xFFD0D3D8),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   contentPadding: const EdgeInsets.symmetric(
  //                                     vertical: 12.0,
  //                                     horizontal: 12.0,
  //                                   ),
  //                                   enabledBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(8.0),
  //                                     borderSide: BorderSide(
  //                                       color: controllerMinus.text.isEmpty
  //                                           ? showErrorColor
  //                                                 ? const Color(0xFFF44336)
  //                                                 : const Color(0xFFD0D3D8)
  //                                           : const Color(0xFFD0D3D8),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   focusedBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(12.0),
  //                                     borderSide: BorderSide(
  //                                       color: controllerMinus.text.isEmpty
  //                                           ? showErrorColor
  //                                                 ? const Color(0xFFF44336)
  //                                                 : const Color(0xFF002B5C)
  //                                           : const Color(0xFF002B5C),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   errorBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(8.0),
  //                                     borderSide: const BorderSide(
  //                                       color: Color(0xFFF44336),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   focusedErrorBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(8.0),
  //                                     borderSide: const BorderSide(
  //                                       color: Color(0xFFF44336),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   errorStyle: label == 'Ambient Temperature'
  //                                       ? GoogleFonts.inter(
  //                                           color: const Color(0xFFF44336),
  //                                           fontSize: 12.0,
  //                                           height: 10 / 12,
  //                                         )
  //                                       : GoogleFonts.inter(
  //                                           color: const Color(0xFFF44336),
  //                                           fontSize: 12.0,
  //                                           height: 0.1,
  //                                         ),
  //                                   suffixIcon:
  //                                       (label == 'GPS Coordinates' ||
  //                                           label == 'RFID Reference')
  //                                       ? GestureDetector(
  //                                           behavior:
  //                                               HitTestBehavior.translucent,
  //                                           onTap: !isEditMode
  //                                               ? null
  //                                               : label == 'GPS Coordinates'
  //                                               ? _getCurrentLocation
  //                                               : () async {
  //                                                   getRFIDTag(controllerMinus);
  //                                                 },
  //                                           child: Padding(
  //                                             padding: const EdgeInsets.all(
  //                                               10.0,
  //                                             ),
  //                                             child: SvgPicture.asset(
  //                                               label == 'GPS Coordinates'
  //                                                   ? 'lib/src/features/ex_inspections/assets/R-Icon1.svg'
  //                                                   : 'lib/src/features/ex_register/assets/rfid-icon.svg',
  //                                               height:
  //                                                   MediaQuery.of(
  //                                                     context,
  //                                                   ).size.height *
  //                                                   0.03,
  //                                               width:
  //                                                   MediaQuery.of(
  //                                                     context,
  //                                                   ).size.width *
  //                                                   0.06,
  //                                               color: !isEditMode
  //                                                   ? const Color(0xFFBABABA)
  //                                                   : const Color(0xFF3B475B),
  //                                             ),
  //                                           ),
  //                                         )
  //                                       : null,
  //                                 ),
  //                                 readOnly:
  //                                     !isEditMode || label == 'GPS Coordinates',
  //                                 validator: (valueMinus) {
  //                                   if (_isSubmitting &&
  //                                       isMandatory &&
  //                                       (valueMinus == null ||
  //                                           valueMinus.isEmpty)) {
  //                                     return '';
  //                                   }
  //                                   if (label == 'Ambient Temperature' &&
  //                                       valueMinus != null &&
  //                                       valueMinus.isNotEmpty) {
  //                                     if (valueMinus == 'Not Available') {
  //                                       return null;
  //                                     }
  //                                     final tempSingleValueMinusRegex = RegExp(
  //                                       r'^[-+]?\d{1,3}°C$',
  //                                     );

  //                                     if (!tempSingleValueMinusRegex.hasMatch(
  //                                       valueMinus,
  //                                     )) {
  //                                       return 'Format: -40°C';
  //                                     }
  //                                   }
  //                                   return null;
  //                                 },
  //                                 onChanged: !isEditMode
  //                                     ? null
  //                                     : (valueMinus) {
  //                                         updateError();
  //                                         if (label == 'Ambient Temperature') {
  //                                           String formattedValue = valueMinus;
  //                                           final tempInputPattern = RegExp(
  //                                             r'^([-+]?\d{1,3})$',
  //                                           );

  //                                           if (formattedValue.endsWith(' ')) {
  //                                             formattedValue = formattedValue
  //                                                 .trimRight();

  //                                             if (formattedValue.startsWith(
  //                                               '-',
  //                                             )) {
  //                                               if (tempInputPattern.hasMatch(
  //                                                 formattedValue.substring(1),
  //                                               )) {
  //                                                 formattedValue += '°C';
  //                                               }
  //                                             } else if (formattedValue
  //                                                 .startsWith('+')) {
  //                                               if (tempInputPattern.hasMatch(
  //                                                 formattedValue.substring(1),
  //                                               )) {
  //                                                 formattedValue += '°C';
  //                                               }
  //                                             } else {
  //                                               if (tempInputPattern.hasMatch(
  //                                                 formattedValue,
  //                                               )) {
  //                                                 formattedValue += '°C';
  //                                               }
  //                                             }
  //                                           }
  //                                           controllerMinus
  //                                               .value = TextEditingValue(
  //                                             text: formattedValue,
  //                                             selection:
  //                                                 TextSelection.fromPosition(
  //                                                   TextPosition(
  //                                                     offset:
  //                                                         formattedValue.length,
  //                                                   ),
  //                                                 ),
  //                                           );
  //                                         }
  //                                       },
  //                               ),
  //                             ),
  //                             const SizedBox(width: 10),
  //                             Expanded(
  //                               child: TextFormField(
  //                                 keyboardType: label == "Ambient Temperature"
  //                                     ? const TextInputType.numberWithOptions()
  //                                     : TextInputType.text,
  //                                 style: GoogleFonts.inter(
  //                                   fontSize: 17,
  //                                   fontWeight: FontWeight.w400,
  //                                   color: const Color(0xFF212121),
  //                                   height: 24 / 17,
  //                                 ),
  //                                 autovalidateMode:
  //                                     AutovalidateMode.onUserInteraction,
  //                                 controller: controllerPlus,
  //                                 decoration: InputDecoration(
  //                                   hintText: 'Max°C',
  //                                   hintStyle: GoogleFonts.inter(
  //                                     fontWeight: FontWeight.w400,
  //                                     color: const Color(0xFF979797),
  //                                     fontSize: 17.0,
  //                                     height: 24 / 17,
  //                                   ),
  //                                   filled: true,
  //                                   fillColor: isEditMode
  //                                       ? Colors.white
  //                                       : const Color(0xFFFFFFFF),
  //                                   border: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(8.0),
  //                                     borderSide: BorderSide(
  //                                       color: showErrorPlusColor
  //                                           ? const Color(0xFFF44336)
  //                                           : const Color(0xFFD0D3D8),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   contentPadding: const EdgeInsets.symmetric(
  //                                     vertical: 12.0,
  //                                     horizontal: 12.0,
  //                                   ),
  //                                   enabledBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(8.0),
  //                                     borderSide: BorderSide(
  //                                       color: controllerPlus.text.isEmpty
  //                                           ? showErrorPlusColor
  //                                                 ? const Color(0xFFF44336)
  //                                                 : const Color(0xFFD0D3D8)
  //                                           : const Color(0xFFD0D3D8),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   focusedBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(12.0),
  //                                     borderSide: BorderSide(
  //                                       color: controllerPlus.text.isEmpty
  //                                           ? showErrorPlusColor
  //                                                 ? const Color(0xFFF44336)
  //                                                 : const Color(0xFF002B5C)
  //                                           : const Color(0xFF002B5C),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   errorBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(8.0),
  //                                     borderSide: const BorderSide(
  //                                       color: Color(0xFFF44336),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   focusedErrorBorder: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(8.0),
  //                                     borderSide: const BorderSide(
  //                                       color: Color(0xFFF44336),
  //                                       width: 1.0,
  //                                     ),
  //                                   ),
  //                                   errorStyle: label == 'Ambient Temperature'
  //                                       ? GoogleFonts.inter(
  //                                           color: const Color(0xFFF44336),
  //                                           fontSize: 12.0,
  //                                           height: 10 / 12,
  //                                         )
  //                                       : GoogleFonts.inter(
  //                                           color: const Color(0xFFF44336),
  //                                           fontSize: 12.0,
  //                                           height: 0.1,
  //                                         ),
  //                                   suffixIcon:
  //                                       (label == 'GPS Coordinates' ||
  //                                           label == 'RFID Reference')
  //                                       ? GestureDetector(
  //                                           behavior:
  //                                               HitTestBehavior.translucent,
  //                                           onTap: !isEditMode
  //                                               ? null
  //                                               : label == 'GPS Coordinates'
  //                                               ? _getCurrentLocation
  //                                               : () async {
  //                                                   getRFIDTag(controllerPlus);
  //                                                 },
  //                                           child: Padding(
  //                                             padding: const EdgeInsets.all(
  //                                               10.0,
  //                                             ),
  //                                             child: SvgPicture.asset(
  //                                               label == 'GPS Coordinates'
  //                                                   ? 'lib/src/features/ex_inspections/assets/R-Icon1.svg'
  //                                                   : 'lib/src/features/ex_register/assets/rfid-icon.svg',
  //                                               height:
  //                                                   MediaQuery.of(
  //                                                     context,
  //                                                   ).size.height *
  //                                                   0.03,
  //                                               width:
  //                                                   MediaQuery.of(
  //                                                     context,
  //                                                   ).size.width *
  //                                                   0.06,
  //                                               color: !isEditMode
  //                                                   ? const Color(0xFFBABABA)
  //                                                   : const Color(0xFF3B475B),
  //                                             ),
  //                                           ),
  //                                         )
  //                                       : null,
  //                                 ),
  //                                 readOnly:
  //                                     !isEditMode || label == 'GPS Coordinates',
  //                                 validator: (valuePlus) {
  //                                   if (_isSubmitting &&
  //                                       isMandatory &&
  //                                       (valuePlus == null ||
  //                                           valuePlus.isEmpty)) {
  //                                     return '';
  //                                   }
  //                                   if (label == 'Ambient Temperature' &&
  //                                       valuePlus != null &&
  //                                       valuePlus.isNotEmpty) {
  //                                     if (valuePlus == 'Not Available') {
  //                                       return null;
  //                                     }
  //                                     final tempSingleValuePlusRegex = RegExp(
  //                                       r'^[-+]?\d{1,3}°C$',
  //                                     );

  //                                     if (!tempSingleValuePlusRegex.hasMatch(
  //                                       valuePlus,
  //                                     )) {
  //                                       return 'Format: +40°C';
  //                                     }
  //                                   }
  //                                   return null;
  //                                 },
  //                                 onChanged: !isEditMode
  //                                     ? null
  //                                     : (valuePlus) {
  //                                         updateError();
  //                                         if (label == 'Ambient Temperature') {
  //                                           String formattedValue = valuePlus;
  //                                           final tempInputPattern = RegExp(
  //                                             r'^([-+]?\d{1,3})$',
  //                                           );

  //                                           if (formattedValue.endsWith(' ')) {
  //                                             formattedValue = formattedValue
  //                                                 .trimRight();

  //                                             if (formattedValue.startsWith(
  //                                               '-',
  //                                             )) {
  //                                               if (tempInputPattern.hasMatch(
  //                                                 formattedValue.substring(1),
  //                                               )) {
  //                                                 formattedValue += '°C';
  //                                               }
  //                                             } else if (formattedValue
  //                                                 .startsWith('+')) {
  //                                               if (tempInputPattern.hasMatch(
  //                                                 formattedValue.substring(1),
  //                                               )) {
  //                                                 formattedValue += '°C';
  //                                               }
  //                                             } else {
  //                                               if (tempInputPattern.hasMatch(
  //                                                 formattedValue,
  //                                               )) {
  //                                                 formattedValue =
  //                                                     "+$formattedValue°C";
  //                                               }
  //                                             }
  //                                           }
  //                                           controllerPlus
  //                                               .value = TextEditingValue(
  //                                             text: formattedValue,
  //                                             selection:
  //                                                 TextSelection.fromPosition(
  //                                                   TextPosition(
  //                                                     offset:
  //                                                         formattedValue.length,
  //                                                   ),
  //                                                 ),
  //                                           );
  //                                         }
  //                                       },
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildRfidTextField({
    required String label,
    required TextEditingController controller,
    bool isMandatory = false,
    String? hintText,
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
        // updateError() {
        //   setState(() {
        //     if (isMandatory) {
        //       showErrorColor = isMandatory && controller.text.trim().isEmpty;
        //     }
        //   });
        // }

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.275,
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
                  return Focus(
                    child: Builder(
                      builder: (context) {
                        final isFocused = Focus.of(context).hasFocus;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: label != "Ambient Temperature"
                                ? isFocused && isEditMode
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
                            focusNode: _rfidFocusNode,
                            keyboardType: TextInputType.none,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF212121),
                              height: 24 / 17,
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: hintText ?? 'Enter here',
                              hintStyle: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF979797),
                                fontSize: 17.0,
                                height: 24 / 17,
                              ),
                              filled: true,
                              fillColor: isEditMode
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
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: controller.text.isEmpty
                                      ? showErrorColor
                                          ? const Color(0xFFF44336)
                                          : const Color(0xFF002B5C)
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
                                height: 0.1,
                              ),
                              suffixIcon: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: !isEditMode
                                    ? null
                                    : () async {
                                        getRFIDTag(controller);
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(
                                    'lib/src/features/ex_register/assets/rfid-icon.svg',
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                    width: MediaQuery.of(context).size.width *
                                        0.06,
                                    color: !isEditMode
                                        ? const Color(0xFFBABABA)
                                        : const Color(0xFF3B475B),
                                  ),
                                ),
                              ),
                            ),
                            readOnly: !isEditMode || rfidReadonly,
                            onChanged: !isEditMode ? null : (value) {},
                            onFieldSubmitted: (value) async {
                              if (!nfcUsed) {
                                CommonFunctions commonFunctions =
                                    CommonFunctions();
                                String rfidValue = await commonFunctions
                                    .reversedRFIDString(value);
                                controller.text = rfidValue;
                                controller.selection = TextSelection.collapsed(
                                  offset: rfidValue.length,
                                );
                              }
                              setState(() {
                                rfidReadonly = true;
                              });
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
      },
    );
  }

  Widget _buildLabeledDropdownField({
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
      width: MediaQuery.of(context).size.width * 0.275,
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
              return FormField<String>(
                initialValue: value,
                builder: (FormFieldState<String> state) {
                  return SearchableDropdown(
                    value: value,
                    items: items,
                    onChanged: (newValue) {
                      state.didChange(newValue);
                      onChanged?.call(newValue);
                    },
                    isEditMode: isEditMode,
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
          ),
        ],
      ),
    );
  }

  String _getTextFieldValue(TextEditingController controller) {
    return controller.text.isEmpty ? '' : controller.text;
  }

  void onSubmitEquipmentTag({bool skipValidation = false}) async {
    setState(() {
      _isSubmitting = !skipValidation;
    });
    if (!skipValidation && !formKey.currentState!.validate()) {
      return;
    }
    // final String ambientTemp1 = _ambientTemperatureController.text.trim();
    // final String ambientTemp2 = _ambientTemperaturePlusController.text.trim();

    // String ambientTemperature = '';
    // if (ambientTemp1.isNotEmpty && ambientTemp2.isNotEmpty) {
    //   ambientTemperature =
    //       "${_getTextFieldValue(_ambientTemperatureController)} to ${_getTextFieldValue(_ambientTemperaturePlusController)}";
    // } else if (ambientTemp1.isNotEmpty) {
    //   ambientTemperature = _getTextFieldValue(_ambientTemperatureController);
    // } else if (ambientTemp2.isNotEmpty) {
    //   ambientTemperature =
    //       _getTextFieldValue(_ambientTemperaturePlusController);
    // }

    // if (ambientTemperature.isEmpty) {
    //   ambientTemperature = 'Not Available';
    // }

    final String locationId = widget.exInspectionRequest.equipmentTagRequest
                ?.locationId.isNotEmpty ==
            true
        ? widget.exInspectionRequest.equipmentTagRequest!.locationId
        : widget.exInspectionRequest.functionalAreaRequest?.locationId ?? '';
    widget.exInspectionRequest.equipmentTagRequest = EquipmentTagRequest(
      locationId: locationId,
      location:
          widget.exInspectionRequest.functionalAreaRequest?.location ?? '',
      area: widget.exInspectionRequest.functionalAreaRequest?.area ?? '',
      subArea: widget.exInspectionRequest.functionalAreaRequest?.subArea,
      zone: widget.exInspectionRequest.functionalAreaRequest?.zone ?? '',
      isActive:
          widget.exInspectionRequest.functionalAreaRequest?.isActive ?? true,
      locationGasGroup:
          widget.exInspectionRequest.functionalAreaRequest?.locationGasGroup ??
              [],
      locationTClass:
          widget.exInspectionRequest.functionalAreaRequest?.locationTClass ??
              [],

      locationIpRating:
          widget.exInspectionRequest.functionalAreaRequest?.locationIpRating ??
              [],
      locationTAmbient:
          widget.exInspectionRequest.functionalAreaRequest?.tAmbient ?? '',
      areaClassDrawAttach: widget
              .exInspectionRequest.functionalAreaRequest?.areaClassDrawAttach ??
          [],
      areaClassDrawNo:
          widget.exInspectionRequest.functionalAreaRequest?.areaClassDrawNo ??
              [],
      eqpmtLytDrawAttach: widget
              .exInspectionRequest.functionalAreaRequest?.eqpmtLytDrawAttach ??
          [],
      eqpmtLytDrawNo:
          widget.exInspectionRequest.functionalAreaRequest?.eqpmtLytDrawNo ??
              [],
      eqpmtLytDrawAttachOrgName: widget.exInspectionRequest
              .functionalAreaRequest?.eqpmtLytDrawAttachOrgName ??
          [],
      areaClassDrawAttachOrgName: widget.exInspectionRequest
              .functionalAreaRequest?.areaClassDrawAttachOrgName ??
          [],
      locationLatitude:
          widget.exInspectionRequest.functionalAreaRequest?.locationLatitude,
      locationLongitude:
          widget.exInspectionRequest.functionalAreaRequest?.locationLongitude,
      deckLevel:
          widget.exInspectionRequest.functionalAreaRequest?.deckLevel ?? '',
      rfidRef: _getTextFieldValue(_rfidReferenceController),
      gpsCord: _getTextFieldValue(_gpsCoordinatesController),
      eqpmtCatg: _selectedDicipline.toString(),
      eqpmtTag: _getTextFieldValue(_equipmentIdController),
      // circuitId: _getTextFieldValue(_cableIdController),
      areaStatus: _selectedEquipmentStatus,
      cableId: _getTextFieldValue(_cableIdController),
      equipmentCategory: _selectedEquipmentCategory,
      description: _getTextFieldValue(_equipmentDescription),
      manufacturer: _getTextFieldValue(_manufacturerController),
      type: _getTextFieldValue(_typeController),
      serialNumber: _getTextFieldValue(_serialNumberController),
      atexCatg: selectedAtexItems,
      epl: selectedEPLItems,
      protectionStd: _selectedProtectionStandard,
      protectionType: selectedProtectionTypeItems,
      equipmentGasGroup: selectedGasItems,
      equipmentTClass: selectedTClassItems,
      equipmentIpRating: selectedIpRatingItems,
      certfnBody: _getTextFieldValue(_certificationBodyController),
      certfnNo: _getTextFieldValue(_certificationNumberController),
      tAmbient: _getTextFieldValue(
        _ambientTemperatureController,
      ), //ambientTemperature,
      tAmbientEquip: _getTextFieldValue(_ambientTemperatureController),
      specialCond: _selectedSpecialCondition,
      oracleId: _getTextFieldValue(_oracleIdController),
      assetId: dotenv.env['IS_API_FLAG'] == 'true'
          ? (widget.exInspectionRequest.equipmentTagRequest?.assetId)
          : (widget.exInspectionRequest.equipmentTagRequest?.assetId ?? ''),
      checkList:
          widget.exInspectionRequest.equipmentTagRequest?.checkList ?? [],
      yesNoSelection:
          widget.exInspectionRequest.equipmentTagRequest?.yesNoSelection ?? {},
      inspectedBy:
          widget.exInspectionRequest.equipmentTagRequest?.inspectedBy ?? '',
      inspectedDate:
          widget.exInspectionRequest.equipmentTagRequest?.inspectedDate ?? '',
      faultyItems:
          widget.exInspectionRequest.equipmentTagRequest?.faultyItems ?? '',
      defectDefectCategory: widget
              .exInspectionRequest.equipmentTagRequest?.defectDefectCategory ??
          '',
      inspectionSignOff:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionSignOff,
      repairSignOff:
          widget.exInspectionRequest.equipmentTagRequest?.repairSignOff,
      inspectionStatus:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionStatus ??
              '',
      defectOverallCondition: widget.exInspectionRequest.equipmentTagRequest
              ?.defectOverallCondition ??
          '',
      defectIsolation:
          widget.exInspectionRequest.equipmentTagRequest?.defectIsolation ?? '',
      defectOtherRequirements: widget.exInspectionRequest.equipmentTagRequest
              ?.defectOtherRequirements ??
          [],
      remarks: widget.exInspectionRequest.equipmentTagRequest?.remarks ?? '',
      defectCertificationNo: widget
              .exInspectionRequest.equipmentTagRequest?.defectCertificationNo ??
          '',
      defectCertificationOrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.defectCertificationOrgName ??
          '',
      dataSheet:
          widget.exInspectionRequest.equipmentTagRequest?.dataSheet ?? '',
      dataSheetNo:
          widget.exInspectionRequest.equipmentTagRequest?.dataSheetNo ?? '',
      dataSheetOrgName:
          widget.exInspectionRequest.equipmentTagRequest?.dataSheetOrgName ??
              '',
      defectCertificationAttach: widget.exInspectionRequest.equipmentTagRequest
              ?.defectCertificationAttach ??
          '',
      correctiveCertificationAttach: widget.exInspectionRequest
              .equipmentTagRequest?.correctiveCertificationAttach ??
          '',
      defectivePhoto1:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto1 ?? '',
      defectivePhoto1OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.defectivePhoto1OrgName ??
          '',
      defectivePhoto2:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto2 ?? '',
      defectivePhoto2OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.defectivePhoto2OrgName ??
          '',
      defectivePhoto3:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto3 ?? '',
      defectivePhoto3OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.defectivePhoto3OrgName ??
          '',
      defectivePhoto4:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto4 ?? '',
      defectivePhoto4OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.defectivePhoto4OrgName ??
          '',
      defectivePhoto5:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto5 ?? '',
      defectivePhoto5OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.defectivePhoto5OrgName ??
          '',
      defectivePhoto6:
          widget.exInspectionRequest.equipmentTagRequest?.defectivePhoto6 ?? '',
      defectivePhoto6OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.defectivePhoto6OrgName ??
          '',
      additionalInfoForRepairs: widget.exInspectionRequest.equipmentTagRequest
              ?.additionalInfoForRepairs ??
          '',
      existingFaults:
          widget.exInspectionRequest.equipmentTagRequest?.existingFaults ?? '',
      correctiveDefectCategory: widget.exInspectionRequest.equipmentTagRequest
              ?.correctiveDefectCategory ??
          '',
      currentStatus:
          widget.exInspectionRequest.equipmentTagRequest?.currentStatus ?? '',
      correctiveOverallCondition: widget.exInspectionRequest.equipmentTagRequest
              ?.correctiveOverallCondition ??
          '',
      correctiveisolation:
          widget.exInspectionRequest.equipmentTagRequest?.correctiveisolation ??
              '',
      correctiveOtherRequirements: widget.exInspectionRequest
              .equipmentTagRequest?.correctiveOtherRequirements ??
          '',
      repairsDone:
          widget.exInspectionRequest.equipmentTagRequest?.repairsDone ?? '',
      remarksIfAny:
          widget.exInspectionRequest.equipmentTagRequest?.remarksIfAny ?? '',
      correctiveCertificationOrgName: widget.exInspectionRequest
              .equipmentTagRequest?.correctiveCertificationOrgName ??
          '',
      correctiveCertificationNo: widget.exInspectionRequest.equipmentTagRequest
              ?.correctiveCertificationNo ??
          '',
      correctivePhoto1:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto1 ??
              '',
      correctivePhoto1OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.correctivePhoto1OrgName ??
          '',
      correctivePhoto2:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto2 ??
              '',
      correctivePhoto2OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.correctivePhoto2OrgName ??
          '',
      correctivePhoto3:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto3 ??
              '',
      correctivePhoto3OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.correctivePhoto3OrgName ??
          '',
      correctivePhoto4:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto4 ??
              '',
      correctivePhoto4OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.correctivePhoto4OrgName ??
          '',
      correctivePhoto5:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto5 ??
              '',
      correctivePhoto5OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.correctivePhoto5OrgName ??
          '',
      correctivePhoto6:
          widget.exInspectionRequest.equipmentTagRequest?.correctivePhoto6 ??
              '',
      correctivePhoto6OrgName: widget.exInspectionRequest.equipmentTagRequest
              ?.correctivePhoto6OrgName ??
          '',
      repairedBy:
          widget.exInspectionRequest.equipmentTagRequest?.repairedBy ?? '',
      repairedDate:
          widget.exInspectionRequest.equipmentTagRequest?.repairedDate ?? '',
      supplementaryMaterialReq: widget.exInspectionRequest.equipmentTagRequest
              ?.supplementaryMaterialReq ??
          [],
      inspectionChecklistType: widget.exInspectionRequest.equipmentTagRequest
              ?.inspectionChecklistType ??
          [],
      inspectionGrade:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionGrade ?? '',
      inspectionType:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionType ?? '',
      equipmentEquipmentType: widget.exInspectionRequest.equipmentTagRequest
              ?.equipmentEquipmentType ??
          '',
      materials:
          widget.exInspectionRequest.equipmentTagRequest?.materials ?? [],
      rbiStrategy: widget.exInspectionRequest.equipmentTagRequest?.rbiStrategy,
      primaryId: widget.exInspectionRequest.equipmentTagRequest?.primaryId,
      repairTimeEstimate:
          widget.exInspectionRequest.equipmentTagRequest?.repairTimeEstimate,
      repairDuration:
          widget.exInspectionRequest.equipmentTagRequest?.repairDuration,
      inspectionPriority:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionPriority,
    );
    context.read<ExInspectionsBloc>().add(
          SubmitEquipmentTag(
            widget.exInspectionRequest,
            screenType: 'Equipment Tag',
          ),
        );
  }

  Future<void> getRFIDTag(controller) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
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
                                      'Select Scanning Source',
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
                              onPressed: () async {
                                bool isAvailable = await NFCUtility(
                                  context,
                                ).isNfcAvailable();
                                if (!isAvailable) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("NFC is not available."),
                                    ),
                                  );
                                  return;
                                }
                                await NFCUtility(
                                  context,
                                ).startNfcSession(controller);
                                setState(() {
                                  nfcUsed = true;
                                });
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
                                'Default NFC',
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
                                setState(() {
                                  _rfidFocusNode.requestFocus();
                                  rfidReadonly = false;
                                });
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
                                'RFID Reader',
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
              Positioned(
                top: -10, // Adjust for better positioning
                right: -10,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
