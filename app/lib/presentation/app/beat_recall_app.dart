import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/database/isar_database.dart';
import '../../data/repositories/isar_card_repository.dart';
import '../../services/csv_import_service.dart';
import '../../services/srs_service.dart';
import '../screens/csv_import/csv_import_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/dashboard_viewmodel.dart';
import '../screens/library/library_screen.dart';
import '../screens/library/library_viewmodel.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/quiz/quiz_viewmodel.dart';

class BeatRecallApp extends StatelessWidget {
  const BeatRecallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: IsarDatabase.open(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing database: ${snapshot.error}'),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            // Repository
            Provider<IsarCardRepository>(
              create: (context) => IsarCardRepository(),
            ),
            // Services
            Provider<SrsService>(
              create: (context) => SrsService(),
            ),
            Provider<CsvImportService>(
              create: (context) => CsvImportService(
                context.read<IsarCardRepository>(),
              ),
            ),
            // ViewModels
            ChangeNotifierProvider<LibraryViewModel>(
              create: (context) => LibraryViewModel(
                cardRepository: context.read<IsarCardRepository>(),
              ),
            ),
            ChangeNotifierProvider<DashboardViewModel>(
              create: (context) => DashboardViewModel(
                cardRepository: context.read<IsarCardRepository>(),
              ),
            ),
            ChangeNotifierProvider<QuizViewModel>(
              create: (context) => QuizViewModel(
                cardRepository: context.read<IsarCardRepository>(),
                srsService: context.read<SrsService>(),
              ),
            ),
          ],
          child: MaterialApp(
            title: 'BeatRecall',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1DB954)),
              useMaterial3: true,
            ),
            routes: {
              '/': (context) => const DashboardScreen(),
              '/library': (context) => const LibraryScreen(),
              '/csv-import': (context) => const CsvImportScreen(),
              '/quiz': (context) => const QuizScreen(),
            },
          ),
        );
      },
    );
  }
}
