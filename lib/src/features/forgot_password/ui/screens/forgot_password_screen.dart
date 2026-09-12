import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/data/models/user_forgot_password.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/data/repository/forgot_password_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/data/services/forgot_password_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final FocusNode _userFocusNode = FocusNode();

  bool _isUserFocused = false;
  bool _isLoading = false;
  late final ForgotPasswordRepository _authForgotPassword;

  @override
  void initState() {
    super.initState();
    _authForgotPassword = ForgotPasswordRepository(
      forgotPasswordService: ForgotPasswordService(),
      authUtils: AuthUtils(),
      dbHelper: DBHelper(),
    );

    _userFocusNode.addListener(() {
      setState(() {
        _isUserFocused = _userFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _userFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final username = _userController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username or email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userLogin = UserForgotPassword(username: username);
      final response = await _authForgotPassword.sendOtp(userLogin);
      if (response['status'] == true) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/new_password_screen',
          arguments: {
            'username': username,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${response['message'] ?? 'Failed to send OTP'}${response['additionalInfo'] != null ? ', ${response['additionalInfo']}' : ''}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
    final orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF070B14),
        statusBarIconBrightness: Brightness.light,
      ),
    );

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
                                    Colors.black.withValues(alpha: 0.2),
                                    const Color(0xFF0A0E1A).withValues(alpha: 0.6),
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

                    // 2. Right Side Form Panel
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: const Color(0xFF0A0E1A),
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48.0, vertical: 32.0),
                          child: _buildRightCard(context),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildRightCard(context),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRightCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Form(
        key: _formKey,
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

            // Heading
            Text(
              'Forgot Password?',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Enter your username or registered email address to receive a password reset OTP.',
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Username / Email Field Label
            Text(
              'Username or Email',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 8),

            // Text Input Field
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
                controller: _userController,
                focusNode: _userFocusNode,
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
                  hintText: 'Enter username or email',
                  hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                onFieldSubmitted: (_) => _handleSendOtp(),
              ),
            ),
            const SizedBox(height: 28),

            // Send OTP Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D6FF),
                  disabledBackgroundColor:
                      const Color(0xFF00D6FF).withValues(alpha: 0.85),
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
                        'Send OTP',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0E1A),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Back to Login Link
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: Color(0xFF00D6FF),
                ),
                label: Text(
                  'Back to Login',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF00D6FF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
