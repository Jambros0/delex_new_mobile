import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LeftColumn extends StatelessWidget {
  const LeftColumn({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.05;
    double iconWidth = screenWidth * 0.35;
    double iconHeight = iconWidth * 0.15;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.only(left: padding, bottom: padding * 1.5),
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'lib/src/features/home/assets/svg/delex_logo_home_page.svg',
                width: iconWidth,
                height: iconHeight,
              ),
              const SizedBox(height: 30),
              Text(
                'A Complete Solution For\n'
                    'Hazardous Area Inspection\n'
                    'And Management!',
                style: GoogleFonts.jost(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: 0.05 * 32,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 8.29),
                      blurRadius: 4.29,
                      color: Color(0xCC000000),
                    ),
                    const Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 4.29,
                      color: Color(0x52000000),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            SvgPicture.asset(
              'lib/src/features/home/assets/svg/delex_logo_home_page.svg',
              width: iconWidth,
              height: iconHeight,
            ),
            const SizedBox(height: 30),
            Text(
              'A Complete Solution For\n'
                  'Hazardous Area Inspection\n'
                  'And Management!',
              style: GoogleFonts.jost(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: 0.05 * 32,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    offset: Offset(0, 8.29),
                    blurRadius: 4.29,
                    color: Color(0xCC000000),
                  ),
                  const Shadow(
                    offset: Offset(0, 0),
                    blurRadius: 4.29,
                    color: Color(0x52000000),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );

  }
}
