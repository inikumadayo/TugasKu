import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/date_time_helper.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/presentation/screens/dashboard.dart';
import 'package:adistyclone/presentation/screens/schedule.dart';
import 'package:adistyclone/presentation/screens/setting.dart';
import 'package:adistyclone/presentation/screens/task.dart';
import 'package:adistyclone/presentation/widgets/dialogs/edit_profile_dialog.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    DateTimeHelper.startHeartbeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeProfile();
    });
  }

  @override
  void dispose() {
    DateTimeHelper.stopHeartbeat();
    super.dispose();
  }

  void _checkFirstTimeProfile() async {
    if (!DatabaseHelper.isProfileInitialized()) {
      final updated = await showEditProfileDialog(context, isFirstTime: true);
      if (updated && mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ColorsTheme.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: ColorsTheme.latar,
          body: IndexedStack(
            key: ValueKey(isDark),
            index: _selectedIndex,
            children: const [Dashboard(), Schedule(), Task(), Setting()],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: ColorsTheme.latarKomponen,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: ColorsTheme.isDarkMode ? 0.3 : 0.06,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Beranda',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today_rounded,
                      label: 'Jadwal',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.check_circle_outline_rounded,
                      activeIcon: Icons.check_circle_rounded,
                      label: 'Tugas',
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill container for active icon
            Container(
              width: 54,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? ColorsTheme.aksen : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? ColorsTheme.teksDiAksen
                      : ColorsTheme.teksSekunder,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? ColorsTheme.teks : ColorsTheme.teksSekunder,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
