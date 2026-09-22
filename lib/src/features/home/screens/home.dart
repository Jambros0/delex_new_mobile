import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/ui/screens/dashboard_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/screens/device_sync.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/screens/ex_inspection.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/ui/screen/ex_register_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/ui/screens/functional_areas.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/ui/screens/landing_page_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/bloc/notification_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/bloc/notification_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/ui/screens/notification_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/profile/ui/screens/profile_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/network_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../equipment_locator/screens/equipment_locator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late String _selectedMenu;
  bool _isCollapsed = true;
  String? assetId;
  String? locationId;
  String? gpsCord;
  int? step;
  String? _previousMenu;
  bool fromExRegister = false;
  final _networkUtils = NetworkUtils();
  bool? isSelectedScreenFlag;
  dynamic moreassetId;
  String? _token = "";
  final DBHelper _dbHelper = DBHelper();
  UserDetails? loggedInUser;
  String? _userType;
  @override
  void initState() {
    super.initState();
    dynamic args = Get.arguments;

    FirebaseMessaging.instance.getToken().then((token) {
      if (mounted) {
        setState(() {
          _token = token;
        });
      }
      BlocProvider.of<NotificationBloc>(
        context,
      ).add(NotificationsPostNotification(token: _token ?? ""));
    }).catchError((e) {
      debugPrint("Failed to get Firebase token in home: $e");
      return null;
    });

    if (args is Map) {
      _selectedMenu = args['menu'] ?? 'Landing Screen';
      _isCollapsed = args['isCollapsed'] ?? false;
      assetId = args['assetId'];
      locationId = args['locationId'];
      gpsCord = args['gpsCord'];
      moreassetId = args['assetId'];
      step = args['step'];
      fromExRegister = args['fromExRegister'] ?? false;
    } else {
      _selectedMenu = 'Landing Screen';
      _isCollapsed = false;
      assetId = null;
      locationId = null;
      gpsCord = null;
      moreassetId = null;
      step = null;
    }
    if (_selectedMenu == 'Ex Inspections') {
      _isCollapsed = true;
    }
    _fetchLoggedInUser();
    _previousMenu = _selectedMenu;
  }

  Future<void> _fetchLoggedInUser() async {
    final userType = await AuthUtils().getUserType();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final user = await _dbHelper.getLoggedInUserByUserId(userId);
      setState(() {
        loggedInUser = user;
        _userType = userType;
      });
      // if (user != null && (user.signature.isEmpty)) {
      BlocProvider.of<NotificationBloc>(
        context,
      ).add(NotificationsFetchNotification(loggedInUser: loggedInUser));
      // }
    } else {
      setState(() {
        _userType = userType;
      });
    }
  }

  Widget _getHeaderWidget({String? title}) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    final fromFunctionalArea = arguments?['fromFunctionalArea'] ?? false;

    return Container(
      height: 72,
      padding: EdgeInsets.only(
        left: fromFunctionalArea && _selectedMenu == 'Ex Inspections' ? 0 : 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F2F7), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x29002B5C),
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (_selectedMenu == 'Ex Inspections' && fromFunctionalArea)
                IconButton(
                  icon: SvgPicture.asset(
                    'lib/src/features/ex_inspections/assets/arrow_left.svg',
                    height: 32.0,
                    width: 32.0,
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                      arguments: {'menu': 'Area Details', 'isCollapsed': true},
                    );
                  },
                ),
              if (title != null)
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B2029),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              //   BlocConsumer<NotificationBloc, NotificationState>(
              //   listener: (context, state) {},
              //   builder: (context, state) {
              //     final bool hasNotifications = state is NotificationsLoaded;

              //     return GestureDetector(
              //  behavior: HitTestBehavior.translucent,
              //       onTapDown: (TapDownDetails details) {
              //         if (!_networkUtils.isNetworkAvailable) {
              //           ScaffoldMessenger.of(context).showSnackBar(
              //             const SnackBar(
              //               content: Text(
              //                   'No network available. Please connect and try again.'),
              //             ),
              //           );
              //           return;
              //         }

              //         if (hasNotifications) {
              //           showDialog(
              //             context: context,
              //             builder: (BuildContext dialogContext) {
              //               return const Dialog(
              //                 backgroundColor: Colors.transparent,
              //                 child: NotificationScreen(title: 'Notification'),
              //               );
              //             },
              //           );
              //         }
              //       },
              //       child: SvgPicture.asset(
              //         'lib/src/features/home/assets/svg/mail-icon.svg',
              //         height: 32,
              //         width: 32,
              //       ),
              //     );
              //   },
              // ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (TapDownDetails details) {
                  if (_networkUtils.isNetworkAvailable) {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return const Dialog(
                          backgroundColor: Colors.transparent,
                          child: NotificationScreen(title: 'Notification'),
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
                child: SvgPicture.asset(
                  'lib/src/features/home/assets/svg/mail-icon.svg',
                  height: 32,
                  width: 32,
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Get.to(() => const ProfileScreen());
                },
                child: SvgPicture.asset(
                  'lib/src/features/home/assets/svg/profile-icon.svg',
                  height: 32,
                  width: 32,
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Get.offAllNamed(
                    '/home',
                    arguments: {'menu': 'Landing Screen', 'isCollapsed': false},
                  );
                },
                child: Image.asset(
                  'lib/src/features/home/assets/svg/Home.jpg',
                  height: 32,
                  width: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getContentWidget() {
    String? title;
    if (_selectedMenu == 'To Device') {
      title = _previousMenu ?? 'Dashboard';
    } else if (_selectedMenu == 'To Server') {
      title = _previousMenu ?? 'Dashboard';
    } else {
      title = _selectedMenu;
      _previousMenu = _selectedMenu;
    }
    switch (_previousMenu) {
      case 'Area Details':
        title = 'Area Details';
        break;
      case 'Ex Inspections':
        title = 'Ex Inspections';
        break;
      case 'Ex Register':
        title = 'Ex Register';
        break;
      case 'Locator':
      case 'Equipment Locator':
        title = 'Locator';
        break;
      case 'Landing Screen':
        title = '';
        break;
      default:
        title = 'Dashboard';
    }

    return Stack(
      children: [
        Container(color: Colors.white, child: _buildContent()),
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          child: _getHeaderWidget(title: title),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final now = DateTime.now();
    final modalArgs = ModalRoute.of(context)?.settings.arguments as Map?;
    final getArgs = Get.arguments as Map?;
    final equipmentId = (getArgs?['equipmentId'] ?? modalArgs?['equipmentId']) as String?;
    final filter = (getArgs?['filter'] ?? modalArgs?['filter']) as String?;
    final fltertype = (getArgs?['fltertype'] ?? modalArgs?['fltertype']) as String?;
    final fromDatefilter = (getArgs?['fromDatefilter'] ?? modalArgs?['fromDatefilter']) as DateTime?;
    final ToDatefilter = (getArgs?['ToDatefilter'] ?? modalArgs?['ToDatefilter']) as DateTime?;
    // final isSelectedScreen = Get.arguments?['isSelectedScreen'] as String?;
    final isSelectedScreen = (getArgs?['isSelectedScreenFlag'] ?? modalArgs?['isSelectedScreenFlag']) as bool?;

    final effectiveMenu =
        (_selectedMenu == 'To Device' || _selectedMenu == 'To Server')
        ? _previousMenu
        : _selectedMenu;
    switch (effectiveMenu) {
      case 'Area Details':
        return const FunctionalAreasScreen();
      case 'Ex Inspections':
        return ExInspectionScreen(
          assetId: assetId,
          step: step,
          locationId: locationId,
          fromExRegister: fromExRegister,
        );
      case 'Ex Register':
        final defaultStartDate = (_userType == 'onshore')
            ? DateTime(2023, 6, 13)
            : DateTime(2022, 5, 18);
        return ExRegisterScreen(
          equipmentId: isSelectedScreenFlag == true ? '' : equipmentId,
          filter: isSelectedScreenFlag == true ? 'Show All' : filter,
          fltertype: isSelectedScreenFlag == true ? 'Year to Date' : fltertype,
          fromDatefilter: isSelectedScreenFlag == true
              ? defaultStartDate
              : fromDatefilter,
          ToDatefilter: isSelectedScreenFlag == true
              ? DateTime(now.year, now.month, now.day)
              : ToDatefilter,
          isSelectedScreen: "home",
          isSelectedScreenFlag: isSelectedScreen ?? isSelectedScreenFlag,
        );
      case 'Locator':
      case 'Equipment Locator':
        return EquipmentLocatorScreen(gpsCord: gpsCord, assetId: moreassetId);
      case 'Landing Screen':
        return const LandingScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _showToDevicePopup(BuildContext context) {
    if (_networkUtils.isNetworkAvailable) {
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
          content: Text('No network available. Please connect and try again.'),
        ),
      );
    }
  }

  // void _showNotificationPopup(BuildContext context) {
  //   if (_networkUtils.isNetworkAvailable) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext dialogContext) {
  //         return const Dialog(
  //           backgroundColor: Colors.transparent,
  //           child: NotificationScreen(
  //             title: 'Notification',
  //           ),
  //         );
  //       },
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('No network available. Please connect and try again.'),
  //       ),
  //     );
  //   }
  // }

  Future<void> handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await AuthUtils.handleLogout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double collapsedMenuWidth = screenWidth * 0.081;
    final double expandedMenuWidth = screenWidth * 0.194;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2A6FB2),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFF2A6FB2),
          child: Stack(
            children: [
              Positioned(
                left: _isCollapsed ? collapsedMenuWidth : expandedMenuWidth,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  color: Colors.grey[200],
                  child: _getContentWidget(),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  width: _isCollapsed ? collapsedMenuWidth : expandedMenuWidth,
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: _isCollapsed ? null : const Color(0xFF002B5C),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF001933), Color(0xFF002B5C)],
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.0),
                    border: Border(
                      right: BorderSide(
                        color: _isCollapsed
                            ? const Color(0xFFF2F2F7)
                            : const Color(0xFF002B5C),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: _isCollapsed || isPortrait
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: _isCollapsed
                            ? const EdgeInsets.fromLTRB(0, 20, 0, 0)
                            : const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: Row(
                          mainAxisAlignment: _isCollapsed
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          children: [
                            if (!_isCollapsed)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _toggleMenu,
                                    child: Container(
                                      padding: const EdgeInsets.all(6.0),
                                      child: SvgPicture.asset(
                                        'lib/src/features/home/assets/svg/hamburger_expand.svg',
                                        height: 22,
                                        width: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (_isCollapsed)
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _toggleMenu,
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  child: SvgPicture.asset(
                                    'lib/src/features/home/assets/svg/hamburger_collapse.svg',
                                    height: 22,
                                    width: 22,
                                  ),
                                ),
                              ),
                            if (!_isCollapsed)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'lib/src/features/home/assets/svg/delex_logo_home_page.svg',
                                    height: 26,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: _isCollapsed
                            ? screenHeight * 0.02
                            : screenHeight * 0.045,
                      ),
                      if (!_isCollapsed && !isPortrait)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _isCollapsed || isPortrait
                                ? screenWidth * 0.02
                                : screenWidth * 0.01,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: isPortrait
                                      ? screenWidth * 0.0
                                      : screenWidth * 0.01,
                                ),
                                child: Text(
                                  'Menu',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFB3CCE0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: _isCollapsed
                            ? screenHeight * 0.02
                            : screenHeight * 0,
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            _buildMenuItem(
                              iconPath:
                                  'lib/src/features/home/assets/svg/dashboard_icon.svg',
                              label: 'Dashboard',
                              isSelected: _selectedMenu == 'Dashboard',
                              onTap: () {
                                setState(() {
                                  _selectedMenu = 'Dashboard';
                                  _isCollapsed = true;
                                });
                              },
                            ),
                            _buildMenuItem(
                              iconPath:
                                  'lib/src/features/home/assets/svg/functional_area_icon.svg',
                              label: 'Area Details',
                              isSelected: _selectedMenu == 'Area Details',
                              onTap: () {
                                setState(() {
                                  _selectedMenu = 'Area Details';
                                  _isCollapsed = true;
                                });
                              },
                            ),
                            _buildMenuItem(
                              iconPath:
                                  'lib/src/features/home/assets/svg/ex_inspection_icon.svg',
                              label: 'Ex Inspections',
                              isSelected: _selectedMenu == 'Ex Inspections',
                              onTap: () {
                                setState(() {
                                  _selectedMenu = 'Ex Inspections';
                                  assetId = null;
                                  locationId = null;
                                });
                              },
                            ),
                            _buildMenuItem(
                              iconPath:
                                  'lib/src/features/home/assets/svg/ex_register_icon.svg',
                              label: 'Ex Register',
                              isSelected: _selectedMenu == 'Ex Register',
                              onTap: () {
                                setState(() {
                                  _selectedMenu = 'Ex Register';
                                  _isCollapsed = true;
                                });
                              },
                            ),
                            _buildMenuItem(
                              iconPath:
                                  'lib/src/features/home/assets/svg/equipment_locator_icon.svg',
                              label: 'Locator',
                              isSelected: _selectedMenu == 'Locator' || _selectedMenu == 'Equipment Locator',
                              onTap: () {
                                setState(() {
                                  _selectedMenu = 'Locator';
                                  _isCollapsed = true;
                                  gpsCord = null;
                                });
                              },
                            ),
                            SizedBox(
                              height: _isCollapsed
                                  ? screenHeight * 0.01
                                  : screenHeight * 0,
                            ),
                            Visibility(
                              visible: _isCollapsed,
                              child: _buildSeparator(),
                            ),
                            SizedBox(
                              height: _isCollapsed
                                  ? screenHeight * 0.01
                                  : screenHeight * 0.013,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: _isCollapsed || isPortrait
                                    ? screenWidth * 0.02
                                    : screenWidth * 0.01,
                              ),
                              child: !_isCollapsed
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: isPortrait
                                                  ? screenWidth * 0.0
                                                  : screenWidth * 0.01,
                                            ),
                                            child: Text(
                                              'Data Transfer',
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFB3CCE0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            _buildMenuItem(
                              iconPath:
                                  'lib/src/features/home/assets/svg/to_device_icon.svg',
                              label: 'To Device',
                              isSelected: false,
                              onTap: () {
                                _showToDevicePopup(context);
                              },
                            ),
                            _buildMenuItem(
                              iconPath:
                                  'lib/src/features/home/assets/svg/to_server_icon.svg',
                              label: 'To Server',
                              isSelected: false,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: SyncPopupScreen(
                                        title: 'Data Transfer To Server',
                                        buttonText: 'Transfer To Server',
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(
                              height: _isCollapsed
                                  ? screenHeight * 0.11
                                  : screenHeight * 0.06,
                            ),
                            _buildMenuItem(
                              iconPath:
                                  'lib/src/features/home/assets/svg/logout_icon.svg',
                              label: 'Logout',
                              isSelected: false,
                              onTap: handleLogout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleMenu() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool shouldHighlight =
        label != 'To Server' && label != 'To Device' && isSelected;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          _selectedMenu = label;
          isSelectedScreenFlag = false;
          if (label == 'Ex Inspections') {
            _isCollapsed = true;
          }
          if (label == 'Ex Register') {
            isSelectedScreenFlag = true;
          }
        });
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: shouldHighlight
                ? const Color(0xFF2A6FB2)
                : Colors.transparent,
          ),
          constraints: BoxConstraints(
            maxWidth: shouldHighlight ? screenWidth * 0.6 : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: shouldHighlight && _isCollapsed
                  ? screenWidth * 0.002
                  : (shouldHighlight
                        ? screenWidth * 0.005
                        : screenWidth * 0.0035),
              horizontal: _isCollapsed
                  ? screenWidth * 0.0
                  : screenWidth * 0.001,
            ),
            child: Row(
              mainAxisAlignment: _isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  iconPath,
                  height: _isCollapsed
                      ? screenWidth * 0.0425
                      : screenWidth * 0.0412,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : const Color(0xFFB3CCE0),
                    BlendMode.srcIn,
                  ),
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFB3CCE0),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: _isCollapsed ? 0.5 : 0.5,
        width: _isCollapsed ? 36 : double.infinity,
        color: const Color(0xFF2B4F78),
      ),
    );
  }
}
