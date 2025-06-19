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
      final batch = db.batch();
      batch.execute(
          "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, surname TEXT, email TEXT UNIQUE, password TEXT)");
      batch.execute(
          "CREATE TABLE favorite_products (user_id INTEGER NOT NULL, product_barcode TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES users(id), CONSTRAINT UC_Favorite_Products UNIQUE(user_id, product_barcode))");
      batch.execute(
          "CREATE TABLE allergies (user_id INTEGER NOT NULL, name TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES users(id), CONSTRAINT UC_Allergies UNIQUE(user_id, name))");
      batch.commit();
    }, version: 1);
  }

  static Future<void> insertUser(User user) async {
    final database = await _openDB();

    final userMap = user.toMap();
    userMap.remove("id");

    var changed = await database.insert("users", userMap);
    if (changed > 0) {
      user.id = (await userByEmail(user.email))!.id;
    }
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

    await database
        .update("users", userMap, where: "id = ?", whereArgs: [user.id]);
  }

  static Future<List<User>> users() async {
    final database = await _openDB();
    final List<Map<String, dynamic>> usersMap = await database.query("users");

    return List.generate(
        usersMap.length,
        (i) => User(
            id: usersMap[i]['id'],
            name: usersMap[i]['name'],
            surname: usersMap[i]['surname'],
            email: usersMap[i]['email'],
            password: usersMap[i]['password']));
  }

  static Future<User?> userByEmail(String email) async {
    final database = await _openDB();
    List<Map> usersMap = await database.query('users',
        where: 'email = ?', whereArgs: [email], limit: 1);

    if (usersMap.isEmpty) {
      return null;
    } else {
      return User(
          id: usersMap[0]['id'],
          name: usersMap[0]['name'],
          surname: usersMap[0]['surname'],
          email: usersMap[0]['email'],
          password: usersMap[0]['password']);
    }
  }

  static Future<void> insertProductoFavorito(
      FavoriteProduct favoriteProduct) async {
    final database = await _openDB();

    final productMap = favoriteProduct.toMap();
    productMap.remove("id");

    var changed = await database.insert("favorite_products", productMap);
    if (changed > 0) {
      favoriteProduct.id = (await favoriteProductByUserIdAndProductBarcode(
              favoriteProduct.userId, favoriteProduct.productBarcode))!
          .id;
    }
  }

  static Future<void> deleteProductoFavorito(
      FavoriteProduct favoriteProduct) async {
    final database = await _openDB();

    // await database.delete("favorite_products", where: "user_id = ? AND product_barcode = ?", whereArgs: [favoriteProduct.userId, favoriteProduct.productBarcode]);

    await database.delete("favorite_products",
        where: "rowid = ?", whereArgs: [favoriteProduct.id]);
  }

  static Future<List<FavoriteProduct>> favoriteProductsbyUserId(
      int userId) async {
    final database = await _openDB();
    final List<Map> favoriteProducts = await database.query("favorite_products",
        columns: ['rowid', 'user_id', 'product_barcode'],
        where: "user_id = ?",
        whereArgs: [userId]);

    return List.generate(
        favoriteProducts.length,
        (i) => FavoriteProduct(
              id: favoriteProducts[i]['rowid'],
              userId: favoriteProducts[i]['user_id'],
              productBarcode: favoriteProducts[i]['product_barcode'],
            ));
  }

  static Future<FavoriteProduct?> favoriteProductByUserIdAndProductBarcode(
      int userId, String productBarcode) async {
    final database = await _openDB();
    final List<Map> favoriteProducts = await database.query("favorite_products",
        columns: ['rowid', 'user_id', 'product_barcode'],
        where: "user_id = ? AND product_barcode = ?",
        whereArgs: [userId, productBarcode],
        limit: 1);

    if (favoriteProducts.isEmpty) {
      return null;
    } else {
      return FavoriteProduct(
        id: favoriteProducts.first['rowid'],
        userId: favoriteProducts.first['user_id'],
        productBarcode: favoriteProducts.first['product_barcode'],
      );
    }
  }
}
