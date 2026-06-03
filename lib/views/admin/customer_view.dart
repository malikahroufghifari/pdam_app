import 'package:flutter/material.dart';
import 'package:pdam_app/services/customer_service.dart';
import 'package:pdam_app/services/service_service.dart';
import 'package:pdam_app/widgets/bottom_nav.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  CustomerService customerApi = CustomerService();
  ServiceService serviceApi = ServiceService();

  List customers = [];
  List filteredCustomers = [];
  List services = [];
  bool isLoading = true;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    setState(() => isLoading = true);
    var custResult = await customerApi.showAll();
    var svcResult = await serviceApi.getAll();
    setState(() {
      customers = custResult.data ?? [];
      services = svcResult.data ?? [];
      filterCustomers(searchCtrl.text);
      isLoading = false;
    });
  }

  // SEARCH FILTER DATA LOKAL (Persis logic filterServices Anda)
  void filterCustomers(String query) {
    setState(() {
      filteredCustomers = query.isEmpty
          ? customers
          : customers
                .where(
                  (c) =>
                      c["name"].toString().toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      c["customer_number"].toString().toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7DD3FC), // Background atas biru langit
      body: SafeArea(
        child: Column(
          children: [
            // Judul Utama Halaman
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Text(
                    "Customer",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            // Kontainer putih melengkung besar ke bawah
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          // Search bar + Tombol (+) Tambah
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFD1D5DB),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          color: Color(0xFF9CA3AF),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: searchCtrl,
                                            onChanged: (value) =>
                                                filterCustomers(value),
                                            decoration: const InputDecoration(
                                              hintText: "Cari Pelanggan..",
                                              hintStyle: TextStyle(
                                                color: Color(0xFF9CA3AF),
                                                fontSize: 15,
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Tombol + Kotak Biru Muda
                                InkWell(
                                  onTap: () async {
                                    bool? isChanged =
                                        await Navigator.pushNamed(
                                              context,
                                              '/admin/customers/add',
                                              arguments: {'services': services},
                                            )
                                            as bool?;
                                    if (isChanged == true) loadData();
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF50A7F9,
                                      ).withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // List Customer Outlined Card persis isi gambar "Customer.png"
                          Expanded(
                            child: filteredCustomers.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Customer tidak ditemukan",
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: () async => loadData(),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      itemCount: filteredCustomers.length,
                                      itemBuilder: (ctx, i) {
                                        var c = filteredCustomers[i];
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            onTap: () async {
                                              bool? reloadNeeded =
                                                  await Navigator.pushNamed(
                                                        context,
                                                        '/admin/customers/detail',
                                                        arguments: c["id"],
                                                      )
                                                      as bool?;
                                              if (reloadNeeded == true)
                                                loadData();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              child: Row(
                                                children: [
                                                  // Lingkaran Avatar User (Lebih kecil & proporsional)
                                                  Container(
                                                    height: 44,
                                                    width: 44,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFFF3F4F6,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Color(0xFF9CA3AF),
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // Informasi Text Kustomer
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          c["customer_number"] ??
                                                              "-",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 11,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                letterSpacing:
                                                                    0.3,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          c["name"] ?? "",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Color(
                                                                  0xFF1F2937,
                                                                ),
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 1,
                                                        ),
                                                        Text(
                                                          c["address"] ?? "-",
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Ikon Chevron Tipis & Presisi
                                                  const Icon(
                                                    Icons.chevron_right,
                                                    color: Color(0xFFD1D5DB),
                                                    size: 22,
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
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        2,
      ), // Active index ke 2 (Customer) sesuai highlight biru di gambar
    );
  }
}
