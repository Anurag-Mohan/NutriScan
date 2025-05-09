class Product {
  final String barcode;
  final String? name;
  final String? brands;
  final String? imageUrl;
  final String? ingredients;
  final String? allergens;
  final String? nutriScore;
  
  // Nutrition values
  final double? energy;
  final double? energyPercent;
  final double? fat;
  final double? fatPercent;
  final double? saturatedFat;
  final double? saturatedFatPercent;
  final double? carbohydrates;
  final double? carbohydratesPercent;
  final double? sugars;
  final double? sugarsPercent;
  final double? fiber;
  final double? fiberPercent;
  final double? proteins;
  final double? proteinsPercent;
  final double? salt;
  final double? saltPercent;
  
  // Additional nutritional info
  final Map<String, dynamic>? additionalNutrition;
  final List<String>? additives;
  final List<String>? labels;

  Product({
    required this.barcode,
    this.name,
    this.brands,
    this.imageUrl,
    this.ingredients,
    this.allergens,
    this.nutriScore,
    this.energy,
    this.energyPercent,
    this.fat,
    this.fatPercent,
    this.saturatedFat,
    this.saturatedFatPercent,
    this.carbohydrates,
    this.carbohydratesPercent,
    this.sugars,
    this.sugarsPercent,
    this.fiber,
    this.fiberPercent,
    this.proteins,
    this.proteinsPercent,
    this.salt,
    this.saltPercent,
    this.additionalNutrition,
    this.additives,
    this.labels,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};

    final nutriments = product['nutriments'] ?? {};

    List<String> extractedAdditives = [];
    if (product['additives_tags'] != null) {
      extractedAdditives = List<String>.from(
        product['additives_tags'].map((tag) => tag.toString().replaceAll('en:', '')),
      );
    }

    List<String> extractedLabels = [];
    if (product['labels_tags'] != null) {
      extractedLabels = List<String>.from(
        product['labels_tags'].map((tag) => tag.toString().replaceAll('en:', '')),
      );
    }

    return Product(
      barcode: product['code'] ?? json['code'] ?? '',
      name: product['product_name'],
      brands: product['brands'],
      imageUrl: product['image_url'] ?? product['image_front_url'],
      ingredients: product['ingredients_text'],
      allergens: product['allergens'],
      nutriScore: product['nutriscore_grade'],
      
      energy: _parseDouble(nutriments['energy-kcal_100g'] ?? nutriments['energy_100g']),
      energyPercent: _parseDouble(nutriments['energy-kcal_value']),
      fat: _parseDouble(nutriments['fat_100g']),
      fatPercent: _parseDouble(nutriments['fat_value']),
      saturatedFat: _parseDouble(nutriments['saturated-fat_100g']),
      saturatedFatPercent: _parseDouble(nutriments['saturated-fat_value']),
      carbohydrates: _parseDouble(nutriments['carbohydrates_100g']),
      carbohydratesPercent: _parseDouble(nutriments['carbohydrates_value']),
      sugars: _parseDouble(nutriments['sugars_100g']),
      sugarsPercent: _parseDouble(nutriments['sugars_value']),
      fiber: _parseDouble(nutriments['fiber_100g']),
      fiberPercent: _parseDouble(nutriments['fiber_value']),
      proteins: _parseDouble(nutriments['proteins_100g']),
      proteinsPercent: _parseDouble(nutriments['proteins_value']),
      salt: _parseDouble(nutriments['salt_100g']),
      saltPercent: _parseDouble(nutriments['salt_value']),

      additionalNutrition: nutriments,
      additives: extractedAdditives,
      labels: extractedLabels,
    );
  }
  
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brands': brands,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'allergens': allergens,
      'nutriScore': nutriScore,
      'energy': energy,
      'energyPercent': energyPercent,
      'fat': fat,
      'fatPercent': fatPercent,
      'saturatedFat': saturatedFat,
      'saturatedFatPercent': saturatedFatPercent,
      'carbohydrates': carbohydrates,
      'carbohydratesPercent': carbohydratesPercent,
      'sugars': sugars,
      'sugarsPercent': sugarsPercent,
      'fiber': fiber,
      'fiberPercent': fiberPercent,
      'proteins': proteins,
      'proteinsPercent': proteinsPercent,
      'salt': salt,
      'saltPercent': saltPercent,
      'additives': additives,
      'labels': labels,
    };
  }
}