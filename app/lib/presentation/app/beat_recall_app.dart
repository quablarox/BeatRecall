import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/database/isar_database.dart';
import '../../data/repositories/isar_card_repository.dart';
import '../../services/csv_import_service.dart';
import '../screens/library/library_screen.dart';
import '../screens/library/library_viewmodel.dart';

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
      home: FutureBuilder(
        future: IsarDatabase.open(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error initializing database: ${snapshot.error}'),
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
            ],
            child: const LibraryScreen(),
          );
        },
      ),
    );
  }
}
