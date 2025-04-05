import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:allergeat/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {

  static Future<Database> _openDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    return openDatabase(join(await getDatabasesPath(), 'data.db'),
    onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, surname TEXT, email TEXT, password TEXT)"
        );
    }, version: 1);
  }

  static Future<void> insertUser(User user) async {
    final database = await _openDB();

    await database.insert("users", user.toMap());
  }

  static Future<void> deleteUser(User user) async {
    final database = await _openDB();

    await database.delete("users", where: "id = ?", whereArgs: [user.id]);
  }

  static Future<void> updateUser(User user) async {
    final database = await _openDB();

    await database.update("users", user.toMap(), where: "id = ?", whereArgs: [user.id]);
  }

  static Future<List<User>> users() async {
    final database = await _openDB();
    final List<Map<String, dynamic>> usersMap = await database.query("users");

    return List.generate(usersMap.length,
            (i) => User (
              id: usersMap[i]['id'],
              name: usersMap[i]['nombre'],
              surname: usersMap[i]['apellidos'],
              email: usersMap[i]['email'],
              password: usersMap[i]['contrasena']
            ));
  }
}