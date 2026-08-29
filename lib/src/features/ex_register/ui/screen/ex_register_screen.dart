// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/ui/widgets/date_picker_box.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/ui/widgets/ex_register_table.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/ui/widgets/download_ex_option_popup.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../custom_widgets/nfc_tag_widget.dart';
import '../../../../utils/auth_util.dart';
import '../../../ex_inspections/data/repository/inspection_checklist_repo.dart';
import '../../data/models/dateFilterModel.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import '../../data/services/ex_register_service.dart';
import '../widgets/more_vert.dart';
import '../widgets/show_all_dialogue.dart';

class ExRegisterScreen extends StatefulWidget {
  final String? equipmentId;
  final String? filter;
  final String? fltertype;
  final DateTime? fromDatefilter;
  final DateTime? ToDatefilter;
  final String? isSelectedScreen;
  final bool? isSelectedScreenFlag;
  const ExRegisterScreen({
    super.key,
    this.equipmentId,
    this.filter,
    this.fltertype,
    this.fromDatefilter,
    this.ToDatefilter,
    this.isSelectedScreen,
    this.isSelectedScreenFlag,
  });

  @override
  ExRegisterScreenState createState() => ExRegisterScreenState();
}

class ExRegisterScreenState extends State<ExRegisterScreen> {
  var _openResult = 'Unknown';
  ValueNotifier<dynamic> result = ValueNotifier(null);
  bool nfcUsed = false;
  final FocusNode _rfidFocusNode = FocusNode();
  Map<String, List<String>> collectionSelectedFilter = {};
  List<String> selectedFilters = [];
  bool rfidReadonly = true;
  Future<void> openFile() async {
    if (Platform.isLinux) {
    } else if (Platform.isAndroid) {
      _openAndroidOtherAppFile();
    } else if (Platform.isWindows) {
    } else if (Platform.isMacOS) {}
  }

  Future<void> _openAndroidOtherAppFile() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      final result = await OpenFilex.open(
        "/data/user/0/xxx/images/1.jpg",
      );
      setState(() {
        _openResult = "type=${result.type}  message=${result.message}";
      });
    } else if (await Permission.storage.request().isGranted) {
      final result = await OpenFilex.open(
        "/data/user/0/xxx/images/1.jpg",
      );
      setState(() {
        _openResult = "type=${result.type}  message=${result.message}";
      });
    }
  }

  List<ExRegister> assets = [];
  final authUtils = AuthUtils();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode searchFoucs = FocusNode();
  bool showErrorIDColor = false;
  String _searchQuery = '';
  DateFilter? date;

  late List<String> selectedAssets;
  bool customRangeFlag = false;
  String dateType = '';
  String showSelectedCount = "0";
  final now = DateTime.now();
  DateTime? toDate = DateTime.now();
  bool _hasShownMessage = false;
  bool _hasDownloadShownMessage = false;
  int skip = 0;
  int offset = 0;
  bool hasHandled = false;
  String? alreadySelected;
  bool isLoadMore = false;
  late ExRegisterBloc _bloc;

  @override
  void initState() {
    _bloc = ExRegisterBloc(
      exRegisterService: ExRegisterService(),
      authUtils: AuthUtils(),
      checklistRepo: InspectionChecklistRepo(),
    );
    // ..add(LoadExRegister());
    super.initState();
    showSelectedCount = "0";
    selectedAssets = [];
    _loadInitialData();
  }

  void _initSearch() {
    if (widget.equipmentId?.isNotEmpty ?? false) {
      _searchController.text = widget.equipmentId!;
      _searchQuery = widget.equipmentId!;
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _loadInitialData() {
    collectionSelectedFilter = {};
    final parsedToDate = widget.ToDatefilter != null
        ? DateTime.tryParse(widget.ToDatefilter!.toIso8601String())
        : toDate;
    _initSearch();
    _bloc.add(ExRegisterInitEvent());
    if (widget.isSelectedScreenFlag == true) {
      _bloc.add(
        InitLoadExRegister(
          fromDate: widget.fromDatefilter ?? DateTime(2024, 1, 1),
          toDate: parsedToDate,
          isReset: false,
          type: widget.fltertype ?? "Year to Date",
          showAllFilterType: widget.filter,
        ),
      );
    } else {
      _bloc.add(
        YearToDateFilterExRegister(
          fromDate: widget.fromDatefilter ?? DateTime(2024, 1, 1),
          toDate: parsedToDate,
          isReset: false,
          type: widget.fltertype ?? "Year to Date",
          showAllFilterType: widget.filter,
        ),
      );
    }
    _bloc.add(
      ExRegisterRowSelected(showIcon: false, selectedAssets: selectedAssets),
    );
    if (widget.filter != null) {
      setState(() {
        alreadySelected = widget.filter;
        dateType = widget.fltertype ?? "Year to Date";
        customRangeFlag = dateType == "Custom Range";
        final parsedToDate = widget.ToDatefilter != null
            ? DateTime.tryParse(widget.ToDatefilter!.toIso8601String())
            : toDate;
        date = DateFilter(
          filterType: dateType,
          fromDate: widget.fromDatefilter ?? DateTime(2024, 1, 1),
          toDate: parsedToDate,
        );
      });
      //   _updateShowAllFilter(widget.filter);
    }
  }

  @override
  void dispose() {
    selectedAssets.clear();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void onRowSelectionCountChanged(int selectedCount, dynamic exCollection) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showSelectedCount = selectedCount.toString();
      });
    });
  }

  void _updateDateRange(
    String? type,
    DateTime? fromDate,
    DateTime? toDate,
    bool isReset,
    String isSelectedType,
  ) {
    setState(() {
      customRangeFlag = type == "Custom Range";
      dateType = isSelectedType.isEmpty ? "Custom Range" : type!;
      date = DateFilter(
        filterType: dateType,
        fromDate: fromDate,
        //?? DateTime.now(),
        toDate: toDate,
        // ?? DateTime.now(),
      );
    });
    // final bloc = BlocProvider.of<ExRegisterBloc>(context);
    _bloc.add(
      YearToDateFilterExRegister(
        fromDate: date?.fromDate,
        toDate: date?.toDate,
        isReset: isReset,
        type: dateType,
        showAllFilterType: alreadySelected,
      ),
    );
    _bloc.add(
      ExRegisterRowSelected(showIcon: false, selectedAssets: selectedAssets),
    );
  }

  Future<void> _updateShowAllFilter(String? filterType) async {
    setState(() {
      alreadySelected = filterType;
    });

    await authUtils.setExShowAllFilter(filterType ?? '');

    // final _bloc = BlocProvider.of<ExRegisterBloc>(context);
    _bloc.add(
      ShowAllFilterExRegister(
        type: filterType,
        fromDate: date?.fromDate,
        toDate: date?.toDate,
      ),
    );
    _bloc.add(
      ExRegisterRowSelected(showIcon: false, selectedAssets: selectedAssets),
    );
    // final bloc = BlocProvider.of<ExRegisterBloc>(context);
    // bloc.add(ShowAllFilterExRegister(
    //   type: filterType,
    //   fromDate: date?.fromDate,
    //   toDate: date?.toDate,
    // ));
    // bloc.add(
    //     ExRegisterRowSelected(showIcon: false, selectedAssets: selectedAssets));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
          final double screenWidth = MediaQuery.of(context).size.width;
          final double screenHeight = MediaQuery.of(context).size.height;
          final double searchBarWidthPortrait = screenWidth * 0.3;
          final double paddingValuePortrait =
              (screenWidth + screenHeight) * 0.002;
          final double buttonHeightPortrait =
              (screenWidth + screenHeight) * 0.02;
          final double searchBarWidthLandscape = screenWidth * 0.33;
          final double paddingValueLandscape =
              (screenWidth + screenHeight) * 0.006;
          final double buttonHeightLandscape =
              (screenWidth + screenHeight) * 0.025;
          final double searchBarWidth =
              isPortrait ? searchBarWidthPortrait : searchBarWidthLandscape;
          final double paddingValue =
              isPortrait ? paddingValuePortrait : paddingValueLandscape;
          final double buttonHeight =
              isPortrait ? buttonHeightPortrait : buttonHeightLandscape;
          final double customHorizantal = screenWidth * 0.025;

          return BlocProvider.value(
            value: _bloc,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: customHorizantal,
                  right: customHorizantal,
                  top: screenHeight * 0.04,
                  bottom: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: paddingValue * 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: searchFoucs.hasFocus
                                        ? [
                                            const BoxShadow(
                                              color: Color(0xA3002B5C),
                                              blurRadius: 4,
                                              offset: Offset(0, 0),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  height: (48 / screenHeight) * screenHeight,
                                  child: TextFormField(
                                    onFieldSubmitted: (value) async {
                                      if (!nfcUsed) {
                                        CommonFunctions commonFunctions =
                                            CommonFunctions();
                                        String rfidValue = await commonFunctions
                                            .reversedRFIDString(value);
                                        _searchController.text = rfidValue;
                                        _searchController.selection =
                                            TextSelection.collapsed(
                                          offset: rfidValue.length,
                                        );
                                      }
                                      setState(() {
                                        rfidReadonly = true;
                                      });
                                    },
                                    focusNode: searchFoucs,
                                    keyboardType: TextInputType.none,
                                    // focusNode: searchFoucs,
                                    controller: _searchController,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      height: 24 / 17,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF979797),
                                        height: 24 / 17,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal: 16.0,
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12.0,
                                          bottom: 12.0,
                                          left: 16,
                                          right: 8.0,
                                        ),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'lib/src/features/landing_page/assets/svg/search_icon.svg',
                                              height: 18,
                                              width: 18,
                                              color: const Color(0xFF3B475B),
                                            ),
                                          ),
                                        ),
                                      ),
                                      suffixIcon: _searchController
                                              .text.isNotEmpty
                                          ? GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () {
                                                setState(() {
                                                  _searchController.clear();
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12.0,
                                                  bottom: 12.0,
                                                  left: 8,
                                                  right: 16.0,
                                                ),
                                                child: Container(
                                                  height: 24,
                                                  width: 24,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFF3B475B,
                                                      ),
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 17, // Close icon size
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () async {
                                                getRFIDTag(_searchController);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12.0,
                                                  bottom: 12.0,
                                                  left: 8.0,
                                                  right: 16.0,
                                                ),
                                                child: SvgPicture.asset(
                                                  'lib/src/features/ex_register/assets/rfid-icon.svg',
                                                  height: 24,
                                                  width: 24,
                                                ),
                                              ),
                                            ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                          color: showErrorIDColor
                                              ? const Color(0xFFF44336)
                                              : const Color(0xFFD0D3D8),
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                          color: _searchController.text.isEmpty
                                              ? const Color(0xFFD0D3D8)
                                              : const Color(0xFF9C9C9C),
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
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ShowAllDialog(
                                onFilterSelected: _updateShowAllFilter,
                                alreadySelected: alreadySelected,
                              ),
                              const SizedBox(width: 8),
                              YearToDateBox(
                                dateType: dateType,
                                customRangeFlag: customRangeFlag,
                                type: "asset",
                                height: buttonHeight,
                                width: isPortrait ? 150 : 160,
                                onDateRangeSelected: _updateDateRange,
                                selectedDateFilter: date,
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    alreadySelected = null;
                                    collectionSelectedFilter = {};
                                    date = null;
                                    dateType = '';
                                    customRangeFlag = false;
                                  });
                                  context.read<ExRegisterBloc>().add(
                                    ResetFilterExRegister(
                                      isReset: true,
                                      collectionSelectedFilterData: const {},
                                    ),
                                  );
                                },
                                child: Container(
                                  height: buttonHeight,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xFFD0D3D8)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.refresh, size: 18, color: Color(0xFF002B5C)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Reset',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF002B5C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: BlocConsumer<ExRegisterBloc,
                                    ExRegisterState>(
                                  listenWhen: (previous, current) {
                                    return current is ExRegisterDownloadLoading ||
                                        current is ExRegisterDownloadError ||
                                        current is ExRegisterDownloadSuccess ||
                                        current
                                            is ExRegisterGenerateItrLoading ||
                                        current is ExRegisterGenerateItrLoaded;
                                  },
                                  listener: (context, state) {
                                    if (state is ExRegisterDownloadLoading) {
                                      setState(() {
                                        _hasDownloadShownMessage = false;
                                      });
                                    }
                                    if (state is ExRegisterDownloadSuccess &&
                                        !_hasDownloadShownMessage) {
                                      setState(() {
                                        _hasDownloadShownMessage = true;
                                      });
                                      OpenFilex.open(state.location);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(state.message),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Future.delayed(
                                        const Duration(seconds: 0),
                                        () {
                                          setState(() {
                                            _hasDownloadShownMessage = true;
                                          });
                                        },
                                      );
                                    }
                                    if (state is ExRegisterGenerateItrLoading) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        barrierColor: const Color(0x14000000),
                                        barrierLabel: 'Dismiss',
                                        builder: (context) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      );
                                    }
                                    if (state is ExRegisterGenerateItrLoaded) {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop();
                                    }
                                    if (state is ExRegisterDownloadError) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(state.message),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  buildWhen: (previous, current) =>
                                      current is ExRegisterDownloadLoading ||
                                      current is ExRegisterDownloadError ||
                                      current is ExRegisterDownloadSuccess,
                                  builder: (context, state) {
                                    if (state is ExRegisterDownloadLoading) {
                                      return const Row(
                                        children: [CircularProgressIndicator()],
                                      );
                                    } else {
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTapDown:
                                                (TapDownDetails details) {
                                              showDownloadEXOptionsMenu(
                                                context,
                                                details.globalPosition,
                                                "asset",
                                                assets: assets,
                                                selectedIds: selectedAssets,
                                                fromDate: date?.fromDate,
                                                toDate: date?.toDate,
                                                datetype: dateType,
                                                showFilterType: alreadySelected,
                                                searchQuery: _searchQuery,
                                                filters: {},
                                                bloc: _bloc,
                                              );
                                            },
                                            child: SvgPicture.asset(
                                              'lib/src/features/functional_areas/assets/svg/download.svg',
                                              height: 36,
                                              width: buttonHeight * 4,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                              BlocConsumer<ExRegisterBloc, ExRegisterState>(
                                listenWhen: (previous, current) {
                                  return current is ExRegisterShowLoader ||
                                      current
                                          is ExRegisterDuplicateOrDeleteSuccess ||
                                      current is ExRegisterSaveError;
                                },
                                listener: (context, state) {
                                  if (state is ExRegisterShowLoader) {
                                    setState(() {
                                      _hasShownMessage = false;
                                    });
                                    EasyLoading.show();
                                  }

                                  if (state
                                          is ExRegisterDuplicateOrDeleteSuccess &&
                                      !_hasShownMessage) {
                                    setState(() {
                                      _hasShownMessage = true;
                                    });
                                    EasyLoading.dismiss();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.message),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    // BlocProvider.of<ExRegisterBloc>(context)
                                    _bloc.add(
                                      UpdateExRegisterAfterChange(
                                        currentAssets: assets,
                                        tableHeaders: const [],
                                        totalRecords: assets.length,
                                        skip: skip,
                                        offset: offset,
                                        fromDate: date?.fromDate,
                                        toDate: date?.toDate,
                                        isDuplicate: state.isDuplicate,
                                      ),
                                    );

                                    // }
                                    Future.delayed(
                                      const Duration(seconds: 0),
                                      () {
                                        setState(() {
                                          _hasShownMessage = true;
                                        });
                                      },
                                    );
                                  }
                                  if (state is ExRegisterSaveError) {
                                    EasyLoading.dismiss();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.error),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                buildWhen: (previous, current) =>
                                    current is ShowExRegisterMoreOption ||
                                    current is HideExRegisterMoreOption,
                                builder: (context, state) {
                                  if (state is ShowExRegisterMoreOption) {
                                    selectedAssets = state.selectedAssets;
                                    if (state.showIcon) {
                                      return MoreVertDialog(
                                        selectedAssetIds: state.selectedAssets,
                                        fromDate: date?.fromDate,
                                        toDate: date?.toDate,
                                        type: dateType,
                                        showFilterType: alreadySelected,
                                      );
                                    }
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BlocConsumer<ExRegisterBloc, ExRegisterState>(
                        listenWhen: (previous, current) {
                          return current is ExRegisterLoading ||
                              current is ExRegisterIsLoading ||
                              current is ExRegisterLoaded ||
                              current is ExRegisterError;
                        },
                        listener:
                            (BuildContext context, ExRegisterState state) {
                          if (state is ExRegisterLoading) {
                          } else if (state is ExRegisterIsLoading) {
                            setState(() {
                              isLoadMore = state.isLoadMore;
                            });
                          } else if (state is ExRegisterLoaded) {
                            setState(() {
                              assets = state.assets;
                              skip = state.skip;
                              isLoadMore = state.isLoadMore;
                              offset = state.assets.length;
                              selectedFilters = state.selectedFilters;
                              collectionSelectedFilter =
                                  state.collectionSelectedFilter;
                            });
                          }
                        },
                        buildWhen: (previous, current) =>
                            current is ExRegisterLoading ||
                            current is ExRegisterLoaded ||
                            current is ExRegisterError,
                        builder: (context, state) {
                          if (state is ExRegisterLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is ExRegisterLoaded) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFF2F2F7),
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: NotificationListener<
                                        ScrollEndNotification>(
                                      onNotification: (notification) {
                                        if (notification.metrics.axis ==
                                                Axis.vertical &&
                                            notification.metrics.atEdge &&
                                            notification.metrics.pixels != 0 &&
                                            !isLoadMore &&
                                            state.hasMoreData) {
                                          // Prevent duplicate triggers
                                          setState(() {
                                            isLoadMore = true;
                                          });

                                          _bloc.add(
                                            LoadMoreExRegister(
                                              assets: state.assets,
                                              tableHeaders: state.tableHeaders,
                                              totalRecords: state.totalRecords,
                                              isLoadMore: true,
                                              skip: state.skip,
                                              type: dateType,
                                              showAllFilterType:
                                                  alreadySelected,
                                              fromDate: date?.fromDate,
                                              toDate: date?.toDate,
                                            ),
                                          );
                                          return true;
                                        }
                                        return false;
                                      },
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return ExRegisterTable(
                                            assets: state.assets,
                                            headers: state.tableHeaders,
                                            searchQuery: _searchQuery,
                                            filterIndex: state.filterIndex,
                                            sortOrder: state.sortOrder,
                                            onRowSelectionCountChanged:
                                                onRowSelectionCountChanged,
                                            fromDate: date?.fromDate,
                                            toDate: date?.toDate,
                                            datetype: dateType,
                                            showFilterType:
                                                alreadySelected.toString(),
                                            selectedFilters: selectedFilters,
                                            collectionSelectedFilter:
                                                collectionSelectedFilter,
                                            bloc: _bloc,
                                            tableHeader: "Ex Register",
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: screenHeight * 0.06,
                                    ),
                                    padding: EdgeInsets.all(paddingValue),
                                    margin: EdgeInsets.only(top: paddingValue),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFF2F2F7),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(
                                            27,
                                            32,
                                            41,
                                            0.05,
                                          ),
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Showing: $showSelectedCount Equipment Records',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: const Color(0xFF979797),
                                              height: 20 / 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        if (isLoadMore)
                                          Container(
                                            // padding: const EdgeInsets.all(7),
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.blue,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            
                            return const Center(
                              child: Text('Failed to load data.'),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
                                  searchFoucs.requestFocus();
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
