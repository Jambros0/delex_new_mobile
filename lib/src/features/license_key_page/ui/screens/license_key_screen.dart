import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/license_key_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class LicenseKeyScreen extends StatefulWidget {
  const LicenseKeyScreen({super.key});

  @override
  LicenseKeyScreenState createState() => LicenseKeyScreenState();
}

class LicenseKeyScreenState extends State<LicenseKeyScreen> {
  final TextEditingController _licenseKeyController = TextEditingController(
      text: 'UXvFHZG8cs2ogkFX4cy3QrDgKqThD46WbImy1Ho8bYQ=');
  bool _isLoading = false;
  final authUtils = AuthUtils();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submitLicenseKey();
    });
  }

  Future<void> _submitLicenseKey() async {
    final licenseKey = _licenseKeyController.text.trim();
    if (licenseKey.isEmpty) {
      _showToast('Please enter your license key');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await LicenseKeyUtil().validateKey(licenseKey);
      if (isValid) {
        _showToast('License key is valid!');
        await authUtils.saveLicenseValidationStatus(true);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        _showToast(
            'The license key you have entered is invalid. Please contact your administrator');
      }
    } catch (e) {
      _showToast('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1E90FF),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16.0,
              left: 16.0,
              child: SvgPicture.asset(
                'lib/src/features/home/assets/svg/delex_logo_home_page.svg',
                height: 38,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30.0),
                      const Icon(
                        Icons.vpn_key_outlined,
                        color: Color(0xFF1E90FF),
                        size: 80.0,
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        'License Key',
                        style: GoogleFonts.inter(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: 300.0,
                        height: 45.0,
                        child: TextField(
                          controller: _licenseKeyController,
                          cursorColor: Colors.red,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'Enter your license key here',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitLicenseKey,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E90FF),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 118.0, vertical: 2.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: Text(
                                'SUBMIT',
                                style: GoogleFonts.inter(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
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
    );
  }
}
