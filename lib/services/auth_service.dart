import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdam_app/models/response_data_map.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/url.dart' as url;

class AuthService {
  Map<String, String> get baseHeaders => {
        "app-key": url.AppKey,
      };

  Future<ResponseDataMap> login(Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/auth");
      var response = await http.post(
        uri,
        headers: baseHeaders,
        body: {
          "username": data["username"].toString(),
          "password": data["password"].toString(),
        },
      );

      var resData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          resData["success"] == true) {
        String role = (resData["role"] ?? "").toString().toUpperCase();

        UserLogin userLogin = UserLogin(
          status: true,
          token: resData["token"],
          message: resData["message"] ?? "Login berhasil",
          id: 0,
          name: "",
          username: data["username"].toString(),
          role: role,
        );
        await userLogin.prefs();

        // Jika login sebagai ADMIN, simpan daftar services ke SharedPreferences
        // agar customer bisa baca saat register tanpa token
        if (role == "ADMIN") {
          await _cacheServices(resData["token"]);
        }

        return ResponseDataMap(
          status: true,
          message: "Login berhasil",
          data: resData,
        );
      }

      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Username atau password salah",
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Terjadi kesalahan: $e",
      );
    }
  }

  // Ambil services pakai token admin, simpan ke SharedPreferences
  Future _cacheServices(String token) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/services?page=1&quantity=100");
      var response = await http.get(uri, headers: {
        "app-key": url.AppKey,
        "Authorization": "Bearer $token",
      });
      var resData = json.decode(response.body);

      if (response.statusCode == 200 && resData["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Simpan sebagai JSON string
        await prefs.setString("cached_services", json.encode(resData["data"]));
        print("=== SERVICES CACHED: ${resData["data"].length} layanan ===");
      }
    } catch (e) {
      print("=== CACHE SERVICES ERROR: $e ===");
    }
  }
}