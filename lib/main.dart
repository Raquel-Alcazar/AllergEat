import 'package:allergeat/busqueda_productos.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:allergeat/db.dart';
import 'package:allergeat/user.dart' as u;
import 'pantalla_registro.dart';
import 'bienvenida.dart';

void main() {
  OpenFoodAPIConfiguration.userAgent =
      UserAgent(name: 'mi_app', url: 'https://miapp.com');
  OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
    OpenFoodFactsLanguage.SPANISH,
  ];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.SPAIN;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenFoodFacts Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 236, 248, 255),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFFFC1CC),
          secondary: Color(0xFFFFD6DD),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFFC1CC),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
      home: Bienvenida(),
    );
  }
}