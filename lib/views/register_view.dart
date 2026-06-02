import 'package:flutter/material.dart';
import 'package:pdam_app/services/admin_service.dart';
import 'package:pdam_app/services/customer_service.dart';
import 'package:pdam_app/services/service_service.dart';
import 'package:pdam_app/widgets/alert.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  AdminService adminService = AdminService();
  CustomerService customerService = CustomerService();
  ServiceService serviceApi = ServiceService();

  final formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  // Field tambahan khusus customer
  TextEditingController customerNumber = TextEditingController();
  TextEditingController address = TextEditingController();

  String selectedRole = "ADMIN";
  String? selectedServiceId;
  List services = [];
  bool isLoading = false;
  bool showPass = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  // GANTI JADI INI
  loadServices() async {
    print("=== LOAD SERVICES DIPANGGIL ===");
    var result = await serviceApi.getAllCached(); // ← ganti ke getAllCached
    print("status: ${result.status}");
    print("message: ${result.message}");
    print("data: ${result.data}");
    print("services length: ${result.data?.length}");
    setState(() {
      services = result.data ?? [];
    });
    print("services di state: ${services.length}");

    if (services.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Data layanan belum tersedia. Pastikan admin pernah login di perangkat ini.",
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B2430),
        ),
      ),
    );
  }

  InputDecoration _customInputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.35, 1.0],
              colors: [Color(0xFF86D2FF), Color(0xFFE2F4FF), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "PDAM",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B2430),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedRole == "ADMIN"
                              ? "Buat akun admin baru untuk mengakses\nsistem PDAM"
                              : "Buat akun user baru untuk menikmati\nlayanan PDAM",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // TOGGLE SELEKTOR ROLE
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRole = "CUSTOMER";
                                    });
                                    loadServices(); // sudah otomatis pakai getAllPublic
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedRole == "CUSTOMER"
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: selectedRole == "CUSTOMER"
                                          ? [
                                              const BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Customer",
                                        style: TextStyle(
                                          color: selectedRole == "CUSTOMER"
                                              ? primaryColor
                                              : Colors.black87,
                                          fontWeight: selectedRole == "CUSTOMER"
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedRole = "ADMIN"),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedRole == "ADMIN"
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: selectedRole == "ADMIN"
                                          ? [
                                              const BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Administrator",
                                        style: TextStyle(
                                          color: selectedRole == "ADMIN"
                                              ? primaryColor
                                              : Colors.black87,
                                          fontWeight: selectedRole == "ADMIN"
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // FIELD UTAMA
                        _buildInputLabel("Username"),
                        TextFormField(
                          controller: username,
                          style: const TextStyle(color: Colors.black),
                          decoration: _customInputDecoration(
                            "Masukan Username",
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Username wajib diisi" : null,
                        ),

                        _buildInputLabel("Password"),
                        TextFormField(
                          controller: password,
                          obscureText: showPass,
                          style: const TextStyle(color: Colors.black),
                          decoration: _customInputDecoration(
                            "Masukan Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.black45,
                              ),
                              onPressed: () =>
                                  setState(() => showPass = !showPass),
                            ),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Password wajib diisi" : null,
                        ),

                        _buildInputLabel("Nama"),
                        TextFormField(
                          controller: name,
                          style: const TextStyle(color: Colors.black),
                          decoration: _customInputDecoration("Masukan Nama"),
                          validator: (v) =>
                              v!.isEmpty ? "Nama wajib diisi" : null,
                        ),

                        _buildInputLabel("No.Telepon"),
                        TextFormField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.black),
                          decoration: _customInputDecoration(
                            "Masukan No.Telepon",
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "No.Telepon wajib diisi" : null,
                        ),

                        // FIELD KHUSUS CUSTOMER
                        if (selectedRole == "CUSTOMER") ...[
                          _buildInputLabel("Nomor Pelanggan (NIK)"),
                          TextFormField(
                            controller: customerNumber,
                            style: const TextStyle(color: Colors.black),
                            decoration: _customInputDecoration(
                              "Masukan No. Pelanggan",
                            ),
                            validator: (v) =>
                                selectedRole == "CUSTOMER" && v!.isEmpty
                                ? "No. Pelanggan wajib diisi"
                                : null,
                          ),

                          _buildInputLabel("Alamat"),
                          TextFormField(
                            controller: address,
                            style: const TextStyle(color: Colors.black),
                            decoration: _customInputDecoration(
                              "Masukan Alamat",
                            ),
                            validator: (v) =>
                                selectedRole == "CUSTOMER" && v!.isEmpty
                                ? "Alamat wajib diisi"
                                : null,
                          ),

                          _buildInputLabel("Pilih Layanan"),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedServiceId,
                            decoration: _customInputDecoration(
                              "Pilih jenis layanan",
                            ),
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            items: services.map<DropdownMenuItem<String>>((s) {
                              return DropdownMenuItem<String>(
                                value: s["id"].toString(),
                                child: Text(
                                  "${s["name"]} — Rp ${s["price"]}",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => selectedServiceId = val),
                            validator: (v) =>
                                selectedRole == "CUSTOMER" && v == null
                                ? "Layanan wajib dipilih"
                                : null,
                          ),
                        ],

                        const SizedBox(height: 36),

                        // TOMBOL REGISTER
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      setState(() => isLoading = true);

                                      dynamic result;
                                      if (selectedRole == "ADMIN") {
                                        result = await adminService
                                            .registerAdmin({
                                              "username": username.text,
                                              "password": password.text,
                                              "name": name.text,
                                              "phone": phone.text,
                                            });
                                      } else {
                                        result = await customerService
                                            .registerSelf({
                                              "username": username.text,
                                              "password": password.text,
                                              "name": name.text,
                                              "phone": phone.text,
                                              "customer_number":
                                                  customerNumber.text,
                                              "address": address.text,
                                              "service_id":
                                                  selectedServiceId ?? "",
                                            });
                                      }

                                      setState(() => isLoading = false);

                                      if (result.status == true) {
                                        username.clear();
                                        password.clear();
                                        name.clear();
                                        phone.clear();
                                        customerNumber.clear();
                                        address.clear();
                                        setState(
                                          () => selectedServiceId = null,
                                        );

                                        if (mounted) {
                                          AlertMessage().showAlert(
                                            context,
                                            "Register $selectedRole berhasil!",
                                            true,
                                          );
                                          Future.delayed(
                                            const Duration(seconds: 2),
                                            () {
                                              if (mounted) {
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  '/login',
                                                );
                                              }
                                            },
                                          );
                                        }
                                      } else {
                                        if (mounted) {
                                          AlertMessage().showAlert(
                                            context,
                                            result.message,
                                            false,
                                          );
                                        }
                                      }
                                    }
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    selectedRole == "ADMIN"
                                        ? "Daftar sebagai Administrator"
                                        : "Daftar sebagai User",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Sudah punya akun? ",
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                  TextSpan(
                                    text: "Masuk di sini",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
