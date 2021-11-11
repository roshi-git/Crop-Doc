import 'package:crop_doctor/classes/colors.dart';
import 'package:crop_doctor/classes/disease_info.dart';
import 'package:crop_doctor/classes/language_init.dart';
import 'package:crop_doctor/classes/strings.dart';
import 'package:crop_doctor/classes/stringsEN.dart';
import 'package:crop_doctor/classes/stringsHI.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DiseaseDescription extends StatefulWidget {
  const DiseaseDescription({Key? key}) : super(key: key);

  @override
  _DiseaseDescriptionState createState() => _DiseaseDescriptionState();
}

class _DiseaseDescriptionState extends State<DiseaseDescription> {

  AppStrings? appStrings;

  //TODO: DO THIS
  /*StreamSubscription dbStream = dbRef.onValue.listen((event) {
      var val = event.snapshot.value;
      var key = event.snapshot.key;
      print(val);
      print(key);
    });
    dbStream.resume();
    dbStream.cancel();*/

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

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    String diseaseID = args["diseaseID"];

    await Firebase.initializeApp();

    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("diseasesList").child(diseaseID);

    // GET DISEASE DESCRIPTION AND STUFF FROM FIREBASE RTDB
    var values;
    await dbRef.get().then((snapshot) => values = snapshot.value);

    String diseaseNameEN = values["diseaseNameEN"];
    String diseaseNameHI = values["diseaseNameHI"];
    String descriptionEN = values["descriptionEN"];
    String descriptionHI = values["descriptionHI"];
    String imageLink = values["imageLink"];

    DiseaseInfo diseaseInfo = DiseaseInfo(
      diseaseID: diseaseID,
      diseaseNameEN: diseaseNameEN,
      diseaseNameHI: diseaseNameHI,
      diseaseDescriptionEN: descriptionEN,
      diseaseDescriptionHI: descriptionHI,
      diseaseImagePath: imageLink
    );

    print("Disease info fetched");

    // INIT SCREEN LANGUAGE
    AppStrings appStrings = await languageInitializer.initLanguage();

    return {"appStrings": appStrings, "diseaseInfo": diseaseInfo};
  }

  Widget _buildFunction(BuildContext buildContext, AsyncSnapshot snapshot) {

    Widget child;

    if (snapshot.hasData) {

      appStrings = snapshot.data["appStrings"];
      DiseaseInfo _diseaseInfo = snapshot.data["diseaseInfo"];

      String languageID = appStrings!.languageID;
      String diseaseName;
      String plantName;
      String diseaseDescription;

      if(languageID == "EN") {
        diseaseName = _diseaseInfo.diseaseNameEN;
        diseaseDescription = _diseaseInfo.diseaseDescriptionEN;
        plantName = "";
      }
      else {
        diseaseName = _diseaseInfo.diseaseNameHI;
        diseaseDescription = _diseaseInfo.diseaseDescriptionHI;
        plantName = "";
      }

      child = Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (appStrings!.languageID == "EN") {
              languageInitializer.setLanguage("HI");
              setLanguage("HI");
              setState(() {
                diseaseName = _diseaseInfo.diseaseNameHI;
                diseaseDescription = _diseaseInfo.diseaseDescriptionHI;
                plantName = "";
              });
            }
            else {
              languageInitializer.setLanguage("EN");
              setLanguage("EN");
              setState(() {
                diseaseName = _diseaseInfo.diseaseNameEN;
                diseaseDescription = _diseaseInfo.diseaseDescriptionEN;
                plantName = "";
              });
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: FadeInImage(
                placeholder: AssetImage("assets/placeholder_image.png"),
                image: NetworkImage(_diseaseInfo.diseaseImagePath),
                fit: BoxFit.fitWidth,
              ),
            ),

            // DISEASE NAME
            Padding(
              padding: const EdgeInsets.all(6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  diseaseName,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),

            // DISEASE DESCRIPTION
            Padding(
              padding: const EdgeInsets.all(6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  diseaseDescription,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
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
