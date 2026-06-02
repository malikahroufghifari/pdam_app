import 'package:flutter/material.dart';
import 'package:pdam_app/services/service_service.dart';
import 'package:pdam_app/widgets/alert.dart';

class TambahLayananView extends StatefulWidget {
  const TambahLayananView({super.key});

  @override
  State<TambahLayananView> createState() => _TambahLayananViewState();
}

class _TambahLayananViewState extends State<TambahLayananView> {
  final ServiceService serviceApi = ServiceService();
  
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController minUsageCtrl = TextEditingController();
  final TextEditingController maxUsageCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  
  bool isSaving = false;

  Widget buildInputField({
    required String label, 
    required TextEditingController controller, 
    required String hint, 
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(14), 
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tambah Layanan", 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildInputField(
                        label: "Nama Layanan", 
                        controller: nameCtrl, 
                        hint: "Contoh: Rumah Tangga A",
                      ),
                      buildInputField(
                        label: "Batas Minimal Penggunaan (M³)", 
                        controller: minUsageCtrl, 
                        hint: "Contoh: 40",
                        type: TextInputType.number,
                      ),
                      buildInputField(
                        label: "Batas Maksimal Penggunaan (M³)", 
                        controller: maxUsageCtrl, 
                        hint: "Contoh: 100",
                        type: TextInputType.number,
                      ),
                      buildInputField(
                        label: "Tarif per M³", 
                        controller: priceCtrl, 
                        hint: "Masukkan nominal tarif", 
                        type: TextInputType.number,
                      ),
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
                        
                        // Mapping data disesuaikan dengan payload Postman
                        var data = {
                          "name": nameCtrl.text,
                          "min_usage": int.tryParse(minUsageCtrl.text) ?? 0,
                          "max_usage": int.tryParse(maxUsageCtrl.text) ?? 0,
                          "price": int.tryParse(priceCtrl.text) ?? 0,
                        };
                        
                        var result = await serviceApi.create(data);
                        setState(() => isSaving = false);
                        
                        if (context.mounted) {
                          AlertMessage().showAlert(context, result.message, result.status);
                          if (result.status) Navigator.pop(context, true);
                        }
                      },
                      child: isSaving 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
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