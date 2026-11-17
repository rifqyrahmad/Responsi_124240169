import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/preferences_service.dart';

class WishlistProvider with ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();

  // [GANTI-SOAL 3 - LOCAL DB]: State daftar produk yang tersimpan di wishlist (tersimpan ke local database)
  List<Product> _wishlist = [];

  List<Product> get wishlist => List.unmodifiable(_wishlist);

  WishlistProvider() {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    _wishlist = await _prefs.loadWishlist();
    notifyListeners();
  }

  bool isWishlist(int productId) {
    return _wishlist.any((p) => p.id == productId);
  }

  // [GANTI-SOAL 3 - LOCAL DB]: Tambah atau hapus produk dari wishlist
  Future<bool> toggleWishlist(Product product) async {
    final exists = isWishlist(product.id);
    if (exists) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product);
    }
    await _prefs.saveWishlist(_wishlist);
    notifyListeners();
    return !exists;
  }

  // [GANTI-SOAL 3 - LOCAL DB]: Hapus produk dari wishlist
  Future<void> removeWishlist(int productId) async {
    _wishlist.removeWhere((p) => p.id == productId);
    await _prefs.saveWishlist(_wishlist);
    notifyListeners();
  }
}
