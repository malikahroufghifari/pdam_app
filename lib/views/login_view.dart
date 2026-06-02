import 'package:flutter/material.dart';
import 'package:pdam_app/services/auth_service.dart';
import 'package:pdam_app/widgets/alert.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;
  bool showPass = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(
        0xFFD2EFFF,
      ), // Selaras dengan ujung gradasi background
      body: GestureDetector(
        onTap: () => FocusScope.of(
          context,
        ).unfocus(), // Menutup keyboard saat menyentuh luar form
        child: Stack(
          children: [
            // 1. GRADIENT BACKGROUND (Hanya menghias area atas)
            Container(
              height: screenSize.height * 0.45,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF98D9FF), Color(0xFFD2EFFF)],
                ),
              ),
            ),

            // 2. SCROLLABLE LAYOUT (Solusi anti-bug teks hilang / keyboard overflow)
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  // Komponen LogoSlogan di bagian atas
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Image.asset(
                        'assets/LogoSlogan.png', // Menggunakan LogoSlogan.png sesuai request Anda
                        height: screenSize.height * 0.22,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Kontainer Form Putih Melengkung yang Mengikuti Sisa Layar
                  SliverFillRemaining(
                    hasScrollBody:
                        false, // Membiarkan kolom membesar secara alami
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            32,
                          ), // Lengkungan sudut halus sesuai Login.png
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Selamat Datang",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Silahkan masuk untuk melanjutkan",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7A869A),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // FIELD USERNAME
                            const Text(
                              "Username",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: username,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Masukan Username",
                                hintStyle: const TextStyle(
                                  color: Color(0xFFA5ADBA),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFC1C7D0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFC1C7D0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0C70F2),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Username wajib diisi" : null,
                            ),
                            const SizedBox(height: 20),

                            // FIELD PASSWORD
                            const Text(
                              "Password",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: password,
                              obscureText: showPass,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Masukan Password",
                                hintStyle: const TextStyle(
                                  color: Color(0xFFA5ADBA),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 12.0,
                                  ),
                                  child: IconButton(
                                    onPressed: () =>
                                        setState(() => showPass = !showPass),
                                    icon: Icon(
                                      showPass
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF7A869A),
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFC1C7D0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFC1C7D0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0C70F2),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Password wajib diisi" : null,
                            ),
                            const SizedBox(height: 32),

                            // TOMBOL LOGIN
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0C70F2),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (formKey.currentState!.validate()) {
                                          setState(() => isLoading = true);
                                          var result = await authService.login({
                                            "username": username.text,
                                            "password": password.text,
                                          });
                                          setState(() => isLoading = false);

                                          if (result.status == true) {
                                            if (mounted) {
                                              AlertMessage().showAlert(
                                                context,
                                                "Login berhasil!",
                                                true,
                                              );
                                            }

                                            String role =
                                                (result.data?["role"] ?? "")
                                                    .toString()
                                                    .toUpperCase();

                                            Future.delayed(
                                              const Duration(seconds: 1),
                                              () {
                                                if (mounted) {
                                                  if (role == "ADMIN") {
                                                    Navigator.pushReplacementNamed(
                                                      context,
                                                      '/admin/dashboard',
                                                    );
                                                  } else if (role ==
                                                      "CUSTOMER") {
                                                    Navigator.pushReplacementNamed(
                                                      context,
                                                      '/customer/dashboard',
                                                    );
                                                  } else {
                                                    AlertMessage().showAlert(
                                                      context,
                                                      "Akses ditolak: Role '$role' tidak dikenali sistem.",
                                                      false,
                                                    );
                                                  }
                                                }
                                              },
                                            );
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
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // LINK DAFTAR / REGISTER
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  '/register',
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Belum punya akun? ",
                                        style: TextStyle(
                                          color: Color(0xFF7A869A),
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Daftar sekarang",
                                        style: TextStyle(
                                          color: Color(0xFF0C70F2),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
