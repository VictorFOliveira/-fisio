import 'package:flutter/material.dart';
import 'data/app_database.dart';
import 'screens/home_screen.dart';

class MaisFisioApp extends StatelessWidget {
  const MaisFisioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '+Fisio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF197A73),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: HomeScreen(database: AppDatabase.instance),
    );
  }
}
