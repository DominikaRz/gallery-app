import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ObjectsScreen extends StatelessWidget {
  final String text;
  final paint;
  final File image;

  const ObjectsScreen(
      {required this.text, required this.paint, required this.image});

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object detection:'),
      ),
      body: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
          AspectRatio(
            aspectRatio: 1 / 1,
            child: CustomPaint(painter: paint),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          Clipboard.setData(ClipboardData(text: text));
        },
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.copy),
      ),
    );
  }
}
