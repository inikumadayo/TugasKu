import 'package:adistyclone/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ButtonFilter extends StatelessWidget {
  final String title;
  final bool isSelected;

  const ButtonFilter({
    super.key,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isSelected ? ColorsTheme.kartuUtama : ColorsTheme.latarKomponen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? ColorsTheme.teksDiKartu : ColorsTheme.teks,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
