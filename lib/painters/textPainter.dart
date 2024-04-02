import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'coordinates_translator.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(this.recognizedText, this.absoluteImageSize);

  final RecognizedText recognizedText;
  final Size absoluteImageSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      //..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = Color(0x99000000);

    for (final textBlock in recognizedText.blocks) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 15,
            textDirection: TextDirection.rtl),
      );
      builder.pushStyle(ui.TextStyle(
          color: Colors.lightGreenAccent, background: background)); //
      builder.addText(textBlock.text);
      builder.pop();

      final left =
          translateX(textBlock.boundingBox.left, size, absoluteImageSize);
      final top =
          translateY(textBlock.boundingBox.top, size, absoluteImageSize);
      final right =
          translateX(textBlock.boundingBox.right, size, absoluteImageSize);
      final bottom =
          translateY(textBlock.boundingBox.bottom, size, absoluteImageSize);

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: right - left,
          )),
        Offset(left, top),
      );
    }
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}
