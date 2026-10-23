import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adistyclone/core/theme/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: ColorLight.latar,
      colorScheme: const ColorScheme.light(
        primary: ColorLight.kartuUtama,
        onPrimary: ColorLight.teksDiKartu,
        secondary: ColorLight.aksen,
        onSecondary: ColorLight.teksDiAksen,
        surface: ColorLight.latarKomponen,
        onSurface: ColorLight.teks,
        onSurfaceVariant: ColorLight.teksSekunder,
      ),
      cardColor: ColorLight.latarKomponen,
      dialogTheme: const DialogThemeData(
        backgroundColor: ColorLight.latarKomponen,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorLight.latarKomponen,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorLight.aksen,
          foregroundColor: ColorLight.teksDiAksen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ColorLight.teksSekunder.withValues(alpha: 0.2),
        thickness: 0.5,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: ColorDark.latar,
      colorScheme: const ColorScheme.dark(
        primary: ColorDark.kartuUtama,
        onPrimary: ColorDark.teksDiKartu,
        secondary: ColorDark.aksen,
        onSecondary: ColorDark.teksDiAksen,
        surface: ColorDark.latarKomponen,
        onSurface: ColorDark.teks,
        onSurfaceVariant: ColorDark.teksSekunder,
      ),
      cardColor: ColorDark.latarKomponen,
      dialogTheme: const DialogThemeData(
        backgroundColor: ColorDark.latarKomponen,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorDark.latarKomponen,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorDark.aksen,
          foregroundColor: ColorDark.teksDiAksen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ColorDark.teksSekunder.withValues(alpha: 0.2),
        thickness: 0.5,
      ),
    );
  }
}
