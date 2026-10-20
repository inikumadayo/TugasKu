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
        secondary: ColorLight.aksen,
        surface: ColorLight.latarKomponen,
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
        secondary: ColorDark.aksen,
        surface: ColorDark.latarKomponen,
      ),
    );
  }
}
