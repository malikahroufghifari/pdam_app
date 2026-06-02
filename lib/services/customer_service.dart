import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdam_app/models/response_data_map.dart';
import 'package:pdam_app/models/response_data_list.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/url.dart' as url;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  Future<Map<String, String>> authHeaders() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return {"app-key": url.AppKey, "Authorization": "Bearer ${user.token}"};
  }

  //Create
  Future register(Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/customers");

      // Ambil token dari authHeaders tapi override Content-Type ke JSON
      var user = await UserLogin().getUserLogin();
      var headers = {
        "app-key": url.AppKey,
        "Authorization": "Bearer ${user.token}",
        "Content-Type": "application/json",
      };

      var jsonData = {
        "username": data["username"],
        "password": data["password"],
        "name": data["name"],
        "phone": data["phone"],
        "customer_number": data["customer_number"],
        "address": data["address"],
        "service_id":
            int.tryParse(data["service_id"].toString()) ??
            0, // ← konversi ke int
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
        message: resData["message"] ?? "Gagal menambahkan customer",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // Read All
  Future showAll() async {
    try {
      var uri = Uri.parse(
        "${url.BaseUrl}/customers?page=1&quantity=10&search=",
      );
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
        message: resData["message"] ?? "Gagal mengambil data",
      );
    } catch (e) {
      return ResponseDataList(status: false, message: "Fatal error: $e");
    }
  }

  // Read By ID
  Future showById(int id) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/customers/$id");
      var headers = await authHeaders();
      var response = await http.get(uri, headers: headers);
      var resData = json.decode(response.body);

      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataMap(
          status: true,
          message: resData["message"],
          data: resData["data"],
        );
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Customer tidak ditemukan",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  //Show me
  Future showMe() async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/customers/me");
      var headers = await authHeaders();
      var response = await http.get(uri, headers: headers);
      var resData = json.decode(response.body);

      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataMap(
          status: true,
          message: resData["message"],
          data: resData["data"],
        );
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Gagal memuat profil kamu",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  //Update
  Future update(int id, Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/customers/$id");
      var user = await UserLogin().getUserLogin();
      var headers = {
        "app-key": url.AppKey,
        "Authorization": "Bearer ${user.token}",
        "Content-Type": "application/json", 
      };

      var jsonData = {
        "customer_number": data["customer_number"],
        "address": data["address"],
        "name": data["name"],
        "phone": data["phone"],
        "service_id":
            int.tryParse(data["service_id"].toString()) ??
            0, 
      };

      var response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(jsonData),
      );
      var resData = json.decode(response.body);

      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataMap(
          status: true,
          message: resData["message"],
          data: resData["data"],
        );
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Gagal mengupdate customer",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }
  // Fungsi update profil khusus Admin sesuai dokumentasi endpoint nomor 7
  Future updateProfile(Map data) async {
    try {
      // Ambil ID admin yang dikirim dari form
      var id = data["id"]; 
      
      // SESUAIKAN ENDPOINT: Mengarah ke /admins/$id bukan /customers atau /me
      var uri = Uri.parse("${url.BaseUrl}/admins/$id");
      
      var user = await UserLogin().getUserLogin();
      var headers = {
        "app-key": url.AppKey,
        "Authorization": "Bearer ${user.token}",
        "Content-Type": "application/json", 
      };

      // Bungkus data sesuai yang diperbolehkan di-update oleh admin
      var jsonData = {
        "name": data["name"],
        "phone": data["phone"],
      };

      // Jika password diisi di form, masukkan ke JSON body
      if (data.containsKey("password") && data["password"].toString().isNotEmpty) {
        jsonData["password"] = data["password"];
      }

      var response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(jsonData),
      );
      
      var resData = json.decode(response.body);

      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataMap(
          status: true,
          message: resData["message"] ?? "Profil admin berhasil diperbarui",
          data: resData["data"],
        );
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Gagal memperbarui data profil admin",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  //Delete
  Future delete(int id) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/customers/$id");
      var headers = await authHeaders();
      var response = await http.delete(uri, headers: headers);
      var resData = json.decode(response.body);

      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataMap(
          status: true,
          message: resData["message"],
          data: resData["data"],
        );
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Gagal menghapus customer",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }
  Future registerSelf(Map data) async {
  try {
    var uri = Uri.parse("${url.BaseUrl}/customers");

    // Ambil admin_token yang tersimpan terpisah
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminToken = prefs.getString("admin_token");

    print("=== REGISTER SELF ===");
    print("admin_token: $adminToken");

    if (adminToken == null || adminToken.isEmpty) {
      return ResponseDataMap(
        status: false,
        message:
            "Tidak dapat mendaftar. Pastikan admin pernah login di perangkat ini.",
      );
    }

    var headers = {
      "app-key": url.AppKey,
      "Authorization": "Bearer $adminToken", // ← pakai admin_token
      "Content-Type": "application/json",
    };

    var jsonData = {
      "username":        data["username"],
      "password":        data["password"],
      "name":            data["name"],
      "phone":           data["phone"],
      "customer_number": data["customer_number"],
      "address":         data["address"],
      "service_id": int.tryParse(data["service_id"].toString()) ?? 0,
    };

    var response = await http.post(
      uri,
      headers: headers,
      body: json.encode(jsonData),
    );

    print("statusCode: ${response.statusCode}");
    print("body: ${response.body}");
    print("====================");

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
      message: resData["message"] ?? "Gagal mendaftarkan customer",
    );
  } catch (e) {
    return ResponseDataMap(status: false, message: "Fatal error: $e");
  }
}
}
