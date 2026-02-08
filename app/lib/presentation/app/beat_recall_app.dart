import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_screen.dart';

class BeatRecallApp extends StatelessWidget {
  const BeatRecallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeatRecall',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1DB954)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
