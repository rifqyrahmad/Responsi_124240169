import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // [GANTI-SOAL 3 - LOCAL DB]: Kunci penyimpanan akun lokal untuk platform Web (fallback)
  static const String _webUsersKey = 'shopping_hub_web_users';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // [GANTI-SOAL 3 - LOCAL DB]: Nama file database SQLite lokal ShoppingHub
    _database = await _initDB('shopping_hub.db');
    // Akun default bawaan agar penguji/dosen bisa langsung login
    await _database!.insert(
      'users',
      {'username': '169', 'password': 'Rifqy'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // [GANTI-SOAL 3 - LOCAL DB]: Tabel akun pengguna pada SQLite
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    await db.insert(
      'users',
      {'username': '169', 'password': 'Rifqy'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // --- Web Fallback Methods ---
  Future<List<Map<String, dynamic>>> _getWebUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_webUsersKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      final defaultList = [
        {'id': 1, 'username': '169', 'password': 'Rifqy'}
      ];
      await prefs.setString(_webUsersKey, jsonEncode(defaultList));
      return defaultList;
    }
    final List decoded = jsonDecode(jsonStr);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _saveWebUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webUsersKey, jsonEncode(users));
  }

  // --- Public Auth Methods (SQLite di Mobile/Desktop, SharedPreferences di Web) ---
  Future<bool> registerUser(String username, String password) async {
    if (kIsWeb) {
      final users = await _getWebUsers();
      final exists = users.any(
        (u) =>
            (u['username'] as String).toLowerCase() ==
            username.trim().toLowerCase(),
      );
      if (exists) return false;

      users.add({
        'id': users.length + 1,
        'username': username.trim(),
        'password': password,
      });
      await _saveWebUsers(users);
      return true;
    }

    final db = await instance.database;
    try {
      final existing = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (existing.isNotEmpty) {
        return false;
      }

      await db.insert(
        'users',
        User(username: username, password: password).toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<User?> loginUser(String username, String password) async {
    if (kIsWeb) {
      final users = await _getWebUsers();
      final match = users.cast<Map<String, dynamic>?>().firstWhere(
            (u) =>
                u?['username'] == username.trim() && u?['password'] == password,
            orElse: () => null,
          );
      if (match != null) {
        return User.fromMap(match);
      }
      return null;
    }

    try {
      final db = await instance.database;
      final results = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (results.isNotEmpty) {
        return User.fromMap(results.first);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
