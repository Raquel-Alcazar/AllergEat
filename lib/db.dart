import 'dart:convert';
import 'dart:async';

import 'package:allergeat/modelos/favorite_product.dart';
import 'package:flutter/widgets.dart';
import 'package:allergeat/modelos/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static Future<Database> _openDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    return openDatabase(join(await getDatabasesPath(), 'data.db'),
        onCreate: (db, version) {
      final batch = db.batch();
      batch.execute(
          "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, surname TEXT, email TEXT UNIQUE, password TEXT, allergies BLOB)");
      batch.execute(
          "CREATE TABLE favorite_products (user_id INTEGER NOT NULL, product_barcode TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES users(id), CONSTRAINT UC_Favorite_Products UNIQUE(user_id, product_barcode))");
      batch.commit();
    }, version: 1);
  }

  static Future<void> insertUser(User user) async {
    final database = await _openDB();

    final userMap = user.toMap();
    userMap.remove("id");
    userMap['allergies'] = JsonEncoder().convert(userMap['allergies']);

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
    userMap.remove("allergies");

    await database
        .update("users", userMap, where: "id = ?", whereArgs: [user.id]);
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
          password: usersMap[0]['password'],
          allergies: List<String>.from(JsonDecoder().convert(usersMap[0]['allergies'])));
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

  static Future<void> updateAllergies(User user, List<String> allergies) async {
    final database = await _openDB();

    final String jsonAllergies = JsonEncoder().convert(allergies);

    var changed = await database.update("users", {"allergies": jsonAllergies},
        where: 'id = ?', whereArgs: [user.id]);

    if (changed > 0) {
      user.allergies = allergies;
    }
  }
}
