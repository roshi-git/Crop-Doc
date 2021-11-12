import 'dart:io';

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
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'classes/plant_info.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final appDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDirectory.path);

  Hive.registerAdapter(ProcessedImageAdapter());
  Hive.openBox<ProcessedImage>("processedImages");

  Hive.registerAdapter(PlantInfoAdapter());
  Hive.openBox<PlantInfo>("plantInfo");

  await fetchPlantInfo(appDirectory);
  fetchDiseasesInfo(appDirectory);

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

Future<void> fetchPlantInfo(var appDirectory) async {

  await Firebase.initializeApp();

  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("plantsList");

  //TODO: DO THIS
  /*StreamSubscription dbStream = dbRef.onValue.listen((event) {
    var val = event.snapshot.value;
    var key = event.snapshot.key;
    print(val);
    print(key);
  });
  dbStream.resume();
  dbStream.cancel();*/

  // GET PLANT NAMES AND TYPES FROM FIREBASE RTDB
  var values;
  await dbRef.get().then((snapshot) => values = snapshot.value);

  List<PlantInfo> plantsList = [];
  Box<PlantInfo> plantInfoDatabase = Hive.box<PlantInfo>("plantInfo");

  for(String plant in values.keys) {

    bool fileExists = await File("${appDirectory.path}/$plant.jpg").exists();
    String imageDirectory = "${appDirectory.path}/$plant.jpg";

    // IF PLANT IMAGE IS DOWNLOADED, NO NEED TO DOWNLOAD IMAGE
    // OTHERWISE DOWNLOAD IMAGE AND STORE ITS PATH IN THE DB
    if(!fileExists) {

      File imageFile = File(imageDirectory);

      var response = await Dio().get(
          values[plant]["imageLink"],
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              receiveTimeout: 0
          )
      );

      var raf = imageFile.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    }

    PlantInfo plantInfo = PlantInfo(
        plantID: plant,
        plantNameEN: values[plant]["plantNameEN"],
        plantNameHI: values[plant]["plantNameHI"],
        plantTypeEN: values[plant]["plantTypeEN"],
        plantTypeHI: values[plant]["plantTypeHI"],
        plantImagePath: imageDirectory
    );

    plantInfoDatabase.put(plant, plantInfo);

    plantsList.add(plantInfo);
  }

  // SORT PLANTS ALPHABETICALLY
  plantsList.sort((a, b) => a.plantNameEN.compareTo(b.plantNameEN));

  print("Plants list fetched");
}

void fetchDiseasesInfo(var appDirectory) async {

}

