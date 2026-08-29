import 'dart:convert';
import 'dart:io';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/file_upload_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class UploadSignatureScreen extends StatefulWidget {
  final VoidCallback? onSignatureSaved;

  const UploadSignatureScreen({super.key, this.onSignatureSaved});

  @override
  State<UploadSignatureScreen> createState() => _UploadSignatureScreenState();
}

class _UploadSignatureScreenState extends State<UploadSignatureScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final ValueNotifier<bool> _isSignatureDrawn = ValueNotifier<bool>(false);
  final DBHelper dbHelper = DBHelper();
  String _loggedInUserName = '';
  bool _isConfirmed = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _signatureController.onDrawStart = () {
      if (!_isSignatureDrawn.value) {
        _isSignatureDrawn.value = true;
      }
    };
  }

  Future<void> _fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final user = await dbHelper.getLoggedInUserByUserId(userId);
      if (user != null && mounted) {
        setState(() {
          _loggedInUserName = user.userName;
        });
      }
    }
    if (_loggedInUserName.isEmpty) {
      final username = prefs.getString('username');
      if (username != null && mounted) {
        setState(() {
          _loggedInUserName = username;
        });
      }
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _isSignatureDrawn.dispose();
    super.dispose();
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  Future<void> _saveSignature() async {
    if (!_isConfirmed) {
      _showToast('Please confirm that this is your signature by checking the box', Colors.red);
      return;
    }
    if (_signatureController.isEmpty) {
      _showToast('Please draw a signature first', Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Uint8List? data = await _signatureController.toPngBytes();
      if (data != null) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');

        if (kIsWeb) {
          if (userId != null) {
            final user = await dbHelper.getLoggedInUserByUserId(userId);
            if (user != null) {
              user.signature = 'data:image/png;base64,${base64Encode(data)}';
              await dbHelper.updateUser(user);
              await prefs.setBool('has_completed_signature_$userId', true);
              _showToast('Signature updated successfully', Colors.green);
              widget.onSignatureSaved?.call();
            } else {
              _showToast('User not found', Colors.red);
            }
          } else {
            _showToast('No logged-in user found', Colors.red);
          }
          return;
        }
        final directory = await getApplicationDocumentsDirectory();
        const String extension = 'jpg';
        final String filePath = '${directory.path}/signature.$extension';
        final File file = File(filePath);

        await file.writeAsBytes(data);

        if (userId != null) {
          final user = await dbHelper.getLoggedInUserByUserId(userId);
          if (user != null) {
            user.signature = filePath;
            await dbHelper.updateUser(user);
            await prefs.setBool('has_completed_signature_$userId', true);

            try {
              final fileUploadUtil = FileUploadUtil();
              final response =
                  await fileUploadUtil.fileUpload(file, 'userSignature');
              if (response['status'] == true) {
                _showToast('Signature updated successfully', Colors.green);
              } else {
                _showToast('Signature saved locally', Colors.green);
              }
            } catch (e) {
              _showToast('Signature saved locally', Colors.green);
            }
            widget.onSignatureSaved?.call();
          } else {
            _showToast('User not found', Colors.red);
          }
        } else {
          _showToast('No logged-in user found', Colors.red);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 608,
                  height: 557,
                  padding: const EdgeInsets.only(bottom: 24),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: const [
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
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          color: Colors.white,
                          border: Border(
                            left: BorderSide(color: Color(0xFFF2F2F7)),
                            top: BorderSide(color: Color(0xFFF2F2F7)),
                            right: BorderSide(color: Color(0xFFF2F2F7)),
                            bottom:
                                BorderSide(width: 1, color: Color(0xFFF2F2F7)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x28002B5C),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        child: Text(
                                          'Register Your Signature',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF1B2029),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            height: 1.60,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                  arguments: {
                                    'menu': 'Landing Screen',
                                    'isCollapsed': false,
                                  },
                                );
                              },
                              child: const SizedBox(
                                width: 32,
                                height: 32,
                                child:
                                    Icon(Icons.close, color: Color(0xFF3b475b)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Please create your signature below.',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF212121),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'This signature will be securely stored and used for reports and approvals completed under your account.',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF6A6A6A),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFFBFBFB),
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFD3D3D3)),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 55,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                        color:
                                                            Color(0xFFD3D3D3)),
                                                    top: BorderSide(
                                                        color:
                                                            Color(0xFFD3D3D3)),
                                                    right: BorderSide(
                                                        color:
                                                            Color(0xFFD3D3D3)),
                                                    bottom: BorderSide(
                                                        width: 1,
                                                        color:
                                                            Color(0xFFD3D3D3)),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        child: Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'Signer: ',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: const Color(
                                                                      0xFF6A6A6A),
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.42,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    _loggedInUserName.isNotEmpty
                                                                        ? _loggedInUserName
                                                                        : 'User',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: const Color(
                                                                      0xFF353535),
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  height: 1.42,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      onTap: () {
                                                        _signatureController
                                                            .clear();
                                                        _isSignatureDrawn
                                                            .value = false;
                                                      },
                                                      child:
                                                          ValueListenableBuilder<
                                                              bool>(
                                                        valueListenable:
                                                            _isSignatureDrawn,
                                                        builder: (context,
                                                            isDrawn, child) {
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        12),
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                ShapeDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Clear Signature',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    color: isDrawn
                                                                        ? const Color(
                                                                            0xFFF66358)
                                                                        : const Color(
                                                                            0xFFD3D3D3),
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    decorationColor:
                                                                        isDrawn
                                                                            ? const Color(
                                                                                0xFFF66358)
                                                                            : const Color(
                                                                                0xFFD3D3D3),
                                                                    height:
                                                                        1.41,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Flexible(
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration:
                                                        const ShapeDecoration(
                                                      color: Color(0xFFFBFBFB),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: Color(
                                                                0xFFD3D3D3)),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  8),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  8),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Signature(
                                                      controller:
                                                          _signatureController,
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFFBFBFB),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                       Row(
                                         crossAxisAlignment: CrossAxisAlignment.center,
                                         children: [
                                           SizedBox(
                                             height: 24,
                                             width: 24,
                                             child: Checkbox(
                                               value: _isConfirmed,
                                               activeColor: const Color(0xFF1E90FF),
                                               shape: RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.circular(4),
                                               ),
                                               onChanged: (val) {
                                                 setState(() {
                                                   _isConfirmed = val ?? false;
                                                 });
                                               },
                                             ),
                                           ),
                                           const SizedBox(width: 8),
                                           Expanded(
                                             child: GestureDetector(
                                               onTap: () {
                                                 setState(() {
                                                   _isConfirmed = !_isConfirmed;
                                                 });
                                               },
                                               child: Text(
                                                 'I confirm that this is my signature and agree to its use for authorized transactions performed using my account.',
                                                 style: GoogleFonts.inter(
                                                   color: const Color(0xFF6A6A6A),
                                                   fontSize: 14,
                                                   fontWeight: FontWeight.w400,
                                                   height: 1.33,
                                                 ),
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                               const SizedBox(height: 16),
                               SizedBox(
                                 width: double.infinity,
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   mainAxisAlignment: MainAxisAlignment.end,
                                   crossAxisAlignment: CrossAxisAlignment.center,
                                   children: [
                                     Row(
                                       mainAxisSize: MainAxisSize.min,
                                       mainAxisAlignment:
                                           MainAxisAlignment.start,
                                       crossAxisAlignment:
                                           CrossAxisAlignment.center,
                                       children: [
                                         GestureDetector(
                                           onTap: () {
                                             Navigator.pop(context);
                                           },
                                           child: Container(
                                             padding: const EdgeInsets.symmetric(
                                                 horizontal: 24, vertical: 12),
                                             decoration: ShapeDecoration(
                                               color: Colors.white,
                                               shape: RoundedRectangleBorder(
                                                 side: const BorderSide(
                                                     width: 1,
                                                     color: Color(0xFFAB2F26)),
                                                 borderRadius:
                                                     BorderRadius.circular(8),
                                               ),
                                               shadows: const [
                                                 BoxShadow(
                                                   color: Color(0x3D1A85EC),
                                                   blurRadius: 2,
                                                   offset: Offset(0, 0),
                                                   spreadRadius: 0,
                                                 )
                                               ],
                                             ),
                                             child: Text(
                                               'Cancel',
                                               textAlign: TextAlign.center,
                                               style: GoogleFonts.inter(
                                                 color: const Color(0xFFAB2F26),
                                                 fontSize: 17,
                                                 fontWeight: FontWeight.w600,
                                                 height: 1.41,
                                               ),
                                             ),
                                           ),
                                         ),
                                         const SizedBox(width: 16),
                                         GestureDetector(
                                           onTap: _isSaving ? null : _saveSignature,
                                           child: AnimatedContainer(
                                             duration: const Duration(milliseconds: 150),
                                             padding: const EdgeInsets.symmetric(
                                                 horizontal: 24, vertical: 12),
                                             decoration: ShapeDecoration(
                                               color: _isConfirmed
                                                   ? const Color(0xFF1E90FF)
                                                   : const Color(0xFF9E9E9E),
                                               shape: RoundedRectangleBorder(
                                                 side: BorderSide(
                                                     width: 1,
                                                     color: _isConfirmed
                                                         ? const Color(0xFF1769AA)
                                                         : const Color(0xFF757575)),
                                                 borderRadius:
                                                     BorderRadius.circular(8),
                                               ),
                                               shadows: const [
                                                 BoxShadow(
                                                   color: Color(0x3D1A85EC),
                                                   blurRadius: 2,
                                                   offset: Offset(0, 0),
                                                   spreadRadius: 0,
                                                 )
                                               ],
                                             ),
                                             child: _isSaving
                                                 ? const SizedBox(
                                                     width: 20,
                                                     height: 20,
                                                     child: CircularProgressIndicator(
                                                       strokeWidth: 2,
                                                       valueColor:
                                                           AlwaysStoppedAnimation<Color>(
                                                               Colors.white),
                                                     ),
                                                   )
                                                 : Text(
                                                     'Save Signature',
                                                     textAlign: TextAlign.center,
                                                     style: GoogleFonts.inter(
                                                       color:
                                                           const Color(0xFFFEFEFE),
                                                       fontSize: 17,
                                                       fontWeight: FontWeight.w600,
                                                       height: 1.41,
                                                     ),
                                                   ),
                                           ),
                                         ),
                                       ],
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
              ],
            ),
          ),
        ));
  }
}
