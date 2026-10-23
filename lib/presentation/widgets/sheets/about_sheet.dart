import 'package:adistyclone/core/constants/mascot_assets.dart';
import 'package:adistyclone/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// Menampilkan bottom sheet tentang aplikasi (informasi versi, deskripsi, quote, credit & link trakteer)
Future<void> showAboutSheet(BuildContext context) async {
  final Uri trakteerUri = Uri.parse('https://trakteer.id/kumadayo');

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;

      return Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        decoration: BoxDecoration(
          color: ColorsTheme.latarKomponen,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App / Mascot Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: ColorsTheme.kartuUtama.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          MascotAssets.payung,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title & Version
                      Text(
                        'TugasKu',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ColorsTheme.teks,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Versi 1.2.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorsTheme.teksSekunder,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        'Aplikasi manajemen jadwal kuliah dan tugas untuk mahasiswa yang produktif.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorsTheme.teksSekunder,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ============================================
                      // ICONIC QUOTE CARD
                      // ============================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsTheme.latar,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorsTheme.kartuUtama.withValues(
                              alpha: 0.15,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              size: 26,
                              color: ColorsTheme.kartuUtama.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"Lost in quiet places,\ndreaming of worlds with magic."',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                color: ColorsTheme.teks,
                                height: 1.6,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ============================================
                      // DEVELOPER CREDIT
                      // ============================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Crafted by ',
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorsTheme.teksSekunder,
                            ),
                          ),
                          Text(
                            'Kumadayo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ColorsTheme.teks,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ============================================
                      // TRAKTEER BUTTON
                      // ============================================
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              if (await canLaunchUrl(trakteerUri)) {
                                await launchUrl(
                                  trakteerUri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            } catch (e) {
                              debugPrint('Gagal membuka link trakteer: $e');
                            }
                          },
                          icon: const Icon(Icons.coffee_rounded, size: 20),
                          label: Text(
                            'Dukung di Trakteer ☕',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFC42B24,
                            ), // Warna khas Trakteer
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: ColorsTheme.teksSekunder,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
