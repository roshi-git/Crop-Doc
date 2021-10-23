import 'package:crop_doctor/classes/disease_info.dart';
import 'package:flutter/material.dart';

class DiseaseCard extends StatelessWidget {

  final DiseaseInfo diseaseInfo;
  final String languageID;

  DiseaseCard(this.diseaseInfo, this.languageID);

  @override
  Widget build(BuildContext context) {

    String diseaseName;

    if(languageID == "EN") {
      diseaseName = diseaseInfo.diseaseNameEN;
    }
    else {
      diseaseName = diseaseInfo.diseaseNameHI;
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
            "/disease_description",
            arguments: {
            "diseaseID": diseaseInfo.diseaseID
          }
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Padding(
              padding: const EdgeInsets.all(6),
              child: FadeInImage(
                height: 100,
                width: double.infinity,
                placeholder: AssetImage("assets/placeholder_image.png"),
                image: AssetImage("assets/placeholder_image.png"),
                //NetworkImage(diseaseInfo.diseaseImagePath),
                fit: BoxFit.fitWidth,
              ),
            ),

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
          ],
        ),
      ),
    );
  }
}
