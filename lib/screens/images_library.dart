import 'dart:io';

import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/processed_image.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:crop_doctor/classes/stringsEN.dart';
import 'package:crop_doctor/classes/stringsHI.dart';
import 'package:flutter/material.dart';
import 'package:crop_doctor/classes/colors.dart';

import 'package:hive_flutter/hive_flutter.dart';

class ImagesLibrary extends StatefulWidget {
  @override
  _ImagesLibraryState createState() => _ImagesLibraryState();
}

class _ImagesLibraryState extends State<ImagesLibrary> {

  AppStrings? appStrings;
  Box<ProcessedImage>? processedImagesDatabase;

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

    processedImagesDatabase = Hive.box<ProcessedImage>("processedImages");

    AppStrings appStrings = await languageInitializer.initLanguage();

    return {"appStrings": appStrings};
  }

  Widget _buildFunction(BuildContext context, AsyncSnapshot snapshot) {

    Widget child;

    if(snapshot.hasData) {

      appStrings = snapshot.data["appStrings"];

      child = Scaffold(

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if(appStrings!.languageID == "EN") {
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17
            ),
          ),
          backgroundColor: AppColor.themeColorLight,
        ),

        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(appStrings!.imageLibrary),
          backgroundColor: AppColor.appBarColorLight,
        ),
        body: ValueListenableBuilder(
          valueListenable: processedImagesDatabase!.listenable(),
          builder: (BuildContext context, value, Widget? child) {

            List<int> imagesList = processedImagesDatabase!.keys.cast<int>().toList();
            return ListView.separated(
                itemBuilder: (context, index) {

                  int key = imagesList[index];
                  ProcessedImage? processedImage = processedImagesDatabase!.get(key);
                  Image loadedImage = Image.file(File(processedImage!.imagePath));

                  return InkWell(
                    onTap: () {},
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          child: loadedImage,
                        )
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: imagesList.length);
          },
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
      builder: _buildFunction
    );
  }
}
