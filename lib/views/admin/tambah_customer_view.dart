import 'package:flutter/material.dart';
import 'package:pdam_app/services/customer_service.dart';
import 'package:pdam_app/widgets/alert.dart';

class AddCustomerView extends StatefulWidget {
  const AddCustomerView({super.key});

  @override
  State<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  final CustomerService customerApi = CustomerService();
  
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController customerNumberCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  String? selectedServiceId;
  bool isSaving = false;

  Widget buildInputField({required String label, required TextEditingController controller, required String hint, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFCBD5E1))),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // MENANGKAP ARGUMENTS LANGSUNG DI SINI AGAR ROUTING MAIN SINGKAT
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List services = args['services'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tambah Customer", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInputField(label: "Username", controller: usernameCtrl, hint: "Masukkan username baru"),
                      buildInputField(label: "Password", controller: passwordCtrl, hint: "Masukkan password", obscure: true),
                      buildInputField(label: "Nama Lengkap", controller: nameCtrl, hint: "Masukkan nama lengkap"),
                      buildInputField(label: "No. Telepon", controller: phoneCtrl, hint: "Masukkan nomor telepon"),
                      buildInputField(label: "No. Pelanggan", controller: customerNumberCtrl, hint: "Masukkan nomor pelanggan"),
                      buildInputField(label: "Alamat", controller: addressCtrl, hint: "Masukkan alamat lengkap"),
                      
                      const Text("Pilih Layanan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFCBD5E1))),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedServiceId,
                          decoration: const InputDecoration(border: InputBorder.none),
                          hint: const Text("Pilih Kategori Layanan", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                          items: services.map<DropdownMenuItem<String>>((s) {
                            return DropdownMenuItem<String>(
                              value: s["id"].toString(),
                              child: Text("${s["name"]} - Rp ${s["price"]}"),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selectedServiceId = val),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF88CEFE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056C6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: isSaving ? null : () async {
                        setState(() => isSaving = true);
                        var data = {
                          "username": usernameCtrl.text,
                          "password": passwordCtrl.text,
                          "customer_number": customerNumberCtrl.text,
                          "address": addressCtrl.text,
                          "service_id": selectedServiceId ?? "",
                          "name": nameCtrl.text,
                          "phone": phoneCtrl.text,
                        };
                        var result = await customerApi.register(data);
                        setState(() => isSaving = false);
                        if (context.mounted) {
                          AlertMessage().showAlert(context, result.message, result.status);
                          if (result.status) Navigator.pop(context, true);
                        }
                      },
                      child: isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Simpan", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
}