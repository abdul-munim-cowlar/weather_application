import 'package:shared_preferences/shared_preferences.dart';

import '../app/globals.dart';

class SharedPreferencesGlobal {
  static initInstance() async {
    if (sharedPrefsGlobal == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      sharedPrefsGlobal = prefs;
    }
  }
}
