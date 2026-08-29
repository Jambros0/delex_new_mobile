import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/ui/widgets/forgot_left_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/forgot_right_column.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double imageFraction =
        MediaQuery.of(context).orientation == Orientation.portrait ? 1.0 : 0.5;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2A6FB2),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFF2A6FB2),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              child: Stack(
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: Image.asset(
                      'lib/src/features/login/assets/delex_background_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? Column(
                          children: [
                            SizedBox(
                              width: screenWidth,
                              height: screenHeight * 0.55,
                              child: const ForgotRightColumn(),
                            ),
                            SizedBox(
                              width: screenWidth,
                              height: screenHeight * 0.3,
                              child: const ForgotLeftColumn(),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(
                              width: screenWidth * imageFraction,
                              height: screenHeight,
                              child: const ForgotLeftColumn(),
                            ),
                            SizedBox(
                              width: screenWidth * (1 - imageFraction),
                              height: screenHeight,
                              child: const ForgotRightColumn(),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
