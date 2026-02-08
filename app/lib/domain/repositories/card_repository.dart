import '../entities/flashcard.dart';

/// Repository interface for Flashcard persistence.
///
/// Uses UUID-based identification for stable domain references.
abstract class CardRepository {
  /// Fetches cards that are due for review.
  ///
  /// Returns cards ordered by next review date (oldest first).
  Future<List<Flashcard>> fetchDueCards({int limit = 100});

  /// Finds a single flashcard by its UUID.
  ///
  /// Returns null if no card with the given UUID exists.
  Future<Flashcard?> findByUuid(String uuid);

  /// Fetches all cards with optional search and pagination.
  ///
  /// [searchQuery] filters by title or artist (case-insensitive).
  /// Returns empty list if no cards match.
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  });

  /// Returns the total number of cards in the database.
  Future<int> countAllCards();

  /// Returns the number of cards that are currently due for review.
  Future<int> countDueCards();

  /// Saves a flashcard (insert or update based on UUID).
  ///
  /// If a card with the same UUID exists, it will be updated.
  /// Otherwise, a new card is inserted.
  Future<void> save(Flashcard card);

  /// Saves multiple flashcards in a single transaction.
  Future<void> saveAll(List<Flashcard> cards);

  /// Deletes a flashcard by its UUID.
  ///
  /// Does nothing if no card with the given UUID exists.
  Future<void> deleteByUuid(String uuid);

  /// Checks if a card with the given YouTube ID already exists.
  ///
  /// Useful for duplicate detection during import/creation.
  Future<bool> existsByYoutubeId(String youtubeId);

  /// Finds a flashcard by its YouTube ID.
  ///
  /// Returns null if no card with the given YouTube ID exists.
  /// Useful for duplicate detection and updating existing cards.
  Future<Flashcard?> findByYoutubeId(String youtubeId);

  /// Updates only the SRS fields of a card.
  ///
  /// This is an optimization for review operations that don't modify
  /// other card properties. The [updatedAt] timestamp is automatically updated.
  Future<void> updateSrsFields({
    required String cardUuid,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
  });

  /// Resets the learning progress for all cards (debug/testing only).
  ///
  /// Sets all cards to default SRS values:
  /// - nextReviewDate = now (all cards become due)
  /// - easeFactor = 2.5
  /// - intervalDays = 0
  /// - repetitions = 0
  Future<void> resetAllProgress();
}
