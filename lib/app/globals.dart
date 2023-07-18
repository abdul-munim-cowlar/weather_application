import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/db/database_helper.dart';
import 'package:weather_app/db/weather_application.dart';

SharedPreferences? sharedPrefsGlobal;

WeatherApplicationDB db = WeatherApplicationDB(DatabaseHelper.dbName);
