import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  bool? status = false;
  String? token;
  String? message;
  int? id;
  String? name;
  String? username;
  String? role;

  UserLogin({this.status, this.token, this.message, this.id, this.name, this.username, this.role});

  Future prefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("status", status!);
  prefs.setString("token", token!);
  prefs.setString("message", message ?? "");
  prefs.setInt("id", id!);
  prefs.setString("name", name ?? "");
  prefs.setString("username", username ?? "");
  prefs.setString("role", role!);

  // Simpan admin_token secara terpisah agar tidak ikut terhapus saat logout
  print("=== PREFS DISIMPAN ===");
  print("role: $role");
  print("token: $token");

  if (role == "ADMIN") {
    await prefs.setString("admin_token", token!);
    print("admin_token DISIMPAN: $token");
  } else {
    print("bukan ADMIN, admin_token tidak disimpan");
  }
  print("======================");
}

  Future getUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loginStatus = prefs.getBool("status");
    if (loginStatus == null || loginStatus == false) {
      return UserLogin(status: false);
    }
    return UserLogin(
      status: prefs.getBool("status"),
      token: prefs.getString("token"),
      message: prefs.getString("message"),
      id: prefs.getInt("id"),
      name: prefs.getString("name"),
      username: prefs.getString("username"),
      role: prefs.getString("role"),
    );
  }

  // Di user_login.dart
Future logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Hapus hanya data session user, JANGAN hapus cache services
  await prefs.remove("status");
  await prefs.remove("token");
  await prefs.remove("message");
  await prefs.remove("id");
  await prefs.remove("name");
  await prefs.remove("username");
  await prefs.remove("role");
  
  
}
}