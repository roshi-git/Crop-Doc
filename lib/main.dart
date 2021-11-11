import 'package:crop_doctor/classes/processed_image.dart';
import 'package:crop_doctor/screens/about.dart';
import 'package:crop_doctor/screens/disease_description.dart';
import 'package:crop_doctor/screens/examine_leaf.dart';
import 'package:crop_doctor/screens/image_details.dart';
import 'package:crop_doctor/screens/images_library.dart';
import 'package:crop_doctor/screens/diseases_library.dart';
import 'package:crop_doctor/screens/capture_image.dart';
import 'package:crop_doctor/screens/home.dart';
import 'package:crop_doctor/screens/load_image.dart';
import 'package:crop_doctor/screens/plant__diseases.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);

  Hive.registerAdapter(ProcessedImageAdapter());
  Hive.openBox<ProcessedImage>("processedImages");

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
      "/image_details": (context) => ImageDetails(),
      "/plant_diseases": (context) => PlantDiseases(),
      "/disease_description": (context) => DiseaseDescription()
    }
  ));
}

