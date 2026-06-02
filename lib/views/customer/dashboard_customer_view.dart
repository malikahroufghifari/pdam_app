import 'package:flutter/material.dart';
import 'package:pdam_app/models/user_login.dart';
import 'package:pdam_app/services/bill_service.dart';
import 'package:pdam_app/views/customer/bannerTips_view.dart';
import 'package:pdam_app/views/customer/bantuan_view.dart';
import 'package:pdam_app/views/customer/bill_customer_view.dart';
import 'package:pdam_app/views/customer/payment_view.dart';
import 'package:pdam_app/views/customer/upload_payment_view.dart';
import 'package:pdam_app/widgets/bottom_nav.dart';

class DashboardCustomerView extends StatefulWidget {
  const DashboardCustomerView({super.key});

  @override
  State<DashboardCustomerView> createState() => _DashboardCustomerViewState();
}

class _DashboardCustomerViewState extends State<DashboardCustomerView> {
  String? name;
  String? username;
  int belumDibayar = 0;
  List<dynamic> listBill = [];
  bool isLoading = true;
  dynamic singleUnpaidBill;
  double totalTagihan = 0.0;
  String jatuhTempo = "-";
  String customerId = "-";

  Future<void> loadData() async {
    var user = await UserLogin().getUserLogin();
    setState(() {
      name = user.name;
      username = user.username;
      if (user.id != null) {
        customerId = "CUST-${user.id.toString().padLeft(4, '0')}";
      }
    });

    var response = await BillService().showAllByCustomer(page: 1, quantity: 12);

    int unPaidCount = 0;
    List<dynamic> tempBill = [];
    double accumulatedUnpaidAmount = 0.0; // Ganti penampung nilai di sini
    String currentDueDate = "-";

    if (response.data != null && response.data is List) {
      tempBill = response.data;
      
      dynamic foundUnpaid; 
      for (var b in response.data) {
        // Cek status paid (berupa boolean true/false dari API Anda)
        var isPaid = b["paid"];
        if (isPaid == false || isPaid == 0 || isPaid.toString() == "0") {
          unPaidCount++;
          foundUnpaid = b; 
          
          // PERBAIKAN DI SINI: Menggunakan kata 'amount', bukan 'total_amount'
          double billAmount = double.tryParse(b['amount'].toString()) ?? 0.0;
          accumulatedUnpaidAmount += billAmount;
        }
      }
      
      if (foundUnpaid != null) {
        if (foundUnpaid['due_date'] != null) {
          currentDueDate = foundUnpaid['due_date'].toString();
        } else if (foundUnpaid['month'] != null) {
          currentDueDate =
              "20 ${_convertMonthFull(foundUnpaid['month'])} ${foundUnpaid['year'] ?? DateTime.now().year}";
        }
      } else if (tempBill.isNotEmpty) {
        var latestBill = tempBill.first;
        if (latestBill['due_date'] != null) {
          currentDueDate = latestBill['due_date'].toString();
        } else if (latestBill['month'] != null) {
          currentDueDate =
              "20 ${_convertMonthFull(latestBill['month'])} ${latestBill['year'] ?? DateTime.now().year}";
        }
      }

      setState(() {
        singleUnpaidBill = foundUnpaid;
      });
    }
    setState(() {
      listBill = tempBill;
      belumDibayar = unPaidCount;
      totalTagihan =
          accumulatedUnpaidAmount; // Sekarang berisi total akumulasi tagihan belum lunas
      jatuhTempo = currentDueDate;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  String _convertMonth(dynamic monthNum) {
    int month = int.tryParse(monthNum.toString()) ?? 1;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return "$month";
  }

  String _convertMonthFull(dynamic monthNum) {
    int month = int.tryParse(monthNum.toString()) ?? 1;
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return "$month";
  }

  double _maxOf(double a, double b) => a > b ? a : b;

  String _formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}";
  }

  // ── BAGIAN ATAS: fixed, tidak ikut scroll ──────────────────────────────────
  Widget _buildFixedHeader() {
    final greeting = (name != null && name!.trim().isNotEmpty)
        ? name!
        : (username != null && username!.trim().isNotEmpty)
        ? username!
        : 'Pelanggan';

    return Container(
      // Background biru memenuhi seluruh area header + card
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salam + Logout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Halo,",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID Pelanggan: $customerId",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await UserLogin().logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Card Tagihan Bulan Ini
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tagihan Bulan Ini",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: belumDibayar > 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        belumDibayar > 0 ? "BELUM DIBAYAR" : "LUNAS",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatRupiah(totalTagihan),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Jatuh Tempo",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  jatuhTempo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    // UBAH BAGIAN ONPRESSED INI
                    onPressed: belumDibayar == 0
                        ? null // Tombol mati jika tidak ada tagihan
                        : () {
                            if (belumDibayar > 1) {
                              // Jika tagihan lebih dari satu, ke halaman CustomerBillView
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CustomerBillView(),
                                ),
                              );
                            } else if (belumDibayar == 1 &&
                                singleUnpaidBill != null) {
                              // Jika tagihan hanya satu, ke halaman CustomerCreatePaymentView membawa objek bill
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerCreatePaymentView(
                                    bill: singleUnpaidBill,
                                  ),
                                ),
                              );
                            }
                          },
                    child: const Text(
                      "Bayar Sekarang",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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

  // ── GRAFIK BATANG ───────────────────────────────────────────────────────────
  Widget _buildChart(List<dynamic> bills) {
    if (bills.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          "Belum ada data penggunaan air.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    List<dynamic> displayBills = bills.reversed.toList();
    if (displayBills.length > 6) {
      displayBills = displayBills.sublist(displayBills.length - 6);
    }

    double maxUsage = displayBills
        .map((e) => double.tryParse(e['usage_value'].toString()) ?? 0.0)
        .fold(1.0, (prev, elem) => elem > prev ? elem : prev);

    int lastIndex = displayBills.length - 1;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(displayBills.length, (i) {
                var bill = displayBills[i];
                double usage =
                    double.tryParse(bill['usage_value'].toString()) ?? 0.0;
                double barRatio = usage / _maxOf(maxUsage, 1.0);
                bool isLastMonth = (i == lastIndex);
                bool isUnpaid = bill['paid'] == false;

                Color barColor = isLastMonth
                    ? const Color(0xFF1E3A8A)
                    : (isUnpaid
                          ? const Color(0xFFFF5252)
                          : const Color(0xFF90CAF9));

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 80),
                          curve: Curves.easeOut,
                          width: double.infinity,
                          height: (120 * barRatio).clamp(8.0, 120.0),
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(displayBills.length, (i) {
              bool isLastMonth = (i == lastIndex);
              return Expanded(
                child: Center(
                  child: Text(
                    _convertMonth(displayBills[i]['month']),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isLastMonth
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isLastMonth
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── BANNER TIPS HEMAT AIR ────────────────────────────────────────────────
  Widget _buildBannerTips() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BannerTipsView()),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 140,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: gambar background penuh
              Image.asset('assets/backgroundTetes.png', fit: BoxFit.cover),
              // Layer 2: overlay gradient tipis supaya teks terbaca
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFBAE6FD).withOpacity(0.85),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              // Layer 3: teks + tombol di atas gambar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 120, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hemat Air, Hemat Biaya",
                          style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tips bijak gunakan air di musim\nkemarau",
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    // Tombol Selengkapnya
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                      ),
                      child: const Text(
                        "Selengkapnya",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── QUICK SERVICE BUTTON ────────────────────────────────────────────────
  Widget _buildQuickServiceButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: const Color(0xFF1E3A8A)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // ── FIXED: header biru + card tagihan ──
                  _buildFixedHeader(),

                  // ── SCROLLABLE: grafik ke bawah ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Grafik
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Tagihan Perbulan",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                belumDibayar > 0
                                    ? "$belumDibayar Belum Lunas"
                                    : "6 Bulan Terakhir",
                                style: TextStyle(
                                  color: belumDibayar > 0
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF3B82F6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Grafik Batang
                          _buildChart(listBill),
                          const SizedBox(height: 28),

                          // Layanan Cepat
                          const Text(
                            "Layanan Cepat",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQuickServiceButton(
                                Icons.receipt_long_outlined,
                                "Tagihan",
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CustomerBillView(),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickServiceButton(
                                Icons.credit_card_outlined,
                                "Pembayaran",
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CustomerPaymentView(),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickServiceButton(
                                Icons.help_outline_rounded,
                                "Bantuan",
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CallAdminView(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Banner Tips Hemat Air
                          _buildBannerTips(),
                          const SizedBox(height: 20),
                        ],
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
