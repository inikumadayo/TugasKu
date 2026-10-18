import 'dart:convert';
import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:adistyclone/utils/edit_profile_dialog.dart';
import 'package:adistyclone/utils/hero.dart';
import 'package:adistyclone/utils/task_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<TaskModel> _tasks = [];

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
    setState(() {
      _tasks = DatabaseHelper.getIncompleteTasks();
    });
  }

  void checkBoxChanged(bool? value, String taskId) async {
    await DatabaseHelper.toggleTaskCompletion(taskId);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = DatabaseHelper.totalTaskCount();
    final profile = DatabaseHelper.getUserProfile();

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
                        child: profile.profileImageBase64 != null
                            ? Image.memory(
                                base64Decode(profile.profileImageBase64!),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: ColorsTheme.kartuUtama,
                                  size: 35,
                                ),
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
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            profile.description,
                            style: TextStyle(
                              color: ColorsTheme.teksSekunder,
                              fontSize: 14,
                              fontFamily: GoogleFonts.poppins().fontFamily,
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
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                  Text(
                    "$totalTasks Total Tugas",
                    style: TextStyle(
                      color: ColorsTheme.kartuUtama,
                      fontSize: 14,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: _tasks.isEmpty
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
                                fontFamily: GoogleFonts.poppins().fontFamily,
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
