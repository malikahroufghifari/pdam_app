import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:pdam_app/models/response_data_map.dart';
import 'package:pdam_app/models/response_data_list.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/url.dart' as url;

class PaymentService {
  Future<Map<String, String>> authHeaders() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return {
      "app-key": url.AppKey,
      "Authorization": "Bearer ${user.token}",
    };
  }

  static String getPaymentProofUrl(String fileName) {
    return "${url.BaseUrl}/payment-proof/$fileName";
  }

  // CREATE - Kirim Bukti Pembayaran
  Future<ResponseDataMap> create(int billId, File imageFile) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/payments");
      var request = http.MultipartRequest('POST', uri);

      var headers = await authHeaders();
      request.headers.addAll(headers);

      request.fields['bill_id'] = billId.toString();

      String originalPath = imageFile.path;
      String ext = path.extension(originalPath).toLowerCase().replaceAll('.', '');

      if (ext.isEmpty || !['jpg', 'jpeg', 'png'].contains(ext)) {
        ext = 'jpg'; 
      }

      String mimeSubtype = ext; 
      if (ext == 'jpg') {
        mimeSubtype = 'jpeg';
      }

      String safeExtension = (mimeSubtype == 'jpeg') ? 'jpeg' : mimeSubtype;
      String cleanFileName = 'payment_proof_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', 
          imageFile.path,
          filename: cleanFileName,          
          contentType: MediaType('image', mimeSubtype),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var resData = json.decode(response.body);

      if ((streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) &&
          resData["success"] == true) {
        return ResponseDataMap(
            status: true, message: resData["message"], data: resData["data"]);
      }
      return ResponseDataMap(
          status: false,
          message: resData["message"] ?? "Gagal mengirim pembayaran");
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  // ACC/Verifikasi oleh Admin (Sesuai Postman Anda yang murni PATCH tanpa body)
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

  // Tolak/Hapus Pembayaran oleh Admin
  Future rejectPayment(int paymentId) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/payments/$paymentId");
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
        message: resData["message"] ?? "Gagal menolak pembayaran",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }

  Future showAllByAdmin({int page = 1, int quantity = 100, String search = ""}) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/payments?page=$page&quantity=$quantity&search=$search");
      var headers = await authHeaders();
      var response = await http.get(uri, headers: headers);
      var resData = json.decode(response.body);
      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataList(status: true, message: resData["message"], data: resData["data"], count: resData["count"]);
      }
      return ResponseDataList(status: false, message: resData["message"] ?? "Gagal mengambil semua data pembayaran");
    } catch (e) { return ResponseDataList(status: false, message: "Fatal error: $e"); }
  }

  Future showAllByCustomer({int page = 1, int quantity = 100, String search = ""}) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/payments/me?page=$page&quantity=$quantity&search=$search");
      var headers = await authHeaders();
      var response = await http.get(uri, headers: headers);
      var resData = json.decode(response.body);
      if (response.statusCode == 200 && resData["success"] == true) {
        return ResponseDataList(status: true, message: resData["message"], data: resData["data"], count: resData["count"]);
      }
      return ResponseDataList(status: false, message: resData["message"] ?? "Gagal mengambil riwayat pembayaran");
    } catch (e) { return ResponseDataList(status: false, message: "Fatal error: $e"); }
  }
  Future<ResponseDataMap> showDetailByCustomer(int paymentId) async {
    try {
      var uri = Uri.parse("${url.BaseUrl}/payments/me/$paymentId");
      UserLogin userLogin = UserLogin();
      var user = await userLogin.getUserLogin();

      var response = await http.get(uri, headers: {
        "app-key": url.AppKey,
        "Authorization": "Bearer ${user.token}",
      });
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
        message: resData["message"] ?? "Gagal mengambil detail pembayaran",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Fatal error: $e");
    }
  }
}
