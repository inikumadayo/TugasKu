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
    // Tampilkan dialog profil jika pengguna baru pertama kali membuka aplikasi
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

  final List<Widget> _pages = const [
    Dashboard(),
    Schedule(),
    Task(),
    Setting(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsTheme.latar,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: NavigationBar(
              backgroundColor: ColorsTheme.latarKomponen,
              indicatorColor: ColorsTheme.aksen,
              labelTextStyle: WidgetStateTextStyle.resolveWith((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(color: ColorsTheme.teks);
                }
                return TextStyle(color: ColorsTheme.teksSekunder);
              }),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: ColorsTheme.teks,
                  ),
                  icon: Icon(
                    Icons.home_rounded,
                    color: ColorsTheme.teksSekunder,
                  ),
                  label: "Beranda",
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.calendar_today_rounded,
                    color: ColorsTheme.teks,
                  ),
                  icon: Icon(
                    Icons.calendar_today_rounded,
                    color: ColorsTheme.teksSekunder,
                  ),
                  label: "Jadwal",
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.task_rounded,
                    color: ColorsTheme.teks,
                  ),
                  icon: Icon(
                    Icons.task_rounded,
                    color: ColorsTheme.teksSekunder,
                  ),
                  label: "Tugas",
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: ColorsTheme.teks,
                  ),
                  icon: Icon(
                    Icons.person_rounded,
                    color: ColorsTheme.teksSekunder,
                  ),
                  label: "Profil",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
