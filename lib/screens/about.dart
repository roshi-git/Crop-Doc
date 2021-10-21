import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:crop_doctor/classes/stringsEN.dart';
import 'package:crop_doctor/classes/stringsHI.dart';
import 'package:flutter/material.dart';
import 'package:crop_doctor/classes/colors.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {

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

  Widget _builderFunction(BuildContext buildContext, AsyncSnapshot snapshot) {

    Widget child;

    if(snapshot.hasData) {

      appStrings = snapshot.data;

      child = Scaffold(
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
              Navigator.pop(context);
            },
          ),
          title: Text(appStrings!.about),
          backgroundColor: AppColor.appBarColorLight,
        ),
      );
    }
    else
      child = Scaffold(
        body: Center(
          child: Text("Loading.."),
        ),
      );
    
    return child;
  }
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: languageInitializer.initLanguage(),
      builder: _builderFunction
    );
  }
}