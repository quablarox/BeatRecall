import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/data/entities/isar_flashcard.dart';
import 'package:beat_recall/data/mappers/flashcard_mapper.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';

/// Unit tests for [FlashcardMapper].
///
/// These tests verify the bidirectional mapping between
/// domain [Flashcard] and data [IsarFlashcard].
void main() {
  late FlashcardMapper mapper;

  setUp(() {
    mapper = FlashcardMapper();
  });

  group('FlashcardMapper - Domain to Data', () {
    test('toData converts domain Flashcard to IsarFlashcard', () {
      // Given: A domain Flashcard
      final domain = Flashcard(
        uuid: 'test-uuid-123',
        youtubeId: 'dQw4w9WgXcQ',
        title: 'Never Gonna Give You Up',
        artist: 'Rick Astley',
        album: 'Whenever You Need Somebody',
        intervalDays: 7,
        easeFactor: 2.6,
        repetitions: 3,
        nextReviewDate: DateTime(2026, 3, 1),
        startAtSecond: 10,
        endAtSecond: 120,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 2, 1),
      );

      // When: Converting to data entity
      final data = mapper.toData(domain);

      // Then: All fields are correctly mapped
      expect(data.uuid, 'test-uuid-123');
      expect(data.youtubeId, 'dQw4w9WgXcQ');
      expect(data.title, 'Never Gonna Give You Up');
      expect(data.artist, 'Rick Astley');
      expect(data.album, 'Whenever You Need Somebody');
      expect(data.intervalDays, 7);
      expect(data.easeFactor, 2.6);
      expect(data.repetitions, 3);
      expect(data.nextReviewDate, DateTime(2026, 3, 1));
      expect(data.startAtSecond, 10);
      expect(data.endAtSecond, 120);
      expect(data.createdAt, DateTime(2026, 1, 1));
      expect(data.updatedAt, DateTime(2026, 2, 1));
    });

    test('toData preserves isarId when provided', () {
      // Given: A domain Flashcard and existing isarId
      final domain = Flashcard(
        uuid: 'test-uuid',
        youtubeId: 'xyz',
        title: 'Test',
        artist: 'Artist',
        nextReviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // When: Converting with specific isarId
      final data = mapper.toData(domain, isarId: 42);

      // Then: IsarId is preserved
      expect(data.id, 42);
    });

    test('toData handles null optional fields', () {
      // Given: A domain Flashcard with null optionals
      final domain = Flashcard(
        uuid: 'test-uuid',
        youtubeId: 'xyz',
        title: 'Test',
        artist: 'Artist',
        album: null, // Optional
        endAtSecond: null, // Optional
        nextReviewDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // When: Converting to data entity
      final data = mapper.toData(domain);

      // Then: Null fields remain null
      expect(data.album, isNull);
      expect(data.endAtSecond, isNull);
    });
  });

  group('FlashcardMapper - Data to Domain', () {
    test('toDomain converts IsarFlashcard to domain Flashcard', () {
      // Given: An IsarFlashcard
      final data = IsarFlashcard()
        ..id = 42
        ..uuid = 'test-uuid-456'
        ..youtubeId = 'abc123'
        ..title = 'Test Song'
        ..artist = 'Test Artist'
        ..album = 'Test Album'
        ..intervalDays = 14
        ..easeFactor = 2.8
        ..repetitions = 5
        ..nextReviewDate = DateTime(2026, 4, 1)
        ..startAtSecond = 30
        ..endAtSecond = 90
        ..createdAt = DateTime(2026, 1, 15)
        ..updatedAt = DateTime(2026, 2, 15);

      // When: Converting to domain entity
      final domain = mapper.toDomain(data);

      // Then: All fields are correctly mapped (except isarId)
      expect(domain.uuid, 'test-uuid-456');
      expect(domain.youtubeId, 'abc123');
      expect(domain.title, 'Test Song');
      expect(domain.artist, 'Test Artist');
      expect(domain.album, 'Test Album');
      expect(domain.intervalDays, 14);
      expect(domain.easeFactor, 2.8);
      expect(domain.repetitions, 5);
      expect(domain.nextReviewDate, DateTime(2026, 4, 1));
      expect(domain.startAtSecond, 30);
      expect(domain.endAtSecond, 90);
      expect(domain.createdAt, DateTime(2026, 1, 15));
      expect(domain.updatedAt, DateTime(2026, 2, 15));
    });

    test('toDomain discards isarId', () {
      // Given: An IsarFlashcard with isarId
      final data = IsarFlashcard()
        ..id = 999
        ..uuid = 'test-uuid'
        ..youtubeId = 'xyz'
        ..title = 'Test'
        ..artist = 'Artist'
        ..nextReviewDate = DateTime.now()
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      // When: Converting to domain
      final domain = mapper.toDomain(data);

      // Then: Domain uses UUID only (no isarId property exists)
      expect(domain.uuid, 'test-uuid');
      // IsarId is not part of domain model
    });
  });

  group('FlashcardMapper - Round-trip conversion', () {
    test('domain -> data -> domain preserves data', () {
      // Given: Original domain Flashcard
      final original = Flashcard(
        uuid: 'round-trip-test',
        youtubeId: 'round123',
        title: 'Round Trip Song',
        artist: 'Round Artist',
        album: 'Round Album',
        intervalDays: 21,
        easeFactor: 2.9,
        repetitions: 7,
        nextReviewDate: DateTime(2026, 5, 1),
        startAtSecond: 45,
        endAtSecond: 180,
        createdAt: DateTime(2026, 1, 20),
        updatedAt: DateTime(2026, 2, 20),
      );

      // When: Converting to data and back
      final data = mapper.toData(original);
      final backToDomain = mapper.toDomain(data);

      // Then: All domain fields are preserved
      expect(backToDomain.uuid, original.uuid);
      expect(backToDomain.youtubeId, original.youtubeId);
      expect(backToDomain.title, original.title);
      expect(backToDomain.artist, original.artist);
      expect(backToDomain.album, original.album);
      expect(backToDomain.intervalDays, original.intervalDays);
      expect(backToDomain.easeFactor, original.easeFactor);
      expect(backToDomain.repetitions, original.repetitions);
      expect(backToDomain.nextReviewDate, original.nextReviewDate);
      expect(backToDomain.startAtSecond, original.startAtSecond);
      expect(backToDomain.endAtSecond, original.endAtSecond);
      expect(backToDomain.createdAt, original.createdAt);
      expect(backToDomain.updatedAt, original.updatedAt);
    });
  });

  group('FlashcardMapper - List operations', () {
    test('toDataList converts list of domain entities', () {
      // Given: List of domain Flashcards
      final domainList = [
        Flashcard(
          uuid: 'uuid-1',
          youtubeId: 'yt1',
          title: 'Song 1',
          artist: 'Artist 1',
          nextReviewDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Flashcard(
          uuid: 'uuid-2',
          youtubeId: 'yt2',
          title: 'Song 2',
          artist: 'Artist 2',
          nextReviewDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // When: Converting list to data
      final dataList = mapper.toDataList(domainList);

      // Then: All items converted
      expect(dataList.length, 2);
      expect(dataList[0].uuid, 'uuid-1');
      expect(dataList[1].uuid, 'uuid-2');
    });

    test('toDomainList converts list of data entities', () {
      // Given: List of IsarFlashcards
      final dataList = [
        IsarFlashcard()
          ..uuid = 'uuid-3'
          ..youtubeId = 'yt3'
          ..title = 'Song 3'
          ..artist = 'Artist 3'
          ..nextReviewDate = DateTime.now()
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now(),
        IsarFlashcard()
          ..uuid = 'uuid-4'
          ..youtubeId = 'yt4'
          ..title = 'Song 4'
          ..artist = 'Artist 4'
          ..nextReviewDate = DateTime.now()
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now(),
      ];

      // When: Converting list to domain
      final domainList = mapper.toDomainList(dataList);

      // Then: All items converted
      expect(domainList.length, 2);
      expect(domainList[0].uuid, 'uuid-3');
      expect(domainList[1].uuid, 'uuid-4');
    });
  });
}
