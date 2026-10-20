import 'package:adistyclone/core/theme/app_theme.dart';
import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/presentation/screens/homepage.dart';
import 'package:adistyclone/services/notification_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  await NotificationService.init();
  await DatabaseHelper.seedIfEmpty();
  await DatabaseHelper.deleteExpiredWeeklyTasks();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ColorsTheme.isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const Homepage(),
        );
      },
    );
  }
}
