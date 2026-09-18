import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Core Brand Colors (Light)
  static const Color primary = Color(0xFF14786D);
  static const Color primaryLight = Color(0xFF1CB8A8);
  static const Color primaryDark = Color(0xFF083B3F);
  static const Color background = Color(0xFFF4F7F6);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF7FAF9);
  static const Color ink = Color(0xFF12393B);
  static const Color inkLight = Color(0xFF264E50);
  static const Color muted = Color(0xFF5D7772);
  static const Color mutedLight = Color(0xFF90A5A1);
  static const Color line = Color(0xFFE0EBE7);
  static const Color lineStrong = Color(0xFFD0E0DC);

  // Core Brand Colors (Dark - Obsidian & Luminous Emerald)
  static const Color darkBackground = Color(0xFF0A1312);
  static const Color darkSurface = Color(0xFF11201F);
  static const Color darkSurfaceSubtle = Color(0xFF162B29);
  static const Color darkInk = Color(0xFFF0FDF9);
  static const Color darkInkLight = Color(0xFFD3E7E3);
  static const Color darkMuted = Color(0xFF88A5A0);
  static const Color darkMutedLight = Color(0xFF5D7C77);
  static const Color darkLine = Color(0xFF1E3735);
  static const Color darkLineStrong = Color(0xFF2B4C49);

  // Accent & Status Colors (Shared Luxury Palette)
  static const Color gold = Color(0xFFF0B84F);
  static const Color goldLight = Color(0xFFFFF6E5);
  static const Color accent = Color(0xFFD95F35);
  static const Color success = Color(0xFF2FA96B);
  static const Color successLight = Color(0xFFE8F7F0);
  static const Color danger = Color(0xFFD94226);
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

  static const LinearGradient heroGradientDark = LinearGradient(
    colors: [Color(0xFF051C1A), Color(0xFF092C29), Color(0xFF0E433E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFDFD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF132423), Color(0xFF101D1C)],
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
          color: const Color(0xFF12393B).withAlpha(14),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: const Color(0xFF12393B).withAlpha(7),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadowDark => [
        BoxShadow(
          color: Colors.black.withAlpha(90),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withAlpha(50),
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

  // Dynamic Theme Helpers
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackground(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color getSurface(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color getSurfaceSubtle(BuildContext context) =>
      isDark(context) ? darkSurfaceSubtle : surfaceSubtle;

  static Color getInk(BuildContext context) =>
      isDark(context) ? darkInk : ink;

  static Color getInkLight(BuildContext context) =>
      isDark(context) ? darkInkLight : inkLight;

  static Color getMuted(BuildContext context) =>
      isDark(context) ? darkMuted : muted;

  static Color getMutedLight(BuildContext context) =>
      isDark(context) ? darkMutedLight : mutedLight;

  static Color getLine(BuildContext context) =>
      isDark(context) ? darkLine : line;

  static Color getLineStrong(BuildContext context) =>
      isDark(context) ? darkLineStrong : lineStrong;

  static LinearGradient getHeroGradient(BuildContext context) =>
      isDark(context) ? heroGradientDark : heroGradient;

  // Reusable Luxury Card Decoration
  static BoxDecoration cardDecoration({
    BuildContext? context,
    Color? color,
    double? radius,
    double borderRadius = 18,
    Border? border,
    Gradient? gradient,
    List<BoxShadow>? shadow,
  }) {
    final effectiveRadius = radius ?? borderRadius;
    final isDarkMode = context != null && isDark(context);

    final defaultBg = isDarkMode ? darkSurface : Colors.white;
    final defaultBorder = isDarkMode
        ? Border.all(color: darkLine, width: 1)
        : Border.all(color: line, width: 1);
    final defaultShadow = isDarkMode ? cardShadowDark : cardShadow;

    return BoxDecoration(
      color: gradient == null ? (color ?? defaultBg) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(effectiveRadius),
      border: border ?? defaultBorder,
      boxShadow: shadow ?? defaultShadow,
    );
  }

  // Light Theme Definition
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: ink,
        error: danger,
        outline: line,
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
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: line, width: 1),
        ),
      ),
    );
  }

  // Dark Theme Definition (Luxury Dark Emerald & Obsidian)
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primaryLight,
        onPrimary: Color(0xFF042220),
        surface: darkSurface,
        onSurface: darkInk,
        error: danger,
        outline: darkLine,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkInk,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkInk,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: darkLine, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 2),
        ),
        labelStyle: const TextStyle(color: darkMuted, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: darkMutedLight, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: const Color(0xFF042220),
          minimumSize: const Size(double.infinity, 52),
          elevation: 2,
          shadowColor: Colors.black.withAlpha(120),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: primaryLight,
        labelColor: primaryLight,
        unselectedLabelColor: darkMutedLight,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkLine, width: 1),
        ),
      ),
    );
  }
}
