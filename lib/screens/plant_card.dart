import 'package:crop_doctor/classes/plant.dart';
import 'package:flutter/material.dart';

class PlantCard extends StatelessWidget {

  final Plant plantInfo;
  final String languageID;

  PlantCard(this.plantInfo, this.languageID);

  @override
  Widget build(BuildContext context) {

    String plantName;
    String plantType;

    if(languageID == "EN") {
      plantName = plantInfo.plantNameEN;
      plantType = plantInfo.plantTypeEN;
    }
    else {
      plantName = plantInfo.plantNameHI;
      plantType = plantInfo.plantTypeHI;
    }

    return InkWell(
      onTap: () {},
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: NetworkImage(plantInfo.plantImagePath),
                  )
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  plantName,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  plantType,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
