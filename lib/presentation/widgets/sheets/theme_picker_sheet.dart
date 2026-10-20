import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Menampilkan bottom sheet pemilih tema (Blueberry Oat / Midnight Navy)
Future<void> showThemePickerSheet(
  BuildContext context, {
  VoidCallback? onThemeChanged,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => StatefulBuilder(
      builder: (ctx, setModalState) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: ColorsTheme.latarKomponen,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Tema',
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorsTheme.teks,
                ),
              ),
              const SizedBox(height: 20),

              // Blueberry Oat (Light)
              _buildThemeOption(
                name: 'Blueberry Oat',
                subtitle: 'Tema terang yang lembut',
                colors: [
                  ColorLight.latar,
                  ColorLight.kartuUtama,
                  ColorLight.aksen,
                  ColorLight.selesai,
                ],
                isSelected: !ColorsTheme.isDarkMode,
                onTap: () {
                  ColorsTheme.setDarkMode(false);
                  DatabaseHelper.setThemeDarkMode(false);
                  Navigator.of(bottomSheetContext).pop();
                  onThemeChanged?.call();
                },
              ),
              const SizedBox(height: 12),

              // Midnight Navy (Dark)
              _buildThemeOption(
                name: 'Blueberry Oat Dark',
                subtitle: 'Tema gelap yang elegan',
                colors: [
                  ColorDark.latar,
                  ColorDark.kartuUtama,
                  ColorDark.aksen,
                  ColorDark.selesai,
                ],
                isSelected: ColorsTheme.isDarkMode,
                onTap: () {
                  ColorsTheme.setDarkMode(true);
                  DatabaseHelper.setThemeDarkMode(true);
                  Navigator.of(bottomSheetContext).pop();
                  onThemeChanged?.call();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildThemeOption({
  required String name,
  required String subtitle,
  required List<Color> colors,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      color: isSelected
          ? ColorsTheme.kartuUtama.withValues(alpha: 0.08)
          : ColorsTheme.latar,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSelected ? ColorsTheme.kartuUtama : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color preview circles
              Row(
                children: colors
                    .map(
                      (c) => Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorsTheme.teks,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 11,
                        color: ColorsTheme.teksSekunder,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: ColorsTheme.kartuUtama,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
