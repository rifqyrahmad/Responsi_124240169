import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';

class AuthProvider with ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  bool _isLoggedIn = false;
  String? _currentUsername;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUsername => _currentUsername;
  bool get isLoading => _isLoading;

  Future<void> checkAuthStatus() async {
    _isLoggedIn = await _prefs.isLoggedIn();
    if (_isLoggedIn) {
      _currentUsername = await _prefs.getLoggedInUsername();
    }
    notifyListeners();
  }

  Future<String?> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _db.registerUser(username.trim(), password);
      if (!success) {
        return 'Username sudah terdaftar! Gunakan username lain.';
      }
      return null;
    } catch (e) {
      return 'Terjadi kesalahan saat pendaftaran: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _db.loginUser(username.trim(), password);
      if (user != null) {
        _isLoggedIn = true;
        _currentUsername = user.username;
        await _prefs.setLoginSession(user.username);
        return null;
      } else {
        return 'Username atau password salah!';
      }
    } catch (e) {
      return 'Terjadi kesalahan saat login: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _prefs.clearLoginSession();
    _isLoggedIn = false;
    _currentUsername = null;
    notifyListeners();
  }
}
