import 'package:crop_doctor/classes/strings.dart';
import 'package:crop_doctor/classes/stringsEN.dart';
import 'package:crop_doctor/classes/stringsHI.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageInitializer {

  String? languageID;
  AppStrings? appStrings;
  var prefs;

  void setLanguage(String languageID) {
    prefs.setString("languageID", languageID);
  }

  Future<AppStrings> initLanguage() async {

    prefs = await SharedPreferences.getInstance();
    languageID = await prefs.getString("languageID") ?? "EN";
    await prefs.setString("languageID", languageID);

    if(languageID == "EN")
      appStrings = AppStringsEN();
    else
      appStrings = AppStringsHI();

    print(languageID);

    return appStrings!;
  }
}