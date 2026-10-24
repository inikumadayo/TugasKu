import 'package:adistyclone/core/theme/colors.dart';
import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  final String title;
  final String tugasapa;
  final bool isCompleted;
  final String sisaWaktu;
  final bool hasNotes;
  final Function(bool?)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskItem({
    super.key,
    required this.title,
    required this.tugasapa,
    required this.isCompleted,
    required this.onChanged,
    this.sisaWaktu = '',
    this.hasNotes = false,
    this.onTap,
    this.onDelete,
  });

  /// Menentukan apakah deadline tergolong mendesak (Besok, Hari ini, jam, menit)
  bool _isUrgentDeadline(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('besok') ||
        lower.contains('hari ini') ||
        lower.contains('jam') ||
        lower.contains('menit') ||
        lower.contains('1 hari')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna chip deadline
    final Color chipBg;
    final Color chipTextColor;
    final String chipLabel;

    if (isCompleted) {
      chipBg = ColorsTheme.selesai;
      chipTextColor = ColorsTheme.teksSelesai;
      chipLabel = 'Selesai';
    } else if (_isUrgentDeadline(sisaWaktu)) {
      chipBg = ColorsTheme.chipLempung;
      chipTextColor = ColorsTheme.teksChipLempung;
      chipLabel = sisaWaktu.isNotEmpty ? sisaWaktu : 'Besok';
    } else {
      chipBg = ColorsTheme.chipBatu;
      chipTextColor = ColorsTheme.teksChipBatu;
      chipLabel = sisaWaktu.isNotEmpty ? sisaWaktu : 'Mendatang';
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: ColorsTheme.latarKomponen,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            // Custom Circle Checkbox
            GestureDetector(
              onTap: () => onChanged?.call(!isCompleted),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? ColorsTheme.selesai : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? ColorsTheme.selesai
                        : ColorsTheme.aksen,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: ColorsTheme.teksSelesai,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCompleted
                          ? ColorsTheme.teksSekunder
                          : ColorsTheme.teks,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: ColorsTheme.teksSekunder,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (hasNotes) ...[
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 13,
                          color: ColorsTheme.aksen,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          tugasapa,
                          style: TextStyle(
                            color: ColorsTheme.teksSekunder,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Chip Status / Deadline
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chipLabel,
                style: TextStyle(
                  color: chipTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
