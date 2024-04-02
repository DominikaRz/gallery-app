import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabelScreen extends StatelessWidget {
  final String text;
  final File? image;

  const LabelScreen({required this.text, required this.image});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Recognized labels:'),
        ),
        body: Center(
          child: Column(
            children: [
              Image.file(
                image!,
                fit: BoxFit.contain,
              ),
              Container(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
