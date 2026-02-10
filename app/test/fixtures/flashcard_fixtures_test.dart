import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';

import '../fixtures/flashcard_fixtures.dart';

/// Unit tests for [FlashcardFixtures].
///
/// Verifies that the fixture factory creates valid flashcards with
/// correct defaults and optional metadata fields.
void main() {
  group('FlashcardFixtures - createCard', () {
    test('creates flashcard with required fields only', () {
      // When: Creating with minimal parameters
      final card = FlashcardFixtures.createCard(
        title: 'Test Song',
        artist: 'Test Artist',
      );

      // Then: Required fields are set
      expect(card.title, 'Test Song');
      expect(card.artist, 'Test Artist');
      expect(card.uuid, isNotEmpty);
      expect(card.youtubeId, isNotEmpty);
      
      // And: Optional metadata fields are null
      expect(card.album, isNull);
      expect(card.year, isNull);
      expect(card.genre, isNull);
      expect(card.youtubeViewCount, isNull);
      
      // And: SRS defaults are applied
      expect(card.repetitions, 0);
      expect(card.intervalMinutes, 0);
      expect(card.easeFactor, 2.5);
    });

    test('creates flashcard with all optional metadata fields', () {
      // When: Creating with all metadata
      final card = FlashcardFixtures.createCard(
        title: 'Never Gonna Give You Up',
        artist: 'Rick Astley',
        album: 'Whenever You Need Somebody',
        year: 1987,
        genre: 'Pop',
        youtubeViewCount: 1500000000,
      );

      // Then: All metadata fields are set
      expect(card.album, 'Whenever You Need Somebody');
      expect(card.year, 1987);
      expect(card.genre, 'Pop');
      expect(card.youtubeViewCount, 1500000000);
    });

    test('creates flashcard with partial metadata', () {
      // When: Creating with some metadata
      final card = FlashcardFixtures.createCard(
        title: 'Modern Song',
        artist: 'New Artist',
        year: 2024,
        genre: 'Electronic',
        // album and youtubeViewCount omitted
      );

      // Then: Provided fields are set
      expect(card.year, 2024);
      expect(card.genre, 'Electronic');
      
      // And: Omitted fields are null
      expect(card.album, isNull);
      expect(card.youtubeViewCount, isNull);
    });

    test('allows custom SRS values', () {
      // When: Creating with custom SRS parameters
      final card = FlashcardFixtures.createCard(
        title: 'Test',
        artist: 'Test',
        repetitions: 5,
        intervalMinutes: 10080,
        easeFactor: 2.8,
      );

      // Then: Custom values are used
      expect(card.repetitions, 5);
      expect(card.intervalMinutes, 10080);
      expect(card.easeFactor, 2.8);
    });

    test('auto-calculates interval from repetitions', () {
      // When: Creating with repetitions but no interval
      final card = FlashcardFixtures.createCard(
        title: 'Test',
        artist: 'Test',
        repetitions: 3,
      );

      // Then: Interval is calculated (3 * 2880 = 8640 minutes)
      expect(card.intervalMinutes, 8640);
    });
  });

  group('FlashcardFixtures - createNewCard', () {
    test('creates new card with correct defaults', () {
      // When: Creating a new card
      final card = FlashcardFixtures.createNewCard(
        title: 'New Song',
        artist: 'Artist',
      );

      // Then: Card has new card properties
      expect(card.repetitions, 0);
      expect(card.intervalMinutes, 0);
      expect(card.nextReviewDate.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });

    test('new card can have metadata', () {
      // When: Creating new card with metadata
      final card = FlashcardFixtures.createNewCard(
        title: 'New Song',
        artist: 'Artist',
        album: 'Debut Album',
        year: 2024,
        genre: 'Pop',
        youtubeViewCount: 50000,
      );

      // Then: Metadata is preserved
      expect(card.album, 'Debut Album');
      expect(card.year, 2024);
      expect(card.genre, 'Pop');
      expect(card.youtubeViewCount, 50000);
      
      // And: Still a new card
      expect(card.repetitions, 0);
    });
  });

  group('FlashcardFixtures - createDueCard', () {
    test('creates due card with past review date', () {
      // When: Creating a due card
      final card = FlashcardFixtures.createDueCard(
        title: 'Due Song',
        artist: 'Artist',
      );

      // Then: Card is overdue
      expect(card.nextReviewDate.isBefore(DateTime.now()), isTrue);
      expect(card.repetitions, greaterThan(0));
    });

    test('allows custom overdue days', () {
      // When: Creating card 5 days overdue
      final card = FlashcardFixtures.createDueCard(
        title: 'Very Overdue',
        artist: 'Artist',
        daysOverdue: 5,
      );

      // Then: nextReviewDate is 5 days ago
      final expectedDate = DateTime.now().subtract(const Duration(days: 5));
      expect(card.nextReviewDate.difference(expectedDate).inHours.abs(), lessThan(1));
    });

    test('due card can have metadata', () {
      // When: Creating due card with metadata
      final card = FlashcardFixtures.createDueCard(
        title: 'Classic Hit',
        artist: 'Legend',
        album: 'Greatest Hits',
        year: 1975,
        genre: 'Rock',
      );

      // Then: Both metadata and due status are correct
      expect(card.album, 'Greatest Hits');
      expect(card.year, 1975);
      expect(card.nextReviewDate.isBefore(DateTime.now()), isTrue);
    });
  });

  group('FlashcardFixtures - createFutureCard', () {
    test('creates future card with future review date', () {
      // When: Creating a future card
      final card = FlashcardFixtures.createFutureCard(
        title: 'Future Song',
        artist: 'Artist',
      );

      // Then: Card is not yet due
      expect(card.nextReviewDate.isAfter(DateTime.now()), isTrue);
    });

    test('allows custom days until due', () {
      // When: Creating card due in 7 days
      final card = FlashcardFixtures.createFutureCard(
        title: 'Next Week',
        artist: 'Artist',
        daysUntilDue: 7,
      );

      // Then: nextReviewDate is ~7 days from now
      final expectedDate = DateTime.now().add(const Duration(days: 7));
      expect(card.nextReviewDate.difference(expectedDate).inHours.abs(), lessThan(1));
    });
  });

  group('FlashcardFixtures - status-specific cards', () {
    test('createLearningCard has 1-2 repetitions', () {
      // When: Creating learning card
      final card = FlashcardFixtures.createLearningCard(
        title: 'Learning',
        artist: 'Artist',
        repetitions: 2,
      );

      // Then: Has learning card properties
      expect(card.repetitions, 2);
      expect(card.intervalMinutes, 5760); // 2 * 2880
    });

    test('createReviewCard has 3+ repetitions', () {
      // When: Creating review card
      final card = FlashcardFixtures.createReviewCard(
        title: 'Review',
        artist: 'Artist',
        repetitions: 5,
      );

      // Then: Has review card properties
      expect(card.repetitions, 5);
      expect(card.intervalMinutes, 21600); // 5 * 4320
    });
  });

  group('FlashcardFixtures - createCardWithMetadata', () {
    test('creates card with all metadata populated', () {
      // When: Creating card with default metadata
      final card = FlashcardFixtures.createCardWithMetadata();

      // Then: All metadata fields are populated
      expect(card.title, isNotEmpty);
      expect(card.artist, isNotEmpty);
      expect(card.album, isNotNull);
      expect(card.year, isNotNull);
      expect(card.genre, isNotNull);
      expect(card.youtubeViewCount, isNotNull);
    });

    test('allows overriding default metadata', () {
      // When: Creating with custom metadata
      final card = FlashcardFixtures.createCardWithMetadata(
        title: 'Custom Song',
        year: 2000,
        genre: 'Jazz',
      );

      // Then: Custom values are used
      expect(card.title, 'Custom Song');
      expect(card.year, 2000);
      expect(card.genre, 'Jazz');
    });
  });

  group('FlashcardFixtures - batch creation', () {
    test('createBatch generates multiple cards', () {
      // When: Creating batch of 5 cards
      final cards = FlashcardFixtures.createBatch(count: 5);

      // Then: 5 cards are created
      expect(cards.length, 5);
      
      // And: Each has sequential title
      expect(cards[0].title, 'Test Song 1');
      expect(cards[4].title, 'Test Song 5');
      
      // And: Each has unique UUID
      final uuids = cards.map((c) => c.uuid).toSet();
      expect(uuids.length, 5);
    });

    test('createBatch with metadata includes optional fields', () {
      // When: Creating batch with metadata
      final cards = FlashcardFixtures.createBatch(
        count: 3,
        withMetadata: true,
      );

      // Then: All cards have metadata
      for (final card in cards) {
        expect(card.album, isNotNull);
        expect(card.year, isNotNull);
        expect(card.genre, isNotNull);
        expect(card.youtubeViewCount, isNotNull);
      }
    });

    test('createBatch without metadata has null optional fields', () {
      // When: Creating batch without metadata
      final cards = FlashcardFixtures.createBatch(
        count: 3,
        withMetadata: false,
      );

      // Then: Metadata fields are null
      for (final card in cards) {
        expect(card.album, isNull);
        expect(card.year, isNull);
        expect(card.genre, isNull);
        expect(card.youtubeViewCount, isNull);
      }
    });
  });

  group('FlashcardFixtures - mixed status batch', () {
    test('creates cards with varied statuses', () {
      // When: Creating mixed status batch
      final cards = FlashcardFixtures.createMixedStatusBatch();

      // Then: Has new cards (repetitions = 0)
      final newCards = cards.where((c) => c.repetitions == 0).length;
      expect(newCards, greaterThan(0));
      
      // And: Has learning cards (1-2 repetitions)
      final learningCards = cards.where((c) => c.repetitions >= 1 && c.repetitions <= 2).length;
      expect(learningCards, greaterThan(0));
      
      // And: Has review cards (3+ repetitions)
      final reviewCards = cards.where((c) => c.repetitions >= 3).length;
      expect(reviewCards, greaterThan(0));
    });
  });

  group('FlashcardFixtures - varied due date batch', () {
    test('creates cards with different due dates', () {
      // When: Creating varied due date batch
      final cards = FlashcardFixtures.createVariedDueDateBatch();
      final now = DateTime.now();

      // Then: Has overdue cards
      final overdue = cards.where((c) => c.nextReviewDate.isBefore(now)).length;
      expect(overdue, greaterThan(0));
      
      // And: Has future cards
      final future = cards.where((c) => c.nextReviewDate.isAfter(now.add(const Duration(hours: 1)))).length;
      expect(future, greaterThan(0));
    });
  });

  group('FlashcardFixtures - classic songs', () {
    test('creates realistic cards with real metadata', () {
      // When: Creating classic songs
      final cards = FlashcardFixtures.createClassicSongsWithMetadata();

      // Then: All cards have complete metadata
      expect(cards.length, greaterThan(0));
      
      for (final card in cards) {
        expect(card.title, isNotEmpty);
        expect(card.artist, isNotEmpty);
        expect(card.album, isNotNull);
        expect(card.year, isNotNull);
        expect(card.genre, isNotNull);
        expect(card.youtubeViewCount, isNotNull);
        expect(card.youtubeId, isNotEmpty);
      }
    });

    test('classic songs have realistic view counts', () {
      // When: Creating classic songs
      final cards = FlashcardFixtures.createClassicSongsWithMetadata();

      // Then: View counts are reasonable (> 100M)
      for (final card in cards) {
        expect(card.youtubeViewCount!, greaterThan(100000000));
      }
    });
  });
}
