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
  bool _hasSchedulesToday = false;

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
      setState(() {
        _hasSchedulesToday = false;
        _nextSchedule = null;
      });
      return;
    }

    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Cari jadwal yang belum selesai (waktu selesai masih di masa depan)
    ScheduleModel? next;
    for (final schedule in todaySchedules) {
      if (schedule.waktuSelesai.compareTo(currentTime) > 0) {
        next = schedule;
        break;
      }
    }

    setState(() {
      _hasSchedulesToday = true;
      _nextSchedule = next;
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
                _hasSchedulesToday
                    ? Icons.task_alt_rounded
                    : Icons.event_available_rounded,
                color: ColorsTheme.teksDiKartu.withValues(alpha: 0.8),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _hasSchedulesToday
                    ? 'Tidak ada jadwal lagi hari ini'
                    : 'Tidak ada jadwal hari ini',
                style: TextStyle(
                  color: ColorsTheme.teksDiKartu,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_hasSchedulesToday) ...[
                const SizedBox(height: 4),
                Text(
                  'Semua jadwal kuliah sudah selesai',
                  style: TextStyle(
                    color: ColorsTheme.teksDiKartu.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final pillBg = ColorsTheme.teksDiKartu.withValues(alpha: 0.18);
    final badgeLabel = _nextSchedule!.jenis.isNotEmpty
        ? '${_nextSchedule!.jenis} terdekat'
        : 'Kuliah terdekat';
    final roomLabel = _nextSchedule!.ruang.startsWith('Ruang')
        ? _nextSchedule!.ruang
        : 'Ruang ${_nextSchedule!.ruang}';

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: ColorsTheme.kartuUtama,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Badge and countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: ColorsTheme.teksDiKartu,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _getTimeUntil(),
                style: TextStyle(
                  color: ColorsTheme.teksDiKartu,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Middle: Title and subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  _nextSchedule!.title,
                  style: TextStyle(
                    color: ColorsTheme.teksDiKartu,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  (_nextSchedule!.dosenPengampu != null &&
                          _nextSchedule!.dosenPengampu!.isNotEmpty)
                      ? _nextSchedule!.dosenPengampu!
                      : _nextSchedule!.jenis,
                  style: TextStyle(
                    color: ColorsTheme.teksDiKartu.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          // Bottom: Time, Room, and SKS pills
          Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${_nextSchedule!.waktuMulai} – ${_nextSchedule!.waktuSelesai}',
                      style: TextStyle(
                        color: ColorsTheme.teksDiKartu,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      roomLabel,
                      style: TextStyle(
                        color: ColorsTheme.teksDiKartu,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_nextSchedule!.sks != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${_nextSchedule!.sks} SKS',
                        style: TextStyle(
                          color: ColorsTheme.teksDiKartu,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
