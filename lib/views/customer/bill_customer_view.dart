import 'package:flutter/material.dart';
import 'package:pdam_app/services/bill_service.dart';
import 'package:pdam_app/services/payment_service.dart';
import 'package:pdam_app/views/customer/upload_payment_view.dart';
import 'package:pdam_app/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerBillView extends StatefulWidget {
  const CustomerBillView({super.key});

  @override
  State<CustomerBillView> createState() => _CustomerBillViewState();
}

class _CustomerBillViewState extends State<CustomerBillView> {
  final BillService _billApi = BillService();
  List _bills = [];
  List<int> _localRejectedBillIds = [];
  bool _isLoading = true;
  String _searchQuery = "";
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    try {
      // Ambil daftar ID tagihan yang ditolak dari penyimpanan lokal HP
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList('rejected_bill_ids');
      if (savedIds != null) {
        _localRejectedBillIds = savedIds.map((id) => int.tryParse(id) ?? 0).toList();
      }

      final result = await _billApi.showAllByCustomer(quantity: 500);
      setState(() {
        _bills = result.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List get _filteredBills {
    List list = _bills;

    if (_searchQuery.isNotEmpty) {
      list = list.where((b) {
        String invoiceNumber = "INV/${b["year"] ?? ''}/${(b["month"] ?? '').toString().padLeft(2, '0')}/${b["id"] ?? ''}".toLowerCase();
        String altBillNum = (b["no_bill"] ?? b["invoice_number"] ?? "").toString().toLowerCase();

        final query = _searchQuery.toLowerCase();
        return invoiceNumber.contains(query) || altBillNum.contains(query);
      }).toList();
    }
    return list;
  }

  String _determineStatus(Map b) {
    final int billId = b["id"] ?? 0;

    if (_localRejectedBillIds.contains(billId)) {
      return "DITOLAK (BAYAR ULANG)";
    }

    var paymentData = b["payments"] ?? b["payment"];
    
    if (paymentData is List && paymentData.isNotEmpty) {
      var latestPayment = paymentData.first; 
      try {
        for (var p in paymentData) {
          final currentId = int.tryParse(p["id"].toString()) ?? 0;
          final latestId = int.tryParse(latestPayment["id"].toString()) ?? 0;
          if (currentId > latestId) {
            latestPayment = p;
          }
        }
      } catch (_) {
        latestPayment = paymentData.last; 
      }
      
      final vLatest = latestPayment["verified"];
      final statusLatest = latestPayment["status"];
      
      if (vLatest == -1 || vLatest == "-1" || statusLatest == "rejected") {
        return "DITOLAK (BAYAR ULANG)";
      }
      
      if (vLatest == 1 || vLatest == true || vLatest == "1" || statusLatest == "verified") {
        return "LUNAS";
      }
      
      return "MENUNGGU KONFIRMASI";
      
    } else if (paymentData is Map) {
      final v = paymentData["verified"];
      final status = paymentData["status"];
      if (v == -1 || v == "-1" || status == "rejected") return "DITOLAK (BAYAR ULANG)";
      if (v == 1 || v == true || v == "1" || status == "verified") return "LUNAS";
      return "MENUNGGU KONFIRMASI";
    }

    // Fallback terbawah (Hanya berjalan jika tidak terdaftar di lokal HP dan payment kosong)
    if (b["paid"] == true || b["paid"] == 1 || b["status"] == "paid") {
      return "LUNAS";
    }
    
    return "BELUM DIBAYAR";
  }
  Color _statusTextColor(String s) {
    switch (s) {
      case "BELUM DIBAYAR": return Colors.white;
      case "DITOLAK (BAYAR ULANG)": return Colors.white; // Tambahan pewarnaan teks penolakan
      case "MENUNGGU KONFIRMASI": return Colors.white;
      case "LUNAS": return const Color(0xFF0F60D6);
      default: return Colors.black;
    }
  }

  Color _statusBgColor(String s) {
    switch (s) {
      case "BELUM DIBAYAR": return const Color(0xFFFF3333);
      case "DITOLAK (BAYAR ULANG)": return const Color(0xFFC62828); // Warna merah tua untuk penolakan
      case "MENUNGGU KONFIRMASI": return const Color(0xFFFFC107);
      case "LUNAS": return const Color(0xFFD2E5F5);
      default: return Colors.grey;
    }
  }

  String _getMonthName(dynamic m) {
    int month = int.tryParse(m.toString()) ?? 1;
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return month >= 1 && month <= 12 ? months[month] : '$month';
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "Rp 0";
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  void _showReceiptPhoto(String fileName) {
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
    final filtered = _filteredBills;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF53B9ED), Color(0xFF6DC3EE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tagihan",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B)),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                    },
                    decoration: const InputDecoration(
                      hintText: "Cari nomor tagihan / invoice..",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text("Tidak ada tagihan yang cocok", style: TextStyle(color: Color(0xFF0F2E4B))))
                    : RefreshIndicator(
                        onRefresh: _loadBills,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemBuilder: (context, index) {
                            final b = filtered[index];
                            final status = _determineStatus(b);
                            
                            var payment = b["payments"] ?? b["payment"];
                            if (payment is List && payment.isNotEmpty) payment = payment.first;
                            final proof = payment?["file"] ?? payment?["payment_proof"];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${_getMonthName(b["month"])} ${b["year"] ?? ''}",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade700),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusBgColor(status),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(color: _statusTextColor(status), fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("INVOICE", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                        "INV/${b["year"] ?? ''}/${(b["month"] ?? '').toString().padLeft(2, '0')}/${b["id"] ?? ''}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B), fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Divider(color: Colors.black12, height: 1),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Total Tagihan", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatCurrency(b["total_amount"] ?? b["amount"]),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF0F2E4B)),
                                          ),
                                        ],
                                      ),
                                      _buildActionButton(b, status, proof),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(1),
    );
  }

  Widget _buildActionButton(Map bill, String status, String? paymentProof) {
    // DI SINI LOGICNYA: Jika BELUM DIBAYAR atau DITOLAK (BAYAR ULANG), munculkan tombol bayar
    if (status == "BELUM DIBAYAR" || status == "DITOLAK (BAYAR ULANG)") {
      return ElevatedButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerCreatePaymentView(bill: bill)));
          _loadBills();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F60D6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          elevation: 0,
        ),
        child: Text(
          status == "DITOLAK (BAYAR ULANG)" ? "Bayar Ulang" : "Bayar Sekarang", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: paymentProof != null ? () => _showReceiptPhoto(paymentProof) : null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF0F2E4B), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: const Text(
          "Lihat Bukti Pembayaran",
          style: TextStyle(color: Color(0xFF0F2E4B), fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }
  }
}