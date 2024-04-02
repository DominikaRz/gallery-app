/*
 Gallery app should: 
  1.1 (3p) allow user to take (or upload/use) photo
  1.2 (2p) display gallery of photos which were taken by the app
  1.3 (3p) when user select specyfic photos he see it full screen and can move to 
      next/previous by swiping gesture
  1.4 (2p) allow user to zoom photo
 */

/*
  To previous gallery app add functionality:
    2.1 (5p) add text recognition functionality and print text 
            in simillar way as tags in samples app
    2.2 (5p) add object detection functionality and draw them on the image 
*/

/*
  Additional information: 
  Aplication contains three options to upload photo for first task:
    - use existing one by importing multiple files
    - use one photo fron some path
    - take a photo using build in camera
    - there is also commented functionality to pick the whole folder, 
      but it is only working on Android version < 10
  There is also additional functionality: 
    when pressed longer on the picture, the dialog with deletion will appear (working)

  For second task there are functionalities 
  (form image view bar starting from the first icon from left):
    - new screen with only text that can be copy 
    - new screen with recognized text that is on image (for 2.1)
    - new screen with accuracy of tags 
    - new screen with paited objects with tags (most of them) on image (for 2.2)
*/

import 'package:flutter/material.dart';
import 'package:gallery/homePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Photo Gallery'),
    );
  }
}
