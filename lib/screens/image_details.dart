import 'dart:io';

import 'package:crop_doctor/classes/colors.dart';
import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/processed_image.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:crop_doctor/classes/stringsEN.dart';
import 'package:crop_doctor/classes/stringsHI.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ImageDetails extends StatefulWidget {
  @override
  _ImageDetailsState createState() => _ImageDetailsState();
}

class _ImageDetailsState extends State<ImageDetails> {

  Image? loadedImage;
  AppStrings? appStrings;

  void setLanguage(String languageID) {

    setState(() {
      if(languageID == "EN")
        appStrings = AppStringsEN();
      else
        appStrings = AppStringsHI();
    });
  }

  LanguageInitializer languageInitializer = LanguageInitializer();

  Future<Map> _init(BuildContext context) async {

    var arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String filePath = arguments["filePath"];
    String diseaseID = arguments["diseaseID"];
    loadedImage = Image.file(File(filePath));

    Box<ProcessedImage> processedImagesDatabase = Hive.box<ProcessedImage>("processedImages");
    processedImagesDatabase.add(ProcessedImage(
        imagePath: filePath,
        diseaseID: diseaseID
    ));

    AppStrings appStrings = await languageInitializer.initLanguage();

    return {"appStrings": appStrings};
  }

  Widget _builderFunction(BuildContext context, AsyncSnapshot snapshot) {

    Widget child;
    double fontSize = 18;

    if(snapshot.hasData) {

      appStrings = snapshot.data["appStrings"];

      child = Scaffold(

        // CHANGE LANGUAGE BUTTON
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (appStrings!.languageID == "EN") {
              languageInitializer.setLanguage("HI");
              setLanguage("HI");
            }
            else {
              languageInitializer.setLanguage("EN");
              setLanguage("EN");
            }
          },
          label: Text(
            appStrings!.otherLanguage,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          backgroundColor: AppColor.themeColorLight,
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
          ),
          backgroundColor: AppColor.appBarColorLight,
          title: Text(appStrings!.leafInfo),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              Container(
                child: loadedImage,
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "Disease Name:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize
                    ),
                  ),

                  SizedBox(width: 10),

                  Text(
                    "<disease name>",
                    style: TextStyle(
                      fontSize: fontSize
                    ),
                  )
                ],
              ),

              SizedBox(height: 20),

              Text(
                "Disease description -",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize
                ),
              ),

              SizedBox(height: 10),

              Text(
                "<disease description>",
                style: TextStyle(
                  fontSize: fontSize
                ),
              )
            ]
          ),
        ),
      );
    }
    else
      child = Scaffold(
        body: Center(
          child: Text(
            "Loading.."
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
