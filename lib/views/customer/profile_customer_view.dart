import 'package:flutter/material.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/customer_service.dart';
import 'package:pdam_app/views/customer/profile_customer_edit_view.dart';
import 'package:pdam_app/widgets/bottom_nav.dart';

class ProfileCustomerView extends StatefulWidget {
  const ProfileCustomerView({super.key});

  @override
  State<ProfileCustomerView> createState() => _ProfileCustomerViewState();
}

class _ProfileCustomerViewState extends State<ProfileCustomerView> {
  Map? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    var result = await CustomerService().showMe();
    
    if (!mounted) return;
    setState(() {
      profileData = result.status ? result.data : null;
      isLoading = false;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "C";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final data = profileData;

    // FIX: Amankan nested map agar tidak memicu error 'Null is not a subtype of Map'
    final Map<dynamic, dynamic> userData = (data?["user"] is Map) ? data!["user"] : {};
    final Map<dynamic, dynamic> serviceData = (data?["service"] is Map) ? data!["service"] : {};

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A58CA)))
          : data == null
              ? const Center(child: Text("Gagal memuat data profil pelanggan"))
              : Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.38,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF8AD4FE), Color(0xFFCBEBFE)],
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Center(
                              child: Text(
                                "Profil Saya",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                          
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: const Color(0xFF0A58CA),
                                child: Text(
                                  _getInitials(data["name"] ?? "Customer"),
                                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Center(
                            child: Text(
                              data["name"] ?? "Nama Pelanggan",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2F0FD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "CUSTOMER",
                                style: TextStyle(color: Color(0xFF0A58CA), fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Expanded(
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
                              children: [
                                _buildSectionCard(
                                  title: "Informasi Akun",
                                  items: [
                                    _buildInlineRow("Nama Lengkap", data["name"]),
                                    _buildInlineRow("Username", userData["username"]),
                                    _buildInlineRow("Password", "••••••••"),
                                    _buildInlineRow("Customer", data["name"]?.toString().split(" ")[0]),
                                    _buildInlineRow("No. Telepon", data["phone"]),
                                    _buildInlineRow("Nomor Pelanggan (NIK)", data["customer_number"]),
                                    _buildInlineRow("Alamat", data["address"]),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                _buildSectionCard(
                                  title: "Informasi Layanan",
                                  items: [
                                    _buildInlineRow("Nama Layanan", serviceData["name"] ?? "Layanan Aktif"),
                                    _buildInlineRow("Minimal Pemakaian", "${serviceData["min_usage"] ?? '0'} m³"),
                                    _buildInlineRow("Maksimal Pemakaian", "${serviceData["max_usage"] ?? '0'} m³"),
                                    _buildInlineRow("Tarif Harga", "Rp ${serviceData["price"] ?? '0'}"),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  clipBehavior: Clip.antiAlias, 
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildMenuActionRow(
                                        icon: Icons.person_outline,
                                        label: "Edit Profil",
                                        iconColor: const Color(0xFF0A58CA),
                                        onTap: () async {
                                          bool? updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditProfileCustomerView(currentData: data),
                                            ),
                                          );
                                          if (updated == true) loadProfile();
                                        },
                                      ),
                                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                                      _buildMenuActionRow(
                                        icon: Icons.settings_outlined,
                                        label: "Ganti Layanan",
                                        iconColor: const Color(0xFF0A58CA),
                                        onTap: () {},
                                      ),
                                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                                      _buildMenuActionRow(
                                        icon: Icons.logout_outlined,
                                        label: "Keluar",
                                        iconColor: const Color(0xFFEF4444),
                                        textColor: const Color(0xFFEF4444),
                                        showArrow: false,
                                        onTap: () async {
                                          await UserLogin().logout();
                                          if (mounted) {
                                            Navigator.pushReplacementNamed(context, '/login');
                                          }
                                        },
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
                  ],
                ),
      bottomNavigationBar: BottomNav(3),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> items}) {
    List<Widget> childrenWithDividers = [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      const SizedBox(height: 16),
    ];

    for (int i = 0; i < items.length; i++) {
      childrenWithDividers.add(items[i]);
      if (i < items.length - 1) {
        childrenWithDividers.add(const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)));
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: childrenWithDividers),
    );
  }

  Widget _buildInlineRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value?.toString() ?? "-",
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuActionRow({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF0F172A),
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
            ),
            if (showArrow) const Icon(Icons.arrow_forward_ios, color: Color(0xFFCBD5E1), size: 14),
          ],
        ),
      ),
    );
  }
}