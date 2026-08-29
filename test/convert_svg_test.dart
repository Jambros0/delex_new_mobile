import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  testWidgets('Convert SVG to PNG icon for launcher', (WidgetTester tester) async {
    const int iconSize = 1024;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, iconSize.toDouble(), iconSize.toDouble()));

    // Dark theme rounded background matching Delex login screen
    final bgPaint = Paint()..color = const Color(0xFF0A0E1A);
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, iconSize.toDouble(), iconSize.toDouble()),
      const Radius.circular(204),
    );
    canvas.drawRRect(rrect, bgPaint);

    final String svgStr = File('lib/src/features/home/assets/svg/delex_logo_home_page.svg').readAsStringSync();
    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(svgStr), null);

    canvas.save();
    final double scale = (iconSize * 0.8) / pictureInfo.size.width;
    final double offsetY = (iconSize - (pictureInfo.size.height * scale)) / 2;
    final double offsetX = (iconSize - (pictureInfo.size.width * scale)) / 2;
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();

    final ui.Image img = await recorder.endRecording().toImage(iconSize, iconSize);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final targetFile = File('lib/src/features/home/assets/img/delex_logo.png');
    targetFile.writeAsBytesSync(bytes);
    print('SUCCESS: Saved 1024x1024 PNG to ${targetFile.path}');
  });
}
