import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mismos colores que el sitio web (css/variables.css), para que la app
/// se sienta como la misma marca, no un rediseño distinto.
class AppColors {
  static const cyan = Color(0xFF00D9FF);
  static const magenta = Color(0xFFFF006E);
  static const verdeNeon = Color(0xFF39FF14);
  static const morado = Color(0xFFB24BF3);
  static const naranja = Color(0xFFFF7A1A);

  static const fondoOscuro = Color(0xFF0A0E27);
  static const fondoMedio = Color(0xFF1A1A3E);
  static const fondoClaro = Color(0xFF0F1829);
  static const cardBg = Color(0x991A1A3E); // rgba(26,26,62,0.6)
  static const textoClaro = Color(0xFFE8ECF1);
  static const textoGris = Color(0xFFA8B8CC);

  static const gradienteFondo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fondoOscuro, fondoMedio, fondoClaro],
  );

  static const gradienteCyanMagenta = LinearGradient(
    colors: [cyan, magenta],
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.fondoOscuro,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.cyan,
        secondary: AppColors.magenta,
        surface: AppColors.fondoMedio,
        error: AppColors.magenta,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textoClaro,
        displayColor: AppColors.textoClaro,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fondoOscuro,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fondoClaro.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cyan),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.magenta, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.cyan),
        hintStyle: TextStyle(color: AppColors.textoGris.withOpacity(0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.fondoOscuro,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
      ),
    );
  }
}
