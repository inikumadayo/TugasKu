import 'package:flutter/material.dart';

class ColorsTheme {
  static bool _isDarkMode = false;
  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

  static bool get isDarkMode => _isDarkMode;

  static void setDarkMode(bool value) {
    _isDarkMode = value;
    isDarkModeNotifier.value = value;
  }

  static Color get latar => _isDarkMode ? ColorDark.latar : ColorLight.latar;

  static Color get latarKomponen =>
      _isDarkMode ? ColorDark.latarKomponen : ColorLight.latarKomponen;

  static Color get kartuUtama =>
      _isDarkMode ? ColorDark.kartuUtama : ColorLight.kartuUtama;

  static Color get aksen => _isDarkMode ? ColorDark.aksen : ColorLight.aksen;

  static Color get teks => _isDarkMode ? ColorDark.teks : ColorLight.teks;

  static Color get teksSekunder =>
      _isDarkMode ? ColorDark.teksSekunder : ColorLight.teksSekunder;

  static Color get chipMentega =>
      _isDarkMode ? ColorDark.chipMentega : ColorLight.chipMentega;

  static Color get selesai =>
      _isDarkMode ? ColorDark.selesai : ColorLight.selesai;

  /// Nama tema yang readable untuk ditampilkan di UI
  static String get themeName =>
      _isDarkMode ? 'Blueberry Oat Dark' : 'Blueberry Oat';
}

class ColorLight {
  static const Color latar = Color(0xFFF5F1EA);
  static const Color latarKomponen = Color(0xFFFFFFFF);
  static const Color kartuUtama = Color(0xFF3F5F85);
  static const Color aksen = Color(0xFFF2C46D);
  static const Color teks = Color(0xFF2B3140);
  static const Color teksSekunder = Color(0xFF7D6454);
  static const Color chipMentega = Color(0xFFF6D2CB);
  static const Color selesai = Color(0xFFCBE3D0);
}

class ColorDark {
  static const Color latar = Color(0xFF1E2025); // abu arang
  static const Color latarKomponen = Color(0xFF2A2D34);
  static const Color kartuUtama = Color(
    0xFF4A6F9C,
  ); // blueberry, lebih terang dari versi terang
  static const Color teksDiKartuUtama = Color(0xFFFFFFFF);
  static const Color aksen = Color(0xFFF2C46D); // butter, tetap sama
  static const Color teksDiAksen = Color(0xFF2B3140);
  static const Color teks = Color(0xFFECEEF2);
  static const Color teksSekunder = Color(0xFFA6ADBB);
  static const Color chipMentega = Color(0xFF4B3538); // teks: 0xFFF6D2CB
  static const Color selesai = Color(0xFF2F4A3A); // teks: 0xFFCBE3D0
}
