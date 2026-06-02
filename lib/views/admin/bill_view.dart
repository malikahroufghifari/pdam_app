import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdam_app/services/bill_service.dart';
import 'package:pdam_app/services/customer_service.dart';
import 'package:pdam_app/views/admin/bill_detail_view.dart';
import 'package:pdam_app/views/admin/bill_edit_view.dart';
import 'package:pdam_app/widgets/alert.dart';
import 'package:pdam_app/widgets/bottom_nav.dart';

class BillView extends StatefulWidget {
  final dynamic arguments; 
  const BillView({super.key, this.arguments});

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView> {
  final BillService billApi = BillService();
  final CustomerService customerApi = CustomerService();

  List bills = [];
  List customers = [];
  bool isLoading = true;
  int selectedTab = 0;
  String searchQuery = "";

  List<int> localRejectedBillIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      print("Argumen yang diterima: ${widget.arguments}");
      // Anda bisa melakukan sesuatu dengan argumen ini di sini
    }
    
    _initLocalDataAndLoad();
  }

  Future<void> _initLocalDataAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedIds = prefs.getStringList('rejected_bill_ids');
    if (savedIds != null) {
      localRejectedBillIds = savedIds.map((id) => int.parse(id)).toList();
    }
    await loadData();
  }

  Future<void> _persistRejectedId(int billId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!localRejectedBillIds.contains(billId)) {
      localRejectedBillIds.add(billId);
      final List<String> stringIds = localRejectedBillIds.map((id) => id.toString()).toList();
      await prefs.setStringList('rejected_bill_ids', stringIds);
    }
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    var billResult = await billApi.showAllByAdmin(quantity: 100);
    var custResult = await customerApi.showAll();
    setState(() {
      bills = billResult.data ?? [];
      customers = custResult.data ?? [];
      isLoading = false;
    });
  }

  String _determineStatus(Map b) {
    if (localRejectedBillIds.contains(b["id"])) {
      return "Ditolak";
    }

    var payment = b["payments"] ?? b["payment"];
    if (payment is List && payment.isNotEmpty) {
      payment = payment.first;
    }

    if (payment != null) {
      var isVerified = payment["verified"];
      if (isVerified == 1 || isVerified == true || isVerified == "1") {
        return "Dikonfirmasi";
      }
      if (isVerified == -1 || isVerified == "-1" || payment["status"] == "rejected") {
        return "Ditolak";
      }
      return "Menunggu Konfirmasi";
    }

    if (b["paid"] == true || b["paid"] == 1 || b["paid"] == "1") {
      return "Dikonfirmasi";
    }

    return "Belum Dibayar";
  }

  List get filteredBills {
    List list = bills;

    if (searchQuery.isNotEmpty) {
      list = list.where((b) {
        var customer = b["customer"] ?? {};
        String name = (customer["name"] ?? "").toString().toLowerCase();
        return name.contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (selectedTab == 0) return list;
    if (selectedTab == 1) return list.where((b) => _determineStatus(b) == "Belum Dibayar").toList();
    if (selectedTab == 2) return list.where((b) => _determineStatus(b) == "Menunggu Konfirmasi").toList();
    if (selectedTab == 3) return list.where((b) => _determineStatus(b) == "Dikonfirmasi").toList();
    if (selectedTab == 4) return list.where((b) => _determineStatus(b) == "Ditolak").toList();
    return list;
  }

  String getMonthName(dynamic m) {
    int month = int.tryParse(m.toString()) ?? 1;
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return month >= 1 && month <= 12 ? months[month] : '$month';
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return "Rp 0";
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  void _showDetailBill(Map b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillDetailScreen(
          bill: b,
          status: _determineStatus(b),
          onReject: (billId, paymentId) => _openRejectReasonDialog(billId, paymentId),
          onVerify: (paymentId) => _handleVerify(paymentId),
        ),
      ),
    ).then((_) => loadData());
  }

  void _openRejectReasonDialog(int billId, int? paymentId) {
    final List<String> reasons = [
      "Nominal tidak sesuai",
      "Rekening tujuan tidak sesuai",
      "Nama pengirim tidak sesuai",
      "Bukti pembayaran tidak jelas",
      "Pembayaran ganda",
      "Lainnya",
    ];

    String selectedReason = reasons.first;
    final customReasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.only(left: 24, right: 16, top: 20, bottom: 10),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pilih Alasan Penolakan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B))),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...reasons.map((String reason) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: const Color(0xFFEBF3FC), borderRadius: BorderRadius.circular(12)),
                      child: RadioListTile<String>(
                        title: Text(reason, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F2E4B))),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: Colors.blue,
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (value) => setDialogState(() => selectedReason = value!),
                      ),
                    );
                  }),
                  if (selectedReason == "Lainnya") ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customReasonCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Tuliskan alasan spesifik lainnya...",
                        hintStyle: const TextStyle(fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF4F9FD),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          customReasonCtrl.dispose();
                          Navigator.pop(ctx);
                        },
                        child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC92A2A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          if (selectedReason == "Lainnya" && customReasonCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Alasan kustom tidak boleh kosong!")));
                            return;
                          }
                          if (paymentId == null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("ID Pembayaran tidak ditemukan!")));
                            return;
                          }

                          Navigator.pop(ctx);
                          customReasonCtrl.dispose();

                          dynamic result = await billApi.rejectPayment(paymentId);

                          if (mounted) {
                            AlertMessage().showAlert(context, result.message, result.status);
                            if (result.status) {
                              await _persistRejectedId(billId);
                              setState(() => selectedTab = 4);
                              loadData();
                            }
                          }
                        },
                        child: const Text("Tolak Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleVerify(int? paymentId) async {
    if (paymentId != null) {
      var result = await billApi.verifyPayment(paymentId);
      AlertMessage().showAlert(context, result.message, result.status);
      if (result.status) loadData();
    }
  }

  void confirmDelete(int id, String billName) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28), // Kelengkungan sudut dialog besar sesuai desain
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Dialog mengikuti tinggi konten didalamnya
          children: [
            // 1. IKON TEMPAT SAMPAH DENGAN LINGKARAN MERAH MUDA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE), // Warna merah muda transparan/soft
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded, // Menggunakan ikon outline tempat sampah
                color: Color(0xFFC62828),     // Merah tua solid
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            // 2. JUDUL: Hapus Layanan
            const Text(
              "Hapus Tagihan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 3. DESKRIPSI TEKS DENGAN NAMA LAYANAN DINAMIS
            Text(
              "Apakah Anda yakin ingin menghapus\ntagihan $billName",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 4. TOMBOL AKSI BERDAMPINGAN (BATAL & HAPUS)
            Row(
              children: [
                // TOMBOL BATAL (OUTLINE BUTTON)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
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
                const SizedBox(width: 16),
                
                // TOMBOL HAPUS (SOLID ELEVATED BUTTON)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828), // Merah gelap pekat sesuai UI
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      var result = await billApi.drop(id);
                      AlertMessage().showAlert(context, result.message, result.status);
                      if (result.status) loadData();
                    },
                    child: const Text(
                      "Hapus",
                      style: TextStyle(
                        color: Colors.white,
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
  );
}

  void _showForm([Map? existing]) {
    if (existing != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditBillPage(
            existing: existing,
            billApi: billApi,
            onSuccess: () => loadData(),
          ),
        ),
      );
    } else {
      final monthCtrl = TextEditingController();
      final yearCtrl = TextEditingController();
      final measurementCtrl = TextEditingController();
      final usageCtrl = TextEditingController();
      String? selectedCustomerId;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Buat Tagihan Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B))),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCustomerId,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF4F9FD),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: "Pilih Customer",
                      ),
                      items: customers.map((c) => DropdownMenuItem<String>(value: c["id"].toString(), child: Text(c["name"] ?? ""))).toList(),
                      onChanged: (val) => setSheetState(() => selectedCustomerId = val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: monthCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Bulan",
                              filled: true,
                              fillColor: const Color(0xFFF4F9FD),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: yearCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Tahun",
                              filled: true,
                              fillColor: const Color(0xFFF4F9FD),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: measurementCtrl,
                      decoration: InputDecoration(
                        labelText: "Nomor Meteran",
                        filled: true,
                        fillColor: const Color(0xFFF4F9FD),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Besar Pemakaian (m³)",
                        filled: true,
                        fillColor: const Color(0xFFF4F9FD),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFF0056C6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        var data = {
                          "customer_id": selectedCustomerId,
                          "month": monthCtrl.text,
                          "year": yearCtrl.text,
                          "measurement_number": measurementCtrl.text,
                          "usage_value": usageCtrl.text,
                        };
                        dynamic result = await billApi.create(data);
                        AlertMessage().showAlert(context, result.message, result.status);
                        if (result.status) loadData();
                      },
                      child: const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case "Belum Dibayar": return const Color(0xFFD32F2F);
      case "Menunggu Konfirmasi": return const Color(0xFFE65100);
      case "Dikonfirmasi": return const Color(0xFF2E7D32);
      case "Ditolak": return const Color(0xFFC62828);
      default: return Colors.grey.shade800;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case "Belum Dibayar": return const Color(0xFFFFEBEE);
      case "Menunggu Konfirmasi": return const Color(0xFFFFF3E0);
      case "Dikonfirmasi": return const Color(0xFFE8F5E9);
      case "Ditolak": return const Color(0xFFFFEBEE);
      default: return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FD),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2E4B))))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF63B8FF), Color(0xFFF4F9FD)],
                  stops: [0.0, 0.25],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60, left: 24, right: 16, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tagihan", style: TextStyle(color: Color(0xFF0F2E4B), fontSize: 26, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0F2E4B), size: 28),
                          onPressed: () => _showForm(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 12),
                            child: TextField(
                              onChanged: (val) => setState(() => searchQuery = val),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                hintText: "Cari Pelanggan..",
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                _tabBtn("Semua (${bills.length})", 0),
                                _tabBtn("Belum Dibayar (${bills.where((b) => _determineStatus(b) == "Belum Dibayar").length})", 1),
                                _tabBtn("Menunggu (${bills.where((b) => _determineStatus(b) == "Menunggu Konfirmasi").length})", 2),
                                _tabBtn("Dikonfirmasi (${bills.where((b) => _determineStatus(b) == "Dikonfirmasi").length})", 3),
                                _tabBtn("Ditolak (${bills.where((b) => _determineStatus(b) == "Ditolak").length})", 4),
                              ],
                            ),
                          ),
                          Expanded(
                            child: filteredBills.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.receipt_long, size: 55, color: Colors.grey[300]),
                                        const SizedBox(height: 8),
                                        Text("Tidak ada data tagihan", style: TextStyle(color: Colors.grey[500])),
                                      ],
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: loadData,
                                    color: const Color(0xFF0F2E4B),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      itemCount: filteredBills.length,
                                      itemBuilder: (ctx, i) {
                                        var b = filteredBills[i];
                                        String status = _determineStatus(b);
                                        var customer = b["customer"] ?? {};
                                        var finalPrice = b["amount"] ?? b["price"] ?? 0;

                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          PopupMenuButton<String>(
                                                            icon: const Icon(Icons.more_vert, color: Color(0xFF0F2E4B)),
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(),
                                                            onSelected: (val) {
                                                              if (val == 'edit') {
                                                                _showForm(b);
                                                              } else if (val == 'delete') {
                                                                confirmDelete(b["id"], b["billName"] ?? "ini");
                                                              }
                                                            },
                                                            itemBuilder: (ctx) => [
                                                              if (status == "Belum Dibayar")
                                                                const PopupMenuItem(value: 'edit', child: Row(children: [Text("Edit")])),
                                                              const PopupMenuItem(value: 'delete', child: Row(children: [Text("Hapus")])),
                                                            ],
                                                          ),
                                                          const SizedBox(width: 4),
                                                          const Icon(Icons.receipt_outlined, color: Colors.grey, size: 18),
                                                          const SizedBox(width: 6),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Text("INVOICE", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                                                Text(
                                                                  "INV/${b["year"]}/${b["month"]?.toString().padLeft(2, '0')}/${b["id"]}",
                                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B), fontSize: 13),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(color: _getStatusBgColor(status), borderRadius: BorderRadius.circular(20)),
                                                      child: Text(status, style: TextStyle(color: _getStatusTextColor(status), fontWeight: FontWeight.bold, fontSize: 11)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 14),
                                                InkWell(
                                                  onTap: () => _showDetailBill(b),
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.all(14),
                                                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Text("Pelanggan", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                                            Expanded(
                                                              child: Text(
                                                                customer["name"] ?? "Nama Customer",
                                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B)),
                                                                textAlign: TextAlign.end,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Text("Periode", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                                            Text("${getMonthName(b["month"])} ${b["year"]}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F2E4B))),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text("TOTAL TAGIHAN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                                        const SizedBox(height: 2),
                                                        Text(formatCurrency(finalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F2E4B))),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.arrow_forward, color: Color(0xFF0F2E4B)),
                                                      onPressed: () => _showDetailBill(b),
                                                    ),
                                                  ],
                                                ),
                                                Text("Pemakaian: ${b["usage_value"] ?? 0} m³", style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic)),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNav(3),
    );
  }

  Widget _tabBtn(String label, int index) {
    bool active = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF0F2E4B) : Colors.grey,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              decoration: active ? TextDecoration.underline : TextDecoration.none,
              decorationColor: const Color(0xFF0F2E4B),
              decorationThickness: 2,
            ),
          ),
        ),
      ),
    );
  }
}