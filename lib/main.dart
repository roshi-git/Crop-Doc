import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crop_doctor/classes/disease_info.dart';
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
  await Hive.openBox<ProcessedImage>("processedImages");

  Hive.registerAdapter(PlantInfoAdapter());
  await Hive.openBox<PlantInfo>("plantInfo");

  //Hive.registerAdapter(DiseaseAdapter());
  await Hive.openBox<List<String>>("diseases");

  Hive.registerAdapter(DiseaseInfoAdapter());
  await Hive.openBox<DiseaseInfo>("diseaseInfo");

  await Hive.openBox("appStates");

  Box appStates = Hive.box("appStates");

  var languageID = appStates.get("languageID");
  if(languageID == null) {
    appStates.put("languageID", "EN");
  }

  var firstLaunch = appStates.get("firstLaunch");
  if(firstLaunch == null) {
    firstLaunch = true;
    appStates.put("firstLaunch", true);
  }
  MaterialApp _runApp;

  // MATERIAL APP TO RUN IF DATABASE CONTAINS ALL DATA
  MaterialApp materialApp = MaterialApp(
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
  );

  // MATERIAL APP TO RUN IF DATABASE IS MISSING SOME DATA
  MaterialApp materialAppError = MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            child: Text("No internet connection available")),
      )
  );

  // CHECK INTERNET CONNECTIVITY
  Connectivity connectivity = Connectivity();
  ConnectivityResult connectivityResult = await connectivity.checkConnectivity();

  // IF THERE IS INTERNET CONNECTION
  // FETCH DATA FROM FIREBASE
  if(connectivityResult != ConnectivityResult.none) {

    // CHECK WHEN THE DATABASE WAS LAST UPDATED
    await Firebase.initializeApp();
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("last_updated");
    var value;
    await dbRef.get().then((snapshot) => value = snapshot.value);
    var lastUpdated = appStates.get("last_updated");

    if(lastUpdated == null || lastUpdated < value) {
      appStates.put("last_updated", value);

      // GET PLANT NAMES AND TYPES FROM FIREBASE RTDB
      await fetchPlantInfo(appDirectory);
    }

    if(firstLaunch)
      appStates.put("firstLaunch", false);

    _runApp = materialApp;
  }
  else {
    if(firstLaunch)
      _runApp = materialAppError;
    else
      _runApp = materialApp;
  }

  runApp(_runApp);
}

Future<void> fetchPlantInfo(var appDirectory) async {

  // GET PLANT NAMES AND TYPES FROM FIREBASE RTDB
  await Firebase.initializeApp();
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("plantsList");
  var values;
  await dbRef.get().then((snapshot) => values = snapshot.value);

  Box<PlantInfo> plantInfoDatabase = Hive.box<PlantInfo>("plantInfo");
  Box<List<String>> diseaseListDatabase = Hive.box<List<String>>("diseases");
  Box<DiseaseInfo> diseaseInfoDatabase = Hive.box<DiseaseInfo>("diseaseInfo");

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

    var diseasesList = await fetchDiseasesList(plant);
    diseaseListDatabase.put(plant, diseasesList);
    for(String disease in diseasesList) {
      DiseaseInfo diseaseInfo = await fetchDiseaseInfo(appDirectory, disease);
      diseaseInfoDatabase.put(disease, diseaseInfo);
    }
  }

  print("Plants list fetched");
}

Future<List<String>> fetchDiseasesList(String plantID) async {

  // GET DISEASES NAMES AND STUFF FROM FIREBASE RTDB
  await Firebase.initializeApp();
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("diseasesGroups").child(plantID);
  var values;
  await dbRef.get().then((snapshot) => values = snapshot.value);

  List<String> diseasesList = [];
  for(String disease in values.keys)
    diseasesList.add(disease);

  print("Diseases list fetched");
  return diseasesList;
}

Future<DiseaseInfo> fetchDiseaseInfo(var appDirectory, String diseaseID) async {

  // GET DISEASE DESCRIPTION AND STUFF FROM FIREBASE RTDB
  await Firebase.initializeApp();
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("diseasesList").child(diseaseID);
  var values;
  await dbRef.get().then((snapshot) => values = snapshot.value);

  bool fileExists = await File("${appDirectory.path}/${values["diseaseNameEN"]}.jpg").exists();
  String imageDirectory = "${appDirectory.path}/${values["diseaseNameEN"]}.jpg";

  // IF DISEASE IMAGE IS DOWNLOADED, NO NEED TO DOWNLOAD IMAGE
  // OTHERWISE DOWNLOAD IMAGE AND STORE ITS PATH IN THE DB
  if(!fileExists) {

    File imageFile = File(imageDirectory);

    var response = await Dio().get(
        values["imageLink"],
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

  DiseaseInfo diseaseInfo = DiseaseInfo(
      diseaseID: diseaseID,
      diseaseNameEN: values["diseaseNameEN"],
      diseaseNameHI: values["diseaseNameHI"],
      diseaseDescriptionEN: values["descriptionEN"],
      diseaseDescriptionHI: values["descriptionHI"],
      diseaseImagePath: imageDirectory
  );

  print("Disease info fetched");

  return diseaseInfo;
}

//flutter packages pub run build_runner build