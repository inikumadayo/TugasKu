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
      height: 130,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    schedule.waktuMulai,
                    style: TextStyle(
                      color: ColorsTheme.teks,
                      fontSize: 14,
                      fontWeight: isOn ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    schedule.waktuSelesai,
                    style: TextStyle(
                      color: ColorsTheme.teks,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onDelete,
              child: Container(
                decoration: BoxDecoration(
                  color: isOn
                      ? ColorsTheme.kartuUtama
                      : ColorsTheme.latarKomponen,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isOn ? 0.08 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.title,
                        style: TextStyle(
                          color: isOn
                              ? ColorsTheme.latarKomponen
                              : ColorsTheme.teks,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Ruang: ${schedule.ruang}',
                        style: TextStyle(
                          color: isOn
                              ? ColorsTheme.latarKomponen.withValues(alpha: 0.7)
                              : ColorsTheme.teksSekunder,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isOn
                              ? ColorsTheme.latarKomponen.withValues(alpha: 0.2)
                              : ColorsTheme.aksen.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          schedule.jenis,
                          style: TextStyle(
                            color: isOn
                                ? ColorsTheme.latarKomponen.withValues(
                                    alpha: 0.9,
                                  )
                                : ColorsTheme.teks,
                            fontSize: 11,
                          ),
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
