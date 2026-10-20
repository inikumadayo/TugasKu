import 'package:adistyclone/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ButtonFilter extends StatelessWidget {
  final String title;
  final bool isSelected;

  const ButtonFilter({super.key, required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(right: 7),
      decoration: BoxDecoration(
        color: isSelected ? ColorsTheme.kartuUtama : ColorsTheme.latarKomponen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? ColorsTheme.latarKomponen : ColorsTheme.teks,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
