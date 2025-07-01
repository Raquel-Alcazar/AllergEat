import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'vistas/bienvenida.dart';

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
        scaffoldBackgroundColor: Color.fromRGBO(236, 248, 255, 1),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF036280),
          secondary: Color(0xFFFFD6DD),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF378BA4),
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