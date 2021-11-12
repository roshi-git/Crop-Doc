import "package:hive/hive.dart";
part "disease.g.dart";

@HiveType(typeId: 2)
class Disease {

  @HiveField(0)
  String diseaseID;

  @HiveField(1)
  String diseaseNameEN;
  @HiveField(2)
  String diseaseNameHI;

  Disease({
    required this.diseaseID,

    required this.diseaseNameEN,
    required this.diseaseNameHI,
  });
}