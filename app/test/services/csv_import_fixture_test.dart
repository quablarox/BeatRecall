import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/services/csv_import_service.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/repositories/card_repository.dart';

/// Integration tests for CSV Import using fixture files.
/// 
/// Tests use real CSV files from test/fixtures/ directory.
/// This ensures CSV parsing works with actual file data.
void main() {
  group('CsvImportService - Integration Tests with Fixtures (@CARDMGMT-001)', () {
    late MockCardRepository mockRepository;
    late CsvImportService importService;

    setUp(() {
      mockRepository = MockCardRepository();
      importService = CsvImportService(mockRepository);
    });

    test('imports all valid cards from test_cards_valid.csv', () async {
      // Given
      final csvFile = File('test/fixtures/test_cards_valid.csv');
      expect(await csvFile.exists(), true, reason: 'Fixture file must exist');
      
      final csvContent = await csvFile.readAsString();

      // When
      final result = await importService.importFromCsvString(csvContent);

      // Then
      expect(result.totalRows, 10, reason: 'CSV has 10 data rows');
      expect(result.successCount, 10, reason: 'All rows are valid');
      expect(result.failedCount, 0);
      expect(result.skippedCount, 0);
      expect(mockRepository.savedCards.length, 10);
      
      // Verify sample cards
      final rickCard = mockRepository.savedCards
          .firstWhere((c) => c.title == 'Never Gonna Give You Up');
      expect(rickCard.artist, 'Rick Astley');
      expect(rickCard.youtubeId, 'dQw4w9WgXcQ');
      expect(rickCard.startAtSecond, 30);
      
      final psyCard = mockRepository.savedCards
          .firstWhere((c) => c.title == 'Gangnam Style');
      expect(psyCard.youtubeId, '9bZkp7q19f0');
      expect(psyCard.startAtSecond, 45);
    });

    test('handles errors correctly from test_cards_with_errors.csv', () async {
      // Given
      final csvFile = File('test/fixtures/test_cards_with_errors.csv');
      final csvContent = await csvFile.readAsString();

      // When
      final result = await importService.importFromCsvString(csvContent);

      // Then
      expect(result.totalRows, 6);
      expect(result.successCount, 2, reason: 'Only 2 valid rows');
      expect(result.failedCount, 4, reason: '4 rows have errors');
      expect(result.errors.length, 4);
      
      // Verify error messages
      final errorReasons = result.errors.map((e) => e.reason).toList();
      expect(errorReasons.any((r) => r.contains('Invalid YouTube URL')), true);
      expect(errorReasons.any((r) => r.contains('Missing required field')), true);
    });

    test('detects duplicates from test_cards_duplicates.csv', () async {
      // Given
      final csvFile = File('test/fixtures/test_cards_duplicates.csv');
      final csvContent = await csvFile.readAsString();

      // When
      final result = await importService.importFromCsvString(csvContent);

      // Then
      expect(result.totalRows, 3);
      expect(result.successCount, 2, reason: 'First and third card imported');
      expect(result.skippedCount, 1, reason: 'Second card is duplicate');
      expect(mockRepository.savedCards.length, 2);
      
      // Verify only unique cards were saved
      final youtubeIds = mockRepository.savedCards.map((c) => c.youtubeId).toList();
      expect(youtubeIds.contains('dQw4w9WgXcQ'), true);
      expect(youtubeIds.contains('9bZkp7q19f0'), true);
      expect(youtubeIds.length, 2, reason: 'No duplicate IDs in saved cards');
    });

    test('imports pipe-delimited CSV from test_cards_pipe.csv', () async {
      // Given
      final csvFile = File('test/fixtures/test_cards_pipe.csv');

      // When
      final result = await importService.importFromFile(csvFile);

      // Then
      expect(result.totalRows, 3);
      expect(result.successCount, 3);
      expect(result.failedCount, 0);
      expect(mockRepository.savedCards.length, 3);

      final savedIds = mockRepository.savedCards.map((c) => c.youtubeId).toSet();
      expect(savedIds.contains('dQw4w9WgXcQ'), true);
      expect(savedIds.contains('9bZkp7q19f0'), true);
      expect(savedIds.contains('kJQP7kiw5Fk'), true);
    });

    test('handles minimal CSV format from test_cards_minimal.csv', () async {
      // Given
      final csvFile = File('test/fixtures/test_cards_minimal.csv');
      final csvContent = await csvFile.readAsString();

      // When
      final result = await importService.importFromCsvString(csvContent);

      // Then
      expect(result.totalRows, 3);
      expect(result.successCount, 3);
      expect(result.failedCount, 0);
      
      // Verify default values applied
      for (final card in mockRepository.savedCards) {
        expect(card.startAtSecond, 0, reason: 'Default start time is 0');
      }
    });

    test('can import from actual file using importFromFile', () async {
      // Given
      final csvFile = File('test/fixtures/test_cards_valid.csv');

      // When
      final result = await importService.importFromFile(csvFile);

      // Then
      expect(result.successCount, 10);
      expect(result.failedCount, 0);
      expect(mockRepository.savedCards.length, 10);
    });

    test('imports cards with metadata from pipe-delimited CSV', () async {
      // Given
      final csvFile = File('test/fixtures/test_cards_with_metadata.csv');

      // When
      final result = await importService.importFromFile(csvFile);

      // Then - Verify import summary
      expect(result.successCount, 6);
      expect(result.failedCount, 0);
      expect(mockRepository.savedCards.length, 6);

      // Verify first card with full metadata
      final despacito = mockRepository.savedCards.firstWhere(
        (card) => card.youtubeId == 'kJQP7kiw5Fk',
      );
      expect(despacito.title, 'Despacito');
      expect(despacito.artist, 'Daddy Yankee');
      expect(despacito.album, isNull); // Empty in CSV
      expect(despacito.year, 2017);
      expect(despacito.genre, 'Pop');
      expect(despacito.youtubeViewCount, 8933544322);

      // Verify second card with all metadata filled
      final rickroll = mockRepository.savedCards.firstWhere(
        (card) => card.youtubeId == 'dQw4w9WgXcQ',
      );
      expect(rickroll.title, 'Never Gonna Give You Up');
      expect(rickroll.artist, 'Rick Astley');
      expect(rickroll.album, 'Whenever You Need Somebody');
      expect(rickroll.year, 1987);
      expect(rickroll.genre, 'Pop');
      expect(rickroll.youtubeViewCount, 1500000000);
      expect(rickroll.startAtSecond, 30);

      // Verify card with missing metadata fields
      final bohemian = mockRepository.savedCards.firstWhere(
        (card) => card.youtubeId == 'fJ9rUzIMcZQ',
      );
      expect(bohemian.title, 'Bohemian Rhapsody');
      expect(bohemian.artist, 'Queen');
      expect(bohemian.album, 'A Night at the Opera');
      expect(bohemian.year, 1975);
      expect(bohemian.genre, 'Rock');
      expect(bohemian.youtubeViewCount, 1800000000);
    });
  });
}

// Mock repository for testing
class MockCardRepository implements CardRepository {
  List<Flashcard> savedCards = [];

  @override
  Future<void> save(Flashcard card) async {
    savedCards.add(card);
  }

  @override
  Future<void> saveAll(List<Flashcard> cards) async {
    savedCards.addAll(cards);
  }

  Future<void> saveCard(Flashcard card) async {
    savedCards.add(card);
  }

  @override
  Future<bool> existsByYoutubeId(String youtubeId) async {
    return savedCards.any((card) => card.youtubeId == youtubeId);
  }

  @override
  Future<Flashcard?> findByYoutubeId(String youtubeId) async {
    try {
      return savedCards.firstWhere((card) => card.youtubeId == youtubeId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> countAllCards() async => savedCards.length;

  @override
  Future<int> countDueCards() async => 0;

  @override
  Future<void> deleteByUuid(String uuid) async {}

  @override
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  }) async => savedCards;

  @override
  Future<List<Flashcard>> fetchDueCards({int limit = 100}) async => [];

  @override
  Future<Flashcard?> findByUuid(String uuid) async => null;

  @override
  Future<void> updateSrsFields({
    required String cardUuid,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalMinutes,
    required int repetitions,
  }) async {}

  @override
  Future<void> resetAllProgress() async {
    final now = DateTime.now();
    for (int i = 0; i < savedCards.length; i++) {
      savedCards[i] = savedCards[i].copyWith(
        nextReviewDate: now,
        easeFactor: 2.5,
        intervalMinutes: 0,
        repetitions: 0,
        updatedAt: now,
      );
    }
  }
}
