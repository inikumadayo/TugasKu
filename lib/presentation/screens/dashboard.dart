import 'package:adistyclone/core/constants/mascot_assets.dart';
import 'package:adistyclone/core/utils/image_helper.dart';
import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/services/update_service.dart';
import 'package:adistyclone/presentation/widgets/cards/hero_card.dart';
import 'package:adistyclone/presentation/widgets/cards/task_item.dart';
import 'package:adistyclone/presentation/widgets/dialogs/edit_profile_dialog.dart';
import 'package:adistyclone/presentation/widgets/dialogs/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    _checkUpdateSilently();
  }

  void _initTasks() async {
    await DatabaseHelper.deleteExpiredWeeklyTasks();
  }

  void _checkUpdateSilently() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final update = await UpdateService.checkForUpdate();
    if (update != null && update.hasUpdate && mounted) {
      await showUpdateDialog(context, updateInfo: update);
    }
  }

  void checkBoxChanged(bool? value, String taskId) async {
    await DatabaseHelper.toggleTaskCompletion(taskId);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: DatabaseHelper.tasksListenable(),
      builder: (context, box, child) {
        final profile = DatabaseHelper.getUserProfile();
        final incompleteTasks = DatabaseHelper.getIncompleteTasks();

        return Scaffold(
          backgroundColor: ColorsTheme.latar,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header Profil
                  GestureDetector(
                    onTap: () async {
                      final updated = await showEditProfileDialog(context);
                      if (updated && mounted) setState(() {});
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: ColorsTheme.latarKomponen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorsTheme.teksSekunder.withValues(
                                alpha: 0.15,
                              ),
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Builder(
                              builder: (context) {
                                final imageBytes = ImageHelper.bytesFromBase64(
                                  profile.profileImageBase64,
                                );
                                if (imageBytes != null) {
                                  return Image.memory(
                                    imageBytes,
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Container(
                                  padding: const EdgeInsets.all(4),
                                  child: SvgPicture.asset(
                                    MascotAssets.lofi,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: TextStyle(
                                  color: ColorsTheme.teks,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.description,
                                style: TextStyle(
                                  color: ColorsTheme.teksSekunder,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          MascotAssets.melambai,
                          height: 46,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Hero Card Jadwal
                  const HeroDash(),

                  const SizedBox(height: 24),

                  // Section Header: Tugasku
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tugasku",
                        style: TextStyle(
                          color: ColorsTheme.teks,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${incompleteTasks.length} belum selesai",
                        style: TextStyle(
                          color: ColorsTheme.teksSekunder,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // List Tugas
                  Expanded(
                    child: incompleteTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  MascotAssets.selesai,
                                  height: 80,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Semua tugas sudah selesai! 🎉',
                                  style: TextStyle(
                                    color: ColorsTheme.teksSekunder,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
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
      },
    );
  }
}
