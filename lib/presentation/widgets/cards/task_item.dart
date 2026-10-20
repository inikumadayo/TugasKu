import 'package:adistyclone/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskItem extends StatelessWidget {
  final String title;
  final String tugasapa;
  final bool isCompleted;
  final String sisaWaktu;
  final Function(bool?)? onChanged;
  final VoidCallback? onDelete;

  const TaskItem({
    super.key,
    required this.title,
    required this.tugasapa,
    required this.isCompleted,
    required this.onChanged,
    this.sisaWaktu = '',
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: ColorsTheme.latarKomponen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: onChanged,
                      activeColor: ColorsTheme.selesai,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: WidgetStateBorderSide.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return BorderSide(
                              color: ColorsTheme.selesai, width: 2);
                        }
                        return BorderSide(color: ColorsTheme.aksen, width: 2);
                      }),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: ColorsTheme.teks,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 4),
                        Text(
                          tugasapa,
                          style: TextStyle(
                            color: ColorsTheme.teks,
                            fontSize: 12,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted ? ColorsTheme.selesai : ColorsTheme.aksen,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isCompleted ? 'Selesai' : sisaWaktu,
                style: TextStyle(
                  color: ColorsTheme.teks,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 10,
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
