
import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/date_time_helper.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:flutter/material.dart';

class HeroDash extends StatefulWidget {
  const HeroDash({super.key});

  @override
  State<HeroDash> createState() => _HeroDashState();
}

class _HeroDashState extends State<HeroDash> {
  ScheduleModel? _nextSchedule;

  @override
  void initState() {
    super.initState();
    _findNextSchedule();
    DateTimeHelper.heartbeat.addListener(_onHeartbeat);
  }

  void _onHeartbeat() {
    if (mounted) _findNextSchedule();
  }

  @override
  void dispose() {
    DateTimeHelper.heartbeat.removeListener(_onHeartbeat);
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
    return DateTimeHelper.getTimeUntilSchedule(_nextSchedule!.waktuMulai);
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
                  ),
                ),
              ),
              Text(
                _getTimeUntil(),
                style: TextStyle(
                  color: ColorsTheme.latarKomponen,
                  fontSize: 14,
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
