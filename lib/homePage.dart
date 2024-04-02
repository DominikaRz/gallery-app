import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//detail screens for text and object detection and label view
import 'package:gallery/screens/showTextScreen.dart';
import 'package:gallery/screens/labelAccuracyScreen.dart';
import 'package:gallery/screens/textScreen.dart';
import 'package:gallery/screens/objectScreen.dart';
//painters for detection
import 'package:gallery/painters/textPainter.dart';
import 'package:gallery/painters/objectPainter.dart';

//for text scan (Warning: Access to Internet required!)
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';

//for routs
import 'package:image_picker/image_picker.dart';
//import 'package:file_picker/file_picker.dart'; //for comented function

//for photos
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<File> _images; //list of images
  late int _currentIndex; //setting index that was currently choosen

  @override
  void initState() {
    super.initState();
    _images = [];
    _currentIndex = 0;
  }

  //picking one file (form manager or camera)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    //if there was something choosen then add to list of images
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

//Pick the whole folder of files
//unfortunately not fully working on Android, but on emulator is working correctly
  /*
  Future<void> _pickFolder() async {
    final folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      final directory = Directory(folderPath);
      final imageFiles = directory
          .listSync()
          .where((file) =>
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.jpeg') ||
              file.path.endsWith('.png'))
          .toList();
      setState(() {
        _images += imageFiles.map((file) => File(file.path)).toList();
        _currentIndex = 0;
        print(imageFiles);
      });
    }
  }
  */

  //picking multiple files
  Future<void> _pickMultiple() async {
    final pickedFiles =
        await ImagePicker().pickMultiImage(); //get the path of files
    //if user set any file add them to list one by one
    if (pickedFiles != null) {
      List<File> pickedImages = [];
      for (var pickedFile in pickedFiles) {
        pickedImages.add(File(pickedFile.path));
      }
      setState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  //setting index to show right image
  void _setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
      // Check if there are any images left in the gallery after deleting one
      if (_images.isEmpty) {
        _currentIndex = 0;
      } else if (_currentIndex >= _images.length) {
        // If the current index is out of range, set it to the last image in the gallery
        _currentIndex = _images.length - 1;
      }
    });
  }

  //show one item (fullscreen)
  Widget _buildGalleryItem(BuildContext context, int index, int _currentIndex) {
    return GestureDetector(
      //setting the doube tap and pinch to zoom gesture
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
              ),
              body: PhotoViewGallery.builder(
                itemCount: _images.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(_images[index]),
                    minScale: PhotoViewComputedScale.contained * 0.5,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    initialScale: PhotoViewComputedScale.covered * 1.0,
                  );
                },
                //scrollDirection: Axis.horizontal,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                pageController: PageController(initialPage: index),
              ),
            ),
          ),
        );
      },
      //show the image
      child: Image.file(
        _images[index],
        fit: BoxFit.contain,
      ),
    );
  }

  //show list of items (the grid)
  Widget _buildGridItem(BuildContext context, int index) {
    return GestureDetector(
      //set action on tap
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                /**/
                backgroundColor: Colors.black,
                actions: [
                  //for text recognizer
                  IconButton(
                    icon: const Icon(Icons
                        .format_color_text_rounded), //type_specimen_rounded
                    onPressed: () {
                      _scanImage(_images[index]);
                    },
                  ),
                  //for text painter
                  IconButton(
                    //for text recognizer
                    icon: const Icon(Icons.type_specimen_rounded),
                    onPressed: () {
                      writeTextOnImage(_images[index]);
                    },
                  ),
                  //for label detection
                  SizedBox(width: 20),
                  IconButton(
                    //for text recognizer
                    icon: const Icon(Icons.tag_outlined),
                    onPressed: () {
                      _scanForLabels(_images[index]);
                    },
                  ),
                  //for object detection
                  IconButton(
                    //for text recognizer
                    icon: const Icon(Icons.sell),
                    onPressed: () {
                      paintObjectsOnImage(_images[index]);
                    },
                  ),
                ],
              ),
              body: PageView.builder(
                controller: PageController(initialPage: index),
                itemCount: _images.length,
                onPageChanged: _setCurrentIndex,
                itemBuilder: (context, index) =>
                    _buildGalleryItem(context, index, _currentIndex),
              ),
            ),
          ),
        );
      },
      //setting the delete function
      onLongPress: () {
        showDialog(
          context: context,
          //the allert box tor deleting the file
          builder: (context) => AlertDialog(
            title: const Text('Delete image?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _images.removeAt(index);
                    if (_currentIndex == index) {
                      _currentIndex = 0;
                    } else if (_currentIndex > index) {
                      _currentIndex--;
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Delete'),
              ),
            ],
          ),
        );
      },
      //show the image
      child: Image.file(
        _images[index],
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          //show the buttons of adding the files
          IconButton(
            //for camera
            icon: Icon(Icons.add_a_photo),
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          IconButton(
            //for one picture
            icon: Icon(Icons.photo),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          IconButton(
            //for multiple pictures
            icon: Icon(Icons.photo_library),
            onPressed: _pickMultiple,
          ), /*
          IconButton(
            //for multiple pictures
            icon: Icon(Icons.add),
            onPressed: _pickFolder,
          ),*/
        ],
      ),
      body: Center(
        child: _images.isEmpty //if the gallery is empty
            ? const Text('No images selected.')
            : GridView.builder(
                //else show the grid of images
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _images.length,
                itemBuilder: _buildGridItem,
              ),
      ),
    );
  }

  //for text recognition
  final _textRecognizer = TextRecognizer();

  //recognition of text in given image (next screen)
  Future<void> _scanImage(File item) async {
    final navigator = Navigator.of(context); //inicialize next screen

    try {
      //convert File to InputImage
      final file = File(item.path);
      final inputImage = InputImage.fromFile(file);
      //recognize text form image
      final recognizedText = await _textRecognizer.processImage(inputImage);

      await navigator.push(
        //navigate to next screen with ability to copy text
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ShowTextScreen(text: recognizedText.text),
        ),
      );
    } catch (e) {
      //for error detection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
    _textRecognizer.close(); //close recognizer
  }

  //write text on image
  Future<void> writeTextOnImage(File image) async {
    final navigator = Navigator.of(context); //inicialize next screen
    //convert File to InputImage
    final file = File(image.path);
    final inputImage = InputImage.fromFile(file);
    //inicialize text recognition
    final recognizedText = await _textRecognizer.processImage(inputImage);

    //get the size of the photo (inputImage is not working here)
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());
    Size size =
        Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());

    if (size != null) {
      //inicialize the painter
      final painter = TextRecognizerPainter(recognizedText, size);
      await navigator.push(
        //navigate to next screen that will show the text on image
        MaterialPageRoute(
          builder: (BuildContext context) => TextScreen(
            text: recognizedText.text,
            paint: painter,
            image: image,
          ),
        ),
      );
    }
  }

  //label detection in next screen
  Future<void> _scanForLabels(File item) async {
    final navigator = Navigator.of(context); //inicialize next screen
    try {
      final inputImage =
          InputImage.fromFilePath(item.path); //convert to InputImage
      //inicialize laberer
      ImageLabeler imageLabeler =
          ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.65));
      //recognize labels form image
      List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
      //get the label with confidence
      StringBuffer sb = StringBuffer();
      for (ImageLabel imgLabel in labels) {
        String lblText = imgLabel.label;
        double confidence = imgLabel.confidence;
        sb.write(lblText);
        sb.write(" : ");
        sb.write((confidence * 100).toStringAsFixed(2));
        sb.write("%\n");
      }
      imageLabeler.close(); //close laberer
      String imageLabel = sb.toString(); //assign recognized labels to variable
      setState(() {});

      await navigator.push(
        //navigate to next screen that will show all teh recognized labels with accuracy > than 65%
        MaterialPageRoute(
          builder: (BuildContext context) =>
              LabelScreen(text: imageLabel, image: item),
        ),
      );
    } catch (e) {
      //for error detection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
    _textRecognizer.close();
  }

  //for detecting objects
  late ObjectDetector objectDetector;

  //paint detected objects on image
  Future<void> paintObjectsOnImage(File image) async {
    final navigator = Navigator.of(context); //inicialize next screen
    final file = File(image.path);
    final inputImage = InputImage.fromFile(file);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    //path to detection model
    final path =
        'assets/ml/lite-model_object_detection_mobile_object_labeler_v1_1.tflite';

    //inicialize object detection
    final modelPath = await _getModel(path); //get whole path
    final options = LocalObjectDetectorOptions(
      //assign options
      mode: DetectionMode.single,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );
    objectDetector =
        ObjectDetector(options: options); //inicialize object detector
    final objects = await objectDetector
        .processImage(inputImage); //assign objects to variable

    //get the size of the photo (inputImage is not working here)
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());
    Size size =
        Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());

    if (size != null) {
      final painter = ObjectDetectorPainter(objects, size); //initialize painter

      await navigator.push(
        //navigate to next screen that will show the objects with labels on image
        MaterialPageRoute(
          builder: (BuildContext context) => ObjectsScreen(
            text: recognizedText.text,
            paint: painter,
            image: image,
          ),
        ),
      );
    } else {
      //in case of null in photo size
      String text = 'Objects found: ${objects.length}\n\n';
      for (final object in objects) {
        text +=
            'Object:  trackingId: ${object.trackingId} - ${object.labels.map((e) => e.text)}\n\n';
      }
    }
    objectDetector.close(); //close object detector
  }
}

//get path to object recognition model
Future<String> _getModel(String assetPath) async {
  if (Platform.isAndroid) {
    //for Android
    return 'flutter_assets/$assetPath';
  }
  //for rest
  final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
  await Directory(path).create(recursive: true);
  final file = File(path);

  if (!await file.exists()) {
    final byteData = await rootBundle.load(assetPath);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  return file.path;
}

//used code:
// - https://github.com/svprdga/Text-Recognition-Flutter
// - https://github.com/ritsat/image_labelling/
// - https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/google_ml_kit/example
