import 'package:flutter/material.dart';
import 'package:pdam_app/services/admin_service.dart';
import 'package:pdam_app/widgets/alert.dart';

class EditAdminView extends StatefulWidget {
  const EditAdminView({super.key});

  @override
  State<EditAdminView> createState() => _EditAdminViewState();
}

class _EditAdminViewState extends State<EditAdminView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  bool _isInit = false;
  bool _isLoading = false;
  late String _adminId;
  String _initialUsername =
      ""; // Menyimpan username awal untuk validasi opsional

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final adminData = ModalRoute.of(context)!.settings.arguments as Map;

      _adminId = adminData["id"].toString();
      _nameController = TextEditingController(
        text: adminData["name"] ?? "Malikah R.G",
      );

      // Mengambil username dari payload bersarang atau root langsung
      String currentUsername =
          adminData["user"]?["username"] ?? adminData["username"] ?? "SOTOM";
      _usernameController = TextEditingController(text: currentUsername);
      _initialUsername = currentUsername; // Kunci data awal

      _phoneController = TextEditingController(
        text: adminData["phone"] ?? "086432678541",
      );
      _passwordController = TextEditingController(
        text: adminData["password"] ?? "MalikahC4ntik",
      );

      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "A";
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. Menyusun data dasar yang aman diperbarui kapan saja
    Map<String, dynamic> updateData = {
      "name": _nameController.text,
      "phone": _phoneController.text,
      "password": _passwordController.text,
    };

    // 2. Logika penyaringan username agar tidak bentrok validasi unique di server
    if (_usernameController.text.trim() != _initialUsername.trim()) {
      updateData["username"] = _usernameController.text.trim();
    }

    // Eksekusi update ke service backend
    var response = await AdminService().updateAdmin(_adminId, updateData);

    setState(() => _isLoading = false);

    if (response.status) {
      // 3. Menggunakan AlertMessage custom Anda saat BERHASIL (status: true)
      AlertMessage().showAlert(
        context,
        "Profil admin berhasil diperbarui",
        true,
      );

      Navigator.pop(context, true);
    } else {
      // 4. Menggunakan AlertMessage custom Anda saat GAGAL (status: false)
      // Ini akan otomatis berwarna merah cerah dan menampilkan pesan error dari API
      AlertMessage().showAlert(context, response.message, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0A58CA)),
            )
          : Stack(
              children: [
                // 1. Background Gradient Biru Area Atas
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8AD4FE), Color(0xFFCBEBFE)],
                    ),
                  ),
                ),

                // 2. Konten Utama
                SafeArea(
                  child: Column(
                    children: [
                      // Custom App Bar Modern
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF0F172A),
                                size: 28,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Color(0xFF0F172A),
                                size: 28,
                              ),
                              onPressed: _submitUpdate,
                            ),
                          ],
                        ),
                      ),

                      // Form Isi Konten (Scrollable)
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            children: [
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 55,
                                    // Menggunakan warna biru solid premium sebagai background avatar menggantikan gambar
                                    backgroundColor: const Color(0xFF0A58CA),
                                    child: Text(
                                      _getInitials(_nameController.text),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Nama Teks Utama di Bawah Foto
                              Center(
                                child: Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text
                                      : "Malikah R.G",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Badge Text status ADMIN
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2F0FD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "ADMIN",
                                    style: TextStyle(
                                      color: Color(0xFF0A58CA),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Card Box Informasi Akun (Sesuai Persis dengan Gambar Desain)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Informasi Akun",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    _buildInlineRowField(
                                      label: "Nama Lengkap",
                                      controller: _nameController,
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                    ),
                                    const Divider(
                                      height: 28,
                                      thickness: 1,
                                      color: Color(0xFFF1F5F9),
                                    ),

                                    _buildInlineRowField(
                                      label: "Username",
                                      controller: _usernameController,
                                    ),
                                    const Divider(
                                      height: 28,
                                      thickness: 1,
                                      color: Color(0xFFF1F5F9),
                                    ),

                                    _buildInlineRowField(
                                      label: "Nomor hp",
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const Divider(
                                      height: 28,
                                      thickness: 1,
                                      color: Color(0xFFF1F5F9),
                                    ),

                                    _buildInlineRowField(
                                      label: "Password",
                                      controller: _passwordController,
                                      isPassword: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Desain Form Sebaris (Label Kiri, Kolom Input Rata Kanan Tanpa Kotak Border)
  Widget _buildInlineRowField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    Function(String)? onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword,
            textAlign: TextAlign
                .end, // Teks otomatis rata kanan mengikuti mockup gambar
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
            ),
            validator: (value) =>
                value!.isEmpty ? "$label tidak boleh kosong" : null,
          ),
        ),
      ],
    );
  }
}
