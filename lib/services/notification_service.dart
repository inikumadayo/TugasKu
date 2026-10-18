import 'dart:io';

import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service yang mengelola penjadwalan dan pembatalan notifikasi lokal
/// untuk Jadwal Kuliah dan Pengingat Tugas.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelScheduleId = 'kuliah_channel';
  static const String _channelScheduleName = 'Jadwal Kuliah';
  static const String _channelScheduleDesc =
      'Notifikasi pengingat sebelum jadwal perkuliahan dimulai';

  static const String _channelTaskId = 'tugas_channel';
  static const String _channelTaskName = 'Pengingat Tugas';
  static const String _channelTaskDesc =
      'Notifikasi pengingat batas waktu/deadline tugas kuliah';

  /// Inisialisasi service, timezone, dan channel notifikasi
  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      // Default timezone Indonesia Barat
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      // Fallback ke local default jika tidak ditemukan
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notifikasi diklik: ${details.payload}');
      },
    );

    // Request permissions pada Android 13+
    await requestPermissions();

    // Buat Notification Channels di Android
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelScheduleId,
            _channelScheduleName,
            description: _channelScheduleDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelTaskId,
            _channelTaskName,
            description: _channelTaskDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
    }

    // Sinkronkan seluruh notifikasi yang aktif saat aplikasi dimulai
    await syncAll();
  }

  /// Meminta izin notifikasi (Android 13+ & iOS)
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted =
          await androidPlugin?.requestNotificationsPermission() ?? false;
      await androidPlugin?.requestExactAlarmsPermission();
      return granted;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  // ============================================================
  //  ID GENERATOR
  // ============================================================

  /// Menghasilkan integer 32-bit deterministik dari String ID
  static int _getNotificationId(String id, {int offset = 0}) {
    return (id.hashCode.abs() + offset) % 2147483647;
  }

  // ============================================================
  //  JADWAL KULIAH (SCHEDULE)
  // ============================================================

  /// Menjadwalkan notifikasi berulang mingguan 15 menit sebelum kuliah dimulai
  static Future<void> scheduleClassNotification(ScheduleModel schedule) async {
    if (!DatabaseHelper.isClassNotificationEnabled()) return;

    try {
      final parts = schedule.waktuMulai.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Ambil preferensi menit pengingat (default 15 menit)
      final timingMinutes = DatabaseHelper.getClassNotificationTiming();

      int totalMinutes = hour * 60 + minute - timingMinutes;
      int targetDay = schedule.hari; // 1 = Senin, 7 = Minggu
      if (totalMinutes < 0) {
        totalMinutes += 24 * 60;
        targetDay = targetDay == 1 ? 7 : targetDay - 1;
      }
      final notifHour = totalMinutes ~/ 60;
      final notifMinute = totalMinutes % 60;

      final scheduledDate = _nextInstanceOfWeekdayTime(
        targetDay,
        notifHour,
        notifMinute,
      );

      final notifId = _getNotificationId(schedule.id, offset: 100000);

      // Custom sound jika ada
      final soundPath = DatabaseHelper.getClassNotificationSoundPath();
      AndroidNotificationSound? androidSound;
      if (soundPath != null && File(soundPath).existsSync()) {
        androidSound = UriAndroidNotificationSound(soundPath);
      }

      String notifTitle;
      if (timingMinutes == 0) {
        notifTitle = 'Kuliah Dimulai Sekarang: ${schedule.title}';
      } else if (timingMinutes >= 60) {
        notifTitle = 'Kuliah ${timingMinutes ~/ 60} Jam Lagi: ${schedule.title}';
      } else {
        notifTitle = 'Kuliah $timingMinutes Menit Lagi: ${schedule.title}';
      }

      await _notifications.zonedSchedule(
        id: notifId,
        title: notifTitle,
        body:
            'Ruang ${schedule.ruang} • ${schedule.waktuMulai} - ${schedule.waktuSelesai}',
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelScheduleId,
            _channelScheduleName,
            channelDescription: _channelScheduleDesc,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            sound: androidSound,
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Gagal menjadwalkan notifikasi kuliah: $e');
    }
  }

  /// Menghitung instance berikutnya dari hari & jam yang ditentukan
  static tz.TZDateTime _nextInstanceOfWeekdayTime(
    int targetWeekday,
    int hour,
    int minute,
  ) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Cari hari yang sesuai dan pastikan waktunya di masa mendatang
    while (scheduledDate.weekday != targetWeekday ||
        scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Batalkan notifikasi jadwal tertentu
  static Future<void> cancelClassNotification(String scheduleId) async {
    final notifId = _getNotificationId(scheduleId, offset: 100000);
    await _notifications.cancel(id: notifId);
  }

  /// Batalkan semua notifikasi jadwal kuliah
  static Future<void> cancelAllClassNotifications() async {
    final schedules = DatabaseHelper.getAllSchedules();
    for (final s in schedules) {
      await cancelClassNotification(s.id);
    }
  }

  /// Jadwalkan ulang semua notifikasi jadwal kuliah
  static Future<void> rescheduleAllClassNotifications() async {
    await cancelAllClassNotifications();
    if (!DatabaseHelper.isClassNotificationEnabled()) return;

    final schedules = DatabaseHelper.getAllSchedules();
    for (final s in schedules) {
      await scheduleClassNotification(s);
    }
  }

  // ============================================================
  //  PENGINGAT TUGAS (TASK)
  // ============================================================

  /// Menjadwalkan pengingat deadline tugas
  static Future<void> scheduleTaskNotification(TaskModel task) async {
    if (!DatabaseHelper.isTaskReminderEnabled()) return;
    if (task.isCompleted || task.deadline == null) {
      await cancelTaskNotification(task.id);
      return;
    }

    try {
      final now = DateTime.now();
      final deadline = task.deadline!;

      // Jika deadline sudah lewat, abaikan
      if (deadline.isBefore(now)) return;

      final notifId = _getNotificationId(task.id, offset: 200000);

      // Ambil preferensi timing tugas (default 1440 menit / 1 hari)
      final timingMinutes = DatabaseHelper.getTaskReminderTiming();
      final reminderTime = deadline.subtract(Duration(minutes: timingMinutes));

      if (reminderTime.isAfter(now)) {
        final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

        final soundPath = DatabaseHelper.getTaskReminderSoundPath();
        AndroidNotificationSound? androidSound;
        if (soundPath != null && File(soundPath).existsSync()) {
          androidSound = UriAndroidNotificationSound(soundPath);
        }

        String timeLabel;
        if (timingMinutes >= 1440) {
          timeLabel = 'Besok';
        } else if (timingMinutes >= 60) {
          timeLabel = '${timingMinutes ~/ 60} Jam Lagi';
        } else {
          timeLabel = '$timingMinutes Menit Lagi';
        }

        await _notifications.zonedSchedule(
          id: notifId,
          title: 'Pengingat Deadline Tugas ($timeLabel): ${task.title}',
          body: task.description.isNotEmpty
              ? task.description
              : 'Batas pengumpulan segera berakhir. Segera selesaikan!',
          scheduledDate: scheduledDate,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channelTaskId,
              _channelTaskName,
              channelDescription: _channelTaskDesc,
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              sound: androidSound,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Gagal menjadwalkan notifikasi tugas: $e');
    }
  }

  /// Batalkan notifikasi tugas tertentu
  static Future<void> cancelTaskNotification(String taskId) async {
    final notifIdH1 = _getNotificationId(taskId, offset: 200000);
    final notifIdHDay = _getNotificationId(taskId, offset: 300000);
    await _notifications.cancel(id: notifIdH1);
    await _notifications.cancel(id: notifIdHDay);
  }

  /// Batalkan semua notifikasi tugas
  static Future<void> cancelAllTaskNotifications() async {
    final tasks = DatabaseHelper.getAllTasks();
    for (final t in tasks) {
      await cancelTaskNotification(t.id);
    }
  }

  /// Jadwalkan ulang semua notifikasi tugas
  static Future<void> rescheduleAllTaskNotifications() async {
    await cancelAllTaskNotifications();
    if (!DatabaseHelper.isTaskReminderEnabled()) return;

    final tasks = DatabaseHelper.getAllTasks();
    for (final t in tasks) {
      if (!t.isCompleted) {
        await scheduleTaskNotification(t);
      }
    }
  }

  // ============================================================
  //  SINKRONISASI KESELURUHAN
  // ============================================================

  /// Sinkronisasi seluruh notifikasi sesuai preferensi database
  static Future<void> syncAll() async {
    if (DatabaseHelper.isClassNotificationEnabled()) {
      await rescheduleAllClassNotifications();
    } else {
      await cancelAllClassNotifications();
    }

    if (DatabaseHelper.isTaskReminderEnabled()) {
      await rescheduleAllTaskNotifications();
    } else {
      await cancelAllTaskNotifications();
    }
  }
}
