import 'package:adistyclone/core/constants/mascot_assets.dart';
import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/mascot_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Menampilkan dialog interaktif saat maskot Lumut di Header diketuk
Future<void> showMascotGreetingDialog(BuildContext context) async {
  final mascot = MascotHelper.getTimeBasedMascot();
  final greeting = MascotHelper.getTimeGreeting();
  final quote = MascotHelper.getRandomFriendlyQuote();

  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: ColorsTheme.latarKomponen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Container Maskot
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: ColorsTheme.kartuUtama.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  mascot,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Judul Sapaan
              Text(
                greeting,
                style: TextStyle(
                  color: ColorsTheme.teks,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Pesan dari Lumut
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ColorsTheme.latar,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ColorsTheme.teksSekunder.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  quote,
                  style: TextStyle(
                    color: ColorsTheme.teks,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Tombol aksi
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsTheme.kartuUtama,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Siap, Lumut! 🐾',
                  style: TextStyle(
                    color: ColorsTheme.teksDiKartu,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Menampilkan dialog selebrasi akbar saat SEMUA tugas berhasil dituntaskan
Future<void> showAllTasksCompletedDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: ColorsTheme.latarKomponen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ColorsTheme.aksen.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(14),
                child: SvgPicture.asset(
                  MascotAssets.selesai,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Semua Tugas Tuntas! 🎉',
                style: TextStyle(
                  color: ColorsTheme.teks,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Luar biasa! Tidak ada lagi tugas yang tertunda. Waktunya santai dan apresiasi dirimu sendiri! 🌿',
                style: TextStyle(
                  color: ColorsTheme.teksSekunder,
                  fontSize: 13.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsTheme.kartuUtama,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Hore, Santai Dulu! 🍵',
                  style: TextStyle(
                    color: ColorsTheme.teksDiKartu,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
