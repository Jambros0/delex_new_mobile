import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_login.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/repository/auth_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/data/services/auth_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/network_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/dropdown_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/inspection_checklist_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/services/ex_inspection_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode userfocusNode = FocusNode();
  final FocusNode passwordfocusNode = FocusNode();

  bool _isUserFocused = false;
  bool _isPassFocused = false;
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      authService: AuthService(),
      authUtils: AuthUtils(),
      dbHelper: DBHelper(),
    );

    userfocusNode.addListener(() {
      setState(() {
        _isUserFocused = userfocusNode.hasFocus;
      });
    });

    passwordfocusNode.addListener(() {
      setState(() {
        _isPassFocused = passwordfocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    userfocusNode.dispose();
    passwordfocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _handleLogin() async {
    final username = userController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter username and password',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userLogin = UserLogin(username: username, password: password);
      await _authRepository.authenticate(userLogin);
      final dropdownRepository = DropdownRepository();
      final checklistRepository = InspectionChecklistRepo();

      if (NetworkUtils().isNetworkAvailable) {
        try {
          await dropdownRepository.checkDailySync(
            () => ExInspectionService().getAllDropDwn(),
          );
          await checklistRepository.checkDailyChecklistSync(
            () => ExInspectionService().fetchInspectionChecklist(),
          );
        } catch (e) {
          Fluttertoast.showToast(
            msg: 'Error syncing data: ${e.toString()}',
            backgroundColor: Colors.red,
          );
        }
      } else {
        try {
          final localData = await dropdownRepository.getLocalDropDownData();
          if (localData == null) {
            throw Exception('No local dropdown data available.');
          }
          final localChecklistData =
              await checklistRepository.getLocalChecklistData();
          if (localChecklistData == null) {
            throw Exception('No local checklist data available.');
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: e.toString(),
            backgroundColor: Colors.red,
          );
        }
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: {
            'menu': 'Landing Screen',
            'isCollapsed': false,
            'username': username,
          },
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Login failed: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: isLandscape
              ? Row(
                  children: [
                    // 1. Left Side Image Panel
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF070B14),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'lib/src/features/login/assets/login_new_bg.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'lib/src/features/login/assets/delex_background_image.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    const Color(0xFF0A0E1A).withOpacity(0.6),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Right Side Form Panel (Logo, Welcome, Fields, Remember me, Forgot Password, Login Button)
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: const Color(0xFF0A0E1A),
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48.0, vertical: 32.0),
                          child: _buildRightLoginFormCard(context),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildRightLoginFormCard(context),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRightLoginFormCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo at top of Right Panel (Left-aligned)
          Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              'lib/src/features/home/assets/svg/delex_logo_home_page.svg',
              height: 48,
            ),
          ),
          const SizedBox(height: 32),

          // Subtitle / Prompt
          Text(
            'Enter username and password to log in.',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),

          // User name Field
          Text(
            'User name',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _isUserFocused
                    ? const Color(0xFF00D6FF)
                    : const Color(0xFF334155),
                width: 1.5,
              ),
              boxShadow: _isUserFocused
                  ? [
                      const BoxShadow(
                        color: Color(0x3300D6FF),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: userController,
              focusNode: userfocusNode,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white,
              ),
              cursorColor: const Color(0xFF00D6FF),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
                hintText: 'Enter username',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Password Field
          Text(
            'Password',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _isPassFocused
                    ? const Color(0xFF00D6FF)
                    : const Color(0xFF334155),
                width: 1.5,
              ),
              boxShadow: _isPassFocused
                  ? [
                      const BoxShadow(
                        color: Color(0x3300D6FF),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: passwordController,
              focusNode: passwordfocusNode,
              obscureText: _obscureText,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white,
              ),
              cursorColor: const Color(0xFF00D6FF),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
                hintText: 'Enter password',
                hintStyle:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Remember me & Forgot password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: const Color(0xFF00D6FF),
                      checkColor: Colors.black,
                      side: const BorderSide(
                          color: Color(0xFF64748B), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                    },
                    child: Text(
                      'Remember me',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot_password');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF00D6FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D6FF),
                disabledBackgroundColor: const Color(0xFF00D6FF).withOpacity(0.85),
                foregroundColor: Colors.black,
                disabledForegroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'Login',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0E1A),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
