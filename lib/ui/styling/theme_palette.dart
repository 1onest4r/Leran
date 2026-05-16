import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Predefined color options for the settings page
  static const List<Color> colorOptions = [
    Color(0xFF50C878), // Emerald Green (Original)
    Color(0xFF5E81AC), // Nordic Blue
    Color(0xFFB48EAD), // Muted Purple
    Color(0xFFD08770), // Terracotta
    Color(0xFFBF616A), // Soft Red
  ];

  static const Color secondary = Color(0xFF56815E);
  static const Color tertiary = Color(0xFFFF9587);
  static const Color neutral = Color(0xFF121212);

  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Notice how this now requires a dynamic color variable
  static ThemeData getDarkTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: neutral,

      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondary,
        tertiary: tertiary,
        surface: darkSurface,
        onSurface: Colors.white,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(color: Colors.white70),
        labelMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: Colors.white60,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF242424),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.grey),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thickness: MaterialStateProperty.all(12.0),
        radius: const Radius.circular(10),
        crossAxisMargin: 2.0,
        thumbColor: MaterialStateProperty.all(Colors.white.withOpacity(0.15)),
      ),
    );
  }

  static ThemeData getLightTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),

      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondary,
        tertiary: tertiary,
        surface: lightSurface,
        onSurface: neutral,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          color: neutral,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: neutral,
        ),
        bodyLarge: GoogleFonts.inter(color: Colors.black87),
        labelMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thickness: MaterialStateProperty.all(12.0),
        radius: const Radius.circular(10),
        crossAxisMargin: 2.0,
        thumbColor: MaterialStateProperty.all(Colors.black.withOpacity(0.2)),
      ),
    );
  }
}
