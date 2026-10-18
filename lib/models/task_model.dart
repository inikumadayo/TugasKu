/// Model class untuk data Tugas/Task
class TaskModel {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime? deadline;
  DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.deadline,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert ke Map untuk penyimpanan Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Buat TaskModel dari Map (data Hive)
  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Sisa waktu deadline sebagai string yang readable
  String get sisaWaktu {
    if (deadline == null) return 'Tanpa Deadline';

    final now = DateTime.now();
    final diff = deadline!.difference(now);

    if (diff.isNegative) return 'Terlambat';
    if (diff.inDays > 0) return '${diff.inDays} Hari';
    if (diff.inHours > 0) return '${diff.inHours} Jam';
    if (diff.inMinutes > 0) return '${diff.inMinutes} Menit';
    return 'Segera';
  }
}
