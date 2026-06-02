import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdam_app/models/response_data_map.dart';
import 'package:pdam_app/models/response_data_list.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/url.dart' as url;

class BillService {
  Future<Map<String, String>> authHeaders() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return {"app-key": url.AppKey, "Authorization": "Bearer ${user.token}"};
  }

  // Verifikasi/ACC Pembayaran oleh Admin (Tetap mengarah ke endpoint /payments/:id sesuai Postman)
  Future verifyPayment(int paymentId) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/payments/$paymentId");
      var headers = await authHeaders();
      var response = await http.patch(uri, headers: headers);
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
        message: resData["message"] ?? "Gagal memverifikasi pembayaran",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // Tolak/Hapus Pembayaran oleh Admin (Tetap mengarah ke endpoint /payments/:id sesuai Postman)
Future rejectPayment(int paymentId) async {
  try {
    var uri = Uri.parse("${url.BaseUrl}/payments/$paymentId");
    var headers = await authHeaders();
    var response = await http.delete(uri, headers: headers); // <--- Ini sudah benar menghapus payment di backend
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
      message: resData["message"] ?? "Gagal menolak pembayaran",
    );
  } catch (e) {
    return ResponseDataMap(status: false, message: "Fatal error: $e");
  }
}

  // Create Bill (Admin)
  Future create(Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/bills");
      var user = await UserLogin().getUserLogin();
      var headers = {
        "app-key": url.AppKey,
        "Authorization": "Bearer ${user.token}",
        "Content-Type": "application/json",
      };

      var jsonData = {
        "customer_id": int.tryParse(data["customer_id"].toString()) ?? 0,
        "month": int.tryParse(data["month"].toString()) ?? 1,
        "year": int.tryParse(data["year"].toString()) ?? 2024,
        "measurement_number": data["measurement_number"],
        "usage_value": num.tryParse(data["usage_value"].toString()) ?? 0,
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
        message: resData["message"] ?? "Gagal membuat tagihan",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // Read all bills (Admin)
  Future showAllByAdmin({
    int page = 1,
    int quantity = 10,
    String search = "",
  }) async {
    try {
      var uri = Uri.parse(
        "${url.BaseUrl}/bills?page=$page&quantity=$quantity&search=$search",
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
        message: resData["message"] ?? "Gagal mengambil semua tagihan",
      );
    } catch (e) {
      return ResponseDataList(status: false, message: "Fatal error: $e");
    }
  }

  // Read detail bill (Admin)
  Future showDetailByAdmin(int id) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/bills/$id");
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
        message: resData["message"] ?? "Tagihan tidak ditemukan",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // Read all bills (Customer)
  Future showAllByCustomer({
    int page = 1,
    int quantity = 10,
    String search = "",
  }) async {
    try {
      var uri = Uri.parse(
        "${url.BaseUrl}/bills/me?page=$page&quantity=$quantity&search=$search",
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
        message: resData["message"] ?? "Gagal mengambil tagihan kamu",
      );
    } catch (e) {
      return ResponseDataList(status: false, message: "Fatal error: $e");
    }
  }

  // Read detail bill (Customer)
  Future showDetailByCustomer(int id) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/bills/me/$id");
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
        message: resData["message"] ?? "Detail tagihan kamu tidak ditemukan",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // Update Bill (Admin)
  Future update(int id, Map data) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/bills/$id");
      var user = await UserLogin().getUserLogin();
      var headers = {
        "app-key": url.AppKey,
        "Authorization": "Bearer ${user.token}",
        "Content-Type": "application/json",
      };

      var jsonData = {
        "month": int.tryParse(data["month"].toString()) ?? 1,
        "year": int.tryParse(data["year"].toString()) ?? 2024,
        "measurement_number": data["measurement_number"],
        "usage_value": num.tryParse(data["usage_value"].toString()) ?? 0,
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
        message: resData["message"] ?? "Gagal memperbarui tagihan",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // Delete Bill (Admin)
  Future drop(int id) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/bills/$id");
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
        message: resData["message"] ?? "Gagal menghapus tagihan",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }
}