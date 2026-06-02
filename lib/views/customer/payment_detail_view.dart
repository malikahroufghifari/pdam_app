import 'package:flutter/material.dart';
import 'package:pdam_app/services/payment_service.dart';

class CustomerPaymentDetailView extends StatelessWidget {
  final Map payment;
  const CustomerPaymentDetailView({super.key, required this.payment});

  String _getMonthName(dynamic m) {
    int month = int.tryParse(m.toString()) ?? 1;
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return (month >= 1 && month <= 12) ? months[month] : '$month';
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "Rp 0";
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}";
  }

  String _formatDate(String? iso) {
    if (iso == null) return "-";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso.toString();
    }
  }

  void _showReceiptPhoto(BuildContext context, String fileName) {
    final fullUrl = PaymentService.getPaymentProofUrl(fileName);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 24, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text("Gagal memuat gambar bukti transfer", style: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3333),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bill = payment["bill"] ?? {};
    final customer = bill["customer"] ?? payment["customer"] ?? {};
    final admin = payment["admin"] ?? {};
    
    final v = payment["verified"];
    bool isSuccess = (v == 1 || v == true || v == "1");
    bool isFail = (v == -1 || v == "-1" || payment["status"] == "rejected");
    
    String statusText = isSuccess ? "Sukses" : (isFail ? "Gagal" : "Menunggu Konfirmasi");
    Color statusTextColor = isSuccess ? const Color(0xFF2EA365) : (isFail ? const Color(0xFFFF3333) : const Color(0xFFFFC107));

    final String? proofFile = payment["file"] ?? payment["payment_proof"];

    return Scaffold(
      backgroundColor: const Color(0xFF53B9ED), // Menggunakan warna dasar biru agar seirama dengan header
      body: Column(
        children: [
          // HEADER: Tetap flat/kotak di bagian bawahnya
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF53B9ED), Color(0xFF6DC3EE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 52, 24, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2E4B), size: 26),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                const Text(
                  "Detail Pembayaran",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B)),
                ),
              ],
            ),
          ),
          
          // BODY KONTEN: Di sinilah letak lengkungan putihnya
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7FAFD), // Latar belakang abu-abu terang untuk area list
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36), // Melengkung ke dalam di sudut kiri atas
                  topRight: Radius.circular(36), // Melengkung ke dalam di sudut kanan atas
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                children: [
                  // CARD 1: Info Pembayaran
                  _buildCardSection(
                    icon: Icons.credit_card,
                    title: "Info Pembayaran",
                    children: [
                      _rowDetail("ID Pembayaran", "${payment["id"] ?? '-'}"),
                      _rowDetail("Tanggal Bayar", _formatDate(payment["createdAt"] ?? payment["created_at"])),
                      _rowDetail("Total Dibayar", _formatCurrency(payment["total_amount"] ?? bill["total_amount"])),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Status Verifikasi", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                            Text(
                              statusText,
                              style: TextStyle(color: statusTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (proofFile != null) ...[
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => _showReceiptPhoto(context, proofFile),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0F2E4B), width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.image_outlined, color: Color(0xFF0F2E4B), size: 18),
                          label: const Text("Foto Bukti Transfer", style: TextStyle(color: Color(0xFF0F2E4B), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 2: Detail Tagihan
                  _buildCardSection(
                    icon: Icons.assignment_outlined,
                    title: "Detail Tagihan",
                    children: [
                      _rowDetail("ID Tagihan", "#${bill["id"] ?? '-'}"),
                      _rowDetail("Periode", "${_getMonthName(bill["month"])} ${bill["year"] ?? ''}"),
                      _rowDetail("No Meteran", "${customer["meter_number"] ?? '-'}"),
                      _rowDetail("Pemakaian", "${bill["usage_value"] ?? '0'} m³"),
                      _rowDetail("Tarif per m³", _formatCurrency(bill["rate_per_meter"] ?? bill["rate"])),
                      _rowDetail("Layanan", "${bill["service_type"] ?? 'Layanan Tetap'}"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 3: Data Customer
                  _buildCardSection(
                    icon: Icons.people_outline,
                    title: "Data Customer",
                    children: [
                      _rowDetail("Nama", "${customer["name"] ?? '-'}"),
                      _rowDetail("No. Pelanggan", "${customer["customer_number"] ?? '-'}"),
                      _rowDetail("Telepon", "${customer["phone"] ?? '-'}"),
                      _rowDetail("Alamat", "${customer["address"] ?? '-'}"),
                    ],
                  ),
                  
                  // CARD 4: Data Admin Verifikator
                  if ((isSuccess || isFail) && admin.isNotEmpty && admin["name"] != null) ...[
                    const SizedBox(height: 16),
                    _buildCardSection(
                      icon: Icons.verified_user_outlined,
                      title: "Diverifikasi Oleh",
                      children: [
                        _rowDetail("Nama Admin", "${admin["name"]}"),
                        if (admin["phone"] != null) _rowDetail("Telepon", "${admin["phone"]}"),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0F2E4B), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F2E4B))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.black12, height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _rowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F2E4B)),
            ),
          ),
        ],
      ),
    );
  }
}