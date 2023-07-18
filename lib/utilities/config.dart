
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../app/shared_prefs_const.dart';
import '../app/globals.dart';

Configs config = Configs.getInstanceSync();

class Configs {
  static Configs? _instance;

  static final validEnv = ['dev', 'stage', 'pre-prod', 'prod'];
  static String _appEnv = "";

  static String _validateEnv(String name) {
    String env = dotenv.get(name, fallback: 'dev');
    if (validEnv.contains(env)) return env;
    throw Exception(
      'ERROR: Invalid value $env for APP_ENV in the config. Valid value is one of: "${validEnv.join(" or ")}"',
    );
  }

  static Future<Configs> getInstance({bool isTesting = false}) async {
    if (_instance == null) {
      await dotenv.load();
      _appEnv = _validateEnv('APP_ENV');

      String storedAppENV =
          sharedPrefsGlobal!.getString(SharedPrefConsts.previousEnvironment) ??
              "";
      if (_appEnv != storedAppENV) {
        sharedPrefsGlobal!.remove(SharedPrefConsts.refreshTokenKey);
        sharedPrefsGlobal!.remove(SharedPrefConsts.sendingOTPNumberKey);
        sharedPrefsGlobal!.remove(SharedPrefConsts.accessTokenKey);
        sharedPrefsGlobal!.remove(SharedPrefConsts.refreshTokenKey);
        sharedPrefsGlobal!.remove(SharedPrefConsts.phoneNumKey);
        sharedPrefsGlobal!.remove(SharedPrefConsts.userStatisticsKey);
        sharedPrefsGlobal!.remove(SharedPrefConsts.invitedUsersLocalKey);
        sharedPrefsGlobal!.remove(SharedPrefConsts.userClubsDataKey);
        sharedPrefsGlobal!.remove(SharedPrefConsts.userInformationKey);
      }
      sharedPrefsGlobal!.setString(
        SharedPrefConsts.previousEnvironment,
        _appEnv,
      );

      _instance = Configs._internal();
    }
    return _instance!;
  }

  String getEnv(String name, {String fallback = ""}) {
    return dotenv.get(
      "${_appEnv.toUpperCase().replaceAll('-', '_')}_$name",
      fallback: fallback,
    );
  }

  bool getEnvBool(String name, bool? fallback) {
    return getEnv(name, fallback: fallback.toString()) == "true" ? true : false;
  }

  int getEnvInt(String name, int fallback) {
    return int.parse(
      getEnv(
        name,
        fallback: fallback.toString(),
      ),
    );
  }

  static Configs getInstanceSync() {
    if (_instance == null) throw Exception("ERROR: Configs not initialized");
    return _instance!;
  }

  Configs._internal();

  //mqtt
  String get _mqttHost => getEnv("MQTT_HOST");
  String get mqttHost =>
      (mqttWebsockets
          ? mqttSSL
              ? "wss://"
              : "ws://"
          : "") +
      _mqttHost;

  String get mqttUsername => getEnv(
        "MQTT_USERNAME",
      );
  String get mqttPassword => getEnv(
        "MQTT_PASSWORD",
      );
  bool get mqttSSL => getEnvBool("MQTT_SSL", true);
  bool get mqttWebsockets => getEnvBool("MQTT_WEBSOCKETS", false);
  int get mqttPort => getEnvInt("MQTT_PORT", 8883);
  String get flutterAccessToken => getEnv(
        "FLUTTER_MAP_ACCESS_TOKEN",
      );

  // API
  String get baseUrl => getEnv("BASE_URL");
}
