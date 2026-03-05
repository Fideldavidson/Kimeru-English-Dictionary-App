import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0D3D33); // Forest Green

  static ThemeData lightTheme(double multiplier) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: _buildTextTheme(multiplier, Brightness.light),
    );
  }

  static ThemeData darkTheme(double multiplier) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: _buildTextTheme(multiplier, Brightness.dark),
    );
  }

  static TextTheme _buildTextTheme(double multiplier, Brightness brightness) {
    final color = brightness == Brightness.light ? Colors.black87 : Colors.white70;

    // Brand font: Playfair Display (Serif) — for Headlines & Titles
    final serif = GoogleFonts.playfairDisplayTextTheme();

    return TextTheme(
      // ── Brand / Serif ──────────────────────────────────
      displayLarge: serif.displayLarge!.copyWith(
        fontSize: 32 * multiplier,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: serif.displayMedium!.copyWith(
        fontSize: 28 * multiplier,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displaySmall: serif.displaySmall!.copyWith(
        fontSize: 24 * multiplier,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineLarge: serif.headlineLarge!.copyWith(
        fontSize: 22 * multiplier,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineMedium: serif.headlineMedium!.copyWith(
        fontSize: 20 * multiplier,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: serif.titleLarge!.copyWith(
        fontSize: 18 * multiplier,
        fontWeight: FontWeight.w600,
        color: color,
      ),

      // ── Utility / System Font ──────────────────────────
      bodyLarge: TextStyle(fontSize: 16 * multiplier, color: color),
      bodyMedium: TextStyle(fontSize: 14 * multiplier, color: color),
      bodySmall: TextStyle(fontSize: 12 * multiplier, color: color),
      labelLarge: TextStyle(
        fontSize: 14 * multiplier,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      labelSmall: TextStyle(fontSize: 11 * multiplier, color: color),
    );
  }
}
