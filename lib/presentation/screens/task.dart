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
  List<TaskModel> _tasks = [];
  String _activeFilter = 'Semua';

  List<List<dynamic>> filterTask = [
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
          _loadTasks();
        } else if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _initTasks() async {
    await DatabaseHelper.deleteExpiredWeeklyTasks();
    if (mounted) _loadTasks();
  }

  @override
  void dispose() {
    DateTimeHelper.heartbeat.removeListener(_onHeartbeat);
    super.dispose();
  }

  /// Load tugas dari database sesuai filter aktif
  void _loadTasks() {
    setState(() {
      switch (_activeFilter) {
        case 'Belum Selesai':
          _tasks = DatabaseHelper.getIncompleteTasks();
          break;
        case 'Selesai':
          _tasks = DatabaseHelper.getCompletedTasks();
          break;
        default:
          _tasks = DatabaseHelper.getAllTasks();
      }
    });
  }

  void checkBoxChanged(bool? value, String taskId) async {
    await DatabaseHelper.toggleTaskCompletion(taskId);
    _loadTasks();
  }

  /// Tampilkan dialog untuk menambah tugas baru
  void _showAddTaskDialog() async {
    final saved = await showAddTaskDialog(context);
    if (saved) _loadTasks();
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
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = DatabaseHelper.totalTaskCount();
    final completedTasks = DatabaseHelper.completedTaskCount();
    final incompleteTasks = totalTasks - completedTasks;

    return Container(
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
                        "Tugas",
                        style: TextStyle(
                          color: ColorsTheme.teks,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1),
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
                    _loadTasks();
                  },
                  child: ButtonFilter(title: filter[0], isSelected: filter[1]),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  SizedBox(height: 15),
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
            SizedBox(height: 15),
            Expanded(
              child: _tasks.isEmpty
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
                          SizedBox(height: 16),
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
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
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
  }
}
