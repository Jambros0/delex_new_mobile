// ignore_for_file: unused_field

import 'package:deex_bloc_mobile_app_dev/src/custom_widgets/nfc_tag_widget.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/screens/device_sync.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/bloc/landing_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/bloc/landing_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/bloc/landing_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/ui/widgets/actions_required.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/ui/widgets/quick_access.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/signature_upload_page/ui/screens/upload_signature_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/network_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/common_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController equipmentIdController = TextEditingController();
  FocusNode equipmentFoucs = FocusNode();
  String _searchQuery = '';
  bool showErrorIDColor = false;
  final DBHelper _dbHelper = DBHelper();
  UserDetails? loggedInUser;
  String? userName;
  bool nfcUsed = false;
  final FocusNode _rfidFocusNode = FocusNode();
  bool rfidReadonly = true;
  FocusNode searchFoucs = FocusNode();
  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser();
    _fetchAssetList();
    equipmentIdController.addListener(() {
      setState(() {
        _searchQuery = equipmentIdController.text;
        // _searchQuery = equipmentIdController.text;
      });
    });
  }

  Future<void> _fetchAssetList() async {
    if (NetworkUtils().isNetworkAvailable) {
      BlocProvider.of<DeviceSyncBloc>(context).add(LoadNewWorkOrder());
    }
  }

  Future<void> _fetchLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final user = await _dbHelper.getLoggedInUserByUserId(userId);
      final bool hasCompletedSig =
          prefs.getBool('has_completed_signature_$userId') ?? false;
      setState(() {
        loggedInUser = user;
        userName = loggedInUser?.userName;
      });
      if (user != null && !hasCompletedSig) {
        _showUploadSignatureOverlay();
      }
    }
  }

  void _showUploadSignatureOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.555,
          height: MediaQuery.of(context).size.height * 0.815,
          child: UploadSignatureScreen(
            onSignatureSaved: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _checkNewAsset(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList('asset_ids') ?? [];
      final state = BlocProvider.of<DeviceSyncBloc>(context).state;
      if (state is WorkOrderNewLoaded) {
        final List<ExRegister> currentAssets = state.assets;
        final List<String> currentIds = currentAssets.map((e) => e.id).toList();
        final Set<String> oldSet = savedIds.toSet();
        final Set<String> currentSet = currentIds.toSet();
        final Set<String> newAssets = currentSet.difference(oldSet);

        if (newAssets.isNotEmpty) {
          _showNewAssetPopup(context);
        }
      }
    } catch (e) {}
  }

  void _showNewAssetPopup(BuildContext context) {
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
                                  'Welcome to Delex',
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
                                  'Do you want to download latest work?',
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
                                        'No',
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
                          onTap: () async {
                            // _deleteFile(context, index, fileOf);
                            Navigator.of(context).pop();
                            if (NetworkUtils().isNetworkAvailable) {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return const Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: SyncPopupScreen(
                                      title: 'Data Transfer To Device',
                                      buttonText: 'Transfer To Device',
                                    ),
                                  );
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No network available. Please connect and try again.',
                                  ),
                                ),
                              );
                            }
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
                                        'Yes',
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

  @override
  void dispose() {
    super.dispose();
    equipmentIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    double searchFieldWidth = orientation == Orientation.portrait
        ? screenWidth * 0.625
        : screenWidth * 0.673;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = MediaQuery.of(context).size.height;

        return BlocListener<DeviceSyncBloc, DeviceSyncState>(
          listenWhen: (previous, current) => current is WorkOrderNewLoaded,
          listener: (context, state) {
            if (state is WorkOrderNewLoaded) {
              // Future.delayed(const Duration(seconds: 1), () {
              _checkNewAsset(context);
              // });
            }
          },
          child: BlocProvider(
            create: (context) => LandingPageBloc()..add(LoadLandingPage()),
            child: BlocBuilder<LandingPageBloc, LandingPageState>(
              builder: (context, state) {
                if (state is LandingPageLoaded) {
                  // Future.delayed(const Duration(seconds: 1), () {
                  //   setState(() {
                  //     _checkNewAsset(context);
                  //   });
                  // });
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 95,
                            left: orientation == Orientation.portrait ? 24 : 24,
                            right:
                                orientation == Orientation.portrait ? 24 : 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Hello, $userName!',
                                      style: GoogleFonts.inter(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF222222),
                                        height: 48 / 28,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: orientation == Orientation.portrait
                                    ? 24
                                    : 24,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: equipmentFoucs.hasFocus
                                          ? [
                                              const BoxShadow(
                                                color: Color(0xA3002B5C),
                                                blurRadius: 4,
                                                offset: Offset(0, 0),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    width: searchFieldWidth,
                                    height: (48 / screenHeight) * screenHeight,
                                    child: Stack(
                                      children: [
                                        TextFormField(
                                          keyboardType: TextInputType.none,
                                          readOnly: rfidReadonly,
                                          // focusNode: searchFoucs,
                                          focusNode: _rfidFocusNode,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          controller: equipmentIdController,
                                          // focusNode: equipmentFoucs,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                            height: 24 / 17,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xFFFFFFFF),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                                decoration:
                                                    const BoxDecoration(),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    'lib/src/features/landing_page/assets/svg/search_icon.svg',
                                                    height: 18,
                                                    width: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            hintText:
                                                'Enter the Equipment Tag Number or Scan the RFID Tag',
                                            hintStyle: GoogleFonts.inter(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF979797),
                                              height: 24 / 17,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: showErrorIDColor
                                                    ? const Color(0xFFF44336)
                                                    : const Color(0xFFD0D3D8),
                                                width: 1.0,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: equipmentIdController
                                                        .text.isEmpty
                                                    ? const Color(0xFFD0D3D8)
                                                    : const Color(0xFF9C9C9C),
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF002B5C),
                                                width: 1.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFF44336),
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                8.0,
                                              ),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFF44336),
                                                width: 1.0,
                                              ),
                                            ),
                                            errorStyle: GoogleFonts.inter(
                                              color: const Color(0xFFF44336),
                                              fontSize: 12.0,
                                            ),
                                            suffixIcon: equipmentIdController
                                                    .text.isNotEmpty
                                                ? GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () {
                                                      setState(() {
                                                        equipmentIdController
                                                            .clear();
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 12.0,
                                                        bottom: 12.0,
                                                        left: 8,
                                                        right: 16.0,
                                                      ),
                                                      child: Container(
                                                        height: 24,
                                                        width: 24,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: const Color(
                                                              0xFF3B475B,
                                                            ),
                                                          ),
                                                          // color: Colors.grey[400], // Circle background color
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          size:
                                                              17, // Close icon size
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () async {
                                                      // bool isAvailable =
                                                      //     await NFCUtility(context)
                                                      //         .isNfcAvailable();
                                                      // if (!isAvailable) {
                                                      //   ScaffoldMessenger.of(
                                                      //           context)
                                                      //       .showSnackBar(
                                                      //     const SnackBar(
                                                      //         content: Text(
                                                      //             "NFC is not available.")),
                                                      //   );
                                                      //   return;
                                                      // }
                                                      // await NFCUtility(context)
                                                      //     .startNfcSession(
                                                      //         equipmentIdController);

                                                      // setState(() {});
                                                      getRFIDTag(
                                                        equipmentIdController,
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                          ),
                                          onFieldSubmitted: (value) async {
                                            if (!nfcUsed) {
                                              CommonFunctions commonFunctions =
                                                  CommonFunctions();
                                              String rfidValue =
                                                  await commonFunctions
                                                      .reversedRFIDString(
                                                value,
                                              );
                                              equipmentIdController.text =
                                                  rfidValue;
                                              equipmentIdController.selection =
                                                  TextSelection.collapsed(
                                                offset: rfidValue.length,
                                              );
                                            }
                                            setState(() {
                                              rfidReadonly = true;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: orientation == Orientation.portrait
                                        ? 24
                                        : 24,
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 24,
                                      ),
                                      backgroundColor: const Color(0xFF1E90FF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      shadowColor: const Color.fromRGBO(
                                        26,
                                        133,
                                        236,
                                        0.24,
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () {
                                      final equipmentId =
                                          equipmentIdController.text.trim();
                                      if (equipmentId.isNotEmpty) {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/home',
                                          (route) => false,
                                          arguments: {
                                            'menu': 'Ex Register',
                                            'isCollapsed': true,
                                            'equipmentId': equipmentId,
                                          },
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Go',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFEFEFE),
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: orientation == Orientation.portrait
                                    ? 32
                                    : 26,
                              ),
                              const QuickAccessSection(),
                              SizedBox(
                                height: orientation == Orientation.portrait
                                    ? 32
                                    : 26,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Text(
                                  "Actions Required",
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF222222),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: orientation == Orientation.portrait
                                    ? 24
                                    : 24,
                              ),
                              const ActionsRequired(),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          left: 0,
                          right: 0,
                          child: Container(
                            width: 760,
                            height: 36,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Powered by ',
                                        style: TextStyle(
                                          color: Color(0xFF4B4B4B),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Del',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF212121),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Ex',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFFFF3B30),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ', Version: 2026.02.24',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF4B4B4B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
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
