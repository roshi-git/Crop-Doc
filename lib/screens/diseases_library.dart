import 'dart:async';

import 'package:crop_doctor/classes/plant.dart';
import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:crop_doctor/classes/stringsEN.dart';
import 'package:crop_doctor/classes/stringsHI.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:crop_doctor/classes/colors.dart';

import 'plant_card.dart';

class DiseasesLibrary extends StatefulWidget {
  @override
  _DiseasesLibraryState createState() => _DiseasesLibraryState();
}

class _DiseasesLibraryState extends State<DiseasesLibrary> {

  List<Plant> plantsList = [];

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

  Future<AppStrings> _init() async {

    await Firebase.initializeApp();

    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("plantsList");

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

    List<Plant> _plantsList = [];

    for(String plant in values.keys) {
      _plantsList.add(
        Plant(
          plantNameEN: values[plant]["plantNameEN"],
          plantNameHI: values[plant]["plantNameHI"],
          plantTypeEN: values[plant]["plantTypeEN"],
          plantTypeHI: values[plant]["plantTypeHI"],
          plantImagePath: values[plant]["imageLink"]
        )
      );
    }

    // SORT PLANTS ALPHABETICALLY
    _plantsList.sort((a, b) => a.plantNameEN.compareTo(b.plantNameEN));
    plantsList = _plantsList;

    print("Plants list fetched");

    // INIT SCREEN LANGUAGE
    AppStrings appStrings = await languageInitializer.initLanguage();

    return appStrings;
  }

  Widget _buildFunction(BuildContext buildContext, AsyncSnapshot snapshot) {

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
          title: Text(appStrings!.diseasesLibrary),
          backgroundColor: AppColor.appBarColorLight,
        ),
        body: Center(
          child: ListView.builder(
            itemCount: plantsList.length,
            itemBuilder: (context, index) {
            return PlantCard(plantsList[index]);
          }),
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
      future: _init(),
      builder: _buildFunction
    );
  }
}
