import 'package:flutter/material.dart';
import 'package:pdam_app/services/customer_service.dart';
import 'package:pdam_app/widgets/alert.dart';

class EditCustomerView extends StatefulWidget {
  const EditCustomerView({super.key});

  @override
  State<EditCustomerView> createState() => _EditCustomerViewState();
}

class _EditCustomerViewState extends State<EditCustomerView> {
  final CustomerService customerApi = CustomerService();
  
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController customerNumberCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  String? selectedServiceId;
  
  bool isDataLoaded = false;
  bool isSaving = false;
  late Map existing;
  late List services;

  Widget buildInputField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFCBD5E1))),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // MENANGKAP ARGUMENTS SECARA MANDIRI DAN SET VALUE CONTROLLER SEKALI SAJA
    if (!isDataLoaded) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      existing = args['existing'];
      services = args['services'] ?? [];

      nameCtrl.text = existing["name"] ?? "";
      phoneCtrl.text = existing["phone"] ?? "";
      customerNumberCtrl.text = existing["customer_number"] ?? "";
      addressCtrl.text = existing["address"] ?? "";
      selectedServiceId = existing["service_id"]?.toString();
      isDataLoaded = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Customer", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInputField(label: "Nama Lengkap", controller: nameCtrl),
                      buildInputField(label: "No. Telepon", controller: phoneCtrl),
                      buildInputField(label: "No. Pelanggan", controller: customerNumberCtrl),
                      buildInputField(label: "Alamat", controller: addressCtrl),
                      
                      const Text("Layanan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFCBD5E1))),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedServiceId,
                          decoration: const InputDecoration(border: InputBorder.none),
                          items: services.map<DropdownMenuItem<String>>((s) {
                            return DropdownMenuItem<String>(
                              value: s["id"].toString(),
                              child: Text("${s["name"]} - Rp ${s["price"]}"),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selectedServiceId = val),
                        ),
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
                        var data = {
                          "customer_number": customerNumberCtrl.text,
                          "address": addressCtrl.text,
                          "service_id": selectedServiceId ?? "",
                          "name": nameCtrl.text,
                          "phone": phoneCtrl.text,
                        };
                        var result = await customerApi.update(existing["id"], data);
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