import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:async';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  // Posisi awal ombak bersembunyi penuh di bawah lingkaran
  double _waveBottomPosition = -300.0; 
  double _circleScale = 1.0;
  double _finalOpacity = 0.0;

  late AnimationController _waveController;
  late Animation<double> _waveSway;

  @override
  void initState() {
    super.initState();
    
    // Durasi ayunan gelombang (2 detik agar gerakannya mengalir lembut)
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Rentang geser horizontal yang ideal agar efek airnya nyata
    _waveSway = Tween<double>(begin: -40.0, end: 40.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Animasi gelombang berjalan loop bolak-balik
    _waveController.repeat(reverse: true);

    // Hapus native splash screen bawaan OS jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    
    _startAnimation();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 1. Ombak meluncur naik hingga melewati batas atas lingkaran agar terisi penuh
    setState(() {
      _waveBottomPosition = 10.0; 
    });

    // 2. Tunggu ombak selesai naik (1.5 detik), lalu lingkaran langsung Zoom In besar
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _circleScale = 25.0; // Skala besar untuk menutup seluruh layar HP
    });

    // 3. Saat layar tertutup warna biru, munculkan background putih & logo utama
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _finalOpacity = 1.0;
    });

    // 4. BERHASIL: Tunggu logo terlihat jelas selama 2 detik, lalu pindah ke halaman Login
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          
          // --- LAYER 1: Lingkaran & Efek Ombak Bergelombang ---
          Center(
            child: AnimatedScale(
              scale: _circleScale,
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeInOutQuart, // Efek zoom yang punchy dan halus
              child: Container(
                width: 250.0,
                height: 250.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF2F2F2), // Latar abu-abu awal lingkaran Anda
                ),
                clipBehavior: Clip.antiAlias, // Memotong ombak agar tetap bulat
                child: Stack(
                  children: [
                    
                    // --- Ombak Belakang (Vector 2 - Biru Terang) ---
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      bottom: _waveBottomPosition,
                      left: -55, // Ruang aman agar samping tidak bolong saat digeser
                      right: -55,
                      child: AnimatedBuilder(
                        animation: _waveSway,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(-_waveSway.value, 0), // Bergerak ke Kiri
                            child: Image.asset(
                              'assets/Vector 2.png',
                              height: 300, // Tinggi ekstra agar menutup sempurna
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),

                    // --- Ombak Depan (Vector 1 - Biru Gelap) ---
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      // Dibuat sedikit lebih rendah agar ombak Vector 2 di belakangnya mengintip manis
                      bottom: _waveBottomPosition - 20, 
                      left: -55,
                      right: -55,
                      child: AnimatedBuilder(
                        animation: _waveSway,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_waveSway.value, 0), // Bergerak ke Kanan
                            child: Image.asset(
                              'assets/Vector 1.png',
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          // --- LAYER 2: Halaman Putih & Final Logo (Transisi Akhir) ---
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _finalOpacity,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/final logo.png',
                  width: 240, // Proporsi pas untuk logo utama
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}