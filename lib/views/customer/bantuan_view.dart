import 'package:flutter/material.dart';
import 'package:pdam_app/models/response_data_list.dart';
import 'package:pdam_app/services/admin_service.dart';

class CallAdminView extends StatefulWidget {
  const CallAdminView({super.key});

  @override
  State<CallAdminView> createState() => _CallAdminViewState();
}

class _CallAdminViewState extends State<CallAdminView> {
  List<dynamic> listAdmin = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    final ResponseDataList response =
        await AdminService().showAll(page: 1, quantity: 10);
    setState(() {
      if (response.status && response.data!.isNotEmpty) {
        listAdmin = response.data!;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          // ── FIXED: Header biru (back button + judul + ilustrasi) ──────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Back
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF0D47A1)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Judul + Ilustrasi Headset
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Teks kiri
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Butuh bantuan?\nHubungi admin\nPDAM",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Kami siap membantu Anda kapan pun\ndengan layanan terbaik.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1565C0),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Ilustrasi Headset
                        Container(
                          width: 110,
                          height: 110,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 12,
                                child: Container(
                                  width: 80,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF1E3A8A),
                                        width: 5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 14,
                                bottom: 22,
                                child: Container(
                                  width: 14,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 14,
                                bottom: 22,
                                child: Container(
                                  width: 14,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 18,
                                bottom: 10,
                                child: Container(
                                  width: 3,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF29B6F6),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 2,
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
                ],
              ),
            ),
          ),

          // ── SCROLLABLE: List card admin ───────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : listAdmin.isEmpty
                    ? const Center(child: Text("Tidak ada admin aktif."))
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        itemCount: listAdmin.length,
                        itemBuilder: (context, index) {
                          final admin = listAdmin[index];
                          final String adminName =
                              admin['name'] ?? "Admin PDAM";
                          final String phone = admin['phone'] ?? "-";
                          final String username =
                              admin['user']?['username'] ?? "";
                          // API belum mengirim field status, default Aktif.
                          // Jika sudah ada: admin['status'] == 'Aktif'
                          const bool isOnline = true;

                          return _buildAdminCard(
                            name: adminName,
                            username: username,
                            phone: phone,
                            isOnline: isOnline,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard({
    required String name,
    required String username,
    required String phone,
    required bool isOnline,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar + dot status
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE0F2FE),
                backgroundImage: const AssetImage(
                    'assets/images/avatar_placeholder.png'),
                onBackgroundImageError: (_, __) {},
                child: const Icon(Icons.person,
                    size: 34, color: Color(0xFF90CAF9)),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Colors.green
                        : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Info admin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Customer Service Online",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (username.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    "@$username",
                    style: const TextStyle(
                      color: Color(0xFF90CAF9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: isOnline
                          ? Colors.green
                          : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? "Aktif" : "Offline",
                      style: TextStyle(
                        color: isOnline
                            ? Colors.green
                            : const Color(0xFFEF4444),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone_outlined,
                        size: 14, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}