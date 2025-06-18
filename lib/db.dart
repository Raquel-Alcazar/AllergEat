import 'dart:async';

import 'package:allergeat/favorite_product.dart';
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
          "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, surname TEXT, email TEXT UNIQUE, password TEXT);"
          "CREATE TABLE favorite_products (FOREIGN KEY(user_id) REFERENCES users(id) NOT NULL, product_id INTEGER NOT NULL);"
          "CREATE TABLE allergies (FOREIGN KEY(user_id) REFERENCES users(id) NOT NULL, name TEXT"
        );
    }, version: 1);
  }

  static Future<void> insertUser(User user) async {
    final database = await _openDB();

    final userMap = user.toMap();
    userMap.remove("id");

    await database.insert("users", userMap);
  }

  static Future<void> deleteUser(User user) async {
    final database = await _openDB();

    await database.delete("users", where: "id = ?", whereArgs: [user.id]);
  }

  static Future<void> updateUser(User user) async {
    final database = await _openDB();

    final userMap = user.toMap();
    userMap.remove("id");
    userMap.remove("email");

    await database.update("users", userMap, where: "id = ?", whereArgs: [user.id]);
  }

  static Future<List<User>> users() async {
    final database = await _openDB();
    final List<Map<String, dynamic>> usersMap = await database.query("users");
  
    return List.generate(usersMap.length,
            (i) => User (
              id: usersMap[i]['id'],
              name: usersMap[i]['name'],
              surname: usersMap[i]['surname'],
              email: usersMap[i]['email'],
              password: usersMap[i]['password']
            ));
  }

  static Future<User?> userByEmail(String email) async {
    final database = await _openDB();
    List<Map> usersMap = await database.query(
      'users',
      where: 'email = ?', 
      whereArgs: [email], 
      limit: 1
    );
    
    if (usersMap.isEmpty) {
      return null;
    } else {
      return User(
        id: usersMap[0]['id'],
        name: usersMap[0]['name'],
        surname: usersMap[0]['surname'],
        email: usersMap[0]['email'],
        password: usersMap[0]['password']
      );
    }
  }

    static Future<void> insertProductoFavorito(FavoriteProduct favoriteProduct) async {
    final database = await _openDB();

    await database.insert("favorite_products", favoriteProduct.toMap());
  }

    static Future<void> deleteProductoFavorito(FavoriteProduct favoriteProduct) async {
    final database = await _openDB();

    await database.delete("favorite_products", where: "userId = ? AND productId = ?", whereArgs: [favoriteProduct.userId, favoriteProduct.productId]);
  }

    static Future<List<FavoriteProduct>> favoriteProducts () async {
    final database = await _openDB();
    final List<Map<String, dynamic>> favoriteProducts = await database.query("favorite_products");
  
    return List.generate(favoriteProducts.length,
            (i) => FavoriteProduct (
              userId: favoriteProducts[i]['userId'],
              productId: favoriteProducts[i]['productId'],
            ));
  }

}