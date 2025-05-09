import 'package:uuid/uuid.dart';
import 'product.dart';

class ScannedProduct {
  final String id;
  final Product product;
  final DateTime timestamp;

  ScannedProduct({
    String? id,
    required this.product,
    DateTime? timestamp,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();

  factory ScannedProduct.fromJson(Map<String, dynamic> json) {
    return ScannedProduct(
      id: json['id'],
      product: Product.fromJson(json['product']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}