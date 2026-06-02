import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdam_app/models/response_data_list.dart';
import 'package:pdam_app/models/response_data_map.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/url.dart' as url;

class AdminService {
  // 1. Tambahkan Content-Type JSON ke baseHeaders agar server mengenali request body
  Map<String, String> get baseHeaders => {
        "app-key": url.AppKey,
        "Content-Type": "application/json", 
      };

  Future<Map<String, String>> authHeaders() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return {
      "app-key": url.AppKey,
      "Authorization": "Bearer ${user.token}",
      "Content-Type": "application/json",
    };
  }

  Future registerAdmin(Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/admins");
      
      // Sekarang sudah aman karena baseHeaders membawa Content-Type JSON
      var response = await http.post(
        uri,
        headers: baseHeaders,
        body: json.encode(data),
      );
      
      var resData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (resData["success"] == true) {
          return ResponseDataMap(
            status: true,
            message: resData["message"],
            data: resData["data"],
          );
        }
        return ResponseDataMap(
          status: false,
          message: resData["message"] ?? "Gagal register",
        );
      }
      
      if (response.statusCode == 400) {
        print("Eror dari server: ${response.body}");
        // Jika server mengembalikan object pesan, kita tampilkan pesan erornya langsung ke UI
        return ResponseDataMap(
          status: false,
          message: resData["message"] ?? "Validasi gagal (Bad Request)",
        );
      }
      
      return ResponseDataMap(
        status: false,
        message: "Error: ${response.statusCode}",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  

Future showAll({int page = 1, int quantity = 10}) async {
  try {
    var uri = Uri.parse("${url.BaseUrl}/admins?page=$page&quantity=$quantity");
    var headers = await authHeaders(); 
    var response = await http.get(uri, headers: headers);
    var resData = json.decode(response.body);

    if (response.statusCode == 200) {
      return ResponseDataList(
        status: true,
        message: resData["message"] ?? "Berhasil mengambil data admin",
        data: resData["data"], 
      );
    }
    return ResponseDataList(
      status: false,
      message: resData["message"] ?? "Error: ${response.statusCode}",
    );
  } catch (e) {
    return ResponseDataList(status: false, message: "Fatal error: $e");
  }
}

  Future getMe() async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/admins/me");
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
        message: resData["message"] ?? "Gagal",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // FITUR UPDATE ADMIN
  Future updateAdmin(String id, Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/admins/$id");
      var headers = await authHeaders();
      var response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      var resData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResponseDataMap(
          status: true,
          message: resData["message"] ?? "Berhasil memperbarui data admin",
          data: resData["data"],
        );
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Error: ${response.statusCode}",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // DELETE ADMIN
  Future deleteAdmin(String id) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/admins/$id");
      var headers = await authHeaders();

      var response = await http.delete(uri, headers: headers);
      var resData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ResponseDataMap(
          status: true,
          message: resData["message"] ?? "Admin berhasil dihapus",
        );
      }
      return ResponseDataMap(
        status: false,
        message: resData["message"] ?? "Error: ${response.statusCode}",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }
}