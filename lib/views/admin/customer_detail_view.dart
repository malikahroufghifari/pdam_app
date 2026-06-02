import 'package:flutter/material.dart';
import 'package:pdam_app/services/customer_service.dart';
import 'package:pdam_app/services/service_service.dart';
import 'package:pdam_app/widgets/alert.dart';

class CustomerDetailView extends StatefulWidget {
  const CustomerDetailView({super.key});

  @override
  State<CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView> {
  final CustomerService customerApi = CustomerService();
  final ServiceService serviceApi = ServiceService();
  
  Map? customerData;
  List allServices = [];
  bool isLoading = true;
  bool isIdFetched = false;

  fetchDetailAndServices(int id) async {
    setState(() => isLoading = true);
    var detailResult = await customerApi.showById(id);
    var serviceResult = await serviceApi.getAll();
    
    setState(() {
      customerData = detailResult.data;
      allServices = serviceResult.data ?? [];
      isLoading = false;
    });
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void confirmDelete(int id, String name, String custNumber) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFFDE8E8), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Color(0xFFC81E1E), size: 48),
              ),
              const SizedBox(height: 20),
              const Text("Hapus Customer", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
                  children: [
                    const TextSpan(text: "Apakah Anda yakin ingin menghapus\n"),
                    TextSpan(text: "$custNumber $name?", style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Batal", style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC81E1E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        var result = await customerApi.delete(id);
                        if (context.mounted) {
                          AlertMessage().showAlert(context, result.message, result.status);
                        }
                        if (result.status && context.mounted) {
                          // Mengirim 'true' ke halaman list agar tahu data berubah dan harus reload
                          Navigator.pop(context, true); 
                        }
                      },
                      child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isIdFetched) {
      final customerId = ModalRoute.of(context)!.settings.arguments as int;
      fetchDetailAndServices(customerId);
      isIdFetched = true;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7DD3FC), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 26),
                      // Mengirim sinyal kembali ke halaman utama (list) sambil membawa info apakah ada perubahan data
                      onPressed: () => Navigator.pop(context, true), 
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48.0),
                        child: Text(
                          "Detail Customer",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : customerData == null
                        ? const Center(child: Text("Customer tidak ditemukan"))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const CircleAvatar(
                                        radius: 42,
                                        backgroundColor: Color(0xFFE5E7EB),
                                        child: Icon(Icons.person, size: 54, color: Color(0xFF9CA3AF)),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        customerData!["customer_number"] ?? "-",
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        customerData!["name"] ?? "-",
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Pelanggan Sejak 01 Mei 2024",
                                        style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                const Text("Informasi Akun", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                const SizedBox(height: 12),
                                buildInfoRow("Username", customerData!["username"] ?? "-"),
                                buildInfoRow("Nomor Pelanggan (NIK)", customerData!["nik"] ?? customerData!["customer_number"] ?? "-"),
                                buildInfoRow("Nomor HP", customerData!["phone"] ?? "-"),
                                buildInfoRow("Alamat", customerData!["address"] ?? "-"),
                                const SizedBox(height: 24),
                                const Text("Layanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(color: const Color(0xFF1097DB), borderRadius: BorderRadius.circular(24)),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/PDAMappLogo.png',
                                        height: 56,
                                        width: 56,
                                        errorBuilder: (c, e, s) => const Icon(Icons.water_drop, size: 44, color: Colors.white),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customerData!["service"]?["name"] ?? "Rumah Tangga A",
                                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
                                            ),
                                            const SizedBox(height: 2),
                                            Text("Min 0 m³ | Maks 10 m³", style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                                            Text("Rp ${customerData!["service"]?["price"] ?? "2.000"} / m³", style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 36),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0D6EFD),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        onPressed: () async {
                                          bool? isUpdated = await Navigator.pushNamed(
                                            context,
                                            '/admin/customers/edit',
                                            arguments: {
                                              'existing': customerData,
                                              'services': allServices,
                                            },
                                          ) as bool?;

                                          if (isUpdated == true) {
                                            fetchDetailAndServices(customerData!["id"]);
                                          }
                                        },
                                        child: const Text("Edit Customer", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFBA1A1A),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        onPressed: () => confirmDelete(
                                          customerData!["id"],
                                          customerData!["name"] ?? "",
                                          customerData!["customer_number"] ?? "",
                                        ),
                                        child: const Text("Hapus Customer", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}