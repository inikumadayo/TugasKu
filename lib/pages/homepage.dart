import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/pages/dashboard.dart';
import 'package:adistyclone/pages/schedule.dart';
import 'package:adistyclone/pages/setting.dart';
import 'package:adistyclone/pages/task.dart';
import 'package:adistyclone/utils/edit_profile_dialog.dart';
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
    // Tampilkan dialog profil jika pengguna baru pertama kali membuka aplikasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeProfile();
    });
  }

  void _checkFirstTimeProfile() async {
    if (!DatabaseHelper.isProfileInitialized()) {
      final updated = await showEditProfileDialog(context, isFirstTime: true);
      if (updated && mounted) {
        setState(() {});
      }
    }
  }

  /// Callback yang dipanggil saat tema berubah (dari halaman Setting)
  void _onThemeChanged() {
    setState(() {});
  }

  // Menggunakan getter agar widget di-rebuild saat berpindah tab
  // sehingga data terbaru dari database selalu ditampilkan
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Dashboard();
      case 1:
        return Schedule();
      case 2:
        return Task();
      case 3:
        return Setting(onThemeChanged: _onThemeChanged);
      default:
        return Dashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsTheme.latar,
      body: _getPage(_selectedIndex),
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
