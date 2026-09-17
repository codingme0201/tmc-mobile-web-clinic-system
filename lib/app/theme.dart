import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Core Brand Colors
  static const Color primary = Color(0xFF14786D);
  static const Color primaryLight = Color(0xFF1E9B8D);
  static const Color primaryDark = Color(0xFF083B3F);
  static const Color background = Color(0xFFF2F6F5);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF7FAF9);
  static const Color ink = Color(0xFF12393B);
  static const Color inkLight = Color(0xFF264E50);
  static const Color muted = Color(0xFF5D7772);
  static const Color mutedLight = Color(0xFF90A5A1);
  static const Color line = Color(0xFFE0EBE7);
  static const Color lineStrong = Color(0xFFD0E0DC);
  static const Color gold = Color(0xFFF0B84F);
  static const Color goldLight = Color(0xFFFFF6E5);
  static const Color accent = Color(0xFFD95F35);
  static const Color success = Color(0xFF2FA96B);
  static const Color successLight = Color(0xFFE8F7F0);
  static const Color danger = Color(0xFFB23C1F);
  static const Color dangerLight = Color(0xFFFDF0ED);
  static const Color warning = Color(0xFFD49A17);
  static const Color warningLight = Color(0xFFFFF9EC);
  static const Color info = Color(0xFF2A83B8);
  static const Color infoLight = Color(0xFFEBF5FB);

  // Luxury Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF14786D), Color(0xFF0C554D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF083B3F), Color(0xFF0E5652), Color(0xFF14786D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFDFD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF3C469), Color(0xFFE5A934)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Elevation & Layered Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF12393B).withAlpha(15),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: const Color(0xFF12393B).withAlpha(8),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadowSubtle => [
        BoxShadow(
          color: const Color(0xFF12393B).withAlpha(10),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primary.withAlpha(70),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: accent.withAlpha(60),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ];

  // Reusable Luxury Card Decoration
  static BoxDecoration cardDecoration({
    Color? color,
    double? radius,
    double borderRadius = 18,
    Border? border,
    Gradient? gradient,
    List<BoxShadow>? shadow,
  }) {
    final effectiveRadius = radius ?? borderRadius;
    return BoxDecoration(
      color: gradient == null ? (color ?? Colors.white) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(effectiveRadius),
      border: border ?? Border.all(color: line, width: 1),
      boxShadow: shadow ?? cardShadow,
    );
  }

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
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: line, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 2),
        ),
        labelStyle: const TextStyle(color: muted, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: mutedLight, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 2,
          shadowColor: primary.withAlpha(80),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withAlpha(180),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}
