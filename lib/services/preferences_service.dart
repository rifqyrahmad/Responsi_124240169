import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class PreferencesService {
  static const String _keyIsLoggedIn = 'shopping_hub_logged_in';
  static const String _keyUsername = 'shopping_hub_username';

  // [GANTI-SOAL 3 - LOCAL DB]: Kunci SharedPreferences untuk menyimpan daftar Wishlist produk
  static const String _keyWishlist = 'shopping_hub_wishlist';

  Future<void> setLoginSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<void> clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }

  // [GANTI-SOAL 3 - LOCAL DB]: Menyimpan data wishlist produk ke local database
  Future<void> saveWishlist(List<Product> wishlist) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = Product.encodeList(wishlist);
    await prefs.setString(_keyWishlist, jsonStr);
  }

  // [GANTI-SOAL 3 - LOCAL DB]: Memuat data wishlist produk dari local database
  Future<List<Product>> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyWishlist);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    return Product.decodeList(jsonStr);
  }
}
