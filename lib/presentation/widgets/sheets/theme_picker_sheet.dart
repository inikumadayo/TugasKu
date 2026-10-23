import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:flutter/material.dart';

/// Menampilkan bottom sheet pemilih tema (Matcha Paper / Rainy Garden)
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
                  color: ColorsTheme.teksSekunder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Tema',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorsTheme.teks,
                ),
              ),
              const SizedBox(height: 20),

              // Matcha Paper (Light)
              _buildThemeOption(
                name: 'Matcha Paper',
                subtitle: 'Kertas lukisan tinta',
                colors: [
                  ColorLight.latar,
                  ColorLight.kartuUtama,
                  ColorLight.aksen,
                  ColorLight.selesai,
                  ColorLight.chipLempung,
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

              // Rainy Garden (Dark)
              _buildThemeOption(
                name: 'Rainy Garden',
                subtitle: 'Arang kehijauan',
                colors: [
                  ColorDark.latar,
                  ColorDark.kartuUtama,
                  ColorDark.aksen,
                  ColorDark.selesai,
                  ColorDark.chipLempung,
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
        color: isSelected
            ? ColorsTheme.kartuUtama
            : ColorsTheme.teksSekunder.withValues(alpha: 0.2),
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
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.15),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorsTheme.teks,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
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
