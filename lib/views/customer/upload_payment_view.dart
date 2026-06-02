import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdam_app/services/payment_service.dart';
import 'package:pdam_app/widgets/alert.dart';

class CustomerCreatePaymentView extends StatefulWidget {
  final Map bill;
  const CustomerCreatePaymentView({super.key, required this.bill});

  @override
  State<CustomerCreatePaymentView> createState() => _CustomerCreatePaymentViewState();
}

class _CustomerCreatePaymentViewState extends State<CustomerCreatePaymentView> {
  final PaymentService _paymentApi = PaymentService();
  File? _selectedFile;
  bool _isSubmitting = false;

  String _getMonthName(dynamic m) {
    int month = int.tryParse(m.toString()) ?? 1;
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return (month >= 1 && month <= 12) ? months[month] : '$month';
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "Rp 0";
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}";
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan pilih file bukti pembayaran terlebih dahulu!")));
      return;
    }

    setState(() => _isSubmitting = true);
    final int billId = int.tryParse(widget.bill["id"].toString()) ?? 0;
    final result = await _paymentApi.create(billId, _selectedFile!);
    setState(() => _isSubmitting = false);

    if (context.mounted) {
      AlertMessage().showAlert(context, result.message, result.status);
      if (result.status) {
        Navigator.pop(context, true);
      }
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
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2E4B)),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Tagihan",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Invoice #", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF0F60D6), borderRadius: BorderRadius.circular(20)),
                              child: const Text("TAGIHAN AIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.bill["no_bill"] ?? widget.bill["invoice_number"] ?? "INV-240501-001",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0F2E4B)),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.black12, height: 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Periode", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text("${_getMonthName(widget.bill["month"])} ${widget.bill["year"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2E4B))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Total Bayar", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(_formatCurrency(widget.bill["total_amount"] ?? widget.bill["amount"]), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0F2E4B))),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Unggah Bukti Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F60D6))),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FD),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black26, width: 1),
                      ),
                      child: _selectedFile != null
                          ? Stack(
                              children: [
                                Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(_selectedFile!, fit: BoxFit.cover))),
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
                                    child: const Text("Ketuk untuk mengganti gambar", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.drive_folder_upload, size: 36, color: Color(0xFF0F2E4B)),
                                const SizedBox(height: 12),
                                const Text("Klik untuk pilih file", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2E4B), fontSize: 15)),
                                const SizedBox(height: 4),
                                Text("Maksimum ukuran file 5MB (JPG, PNG, PDF)", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Tagihan", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)),
                      Text(_formatCurrency(widget.bill["total_amount"] ?? widget.bill["amount"]), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF0F2E4B))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F60D6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Konfirmasi Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}