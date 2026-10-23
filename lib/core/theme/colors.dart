import 'package:flutter/material.dart';

class ColorsTheme {
  static bool _isDarkMode = false;
  static final ValueNotifier<bool> isDarkModeNotifier =
      ValueNotifier<bool>(false);

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

  static Color get teksDiKartu =>
      _isDarkMode ? ColorDark.teksDiKartu : ColorLight.teksDiKartu;

  static Color get aksen => _isDarkMode ? ColorDark.aksen : ColorLight.aksen;

  static Color get teksDiAksen =>
      _isDarkMode ? ColorDark.teksDiAksen : ColorLight.teksDiAksen;

  static Color get teks => _isDarkMode ? ColorDark.teks : ColorLight.teks;

  static Color get teksSekunder =>
      _isDarkMode ? ColorDark.teksSekunder : ColorLight.teksSekunder;

  static Color get chipLempung =>
      _isDarkMode ? ColorDark.chipLempung : ColorLight.chipLempung;

  static Color get teksChipLempung =>
      _isDarkMode ? ColorDark.teksChipLempung : ColorLight.teksChipLempung;

  static Color get chipBatu =>
      _isDarkMode ? ColorDark.chipBatu : ColorLight.chipBatu;

  static Color get teksChipBatu =>
      _isDarkMode ? ColorDark.teksChipBatu : ColorLight.teksChipBatu;

  static Color get selesai =>
      _isDarkMode ? ColorDark.selesai : ColorLight.selesai;

  static Color get teksSelesai =>
      _isDarkMode ? ColorDark.teksSelesai : ColorLight.teksSelesai;

  /// Backward compatibility alias
  static Color get chipMentega => chipLempung;

  /// Nama tema yang readable untuk ditampilkan di UI
  static String get themeName =>
      _isDarkMode ? 'Rainy Garden' : 'Matcha Paper';
}

class ColorLight {
  static const Color latar         = Color(0xFFF0EFE7); // kertas lukisan tinta
  static const Color latarKomponen = Color(0xFFFBFAF5);
  static const Color kartuUtama    = Color(0xFF4A6650); // hijau lumut
  static const Color teksDiKartu   = Color(0xFFFFFFFF);
  static const Color aksen         = Color(0xFFE3A65C); // amber
  static const Color teksDiAksen   = Color(0xFF2B2A26);
  static const Color teks          = Color(0xFF232A25);
  static const Color teksSekunder  = Color(0xFF5E6A60);
  static const Color chipLempung   = Color(0xFFF0D5BF); // teks 0xFF6A3F22
  static const Color teksChipLempung = Color(0xFF6A3F22);
  static const Color chipBatu      = Color(0xFFD9E3E6); // teks 0xFF33474F
  static const Color teksChipBatu  = Color(0xFF33474F);
  static const Color selesai       = Color(0xFFDCE6C1); // teks 0xFF3F5224
  static const Color teksSelesai   = Color(0xFF3F5224);

  // Backward compatibility alias
  static const Color chipMentega   = chipLempung;
}

class ColorDark {
  static const Color latar         = Color(0xFF1A1F1C); // arang kehijauan
  static const Color latarKomponen = Color(0xFF252B27);
  static const Color kartuUtama    = Color(0xFF46624D); // hijau lumut
  static const Color teksDiKartu   = Color(0xFFEEF1E6);
  static const Color aksen         = Color(0xFFE3A65C); // amber lampu
  static const Color teksDiAksen   = Color(0xFF1F2420);
  static const Color teks          = Color(0xFFE9ECE2); // putih kertas
  static const Color teksSekunder  = Color(0xFFA3AD9F);
  static const Color chipLempung   = Color(0xFF4A3328); // teks 0xFFEBC2A0
  static const Color teksChipLempung = Color(0xFFEBC2A0);
  static const Color chipBatu      = Color(0xFF2E3A42); // teks 0xFFBCD0DA
  static const Color teksChipBatu  = Color(0xFFBCD0DA);
  static const Color selesai       = Color(0xFF3A4A2C); // matcha, teks 0xFFD3E3A6
  static const Color teksSelesai   = Color(0xFFD3E3A6);

  // Backward compatibility alias
  static const Color chipMentega   = chipLempung;
  static const Color teksDiKartuUtama = teksDiKartu;
}
