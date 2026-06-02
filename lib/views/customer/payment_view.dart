import 'package:flutter/material.dart';
import 'package:pdam_app/services/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdam_app/views/customer/payment_detail_view.dart';
import 'package:pdam_app/widgets/bottom_nav.dart';

class CustomerPaymentView extends StatefulWidget {
  const CustomerPaymentView({super.key});

  @override
  State<CustomerPaymentView> createState() => _CustomerPaymentViewState();
}

class _CustomerPaymentViewState extends State<CustomerPaymentView> {
  final PaymentService _paymentApi = PaymentService();
  List _payments = [];
  List<int> _localRejectedBillIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);

    try {
      // <-- 3. Ambil daftar ID tagihan yang ditolak dari penyimpanan lokal HP
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList('rejected_bill_ids');
      if (savedIds != null) {
        _localRejectedBillIds = savedIds
            .map((id) => int.tryParse(id) ?? 0)
            .toList();
      }

      // 4. Ambil data pembayaran dari API
      final result = await _paymentApi.showAllByCustomer(quantity: 100);

      setState(() {
        _payments = result.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "Rp 0";
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}";
  }

  String _getMonthName(dynamic m) {
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

  String _formatDate(String? iso) {
    if (iso == null) return "-";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day} ${_getMonthName(dt.month)} ${dt.year} . ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
            child: const Text(
              "Pembayaran",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F2E4B),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada riwayat transaksi",
                      style: TextStyle(color: Color(0xFF0F2E4B)),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPayments,
                    child: ListView.builder(
                      itemCount: _payments.length,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemBuilder: (context, index) {
                        final p = _payments[index];
                        final bill = p["bill"] ?? {};
                        final int billId = bill["id"] ?? 0;
                        final v = p["verified"];

                        bool isSuccess = (v == 1 || v == true || v == "1");
                        bool isFail =
                            (v == -1 ||
                            v == "-1" ||
                            p["status"] == "rejected" ||
                            p["status"] == "failed" ||
                            _localRejectedBillIds.contains(billId));

                        // DI SINI LOGICNYA: Mengubah tulisan "Gagal" menjadi "Ditolak" agar sinkron dengan CustomerBillView Anda
                        String statusText = isSuccess
                            ? "Berhasil"
                            : (isFail ? "Ditolak" : "Diproses");
                        
                        Color statusColor = isSuccess
                            ? const Color(0xFF2E7D32)
                            : (isFail
                                  ? const Color(0xFFFF3333)
                                  : const Color(0xFFFFC107));
                                  
                        IconData statusIcon = isSuccess
                            ? Icons.check_circle
                            : (isFail ? Icons.cancel : Icons.timelapse);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () async {
                              // 1. Tambahkan 'await' agar Flutter menunggu sampai user selesai dari halaman detail
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CustomerPaymentDetailView(payment: p),
                                ),
                              );

                              // 2. Begitu user kembali ke halaman ini, otomatis tarik data ulang dari API secara real-time
                              _loadPayments();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${_getMonthName(bill["month"])} ${bill["year"] ?? '-'}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF0F2E4B),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            statusIcon,
                                            color: statusColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bill["no_bill"] ??
                                        bill["invoice_number"] ??
                                        "INV/XXXX/XX/XXX",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(
                                      p["createdAt"] ?? p["created_at"],
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _formatCurrency(
                                      p["total_amount"] ?? bill["total_amount"],
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F2E4B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(2),
    );
  }
}