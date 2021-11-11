import "package:hive/hive.dart";
part "processed_image.g.dart";

@HiveType(typeId: 0)
class ProcessedImage {

  @HiveField(0)
  String imagePath;

  @HiveField(1)
  String diseaseID;

  ProcessedImage({
    required this.imagePath,
    required this.diseaseID
  });
}