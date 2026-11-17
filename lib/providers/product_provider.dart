import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _products = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // [GANTI-SOAL 4 - UI HOME & FILTER]: Memuat daftar kategori dari API GET /products/category-list
  Future<void> fetchCategories() async {
    try {
      final list = await _api.getCategories();
      _categories = ['All', ...list];
      notifyListeners();
    } catch (_) {
      // Jika error, gunakan daftar standar
      _categories = ['All', 'beauty', 'fragrances', 'furniture', 'groceries'];
      notifyListeners();
    }
  }

  // Memuat daftar minimal 10 produk dari API
  Future<void> fetchProducts({bool refresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getProducts(
        category: _selectedCategory,
        query: _searchQuery,
      );

      _products = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // [GANTI-SOAL 4 - UI HOME & FILTER]: Filter produk berdasarkan kategori yang dipilih pengguna
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchProducts(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProducts(refresh: true);
  }
}
