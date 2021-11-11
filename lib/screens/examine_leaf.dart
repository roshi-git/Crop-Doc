import 'package:crop_doctor/classes/colors.dart';
import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:flutter/material.dart';

class ExamineLeaf extends StatefulWidget {
  @override
  _ExamineLeafState createState() => _ExamineLeafState();
}

class _ExamineLeafState extends State<ExamineLeaf> {

  String? languageID;
  String currentTask = "Processing image";

/*

  Future<bool> examineLeaf() async {

    if(!(await detectLeaf()))
      return Future.value(false);
    if(!(await detectDiseases()))
      return Future.value(false);
    if(!(await markAreas()))
      return Future.value(false);

    return Future.value(true);
  }

  Future<bool> detectLeaf() async {

    print("Detecting leaves");

    Future.delayed(Duration(seconds: 3), () {
      print("Leaves detected");
    });

    return true;
  }

  Future<bool> detectDiseases() async {

    print("Detecting diseases");

    */
/*setState(() {
      currentTask = detectingDiseases!;
    });*/
/*
    Future.delayed(Duration(seconds: 3), () {
      print("Diseases detected");
    });

    return true;
  }

  Future<bool> markAreas() async {

    print("Marking spots");

    */
/*
setState(() {
      currentTask = markingAffectedAreas!;
    });*/
/*
    Future.delayed(Duration(seconds: 3), () {
      print("Spots marked");
    });

    return true;
  }
*/

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
    String diseaseID = "0";

    Future.delayed(Duration(seconds: 3), () {
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
