import 'package:adistyclone/core/theme/colors.dart';
import 'package:flutter/material.dart';

class FilterDate extends StatefulWidget {
  final String day;
  final String date;
  final bool isSelected;

  const FilterDate({
    super.key,
    required this.day,
    required this.date,
    required this.isSelected,
  });

  @override
  State<FilterDate> createState() => _FilterDateState();
}

class _FilterDateState extends State<FilterDate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 53.5,
      height: 60,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? ColorsTheme.kartuUtama
            : ColorsTheme.latarKomponen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.day,
            style: TextStyle(
              color: widget.isSelected
                  ? ColorsTheme.latarKomponen
                  : ColorsTheme.teks,
              fontSize: 14,
              fontWeight: widget.isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          SizedBox(height: 5),
          Text(
            widget.date,
            style: TextStyle(
              color: widget.isSelected
                  ? ColorsTheme.latarKomponen
                  : ColorsTheme.teks,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
