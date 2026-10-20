import 'dart:async';

import 'package:flutter/material.dart';

/// Helper kelas untuk pemrosesan, formatting, dan kalkulasi tanggal & waktu.
class DateTimeHelper {
  static Timer? _heartbeatTimer;

  /// Heartbeat ticker tunggal untuk seluruh aplikasi (update setiap 30 detik)
  static final ValueNotifier<DateTime> heartbeat = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  /// Mulai timer heartbeat terpusat
  static void startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      heartbeat.value = DateTime.now();
    });
  }

  /// Hentikan timer heartbeat
  static void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Nama hari lengkap (1 = Senin, ..., 7 = Minggu, indeks 0 dummy)
  static const List<String> namaHari = [
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  /// Singkatan hari kerja (Senin - Sabtu)
  static const List<String> singkatanHari = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  /// Nama bulan bahasa Indonesia
  static const List<String> namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Mendapatkan nama hari lengkap dari angka 1-7
  static String getNamaHari(int hari) {
    if (hari >= 1 && hari <= 7) {
      return namaHari[hari];
    }
    return '';
  }

  /// Format tanggal dengan gaya: "20 Oktober 2026"
  static String getFormattedDate([DateTime? date]) {
    final target = date ?? DateTime.now();
    return '${target.day} ${namaBulan[target.month]} ${target.year}';
  }

  /// Menghasilkan daftar hari kerja (Senin-Sabtu) untuk minggu ini
  static List<Map<String, dynamic>> getWorkDaysInWeek([DateTime? date]) {
    final now = date ?? DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(6, (i) {
      final day = monday.add(Duration(days: i));
      return {
        'singkatan': singkatanHari[i],
        'tanggal': day.day.toString(),
        'hari': i + 1,
      };
    });
  }

  /// Format [TimeOfDay] menjadi string "HH:mm" (2 digit zero-padded)
  static String formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Parsing string waktu "HH:mm" menjadi [TimeOfDay]
  static TimeOfDay parseTime(
    String text, {
    TimeOfDay fallback = const TimeOfDay(hour: 0, minute: 0),
  }) {
    if (text.isEmpty) return fallback;
    final parts = text.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) {
        return TimeOfDay(hour: h, minute: m);
      }
    }
    return fallback;
  }

  /// Hitung sisa waktu hingga deadline task (contoh: "3 Hari", "2 Jam", "Terlambat")
  static String getRemainingTime(
    DateTime? deadline, {
    String fallback = 'Tanpa Deadline',
  }) {
    if (deadline == null) return fallback;

    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) return 'Terlambat';
    if (diff.inDays > 0) return '${diff.inDays} Hari';
    if (diff.inHours > 0) return '${diff.inHours} Jam';
    if (diff.inMinutes > 0) return '${diff.inMinutes} Menit';
    return 'Segera';
  }

  /// Hitung estimasi waktu countdown hingga jadwal mulai hari ini (format "HH:mm")
  static String getTimeUntilSchedule(String waktuMulai) {
    final parts = waktuMulai.split(':');
    if (parts.length < 2) return '';

    final now = DateTime.now();
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
}
