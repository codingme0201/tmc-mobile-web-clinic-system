import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF14786D);
  static const Color primaryDark = Color(0xFF083B3F);
  static const Color background = Color(0xFFEEF4F2);
  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF12393B);
  static const Color muted = Color(0xFF627772);
  static const Color mutedLight = Color(0xFF8FA3A0);
  static const Color line = Color(0xFFD6E0DC);
  static const Color gold = Color(0xFFF0B84F);
  static const Color accent = Color(0xFFD95F35);
  static const Color success = Color(0xFF2FA96B);
  static const Color danger = Color(0xFFB23C1F);
  static const Color dangerLight = Color(0xFFFCEAE5);
  static const Color warning = Color(0xFFD4A017);
  static const Color info = Color(0xFF2F7DA9);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: ink,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger, width: 2),
        ),
        labelStyle: const TextStyle(color: muted),
        hintStyle: const TextStyle(color: mutedLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
