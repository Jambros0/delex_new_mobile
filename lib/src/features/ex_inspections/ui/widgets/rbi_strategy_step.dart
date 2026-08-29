import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/equipment_tag_request.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/models/ex_inspection_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/widgets/searchable_dropdown.dart';

class RBIStrategyStep extends StatefulWidget {
  final ExInspectionRequest exInspectionRequest;
  final bool isUpdate;
  final ValueNotifier<bool> isEditModeNotifier;
  const RBIStrategyStep({
    super.key,
    required this.exInspectionRequest,
    required this.isUpdate,
    required this.isEditModeNotifier,
  });

  @override
  RBIStrategyStepState createState() => RBIStrategyStepState();
}

class RBIStrategyStepState extends State<RBIStrategyStep> {
  String? _selectedEquipmentCriticality;
  String? _selectedFaultCategory;
  String? _selectedFailureHistory;
  String? _selectedequipmentAgening;
  String? _selectedenvSeverity;
  String? _selectedAtmosphere;
  String? _selectedIgnitionSource;
  String? _selectedignitionFlask;
  String? _selectedOperationalImpact;
  final TextEditingController _remarks = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeValues();
    }
    context.read<ExInspectionsBloc>().add(FetchAllDropDwn());
  }

  @override
  void didUpdateWidget(covariant RBIStrategyStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exInspectionRequest != oldWidget.exInspectionRequest &&
        widget.exInspectionRequest.equipmentTagRequest != null) {
      _initializeValues();
    }
  }

  void _initializeValues() {
    final request = widget.exInspectionRequest.equipmentTagRequest;

    _selectedEquipmentCriticality = request?.rbiStrategy?.equipmentCriticality;
    _selectedFaultCategory = request?.rbiStrategy?.faultCategory;
    _selectedFailureHistory = request?.rbiStrategy?.failureHistory;
    _selectedequipmentAgening = request?.rbiStrategy?.equipmentAgening;
    _selectedenvSeverity = request?.rbiStrategy?.envSeverity;
    _selectedAtmosphere = request?.rbiStrategy?.protFlamambleAtom;
    _selectedIgnitionSource = request?.rbiStrategy?.ignitionSourceProb;
    _selectedignitionFlask = request?.rbiStrategy?.ignitionFlask;
    _selectedOperationalImpact = request?.rbiStrategy?.operationalImpact;
    _remarks.text = request?.rbiStrategy?.remarks ?? '';
  }

  void clearFields() {
    setState(() {
      _selectedEquipmentCriticality = '';
      _selectedFaultCategory = '';
      _selectedFailureHistory = '';
      _selectedignitionFlask = '';
      _selectedIgnitionSource = '';
      _selectedAtmosphere = '';
      _selectedOperationalImpact = '';
      _selectedenvSeverity = '';
      _selectedequipmentAgening = '';
      _remarks.clear();
    });
    onSubmitRbiStrategy();
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
          if (state is ExInspectionSuccess) {
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
            if (state is ExInspectionSubmitting) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExInspectionLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [_buildForm(state.allDropDowns ?? {})],
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
      ),
    );
  }

  Widget _buildForm(Map<String, dynamic> getAllDropDowns) {
    final exRegisterDropDown = getAllDropDowns['result']['exResiterDropDown'][0]
        as Map<String, dynamic>;
    final equipmentCriticality =
        (exRegisterDropDown['equipmentCriticality'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final faultCategory = (exRegisterDropDown['faultCategory'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();

    final failureHistory =
        (exRegisterDropDown['failureHistory'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final equipmentAgening =
        (exRegisterDropDown['equipmentAgening'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final envSeverity = (exRegisterDropDown['envSeverity'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();

    final protFlamambleAtom =
        (exRegisterDropDown['protFlamambleAtom'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final ignitionSourceProb =
        (exRegisterDropDown['ignitionSourceProb'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    final ignitionFlask = (exRegisterDropDown['ignitionFlask'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();

    final operationalImpact =
        (exRegisterDropDown['ignitionFlask'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Column(
        children: [
          Wrap(
            spacing: 24.0,
            runSpacing: 16.0,
            children: [
              _buildLabeledDropdownField(
                label: 'Equipment Criticality',
                value: _selectedEquipmentCriticality,
                items: equipmentCriticality,
                onChanged: (value) {
                  setState(() {
                    _selectedEquipmentCriticality = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Fault Category',
                value: _selectedFaultCategory,
                items: faultCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedFaultCategory = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Failure History',
                value: _selectedFailureHistory,
                items: failureHistory,
                onChanged: (value) {
                  setState(() {
                    _selectedFailureHistory = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Equipment Ageing',
                value: _selectedequipmentAgening,
                items: equipmentAgening,
                onChanged: (value) {
                  setState(() {
                    _selectedequipmentAgening = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Environmental Severity',
                value: _selectedenvSeverity,
                items: envSeverity,
                onChanged: (value) {
                  setState(() {
                    _selectedenvSeverity = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Flammable Atmosphere',
                value: _selectedAtmosphere,
                items: protFlamambleAtom,
                onChanged: (value) {
                  setState(() {
                    _selectedAtmosphere = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Ignition Source',
                value: _selectedIgnitionSource,
                items: ignitionSourceProb,
                onChanged: (value) {
                  setState(() {
                    _selectedIgnitionSource = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Ignition Risk',
                value: _selectedignitionFlask,
                items: ignitionFlask,
                onChanged: (value) {
                  setState(() {
                    _selectedignitionFlask = value;
                  });
                },
              ),
              _buildLabeledDropdownField(
                label: 'Operational Impact',
                value: _selectedOperationalImpact,
                items: operationalImpact,
                onChanged: (value) {
                  setState(() {
                    _selectedOperationalImpact = value;
                  });
                },
              ),
              _buildLabeledTextField(
                label: 'Additional Comments If Any',
                controller: _remarks,
              ),
            ],
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
      width: MediaQuery.of(context).size.width * 0.274,
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

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.869,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              height: 20 / 14,
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
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF212121),
                          height: 24 / 17,
                        ),
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
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D3D8),
                              width: 1.0,
                            ),
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
    );
  }

  String? _getTextFieldValue(TextEditingController controller) {
    return controller.text.isEmpty ? null : controller.text;
  }

  void onSubmitRbiStrategy() async {
    final rbiStrategy = RbiStrategy(
      equipmentCriticality: _selectedEquipmentCriticality,
      faultCategory: _selectedFaultCategory,
      failureHistory: _selectedFailureHistory,
      equipmentAgening: _selectedequipmentAgening,
      envSeverity: _selectedenvSeverity,
      protFlamambleAtom: _selectedAtmosphere,
      ignitionSourceProb: _selectedIgnitionSource,
      ignitionFlask: _selectedignitionFlask,
      operationalImpact: _selectedOperationalImpact,
      remarks: _getTextFieldValue(_remarks),
    );
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
      locationTAmbient:
          widget.exInspectionRequest.functionalAreaRequest!.tAmbient,
      areaClassDrawAttach:
          widget.exInspectionRequest.functionalAreaRequest!.areaClassDrawAttach,
      areaClassDrawNo:
          widget.exInspectionRequest.functionalAreaRequest!.areaClassDrawNo,
      eqpmtLytDrawAttach:
          widget.exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawAttach,
      eqpmtLytDrawNo:
          widget.exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawNo,
      locationLatitude:
          widget.exInspectionRequest.functionalAreaRequest!.locationLatitude,
      locationLongitude:
          widget.exInspectionRequest.functionalAreaRequest!.locationLongitude,
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
      checkList: widget.exInspectionRequest.equipmentTagRequest?.checkList,
      inspectedBy: widget.exInspectionRequest.equipmentTagRequest?.inspectedBy,
      inspectedDate:
          widget.exInspectionRequest.equipmentTagRequest?.inspectedDate,
      faultyItems: widget.exInspectionRequest.equipmentTagRequest?.faultyItems,
      defectDefectCategory:
          widget.exInspectionRequest.equipmentTagRequest?.defectDefectCategory,
      inspectionStatus:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionStatus,
      defectOverallCondition: widget
          .exInspectionRequest.equipmentTagRequest?.defectOverallCondition,
      defectIsolation:
          widget.exInspectionRequest.equipmentTagRequest?.defectIsolation,
      defectOtherRequirements: widget
          .exInspectionRequest.equipmentTagRequest!.defectOtherRequirements,
      yesNoSelection:
          widget.exInspectionRequest.equipmentTagRequest!.yesNoSelection,
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
      areaStatus: widget.exInspectionRequest.equipmentTagRequest?.areaStatus,
      additionalInfoForRepairs: widget
          .exInspectionRequest.equipmentTagRequest?.additionalInfoForRepairs,
      existingFaults:
          widget.exInspectionRequest.equipmentTagRequest?.existingFaults,
      correctiveDefectCategory: widget
          .exInspectionRequest.equipmentTagRequest?.correctiveDefectCategory,
      currentStatus:
          widget.exInspectionRequest.equipmentTagRequest?.currentStatus,
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
      repairedBy: widget.exInspectionRequest.equipmentTagRequest?.repairedBy,
      inspectionChecklistType: widget
          .exInspectionRequest.equipmentTagRequest!.inspectionChecklistType,
      inspectionGrade:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionGrade,
      inspectionType:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionType,
      remarks: widget.exInspectionRequest.equipmentTagRequest?.remarks,
      subArea: widget.exInspectionRequest.equipmentTagRequest?.subArea,
      equipmentEquipmentType: widget
          .exInspectionRequest.equipmentTagRequest?.equipmentEquipmentType,
      materials: widget.exInspectionRequest.equipmentTagRequest?.materials,
      repairedDate:
          widget.exInspectionRequest.equipmentTagRequest?.repairedDate,
      rbiStrategy: rbiStrategy,
      eqpmtLytDrawAttachOrgName: widget
          .exInspectionRequest.functionalAreaRequest!.eqpmtLytDrawAttachOrgName,
      areaClassDrawAttachOrgName: widget.exInspectionRequest
          .functionalAreaRequest!.areaClassDrawAttachOrgName,
      dataSheetNo: widget.exInspectionRequest.equipmentTagRequest!.dataSheetNo,
      defectCertificationAttach: widget
          .exInspectionRequest.equipmentTagRequest!.defectCertificationAttach,
      correctiveCertificationAttach: widget.exInspectionRequest
          .equipmentTagRequest!.correctiveCertificationAttach,
      primaryId: widget.exInspectionRequest.equipmentTagRequest?.primaryId,
      repairTimeEstimate:
          widget.exInspectionRequest.equipmentTagRequest?.repairTimeEstimate,
      repairDuration:
          widget.exInspectionRequest.equipmentTagRequest?.repairDuration,
      inspectionPriority:
          widget.exInspectionRequest.equipmentTagRequest?.inspectionPriority,
    );
    if (!mounted) return;
    context.read<ExInspectionsBloc>().add(
          SubmitEquipmentTag(
            widget.exInspectionRequest,
            screenType: 'RBI Stratrgy',
          ),
        );
  }
}
