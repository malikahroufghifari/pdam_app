import 'package:flutter/material.dart';

class BannerTipsView extends StatelessWidget {
  const BannerTipsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          // Background biru atas
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar custom
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFF0D47A1)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Tips Hemat",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Konten scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Banner Atas - backgroundTetes.png dengan teks di stack atas
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Layer 1: gambar background penuh
                                Image.asset(
                                  'assets/backgroundTetes.png',
                                  fit: BoxFit.cover,
                                ),
                                // Layer 2: overlay gradient kiri agar teks terbaca
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFBAE6FD).withOpacity(0.90),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                                // Layer 3: teks di atas gambar
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 24, 110, 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Hemat Air, Hemat Biaya",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0D47A1),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "Tips bijak gunakan air dimusim\nkemarau",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1565C0),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Card intro
                        _buildTipsCard(
                          child: Text(
                            "Air adalah sumber daya yang terbatas. Dengan melakukan penghematan penggunaan air, Anda tidak hanya berkontribusi pada pelestarian alam, namun juga secara signifikan dapat menurunkan tagihan bulanan utilitas Anda. Berikut adalah langkah praktis yang bisa Anda terapkan segera.",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Perbaikan Keran Bocor
                        _buildTipsCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Perbaikan Keran Bocor",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Satu tetesan per detik dapat membuang lebih dari 10.000 liter air per tahun. Segera ganti seal atau katup yang aus.",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gunakan Air Secukupnya
                        _buildTipsCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Gunakan Air Secukupnya",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Matikan keran saat menggosok gigi atau menyabuni tangan. Gunakan pancuran (shower) daripada bak mandi untuk menghemat hingga 60% air.",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gunakan Air Bekas
                        _buildTipsCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Gunakan Air Bekas",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Air bekas cucian sayur atau buah masih bisa digunakan untuk menyiram tanaman di halaman rumah Anda.",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gunakan Penampung Hujan
                        _buildTipsCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Gunakan Penampung Hujan",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Manfaatkan air hujan untuk menyiram tanaman atau mencuci kendaraan. Ini adalah alternatif gratis yang ramah lingkungan.",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Tombol Kembali
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Kembali",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }

  Widget _buildTipsCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }
}