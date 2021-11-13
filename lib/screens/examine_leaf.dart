import 'package:crop_doctor/classes/colors.dart';
import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/processed_image.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ExamineLeaf extends StatefulWidget {
  @override
  _ExamineLeafState createState() => _ExamineLeafState();
}

class _ExamineLeafState extends State<ExamineLeaf> {

  String? languageID;
  String currentTask = "Processing image";

  AppStrings? appStrings;

  LanguageInitializer languageInitializer = LanguageInitializer();

  Widget _builderFunction(BuildContext context, AsyncSnapshot snapshot) {

    Widget child;

    if(snapshot.hasData) {
      appStrings = snapshot.data;

      child = Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.appBarColorLight,
          title: Text(appStrings!.examineLeaf),
        ),
        body: Center(
          child: Text(
            currentTask,
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
          "Loading.."
        ),
      );

    return child;
  }

  @override
  Widget build(BuildContext context) {

    var arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String filePath = arguments["filePath"];
    String diseaseID = "disease 01";

    Future.delayed(Duration(seconds: 3), () {

      Box<ProcessedImage> processedImagesDatabase = Hive.box<ProcessedImage>("processedImages");
      processedImagesDatabase.add(ProcessedImage(
          imagePath: filePath,
          diseaseID: diseaseID,
          epochSeconds: DateTime.now().millisecondsSinceEpoch
      ));

      var arguments = {
        "filePath": filePath,
        "diseaseID": diseaseID,
      };

      Navigator.pushReplacementNamed(context, "/image_details", arguments: arguments);
    });

    return FutureBuilder(
      future: languageInitializer.initLanguage(),
      builder: _builderFunction
    );
  }
}
