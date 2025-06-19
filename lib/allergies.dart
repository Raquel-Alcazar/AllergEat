class Allergies {
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
    'Lupinus': 'en:lupinus',
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
}