

// ignore_for_file: deprecated_member_use

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
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/file_uploads_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/progress_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
        _selectedRows = rowSelection;
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
      if (BlocProvider.of<DeviceSyncBloc>(context).state is WorkOrderLoaded) {
        var state =
            BlocProvider.of<DeviceSyncBloc>(context).state as WorkOrderLoaded;

        List<ExRegister> selectedAssets = [];
        if (_selectedRows.length != state.assets.length) {
          _selectedRows.clear();
          _selectedRows.addAll(List<bool>.filled(state.assets.length, false));
        }
        for (int i = 0; i < _selectedRows.length; i++) {
          if (_selectedRows[i]) {
            selectedAssets.add(state.assets[i]);
          }
        }
        if (selectedAssets.isNotEmpty) {
          await _insertIntoLocalDB(
            selectedAssets,
            navigator,
            scaffoldMessenger,
            state.workOrderCollection,
          );
        } else {
          _closeDialogIfOpen(navigator);
          _showToast("No items selected.", Colors.red, scaffoldMessenger);
        }
      }
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> _insertIntoLocalDB(
    List<ExRegister> assets,
    NavigatorState navigator,
    ScaffoldMessengerState scaffoldMessenger,
    List<WorkOrderTableJson> workOrderCollection,
  ) async {
    final repository = WorkOrderRepository();
    final dbHelper = DBHelper();
    final fileUploadRepo = FileUploadRepository();
    final UserDetails? loggedInUser = await dbHelper.getLoggedInUser();
    if (loggedInUser == null) {
      _closeDialogIfOpen(navigator);
      _showToast(
        "Failed to fetch logged-in user.",
        Colors.red,
        scaffoldMessenger,
      );
      return;
    }
    final userId = loggedInUser.userId;
    try {
      int totalAssetsToSync = assets.length;
      int syncedCount = 0;
      for (int j = 0; j < workOrderCollection.length; j++) {
        final json = workOrderCollection[j].toJson();
        for (int i = 0; i < workOrderCollection[j].assets.length; i++) {
          // Only process assets that are in the selectedAssets list
          var asset = workOrderCollection[j].assets[i];
          if (!assets.any((ass) => ass.id == asset.id)) {
            continue;
          }
          selectedAssetsSync.add(asset.id);
          json['assets'] = asset.toJson();
          final fileFields = [
            "correctivePhoto1",
            "correctivePhoto2",
            "correctivePhoto3",
            "correctivePhoto4",
            "correctivePhoto5",
            "correctivePhoto6",
            "dataSheet",
            "defectivePhoto1",
            "defectivePhoto2",
            "defectivePhoto3",
            "defectivePhoto4",
            "defectivePhoto5",
            "defectivePhoto6",
            // "inspectionSignOff",
            // "repairSignOff",
          ];

          json['assets']['checkList'] = json['assets']['checkList']
              ?.map((item) => item.toJson())
              ?.toList();
          if (json['assets']['checkList'].isNotEmpty &&
              (json['assets']['yesNoSelection'] == null ||
                  json['assets']['yesNoSelection'].isEmpty)) {
            json['assets']['yesNoSelection'] ??= <String, dynamic>{};
            for (var checklist in json['assets']['checkList']) {
              for (var defectCodes in checklist['defectCodes']) {
                json['assets']['yesNoSelection'][defectCodes['defectCode']] =
                    "no";
              }
            }
          }
          for (var field in fileFields) {
            final filePath = json['assets'][field];
            if (filePath != null && filePath.isNotEmpty && filePath != "null") {
              try {
                final uploadResponse =
                    await fileUploadRepo.downloadAndCacheFile(filePath, field);
                if (uploadResponse['status'] == true) {
                  final uploadedPath =
                      uploadResponse['data']['uploadStatus']['file'];
                  json['assets'][field] = uploadedPath;
                } else {
                  _showToast(
                    "Failed to upload $field.",
                    Colors.red,
                    scaffoldMessenger,
                  );
                }
              } catch (e) {
                _showToast(
                  "Error uploading $field: $e",
                  Colors.red,
                  scaffoldMessenger,
                );
              }
            }
          }
          final fileSignFields = ["inspectionSignOff", "repairSignOff"];
          for (var field in fileSignFields) {
            final filePath = json['assets'][field];
            if (filePath != null && filePath.isNotEmpty && filePath != "null") {
              try {
                final uploadResponse = await fileUploadRepo
                    .downloadAndFullCacheFile(filePath, field);
                if (uploadResponse['status'] == true) {
                  final uploadedPath =
                      uploadResponse['data']['uploadStatus']['file'];
                  json['assets'][field] = uploadedPath;
                } else {
                  _showToast(
                    "Failed to upload $field.",
                    Colors.red,
                    scaffoldMessenger,
                  );
                }
              } catch (e) {
                _showToast(
                  "Error uploading $field: $e",
                  Colors.red,
                  scaffoldMessenger,
                );
              }
            }
          }

          if (json['assets']['materials'] != null &&
              json['assets']['materials'] is List) {
            for (var item in json['assets']['materials']) {
              final certPath = item['certificationAttach'];
              if (certPath != null &&
                  certPath.isNotEmpty &&
                  certPath != "null") {
                try {
                  final uploadResponse =
                      await fileUploadRepo.downloadAndCacheFile(
                    certPath,
                    'defectCertificationAttach',
                  );
                  if (uploadResponse['status'] == true) {
                    final uploadedPath =
                        uploadResponse['data']['uploadStatus']['file'];
                    item['certificationAttach'] = uploadedPath;
                  } else {
                    _showToast(
                      "Failed to upload Material Certification Attach.",
                      Colors.red,
                      scaffoldMessenger,
                    );
                  }
                } catch (e) {
                  _showToast(
                    "Error uploading Material Certification Attach: $e",
                    Colors.red,
                    scaffoldMessenger,
                  );
                }
              }
            }
          }
          if (json['assets']['areaClassDrawAttach'] != null &&
              json['assets']['areaClassDrawAttach'] is List) {
            List areaClassDrawAttachList =
                json['assets']['areaClassDrawAttach'];

            List<String> uploadedFiles = [];
            for (var certPath in areaClassDrawAttachList) {
              if (certPath != null && certPath.toString().isNotEmpty) {
                try {
                  final uploadResponse = await fileUploadRepo
                      .downloadAndCacheFile(certPath, 'areaClassDrawAttach');

                  if (uploadResponse['status'] == true) {
                    final uploadedPath =
                        uploadResponse['data']['uploadStatus']['file'];
                    uploadedFiles.add(uploadedPath);
                  } else {
                    _showToast(
                      "Failed to upload Area Classification Drawing Number.",
                      Colors.red,
                      scaffoldMessenger,
                    );
                  }
                } catch (e) {
                  _showToast(
                    "Error uploading Area Classification Drawing Number: $e",
                    Colors.red,
                    scaffoldMessenger,
                  );
                }
              }
            }
            json['assets']['areaClassDrawAttach'] = uploadedFiles;
          }
          if (json['assets']['eqpmtLytDrawAttach'] != null &&
              json['assets']['eqpmtLytDrawAttach'] is List) {
            List eqpmtLytDrawAttachList = json['assets']['eqpmtLytDrawAttach'];

            List<String> uploadedFiles = [];

            for (var certPath in eqpmtLytDrawAttachList) {
              if (certPath != null && certPath.toString().isNotEmpty) {
                try {
                  final uploadResponse = await fileUploadRepo
                      .downloadAndCacheFile(certPath, 'eqpmtLytDrawAttach');

                  if (uploadResponse['status'] == true) {
                    final uploadedPath =
                        uploadResponse['data']['uploadStatus']['file'];
                    uploadedFiles.add(uploadedPath);
                  } else {
                    _showToast(
                      "Failed to upload Equipment Layout Drawing Number.",
                      Colors.red,
                      scaffoldMessenger,
                    );
                  }
                } catch (e) {
                  _showToast(
                    "Error uploading Equipment Layout Drawing Number: $e",
                    Colors.red,
                    scaffoldMessenger,
                  );
                }
              }
            }
            json['assets']['eqpmtLytDrawAttach'] = uploadedFiles;
          }

          final workOrder = {
            'id': json['assets']['_id'],
            'work_order_json': json,
            'created_by': userId,
            'updated_by': userId,
          };
          await repository.insertWorkOrderAsset(workOrder);

          syncedCount++;

          double progress = syncedCount / totalAssetsToSync;
          _updateSyncProgress(progress);
        }
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
          _selectedRows.clear();
          _selectedRows.addAll(List<bool>.filled(allAssets.length, false));
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
              _selectedRows = List<bool>.filled(state.assets.length, false);
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
                              // key: ValueKey(state.assets.hashCode),
                              assets: state.assets,
                              registerCollections: registerCollections,
                              headers: state.tableHeaders,
                              onRowSelected: (index) {
                                setState(() {
                                  _selectedRows[index] = !_selectedRows[index];
                                });
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
