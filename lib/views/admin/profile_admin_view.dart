import 'package:flutter/material.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/admin_service.dart';
import 'package:pdam_app/widgets/bottom_nav.dart';

class ProfileAdminView extends StatefulWidget {
  const ProfileAdminView({super.key});

  @override
  State<ProfileAdminView> createState() => _ProfileAdminViewState();
}

class _ProfileAdminViewState extends State<ProfileAdminView> {
  Map? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  loadProfile() async {
    setState(() => isLoading = true);
    var result = await AdminService().getMe();
    setState(() {
      profileData = result.status ? result.data : null;
      isLoading = false;
    });
  }

  // Fungsi untuk menangani Delete Account
  // Ganti fungsi _deleteAccount lama Anda dengan kode di bawah ini
  void _deleteAccount() async {
    if (profileData == null) return;

    var adminId = profileData!["id"]?.toString() ?? "";
    String adminName = profileData!["name"] ?? "Admin";

    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lingkaran Ikon Tempat Sampah (Merah Soft)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF1F2), // Merah sangat muda/soft
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_sweep_rounded, // Atau Icons.delete_outline
                      color: Color(
                        0xFFBA1A1A,
                      ), // Merah solid marun sesuai mockup
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Judul Modal
                  const Text(
                    "Hapus Akun",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Deskripsi Teks Tengah
                  Text(
                    "Apakah Anda yakin ingin menghapus akun admin $adminName?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Baris Tombol Aksi (Batal & Hapus)
                  Row(
                    children: [
                      // Tombol Batal
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tombol Hapus (Merah Marun)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFBA1A1A,
                            ), // Merah sesuai gambar
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Hapus",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;

    if (confirm) {
      setState(() => isLoading = true);
      var res = await AdminService().deleteAdmin(adminId);
      if (res.status) {
        await UserLogin().logout();
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(res.message)));
        }
      }
    }
  }

  // Fungsi navigasi ke halaman edit (Anda perlu membuat form UI edit sendiri nantinya)
  void _navigateToEdit() async {
    if (profileData == null) return;

    // Contoh asumsi navigasi ke page edit dengan membawa data saat ini
    var result = await Navigator.pushNamed(
      context,
      '/admin/profile/edit',
      arguments: profileData,
    );
    // Jika kembali dan membawa data sukses update, refresh profil
    if (result == true) {
      loadProfile();
    }
  }

  Widget _infoRowWidget(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil status bar height agar info baterai/jam tidak tertutup
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileData == null
          ? const Center(child: Text("Gagal memuat profil"))
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8CD3FF), Color(0xFFEBF7FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: statusBarHeight + 10),
                      // Custom Header Title & Back Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF004D80),
                              ),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Profil Saya",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 48,
                            ), // Balancer untuk arrow back
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(
                          0xFF004D80,
                        ), // Menggunakan warna hex biru gelap konstan agar serasi dengan tema
                        child: Text(
                          (profileData!["name"] ?? "A")[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Nama & Badge ADMIN
                      Text(
                        profileData!["name"] ?? "Malikah R.G",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "ADMIN",
                          style: TextStyle(
                            color: Color(0xFF0284C7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // White Container Main Content
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Informasi Akun",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _infoRowWidget(
                              "Nama Lengkap",
                              profileData!["name"] ?? "-",
                            ),
                            const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            _infoRowWidget(
                              "Username",
                              profileData!["user"]?["username"] ??
                                  profileData!["username"] ??
                                  "-",
                            ),
                            const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            _infoRowWidget(
                              "Nomor hp",
                              profileData!["phone"] ?? "-",
                            ),
                            const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            _infoRowWidget(
                              "Password",
                              "••••••••",
                            ), // Keamanan display
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Menu (Edit Profil & Keluar/Delete)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.person_outline,
                                color: Colors.blue,
                              ),
                              title: const Text(
                                "Edit Profil",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                              onTap: _navigateToEdit,
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: const Text(
                                "Keluar",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                await UserLogin().logout();
                                if (mounted)
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                              },
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            ListTile(
                              leading: const Icon(
                                Icons.delete_forever_outlined,
                                color: Colors.redAccent,
                              ),
                              title: const Text(
                                "Hapus Akun Admin",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: _deleteAccount,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const BottomNav(4),
    );
  }
}
