import 'package:crop_doctor/classes/colors.dart';
import 'package:crop_doctor/classes/disease_id_map.dart';
import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/processed_image.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tflite/tflite.dart';

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

  Future<Map> _init(BuildContext context) async {

    var arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String imagePath = arguments["filePath"];

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
      child = Center(
        child: Text(
          "Loading model..."
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
