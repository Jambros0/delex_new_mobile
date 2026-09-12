import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../utils/auth_util.dart';
import '../../../../utils/network_util.dart';
import '../../../ex_inspections/data/repository/dropdown_repo.dart';
import '../../../ex_inspections/data/repository/inspection_checklist_repo.dart';
import '../../../ex_inspections/data/services/ex_inspection_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    final startTime = DateTime.now();

    final authUtils = AuthUtils();
    final isLicenseValidated = await authUtils.isLicenseValidated();
    final isLoggedIn = await authUtils.isSessionActive();

    if (isLoggedIn) {
      try {
        final dropdownRepository = DropdownRepository();
        final checklistRepository = InspectionChecklistRepo();
        if (NetworkUtils().isNetworkAvailable) {
          await dropdownRepository
              .checkDailySync(() => ExInspectionService().getAllDropDwn());
          await checklistRepository.checkDailyChecklistSync(
              () => ExInspectionService().fetchInspectionChecklist());
        }
      } catch (e) {
        debugPrint('Sync check error in splash: $e');
      }
    }

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 1200) {
      await Future.delayed(Duration(milliseconds: 1200 - elapsed));
    }

    if (!mounted) return;

    if (!isLicenseValidated) {
      Get.offAllNamed('/license');
    } else if (isLoggedIn) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final logoWidth = isLandscape
        ? (size.width * 0.35).clamp(240.0, 480.0)
        : (size.width * 0.65).clamp(220.0, 400.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Center(
          child: SvgPicture.asset(
            'lib/src/features/home/assets/svg/delex_logo_home_page.svg',
            width: logoWidth,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
