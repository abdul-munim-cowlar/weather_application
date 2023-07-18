import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class WeatherApplicationDB {
  final String dbName;
  Database? _db;

  WeatherApplicationDB(this.dbName);

  Future<bool> open({bool isFake = false}) async {
    if (_db != null) {
      return true;
    }

    Directory directory;
    String path = "";

    directory = await getApplicationDocumentsDirectory();
    path = '${directory.path}/$dbName';

    try {
      final db = await openDatabase(path);
      _db = db;
      log("--- Database Opened Successfully!");
      return true;
    } catch (e) {
      return false;
    }
  }
}
