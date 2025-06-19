import 'package:openfoodfacts/openfoodfacts.dart';

class Allergies {
  static const Map<String, AllergensTag> _allergensTag = {
    'en:gluten': AllergensTag.GLUTEN,
    'en:milk': AllergensTag.MILK,
    'en:eggs': AllergensTag.EGGS,
    'en:nuts': AllergensTag.NUTS,
    'en:peanuts': AllergensTag.PEANUTS,
    'en:sesame-seeds': AllergensTag.SESAME_SEEDS,
    'en:soybeans': AllergensTag.SOYBEANS,
    'en:celery': AllergensTag.CELERY,
    'en:mustard': AllergensTag.MUSTARD,
    'en:lupin': AllergensTag.LUPIN,
    'en:fish': AllergensTag.FISH,
    'en:crustaceans': AllergensTag.CRUSTACEANS,
    'en:molluscs': AllergensTag.MOLLUSCS,
    'en:sulphur-dioxide-and-sulphites': AllergensTag.SULPHUR_DIOXIDE_AND_SULPHITES
  };

  static const Map<String, String> allergies = {
    'Gluten': 'en:gluten',
    'Lácteos': 'en:milk',
    'Huevos': 'en:eggs',
    'Frutos secos': 'en:nuts',
    'Cacahuetes': 'en:peanuts',
    'Sésamo': 'en:sesame-seeds',
    'Soja': 'en:soybeans',
    'Apio': 'en:celery',
    'Mostaza': 'en:mustard',
    'Lupinus': 'en:lupin',
    'Pescado': 'en:fish',
    'Crustáceos': 'en:crustaceans',
    'Moluscos': 'en:molluscs',
    'Sulfitos': 'en:sulphur-dioxide-and-sulphites',
  };

  static String toSpanish(String code) {
    return allergies.keys.firstWhere((key) => allergies[key] == code, orElse: () => code);
  }

  static String toCode(String allergy) {
    return allergies[allergy] ?? allergy;
  }

  static AllergensTag? toAllergensTag(String code) {
    return _allergensTag[code];
  }
}