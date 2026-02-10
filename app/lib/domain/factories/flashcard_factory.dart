import 'package:uuid/uuid.dart';

import '../entities/flashcard.dart';

/// Factory for creating [Flashcard] instances.
///
/// Provides convenient methods for creating flashcards with sensible defaults
/// and automatic UUID generation.
class FlashcardFactory {
  static const _uuid = Uuid();

  /// Creates a new flashcard with a generated UUID.
  ///
  /// All required fields must be provided. Optional fields have defaults:
  /// - [intervalMinutes]: 0 (new card, no interval yet)
  /// - [easeFactor]: 2.5 (default difficulty)
  /// - [repetitions]: 0 (not reviewed yet)
  /// - [nextReviewDate]: now (due immediately)
  /// - [startAtSecond]: 0 (start from beginning)
  /// - [createdAt]: now
  /// - [updatedAt]: now
  static Flashcard create({
    String? uuid,
    required String youtubeId,
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
      uuid: uuid ?? _uuid.v4(),
      youtubeId: youtubeId,
      title: title,
      artist: artist,
      album: album,
      year: year,
      genre: genre,
      youtubeViewCount: youtubeViewCount,
      intervalMinutes: intervalMinutes ?? 0,
      easeFactor: easeFactor ?? 2.5,
      repetitions: repetitions ?? 0,
      nextReviewDate: nextReviewDate ?? now,
      startAtSecond: startAtSecond ?? 0,
      endAtSecond: endAtSecond,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Creates a flashcard that is due for review.
  ///
  /// Sets [nextReviewDate] to yesterday.
  static Flashcard createDueCard({
    required String youtubeId,
    required String title,
    required String artist,
    String? album,
  }) {
    return create(
      youtubeId: youtubeId,
      title: title,
      artist: artist,
      album: album,
      nextReviewDate: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  /// Creates a flashcard that is not yet due.
  ///
  /// Sets [nextReviewDate] to tomorrow.
  static Flashcard createFutureCard({
    required String youtubeId,
    required String title,
    required String artist,
    String? album,
  }) {
    return create(
      youtubeId: youtubeId,
      title: title,
      artist: artist,
      album: album,
      nextReviewDate: DateTime.now().add(const Duration(days: 1)),
    );
  }
}
