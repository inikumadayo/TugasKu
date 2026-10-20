import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/date_time_helper.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:adistyclone/presentation/widgets/cards/schedule_item.dart';
import 'package:adistyclone/presentation/widgets/dialogs/add_schedule_dialog.dart';
import 'package:adistyclone/presentation/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:adistyclone/presentation/widgets/filters/filter_date.dart';
import 'package:flutter/material.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  // Hari yang dipilih (1=Senin, ..., 7=Minggu), default hari ini
  late int _selectedHari;
  List<ScheduleModel> _schedules = [];

  // Data filter hari (akan digenerate otomatis dari minggu ini)
  late List<Map<String, dynamic>> _filterDays;

  @override
  void initState() {
    super.initState();
    _initDays();
    _loadSchedules();
    DateTimeHelper.heartbeat.addListener(_onHeartbeat);
  }

  void _onHeartbeat() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DateTimeHelper.heartbeat.removeListener(_onHeartbeat);
    super.dispose();
  }

  /// Generate daftar hari kerja (Senin-Sabtu) dalam minggu ini
  void _initDays() {
    final now = DateTime.now();
    // DateTime.weekday: 1=Monday ... 7=Sunday
    // Jika hari ini Minggu, default ke Senin
    _selectedHari = now.weekday <= 6 ? now.weekday : 1;
    _filterDays = DateTimeHelper.getWorkDaysInWeek(now);
  }

  /// Load jadwal dari database berdasarkan hari yang dipilih
  void _loadSchedules() {
    setState(() {
      _schedules = DatabaseHelper.getSchedulesByDay(_selectedHari);
    });
  }

  /// Nama hari lengkap
  String _getNamaHari(int hari) => DateTimeHelper.getNamaHari(hari);

  /// Format tanggal hari ini
  String _getFormattedDate() {
    final now = DateTime.now();
    return '${_getNamaHari(now.weekday)}, ${DateTimeHelper.getFormattedDate(now)}';
  }

  /// Tampilkan dialog untuk menambah jadwal baru
  void _showAddScheduleDialog() async {
    final saved = await showAddScheduleDialog(
      context,
      defaultHari: _selectedHari,
    );
    if (saved) _loadSchedules();
  }

  /// Konfirmasi hapus jadwal
  void _confirmDeleteSchedule(ScheduleModel schedule) async {
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Hapus Jadwal?',
      itemName: schedule.title,
    );

    if (confirmed) {
      await DatabaseHelper.deleteSchedule(schedule.id);
      _loadSchedules();
    }
  }

  /// Mencari ID jadwal yang sedang berlangsung atau terdekat yang akan datang hari ini
  String? _getActiveScheduleId() {
    final now = DateTime.now();
    // Hanya berlaku jika hari yang dipilih adalah hari ini
    if (_selectedHari != now.weekday) return null;

    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final schedule in _schedules) {
      if (schedule.waktuSelesai.compareTo(currentTime) >= 0) {
        return schedule.id;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final activeScheduleId = _getActiveScheduleId();

    return Scaffold(
      backgroundColor: ColorsTheme.latar,
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jadwal",
                          style: TextStyle(
                            color: ColorsTheme.teks,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          _getFormattedDate(),
                          style: TextStyle(
                            color: ColorsTheme.teks,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddScheduleDialog,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: ColorsTheme.aksen,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: ColorsTheme.teks,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_filterDays.length, (index) {
                  final day = _filterDays[index];
                  final isSelected = day['hari'] == _selectedHari;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedHari = day['hari'];
                      });
                      _loadSchedules();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterDate(
                        day: day['singkatan'],
                        date: day['tanggal'],
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _schedules.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              size: 64,
                              color: ColorsTheme.teksSekunder.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada jadwal hari ${_getNamaHari(_selectedHari)}',
                              style: TextStyle(
                                color: ColorsTheme.teksSekunder,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = _schedules[index];
                          return ScheduleItem(
                            schedule: schedule,
                            isOn: schedule.id == activeScheduleId,
                            onDelete: () =>
                                _confirmDeleteSchedule(_schedules[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
