// [GANTI-SOAL 3 - LOCAL DB]: Model User untuk autentikasi dan penyimpanan akun di database lokal (SQLite / Hive / SharedPreferences)
class User {
  final int? id;
  final String username;
  final String password;

  User({this.id, required this.username, required this.password});

  // Mapping ke Map untuk operasi insert SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  // Mapping dari Map hasil query SQLite ke objek User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }
}
