import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/scanned_product.dart';
import 'scan_history_provider.dart';

class ProductProvider with ChangeNotifier {
  Product? _product;
  bool _isLoading = false;
  String? _error;

  Product? get product => _product;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setProduct(Product product) {
    _product = product;
    _error = null;
    notifyListeners();
  }

  void clearProduct() {
    _product = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> fetchProductByBarcode(String barcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 1) {
          _product = Product.fromJson(data);
          
          if (_product != null && _product!.name != null) {
            final scannedProduct = ScannedProduct(product: _product!);
            ScanHistoryProvider().addToHistory(scannedProduct);
          }
          
          notifyListeners();
          return true;
        } else {
          _error = 'Product not found';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Failed to fetch product data: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }
}