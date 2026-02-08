import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/factories/flashcard_factory.dart';

/// Unit tests for [FlashcardFactory].
///
/// Verifies UUID generation and creation of domain entities.
void main() {
  group('FlashcardFactory - create', () {
    test('creates Flashcard with auto-generated UUID', () {
      // When: Creating a flashcard without UUID
      final card = FlashcardFactory.create(
        youtubeId: 'dQw4w9WgXcQ',
        title: 'Test Song',
        artist: 'Test Artist',
      );

      // Then: UUID is generated
      expect(card.uuid, isNotEmpty);
      expect(card.uuid.length, greaterThan(10)); // UUID format
    });

    test('creates Flashcard with custom UUID', () {
      // When: Creating with specific UUID
      final card = FlashcardFactory.create(
        uuid: 'custom-uuid-123',
        youtubeId: 'xyz',
        title: 'Test',
        artist: 'Artist',
      );

      // Then: Custom UUID is used
      expect(card.uuid, 'custom-uuid-123');
    });

    test('generates unique UUIDs for each card', () {
      // When: Creating multiple cards
      final card1 = FlashcardFactory.create(
        youtubeId: 'id1',
        title: 'Song 1',
        artist: 'Artist',
      );
      final card2 = FlashcardFactory.create(
        youtubeId: 'id2',
        title: 'Song 2',
        artist: 'Artist',
      );

      // Then: UUIDs are different
      expect(card1.uuid, isNot(equals(card2.uuid)));
    });

    test('applies default SRS values', () {
      // When: Creating without SRS parameters
      final card = FlashcardFactory.create(
        youtubeId: 'xyz',
        title: 'Test',
        artist: 'Artist',
      );

      // Then: Defaults are applied
      expect(card.intervalDays, 0);
      expect(card.easeFactor, 2.5);
      expect(card.repetitions, 0);
      expect(card.startAtSecond, 0);
    });

    test('allows custom SRS values', () {
      // When: Creating with custom SRS values
      final card = FlashcardFactory.create(
        youtubeId: 'xyz',
        title: 'Test',
        artist: 'Artist',
        intervalDays: 7,
        easeFactor: 2.8,
        repetitions: 3,
        startAtSecond: 30,
        endAtSecond: 90,
      );

      // Then: Custom values are used
      expect(card.intervalDays, 7);
      expect(card.easeFactor, 2.8);
      expect(card.repetitions, 3);
      expect(card.startAtSecond, 30);
      expect(card.endAtSecond, 90);
    });

    test('sets timestamps to now by default', () {
      // When: Creating without timestamps
      final before = DateTime.now();
      final card = FlashcardFactory.create(
        youtubeId: 'xyz',
        title: 'Test',
        artist: 'Artist',
      );
      final after = DateTime.now();

      // Then: Timestamps are recent
      expect(card.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(card.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(card.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(card.updatedAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(card.nextReviewDate.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(card.nextReviewDate.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('FlashcardFactory - createDueCard', () {
    test('creates card with nextReviewDate in the past', () {
      // When: Creating a due card
      final card = FlashcardFactory.createDueCard(
        youtubeId: 'xyz',
        title: 'Due Song',
        artist: 'Artist',
      );

      // Then: Card is due (nextReviewDate is yesterday)
      expect(card.nextReviewDate.isBefore(DateTime.now()), isTrue);
      final hoursDifference = DateTime.now().difference(card.nextReviewDate).inHours;
      expect(hoursDifference, greaterThanOrEqualTo(23)); // ~24 hours ago
      expect(hoursDifference, lessThanOrEqualTo(25));
    });

    test('due card has default new card properties', () {
      // When: Creating a due card
      final card = FlashcardFactory.createDueCard(
        youtubeId: 'xyz',
        title: 'Test',
        artist: 'Artist',
      );

      // Then: SRS values are defaults for new card
      expect(card.intervalDays, 0);
      expect(card.easeFactor, 2.5);
      expect(card.repetitions, 0);
    });
  });

  group('FlashcardFactory - createFutureCard', () {
    test('creates card with nextReviewDate in the future', () {
      // When: Creating a future card
      final card = FlashcardFactory.createFutureCard(
        youtubeId: 'xyz',
        title: 'Future Song',
        artist: 'Artist',
      );

      // Then: Card is not due (nextReviewDate is tomorrow)
      expect(card.nextReviewDate.isAfter(DateTime.now()), isTrue);
      final hoursDifference = card.nextReviewDate.difference(DateTime.now()).inHours;
      expect(hoursDifference, greaterThanOrEqualTo(23)); // ~24 hours ahead
      expect(hoursDifference, lessThanOrEqualTo(25));
    });

    test('future card has default new card properties', () {
      // When: Creating a future card
      final card = FlashcardFactory.createFutureCard(
        youtubeId: 'xyz',
        title: 'Test',
        artist: 'Artist',
      );

      // Then: SRS values are defaults for new card
      expect(card.intervalDays, 0);
      expect(card.easeFactor, 2.5);
      expect(card.repetitions, 0);
    });
  });

  group('FlashcardFactory - Integration', () {
    test('different factory methods create valid Flashcards', () {
      // When: Creating cards with different factory methods
      final normal = FlashcardFactory.create(
        youtubeId: 'id1',
        title: 'Normal',
        artist: 'Artist',
      );
      final due = FlashcardFactory.createDueCard(
        youtubeId: 'id2',
        title: 'Due',
        artist: 'Artist',
      );
      final future = FlashcardFactory.createFutureCard(
        youtubeId: 'id3',
        title: 'Future',
        artist: 'Artist',
      );

      // Then: All have unique UUIDs
      expect(normal.uuid, isNot(equals(due.uuid)));
      expect(normal.uuid, isNot(equals(future.uuid)));
      expect(due.uuid, isNot(equals(future.uuid)));

      // And: Review dates are correctly set
      expect(due.nextReviewDate.isBefore(normal.nextReviewDate), isTrue);
      expect(future.nextReviewDate.isAfter(normal.nextReviewDate), isTrue);
    });
  });
}
