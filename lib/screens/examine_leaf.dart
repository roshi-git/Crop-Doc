import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crop_doctor/classes/colors.dart';
import 'package:crop_doctor/classes/disease_id_map.dart';
import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/processed_image.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tflite/tflite.dart';
import 'package:http/http.dart' as http;

class ExamineLeaf extends StatefulWidget {
  @override
  _ExamineLeafState createState() => _ExamineLeafState();
}

class _ExamineLeafState extends State<ExamineLeaf> {

  // LOAD THE ML MODEL
  Future<void> loadModel() async {
    var result = await Tflite.loadModel(
        model: "assets/model/simple_model.tflite",
        labels: "assets/model/labels.txt"
    );

    print(result);
  }

  // PREDICT CLASS OF THE DISEASE LOCALLY
  void predictClass(String imagePath) async {

    // PREDICT CLASS OF DISEASE
    List? result = await Tflite.runModelOnImage(
      path: imagePath,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 2
    );
    print(result);

    int index = result![0]["index"];
    String diseaseID;

    // CHECK IF DISEASE IS RELATED TO TOMATO
    if(index < 28)
      diseaseID = "unknown";
    else
      diseaseID = DiseaseIDMap.diseaseIDMap[index];

    // STORE DISEASE INFO
    Box<ProcessedImage> processedImagesDatabase = Hive.box<ProcessedImage>("processedImages");
    processedImagesDatabase.add(ProcessedImage(
        imagePath: imagePath,
        diseaseID: diseaseID,
        epochSeconds: DateTime.now().millisecondsSinceEpoch
    ));

    var arguments = {
      "filePath": imagePath,
      "diseaseID": diseaseID,
    };
    Navigator.pushReplacementNamed(context, "/image_details", arguments: arguments);
  }

  // PREDICT CLASS OF THE DISEASE ON THE SERVER
  void predictClassOnline(String fileURL) async {

  }

  // UPLOAD IMAGE TO FIREBASE STORAGE
  Future<String> uploadFile(File file) async {

    UploadTask uploadTask;

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference ref = firebaseStorage.ref()
        .child("processed_images")
        .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

    uploadTask = ref.putFile(file);

    var downloadURL;
    await uploadTask.whenComplete(() async {
      try{
        downloadURL = await ref.getDownloadURL();
      }catch(onError){
        print("Error");
      }
    });

    return downloadURL.toString();
  }

  Future<Map> _init(BuildContext context) async {

    var arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String imagePath = arguments["filePath"];

    // CHECK INTERNET CONNECTIVITY
    Connectivity connectivity = Connectivity();
    ConnectivityResult connectivityResult = await connectivity.checkConnectivity();

    // IF THERE IS INTERNET CONNECTION
    // UPLOAD IMAGE TO FIREBASE STORAGE
    if(connectivityResult != ConnectivityResult.none) {

      // UPLOAD IMAGE TO FIREBASE STORAGE
      String fileURL = await uploadFile(File(imagePath));
      print(fileURL);

      // GET ML SERVER LINK FROM FIREBASE RTDB
      DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("server_url");
      var serverURLString;
      await dbRef.get().then((snapshot) => serverURLString = snapshot.value);
      var serverURL = Uri.parse(serverURLString);

      // SEND DOWNLOAD LINK TO ML SERVER
      // var body = {"imageURL": fileURL};
      var body = {'name': 'doodle', 'color': 'blue'};
      var response = await http.post(serverURL, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // RESPONSE CONTAINS THE LINK OF THE CLASSIFIED IMAGE
      // USE THE LINK TO DOWNLOAD THE IMAGE AND CHANGE TO THE NEXT ACTIVITY
    }
    else {
      // PREDICT USING LOCAL ML MODEL
      await loadModel();
      predictClass(imagePath);
    }

    await loadModel();
    LanguageInitializer languageInitializer = LanguageInitializer();
    AppStrings appStrings = await languageInitializer.initLanguage();

    return {"appStrings": appStrings, "imagePath": imagePath};
  }

  Widget _builderFunction(BuildContext context, AsyncSnapshot snapshot) {

    Widget child;

    if(snapshot.hasData) {
      AppStrings appStrings = snapshot.data["appStrings"];
      String imagePath = snapshot.data["imagePath"];

      predictClass(imagePath);

      child = Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.appBarColorLight,
          title: Text(appStrings.examineLeaf),
        ),
        body: Center(
          child: Text(
            "Predicting diseases...",
            style: TextStyle(
              fontSize: 17,
            ),
          ),
        ),
      );
    }
    else
      child = Scaffold(
        body: Center(
          child: Text(
            "Loading model..."
          ),
        ),
      );

    return child;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _init(context),
      builder: _builderFunction
    );
  }
}
