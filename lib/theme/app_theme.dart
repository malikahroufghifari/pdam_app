import 'package:flutter/material.dart';

class AppColors {
  // Palet Utama (Sesuai Logomu & Group 2463)
  static const Color primary = Color(0xFF0C70F2);       // Biru tegas tombol & link
  static const Color primaryLight = Color(0xFF98D9FF);  // Gradasi atas background
  static const Color bgGradientEnd = Color(0xFFD2EFFF);  // Gradasi bawah background top
  
  // Warna Netral
  static const Color textDark = Color(0xFF1A1A1A);      // Judul / Text Utama
  static const Color textMuted = Color(0xFF7A869A);     // Subtitle / Label / Hint
  static const Color borderGrey = Color(0xFFC1C7D0);    // Border text field
  static const Color cardBg = Color(0xFFFFFFFF);        // Background form putih
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
      
      // Pengaturan Font Global Default (Menggunakan Sans-Serif Standar Sistem / Poppins jika diunduh)
      fontFamily: 'Poppins', 
      
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}