import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowTextScreen extends StatelessWidget {
  final String text;

  const ShowTextScreen({required this.text});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Copyable recognizedd text:'),
        ),
        body: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(30.0),
                  child: SelectableText(text),
                ),
              ),
            ],
          ),
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
