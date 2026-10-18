import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/pages/homepage.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  await DatabaseHelper.seedIfEmpty();
  await DatabaseHelper.deleteExpiredWeeklyTasks();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Homepage());
  }
}
