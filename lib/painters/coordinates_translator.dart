import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateX(double x, Size size, Size absoluteImageSize) {
  return x * size.width / absoluteImageSize.width;
}

double translateY(double y, Size size, Size absoluteImageSize) {
  return y * size.height / absoluteImageSize.height;
}
