import 'dart:async';

import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroDash extends StatefulWidget {
  const HeroDash({super.key});

  @override
  State<HeroDash> createState() => _HeroDashState();
}

class _HeroDashState extends State<HeroDash> {
  ScheduleModel? _nextSchedule;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _findNextSchedule();

    // Update berkala agar hitung mundur dan jadwal terdekat update realtime
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _findNextSchedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Cari jadwal terdekat hari ini
  void _findNextSchedule() {
    final now = DateTime.now();
    final todaySchedules = DatabaseHelper.getSchedulesByDay(now.weekday);

    if (todaySchedules.isEmpty) {
      setState(() => _nextSchedule = null);
      return;
    }

    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Cari jadwal yang belum lewat
    ScheduleModel? next;
    for (final schedule in todaySchedules) {
      if (schedule.waktuSelesai.compareTo(currentTime) > 0) {
        next = schedule;
        break;
      }
    }

    setState(() {
      _nextSchedule =
          next ?? (todaySchedules.isNotEmpty ? todaySchedules.first : null);
    });
  }

  /// Hitung estimasi waktu ke jadwal berikutnya
  String _getTimeUntil() {
    if (_nextSchedule == null) return '';

    final now = DateTime.now();
    final parts = _nextSchedule!.waktuMulai.split(':');
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final diff = scheduleTime.difference(now);

    if (diff.isNegative) return 'Sedang berlangsung';
    if (diff.inHours > 0) return 'dalam ${diff.inHours} Jam';
    if (diff.inMinutes > 0) return 'dalam ${diff.inMinutes} Menit';
    return 'Segera dimulai';
  }

  @override
  Widget build(BuildContext context) {
    if (_nextSchedule == null) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorsTheme.kartuUtama,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available_rounded,
                color: ColorsTheme.latarKomponen.withValues(alpha: 0.7),
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'Tidak ada jadwal hari ini',
                style: TextStyle(
                  color: ColorsTheme.latarKomponen.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsTheme.kartuUtama,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: ColorsTheme.latarKomponen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _nextSchedule!.jenis,
                  style: TextStyle(
                    color: ColorsTheme.latarKomponen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
              ),
              Text(
                _getTimeUntil(),
                style: TextStyle(
                  color: ColorsTheme.latarKomponen,
                  fontSize: 14,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  _nextSchedule!.title,
                  style: TextStyle(
                    color: ColorsTheme.latarKomponen,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  _nextSchedule!.namaHari,
                  style: TextStyle(
                    color: ColorsTheme.latarKomponen,
                    fontSize: 14,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: ColorsTheme.latarKomponen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${_nextSchedule!.waktuMulai} - ${_nextSchedule!.waktuSelesai}',
                  style: TextStyle(
                    color: ColorsTheme.latarKomponen,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: ColorsTheme.latarKomponen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Ruang: ${_nextSchedule!.ruang}',
                  style: TextStyle(
                    color: ColorsTheme.latarKomponen,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
