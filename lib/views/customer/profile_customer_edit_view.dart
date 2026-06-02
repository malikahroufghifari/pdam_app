import 'package:flutter/material.dart';
import 'package:pdam_app/services/customer_service.dart'; 
import 'package:pdam_app/widgets/alert.dart';

class EditProfileCustomerView extends StatefulWidget {
  final Map? currentData; 

  const EditProfileCustomerView({super.key, this.currentData});

  @override
  State<EditProfileCustomerView> createState() => _EditProfileCustomerViewState();
}

class _EditProfileCustomerViewState extends State<EditProfileCustomerView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _customerNumberController;
  late TextEditingController _addressController;
  late TextEditingController _serviceIdController;

  bool _isInit = false;
  bool _isLoading = false;
  late int _customerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // FIX: Ambil dari widget.currentData (bukan ModalRoute arguments)
      // Jika ternyata null, amankan dengan fallback Map kosong {}
      final customerData = widget.currentData ?? {};

      _customerId = int.tryParse(customerData["id"]?.toString() ?? "0") ?? 0;
      
      _nameController = TextEditingController(
        text: customerData["name"]?.toString() ?? "",
      );
      _phoneController = TextEditingController(
        text: customerData["phone"]?.toString() ?? "",
      );
      _customerNumberController = TextEditingController(
        text: customerData["customer_number"]?.toString() ?? "",
      );
      _addressController = TextEditingController(
        text: customerData["address"]?.toString() ?? "",
      );
      _serviceIdController = TextEditingController(
        text: customerData["service_id"]?.toString() ?? "",
      );

      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _customerNumberController.dispose();
    _addressController.dispose();
    _serviceIdController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "C";
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> updateData = {
      "name": _nameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "customer_number": _customerNumberController.text.trim(),
      "address": _addressController.text.trim(),
      "service_id": _serviceIdController.text.trim(),
    };

    var response = await CustomerService().update(_customerId, updateData);

    setState(() => _isLoading = false);

    if (response.status) {
      AlertMessage().showAlert(
        context,
        "Profil pelanggan berhasil diperbarui",
        true,
      );

      Navigator.pop(context, true);
    } else {
      AlertMessage().showAlert(context, response.message, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0A58CA)),
            )
          : Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8AD4FE), Color(0xFFCBEBFE)],
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              "Edit Profil Pelanggan",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: Color(0xFF0F172A), size: 28),
                              onPressed: _submitUpdate,
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            children: [
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: const Color(0xFF0A58CA),
                                    child: Text(
                                      _getInitials(_nameController.text),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              Center(
                                child: Text(
                                  _nameController.text.isNotEmpty ? _nameController.text : "Pelanggan",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),

                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2F0FD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "CUSTOMER",
                                    style: TextStyle(
                                      color: Color(0xFF0A58CA),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Informasi Akun Pelanggan",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    _buildInlineRowField(
                                      label: "Nama Lengkap",
                                      controller: _nameController,
                                      onChanged: (val) => setState(() {}),
                                    ),
                                    const Divider(height: 28, thickness: 1, color: Color(0xFFF1F5F9)),

                                    _buildInlineRowField(
                                      label: "Nomor Hp",
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const Divider(height: 28, thickness: 1, color: Color(0xFFF1F5F9)),

                                    _buildInlineRowField(
                                      label: "No. Pelanggan",
                                      controller: _customerNumberController,
                                      keyboardType: TextInputType.number,
                                    ),
                                    const Divider(height: 28, thickness: 1, color: Color(0xFFF1F5F9)),

                                    _buildInlineRowField(
                                      label: "Alamat Rumah",
                                      controller: _addressController,
                                    ),
                                    const Divider(height: 28, thickness: 1, color: Color(0xFFF1F5F9)),

                                    _buildInlineRowField(
                                      label: "ID Layanan (Service ID)",
                                      controller: _serviceIdController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
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

  Widget _buildInlineRowField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.end,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
            ),
            validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
          ),
        ),
      ],
    );
  }
}