import 'package:crop_doctor/classes/colors.dart';
import 'package:crop_doctor/classes/disease_info.dart';
import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:crop_doctor/classes/stringsEN.dart';
import 'package:crop_doctor/classes/stringsHI.dart';
import 'package:crop_doctor/screens/disease_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PlantDiseases extends StatefulWidget {
  const PlantDiseases({Key? key}) : super(key: key);

  @override
  _PlantDiseasesState createState() => _PlantDiseasesState();
}

class _PlantDiseasesState extends State<PlantDiseases> {

  List<DiseaseInfo> diseaseList = [];

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

  Future<AppStrings> _init(BuildContext context) async {

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    String plantID = args["plantID"];

    await Firebase.initializeApp();

    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("diseasesGroups").child(plantID);

    //TODO: DO THIS
    /*StreamSubscription dbStream = dbRef.onValue.listen((event) {
      var val = event.snapshot.value;
      var key = event.snapshot.key;
      print(val);
      print(key);
    });
    dbStream.resume();
    dbStream.cancel();*/

    // GET DISEASES NAMES AND STUFF FROM FIREBASE RTDB
    var values;
    await dbRef.get().then((snapshot) => values = snapshot.value);

    List<DiseaseInfo> _diseasesList = [];

    for(String disease in values.keys) {
      _diseasesList.add(
        DiseaseInfo(
          diseaseID: disease,
          diseaseNameEN: values[disease]["diseaseNameEN"],
          diseaseNameHI: values[disease]["diseaseNameHI"],
          diseaseDescriptionEN: "",
          diseaseDescriptionHI: "",
          diseaseImagePath: values[disease]["imageLink"]
        )
      );
    }

    // SORT DISEASES ALPHABETICALLY
    _diseasesList.sort((a, b) => a.diseaseNameEN.compareTo(b.diseaseNameEN));
    diseaseList = _diseasesList;

    print("Diseases list fetched");

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
              itemCount: diseaseList.length,
              itemBuilder: (context, index) {
                return DiseaseCard(diseaseList[index], appStrings!.languageID);
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
        future: _init(context),
        builder: _buildFunction
    );
  }
}
