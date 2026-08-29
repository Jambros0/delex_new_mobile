// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionsRequired extends StatelessWidget {
  const ActionsRequired({super.key});

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
      vertical: screenHeight * 0.01,
      horizontal: screenWidth * 0.02,
    )
        : EdgeInsets.symmetric(
      vertical: screenHeight * 0.025,
      horizontal: screenWidth * 0.02,
    );

    double containerWidth = screenWidth * 0.89;

    return Column(
      children: [
        Stack(
          children: [
            Positioned(
              left: 230.91,
              top: -129.28,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, 0.0)
                  ..rotateZ(pi / 1000),
                child: Container(
                  width: 872,
                  height: 223,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-0.94, 12),
                      end: const Alignment(1, -0),
                      colors: [
                        const Color(0xAF0E67AE),
                        Colors.white.withValues(alpha: 0)
                      ],
                    ),
                    shape: const OvalBorder(),
                  ),
                ),
              ),
            ),
            Positioned(
                left: 586.43,
                top: 318.28,
                child: Opacity(
                  opacity: 0.40,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translate(0.0, 0.0)
                      ..rotateZ(-3.01),
                    child: Container(
                      width: 773,
                      height: 180,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(0.64, -5.77),
                          end: const Alignment(-0.64, 0.77),
                          colors: [
                            const Color(0xAF0E67AE),
                            Colors.blue.withValues(alpha: 0)
                          ],
                        ),
                        shape: const OvalBorder(),
                      ),
                    ),
                  ),
                )),
            Container(
              width: containerWidth,
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD0D3D8),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'lib/src/features/landing_page/assets/svg/periodic_inspection.svg',
                    height: iconSize,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periodic Inspections',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Preventive Maintenance Inspections',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6A6A6A),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: screenWidth * 0.06,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                              (route) => false,
                          arguments: {
                            'menu': 'Ex Register',
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
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text(
                        'Go',
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
            ),
          ],
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            Positioned(
              left: 230.91,
              top: -129.28,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, 0.0)
                  ..rotateZ(pi / 1000),
                child: Container(
                  width: 872,
                  height: 223,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-0.94, 7),
                      end: const Alignment(0, -0),
                      colors: [
                        const Color(0xFFF44336),
                        Colors.white.withValues(alpha: 0)
                      ],
                    ),
                    shape: const OvalBorder(),
                  ),
                ),
              ),
            ),
            Positioned(
                left: 586.43,
                top: 318.28,
                child: Opacity(
                  opacity: 0.40,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translate(0.0, 0.0)
                      ..rotateZ(-3.01),
                    child: Container(
                      width: 773,
                      height: 180,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(0.64, -5.77),
                          end: const Alignment(-0.64, 0.77),
                          colors: [
                            const Color(0xFFF44336),
                            Colors.white.withValues(alpha: 0)
                          ],
                        ),
                        shape: const OvalBorder(),
                      ),
                    ),
                  ),
                )),
            Container(
              width: containerWidth,
              padding: padding,
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD0D3D8),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'lib/src/features/landing_page/assets/svg/repair_works.svg',
                    height: iconSize,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repair Works',
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF212121)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Corrective actions to be carried out',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6A6A6A)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: screenWidth * 0.06,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                          arguments: {
                            'menu': 'Ex Register',
                            'isCollapsed': true,
                            'filter': "Corrective Actions",
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
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Go',
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
            ),
          ],
        ),
      ],
    );
  }
}
