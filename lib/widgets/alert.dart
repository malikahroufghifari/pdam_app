import 'package:flutter/material.dart';

class AlertMessage {
  showAlert(BuildContext context, String message, bool status) {
    // Menentukan Judul secara otomatis berdasarkan status true/false
    String title = status ? "Berhasil!" : "Gagal!";

    // Penyesuaian Warna Berdasarkan Desain Foto & Kebutuhan Status
    Color warnaFill = status ? const Color(0xFFEAF7EE) : const Color(0xFFFF3B30);
    Color warnaGaris = status ? const Color(0xFFBFE7CD) : Colors.transparent;
    Color warnaTeksUtama = status ? const Color(0xFF1C2A38) : Colors.white;
    Color warnaTeksSub = status ? const Color(0xFF54687A) : Colors.white54;
    // Memastikan tombol X terlihat kontras saat background merah (gagal)
    Color warnaIkonClose = status ? const Color(0xFF8A99A8) : Colors.white.withOpacity(0.85);

    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating, 
      // MENGUBAH POSISI KE ATAS: Mengatur margin top agar muncul di bagian atas layar
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10, // Menyesuaikan tinggi status bar HP
        left: 16,
        right: 16,
      ),   
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: warnaFill,
          border: Border.all(color: warnaGaris, width: 1),
          borderRadius: BorderRadius.circular(12), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ikon Centang (Hanya muncul jika status sukses / true)
            if (status) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF1ECB63),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
            ],
            
            // Kolom Teks (Judul + Pesan Dinamis)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: warnaTeksUtama,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(
                        color: warnaTeksSub,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Tombol Close (X) - Sekarang dipastikan kontras dan selalu muncul
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              icon: Icon(Icons.close, color: warnaIkonClose, size: 18),
            )
          ],
        ),
      ),
    );

    // Bersihkan snackbar lama sebelum memunculkan yang baru
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}