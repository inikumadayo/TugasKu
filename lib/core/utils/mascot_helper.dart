import 'dart:math';

import 'package:adistyclone/core/constants/mascot_assets.dart';
import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/presentation/widgets/dialogs/mascot_dialog.dart' as mascot_dialog;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Helper untuk pengelolaan interaktivitas, sapaan dinamis,
/// dan gamifikasi perayaan maskot "Lumut".
class MascotHelper {
  static final _random = Random();

  /// Mengambil aset maskot berdasarkan waktu hari ini
  static String getTimeBasedMascot() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return MascotAssets.berangkat; // Pagi: Lumut siap kuliah
    } else if (hour >= 11 && hour < 15) {
      return MascotAssets.belajar; // Siang: Lumut belajar
    } else if (hour >= 15 && hour < 18) {
      return MascotAssets.matcha; // Sore: Lumut santai matcha
    } else if (hour >= 18 && hour < 22) {
      return MascotAssets.mengetik; // Malam: Lumut nugas
    } else {
      return MascotAssets.mengantuk; // Larut malam: Lumut mengantuk
    }
  }

  /// Sapaan ramah berdasarkan jam saat ini
  static String getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Semangat Pagi! ☀️';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang! 🌤️';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore! 🍵';
    } else if (hour >= 18 && hour < 22) {
      return 'Selamat Malam! 🌙';
    } else {
      return 'Sudah Larut Malam 😴';
    }
  }

  /// Kumpulan pesan/motivasi santai dari Lumut
  static const List<String> _friendlyQuotes = [
    'Jangan lupa minum air putih dan istirahat sejenak ya~ 🍵',
    'Cicil tugas sedikit demi sedikit, yang penting jalan! 🐾',
    'Semangat kuliahnya hari ini! Kamu pasti bisa melaluinya. ✨',
    'Capek nugas? Putar musik lofi dan santai 5 menit dulu yuk 🎧',
    'Tugas yang selesai tepat waktu bikin tidur lebih nyenyak! 💤',
    'Lumut selalu siap menemanimu belajar dan berprogres! 🌿',
    'Ingat, kesehatan fisik & mentalmu nomor satu! 💖',
  ];

  /// Kumpulan pesan apresiasi saat satu tugas selesai
  static const List<String> _taskCheerQuotes = [
    'Hebat! Satu beban tugas berhasil terangkat! 🎉',
    'Keren banget! Selangkah lebih dekat ke liburan ✨',
    'Mantap! Lumut bangga sama kerja kerasmu hari ini! 🐾',
    'Tugas tuntas! Waktunya santai sejenak minum matcha 🍵',
    'Progres luar biasa! Tetap jaga ritme belajarmu ya! 💪',
    'Satu tugas beres! Semakin tenang deh harimu 🚀',
  ];

  /// Mengambil quote motivasi acak
  static String getRandomFriendlyQuote() {
    return _friendlyQuotes[_random.nextInt(_friendlyQuotes.length)];
  }

  /// Mengambil pesan apresiasi acak untuk tugas selesai
  static String getRandomCheerQuote() {
    return _taskCheerQuotes[_random.nextInt(_taskCheerQuotes.length)];
  }

  /// Menampilkan dialog interaktif saat maskot di Header diketuk
  static void showMascotGreetingDialog(BuildContext context) {
    mascot_dialog.showMascotGreetingDialog(context);
  }

  /// Menampilkan perayaan saat tugas diselesaikan
  static void showTaskCelebration(
    BuildContext context, {
    required bool isAllCompleted,
  }) {
    if (isAllCompleted) {
      // Perayaan Spesial: SEMUA tugas tuntas
      mascot_dialog.showAllTasksCompletedDialog(context);
    } else {
      // Perayaan Satu Tugas Selesai (Floating SnackBar estetik)
      final cheer = getRandomCheerQuote();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ColorsTheme.latarKomponen,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: ColorsTheme.aksen.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          content: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ColorsTheme.aksen.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  MascotAssets.selesai,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cheer,
                  style: TextStyle(
                    color: ColorsTheme.teks,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 2400),
        ),
      );
    }
  }
}
