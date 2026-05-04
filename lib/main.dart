import 'package:flutter/material.dart';

import 'features/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrainAgeApp());
}

class BrainAgeApp extends StatelessWidget {
  const BrainAgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Age Daily',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF11182B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}