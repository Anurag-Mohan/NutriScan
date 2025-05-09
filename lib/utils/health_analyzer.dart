import '../models/product.dart';

class HealthAnalyzer {
  static double calculateHealthScore(Product product) {
    if (product.nutriScore != null) {
      switch (product.nutriScore!.toLowerCase()) {
        case 'a':
          return 90;
        case 'b':
          return 75;
        case 'c':
          return 60;
        case 'd':
          return 40;
        case 'e':
          return 20;
      }
    }

    double score = 50;

    if (product.sugars != null) {
      if (product.sugars! > 10) {
        score -= 10;
      } else if (product.sugars! > 5) {
        score -= 5;
      }
    }

    if (product.saturatedFat != null) {
      if (product.saturatedFat! > 5) {
        score -= 10;
      } else if (product.saturatedFat! > 2) {
        score -= 5;
      }
    }

    if (product.salt != null) {
      if (product.salt! > 1.5) {
        score -= 10;
      } else if (product.salt! > 0.8) {
        score -= 5;
      }
    }

    if (product.proteins != null) {
      if (product.proteins! > 20) {
        score += 10;
      } else if (product.proteins! > 10) {
        score += 5;
      }
    }

    if (product.fiber != null) {
      if (product.fiber! > 6) {
        score += 10;
      } else if (product.fiber! > 3) {
        score += 5;
      }
    }

    if (product.additives != null && product.additives!.isNotEmpty) {
      if (product.additives!.length > 5) {
        score -= 15;
      } else if (product.additives!.length > 2) {
        score -= 10;
      } else {
        score -= 5;
      }
    }

    if (product.labels != null && product.labels!.isNotEmpty) {
      bool hasHealthyLabel = product.labels!.any((label) =>
          label.toLowerCase().contains('organic') ||
          label.toLowerCase().contains('bio') ||
          label.toLowerCase().contains('natural') ||
          label.toLowerCase().contains('fair trade'));
      
      if (hasHealthyLabel) {
        score += 10;
      }
    }
    return score.clamp(0, 100);
  }

  static List<String> getRecommendations(Product product) {
    List<String> recommendations = [];
    if (product.sugars != null) {
      if (product.sugars! > 10) {
        recommendations.add(
            'This product is high in sugar (${product.sugars}g per 100g). Consider alternatives with less added sugar.');
      } else if (product.sugars! > 5) {
        recommendations.add(
            'This product contains a moderate amount of sugar (${product.sugars}g per 100g).');
      }
    }

    if (product.saturatedFat != null) {
      if (product.saturatedFat! > 5) {
        recommendations.add(
            'This product is high in saturated fat (${product.saturatedFat}g per 100g), which may contribute to heart disease risk.');
      } else if (product.saturatedFat! > 2) {
        recommendations.add(
            'This product contains a moderate amount of saturated fat (${product.saturatedFat}g per 100g).');
      }
    }

    if (product.salt != null) {
      if (product.salt! > 1.5) {
        recommendations.add(
            'This product is high in salt (${product.salt}g per 100g). High salt intake may increase blood pressure.');
      } else if (product.salt! > 0.8) {
        recommendations.add(
            'This product contains a moderate amount of salt (${product.salt}g per 100g).');
      }
    }

    if (product.additives != null && product.additives!.isNotEmpty) {
      if (product.additives!.length > 5) {
        recommendations.add(
            'This product contains ${product.additives!.length} additives. Products with fewer additives are generally considered healthier.');
      } else if (product.additives!.length > 0) {
        recommendations.add(
            'This product contains ${product.additives!.length} additives.');
      }
    }

    if (product.proteins != null && product.proteins! < 5) {
      recommendations.add(
          'This product is low in protein (${product.proteins}g per 100g). Consider including other protein sources in your diet.');
    }

    if (product.fiber != null && product.fiber! < 3) {
      recommendations.add(
          'This product is low in fiber (${product.fiber}g per 100g). Dietary fiber is important for digestive health.');
    }

    if (recommendations.isEmpty) {
      recommendations.add(
          'This product appears to have a balanced nutritional profile. Remember to maintain a varied diet with plenty of fruits and vegetables.');
    }

    return recommendations;
  }
}