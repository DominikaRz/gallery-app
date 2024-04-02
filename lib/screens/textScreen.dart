import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextScreen extends StatelessWidget {
  final String text;
  final paint;
  final File image;

  const TextScreen(
      {required this.text, required this.paint, required this.image});

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognized text on image:'),
      ),
      body: Stack(
        children: <Widget>[
          Image.file(image),
          AspectRatio(
            aspectRatio: 100 / 100,
            child: CustomPaint(painter: paint),
          ),
        ],
      ),
    );
  }
}
