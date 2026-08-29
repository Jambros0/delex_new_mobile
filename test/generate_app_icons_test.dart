import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  testWidgets('Generate App Icons and Splash Logo from Delex Logo SVG', (WidgetTester tester) async {
    final sizes = {
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };

    final String svgStr = File('lib/src/features/home/assets/svg/delex_logo_home_page.svg').readAsStringSync();
    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(svgStr), null);

    // 1. Generate App Icons (Dark Background #0A0E1A)
    for (final entry in sizes.entries) {
      final folder = entry.key;
      final size = entry.value;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));

      final bgPaint = Paint()..color = const Color(0xFF0A0E1A);
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(size * 0.2),
      );
      canvas.drawRRect(rrect, bgPaint);

      canvas.save();
      final double scale = (size * 0.82) / pictureInfo.size.width;
      final double offsetY = (size - (pictureInfo.size.height * scale)) / 2;
      final double offsetX = (size - (pictureInfo.size.width * scale)) / 2;
      canvas.translate(offsetX, offsetY);
      canvas.scale(scale, scale);
      canvas.drawPicture(pictureInfo.picture);
      canvas.restore();

      final ui.Image img = await recorder.endRecording().toImage(size, size);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final targetDir = Directory('android/app/src/main/res/$folder');
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }
      File('${targetDir.path}/delex_logo.png').writeAsBytesSync(bytes);
      File('${targetDir.path}/ic_launcher.png').writeAsBytesSync(bytes);
      File('${targetDir.path}/ic_launcher_round.png').writeAsBytesSync(bytes);
    }

    // 2. Generate Native Splash Logo Image (drawable/delex_logo.png) (384x120px)
    final splashWidth = 384;
    final splashHeight = 120;
    final splashRecorder = ui.PictureRecorder();
    final splashCanvas = Canvas(splashRecorder, Rect.fromLTWH(0, 0, splashWidth.toDouble(), splashHeight.toDouble()));

    splashCanvas.save();
    final double splashScale = (splashWidth * 0.9) / pictureInfo.size.width;
    final double splashOffsetY = (splashHeight - (pictureInfo.size.height * splashScale)) / 2;
    final double splashOffsetX = (splashWidth - (pictureInfo.size.width * splashScale)) / 2;
    splashCanvas.translate(splashOffsetX, splashOffsetY);
    splashCanvas.scale(splashScale, splashScale);
    splashCanvas.drawPicture(pictureInfo.picture);
    splashCanvas.restore();

    final ui.Image splashImg = await splashRecorder.endRecording().toImage(splashWidth, splashHeight);
    final splashByteData = await splashImg.toByteData(format: ui.ImageByteFormat.png);
    final splashBytes = splashByteData!.buffer.asUint8List();

    final drawableDir = Directory('android/app/src/main/res/drawable');
    if (!drawableDir.existsSync()) {
      drawableDir.createSync(recursive: true);
    }
    File('${drawableDir.path}/delex_logo.png').writeAsBytesSync(splashBytes);

    final drawableV21Dir = Directory('android/app/src/main/res/drawable-v21');
    if (!drawableV21Dir.existsSync()) {
      drawableV21Dir.createSync(recursive: true);
    }
    File('${drawableV21Dir.path}/delex_logo.png').writeAsBytesSync(splashBytes);
  });
}
