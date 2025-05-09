import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scanned_product.dart';

class ScanHistoryProvider with ChangeNotifier {
  static final ScanHistoryProvider _instance = ScanHistoryProvider._internal();

  factory ScanHistoryProvider() {
    return _instance;
  }

  ScanHistoryProvider._internal() {
    _loadHistory();
  }

  List<ScannedProduct> _scanHistory = [];
  
  List<ScannedProduct> get scanHistory => _scanHistory;

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('scan_history') ?? [];
      
      _scanHistory = historyJson
          .map((item) => ScannedProduct.fromJson(json.decode(item)))
          .toList();

      _scanHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading scan history: $e');
      _scanHistory = [];
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _scanHistory
          .map((item) => json.encode(item.toJson()))
          .toList();
      
      await prefs.setStringList('scan_history', historyJson);
    } catch (e) {
      debugPrint('Error saving scan history: $e');
    }
  }

  void addToHistory(ScannedProduct product) {
    final existingIndex = _scanHistory.indexWhere(
      (item) => item.product.barcode == product.product.barcode
    );
    
    if (existingIndex != -1) {
      _scanHistory.removeAt(existingIndex);
    }

    _scanHistory.insert(0, product);

    if (_scanHistory.length > 50) {
      _scanHistory = _scanHistory.sublist(0, 50);
    }
    
    notifyListeners();
    _saveHistory();
  }

  void removeFromHistory(String id) {
    _scanHistory.removeWhere((item) => item.id == id);
    notifyListeners();
    _saveHistory();
  }

  void clearHistory() {
    _scanHistory.clear();
    notifyListeners();
    _saveHistory();
  }
}