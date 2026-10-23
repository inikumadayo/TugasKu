import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/date_time_helper.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:adistyclone/presentation/widgets/cards/task_item.dart';
import 'package:adistyclone/presentation/widgets/dialogs/add_task_dialog.dart';
import 'package:adistyclone/presentation/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:adistyclone/presentation/widgets/filters/filter.dart';
import 'package:flutter/material.dart';

class Task extends StatefulWidget {
  const Task({super.key});

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  String _activeFilter = 'Semua';

  final List<List<dynamic>> filterTask = [
    ['Semua', true],
    ['Belum Selesai', false],
    ['Selesai', false],
  ];

  @override
  void initState() {
    super.initState();
    _initTasks();
    DateTimeHelper.heartbeat.addListener(_onHeartbeat);
  }

  void _onHeartbeat() {
    if (mounted) {
      DatabaseHelper.deleteExpiredWeeklyTasks().then((deleted) {
        if (deleted > 0 && mounted) {
          setState(() {});
        }
      });
    }
  }

  void _initTasks() async {
    await DatabaseHelper.deleteExpiredWeeklyTasks();
  }

  @override
  void dispose() {
    DateTimeHelper.heartbeat.removeListener(_onHeartbeat);
    super.dispose();
  }

  /// Ambil tugas dari database sesuai filter aktif
  List<TaskModel> _getFilteredTasks() {
    switch (_activeFilter) {
      case 'Belum Selesai':
        return DatabaseHelper.getIncompleteTasks();
      case 'Selesai':
        return DatabaseHelper.getCompletedTasks();
      default:
        return DatabaseHelper.getAllTasks();
    }
  }

  void checkBoxChanged(bool? value, String taskId) async {
    await DatabaseHelper.toggleTaskCompletion(taskId);
  }

  /// Tampilkan dialog untuk menambah tugas baru
  void _showAddTaskDialog() async {
    await showAddTaskDialog(context);
  }

  /// Konfirmasi hapus tugas
  void _confirmDeleteTask(TaskModel task) async {
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Hapus Tugas?',
      itemName: task.title,
    );

    if (confirmed) {
      await DatabaseHelper.deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: DatabaseHelper.tasksListenable(),
      builder: (context, box, child) {
        final totalTasks = DatabaseHelper.totalTaskCount();
        final completedTasks = DatabaseHelper.completedTaskCount();
        final incompleteTasks = totalTasks - completedTasks;
        final currentTasks = _getFilteredTasks();

        return Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tugas",
                            style: TextStyle(
                              color: ColorsTheme.teks,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "$incompleteTasks Belum Selesai",
                            style: TextStyle(
                              color: ColorsTheme.teks,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddTaskDialog,
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
                            color: ColorsTheme.teksDiAksen,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: filterTask.map((filter) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          for (var f in filterTask) {
                            f[1] = false;
                          }
                          filter[1] = true;
                          _activeFilter = filter[0];
                        });
                      },
                      child: ButtonFilter(
                        title: filter[0],
                        isSelected: filter[1],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsTheme.latarKomponen,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Minggu Ini",
                            style: TextStyle(
                              color: ColorsTheme.teks,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$completedTasks dari $totalTasks Selesai",
                            style: TextStyle(
                              color: ColorsTheme.teks,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Transform.scale(
                        scaleY: 2.8,
                        child: LinearProgressIndicator(
                          value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                          borderRadius: BorderRadius.circular(20),
                          backgroundColor: ColorsTheme.kartuUtama.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorsTheme.aksen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: currentTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt_rounded,
                                size: 64,
                                color: ColorsTheme.teksSekunder.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada tugas',
                                style: TextStyle(
                                  color: ColorsTheme.teksSekunder,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: currentTasks.length,
                          itemBuilder: (context, index) {
                            final task = currentTasks[index];
                            return TaskItem(
                              title: task.title,
                              tugasapa: task.description,
                              isCompleted: task.isCompleted,
                              sisaWaktu: task.sisaWaktu,
                              onChanged: (value) {
                                checkBoxChanged(value, task.id);
                              },
                              onDelete: () => _confirmDeleteTask(task),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
