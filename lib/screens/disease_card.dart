import 'dart:io';

import 'package:crop_doctor/classes/disease.dart';
import 'package:flutter/material.dart';

class DiseaseCard extends StatelessWidget {

  final Disease disease;
  final String languageID;
  final String imagePath;

  DiseaseCard(this.disease, this.languageID, this.imagePath);

  @override
  Widget build(BuildContext context) {

    String diseaseName;

    if(languageID == "EN") {
      diseaseName = disease.diseaseNameEN;
    }
    else {
      diseaseName = disease.diseaseNameHI;
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
            "/disease_description",
            arguments: {
            "diseaseID": disease.diseaseID
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
                height: 200,
                width: double.infinity,
                placeholder: AssetImage("assets/placeholder_image.png"),
                image: FileImage(
                  File(imagePath)
                ),
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
