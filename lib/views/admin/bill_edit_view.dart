import 'package:flutter/material.dart';
import 'package:pdam_app/services/bill_service.dart';
import 'package:pdam_app/widgets/alert.dart';

class EditBillPage extends StatefulWidget {
  final Map existing;
  final BillService billApi;
  final VoidCallback onSuccess;

  const EditBillPage({
    super.key,
    required this.existing,
    required this.billApi,
    required this.onSuccess,
  });

  @override
  State<EditBillPage> createState() => _EditBillPageState();
}

class _EditBillPageState extends State<EditBillPage> {
  late TextEditingController customerNameCtrl;
  late TextEditingController monthCtrl;
  late TextEditingController yearCtrl;
  late TextEditingController measurementCtrl;
  late TextEditingController usageCtrl;

  final int waterTariffPerM3 = 5000;
  int estimatedBill = 0;

  @override
  void initState() {
    super.initState();
    customerNameCtrl = TextEditingController(
      text: widget.existing["customer"]?["name"] ?? widget.existing["customer_name"] ?? "Siti Aminah",
    );
    monthCtrl = TextEditingController(text: widget.existing["month"]?.toString() ?? "");
    yearCtrl = TextEditingController(text: widget.existing["year"]?.toString() ?? "");
    measurementCtrl = TextEditingController(text: widget.existing["measurement_number"]?.toString() ?? "");
    usageCtrl = TextEditingController(text: widget.existing["usage_value"]?.toString() ?? "");

    _calculateEstimation();
    usageCtrl.addListener(_calculateEstimation);
  }

  void _calculateEstimation() {
    final usage = int.tryParse(usageCtrl.text) ?? 0;
    setState(() {
      estimatedBill = usage * waterTariffPerM3;
    });
  }

  @override
  void dispose() {
    customerNameCtrl.dispose();
    monthCtrl.dispose();
    yearCtrl.dispose();
    measurementCtrl.dispose();
    usageCtrl.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({required String labelText, String? helperText}) {
    return InputDecoration(
      labelText: labelText,
      helperText: helperText,
      helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0056C6), width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedPrice = estimatedBill.toString().replaceAllMapped(currencyFormat, (Match m) => "${m[1]}.");

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF64B5F6), Color(0xFFE3F2FD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2E4B), size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Edit Tagihan",
                    style: TextStyle(color: Color(0xFF0F2E4B), fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: customerNameCtrl,
                            enabled: false,
                            style: const TextStyle(color: Colors.grey),
                            decoration: _buildInputDecoration(labelText: "Pelanggan"),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: monthCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(labelText: "Bulan"),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: yearCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(labelText: "Tahun"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: measurementCtrl,
                            decoration: _buildInputDecoration(labelText: "No.Meteran", helperText: "Nomor fisik meteran air"),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: usageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(labelText: "Nilai Penggunaan (m³)", helperText: "Baca dari Meteran"),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF0D47A1), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Estimasi Tagihan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                const SizedBox(height: 4),
                                Text("Rp $formattedPrice", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              backgroundColor: const Color(0xFF0056C6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              var data = {
                                "month": monthCtrl.text,
                                "year": yearCtrl.text,
                                "measurement_number": measurementCtrl.text,
                                "usage_value": usageCtrl.text
                              };
                              
                              dynamic result = await widget.billApi.update(widget.existing["id"], data);
                              
                              if (context.mounted) {
                                AlertMessage().showAlert(context, result.message, result.status);
                                if (result.status) {
                                  widget.onSuccess();
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text("Simpan Tagihan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              side: const BorderSide(color: Color(0xFF0056C6), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Batal", style: TextStyle(color: Color(0xFF0056C6), fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ],
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
}