import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdam_app/models/response_data_map.dart';
import 'package:pdam_app/models/response_data_list.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/url.dart' as url;
import 'package:shared_preferences/shared_preferences.dart';

class ServiceService {
  Future<Map<String, String>> authHeaders() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return {"app-key": url.AppKey, "Authorization": "Bearer ${user.token}"};
  }

  // SOAL NO 4 — Read All Services
  Future getAll() async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/services?page=1&quantity=100");
      var headers = await authHeaders();
      var response = await http.get(uri, headers: headers);
      var resData = json.decode(response.body);
      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataList(
          status: true,
          message: resData["message"],
          data: resData["data"],
          count: resData["count"],
        );
      }
      return ResponseDataList(
        status: false,
        message: resData["message"] ?? "Gagal",
      );
    } catch (e) {
      return ResponseDataList(status: false, message: "Fatal error: $e");
    }
  }

  // Tambahkan fungsi ini di ServiceService
  // Dipakai saat user belum login (halaman Register)
  Future getAllPublic() async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/services?page=1&quantity=100");
      var headers = {"app-key": url.AppKey};
      var response = await http.get(uri, headers: headers);

      print("=== GET SERVICES PUBLIC ===");
      print("statusCode: ${response.statusCode}");
      print("body: ${response.body}");
      print("===========================");

      var resData = json.decode(response.body);
      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataList(
          status: true,
          message: resData["message"],
          data: resData["data"],
          count: resData["count"],
        );
      }
      return ResponseDataList(
        status: false,
        message: resData["message"] ?? "Gagal memuat layanan",
      );
    } catch (e) {
      return ResponseDataList(status: false, message: "Fatal error: $e");
    }
  }

  // Create
  Future create(Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/services");
      var user = await UserLogin().getUserLogin();
      var headers = {
        "app-key": url.AppKey,
        "Authorization": "Bearer ${user.token}",
        "Content-Type": "application/json",
      };

      var jsonData = {
        "name": data["name"],
        "min_usage": num.tryParse(data["min_usage"].toString()) ?? 0,
        "max_usage": num.tryParse(data["max_usage"].toString()) ?? 0,
        "price": num.tryParse(data["price"].toString()) ?? 0,
      };

      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(jsonData),
      );
      var resData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          resData["success"] == true) {
        return ResponseDataMap(
          status: true,
          message: resData["message"],
          data: resData["data"],
        );
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Gagal",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // Update
  Future update(int id, Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/services/$id");
      var user = await UserLogin().getUserLogin();
      var headers = {
        "app-key": url.AppKey,
        "Authorization": "Bearer ${user.token}",
        "Content-Type": "application/json", // ← wajib
      };

      var jsonData = {
        "name": data["name"],
        "min_usage": num.tryParse(data["min_usage"].toString()) ?? 0,
        "max_usage": num.tryParse(data["max_usage"].toString()) ?? 0,
        "price": num.tryParse(data["price"].toString()) ?? 0,
      };

      var response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(jsonData),
      );
      var resData = json.decode(response.body);

      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataMap(status: true, message: resData["message"]);
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Gagal",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  Future delete(int id) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/services/$id");
      var headers = await authHeaders();
      var response = await http.delete(uri, headers: headers);
      var resData = json.decode(response.body);

      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataMap(status: true, message: resData["message"]);
      }
      // Tangkap pesan Prisma dan tampilkan pesan yang lebih ramah
      String msg = resData["message"] ?? "Gagal menghapus";
      if (msg.contains("Prisma") || msg.contains("constraint")) {
        msg =
            "Layanan tidak dapat dihapus karena masih digunakan oleh customer.";
      }
      return ResponseDataMap(status: false, message: msg);
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }
  // Tambahkan fungsi ini di ServiceService
// Baca dari cache SharedPreferences — tidak butuh token
Future getAllCached() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("=== CEK SEMUA KEY DI SHAREDPREFS ===");
    print("semua keys: ${prefs.getKeys()}");
    print("nilai cached_services: ${prefs.getString("cached_services")}");
    print("=====================================");
    String? cached = prefs.getString("cached_services");

    if (cached != null && cached.isNotEmpty) {
      List data = json.decode(cached);
      return ResponseDataList(
        status: true,
        message: "Data dari cache",
        data: data,
        count: data.length,
      );
    }

    // Cache kosong — belum ada admin yang login
    return ResponseDataList(
      status: false,
      message: "Data layanan belum tersedia. Minta admin login terlebih dahulu.",
    );
  } catch (e) {
    return ResponseDataList(status: false, message: "Fatal error: $e");
  }
}
}
