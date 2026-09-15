import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/product.dart';

class CatalogService extends ChangeNotifier {
  CatalogService._();

  static final CatalogService instance = CatalogService._();

  final List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => List.unmodifiable(_products);

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> load() async {
    if (_isLoading) return;
    if (_products.isNotEmpty) return;

    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/api/products');
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      _products
        ..clear()
        ..addAll(list);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'No se pudo conectar con el servidor';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    _products.clear();
    _isLoading = false;
    notifyListeners();
    await load();
  }

  Future<void> reset() async {
    _products.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}