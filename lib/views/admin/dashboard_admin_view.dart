import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/bill_service.dart';
import 'package:pdam_app/services/customer_service.dart';
import 'package:pdam_app/services/service_service.dart';
import 'package:pdam_app/services/payment_service.dart';
import 'package:pdam_app/widgets/bottom_nav.dart';

class DashboardAdminView extends StatefulWidget {
  const DashboardAdminView({super.key});
  @override
  State<DashboardAdminView> createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  String? name;
  String? role;
  String? username;
  int totalCustomer = 0,
      totalLayanan = 0,
      totalTagihan = 0,
      belumVerifikasi = 0;
  List<dynamic> recentPayments = [];
  bool isLoading = true;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> loadData() async {
    try {
      var user = await UserLogin().getUserLogin();
      setState(() {
        name = user.name;
        role = user.role;
        username = user.username;
      });

      // Melakukan pemanggilan 4 API sekaligus secara bersamaan (Paralel)
      final results = await Future.wait([
        CustomerService().showAll(),
        ServiceService().getAll(),
        PaymentService().showAllByAdmin(page: 1, quantity: 100),
        BillService().showAllByAdmin(page: 1, quantity: 1),
      ]);

      final customers = results[0];
      final services = results[1];
      final payments = results[2];
      final bills = results[3];

      int unverified = 0;
      List<dynamic> paymentList = [];

      if (payments.data != null) {
        paymentList = List<dynamic>.from(payments.data!);
        for (var p in paymentList) {
          if (p["verified"] == false || p["verified"] == null) unverified++;
        }
      }

      paymentList.sort((a, b) {
        final aId = int.tryParse(a["id"]?.toString() ?? "0") ?? 0;
        final bId = int.tryParse(b["id"]?.toString() ?? "0") ?? 0;
        return bId.compareTo(aId);
      });

      setState(() {
        totalCustomer = customers.count ?? 0;
        totalLayanan = services.count ?? 0;

        // Mengambil nilai total data riil dari database counter milik 'bills'
        totalTagihan = bills.count ?? 0;

        belumVerifikasi = unverified;
        recentPayments = paymentList.take(4).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Desain Card dibuat Expanded agar ukurannya konsisten
  Widget _buildStatCard(
    String label,
    int value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$value",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<dynamic, dynamic> payment) {
    final paymentId = payment["id"]?.toString() ?? "-";
    final bill = payment["bill"] as Map? ?? {};

    // Perluasan logika pencarian nilai nominal (antisipasi respon API)
    final rawAmount =
        payment["amount"] ??
        payment["total_amount"] ??
        payment["nominal"] ??
        bill["amount"] ??
        bill["total_amount"] ??
        bill["total"] ??
        0;

    final amount = num.tryParse(rawAmount.toString()) ?? 0;

    // Mengambil bill_id langsung dari data payment, jika tidak ada pakai payment id
    final billId = payment["bill_id"]?.toString() ?? paymentId;

    // Perbaikan Regex: Menambahkan ${m[3]} agar ID asli tidak terpotong
    final invoiceLabel =
        "INV-${billId.padLeft(9, '0').replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d{3})'), (m) => '${m[1]}-${m[2]}-${m[3]}')}";

    final rawDate =
        payment["createdAt"] ??
        payment["created_at"] ??
        payment["updatedAt"] ??
        "";
    String formattedDate = "-";
    try {
      final dt = DateTime.parse(rawDate.toString()).toLocal();
      formattedDate = DateFormat("dd MMM yyyy • HH:mm").format(dt);
    } catch (_) {}

    final isVerified = payment["verified"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/admin/bills'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                // Expanded agar teks invoice terdorong tanpa menabrak nominal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoiceLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Kolom Nominal dan Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0F4C75),
                      ),
                    ),
                    if (!isVerified) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Menunggu",
                          style: TextStyle(
                            color: Color(0xFFE11D48),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF88CEFE),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selamat datang, ${(name != null && name!.isNotEmpty)
                                    ? name
                                    : (username != null && username!.isNotEmpty)
                                    ? username
                                    : (role ?? 'ADMIN')}!",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Ringkasan sistem hari ini",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Baris Pertama Card
                              // Baris Pertama Card
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      "Total\nCustomer",
                                      totalCustomer,
                                      Icons.people,
                                      Colors.blue.shade700,
                                      Colors.blue.shade50,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      "Layanan\nAktif",
                                      totalLayanan,
                                      Icons.check_circle,
                                      Colors.green.shade700,
                                      Colors.green.shade50,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      "Total\nTagihan",
                                      totalTagihan, // Menggunakan variabel totalTagihan yang sudah diperbaiki
                                      Icons.receipt_long,
                                      Colors.blueGrey.shade700,
                                      Colors.blueGrey.shade50,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      "Belum\nDiverifikasi",
                                      belumVerifikasi,
                                      Icons.pending_actions,
                                      Colors.orange.shade700,
                                      Colors.orange.shade50,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Pembayaran Masuk Terbaru",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/admin/bills',
                                    ),
                                    child: Text(
                                      "Lihat semua",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              recentPayments.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Belum ada pembayaran masuk",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: recentPayments
                                          .map(
                                            (payment) => _buildPaymentItem(
                                              Map<dynamic, dynamic>.from(
                                                payment,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(0),
    );
  }
}
