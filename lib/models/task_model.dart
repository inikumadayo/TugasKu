import 'package:adistyclone/core/utils/date_time_helper.dart';

/// Model class untuk data Tugas/Task
class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? deadline;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.deadline,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
  String get sisaWaktu => DateTimeHelper.getRemainingTime(deadline);
}
