import 'package:flutter/material.dart';
import 'package:pdam_app/services/url.dart' as url;

class BillDetailScreen extends StatelessWidget {
  final Map bill;
  final String status;
  final Function(int billId, int? paymentId) onReject;
  final Function(int? paymentId) onVerify;

  const BillDetailScreen({
    super.key,
    required this.bill,
    required this.status,
    required this.onReject,
    required this.onVerify,
  });

  String getMonthName(dynamic m) {
    int month = int.tryParse(m.toString()) ?? 1;
    const months = [
      '',
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
    return month >= 1 && month <= 12 ? months[month] : '$month';
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return "Rp 0";
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  void _showReceiptPhoto(BuildContext context, String? paymentProof) {
    final String fullImageUrl = "${url.BaseUrl}/payment-proof/$paymentProof";

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text(
                  "Bukti Pembayaran",
                  style: TextStyle(
                    color: Color(0xFF0F2E4B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const Divider(),
              if (paymentProof != null && paymentProof.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fullImageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text("Berkas bukti rusak atau tidak ditemukan"),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(
                  height: 200,
                  child: Center(child: Text("Bukti tidak diunggah")),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var paymentData = bill["payments"] ?? bill["payment"];
    dynamic payment;

    if (paymentData is List && paymentData.isNotEmpty) {
      // PERBAIKAN: Cari transaksi yang paling baru berdasarkan ID terbesar
      payment = paymentData.first;
      try {
        for (var p in paymentData) {
          final currentId = int.tryParse(p["id"].toString()) ?? 0;
          final latestId = int.tryParse(payment["id"].toString()) ?? 0;
          if (currentId > latestId) {
            payment = p;
          }
        }
      } catch (_) {
        payment = paymentData.last;
      }
    } else if (paymentData is Map) {
      payment = paymentData;
    }

    var customer = bill["customer"] ?? {};
    var service = bill["service"] ?? {};
    var admin = bill["admin"] ?? {};
    var finalPrice = bill["amount"] ?? bill["price"] ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FD),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF63B8FF), Color(0xFFF4F9FD)],
            stops: [0.0, 0.25],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF0F2E4B),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "INV-${bill["year"] ?? ''}${bill["month"] ?? ''}-${bill["id"] ?? ''}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    "Detail Tagihan\nPelanggan",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Color(0xFF0F2E4B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  children: [
                    // CARD 1: Detail Tagihan
                    _buildCard("Detail Tagihan", Icons.receipt_long_outlined, [
                      _row("ID Tagihan", "#${bill["id"] ?? '-'}"),
                      _row(
                        "Periode",
                        "${getMonthName(bill["month"])} ${bill["year"] ?? ''}",
                      ),
                      _row(
                        "No Meteran",
                        bill["measurement_number"]?.toString() ?? "-",
                      ),
                      _row("Pemakaian", "${bill["usage_value"] ?? 0} m³"),
                      _row(
                        "Tarif per m³",
                        formatCurrency(service["price"] ?? bill["price"]),
                      ),
                      _row("Layanan", service["name"] ?? "Layanan Tetap"),
                      _row(
                        "Status Bayar",
                        bill["paid"] == true || bill["paid"] == 1
                            ? "Sukses"
                            : "Belum Lunas",
                      ),
                    ]),

                    // CARD 2: Data Customer
                    _buildCard("Data Customer", Icons.person_outline, [
                      _row("Nama", customer["name"] ?? "-"),
                      _row("No. Pelanggan", customer["customer_number"] ?? "-"),
                      _row("Telepon", customer["phone"] ?? "-"),
                      _row("Alamat", customer["address"] ?? "-"),
                    ]),

                    // CARD 3: Dibuat Oleh (BERDIRI SENDIRI SEPERTI DI DESAIN GAMBAR)
                    _buildCard("Dibuat Oleh", Icons.gpp_good_outlined, [
                      _row("Nama Admin", admin["name"] ?? "-"),
                      _row("Telepon", admin["phone"] ?? "-"),
                    ]),

                    // CARD 4: Data Pembayaran
                    if (payment != null)
                      _buildCard("Data Pembayaran", Icons.payment_outlined, [
                        _row("ID Pembayaran", "${payment["id"] ?? '-'}"),
                        _row(
                          "Tanggal Bayar",
                          payment["payment_date"]?.toString().substring(
                                0,
                                10,
                              ) ??
                              "-",
                        ),
                        _row("Total Dibayar", formatCurrency(finalPrice)),
                        _row(
                          "Status Verifikasi",
                          payment["verified"] == true
                              ? "Terverifikasi"
                              : "Belum Dikonfirmasi",
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 58,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 12),
                          child: OutlinedButton.icon(
                            onPressed: () => _showReceiptPhoto(
                              context,
                              payment["payment_proof"],
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color(0xFF0F2E4B),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF0F2E4B),
                              size: 22,
                            ),
                            label: const Text(
                              "Foto Bukti Transfer",
                              style: TextStyle(
                                color: Color(0xFF0F2E4B),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
            _buildBottomAction(context, payment),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, dynamic payment) {
    if (status == "Menunggu Konfirmasi") {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFE53935),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => onReject(bill["id"], payment?["id"]),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFFE53935),
                      size: 20,
                    ),
                    label: const Text(
                      "Tolak",
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A4778),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => onVerify(payment?["id"]),
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      "Verifikasi",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCard(
    String title,
    IconData icon,
    List<Widget> children, {
    double? height,
  }) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0F2E4B)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F2E4B),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: value == "Sukses" || value == "Terverifikasi"
                    ? const Color(0xFF2E7D32)
                    : (value == "Belum Lunas" || value == "Belum Dikonfirmasi"
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF0F2E4B)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}