import 'package:beat_recall/domain/entities/flashcard.dart';

/// Test fixtures for creating [Flashcard] instances in tests.
///
/// Provides factory methods for creating flashcards with sensible defaults
/// and optional parameters for all fields including metadata.
class FlashcardFixtures {
  /// Creates a test flashcard with customizable parameters.
  ///
  /// All parameters are optional except [title] and [artist].
  /// Provides sensible defaults for all other fields.
  ///
  /// Example:
  /// ```dart
  /// final card = FlashcardFixtures.createCard(
  ///   title: 'Never Gonna Give You Up',
  ///   artist: 'Rick Astley',
  ///   album: 'Whenever You Need Somebody',
  ///   year: 1987,
  ///   genre: 'Pop',
  ///   youtubeViewCount: 1500000000,
  /// );
  /// ```
  static Flashcard createCard({
    String? uuid,
    String? youtubeId,
    required String title,
    required String artist,
    String? album,
    int? year,
    String? genre,
    int? youtubeViewCount,
    int? intervalMinutes,
    double? easeFactor,
    int? repetitions,
    DateTime? nextReviewDate,
    int? startAtSecond,
    int? endAtSecond,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return Flashcard(
      uuid: uuid ?? 'test-uuid-${title.hashCode}',
      youtubeId: youtubeId ?? 'test-yt-${title.hashCode}',
      title: title,
      artist: artist,
      album: album,
      year: year,
      genre: genre,
      youtubeViewCount: youtubeViewCount,
      intervalMinutes: intervalMinutes ?? (repetitions != null && repetitions > 0 ? repetitions * 2880 : 0),
      easeFactor: easeFactor ?? 2.5,
      repetitions: repetitions ?? 0,
      nextReviewDate: nextReviewDate ?? now,
      startAtSecond: startAtSecond ?? 0,
      endAtSecond: endAtSecond,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Creates a new flashcard (not yet reviewed).
  ///
  /// Sets repetitions=0, intervalMinutes=0, nextReviewDate=now.
  static Flashcard createNewCard({
    required String title,
    required String artist,
    String? album,
    int? year,
    String? genre,
    int? youtubeViewCount,
  }) {
    return createCard(
      title: title,
      artist: artist,
      album: album,
      year: year,
      genre: genre,
      youtubeViewCount: youtubeViewCount,
      repetitions: 0,
      intervalMinutes: 0,
      nextReviewDate: DateTime.now(),
    );
  }

  /// Creates a due flashcard (review date in the past).
  ///
  /// Sets nextReviewDate to yesterday by default.
  static Flashcard createDueCard({
    required String title,
    required String artist,
    String? album,
    int? year,
    String? genre,
    int? youtubeViewCount,
    int? repetitions,
    int? daysOverdue,
  }) {
    final overdue = daysOverdue ?? 1;
    return createCard(
      title: title,
      artist: artist,
      album: album,
      year: year,
      genre: genre,
      youtubeViewCount: youtubeViewCount,
      repetitions: repetitions ?? 1,
      nextReviewDate: DateTime.now().subtract(Duration(days: overdue)),
      intervalMinutes: (repetitions ?? 1) * 2880,
    );
  }

  /// Creates a future flashcard (not yet due).
  ///
  /// Sets nextReviewDate to tomorrow by default.
  static Flashcard createFutureCard({
    required String title,
    required String artist,
    String? album,
    int? year,
    String? genre,
    int? youtubeViewCount,
    int? repetitions,
    int? daysUntilDue,
  }) {
    final daysAhead = daysUntilDue ?? 1;
    return createCard(
      title: title,
      artist: artist,
      album: album,
      year: year,
      genre: genre,
      youtubeViewCount: youtubeViewCount,
      repetitions: repetitions ?? 1,
      nextReviewDate: DateTime.now().add(Duration(days: daysAhead)),
      intervalMinutes: (repetitions ?? 1) * 2880,
    );
  }

  /// Creates a learning card (reviewed 1-2 times).
  ///
  /// Sets repetitions between 1-2 with appropriate interval.
  static Flashcard createLearningCard({
    required String title,
    required String artist,
    String? album,
    int? year,
    String? genre,
    int? youtubeViewCount,
    int? repetitions,
  }) {
    final reps = repetitions ?? 1;
    return createCard(
      title: title,
      artist: artist,
      album: album,
      year: year,
      genre: genre,
      youtubeViewCount: youtubeViewCount,
      repetitions: reps,
      intervalMinutes: reps * 2880, // 2-4 days
      nextReviewDate: DateTime.now(),
    );
  }

  /// Creates a review card (reviewed 3+ times).
  ///
  /// Sets repetitions to 3 or more with longer interval.
  static Flashcard createReviewCard({
    required String title,
    required String artist,
    String? album,
    int? year,
    String? genre,
    int? youtubeViewCount,
    int? repetitions,
  }) {
    final reps = repetitions ?? 3;
    return createCard(
      title: title,
      artist: artist,
      album: album,
      year: year,
      genre: genre,
      youtubeViewCount: youtubeViewCount,
      repetitions: reps,
      intervalMinutes: reps * 4320, // 9+ days
      nextReviewDate: DateTime.now(),
    );
  }

  /// Creates a flashcard with rich metadata (all optional fields populated).
  ///
  /// Useful for testing metadata display functionality.
  static Flashcard createCardWithMetadata({
    String? title,
    String? artist,
    String? album,
    int? year,
    String? genre,
    int? youtubeViewCount,
  }) {
    return createCard(
      title: title ?? 'Never Gonna Give You Up',
      artist: artist ?? 'Rick Astley',
      album: album ?? 'Whenever You Need Somebody',
      year: year ?? 1987,
      genre: genre ?? 'Pop',
      youtubeViewCount: youtubeViewCount ?? 1500000000,
    );
  }

  /// Creates a batch of test flashcards with sequential titles.
  ///
  /// Useful for testing lists, pagination, etc.
  static List<Flashcard> createBatch({
    required int count,
    String? titlePrefix,
    String? artist,
    bool withMetadata = false,
  }) {
    return List.generate(count, (index) {
      final title = '${titlePrefix ?? "Test Song"} ${index + 1}';
      return createCard(
        title: title,
        artist: artist ?? 'Test Artist',
        album: withMetadata ? 'Test Album' : null,
        year: withMetadata ? 2020 + index : null,
        genre: withMetadata ? 'Pop' : null,
        youtubeViewCount: withMetadata ? 1000000 + (index * 100000) : null,
      );
    });
  }

  /// Creates a list of flashcards with varying review statuses.
  ///
  /// Returns a mix of new, learning, and review cards for comprehensive testing.
  static List<Flashcard> createMixedStatusBatch() {
    return [
      createNewCard(title: 'New Card 1', artist: 'Artist A'),
      createNewCard(title: 'New Card 2', artist: 'Artist B'),
      createLearningCard(title: 'Learning Card 1', artist: 'Artist C', repetitions: 1),
      createLearningCard(title: 'Learning Card 2', artist: 'Artist D', repetitions: 2),
      createReviewCard(title: 'Review Card 1', artist: 'Artist E', repetitions: 5),
      createReviewCard(title: 'Review Card 2', artist: 'Artist F', repetitions: 10),
    ];
  }

  /// Creates cards with different due dates for testing filters.
  ///
  /// Returns cards that are overdue, due today, and due in the future.
  static List<Flashcard> createVariedDueDateBatch() {
    final now = DateTime.now();
    return [
      createCard(title: 'Overdue 1', artist: 'Artist A', nextReviewDate: now.subtract(const Duration(days: 5)), repetitions: 1),
      createCard(title: 'Overdue 2', artist: 'Artist B', nextReviewDate: now.subtract(const Duration(days: 1)), repetitions: 2),
      createCard(title: 'Due Today', artist: 'Artist C', nextReviewDate: now, repetitions: 1),
      createCard(title: 'Due Tomorrow', artist: 'Artist D', nextReviewDate: now.add(const Duration(days: 1)), repetitions: 1),
      createCard(title: 'Due Next Week', artist: 'Artist E', nextReviewDate: now.add(const Duration(days: 7)), repetitions: 1),
    ];
  }

  /// Creates classic songs with real-world metadata.
  ///
  /// Useful for integration tests and realistic test scenarios.
  static List<Flashcard> createClassicSongsWithMetadata() {
    return [
      createCard(
        title: 'Never Gonna Give You Up',
        artist: 'Rick Astley',
        album: 'Whenever You Need Somebody',
        year: 1987,
        genre: 'Pop',
        youtubeViewCount: 1500000000,
        youtubeId: 'dQw4w9WgXcQ',
      ),
      createCard(
        title: 'Bohemian Rhapsody',
        artist: 'Queen',
        album: 'A Night at the Opera',
        year: 1975,
        genre: 'Rock',
        youtubeViewCount: 1800000000,
        youtubeId: 'fJ9rUzIMcZQ',
      ),
      createCard(
        title: 'Stairway to Heaven',
        artist: 'Led Zeppelin',
        album: 'Led Zeppelin IV',
        year: 1971,
        genre: 'Rock',
        youtubeViewCount: 500000000,
        youtubeId: 'QkF3oxziUI4',
      ),
      createCard(
        title: 'Imagine',
        artist: 'John Lennon',
        album: 'Imagine',
        year: 1971,
        genre: 'Soft Rock',
        youtubeViewCount: 450000000,
        youtubeId: 'YkgkThdzX-8',
      ),
      createCard(
        title: 'Smells Like Teen Spirit',
        artist: 'Nirvana',
        album: 'Nevermind',
        year: 1991,
        genre: 'Grunge',
        youtubeViewCount: 1400000000,
        youtubeId: 'hTWKbfoikeg',
      ),
    ];
  }
}
