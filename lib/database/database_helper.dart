import 'package:hive_flutter/hive_flutter.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:adistyclone/models/user_profile_model.dart';

/// Database helper class yang mengelola semua operasi CRUD
/// menggunakan Hive sebagai local NoSQL database.
class DatabaseHelper {
  static const String _scheduleBox = 'schedules';
  static const String _taskBox = 'tasks';
  static const String _profileBox = 'user_profile';

  /// Inisialisasi Hive — panggil di main() sebelum runApp()
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_scheduleBox);
    await Hive.openBox(_taskBox);
    await Hive.openBox(_profileBox);
  }

  // ============================================================
  //  SCHEDULE CRUD
  // ============================================================

  /// Mendapatkan box schedule
  static Box get _schedules => Hive.box(_scheduleBox);

  /// Tambah jadwal baru
  static Future<void> addSchedule(ScheduleModel schedule) async {
    await _schedules.put(schedule.id, schedule.toMap());
  }

  /// Ambil semua jadwal
  static List<ScheduleModel> getAllSchedules() {
    return _schedules.values
        .map((e) => ScheduleModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  /// Ambil jadwal berdasarkan hari (1=Senin, ..., 7=Minggu)
  static List<ScheduleModel> getSchedulesByDay(int hari) {
    return getAllSchedules().where((s) => s.hari == hari).toList()
      ..sort((a, b) => a.waktuMulai.compareTo(b.waktuMulai));
  }

  /// Update jadwal
  static Future<void> updateSchedule(ScheduleModel schedule) async {
    await _schedules.put(schedule.id, schedule.toMap());
  }

  /// Hapus jadwal
  static Future<void> deleteSchedule(String id) async {
    await _schedules.delete(id);
  }

  /// Ambil jadwal berdasarkan ID
  static ScheduleModel? getScheduleById(String id) {
    final data = _schedules.get(id);
    if (data == null) return null;
    return ScheduleModel.fromMap(data as Map<dynamic, dynamic>);
  }

  // ============================================================
  //  TASK CRUD
  // ============================================================

  /// Mendapatkan box task
  static Box get _tasks => Hive.box(_taskBox);

  /// Tambah tugas baru
  static Future<void> addTask(TaskModel task) async {
    await _tasks.put(task.id, task.toMap());
  }

  /// Ambil semua tugas
  static List<TaskModel> getAllTasks() {
    return _tasks.values
        .map((e) => TaskModel.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Ambil tugas yang belum selesai
  static List<TaskModel> getIncompleteTasks() {
    return getAllTasks().where((t) => !t.isCompleted).toList();
  }

  /// Ambil tugas yang sudah selesai
  static List<TaskModel> getCompletedTasks() {
    return getAllTasks().where((t) => t.isCompleted).toList();
  }

  /// Toggle status selesai tugas
  static Future<void> toggleTaskCompletion(String id) async {
    final task = getTaskById(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await _tasks.put(id, task.toMap());
    }
  }

  /// Update tugas
  static Future<void> updateTask(TaskModel task) async {
    await _tasks.put(task.id, task.toMap());
  }

  /// Hapus tugas
  static Future<void> deleteTask(String id) async {
    await _tasks.delete(id);
  }

  /// Ambil tugas berdasarkan ID
  static TaskModel? getTaskById(String id) {
    final data = _tasks.get(id);
    if (data == null) return null;
    return TaskModel.fromMap(data as Map<dynamic, dynamic>);
  }

  /// Jumlah tugas yang sudah selesai
  static int completedTaskCount() {
    return getAllTasks().where((t) => t.isCompleted).length;
  }

  /// Total jumlah tugas
  static int totalTaskCount() {
    return getAllTasks().length;
  }

  /// Hapus task yang sudah lewat deadline saat berganti ke awal minggu baru (Senin).
  ///
  /// Aturan:
  /// 1. Task dari minggu-minggu sebelumnya yang deadlinenya sebelum hari Senin minggu ini (jam 00:00:00) akan dihapus.
  /// 2. Task yang deadlinenya di minggu berjalan (termasuk hari Minggu) akan tetap tersimpan sampai minggu berganti ke hari Senin berikutnya.
  /// 3. Berlaku untuk semua task baik yang sudah selesai maupun belum.
  /// 4. Task tanpa deadline tidak akan dihapus.
  static Future<int> deleteExpiredWeeklyTasks() async {
    final now = DateTime.now();

    // Hari Senin minggu ini jam 00:00:00
    final startOfThisWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final allTasks = getAllTasks();
    final List<String> taskIdsToDelete = [];

    for (final task in allTasks) {
      if (task.deadline == null) continue;

      // Hapus jika deadlinenya berada sebelum hari Senin minggu ini
      if (task.deadline!.isBefore(startOfThisWeek)) {
        taskIdsToDelete.add(task.id);
      }
    }

    for (final id in taskIdsToDelete) {
      await deleteTask(id);
    }

    return taskIdsToDelete.length;
  }

  // ============================================================
  //  USER PROFILE
  // ============================================================

  /// Mendapatkan box user profile
  static Box get _profile => Hive.box(_profileBox);

  /// Ambil data profil pengguna
  static UserProfileModel getUserProfile() {
    final data = _profile.get('profile');
    if (data == null) {
      return UserProfileModel(
        name: 'Kuma dayo',
        description: 'Yahooo',
        isInitialized: false,
      );
    }
    return UserProfileModel.fromMap(data as Map<dynamic, dynamic>);
  }

  /// Simpan atau perbarui data profil pengguna
  static Future<void> saveUserProfile(UserProfileModel profile) async {
    await _profile.put('profile', profile.toMap());
  }

  /// Cek apakah pengguna sudah pernah mengisi profil (pertama kali buka aplikasi)
  static bool isProfileInitialized() {
    final data = _profile.get('profile');
    if (data == null) return false;
    return (data['isInitialized'] as bool?) ?? false;
  }

  // ============================================================
  //  SEED DATA (Data awal untuk testing)
  // ============================================================

  /// Isi database dengan data contoh HANYA pada instalasi pertama kali
  static Future<void> seedIfEmpty() async {
    final hasSeeded =
        (_profile.get('has_seeded_initial_data') as bool?) ?? false;
    if (hasSeeded) return;

    if (_schedules.isEmpty) {
      final sampleSchedules = [
        ScheduleModel(
          id: 's1',
          title: 'Pemrograman Web Dinamis',
          ruang: '4.1.4.34',
          waktuMulai: '08:00',
          waktuSelesai: '09:40',
          jenis: 'Mata Kuliah',
          hari: 1,
        ),
        ScheduleModel(
          id: 's2',
          title: 'Basis Data Lanjut',
          ruang: '4.1.3.21',
          waktuMulai: '10:00',
          waktuSelesai: '11:40',
          jenis: 'Mata Kuliah',
          hari: 1,
        ),
        ScheduleModel(
          id: 's3',
          title: 'Pemrograman Mobile',
          ruang: '4.1.4.32',
          waktuMulai: '13:00',
          waktuSelesai: '14:40',
          jenis: 'Mata Kuliah',
          hari: 2,
        ),
        ScheduleModel(
          id: 's4',
          title: 'Kecerdasan Buatan',
          ruang: '4.1.3.22',
          waktuMulai: '08:00',
          waktuSelesai: '09:40',
          jenis: 'Mata Kuliah',
          hari: 3,
        ),
        ScheduleModel(
          id: 's5',
          title: 'Jaringan Komputer',
          ruang: '4.1.2.15',
          waktuMulai: '10:00',
          waktuSelesai: '11:40',
          jenis: 'Mata Kuliah',
          hari: 4,
        ),
        ScheduleModel(
          id: 's6',
          title: 'Rekayasa Perangkat Lunak',
          ruang: '4.1.4.35',
          waktuMulai: '08:00',
          waktuSelesai: '09:40',
          jenis: 'Mata Kuliah',
          hari: 5,
        ),
      ];

      for (final schedule in sampleSchedules) {
        await addSchedule(schedule);
      }
    }

    if (_tasks.isEmpty) {
      final sampleTasks = [
        TaskModel(
          id: 't1',
          title: 'Tugas PWD',
          description: 'Pemrograman Web Dinamis',
          deadline: DateTime.now().add(const Duration(days: 2)),
        ),
        TaskModel(
          id: 't2',
          title: 'Laporan Basis Data',
          description: 'Basis Data Lanjut',
          deadline: DateTime.now().add(const Duration(days: 5)),
        ),
        TaskModel(
          id: 't3',
          title: 'Project Mobile App',
          description: 'Pemrograman Mobile',
          deadline: DateTime.now().add(const Duration(days: 7)),
        ),
        TaskModel(
          id: 't4',
          title: 'Makalah AI',
          description: 'Kecerdasan Buatan',
          isCompleted: true,
          deadline: DateTime.now().add(const Duration(days: 1)),
        ),
        TaskModel(
          id: 't5',
          title: 'Quiz Jaringan',
          description: 'Jaringan Komputer',
          deadline: DateTime.now().add(const Duration(hours: 48)),
        ),
      ];

      for (final task in sampleTasks) {
        await addTask(task);
      }
    }

    // Tandai bahwa seeding pertama kali sudah selesai
    await _profile.put('has_seeded_initial_data', true);
  }
}
