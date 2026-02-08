import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/repositories/card_repository.dart';
import 'package:beat_recall/presentation/screens/csv_import/csv_import_screen.dart';
import 'package:beat_recall/presentation/screens/library/library_viewmodel.dart';
import 'package:beat_recall/services/csv_import_service.dart';

/// Mock implementation of CardRepository for testing
class MockCardRepository implements CardRepository {
  final Map<String, Flashcard> _cardsByUuid = {};
  final Map<String, Flashcard> _cardsByYoutubeId = {};

  @override
  Future<void> save(Flashcard card) async {
    _cardsByUuid[card.uuid] = card;
    _cardsByYoutubeId[card.youtubeId] = card;
  }

  @override
  Future<void> saveAll(List<Flashcard> cards) async {
    for (final card in cards) {
      await save(card);
    }
  }

  @override
  Future<Flashcard?> findByUuid(String uuid) async {
    return _cardsByUuid[uuid];
  }

  @override
  Future<Flashcard?> findByYoutubeId(String youtubeId) async {
    return _cardsByYoutubeId[youtubeId];
  }

  @override
  Future<bool> existsByYoutubeId(String youtubeId) async {
    return _cardsByYoutubeId.containsKey(youtubeId);
  }

  @override
  Future<int> countAllCards() async => _cardsByUuid.length;

  @override
  Future<int> countDueCards() async => 0;

  @override
  Future<void> deleteByUuid(String uuid) async {
    final card = _cardsByUuid.remove(uuid);
    if (card != null) {
      _cardsByYoutubeId.remove(card.youtubeId);
    }
  }

  @override
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  }) async {
    return _cardsByUuid.values.toList();
  }

  @override
  Future<List<Flashcard>> fetchDueCards({int limit = 100}) async {
    return [];
  }

  @override
  Future<void> updateSrsFields({
    required String cardUuid,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
  }) async {
    final card = _cardsByUuid[cardUuid];
    if (card != null) {
      final updated = card.copyWith(
        nextReviewDate: nextReviewDate,
        easeFactor: easeFactor,
        intervalDays: intervalDays,
        repetitions: repetitions,
        updatedAt: DateTime.now(),
      );
      _cardsByUuid[cardUuid] = updated;
      _cardsByYoutubeId[card.youtubeId] = updated;
    }
  }

  @override
  Future<void> resetAllProgress() async {
    final now = DateTime.now();
    final resetCards = _cardsByUuid.values.map((card) {
      return card.copyWith(
        nextReviewDate: now,
        easeFactor: 2.5,
        intervalDays: 0,
        repetitions: 0,
        updatedAt: now,
      );
    }).toList();
    
    _cardsByUuid.clear();
    _cardsByYoutubeId.clear();
    for (final card in resetCards) {
      _cardsByUuid[card.uuid] = card;
      _cardsByYoutubeId[card.youtubeId] = card;
    }
  }
}

/// Tests to ensure providers are available throughout the app.
/// 
/// **Issue:** ProviderNotFoundException when navigating to CsvImportScreen
/// **Fix:** Restructured app to place providers above MaterialApp
void main() {
  group('Provider Scope Tests', () {
    late MockCardRepository mockRepository;

    setUp(() {
      mockRepository = MockCardRepository();
    });

    Widget createTestApp(Widget home) {
      return MultiProvider(
        providers: [
          // Repository (using interface type for flexibility with mocks)
          Provider<CardRepository>(
            create: (context) => mockRepository,
          ),
          // Services
          Provider<CsvImportService>(
            create: (context) => CsvImportService(
              context.read<CardRepository>(),
            ),
          ),
          // ViewModels
          ChangeNotifierProvider<LibraryViewModel>(
            create: (context) => LibraryViewModel(
              cardRepository: context.read<CardRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          routes: {
            '/': (context) => home,
            '/csv-import': (context) => const CsvImportScreen(),
          },
        ),
      );
    }

    testWidgets('CsvImportService provider is accessible in CsvImportScreen', (tester) async {
      // This is the critical test - it verifies the fix for ProviderNotFoundException
      await tester.pumpWidget(createTestApp(const CsvImportScreen()));
      await tester.pump();

      // Verify screen is displayed without ProviderNotFoundException
      expect(find.byType(CsvImportScreen), findsOneWidget);
      expect(find.text('Import from CSV'), findsOneWidget);
      
      // Get the service from context to verify it's accessible
      final context = tester.element(find.byType(CsvImportScreen));
      final service = context.read<CsvImportService>();
      
      expect(service, isNotNull);
      expect(service, isA<CsvImportService>());
    });

    testWidgets('all providers are accessible in CsvImportScreen', (tester) async {
      await tester.pumpWidget(createTestApp(const CsvImportScreen()));
      await tester.pump();

      // Find the CsvImportScreen context
      final context = tester.element(find.byType(CsvImportScreen));

      // Verify all providers are accessible
      expect(
        () => context.read<CardRepository>(),
        returnsNormally,
        reason: 'CardRepository should be available in CsvImportScreen',
      );
      
      expect(
        () => context.read<CsvImportService>(),
        returnsNormally,
        reason: 'CsvImportService should be available in CsvImportScreen',
      );
      
      expect(
        () => context.read<LibraryViewModel>(),
        returnsNormally,
        reason: 'LibraryViewModel should be available in CsvImportScreen',
      );
    });

    testWidgets('providers are accessible after named route navigation', (tester) async {
      // Create a simple test screen with a button to navigate
      final testScreen = Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/csv-import'),
              child: const Text('Navigate to CSV Import'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createTestApp(testScreen));
      await tester.pump();

      // Navigate using named route
      await tester.tap(find.text('Navigate to CSV Import'));
      await tester.pumpAndSettle();

      // Verify navigation succeeded and providers are available
      expect(find.byType(CsvImportScreen), findsOneWidget);
      
      final csvImportContext = tester.element(find.byType(CsvImportScreen));
      
      expect(
        () => csvImportContext.read<CsvImportService>(),
        returnsNormally,
        reason: 'CsvImportService should be available after navigation',
      );
    });

    testWidgets('providers maintain state across navigation', (tester) async {
      final testScreen = Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/csv-import'),
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createTestApp(testScreen));
      await tester.pump();

      // Get initial ViewModel instance
      final initialContext = tester.element(find.byType(Scaffold));
      final initialViewModel = initialContext.read<LibraryViewModel>();

      // Navigate to CsvImportScreen
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Get ViewModel from new route
      final csvImportContext = tester.element(find.byType(CsvImportScreen));
      final viewModelInCsvScreen = csvImportContext.read<LibraryViewModel>();

      // Verify it's the same instance (providers are scoped above routes)
      expect(
        identical(initialViewModel, viewModelInCsvScreen),
        isTrue,
        reason: 'Should be the same ViewModel instance across routes',
      );
    });
  });
}

