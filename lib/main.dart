import 'package:crop_doctor/screens/about.dart';
import 'package:crop_doctor/screens/examine_leaf.dart';
import 'package:crop_doctor/screens/image_details.dart';
import 'package:crop_doctor/screens/images_library.dart';
import 'package:crop_doctor/screens/diseases_library.dart';
import 'package:crop_doctor/screens/capture_image.dart';
import 'package:crop_doctor/screens/home.dart';
import 'package:crop_doctor/screens/load_image.dart';

import 'package:flutter/material.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      "/": (context) => Home(),
      "/capture_image":  (context) => CaptureImage(),
      "/load_image": (context) => LoadImage(),
      "/images_library":  (context) => ImagesLibrary(),
      "/disease_library":  (context) => DiseasesLibrary(),
      "/about":  (context) => About(),
      "/examine_leaf": (context) => ExamineLeaf(),
      "/image_details": (context) => ImageDetails()
    }
  ));
}
