// ignore_for_file: deprecated_member_use

import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/multi_select_dropdown.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/ex_inspection_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/inspection_checklist_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/searchable_dropdown.dart';
import 'package:intl/intl.dart';

import '../../../../custom_widgets/custom_radio_box.dart';
import '../../../../utils/auth_util.dart';
import '../../../../utils/common_util.dart';
import '../../../../utils/database_helper.dart';
import '../../../ex_register/data/services/ex_register_service.dart';
import '../../../functional_areas/data/services/location_service.dart';
import '../../bloc/ex_inspection_bloc.dart';
import '../../data/models/functional_area_request.dart';

class InspectionChecklistStep extends StatefulWidget {
  final ExInspectionRequest exInspectionRequest;
  final bool isUpdate;
  final bool fromExRegister;
  final String assetId;
  final ValueNotifier<bool> isEditModeNotifier;
  const InspectionChecklistStep({
    super.key,
    required this.exInspectionRequest,
    required this.isUpdate,
    required this.fromExRegister,
    required this.assetId,
    required this.isEditModeNotifier,
  });

  @override
  InspectionChecklistStepState createState() => InspectionChecklistStepState();
}

class InspectionChecklistStepState extends State<InspectionChecklistStep> {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? _selectedInspectionType = '';
  String? _selectedEquipmentType = '';
  String? _selectedInspectionChecklist;
  String? _selectedInspectionGrade = '';
  List<String> selectedInspectionChecklist = [];
  final Map<String, bool> _expandedRows = {};
  Map<String, int> categoryCountMap = {};
  Map<String, String> defectCodeIdMap = {};
  Map<String, bool> selectedFindings = {};
  Map<String, dynamic> yesNoSelection = {};
  List<String> checkDefectCode = [];
  bool _isSubmitting = false;
  final isApiFlag = dotenv.env['IS_API_FLAG']?.toLowerCase() == 'true';
  ExInspectionRequest? exInspectionRequest;
  List<CheckList> selectedChecklist = [];
  List<dynamic> relatedCollections = [];
  List<Map<String, dynamic>> selectedActionCollection = [];
  List<Map<String, dynamic>> untickedActionCollection = [];
  List<Map<String, dynamic>> relatedDetailsCollection = [];
  final Map<String, bool> _defectValidationMap = {};

  bool checkLableFlag = false;
  // _isEditingRow removed - Edit button replaced with +Add pattern

  @override
  void initState() {
    super.initState();

    if (widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeValues();
      selectedChecklist =
          widget.exInspectionRequest.equipmentTagRequest?.checkList ?? [];
    }
    if (_shouldFetchFilteredData()) {
      onSubmitInspectionChecklist();
    } else {
      _fetchInspectionChecklistData();
    }
    context.read<ExInspectionsBloc>().add(FetchAllDropDwn());
    if (widget.fromExRegister) {
      _fetchAssetData(widget.assetId);
    } else {
      _initializeSelectedFindings();
    }
    if (_selectedInspectionType != null ||
        _selectedEquipmentType != null ||
        selectedInspectionChecklist.isNotEmpty ||
        _selectedInspectionGrade != null) {
      _filterChecklistData();
    }
  }

  void _initializeSelectedFindings() {
    // if(widget.fromExRegister){
    //   selectedFindings.clear();
    //   final savedChecklists =
    //       exInspectionRequest?.equipmentTagRequest?.checkList;
    //
    //   if (savedChecklists != null) {
    //     for (var checkList in savedChecklists) {
    //       for (var defectCode in checkList.defectCodes) {
    //         for (var finding in defectCode.findingsAndActions) {
    //           if (finding.isSelected) {
    //             selectedFindings[finding.id] = true;
    //           }
    //         }
    //       }
    //     }
    //   }
    // }
    // else{
    selectedFindings.clear();
    final savedChecklists =
        widget.exInspectionRequest.equipmentTagRequest?.checkList;
    if (savedChecklists != null) {
      for (var checkList in savedChecklists) {
        for (var defectCode in checkList.defectCodes) {
          for (var finding in defectCode.findingsAndActions) {
            if (finding.isSelected) {
              selectedFindings[finding.id] = true;
            }
          }
        }
      }
    }
    // }
  }

  bool _shouldFetchFilteredData() {
    return _selectedInspectionType != null ||
        _selectedEquipmentType != null ||
        selectedInspectionChecklist.isNotEmpty ||
        _selectedInspectionGrade != null;
  }

  @override
  void didUpdateWidget(covariant InspectionChecklistStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exInspectionRequest != oldWidget.exInspectionRequest &&
        widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeValues();
      if (_selectedInspectionType != null ||
          _selectedEquipmentType != null ||
          selectedInspectionChecklist.isNotEmpty ||
          _selectedInspectionGrade != null) {
        _filterChecklistData();
      }
    }
  }

  void _initializeValues() {
    final request = widget.exInspectionRequest.equipmentTagRequest;

    _selectedInspectionType = request?.inspectionType;
    _selectedEquipmentType = request?.equipmentEquipmentType;
    // _selectedInspectionChecklist = request.inspectionChecklistType;
    selectedInspectionChecklist = request!.inspectionChecklistType;
    _selectedInspectionGrade = request.inspectionGrade;
    yesNoSelection = request.yesNoSelection;
    if (yesNoSelection.isNotEmpty) {
      yesNoSelection.updateAll((key, value) => value.toLowerCase());
    }
  }

  void clearFields() {
    setState(() {
      _isSubmitting = false;
      _selectedInspectionType = '';
      _selectedEquipmentType = '';
      yesNoSelection = {};
      // _selectedInspectionChecklist = '';
      selectedInspectionChecklist.clear();
      _selectedInspectionGrade = '';
      selectedFindings.clear();
      widget.exInspectionRequest.equipmentTagRequest?.inspectionChecklistType
          .clear();
      widget.exInspectionRequest.equipmentTagRequest?.inspectionGrade = null;
      widget.exInspectionRequest.equipmentTagRequest?.inspectionType = null;
      widget.exInspectionRequest.equipmentTagRequest?.equipmentEquipmentType =
          null;
      widget.exInspectionRequest.equipmentTagRequest?.faultyItems = null;
      widget.exInspectionRequest.equipmentTagRequest?.repairsDone = '';
      widget.exInspectionRequest.equipmentTagRequest?.inspectionPriority = null;
      widget.exInspectionRequest.equipmentTagRequest?.existingFaults = null;
      widget.exInspectionRequest.equipmentTagRequest?.checkList = [];
      widget.exInspectionRequest.equipmentTagRequest?.inspectionStatus = null;
      widget.exInspectionRequest.equipmentTagRequest?.currentStatus = null;
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
      widget.exInspectionRequest.equipmentTagRequest?.correctiveDefectCategory =
          '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveOverallCondition = '';
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveOtherRequirements = '';
      widget.exInspectionRequest.equipmentTagRequest?.dataSheetNo = '';
      widget.exInspectionRequest.equipmentTagRequest?.dataSheet = '';
      widget.exInspectionRequest.equipmentTagRequest?.dataSheetOrgName = '';
      widget.exInspectionRequest.equipmentTagRequest?.inspectedDate = '';
      widget.exInspectionRequest.equipmentTagRequest?.inspectedBy = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairedDate = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairedBy = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairDuration = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairTimeEstimate = '';
      widget.exInspectionRequest.equipmentTagRequest?.defectDefectCategory =
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
      untickedActionCollection.clear();
      selectedActionCollection.clear();
      relatedDetailsCollection.clear();
    });

    onSubmitEquipmentTag([], [], {}, skipValidation: true, 'empty');
  }

  void _initializeDefectCodeIdMap() {
    defectCodeIdMap = Map.fromEntries(
      widget.exInspectionRequest.equipmentTagRequest?.checkList?.expand(
            (checkList) => checkList.defectCodes.map(
              (defectCode) => MapEntry(defectCode.id, defectCode.defectCode),
            ),
          ) ??
          [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExInspectionsBloc, ExInspectionsState>(
      listener: (context, state) {
        if (state is ExInspectionSuccess) {
          if (widget.isEditModeNotifier.value) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_SHORT,
            );
          }
          _fetchInspectionChecklistData();
          // selectedChecklist =
          //     widget.exInspectionRequest.equipmentTagRequest!.checkList ?? [];
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
            // final List<String> newDefectCodes = state
            //     .checklistData!['checkListDetails']
            //     .map<String>((e) => e['defectCode'] as String)
            //     .toSet()
            //     .toList();

            // final List<String> existingDefectCodes =
            //     yesNoSelection.keys.toSet().toList();

            // // Sort both lists to compare regardless of order
            // newDefectCodes.sort();
            // existingDefectCodes.sort();

            // if (!listEquals(newDefectCodes, existingDefectCodes)) {
            //   // They are different, so update yesNoSelection
            //   yesNoSelection.clear(); // Optional: clear before repopulating
            //   for (var element in state.checklistData!['checkListDetails']) {
            //     String code = element['defectCode']!;
            //     yesNoSelection[code] = '';
            //   }
            // }
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  _buildForm(state.allDropDowns ?? {}),
                  _buildAccordionSection(state.checklistData ?? {}),
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

  void _fetchInspectionChecklistData() {
    widget.exInspectionRequest.inspectionChecklistRequest ??=
        InspectionChecklistRequest(
      inspectionType: _selectedInspectionType,
      equipmentType: _selectedEquipmentType,
      // checklistName: _selectedInspectionChecklist,
      checklistName: selectedInspectionChecklist,
      inspectionGrade: _selectedInspectionGrade,
    );

    final filters = {
      'inspectionType': _selectedInspectionType,
      'equipmentType': _selectedEquipmentType,
      // 'checklistName': _selectedInspectionChecklist,
      'checklistName': selectedInspectionChecklist,
      'inspectionGrade': _selectedInspectionGrade,
    };

    context.read<ExInspectionsBloc>().add(
          SubmitInspectionChecklist(
            widget.exInspectionRequest.inspectionChecklistRequest!,
            filters,
            selectedChecklist,
          ),
        );

    _initializeCategoryCountMap();
    _initializeDefectCodeIdMap();
  }

  void _filterChecklistData() {
    _fetchInspectionChecklistData();
  }

  Widget _buildForm(Map<String, dynamic> getAllDropDowns) {
    final exRegisterDropDown = getAllDropDowns['result']['exResiterDropDown'][0]
        as Map<String, dynamic>;
    final inspectionTypes =
        (exRegisterDropDown['inspectionType'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();
    final equipmentTypes =
        (exRegisterDropDown['equipmentType'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();
    final checklistNames =
        (exRegisterDropDown['inspectionCheckList'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();
    final inspectionGrades =
        (exRegisterDropDown['inspectionGrade'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        child: Wrap(
          spacing: 24.0,
          runSpacing: 16.0,
          children: [
            _buildLabeledDropdownField(
              label: 'Inspection Type',
              value: _selectedInspectionType,
              items: inspectionTypes,
              onChanged: (value) {
                setState(() {
                  _selectedInspectionType = value;
                });
                _filterChecklistData();
              },
              isMandatory: true,
            ),
            _buildLabeledDropdownField(
              label: 'Equipment Type',
              value: _selectedEquipmentType,
              items: equipmentTypes,
              onChanged: (value) {
                setState(() {
                  _selectedEquipmentType = value;
                });
                _filterChecklistData();
              },
              isMandatory: true,
            ),
            MultiSelectDropdown(
              label: 'Inspection Checklist',
              items: checklistNames,
              selectedItems: selectedInspectionChecklist,
              isSubmitting: _isSubmitting,
              selectedItemString: _selectedInspectionChecklist,
              onChanged: (value) {
                setState(() {
                  selectedInspectionChecklist = value;
                  _selectedInspectionChecklist =
                      value.isEmpty ? '' : value.join(', ');
                });
                _filterChecklistData();
              },
              isMandatory: true,
              isInspectionFlag: true,
              isEditModeNotifier: widget.isEditModeNotifier,
            ),
            // _buildLabeledDropdownField(
            //   label: 'Inspection Checklist',
            //   value: _selectedInspectionChecklist,
            //   items: checklistNames,
            //   onChanged: (value) {
            //     setState(() {
            //       _selectedInspectionChecklist = value;
            //     });
            //     _filterChecklistData();
            //   },
            //   isMandatory: true,
            // ),
            _buildLabeledDropdownField(
              label: 'Inspection Grade',
              value: _selectedInspectionGrade,
              items: inspectionGrades,
              onChanged: (value) {
                setState(() {
                  _selectedInspectionGrade = value;
                });
                _filterChecklistData();
              },
              isMandatory: true,
            ),
          ],
        ),
      ),
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
      width: MediaQuery.of(context).size.width * 0.202,
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

  void onSubmitInspectionChecklist() {
    _fetchInspectionChecklistData();
  }

  void _initializeCategoryCountMap() {
    categoryCountMap = Map<String, int>.fromEntries(
      widget.exInspectionRequest.equipmentTagRequest?.checkList?.map(
            (checkList) => MapEntry(
              checkList.defectCategory,
              checkList.defectCodes.length,
            ),
          ) ??
          [],
    );
  }

  Widget _buildAccordionSection(Map<String, dynamic> checklistData) {
    final List<dynamic> checkLists = checklistData['checkLists'] ?? [];
    final List<dynamic> checkListDetails =
        checklistData['checkListDetails'] ?? [];
    checkDefectCode.clear();
    checkLists.sort((a, b) {
      String defectCategoryA = a['defectCategory']?.toString() ?? '';
      String defectCategoryB = b['defectCategory']?.toString() ?? '';
      return defectCategoryA.compareTo(defectCategoryB);
    });
    relatedCollections.clear();
    return Column(
      children: checkLists.map((checkList) {
        final defectCategory = checkList['defectCategory']?.toString() ?? '';
        final relatedDetails = checkListDetails
            .where((detail) => detail['defectCategory'] == defectCategory)
            .toList();
        relatedDetails.sort((a, b) {
          String defectCodeA = a['defectCode']?.toString() ?? '';
          String defectCodeB = b['defectCode']?.toString() ?? '';
          RegExp regex = RegExp(r'([a-zA-Z]+)(\d+)');
          Match? matchA = regex.firstMatch(defectCodeA);
          Match? matchB = regex.firstMatch(defectCodeB);

          if (matchA != null && matchB != null) {
            String letterA = matchA.group(1) ?? '';
            String letterB = matchB.group(1) ?? '';
            int numberA = int.tryParse(matchA.group(2) ?? '') ?? 0;
            int numberB = int.tryParse(matchB.group(2) ?? '') ?? 0;

            int compare = letterA.compareTo(letterB);
            if (compare == 0) {
              return numberA.compareTo(numberB);
            }
            return compare;
          }
          return defectCodeA.compareTo(defectCodeB);
        });

        final totalRecords = relatedDetails.length;
        final count = categoryCountMap[defectCategory] ?? 0;
        // relatedCollections.add(relatedDetails);
        for (var detail in relatedDetails) {
          String? defectCode = detail['defectCode']?.toString();
          if (defectCode != null &&
              defectCode.isNotEmpty &&
              !checkDefectCode.contains(defectCode)) {
            checkDefectCode.add(defectCode);
          }
        }
        final detailsContent = relatedDetails.isNotEmpty
            ? relatedDetails
                .map(
                  (detail) =>
                      '${detail['defectCode']} ${detail['checkListGroup']}',
                )
                .join('\n')
            : '';
        final recordDisplay = '$count/$totalRecords';
        return _buildAccordion(
          key: ValueKey(defectCategory),
          title: _buildAccordionTitle(
            'Defect Code',
            '$defectCategory. ${checkList['checklistName']}',
            recordDisplay,
          ),
          content: detailsContent,
          details: relatedDetails,
        );
      }).toList(),
    );
  }

  Widget _buildAccordionTitle(
    String defectCode,
    String checklistName,
    String additionalText,
  ) {
    return SizedBox(
      child: Row(
        children: [
          SizedBox(
            child: Text(
              defectCode,
              style: GoogleFonts.inter(
                color: const Color(0xFFE6EAEF),
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
                height: 14 / 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40.0),
          Expanded(
            child: Text(
              checklistName,
              style: GoogleFonts.inter(
                color: const Color(0xFFE6EAEF),
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
                height: 14 / 12,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(
            child: Text(
              additionalText,
              style: GoogleFonts.inter(
                color: const Color(0xFFE6EAEF),
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
                height: 14 / 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 20.0),
        ],
      ),
    );
  }

  Widget _buildAccordion({
    required Key key,
    required Widget title,
    required String content,
    required List<dynamic> details,
  }) {
    Map<String, int> displayedCountPerCategory = {};
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF002B5C).withOpacity(0.1),
        border: const Border(
          left: BorderSide(color: Color(0xFFF2F2F7), width: 1),
          right: BorderSide(color: Color(0xFFF2F2F7), width: 1),
          bottom: BorderSide(color: Color(0xFFF2F2F7), width: 1),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: ExpansionTile(
          key: key,
          title: title,
          tilePadding: const EdgeInsets.symmetric(horizontal: 24.0),
          collapsedBackgroundColor: const Color(0xFF002B5C),
          backgroundColor: const Color(0xFF002B5C),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          maintainState: true,
          shape: Border.all(width: 0, color: Colors.transparent),
          collapsedShape: Border.all(width: 0, color: Colors.transparent),
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: content.split('\n').map((row) {
                  final parts = row.split(' ');
                  final defectCode =
                      parts.isNotEmpty ? parts[0] : 'Unknown Code';
                  final relatedDetail = details.firstWhere(
                    (detail) => detail['defectCode'] == defectCode,
                    orElse: () => {},
                  );

                  final defectCategory =
                      relatedDetail['defectCategory'] ?? 'Unknown Category';
                  final defectCodeId = defectCodeIdMap.entries
                      .firstWhere(
                        (entry) => entry.value == defectCode,
                        orElse: () => const MapEntry('', ''),
                      )
                      .key;
                  int totalCountForCategory =
                      categoryCountMap[defectCategory] ?? 0;
                  displayedCountPerCategory[defectCategory] ??= 0;
                  int displayedCount =
                      displayedCountPerCategory[defectCategory]!;
                  bool showCancelIcon = defectCodeId.isNotEmpty &&
                      displayedCount < totalCountForCategory &&
                      widget.exInspectionRequest.equipmentTagRequest?.checkList
                              ?.expand((checkList) => checkList.defectCodes)
                              .any(
                                (defectCode) => defectCode.id == defectCodeId,
                              ) ==
                          true;
                  if (showCancelIcon) {
                    displayedCountPerCategory[defectCategory] =
                        displayedCount + 1;
                  }
                  List<Map<String, dynamic>> findingsAndActions =
                      (relatedDetail['findingsAndActions'] as List<dynamic>?)
                              ?.map((e) => e as Map<String, dynamic>)
                              .toList() ??
                          [];
                  for (var element in findingsAndActions) {
                    final String findingId = element['_id'];
                    bool isChecked = selectedFindings[findingId] ?? false;
                    if (isChecked) {
                      if (!selectedActionCollection.any(
                        (a) => a['_id'] == element['_id'],
                      )) {
                        var col = selectedChecklist.isNotEmpty
                            ? selectedChecklist
                            : widget.exInspectionRequest.equipmentTagRequest
                                    ?.checkList ??
                                [];
                        for (var category in col) {
                          for (var defect in category.defectCodes) {
                            for (var finding in defect.findingsAndActions) {
                              if (finding.id == findingId) {
                                element['finding'] = finding.finding;
                                element['remedialAction'] =
                                    finding.remedialAction;
                                element['defectCode'] = finding.defectCode;
                                element['defectCategory'] =
                                    finding.defectCategory;
                              }
                            }
                          }
                        }
                        selectedActionCollection.add(element);
                        relatedDetailsCollection.add(relatedDetail);
                      }
                    }
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 56,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                                horizontal: 24.0,
                              ),
                              margin: const EdgeInsets.only(left: 30.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEDF3F8),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              child: Text(
                                defectCode,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF353535),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  height: 22 / 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                ),
                                child: Text(
                                  parts.sublist(1).join(' '),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF353535),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                    height: 16 / 12,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 70.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: !widget.isEditModeNotifier.value
                                        ? null
                                        : () {
                                            setState(() {
                                              if (yesNoSelection[defectCode] ==
                                                  'yes') {
                                                yesNoSelection.remove(
                                                  defectCode,
                                                );
                                              } else {
                                                // Clear any existing "no" state
                                                yesNoSelection[defectCode] =
                                                    'yes';

                                                // Remove related findings and actions (clean 'no' state)
                                                List<Map<String, dynamic>>
                                                    findingsAndActions =
                                                    (relatedDetail['findingsAndActions']
                                                                as List<
                                                                    dynamic>?)
                                                            ?.map(
                                                              (e) => e as Map<
                                                                  String,
                                                                  dynamic>,
                                                            )
                                                            .toList() ??
                                                        [];

                                                for (var action
                                                    in findingsAndActions) {
                                                  final String findingId =
                                                      action['_id'];
                                                  selectedFindings.remove(
                                                    findingId,
                                                  );
                                                  selectedActionCollection
                                                      .removeWhere(
                                                    (a) =>
                                                        a['_id'] == findingId,
                                                  ); // Clear saved actions
                                                  untickedActionCollection
                                                      .removeWhere(
                                                    (a) =>
                                                        a['_id'] == findingId,
                                                  ); // Also clear unticked ones
                                                }

                                                relatedDetailsCollection
                                                    .removeWhere(
                                                  (r) =>
                                                      r['_id'] ==
                                                      relatedDetail['_id'],
                                                ); // Remove defect reference

                                                _expandedRows[defectCode] =
                                                    false;
                                                _defectValidationMap[
                                                    defectCode] = true;
                                              }
                                            });
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFF1F1F1),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x1A1B2029),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            yesNoSelection[defectCode] == 'yes'
                                                ? "lib/src/features/ex_inspections/assets/check_icon.svg"
                                                : "lib/src/features/ex_inspections/assets/empty_checkbox.svg",
                                            color: yesNoSelection[defectCode] ==
                                                    'yes'
                                                ? Colors.green
                                                : const Color(0xFFAAAFB4),
                                            width: yesNoSelection[defectCode] ==
                                                    'yes'
                                                ? 18
                                                : 20,
                                            height:
                                                yesNoSelection[defectCode] ==
                                                        'yes'
                                                    ? 18
                                                    : 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Yes",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF3B475B),
                                              height: 20 / 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: !widget.isEditModeNotifier.value
                                        ? null
                                        : () {
                                            setState(() {
                                              final selectedActions =
                                                  findingsAndActions
                                                      .where(
                                                        (action) =>
                                                            selectedFindings[
                                                                action[
                                                                    '_id']] ==
                                                            true,
                                                      )
                                                      .toList();
                                              if (selectedActions.isEmpty) {
                                                // Toggle if no finding selected
                                                if (_expandedRows[defectCode] ==
                                                    true) {
                                                  yesNoSelection.remove(
                                                    defectCode,
                                                  );
                                                  _expandedRows[defectCode] =
                                                      false;
                                                } else {
                                                  yesNoSelection[defectCode] =
                                                      'no';
                                                  _expandedRows[defectCode] =
                                                      true;
                                                }
                                                _defectValidationMap[
                                                    defectCode] = false;
                                              } else {
                                                if (_expandedRows[defectCode] ==
                                                    true) {
                                                  _expandedRows[defectCode] =
                                                      false;
                                                } else {
                                                  _expandedRows[defectCode] =
                                                      true; // keep open
                                                }
                                                yesNoSelection[defectCode] =
                                                    'no';

                                                _defectValidationMap[
                                                    defectCode] = true;
                                              }
                                            });
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFF1F1F1),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x1A1B2029),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            yesNoSelection[defectCode] == 'no'
                                                ? "lib/src/features/ex_inspections/assets/cancel_icon.svg"
                                                : "lib/src/features/ex_inspections/assets/empty_checkbox.svg",
                                            color: yesNoSelection[defectCode] ==
                                                    'no'
                                                ? Colors.red
                                                : const Color(0xFFAAAFB4),
                                            width: yesNoSelection[defectCode] ==
                                                    'no'
                                                ? 18
                                                : 20,
                                            height:
                                                yesNoSelection[defectCode] ==
                                                        'no'
                                                    ? 18
                                                    : 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "No",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF3B475B),
                                              height: 20 / 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _expandedRows[defectCode] == true
                          ? _buildNestedAccordion(
                              relatedDetail,
                              _expandedRows[defectCode],
                              defectCode,
                              setState,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 8),
                      const Divider(
                        color: Color(0xFFF2F2F7),
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNestedAccordion(
    Map<String, dynamic> relatedDetails,
    bool? expandedRow,
    String keyDefectCode,
    void Function(VoidCallback fn) parentSetState,
  ) {
    List<Map<String, dynamic>> findingsAndActions =
        (relatedDetails['findingsAndActions'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

    yesNoSelection[keyDefectCode] == 'no';

    // Tracks new user-added custom rows per defect code
    // Each entry: { 'id': String, 'findingCtrl': TextEditingController, 'remedialCtrl': TextEditingController, 'confirmed': bool }
    final String customRowsKey = 'customRows_$keyDefectCode';
    if (!relatedDetails.containsKey(customRowsKey)) {
      relatedDetails[customRowsKey] = <Map<String, dynamic>>[];
    }
    final List<Map<String, dynamic>> customRows =
        relatedDetails[customRowsKey] as List<Map<String, dynamic>>;

    InputDecoration editFieldDecoration() => const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38),
          ),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38),
          ),
        );

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: const Color(0xFFD0D3D8),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Table header ──────────────────────────────────
                      Container(
                        height: 40,
                        color: const Color(0xFF4682B4),
                        child: Row(
                          children: [
                            // Findings header
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 56.0),
                                child: Text(
                                  'Findings',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(width: 1, color: const Color(0xFFD0D3D8)),
                            // Remedial Actions header
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Remedial Actions',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(width: 1, color: const Color(0xFFD0D3D8)),
                            // +Add button in header
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  final newId =
                                      '_customRow_${DateTime.now().millisecondsSinceEpoch}';
                                  String dCategory = relatedDetails['defectCategory'] ?? '';
                                  if (dCategory.isEmpty && findingsAndActions.isNotEmpty) {
                                    dCategory = findingsAndActions.first['defectCategory'] ?? '';
                                  }
                                  if (dCategory.isEmpty) {
                                    dCategory = relatedDetails['checkListGroup'] ?? 'General Defect';
                                  }
                                  customRows.add({
                                    'id': newId,
                                    'defectCode': relatedDetails['defectCode'] ?? keyDefectCode,
                                    'defectCategory': dCategory,
                                    'findingCtrl': TextEditingController(),
                                    'remedialCtrl': TextEditingController(),
                                    'confirmed': false,
                                  });
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4682B4),
                                  border: Border.all(
                                    color: Colors.white70,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+Add',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Pre-defined rows from server ───────────────────
                      ...findingsAndActions.map<Widget>((action) {
                        final String findingId = action['_id'];
                        bool isChecked = selectedFindings[findingId] ?? false;
                        return Container(
                          decoration: BoxDecoration(
                            color: isChecked
                                ? const Color(0xFFEAF4FC)
                                : Colors.white,
                            border: const Border(
                              bottom: BorderSide(
                                color: Color(0xFFD0D3D8),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Findings cell
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 6.0,
                                    ),
                                    child: Row(
                                      children: [
                                        CustomRadioButton(
                                          value: isChecked,
                                          onChanged: (bool value) {
                                            setState(() {
                                              selectedFindings[findingId] =
                                                  value;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () {
                                              setState(() {
                                                selectedFindings[findingId] =
                                                    !isChecked;
                                              });
                                            },
                                            child: Text(
                                              action['finding'] ?? '',
                                              style: GoogleFonts.inter(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                                height: 21 / 14,
                                                letterSpacing: 0.03,
                                                color: const Color(0xFF353535),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  color: const Color(0xFFD0D3D8),
                                ),
                                // Remedial Actions cell
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 6.0,
                                    ),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setState(() {
                                          selectedFindings[findingId] =
                                              !isChecked;
                                        });
                                      },
                                      child: Text(
                                        action['remedialAction'] ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400,
                                          height: 21 / 14,
                                          letterSpacing: 0.03,
                                          color: const Color(0xFF353535),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  color: const Color(0xFFD0D3D8),
                                ),
                                // Empty action cell (no edit button)
                                const SizedBox(width: 72),
                              ],
                            ),
                          ),
                        );
                      }),
                      // ── User-added custom rows ─────────────────────────
                      ...customRows.map<Widget>((row) {
                        final TextEditingController findingCtrl =
                            row['findingCtrl'] as TextEditingController;
                        final TextEditingController remedialCtrl =
                            row['remedialCtrl'] as TextEditingController;
                        final bool confirmed = row['confirmed'] as bool;
                        final String rowId = row['id'] as String;

                        void syncCustomRow(bool isSelected) {
                          final dCode = row['defectCode'] ?? relatedDetails['defectCode'] ?? keyDefectCode;
                          String dCategory = (row['defectCategory'] != null && row['defectCategory'].toString().isNotEmpty)
                              ? row['defectCategory']
                              : (relatedDetails['defectCategory'] != null && relatedDetails['defectCategory'].toString().isNotEmpty)
                                  ? relatedDetails['defectCategory']
                                  : (findingsAndActions.isNotEmpty && findingsAndActions.first['defectCategory'] != null)
                                      ? findingsAndActions.first['defectCategory']
                                      : (relatedDetails['checkListGroup'] ?? 'General Defect');

                          final findingText = findingCtrl.text.trim().isEmpty ? 'Defect Note' : findingCtrl.text.trim();
                          final remedialText = remedialCtrl.text.trim().isEmpty ? 'Remedial Action' : remedialCtrl.text.trim();

                          final customAction = {
                            '_id': rowId,
                            'defectCode': dCode,
                            'defectCategory': dCategory,
                            'finding': findingText,
                            'remedialAction': remedialText,
                            'isCustom': true,
                          };

                          selectedFindings[rowId] = isSelected;
                          selectedActionCollection.removeWhere((a) => a['_id'] == rowId);
                          if (isSelected) {
                            selectedActionCollection.add(customAction);
                            yesNoSelection[dCode] = 'no';
                            _defectValidationMap[dCode] = true;
                          }
                        }

                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFD0D3D8),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Custom Finding cell
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 6.0,
                                    ),
                                    child: Row(
                                      children: [
                                        CustomRadioButton(
                                          value:
                                              selectedFindings[rowId] ?? false,
                                          onChanged: (bool value) {
                                            setState(() {
                                              syncCustomRow(value);
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: confirmed
                                              ? Text(
                                                  findingCtrl.text,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        const Color(0xFF353535),
                                                  ),
                                                )
                                              : TextFormField(
                                                  controller: findingCtrl,
                                                  decoration:
                                                      editFieldDecoration(),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  color: const Color(0xFFD0D3D8),
                                ),
                                // Custom Remedial Action cell
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 6.0,
                                    ),
                                    child: confirmed
                                        ? Text(
                                            remedialCtrl.text,
                                            style: GoogleFonts.inter(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF353535),
                                            ),
                                          )
                                        : TextFormField(
                                            controller: remedialCtrl,
                                            decoration: editFieldDecoration(),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                            ),
                                          ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  color: const Color(0xFFD0D3D8),
                                ),
                                // Tick + Delete action buttons (hidden when confirmed)
                                SizedBox(
                                  width: 72,
                                  child: confirmed
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF002B5C),
                                            size: 20,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Tick (confirm) button
                                            InkWell(
                                              onTap: () {
                                                if (findingCtrl.text.trim().isEmpty &&
                                                    remedialCtrl.text.trim().isEmpty) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Please enter finding or remedial action.',
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                  );
                                                  return;
                                                }
                                                setState(() {
                                                  row['confirmed'] = true;
                                                  syncCustomRow(true);
                                                });
                                                Fluttertoast.showToast(
                                                  msg:
                                                      'Remedial action saved successfully.',
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                );
                                              },
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Delete button
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  customRows.removeWhere(
                                                    (r) => r['id'] == rowId,
                                                  );
                                                  selectedFindings.remove(rowId);
                                                  selectedActionCollection
                                                      .removeWhere(
                                                    (a) => a['_id'] == rowId,
                                                  );
                                                });
                                              },
                                              child: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 140.0,
                  top: 20.0,
                  bottom: 12,
                  left: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () {
                          final untickedActions = findingsAndActions
                              .where(
                                (action) =>
                                    selectedFindings[action['_id']] == true,
                              )
                              .toList();

                          setState(() {
                            selectedFindings.clear();
                          });

                          yesNoSelection.remove(keyDefectCode);

                          onSubmitEquipmentTag(
                            [],
                            untickedActions,
                            relatedDetails,
                            'empty',
                          );
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: Color(0xFF002B5C),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF002B5C),
                            width: 1.0,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () {
                          final selectedActions = findingsAndActions
                              .where(
                                (action) =>
                                    selectedFindings[action['_id']] == true,
                              )
                              .toList();

                          final List<Map<String, dynamic>> selectedCustomActions = [];
                          for (var customRow in customRows) {
                            final String rId = customRow['id'] as String;
                            if (selectedFindings[rId] == true || customRow['confirmed'] == true) {
                              final TextEditingController fCtrl = customRow['findingCtrl'] as TextEditingController;
                              final TextEditingController rCtrl = customRow['remedialCtrl'] as TextEditingController;
                              String dCat = (customRow['defectCategory'] != null && customRow['defectCategory'].toString().isNotEmpty)
                                  ? customRow['defectCategory']
                                  : (relatedDetails['defectCategory'] != null && relatedDetails['defectCategory'].toString().isNotEmpty)
                                      ? relatedDetails['defectCategory']
                                      : (findingsAndActions.isNotEmpty && findingsAndActions.first['defectCategory'] != null)
                                          ? findingsAndActions.first['defectCategory']
                                          : (relatedDetails['checkListGroup'] ?? 'General Defect');

                              selectedCustomActions.add({
                                '_id': rId,
                                'defectCode': customRow['defectCode'] ?? keyDefectCode,
                                'defectCategory': dCat,
                                'finding': fCtrl.text.trim().isEmpty ? 'Defect Note' : fCtrl.text.trim(),
                                'remedialAction': rCtrl.text.trim().isEmpty ? 'Remedial Action' : rCtrl.text.trim(),
                                'isCustom': true,
                              });
                            }
                          }

                          final untickedActions = findingsAndActions
                              .where(
                                (action) =>
                                    selectedFindings[action['_id']] != true,
                              )
                              .toList();

                          if (selectedActions.isEmpty && selectedCustomActions.isEmpty) {
                            _defectValidationMap[keyDefectCode] = false;
                            Fluttertoast.showToast(
                              msg: "Please select at least one defect findings",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 15.0,
                            );
                            return;
                          }

                          yesNoSelection[keyDefectCode] = 'no';
                          _defectValidationMap[keyDefectCode] = true;

                          for (var action in selectedActions) {
                            if (!selectedActionCollection.any(
                              (a) => a['_id'] == action['_id'],
                            )) {
                              selectedActionCollection.add(action);
                            }
                          }

                          for (var cAction in selectedCustomActions) {
                            if (!selectedActionCollection.any(
                              (a) => a['_id'] == cAction['_id'],
                            )) {
                              selectedActionCollection.add(cAction);
                            }
                          }

                          for (var action in untickedActions) {
                            if (!untickedActionCollection.any(
                              (a) => a['_id'] == action['_id'],
                            )) {
                              untickedActionCollection.add(action);
                            }

                            selectedActionCollection.removeWhere(
                              (a) => a['_id'] == action['_id'],
                            );
                          }

                          if (!relatedDetailsCollection.any(
                            (a) => a['_id'] == relatedDetails['_id'],
                          )) {
                            relatedDetailsCollection.add(relatedDetails);
                          }

                          setState(() {
                            _expandedRows[keyDefectCode] = false;
                          });
                          parentSetState(() {
                            _expandedRows[keyDefectCode] = false;
                          });
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Color(0xFF002B5C),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String getZoneCategory(String zone) {
    switch (zone) {
      case "Zone 0":
      case "Zone 1":
      case "Class 1,Div 1":
        return "1";
      case "Zone 2":
      case "Safe":
      case "Class 1,Div 2":
      case "Not Available":
      case "Not Applicable":
        return "2";
      default:
        return "1";
    }
  }

  bool checkDateFormat(String input) {
    try {
      final format = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss",
      ); // "dd-MM-yyyy hh:mm a"); //DateFormat("dd MMM yy HH:mm 'Hrs'");
      final parsedDate = format.parse(input);
      final formattedDate = format.format(parsedDate);
      return input == formattedDate;
    } catch (e) {
      return false;
    }
  }

  bool isAnyLabelMissing(
    Map<String, dynamic> yesNoSelection,
    List<dynamic> labelCollection,
  ) {
    for (var label in labelCollection) {
      if (!yesNoSelection.containsKey(label)) {
        return false; // A label is missing in the map
      }
    }
    return true; // All labels are present in the map
  }

  String getFromCollection(
    List<Map<String, dynamic>> collection,
    String key,
    String code,
  ) {
    final match = collection.firstWhere(
      (item) => item.containsKey(key) && item['defectCode'] == code,
      orElse: () => {},
    );
    return match[key] ?? '';
  }

  // String _normYesNo(dynamic v) {
  //   if (v == null) return '';
  //   final s = v.toString().trim().toLowerCase();
  //   if (s == 'yes' || s == '1' || s == 'true') return 'yes';
  //   if (s == 'no' || s == '0' || s == 'false') return 'no';
  //   return s; // passes through "yes" / "no" already
  // }

  void onSubmitEquipmentTag(
    List<Map<String, dynamic>> selectedActions,
    List<Map<String, dynamic>> untickedActions,
    Map<String, dynamic> relatedDetails,
    String flag, {
    bool skipValidation = false,
  }) async {
    if (widget.isEditModeNotifier.value) {
      if (flag.trim() != "empty") {
        if (yesNoSelection.isEmpty) {
          Fluttertoast.showToast(
            msg: 'Please answer all the checklists.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0,
          );

          return;
        }

        final List<String> missingCodes = [];

        for (var code in checkDefectCode) {
          if (!yesNoSelection.containsKey(code) ||
              yesNoSelection[code] == null ||
              yesNoSelection[code].toString().trim().isEmpty) {
            missingCodes.add(code);
          }
        }

        if (missingCodes.isNotEmpty) {
          // final String missingList = missingCodes.join(', ');
          Fluttertoast.showToast(
            msg: "Please answer all the checklists",
            // '$missingList ${missingCodes.length == 1 ? "is" : "are"} not selected.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0,
          );

          return;
        }
      }
    }

    for (var detail in relatedDetailsCollection) {
      final String dCode = detail['defectCode'] ?? '';
      final String customKey = 'customRows_$dCode';
      if (detail.containsKey(customKey)) {
        final List<dynamic> cRows = detail[customKey] as List<dynamic>;
        for (var row in cRows) {
          final String rId = row['id'] as String;
          if (selectedFindings[rId] == true || row['confirmed'] == true) {
            final TextEditingController fCtrl = row['findingCtrl'] as TextEditingController;
            final TextEditingController rCtrl = row['remedialCtrl'] as TextEditingController;
            String dCat = (row['defectCategory'] != null && row['defectCategory'].toString().isNotEmpty)
                ? row['defectCategory']
                : (detail['defectCategory'] != null && detail['defectCategory'].toString().isNotEmpty)
                    ? detail['defectCategory']
                    : (detail['checkListGroup'] ?? 'General Defect');

            final customActionMap = {
              '_id': rId,
              'defectCode': dCode,
              'defectCategory': dCat,
              'finding': fCtrl.text.trim().isEmpty ? 'Defect Note' : fCtrl.text.trim(),
              'remedialAction': rCtrl.text.trim().isEmpty ? 'Remedial Action' : rCtrl.text.trim(),
              'isCustom': true,
            };

            if (!selectedActionCollection.any((a) => a['_id'] == rId)) {
              selectedActionCollection.add(customActionMap);
            }
            yesNoSelection[dCode] = 'no';
            _defectValidationMap[dCode] = true;
          }
        }
      }
    }

    for (var entry in yesNoSelection.entries) {
      if (entry.value == 'no') {
        bool hasSelectedAction = selectedActionCollection.any((a) => a['defectCode'] == entry.key);
        if (hasSelectedAction) {
          _defectValidationMap[entry.key] = true;
        }
      }
    }

    bool hasInvalid = _defectValidationMap.values.any(
      (isValid) => isValid == false,
    );
    if (hasInvalid) {
      final incompleteDefects = _defectValidationMap.entries
          .where((entry) => entry.value == false)
          .map((entry) => entry.key)
          .toList();
      Fluttertoast.showToast(
        msg: "Incomplete defects: ${incompleteDefects.join(", ")}",
        // '$missingList ${missingCodes.length == 1 ? "is" : "are"} not selected.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0,
      );

      return;
    }

    List<dynamic> labelCollection = [];
    for (var element in relatedCollections) {
      final detailsContent = element.isNotEmpty
          ? element
              .map(
                (detail) =>
                    '${detail['defectCode']} ${detail['checkListGroup']}',
              )
              .join('\n')
          : '';
      for (var detailsContentelement in detailsContent.split('\n')) {
        final parts = detailsContentelement.split(' ');
        final defectCode = parts.isNotEmpty ? parts[0] : 'Unknown Code';
        if (!labelCollection.contains(defectCode)) {
          labelCollection.add(defectCode);
        }
      }
    }
    bool result = isAnyLabelMissing(yesNoSelection, labelCollection);
    // if (!result) {
    //   skipValidation = true;
    // }
    // bool allNoSelectionsHaveActions = yesNoSelection.entries
    //     .where((entry) => entry.value == 'no')
    //     .every((entry) {
    //   return selectedActionCollection.any((action) {
    //     return action['defectCode'] == entry.key;
    //   });
    // });

    checkLableFlag = result;
    // checklistAnyoneCheck = allNoSelectionsHaveActions;
    setState(() {
      _isSubmitting = !skipValidation;
    });
    // &&
    //     !checklistAnyoneCheck
    if (!skipValidation && !formKey.currentState!.validate() && result) {
      return;
    }

    for (var untickedAction in untickedActionCollection) {
      _removeUntickedFindings(untickedAction, relatedDetails);
    }
    List<CheckList> existingChecklist =
        widget.exInspectionRequest.equipmentTagRequest?.checkList ?? [];
    Map<String, CheckList> existingCategoriesMap = Map.fromEntries(
      existingChecklist.map(
        (checklist) => MapEntry(checklist.defectCategory, checklist),
      ),
    );

    Map<String, Map<String, List<FindingAndAction>>> groupedActions = {};
    Map<String, Map<String, Map<String, dynamic>>> groupedPriorities = {};
    String zoneCategory = getZoneCategory(
      widget.exInspectionRequest.functionalAreaRequest?.zone ?? 'Zone 1',
    );

    for (var action in selectedActionCollection) {
      var defectCategory = action['defectCategory'] ?? '';
      var defectCode = action['defectCode'] ?? '';
      if (defectCategory.isNotEmpty && defectCode.isNotEmpty) {
        groupedActions.putIfAbsent(defectCategory, () => {});
        groupedActions[defectCategory]!.putIfAbsent(defectCode, () => []);
        groupedActions[defectCategory]![defectCode]!.add(
          FindingAndAction(
            id: action['_id'] ?? '',
            defectCode: defectCode,
            finding: action['finding'] ?? '',
            remedialAction: action['remedialAction'] ?? '',
            defectCategory: defectCategory,
            isSelected: true,
          ),
        );
        for (final detail in relatedDetailsCollection) {
          if (detail.containsKey('defectPriority') &&
              detail['defectCode'] == defectCode) {
            groupedPriorities.putIfAbsent(defectCategory, () => {});

            var defectPriorityList = detail['defectPriority'] as List<dynamic>;

            var filteredPriority = defectPriorityList.firstWhere(
              (e) =>
                  (e as Map<String, dynamic>)['zoneCategory'] == zoneCategory,
              orElse: () => {'zoneCategory': zoneCategory, 'priority': 1},
            );

            groupedPriorities[defectCategory]![defectCode] = filteredPriority;

            break; // Stop after first match, remove this if multiple entries are expected
          }
        }
        //  if (relatedDetailsCollection.containsKey('defectPriority')) {
        //   groupedPriorities.putIfAbsent(defectCategory, () => {});
        //   var defectPriorityList =
        //       relatedDetailsCollection['defectPriority'] as List<dynamic>;
        //   var filteredPriority = defectPriorityList.firstWhere(
        //       (e) =>
        //           (e as Map<String, dynamic>)['zoneCategory'] == zoneCategory,
        //       orElse: () => {'zoneCategory': zoneCategory, 'priority': 1});
        //   groupedPriorities[defectCategory]![defectCode] = filteredPriority;
        // }
      }
    }
    List<CheckList> updatedChecklist = [];
    // Helper function to merge old and new FindingAndAction objects
    List<FindingAndAction> mergeFindingsAndActions(
      List<FindingAndAction> oldList,
      List<FindingAndAction> newList,
    ) {
      final Map<String, FindingAndAction> mergedMap = {
        for (var f in oldList) f.id: f,
      };

      for (var newAction in newList) {
        if (mergedMap.containsKey(newAction.id)) {
          final old = mergedMap[newAction.id]!;
          mergedMap[newAction.id] = FindingAndAction(
            id: newAction.id,
            defectCode: newAction.defectCode,
            finding:
                newAction.finding.isNotEmpty ? newAction.finding : old.finding,
            remedialAction: newAction.remedialAction.isNotEmpty
                ? newAction.remedialAction
                : old.remedialAction,
            defectCategory: newAction.defectCategory,
            isSelected: newAction.isSelected || old.isSelected,
            isDone: old.isDone,
            repairedAt: old.repairedAt,
            repairedBy: old.repairedBy,
          );
        } else {
          mergedMap[newAction.id] = newAction;
        }
      }

      return mergedMap.values.toList();
    }

    for (var category in groupedActions.keys) {
      if (existingCategoriesMap.containsKey(category)) {
        var defectCategory = existingCategoriesMap[category]!;

        for (var defectCode in groupedActions[category]!.keys) {
          var defectCodeItem = defectCategory.defectCodes.firstWhere(
            (d) => d.defectCode == defectCode,
            orElse: () => DefectCode(
              id: relatedDetails['_id'] ?? '',
              checkListGroup: getFromCollection(
                relatedDetailsCollection,
                'checkListGroup',
                defectCode,
              ),
              equipmentType: getFromCollection(
                relatedDetailsCollection,
                'equipmentType',
                defectCode,
              ),
              checklistName: getFromCollection(
                relatedDetailsCollection,
                'checklistName',
                defectCode,
              ),
              inspectionGrade: getFromCollection(
                relatedDetailsCollection,
                'inspectionGrade',
                defectCode,
              ),
              inspectionType: getFromCollection(
                relatedDetailsCollection,
                'inspectionType',
                defectCode,
              ),
              defectCode: defectCode,
              findingsAndActions: [],
              defectPriority: {},
              yesNoSelection: yesNoSelection[defectCode] ?? '',
            ),
          );

          defectCodeItem.findingsAndActions = mergeFindingsAndActions(
            defectCodeItem.findingsAndActions,
            groupedActions[category]![defectCode]!,
          );
          if (groupedPriorities.containsKey(category) &&
              groupedPriorities[category]!.containsKey(defectCode)) {
            defectCodeItem.defectPriority =
                groupedPriorities[category]![defectCode]!;
          }

          var existingIndex = defectCategory.defectCodes.indexWhere(
            (d) => d.defectCode == defectCode,
          );

          if (existingIndex != -1) {
            defectCategory.defectCodes[existingIndex].findingsAndActions =
                mergeFindingsAndActions(
              defectCategory.defectCodes[existingIndex].findingsAndActions,
              groupedActions[category]![defectCode]!,
            );
            defectCategory.defectCodes[existingIndex].defectPriority =
                groupedPriorities[category]?[defectCode] ?? {};
          } else {
            defectCategory.defectCodes.add(defectCodeItem);
          }
        }

        defectCategory.count = defectCategory.defectCodes.length;
        updatedChecklist.add(defectCategory);
      } else {
        // Create new defectCategory
        var defectCodes = groupedActions[category]!.entries.map((entry) {
          return DefectCode(
            id: getFromCollection(relatedDetailsCollection, '_id', entry.key),
            checkListGroup: getFromCollection(
              relatedDetailsCollection,
              'checkListGroup',
              entry.key,
            ),
            equipmentType: getFromCollection(
              relatedDetailsCollection,
              'equipmentType',
              entry.key,
            ),
            checklistName: getFromCollection(
              relatedDetailsCollection,
              'checklistName',
              entry.key,
            ),
            inspectionGrade: getFromCollection(
              relatedDetailsCollection,
              'inspectionGrade',
              entry.key,
            ),
            inspectionType: getFromCollection(
              relatedDetailsCollection,
              'inspectionType',
              entry.key,
            ),
            defectCode: entry.key,
            findingsAndActions: entry.value, // no merge needed, it's new
            defectPriority: groupedPriorities[category]![entry.key] ?? {},
            yesNoSelection: yesNoSelection[entry.key] ?? '',
          );
        }).toList();

        var newCategory = CheckList(
          defectCategory: category,
          count: defectCodes.length,
          defectCodes: defectCodes,
        );
        updatedChecklist.add(newCategory);
      }
    }

    updatedChecklist = updatedChecklist
        .where(
          (category) => category.defectCodes.any(
            (code) => code.findingsAndActions.isNotEmpty,
          ),
        )
        .toList();
    for (var checklistItem in existingChecklist) {
      checklistItem.defectCodes.removeWhere((defect) {
        var yesNoValue = yesNoSelection[defect.defectCode]?.toString() ?? '';
        return yesNoValue != defect.yesNoSelection.toString();
      });
    }

    updatedChecklist.addAll(
      existingChecklist.where(
        (checklist) => !groupedActions.containsKey(checklist.defectCategory),
      ),
    );
    int? minPriority;
    int inspectionFaltlyCount = 0;
    int completedCount = 0;
    int? correctivePriority;
    int totalDefects = 0;
    for (var category in updatedChecklist) {
      for (var defectCode in category.defectCodes) {
        if (defectCode.defectPriority.containsKey('priority')) {
          int priority = defectCode.defectPriority['priority'];
          bool hasIncomplete = false;
          // Count findings and check completion
          for (var finding in defectCode.findingsAndActions) {
            totalDefects++;
            if (finding.isDone) {
              completedCount++;
            } else {
              hasIncomplete = true;
            }
          }
          inspectionFaltlyCount += defectCode.findingsAndActions.length;
          // bool hasIncomplete =
          //     defectCode.findingsAndActions.any((finding) => !finding.isDone);

          // if (hasIncomplete) {
          if (minPriority == null || priority < minPriority) {
            minPriority = priority;
          }
          // }
          if (hasIncomplete) {
            if (correctivePriority == null || priority < correctivePriority) {
              correctivePriority = priority;
            }
          }
        }
      }
    }
    bool isAllSelectionsEmpty = _selectedInspectionType.toString().isEmpty &&
        _selectedEquipmentType.toString().isEmpty &&
        selectedInspectionChecklist.isEmpty &&
        // _selectedInspectionChecklist.toString().isEmpty &&
        _selectedInspectionGrade.toString().isEmpty;
    bool isChecklistEmpty = updatedChecklist.isEmpty;
    widget.exInspectionRequest.equipmentTagRequest?.defectDefectCategory =
        isChecklistEmpty ? "Not Applicable" : minPriority.toString();
    if (isAllSelectionsEmpty) {
      widget.exInspectionRequest.equipmentTagRequest?.correctiveDefectCategory =
          "";
      widget.exInspectionRequest.equipmentTagRequest?.existingFaults = "";
      widget.exInspectionRequest.equipmentTagRequest
          ?.correctiveOverallCondition = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairTimeEstimate = '';
      widget.exInspectionRequest.equipmentTagRequest?.repairsDone = " ";
      widget.exInspectionRequest.equipmentTagRequest?.defectOverallCondition =
          '';
      widget.exInspectionRequest.equipmentTagRequest?.repairDuration = '';
      widget.exInspectionRequest.equipmentTagRequest?.faultyItems = "";
    } else if (isChecklistEmpty) {
      widget.exInspectionRequest.equipmentTagRequest?.correctiveDefectCategory =
          "Not Applicable";
      widget.exInspectionRequest.equipmentTagRequest?.existingFaults = "0";
      widget.exInspectionRequest.equipmentTagRequest?.repairsDone = 0;
      widget.exInspectionRequest.equipmentTagRequest?.faultyItems = 0;
      widget.exInspectionRequest.equipmentTagRequest?.repairedDate = "";
      widget.exInspectionRequest.equipmentTagRequest?.inspectedDate = "";
    } else {
      final existingFaults =
          widget.exInspectionRequest.equipmentTagRequest?.existingFaults;
      final repairsDone =
          widget.exInspectionRequest.equipmentTagRequest?.repairsDone;
      if (existingFaults != null &&
          int.tryParse(existingFaults.toString()) != null &&
          int.parse(existingFaults.toString()) != 0) {
        if (repairsDone != null && int.tryParse(repairsDone.toString()) == 0) {
          widget.exInspectionRequest.equipmentTagRequest
                  ?.correctiveDefectCategory =
              widget.exInspectionRequest.equipmentTagRequest
                  ?.defectDefectCategory;
        } else {
          widget.exInspectionRequest.equipmentTagRequest
                  ?.correctiveDefectCategory =
              correctivePriority != null
                  ? correctivePriority.toString()
                  : "Not Applicable";
        }
      } else {
        widget.exInspectionRequest.equipmentTagRequest
                ?.correctiveDefectCategory =
            correctivePriority != null
                ? correctivePriority.toString()
                : "Not Applicable";
      }

      widget.exInspectionRequest.equipmentTagRequest?.existingFaults =
          (totalDefects - completedCount).toString();
      widget.exInspectionRequest.equipmentTagRequest?.repairsDone =
          completedCount.toString();
      widget.exInspectionRequest.equipmentTagRequest?.faultyItems =
          inspectionFaltlyCount.toString();
    }

    String? defectCategory =
        widget.exInspectionRequest.equipmentTagRequest?.defectDefectCategory;
    if (!isAllSelectionsEmpty && !isChecklistEmpty) {
      if (defectCategory == null ||
          defectCategory.isEmpty ||
          defectCategory == 'Not Applicable') {
        widget.exInspectionRequest.equipmentTagRequest
            ?.correctiveOverallCondition = 'Good to Use';
        widget.exInspectionRequest.equipmentTagRequest?.repairTimeEstimate =
            'Not Applicable';
        widget.exInspectionRequest.equipmentTagRequest?.defectOverallCondition =
            'Good to Use';
        widget.exInspectionRequest.equipmentTagRequest?.repairDuration =
            'Not Applicable';
      } else {
        int priority = int.tryParse(defectCategory) ?? 0;
        if (priority <= 2) {
          widget.exInspectionRequest.equipmentTagRequest
              ?.correctiveOverallCondition = 'Major Repair Required';
          widget.exInspectionRequest.equipmentTagRequest
              ?.defectOverallCondition = 'Major Repair Required';
        } else if (priority <= 5) {
          widget.exInspectionRequest.equipmentTagRequest
              ?.correctiveOverallCondition = 'Minor Repair Required';
          widget.exInspectionRequest.equipmentTagRequest
              ?.defectOverallCondition = 'Minor Repair Required';
        } else {
          widget.exInspectionRequest.equipmentTagRequest
              ?.correctiveOverallCondition = 'Good to Use';
          widget.exInspectionRequest.equipmentTagRequest
              ?.defectOverallCondition = 'Good to Use';
        }

        if (priority > 5) {
          widget.exInspectionRequest.equipmentTagRequest?.repairTimeEstimate =
              widget.exInspectionRequest.equipmentTagRequest!.repairTimeEstimate
                          .toString() ==
                      'Not Applicable'
                  ? ''
                  : widget.exInspectionRequest.equipmentTagRequest
                      ?.repairTimeEstimate;
          widget.exInspectionRequest.equipmentTagRequest?.repairDuration =
              widget.exInspectionRequest.equipmentTagRequest!.repairDuration
                          .toString() ==
                      'Not Applicable'
                  ? ''
                  : widget
                      .exInspectionRequest.equipmentTagRequest?.repairDuration;
        }
      }
    }

    // Determine inspection status and current status
    String inStatus = '';
    String cuStatus = '';

    if (!isAllSelectionsEmpty && !isChecklistEmpty) {
      int priority =
          widget.exInspectionRequest.equipmentTagRequest?.inspectionPriority ==
                  null
              ? (minPriority ?? 0)
              : 0;
      int cusPriority = (int.tryParse(
                widget.exInspectionRequest.equipmentTagRequest?.repairsDone
                        .toString() ??
                    "0",
              ) ==
              0)
          ? int.tryParse(
                widget.exInspectionRequest.equipmentTagRequest
                        ?.defectDefectCategory ??
                    "0",
              ) ??
              0
          : int.tryParse(
                widget.exInspectionRequest.equipmentTagRequest
                        ?.correctiveDefectCategory ??
                    "0",
              ) ??
              0;

      inStatus = (priority <= 2)
          ? 'Red'
          : (priority <= 5)
              ? 'Yellow'
              : 'Green';

      final existingFaults =
          widget.exInspectionRequest.equipmentTagRequest?.existingFaults;
      bool isZeroFaults = existingFaults != null &&
          int.tryParse(existingFaults.toString()) == 0;
      if (cusPriority <= 2) {
        cuStatus = isZeroFaults ? 'Green' : 'Red';
      } else if (cusPriority <= 5) {
        cuStatus = isZeroFaults ? 'Green' : 'Yellow';
      } else {
        cuStatus = 'Green';
      }
    } else {
      if (isAllSelectionsEmpty) {
        inStatus = '';
        cuStatus = '';
      } else {
        inStatus = 'Green';
        cuStatus = 'Green';
      }
    }
    final Set<String> defectCodesWithFindings = updatedChecklist
        .expand((category) => category.defectCodes)
        .where((code) => code.findingsAndActions.isNotEmpty)
        .map((code) => code.defectCode)
        .toSet();
    yesNoSelection.removeWhere(
      (defectCode, value) =>
          value == 'no' && !defectCodesWithFindings.contains(defectCode),
    );
    _expandedRows.removeWhere(
      (defectCode, value) =>
          value == true && !defectCodesWithFindings.contains(defectCode),
    );
    setState(() {
      selectedChecklist.clear();
      selectedChecklist = updatedChecklist;
    });
    widget.exInspectionRequest.equipmentTagRequest = EquipmentTagRequest(
      faultyItems: widget.exInspectionRequest.equipmentTagRequest?.faultyItems,
      defectDefectCategory:
          widget.exInspectionRequest.equipmentTagRequest?.defectDefectCategory,
      inspectionStatus: inStatus,
      correctiveDefectCategory: widget
          .exInspectionRequest.equipmentTagRequest?.correctiveDefectCategory,
      currentStatus: cuStatus,
      checkList: updatedChecklist,
      inspectionPriority: (widget.exInspectionRequest.equipmentTagRequest
                      ?.inspectionPriority ==
                  null ||
              widget.exInspectionRequest.equipmentTagRequest!.inspectionPriority
                  .toString()
                  .isEmpty ||
              widget.exInspectionRequest.equipmentTagRequest!
                      .inspectionPriority !=
                  minPriority)
          ? minPriority
          : widget.exInspectionRequest.equipmentTagRequest!.inspectionPriority,
      inspectionChecklistType:
          selectedInspectionChecklist, //  _selectedInspectionChecklist,
      inspectionGrade: _selectedInspectionGrade,
      inspectionType: _selectedInspectionType,
      equipmentEquipmentType: _selectedEquipmentType,
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
      areaStatus: widget.exInspectionRequest.functionalAreaRequest!.areaStatus,
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
      inspectionSignOff:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionSignOff,
      repairSignOff:
          widget.exInspectionRequest.equipmentTagRequest?.repairSignOff,
      specialCond: widget.exInspectionRequest.equipmentTagRequest?.specialCond,
      oracleId: widget.exInspectionRequest.equipmentTagRequest?.oracleId,
      assetId: widget.exInspectionRequest.equipmentTagRequest?.assetId,
      yesNoSelection: yesNoSelection,
      defectOverallCondition: widget
          .exInspectionRequest.equipmentTagRequest?.defectOverallCondition,
      defectIsolation:
          widget.exInspectionRequest.equipmentTagRequest?.defectIsolation,
      defectOtherRequirements: widget
          .exInspectionRequest.equipmentTagRequest!.defectOtherRequirements,
      remarks: widget.exInspectionRequest.equipmentTagRequest?.remarks,
      defectCertificationNo:
          widget.exInspectionRequest.equipmentTagRequest?.defectCertificationNo,
      defectCertificationOrgName: widget
          .exInspectionRequest.equipmentTagRequest?.defectCertificationOrgName,
      dataSheet: widget.exInspectionRequest.equipmentTagRequest?.dataSheet,
      dataSheetOrgName:
          widget.exInspectionRequest.equipmentTagRequest?.dataSheetOrgName,
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
      existingFaults:
          widget.exInspectionRequest.equipmentTagRequest?.existingFaults,

      // widget.exInspectionRequest.equipmentTagRequest?.currentStatus,
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
      repairedBy: widget.exInspectionRequest.equipmentTagRequest?.repairedBy,
      repairedDate:
          widget.exInspectionRequest.equipmentTagRequest?.repairedDate,
      supplementaryMaterialReq: widget
          .exInspectionRequest.equipmentTagRequest?.supplementaryMaterialReq,
      materials: widget.exInspectionRequest.equipmentTagRequest?.materials,

      inspectedBy: widget.exInspectionRequest.equipmentTagRequest?.inspectedBy,
      inspectedDate:
          widget.exInspectionRequest.equipmentTagRequest?.inspectedDate,
      subArea: widget.exInspectionRequest.equipmentTagRequest?.subArea,
      rbiStrategy: widget.exInspectionRequest.equipmentTagRequest?.rbiStrategy,
      areaClassDrawAttach:
          widget.exInspectionRequest.functionalAreaRequest?.areaClassDrawAttach ?? [],
      areaClassDrawNo:
          widget.exInspectionRequest.functionalAreaRequest?.areaClassDrawNo ?? [],
      eqpmtLytDrawAttach:
          widget.exInspectionRequest.functionalAreaRequest?.eqpmtLytDrawAttach ?? [],
      eqpmtLytDrawNo:
          widget.exInspectionRequest.functionalAreaRequest?.eqpmtLytDrawNo ?? [],
      eqpmtLytDrawAttachOrgName: widget
          .exInspectionRequest.functionalAreaRequest?.eqpmtLytDrawAttachOrgName ?? [],
      areaClassDrawAttachOrgName: widget.exInspectionRequest
          .functionalAreaRequest?.areaClassDrawAttachOrgName ?? [],
      dataSheetNo: widget.exInspectionRequest.equipmentTagRequest?.dataSheetNo,
      defectCertificationAttach: widget
          .exInspectionRequest.equipmentTagRequest?.defectCertificationAttach,
      correctiveCertificationAttach: widget.exInspectionRequest
          .equipmentTagRequest?.correctiveCertificationAttach,
      primaryId: widget.exInspectionRequest.equipmentTagRequest?.primaryId,
      repairTimeEstimate:
          widget.exInspectionRequest.equipmentTagRequest?.repairTimeEstimate,
      repairDuration:
          widget.exInspectionRequest.equipmentTagRequest?.repairDuration,
    );

    context.read<ExInspectionsBloc>().add(
          SubmitEquipmentTag(
            widget.exInspectionRequest,
            screenType: 'Inspection Checklist',
          ),
        );
  }

  void _removeUntickedFindings(
    Map<String, dynamic> untickedAction,
    Map<String, dynamic> relatedDetails,
  ) {
    final defectCategory = untickedAction['defectCategory'];
    final defectCode = untickedAction['defectCode'];
    widget.exInspectionRequest.equipmentTagRequest?.checkList?.removeWhere((
      checklist,
    ) {
      if (checklist.defectCategory == defectCategory) {
        checklist.defectCodes.removeWhere((defect) {
          if (defect.defectCode == defectCode) {
            defect.findingsAndActions.removeWhere(
              (finding) => finding.id == untickedAction['_id'],
            );
            return defect.findingsAndActions.isEmpty;
          }
          return false;
        });
        return checklist.defectCodes.isEmpty;
      }
      return false;
    });
  }

  EquipmentTagRequest _mapEquipmentTagRequest(
    Map<String, dynamic> assetDetails,
  ) {
    return EquipmentTagRequest(
      location: assetDetails['location'],
      area: assetDetails['area'],
      subArea: assetDetails['subArea'],
      zone: assetDetails['zone'],
      isActive: assetDetails['isActive'] ?? true,
      locationGasGroup: assetDetails['locationGasGroup'],
      locationTAmbient: assetDetails['locationTAmbient'],
      locationTClass: assetDetails['locationTClass'],
      locationIpRating: assetDetails['locationIpRating'],
      areaClassDrawAttach: assetDetails['areaClassDrawAttach'] ?? '',
      areaClassDrawAttachOrgName:
          assetDetails['areaClassDrawAttachOrgName'] ?? '',
      eqpmtLytDrawAttachOrgName:
          assetDetails['eqpmtLytDrawAttachOrgName'] ?? '',
      areaClassDrawNo: assetDetails['areaClassDrawNo'] ?? '',
      eqpmtLytDrawAttach: assetDetails['eqpmtLytDrawAttach'] ?? '',
      eqpmtLytDrawNo: assetDetails['eqpmtLytDrawNo'] ?? '',
      locationId: assetDetails['locationId'] ?? assetDetails['_id'],
      deckLevel: assetDetails['deckLevel'] ?? '',
      locationLatitude: assetDetails['locationLatitude'] ?? '',
      locationLongitude: assetDetails['locationLongitude'] ?? '',
      rfidRef: assetDetails['rfidRef'] ?? '',
      gpsCord: assetDetails['gpsCord'] ?? '',
      eqpmtCatg: assetDetails['eqpmtCatg'] ?? '',
      eqpmtTag: assetDetails['eqpmtTag'] ?? '',
      circuitId: assetDetails['circuitId'] ?? '',
      cableId: assetDetails['cableId'] ?? '',
      description: assetDetails['description'] ?? '',
      manufacturer: assetDetails['manufacturer'] ?? '',
      type: assetDetails['type'] ?? '',
      serialNumber: assetDetails['serialNumber'] ?? '',
      atexCatg: assetDetails['atexCatg'] ?? '',
      epl: assetDetails['epl'] ?? '',
      protectionStd: assetDetails['protectionStd'] ?? '',
      protectionType: assetDetails['protectionType'] ?? '',
      equipmentGasGroup: assetDetails['equipmentGasGroup'] ?? '',
      equipmentTClass: assetDetails['equipmentTClass'] ?? '',
      equipmentIpRating: assetDetails['equipmentIpRating'] ?? '',
      certfnBody: assetDetails['certfnBody'] ?? '',
      certfnNo: assetDetails['certfnNo'] ?? '',
      tAmbient: assetDetails['tAmbient'] ?? '',
      tAmbientEquip: assetDetails['tAmbientEquip'] ?? '',
      specialCond: assetDetails['specialCond'] ?? '',
      oracleId: assetDetails['oracleId'] ?? '',
      assetId: assetDetails['_id'],
      primaryId: assetDetails['primaryId'],
      yesNoSelection: assetDetails['yesNoSelection'] != null
          ? Map<String, dynamic>.from(assetDetails['yesNoSelection'] as Map)
          : {},
      checkList: (assetDetails['checkList'] as List<dynamic>? ?? [])
          .map(
            (item) => CheckList(
              defectCategory: item['defectCategoryCode'] ?? '',
              count: item['count'] as int? ?? 0,
              defectCodes: (item['defectCodes'] as List<dynamic>? ?? [])
                  .map(
                    (code) => DefectCode(
                      id: code['_id'] ?? '',
                      yesNoSelection: yesNoSelection[code['defectCode']] ?? '',
                      checkListGroup: code['checkListGroup'] ?? '',
                      equipmentType: code['equipmentType'] ?? '',
                      checklistName: code['checklistName'] ?? '',
                      inspectionGrade: code['inspectionGrade'] ?? '',
                      inspectionType: code['inspectionType'] ?? '',
                      defectCode: code['defectCode'] ?? '',
                      findingsAndActions:
                          (code['findingsAndActions'] as List<dynamic>? ?? [])
                              .map(
                                (fa) => FindingAndAction(
                                  id: fa['_id'] ?? '',
                                  defectCode: fa['defectCode'] ?? '',
                                  finding: fa['finding'] ?? '',
                                  remedialAction: fa['remedialAction'] ?? '',
                                  defectCategory: fa['defectCategory'] ?? '',
                                  isDone: fa['isDone'] ?? false,
                                  isSelected: fa['isSelected'] ?? false,
                                  repairedAt: fa['repairedAt'],
                                  repairedBy: fa['repairedBy'],
                                  updatedAt: fa['updatedUp'],
                                ),
                              )
                              .toList(),
                      defectPriority: Map<String, dynamic>.from(
                        code['defectPriority'] ?? {},
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
      inspectedBy: assetDetails['inspectedBy'] ?? '',
      inspectedDate: assetDetails['inspectedDate'] ?? '',
      repairedBy: assetDetails['repairedBy'] ?? '',
      repairedDate: assetDetails['repairedDate'] ?? '',
      faultyItems: assetDetails['faultyItems']?.toString() ?? '',
      repairPriority: assetDetails['repairPriority']?.toString() ?? '',
      inspectionStatus: assetDetails['inspectionStatus'] ?? '',
      defectOverallCondition: assetDetails['defectOverallCondition'] ?? '',
      defectIsolation: assetDetails['defectIsolation'] ?? '',
      defectOtherRequirements: assetDetails['defectOtherRequirements'] ?? '',
      remarks: assetDetails['remarks'] ?? '',
      dataSheet: assetDetails['dataSheet'] ?? '',
      dataSheetOrgName: assetDetails['dataSheetOrgName'] ?? '',
      dataSheetNo: assetDetails['dataSheetNo'] ?? '',
      defectivePhoto1: assetDetails['defectivePhoto1'] ?? '',
      defectivePhoto1OrgName: assetDetails['defectivePhoto1OrgName'] ?? '',
      defectivePhoto2: assetDetails['defectivePhoto2'] ?? '',
      defectivePhoto2OrgName: assetDetails['defectivePhoto2OrgName'] ?? '',
      defectivePhoto3: assetDetails['defectivePhoto3'] ?? '',
      defectivePhoto3OrgName: assetDetails['defectivePhoto3OrgName'] ?? '',
      defectivePhoto4: assetDetails['defectivePhoto4'] ?? '',
      defectivePhoto4OrgName: assetDetails['defectivePhoto4OrgName'] ?? '',
      defectivePhoto5: assetDetails['defectivePhoto5'] ?? '',
      defectivePhoto5OrgName: assetDetails['defectivePhoto5OrgName'] ?? '',
      defectivePhoto6: assetDetails['defectivePhoto6'] ?? '',
      defectivePhoto6OrgName: assetDetails['defectivePhoto6OrgName'] ?? '',
      materials: (assetDetails['materials'] as List<dynamic>?)
              ?.map(
                (material) => Materials(
                  partNumber: material['partNumber'] as String?,
                  description: material['description'] as String?,
                  manufacturer: material['manufacturer'] as String?,
                  certificationAttach:
                      material['certificationAttach'] as String?,
                  certificationOrgName:
                      material['certificationOrgName'] as String?,
                  unit: material['unit'] as String?,
                  quantity: material['quantity'] as String?,
                ),
              )
              .toList() ??
          [],
      existingFaults: assetDetails['existingFaults']?.toString() ?? '',
      correctiveDefectCategory: assetDetails['correctiveDefectCategory'] ?? '',
      currentStatus: assetDetails['currentStatus'] ?? '',
      correctiveOverallCondition:
          assetDetails['correctiveOverallCondition'] ?? '',
      correctiveisolation: assetDetails['correctiveisolation'] ?? '',
      correctiveOtherRequirements:
          assetDetails['correctiveOtherRequirements'] ?? '',
      repairsDone: assetDetails['repairsDone']?.toString() ?? '',
      correctivePhoto1: assetDetails['correctivePhoto1'] ?? '',
      correctivePhoto1OrgName: assetDetails['correctivePhoto1OrgName'] ?? '',
      correctivePhoto2: assetDetails['correctivePhoto2'] ?? '',
      correctivePhoto2OrgName: assetDetails['correctivePhoto2OrgName'] ?? '',
      correctivePhoto3: assetDetails['correctivePhoto3'] ?? '',
      correctivePhoto3OrgName: assetDetails['correctivePhoto3OrgName'] ?? '',
      correctivePhoto4: assetDetails['correctivePhoto4'] ?? '',
      correctivePhoto4OrgName: assetDetails['correctivePhoto4OrgName'] ?? '',
      correctivePhoto5: assetDetails['correctivePhoto5'] ?? '',
      correctivePhoto5OrgName: assetDetails['correctivePhoto5OrgName'] ?? '',
      correctivePhoto6: assetDetails['correctivePhoto6'] ?? '',
      correctivePhoto6OrgName: assetDetails['correctivePhoto6OrgName'] ?? '',
      rbiStrategy: assetDetails['rbiStrategy'] != null
          ? RbiStrategy(
              equipmentCriticality: assetDetails['rbiStrategy']
                  ['equipmentCriticality'],
              faultCategory: assetDetails['rbiStrategy']['faultCategory'],
              failureHistory: assetDetails['rbiStrategy']['failureHistory'],
              equipmentAgening: assetDetails['rbiStrategy']['equipmentAgening'],
              envSeverity: assetDetails['rbiStrategy']['envSeverity'],
              protFlamambleAtom: assetDetails['rbiStrategy']
                  ['protFlamambleAtom'],
              ignitionSourceProb: assetDetails['rbiStrategy']
                  ['ignitionSourceProb'],
              ignitionFlask: assetDetails['rbiStrategy']['ignitionFlask'],
              operationalImpact: assetDetails['rbiStrategy']
                  ['operationalImpact'],
              remarks: assetDetails['rbiStrategy']['remarks'],
            )
          : null,
      additionalInfoForRepairs: assetDetails['additionalInfoForRepairs'] ?? '',
      remarksIfAny: assetDetails['remarksIfAny'] ?? '',
      supplementaryMaterialReq:
          (assetDetails['supplementaryMaterialReq'] as List<dynamic>?)
                  ?.map(
                    (material) => Materials(
                      partNumber: material['partNumber'] as String?,
                      description: material['description'] as String?,
                      manufacturer: material['manufacturer'] as String?,
                      certificationAttach:
                          material['certificationAttach'] as String?,
                      certificationOrgName:
                          material['certificationOrgName'] as String?,
                      unit: material['unit'] as String?,
                      quantity: material['quantity'] as String?,
                    ),
                  )
                  .toList() ??
              [],
      defectCertificationNo: assetDetails['defectCertificationNo'] ?? '',
      defectCertificationOrgName:
          assetDetails['defectCertificationOrgName'] ?? '',
      defectCertificationAttach:
          assetDetails['defectCertificationAttach'] ?? '',
      correctiveCertificationAttach:
          assetDetails['correctiveCertificationAttach'] ?? '',
      correctiveCertificationNo:
          assetDetails['correctiveCertificationNo'] ?? '',
      correctiveCertificationOrgName:
          assetDetails['correctiveCertificationOrgName'] ?? '',
      inspectionGrade: assetDetails['inspectionGrade'] ?? '',
      inspectionType: assetDetails['inspectionType'] ?? '',
      inspectionChecklistType: assetDetails['inspectionChecklistType'] ?? '',
      equipmentEquipmentType: assetDetails['equipmentEquipmentType'] ?? '',
      defectDefectCategory: assetDetails['defectDefectCategory'] ?? '',
      repairDuration: assetDetails['repairDuration'] ?? '',
      repairTimeEstimate: assetDetails['repairTimeEstimate'] ?? '',
      inspectionPriority: assetDetails['inspectionPriority'],
    );
  }

  Future<void> _fetchAssetDataFromOffline(String assetId) async {
    try {
      final String? userType = await authUtils.getUserType();
      List<Map<String, dynamic>> results = (userType == 'onshore')
          ? await _dbHelper.getExRegisterOnshore()
          : await _dbHelper.getExRegister();
      Map<String, dynamic> assetDetails = {};
      for (var record in results) {
        dynamic exRegisterJson = record['exregister_json'];
        Map<String, dynamic> jsonMap = CommonFunctions().decodeJson(
          exRegisterJson,
        );
        if (jsonMap['asset']['_id'] == assetId) {
          assetDetails = jsonMap['asset'];
          break;
        }
      }

      String locationId = assetDetails['locationId'] ?? '';
      Map<String, dynamic> locationData = {};
      if (locationId.isNotEmpty) {
        List<Map<String, dynamic>> functionalAreas = (userType == 'onshore')
            ? await _dbHelper.getFunctionalAreaOnshore()
            : await _dbHelper.getFunctionalArea();
        for (var record in functionalAreas) {
          dynamic functionalAreaJson = record['functional_area_json'];
          Map<String, dynamic> functionalAreaMap = CommonFunctions().decodeJson(
            functionalAreaJson,
          );
          if (functionalAreaMap['location']['locationId'] == locationId) {
            locationData = functionalAreaMap['location'];
            break;
          }
        }
      }

      setState(() {
        exInspectionRequest = ExInspectionRequest(
          functionalAreaRequest: locationId.isNotEmpty
              ? _mapLocationToFunctionalAreaRequest(locationData)
              : null,
          equipmentTagRequest: _mapEquipmentTagRequest(assetDetails),
        );
      });
      selectedFindings.clear();
      final savedChecklists =
          exInspectionRequest?.equipmentTagRequest?.checkList;
      if (savedChecklists != null) {
        for (var checkList in savedChecklists) {
          for (var defectCode in checkList.defectCodes) {
            for (var finding in defectCode.findingsAndActions) {
              if (finding.isSelected) {
                selectedFindings[finding.id] = true;
              }
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error fetching asset data from offline: $e');
    }
  }

  Future<void> _fetchAssetDataFromApi(String assetId) async {
    final ExRegisterService service = ExRegisterService();
    try {
      final response = await service.fetchAssetById(assetId: assetId);
      if (response['status'] == true) {
        final assetDetails = response['data']['assetDetails'];
        String locationId = assetDetails['locationId'] ?? '';
        Map<String, dynamic> locationData = {};
        if (locationId.isNotEmpty) {
          final LocationService locationService = LocationService();
          final locationResponse = await locationService.fetchLocationById(
            locationId: locationId,
          );
          if (locationResponse.containsKey('data')) {
            locationData = locationResponse['data'];
          }
        }
        setState(() {
          exInspectionRequest = ExInspectionRequest(
            functionalAreaRequest: locationId.isNotEmpty
                ? _mapLocationToFunctionalAreaRequest(locationData)
                : null,
            equipmentTagRequest: _mapEquipmentTagRequest(assetDetails),
          );
        });
      } else {
        throw Exception('Failed to load assets');
      }
    } catch (e) {
      throw Exception('Error fetching asset data: $e');
    }
  }

  Future<void> _fetchAssetData(String assetId) async {
    if (isApiFlag) {
      await _fetchAssetDataFromApi(assetId);
    } else {
      await _fetchAssetDataFromOffline(assetId);
    }
  }

  FunctionalAreaRequest _mapLocationToFunctionalAreaRequest(
    Map<String, dynamic> locationData,
  ) {
    return FunctionalAreaRequest(
      location: locationData['location'] ?? '',
      area: locationData['area'] ?? '',
      deckLevel: locationData['deckLevel'],
      subArea: locationData['subArea'] ?? '',
      zone: locationData['zone'] ?? '',
      locationGasGroup: locationData['locationGasGroup'] ?? '',
      locationTClass: locationData['locationTClass'] ?? '',
      locationIpRating: locationData['locationIpRating'] ?? '',
      tAmbient: locationData['tAmbient'] ?? '',
      areaClassDrawAttach: locationData['areaClassDrawAttach'] ?? '',
      areaClassDrawNo: locationData['areaClassDrawNo'] ?? '',
      eqpmtLytDrawAttach: locationData['eqpmtLytDrawAttach'] ?? '',
      eqpmtLytDrawNo: locationData['eqpmtLytDrawNo'] ?? '',
      areaClassDrawAttachOrgName:
          locationData['areaClassDrawAttachOrgName'] ?? '',
      eqpmtLytDrawAttachOrgName:
          locationData['eqpmtLytDrawAttachOrgName'] ?? '',
      locationId: locationData['_id'] ?? locationData['locationId'] ?? '',
      locationLatitude: locationData['locationLatitude'] ?? '',
      locationLongitude: locationData['locationLongitude'] ?? '',
      isActive: locationData['isActive'] ?? true,
    );
  }
}
