import 'dart:convert';

import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/services/notification_service.dart';
import 'package:adistyclone/presentation/widgets/dialogs/edit_profile_dialog.dart';
import 'package:adistyclone/presentation/widgets/sheets/about_sheet.dart';
import 'package:adistyclone/presentation/widgets/sheets/notification_config_sheet.dart';
import 'package:adistyclone/presentation/widgets/sheets/theme_picker_sheet.dart';
import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late bool _pengingatTugas;
  late bool _notifikasiKuliah;

  @override
  void initState() {
    super.initState();
    _pengingatTugas = DatabaseHelper.isTaskReminderEnabled();
    _notifikasiKuliah = DatabaseHelper.isClassNotificationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final profile = DatabaseHelper.getUserProfile();
    final weeklySchedules = DatabaseHelper.getWeeklyScheduleCount();
    final activeTasks = DatabaseHelper.getActiveTaskCount();
    final completedTasks = DatabaseHelper.getCompletedTaskCount();

    return Scaffold(
      backgroundColor: ColorsTheme.latar,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profil",
                    style: TextStyle(
                      color: ColorsTheme.teks,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Pengaturan pribadimu",
                    style: TextStyle(
                      color: ColorsTheme.teksSekunder,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ============================
                    // Profile Card
                    // ============================
                    _buildProfileCard(profile),
                    const SizedBox(height: 16),

                    // ============================
                    // Stats Row
                    // ============================
                    _buildStatsRow(
                      weeklySchedules,
                      activeTasks,
                      completedTasks,
                    ),
                    const SizedBox(height: 16),

                    // ============================
                    // Settings List
                    // ============================
                    _buildSettingsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  PROFILE CARD
  // ============================================================
  Widget _buildProfileCard(dynamic profile) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsTheme.latarKomponen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Banner & Avatar Stack
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Banner
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsTheme.kartuUtama.withValues(alpha: 0.25),
                    image: profile.bannerImageBase64 != null
                        ? DecorationImage(
                            image: MemoryImage(
                              base64Decode(profile.bannerImageBase64!),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: profile.bannerImageBase64 == null
                        ? LinearGradient(
                            colors: [ColorsTheme.kartuUtama, ColorsTheme.aksen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                ),
                // Avatar
                Positioned(
                  bottom: -45,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorsTheme.latarKomponen,
                      border: Border.all(
                        color: ColorsTheme.latarKomponen,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: profile.profileImageBase64 != null
                          ? Image.memory(
                              base64Decode(profile.profileImageBase64!),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: ColorsTheme.kartuUtama.withValues(
                                alpha: 0.15,
                              ),
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: ColorsTheme.kartuUtama,
                                size: 45,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 52),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    profile.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorsTheme.teks,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorsTheme.teksSekunder,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final updated = await showEditProfileDialog(context);
                      if (updated && mounted) setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsTheme.aksen,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorsTheme.teksSekunder.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        "Edit profil",
                        style: TextStyle(
                          color: ColorsTheme.teks,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  STATS ROW
  // ============================================================
  Widget _buildStatsRow(int schedules, int active, int completed) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 102,
            child: _buildStatCard(
              value: schedules.toString(),
              label: 'Kuliah minggu\nini',
              color: ColorsTheme.kartuUtama.withValues(alpha: 0.15),
              textColor: ColorsTheme.kartuUtama,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 102,
            child: _buildStatCard(
              value: active.toString(),
              label: 'Tugas aktif',
              color: ColorsTheme.aksen.withValues(alpha: 0.25),
              textColor: ColorsTheme.aksen,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 102,
            child: _buildStatCard(
              value: completed.toString(),
              label: 'Tugas selesai',
              color: ColorsTheme.selesai.withValues(alpha: 0.5),
              textColor: ColorsTheme.isDarkMode
                  ? ColorsTheme.teksSelesai
                  : ColorsTheme.kartuUtama,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorsTheme.teksSekunder,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  SETTINGS CARD
  // ============================================================
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: ColorsTheme.latarKomponen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tema
          _buildSettingTile(
            icon: Icons.palette_outlined,
            iconBgColor: ColorsTheme.kartuUtama.withValues(alpha: 0.12),
            iconColor: ColorsTheme.kartuUtama,
            title: 'Tema',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ColorsTheme.themeName,
                  style: TextStyle(
                    color: ColorsTheme.teksSekunder,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: ColorsTheme.teksSekunder,
                  size: 20,
                ),
              ],
            ),
            onTap: () {
              showThemePickerSheet(
                context,
                onThemeChanged: () {
                  if (mounted) setState(() {});
                },
              );
            },
          ),
          _buildDivider(),

          // Pengingat tugas
          _buildSettingTile(
            icon: Icons.notifications_outlined,
            iconBgColor: ColorsTheme.aksen.withValues(alpha: 0.15),
            iconColor: ColorsTheme.aksen,
            title: 'Pengingat tugas',
            subtitle: _getTaskReminderSubtitle(),
            trailing: Switch(
              value: _pengingatTugas,
              onChanged: (val) async {
                setState(() => _pengingatTugas = val);
                await DatabaseHelper.setTaskReminderEnabled(val);
                if (val) {
                  await NotificationService.rescheduleAllTaskNotifications();
                } else {
                  await NotificationService.cancelAllTaskNotifications();
                }
              },
              activeTrackColor: ColorsTheme.kartuUtama,
            ),
            onTap: () => _openNotificationConfig(NotificationConfigType.tugas),
          ),
          _buildDivider(),

          // Notifikasi kuliah
          _buildSettingTile(
            icon: Icons.school_outlined,
            iconBgColor: ColorsTheme.chipLempung.withValues(alpha: 0.3),
            iconColor: ColorsTheme.isDarkMode
                ? ColorsTheme.teksChipLempung
                : ColorsTheme.chipLempung,
            title: 'Notifikasi kuliah',
            subtitle: _getClassNotificationSubtitle(),
            trailing: Switch(
              value: _notifikasiKuliah,
              onChanged: (val) async {
                setState(() => _notifikasiKuliah = val);
                await DatabaseHelper.setClassNotificationEnabled(val);
                if (val) {
                  await NotificationService.rescheduleAllClassNotifications();
                } else {
                  await NotificationService.cancelAllClassNotifications();
                }
              },
              activeTrackColor: ColorsTheme.kartuUtama,
            ),
            onTap: () => _openNotificationConfig(NotificationConfigType.kuliah),
          ),
          _buildDivider(),

          // Tentang aplikasi
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            iconBgColor: ColorsTheme.selesai.withValues(alpha: 0.4),
            iconColor: ColorsTheme.isDarkMode
                ? ColorsTheme.teksSelesai
                : ColorsTheme.kartuUtama,
            title: 'Tentang aplikasi',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: ColorsTheme.teksSekunder,
              size: 20,
            ),
            onTap: () => showAboutSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: ColorsTheme.teks,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorsTheme.teksSekunder,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  String _getClassNotificationSubtitle() {
    final timing = DatabaseHelper.getClassNotificationTiming();
    final sound = DatabaseHelper.getClassNotificationSoundName();
    final timeStr = timing == 0
        ? 'Tepat waktu'
        : timing >= 60
        ? '${timing ~/ 60} jam sblm'
        : '$timing mnt sblm';
    return '$timeStr • $sound';
  }

  String _getTaskReminderSubtitle() {
    final timing = DatabaseHelper.getTaskReminderTiming();
    final sound = DatabaseHelper.getTaskReminderSoundName();
    final timeStr = timing >= 1440
        ? 'H-1 deadline'
        : timing >= 60
        ? '${timing ~/ 60} jam sblm'
        : '$timing mnt sblm';
    return '$timeStr • $sound';
  }

  void _openNotificationConfig(NotificationConfigType type) {
    showNotificationConfigSheet(
      context,
      type: type,
      onConfigChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 70,
      color: ColorsTheme.teksSekunder.withValues(alpha: 0.15),
    );
  }
}
