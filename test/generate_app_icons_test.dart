import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  testWidgets('Generate Transparent App Icon from Delex Logo SVG', (WidgetTester tester) async {
    final String svgStr = File('lib/src/features/home/assets/svg/delex_logo_home_page.svg').readAsStringSync();
    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(svgStr), null);

    // 1. Generate 1024x1024 Master Transparent App Icon PNG
    const double masterSize = 1024.0;
    final masterRecorder = ui.PictureRecorder();
    final masterCanvas = Canvas(masterRecorder, const Rect.fromLTWH(0, 0, masterSize, masterSize));

    masterCanvas.save();
    final double masterScale = (masterSize * 0.88) / pictureInfo.size.width;
    final double masterOffsetY = (masterSize - (pictureInfo.size.height * masterScale)) / 2;
    final double masterOffsetX = (masterSize - (pictureInfo.size.width * masterScale)) / 2;
    masterCanvas.translate(masterOffsetX, masterOffsetY);
    masterCanvas.scale(masterScale, masterScale);
    masterCanvas.drawPicture(pictureInfo.picture);
    masterCanvas.restore();

    final ui.Image masterImg = await masterRecorder.endRecording().toImage(masterSize.toInt(), masterSize.toInt());
    final masterByteData = await masterImg.toByteData(format: ui.ImageByteFormat.png);
    final masterBytes = masterByteData!.buffer.asUint8List();

    final imgDir = Directory('lib/src/features/home/assets/img');
    if (!imgDir.existsSync()) {
      imgDir.createSync(recursive: true);
    }
    File('${imgDir.path}/delex_logo_transparent_icon.png').writeAsBytesSync(masterBytes);
    File('${imgDir.path}/delex_logo.png').writeAsBytesSync(masterBytes);

    // 2. Generate Android Mipmap Icons (Transparent Background)
    final sizes = {
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };

    for (final entry in sizes.entries) {
      final folder = entry.key;
      final size = entry.value;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));

      canvas.save();
      final double scale = (size * 0.88) / pictureInfo.size.width;
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
  });
}
