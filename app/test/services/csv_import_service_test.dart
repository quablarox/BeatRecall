import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/services/csv_import_service.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/repositories/card_repository.dart';
import 'package:beat_recall/domain/value_objects/import_result.dart';

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

void main() {
  group('CsvImportService (@CARDMGMT-001)', () {
    late MockCardRepository mockRepository;
    late CsvImportService importService;

    setUp(() {
      mockRepository = MockCardRepository();
      importService = CsvImportService(mockRepository);
    });

    group('importFromCsvString()', () {
      test('successfully imports valid CSV with all fields', () async {
        const csvContent = '''
youtube_url,title,artist,start_at_seconds
https://www.youtube.com/watch?v=dQw4w9WgXcQ,Never Gonna Give You Up,Rick Astley,0
https://youtu.be/9bZkp7q19f0,Gangnam Style,PSY,30
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.totalRows, 2);
        expect(result.successCount, 2);
        expect(result.skippedCount, 0);
        expect(result.failedCount, 0);
        expect(result.errors, isEmpty);
        expect(result.isFullySuccessful, true);

        // Verify cards were saved
        final count = await mockRepository.countAllCards();
        expect(count, 2);
      });

      test('imports CSV with optional start_at_seconds missing', () async {
        const csvContent = '''
youtube_url,title,artist
dQw4w9WgXcQ,Never Gonna Give You Up,Rick Astley
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.totalRows, 1);
        expect(result.successCount, 1);
        expect(result.failedCount, 0);
      });

      test('skips duplicate YouTube IDs', () async {
        // Pre-populate with existing card
        const youtubeId = 'dQw4w9WgXcQ';
        await mockRepository.save(
          Flashcard(
            uuid: 'existing-uuid',
            youtubeId: youtubeId,
            title: 'Existing',
            artist: 'Artist',
            intervalDays: 0,
            easeFactor: 2.5,
            repetitions: 0,
            nextReviewDate: DateTime.now(),
            startAtSecond: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        const csvContent = '''
youtube_url,title,artist
dQw4w9WgXcQ,Never Gonna Give You Up,Rick Astley
9bZkp7q19f0,Gangnam Style,PSY
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.totalRows, 2);
        expect(result.successCount, 1);
        expect(result.skippedCount, 1);
        expect(result.failedCount, 0);

        // Check error message
        final duplicateError =
            result.errors.firstWhere((e) => e.reason.contains('Duplicate'));
        expect(duplicateError.rowNumber, 1);
      });

      test('fails on invalid YouTube URL', () async {
        const csvContent = '''
youtube_url,title,artist
not-a-valid-url,Song Title,Artist Name
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.totalRows, 1);
        expect(result.successCount, 0);
        expect(result.failedCount, 1);

        final error = result.errors.first;
        expect(error.rowNumber, 1);
        expect(error.reason, contains('Invalid YouTube URL'));
      });

      test('fails on missing required field: youtube_url', () async {
        const csvContent = '''
youtube_url,title,artist
,Song Title,Artist Name
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.failedCount, 1);
        expect(result.errors.first.reason, contains('Missing required field: youtube_url'));
      });

      test('fails on missing required field: title', () async {
        const csvContent = '''
youtube_url,title,artist
dQw4w9WgXcQ,,Artist Name
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.failedCount, 1);
        expect(result.errors.first.reason, contains('Missing required field: title'));
      });

      test('fails on missing required field: artist', () async {
        const csvContent = '''
youtube_url,title,artist
dQw4w9WgXcQ,Song Title,
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.failedCount, 1);
        expect(result.errors.first.reason, contains('Missing required field: artist'));
      });

      test('fails on invalid start_at_seconds (negative)', () async {
        const csvContent = '''
youtube_url,title,artist,start_at_seconds
dQw4w9WgXcQ,Song Title,Artist Name,-5
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.failedCount, 1);
        expect(result.errors.first.reason, contains('Invalid start_at_seconds'));
      });

      test('fails on invalid start_at_seconds (non-integer)', () async {
        const csvContent = '''
youtube_url,title,artist,start_at_seconds
dQw4w9WgXcQ,Song Title,Artist Name,abc
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.failedCount, 1);
        expect(result.errors.first.reason, contains('Invalid start_at_seconds'));
      });

      test('handles empty CSV file', () async {
        const csvContent = '';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.totalRows, 0);
        expect(result.successCount, 0);
        expect(result.errors.first.reason, contains('empty'));
      });

      test('handles CSV with only header', () async {
        const csvContent = 'youtube_url,title,artist';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.totalRows, 0);
        expect(result.successCount, 0);
      });

      test('fails if required column youtube_url is missing', () async {
        const csvContent = '''
title,artist
Song Title,Artist Name
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.failedCount, 1);
        expect(result.errors.first.reason, contains('Missing required column: youtube_url'));
      });

      test('fails if required column title is missing', () async {
        const csvContent = '''
youtube_url,artist
dQw4w9WgXcQ,Artist Name
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.failedCount, 1);
        expect(result.errors.first.reason, contains('Missing required column: title'));
      });

      test('handles mixed success and failure results', () async {
        const csvContent = '''
youtube_url,title,artist
dQw4w9WgXcQ,Valid Song,Valid Artist
too-short,Invalid Song,Invalid Artist
9bZkp7q19f0,Another Valid,Another Artist
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.totalRows, 3);
        expect(result.successCount, 2);
        expect(result.failedCount, 1);
        expect(result.errors.length, 1);
        expect(result.errors.first.rowNumber, 2);
      });

      test('trims whitespace from field values', () async {
        const csvContent = '''
youtube_url,title,artist
  dQw4w9WgXcQ  ,  Never Gonna Give You Up  ,  Rick Astley  
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.successCount, 1);

        // Verify trimmed values
        final allCards = await mockRepository.fetchAllCards();
        final card = allCards.first;
        expect(card.title, 'Never Gonna Give You Up');
        expect(card.artist, 'Rick Astley');
      });

      test('handles various YouTube URL formats', () async {
        const csvContent = '''
youtube_url,title,artist
https://www.youtube.com/watch?v=dQw4w9WgXcQ,Song 1,Artist 1
https://youtu.be/9bZkp7q19f0,Song 2,Artist 2
kJQP7kiw5Fk,Song 3,Artist 3
https://m.youtube.com/watch?v=jNQXAC9IVRw,Song 4,Artist 4
''';

        final result = await importService.importFromCsvString(csvContent);

        expect(result.totalRows, 4);
        expect(result.successCount, 4);
        expect(result.failedCount, 0);
      });
    });

    group('ImportResult', () {
      test('getSummary() generates correct summary', () {
        const result = ImportResult(
          totalRows: 10,
          successCount: 7,
          skippedCount: 2,
          failedCount: 1,
          errors: [],
        );

        final summary = result.getSummary();

        expect(summary, contains('Imported: 7'));
        expect(summary, contains('Skipped (duplicates): 2'));
        expect(summary, contains('Failed: 1'));
        expect(summary, contains('Total rows: 10'));
      });

      test('isFullySuccessful returns true when no failures or skips', () {
        const result = ImportResult(
          totalRows: 5,
          successCount: 5,
          skippedCount: 0,
          failedCount: 0,
          errors: [],
        );

        expect(result.isFullySuccessful, true);
      });

      test('isFullySuccessful returns false when there are failures', () {
        const result = ImportResult(
          totalRows: 5,
          successCount: 4,
          skippedCount: 0,
          failedCount: 1,
          errors: [],
        );

        expect(result.isFullySuccessful, false);
      });
    });
  });
}
