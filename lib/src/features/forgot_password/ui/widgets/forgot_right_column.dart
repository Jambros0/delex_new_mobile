import 'dart:ui';

import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/data/models/user_forgot_password.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/data/repository/forgot_password_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/data/services/forgot_password_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ForgotRightColumn extends StatefulWidget {
  const ForgotRightColumn({super.key});

  @override
  ForgotRightColumnState createState() => ForgotRightColumnState();
}

class ForgotRightColumnState extends State<ForgotRightColumn> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();

  String _username = '';
  bool _isLoading = false;
  FocusNode userfocusNode = FocusNode();
  late final ForgotPasswordRepository _authForgotPassword;
  bool showErrorUserColor = false;
  @override
  void initState() {
    super.initState();
    _authForgotPassword = ForgotPasswordRepository(
      forgotPasswordService: ForgotPasswordService(),
      authUtils: AuthUtils(),
      dbHelper: DBHelper(),
    );
  }

  Future<void> _handleForgotPassword() async {
    _formKey.currentState?.save();

    if (_username.isEmpty == true) {
      showErrorUserColor = true;
    }

    if (_formKey.currentState?.validate() ?? false) {
      showErrorUserColor = false;
      final userLogin = UserForgotPassword(username: _username);
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await _authForgotPassword.sendOtp(userLogin);
        if (response['status'] == true) {
          Navigator.pushReplacementNamed(
            context,
            '/new_password_screen',
            arguments: {
              'username': _username,
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${response['message'].toString()}, ${response['additionalInfo'].toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        logger.e('Forgot Password error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerWidth = orientation == Orientation.portrait
        ? screenWidth * 0.80
        : screenWidth * 0.45;
    double containerHeight = orientation == Orientation.portrait
        ? screenHeight * 0.85
        : screenHeight * 0.75;
    double formPaddingWidth = orientation == Orientation.portrait
        ? screenWidth * 0.09
        : screenWidth * 0.035;
    double formPaddingHeight = orientation == Orientation.portrait
        ? screenHeight * 0.03
        : screenHeight * 0.05;
    double inputFieldHeight = orientation == Orientation.portrait
        ? screenHeight * 0.05
        : screenHeight * 0.065;

    return Scaffold(
      backgroundColor: const Color(0x00b7e9f6),
      body: Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            return Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15.84),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.84),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 25.74, sigmaY: 25.74),
                            child: Container(
                              padding: isFocused
                                  ? const EdgeInsets.fromLTRB(60, 15, 60, 15)
                                  : const EdgeInsets.fromLTRB(60, 60, 60, 70),
                              decoration: BoxDecoration(
                                color: const Color(0x29B7E9F6),
                                borderRadius: BorderRadius.circular(15.84),
                              ),
                              child: Container(
                                width: containerWidth,
                                height: containerHeight,
                                padding: EdgeInsets.symmetric(
                                  horizontal: formPaddingWidth,
                                  vertical: formPaddingHeight,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0x66FFFFFF),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.84),
                                  ),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Forgot Password?',
                                            style: GoogleFonts.inter(
                                              fontSize: 21.78,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Please enter the Username or Email ID to reset your password.',
                                            style: GoogleFonts.inter(
                                              fontSize: 16.83,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF4B4B4B),
                                            ),
                                          ),
                                          const SizedBox(height: 41.68),
                                          Text(
                                            'Username',
                                            style: GoogleFonts.inter(
                                              fontSize: 13.86,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF353535),
                                            ),
                                          ),
                                          const SizedBox(height: 7.92),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              boxShadow: userfocusNode.hasFocus
                                                  ? showErrorUserColor == false
                                                      ? [
                                                          const BoxShadow(
                                                            color: Color(
                                                                0xA3002B5C),
                                                            blurRadius: 4,
                                                            offset:
                                                                Offset(0, 0),
                                                          ),
                                                        ]
                                                      : null
                                                  : null,
                                            ),
                                            // width: 329.78,
                                            // height: 47.52,
                                            // decoration: BoxDecoration(
                                            //   color: Colors.white,
                                            //   borderRadius: BorderRadius.circular(7.92),
                                            //   border: Border.all(color: Colors.white),
                                            // ),
                                            child: TextFormField(
                                              controller: userController,
                                              style: GoogleFonts.inter(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF353535),
                                              ),
                                              // onTap: () {
                                              //   FocusScope.of(context)
                                              //       .requestFocus(userfocusNode);
                                              // },
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              focusNode: userfocusNode,
                                              onTap: () {
                                                setState(() {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          userfocusNode);
                                                });
                                              },
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15.0,
                                                        vertical: 12.0),
                                                hintText: 'Username / Email ID',
                                                hintStyle: GoogleFonts.inter(
                                                  fontSize: 16.83,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      const Color(0xFF979797),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                    color: showErrorUserColor
                                                        ? const Color(
                                                            0xFFF44336)
                                                        : const Color(
                                                            0xFFD0D3D8),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                    color: userController
                                                            .text.isEmpty
                                                        ? showErrorUserColor
                                                            ? const Color(
                                                                0xFFF44336)
                                                            : const Color(
                                                                0xFFD0D3D8)
                                                        : const Color(
                                                            0xFFB3B3B3),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                    color: showErrorUserColor
                                                        ? const Color(
                                                            0xFFF44336)
                                                        : const Color(
                                                            0xFF002B5C),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFFF44336),
                                                      width: 1.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFFF44336),
                                                      width: 1.0),
                                                ),
                                                errorStyle: GoogleFonts.inter(
                                                  color:
                                                      const Color(0xFFF44336),
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter your username or email';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value.isNotEmpty) {
                                                    showErrorUserColor = false;
                                                  } else {
                                                    showErrorUserColor = true;
                                                  }
                                                });
                                              },
                                              onSaved: (value) {
                                                userController.text =
                                                    value ?? '';
                                                _username = value ?? '';
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Center(
                                            child: SizedBox(
                                              width: 329.78,
                                              height: 47.52,
                                              child: ElevatedButton(
                                                onPressed:
                                                    _handleForgotPassword,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF1E90FF),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        inputFieldHeight * 0.25,
                                                  ),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(7.92),
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Send Code',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.83,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFFFEFEFE),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(width: 8),
                                              Text(
                                                'Back to',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16.83,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54,
                                                  height: 16 / 12,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, '/login');
                                                },
                                                child: Text(
                                                  'Sign in',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.83,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFF3b475b),
                                                    height: 16 / 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
