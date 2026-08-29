import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;

    double iconSize = orientation == Orientation.portrait
        ? screenHeight * 0.04
        : screenHeight * 0.08;

    EdgeInsetsGeometry padding = orientation == Orientation.portrait
        ? EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.02,
          )
        : EdgeInsets.symmetric(
            vertical: screenHeight * 0.025,
            horizontal: screenWidth * 0.02,
          );

    double containerWidth = screenWidth * 0.89;

    return Container(
      width: containerWidth,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FBFF), Color(0xFFCBE3FF)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'lib/src/features/landing_page/assets/svg/quick_access.svg',
            height: iconSize,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Access',
                style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121)),
              ),
              const SizedBox(height: 5),
              Text(
                'You may conduct the initial inspection for the equipment.',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6A6A6A)),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: screenWidth * 0.14,
            child: OutlinedButton(
              onPressed: () {
                // throw Exception();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                  arguments: {
                    'menu': 'Area Details',
                    'isCollapsed': true,
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF002B5C)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Add Inspection',
                style: TextStyle(
                  color: Color(0xFF002B5C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
