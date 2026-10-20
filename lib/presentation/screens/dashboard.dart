import 'package:adistyclone/core/utils/image_helper.dart';
import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/presentation/widgets/cards/hero_card.dart';
import 'package:adistyclone/presentation/widgets/cards/task_item.dart';
import 'package:adistyclone/presentation/widgets/dialogs/edit_profile_dialog.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    _initTasks();
  }

  void _initTasks() async {
    await DatabaseHelper.deleteExpiredWeeklyTasks();
    if (mounted) _loadTasks();
  }

  void _loadTasks() {
    setState(() {});
  }

  void checkBoxChanged(bool? value, String taskId) async {
    await DatabaseHelper.toggleTaskCompletion(taskId);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = DatabaseHelper.totalTaskCount();
    final profile = DatabaseHelper.getUserProfile();
    final incompleteTasks = DatabaseHelper.getIncompleteTasks();

    return Scaffold(
      backgroundColor: ColorsTheme.latar,
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () async {
                  final updated = await showEditProfileDialog(context);
                  if (updated && mounted) setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ColorsTheme.kartuUtama.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Builder(
                          builder: (context) {
                            final imageBytes = ImageHelper.bytesFromBase64(
                              profile.profileImageBase64,
                            );
                            if (imageBytes != null) {
                              return Image.memory(
                                imageBytes,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            }
                            return Center(
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: ColorsTheme.kartuUtama,
                                size: 35,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: TextStyle(
                              color: ColorsTheme.teks,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            profile.description,
                            style: TextStyle(
                              color: ColorsTheme.teksSekunder,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              HeroDash(),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tugas",
                    style: TextStyle(
                      color: ColorsTheme.teks,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$totalTasks Total Tugas",
                    style: TextStyle(
                      color: ColorsTheme.kartuUtama,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: incompleteTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 64,
                              color: ColorsTheme.selesai,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Semua tugas sudah selesai! 🎉',
                              style: TextStyle(
                                color: ColorsTheme.teksSekunder,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: incompleteTasks.length,
                        itemBuilder: (context, index) {
                          final task = incompleteTasks[index];
                          return TaskItem(
                            title: task.title,
                            tugasapa: task.description,
                            isCompleted: task.isCompleted,
                            sisaWaktu: task.sisaWaktu,
                            onChanged: (value) {
                              checkBoxChanged(value, task.id);
                            },
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
