import 'dart:convert';
import 'dart:io';

import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/signature_upload_page/ui/screens/upload_signature_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/network_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils _authUtils = AuthUtils();
  final NetworkUtils _networkUtils = NetworkUtils();

  UserDetails? _user;
  String? _userType;
  String _employeeId = 'NA';
  bool _isLoading = true;
  ImageProvider? _signatureImageProvider;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final userType = await _authUtils.getUserType();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? prefs.getString('user_id');
      final empId = prefs.getString('employeeId') ??
          prefs.getString('employee_id') ??
          prefs.getString('empId');

      UserDetails? user;
      if (userId != null && userId.isNotEmpty) {
        user = await _dbHelper.getLoggedInUserByUserId(userId);
      }
      user ??= await _dbHelper.getLoggedInUser();

      ImageProvider? sigProvider;
      String rawSig = (user?.signature ?? '').trim();
      if (rawSig.isEmpty && userId != null) {
        rawSig = (prefs.getString('userSignature') ??
                prefs.getString('signature_$userId') ??
                '')
            .trim();
      }

      if (rawSig.isNotEmpty) {
        if (rawSig.startsWith('data:image') || rawSig.contains(';base64,')) {
          final base64Data = rawSig.split(',').last;
          sigProvider = MemoryImage(base64Decode(base64Data));
        } else if (rawSig.startsWith('http://') ||
            rawSig.startsWith('https://')) {
          sigProvider = NetworkImage(rawSig);
        } else {
          final file = File(rawSig);
          if (await file.exists()) {
            sigProvider = FileImage(file);
          } else {
            try {
              final bytes = base64Decode(rawSig);
              if (bytes.isNotEmpty) {
                sigProvider = MemoryImage(bytes);
              }
            } catch (_) {}
          }
        }
      }

      setState(() {
        _user = user;
        _userType = userType;
        _employeeId =
            (empId != null && empId.isNotEmpty) ? empId : 'NA';
        _signatureImageProvider = sigProvider;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showSignatureDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: UploadSignatureScreen(
                onSignatureSaved: () {
                  Navigator.of(dialogContext).pop();
                  _loadUserProfile();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnline = _networkUtils.isNetworkAvailable;
    final String fullName = _user != null
        ? ('${_user!.firstName} ${_user!.lastName}'.trim().isNotEmpty
            ? '${_user!.firstName} ${_user!.lastName}'.trim()
            : _user!.userName)
        : 'User Profile';

    final String userRole = _user?.userRole.isNotEmpty == true
        ? _user!.userRole.toUpperCase()
        : 'INSPECTOR';

    final String userTypeDisplay = (_userType?.toLowerCase() == 'offshore')
        ? 'Offshore Facility'
        : 'Onshore Facility';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002B5C)),
                ),
              )
            : Column(
                children: [
                  // Top Header Bar
                  _buildHeader(context, isOnline),

                  // Main Content Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Column: Profile Card & Quick Info
                            Expanded(
                              flex: 4,
                              child: _buildLeftProfileCard(
                                  fullName, userRole, userTypeDisplay),
                            ),
                            const SizedBox(width: 20),

                            // Right Column: Detailed Information & Signature
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildAccountDetailsCard(userTypeDisplay),
                                  const SizedBox(height: 16),
                                  Expanded(child: _buildSignatureCard()),
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
    );
  }

  Widget _buildHeader(BuildContext context, bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A),
                  size: 20,
                ),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              Text(
                'User Profile',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Online / Offline Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Online Sync Active' : 'Offline Mode',
                      style: GoogleFonts.inter(
                        color: isOnline
                            ? const Color(0xFF047857)
                            : const Color(0xFFB91C1C),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: Text(
                  'Close',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF334155),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftProfileCard(
      String fullName, String userRole, String userTypeDisplay) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF002B5C), Color(0xFF0056B3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002B5C).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(fullName),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            fullName,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Username
          Text(
            '@${_user?.userName ?? 'user'}',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFBAE6FD),
                width: 1,
              ),
            ),
            child: Text(
              userRole,
              style: GoogleFonts.inter(
                color: const Color(0xFF0369A1),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
          const SizedBox(height: 16),

          // Quick Highlights
          _buildQuickHighlightRow(
            Icons.location_city_rounded,
            'Environment',
            userTypeDisplay,
          ),
          const SizedBox(height: 12),
          _buildQuickHighlightRow(
            Icons.verified_user_rounded,
            'Status',
            'Active Account',
            valueColor: const Color(0xFF059669),
          ),
          const SizedBox(height: 12),
          _buildQuickHighlightRow(
            Icons.badge_rounded,
            'Employee ID',
            _employeeId,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHighlightRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: valueColor ?? const Color(0xFF0F172A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetailsCard(String userTypeDisplay) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  color: Color(0xFF002B5C), size: 20),
              const SizedBox(width: 8),
              Text(
                'Account Information',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailGrid([
            _DetailItem('First Name', _user?.firstName ?? '--'),
            _DetailItem('Last Name', _user?.lastName ?? '--'),
            _DetailItem('Username', _user?.userName ?? '--'),
            _DetailItem('Email Address', _user?.email ?? '--'),
            _DetailItem('Employee ID', _employeeId),
            _DetailItem('Role / Position', _user?.userRole ?? '--'),
            _DetailItem('Facility Type', userTypeDisplay),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailGrid(List<_DetailItem> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 14,
      children: items.map((item) {
        return SizedBox(
          width: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value.isNotEmpty ? item.value : '--',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSignatureCard() {
    final bool hasSignature = _signatureImageProvider != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.draw_rounded,
                      color: Color(0xFF002B5C), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Digital Signature',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hasSignature
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasSignature ? 'Verified Signature' : 'Pending Upload',
                  style: GoogleFonts.inter(
                    color: hasSignature
                        ? const Color(0xFF047857)
                        : const Color(0xFFB91C1C),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: hasSignature
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: _signatureImageProvider!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.gesture_rounded,
                            color: Color(0xFF94A3B8), size: 28),
                        const SizedBox(height: 4),
                        Text(
                          'No digital signature recorded',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _showSignatureDialog,
              icon: Icon(
                hasSignature ? Icons.edit_rounded : Icons.draw_rounded,
                size: 16,
              ),
              label: Text(
                hasSignature ? 'Update Signature' : 'Save Signature Here',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSignature
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFF002B5C),
                foregroundColor: hasSignature
                    ? const Color(0xFF334155)
                    : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: hasSignature
                      ? const BorderSide(color: Color(0xFFCBD5E1))
                      : BorderSide.none,
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  _DetailItem(this.label, this.value);
}
