import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:flutter/material.dart';

class ScheduleItem extends StatelessWidget {
  final ScheduleModel schedule;
  final bool isOn;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ScheduleItem({
    super.key,
    required this.schedule,
    this.isOn = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    schedule.waktuMulai,
                    style: TextStyle(
                      color: isOn ? ColorsTheme.aksen : ColorsTheme.teks,
                      fontSize: 14,
                      fontWeight: isOn ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  Text(
                    schedule.waktuSelesai,
                    style: TextStyle(
                      color: ColorsTheme.teksSekunder,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onDelete,
              child: Container(
                decoration: BoxDecoration(
                  color: isOn
                      ? ColorsTheme.kartuUtama
                      : ColorsTheme.latarKomponen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: ColorsTheme.isDarkMode ? 0.2 : 0.04,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.title,
                        style: TextStyle(
                          color: isOn
                              ? ColorsTheme.teksDiKartu
                              : ColorsTheme.teks,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (schedule.dosenPengampu != null &&
                                schedule.dosenPengampu!.isNotEmpty)
                            ? schedule.dosenPengampu!
                            : 'Dosen pengampu',
                        style: TextStyle(
                          color: isOn
                              ? ColorsTheme.teksDiKartu.withValues(alpha: 0.8)
                              : ColorsTheme.teksSekunder,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Badge Jenis
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isOn
                                    ? ColorsTheme.teksDiKartu
                                        .withValues(alpha: 0.2)
                                    : ColorsTheme.aksen.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                schedule.jenis,
                                style: TextStyle(
                                  color: isOn
                                      ? ColorsTheme.teksDiKartu
                                      : ColorsTheme.aksen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // Badge Ruangan (ditaruh sebagai badge di depan SKS)
                            if (schedule.ruang.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isOn
                                      ? ColorsTheme.teksDiKartu
                                          .withValues(alpha: 0.2)
                                      : ColorsTheme.chipLempung,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  schedule.ruang.startsWith('Ruang') ||
                                          schedule.ruang.startsWith('R.')
                                      ? schedule.ruang
                                      : 'R. ${schedule.ruang}',
                                  style: TextStyle(
                                    color: isOn
                                        ? ColorsTheme.teksDiKartu
                                        : ColorsTheme.teksChipLempung,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],

                            // Badge SKS
                            if (schedule.sks != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isOn
                                      ? ColorsTheme.teksDiKartu
                                      .withValues(alpha: 0.2)
                                      : ColorsTheme.chipBatu,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${schedule.sks} SKS',
                                  style: TextStyle(
                                    color: isOn
                                        ? ColorsTheme.teksDiKartu
                                        : ColorsTheme.teksChipBatu,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
