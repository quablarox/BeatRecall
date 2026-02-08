import 'package:isar/isar.dart';

part 'isar_flashcard.g.dart';

/// Isar persistence entity for Flashcard.
///
/// This entity is responsible for database storage only.
/// Domain logic uses [Flashcard] from domain/entities/.
@collection
class IsarFlashcard {
  /// Auto-increment Isar ID (internal database key)
  Id id = Isar.autoIncrement;

  /// UUID (stable identifier, indexed for fast lookup)
  @Index(unique: true)
  late String uuid;

  /// YouTube video ID (indexed for duplicate detection)
  @Index()
  late String youtubeId;

  /// Song title
  late String title;

  /// Artist name
  late String artist;

  /// Optional album name
  String? album;

  /// SRS: Days until next review (0 = new card)
  int intervalDays = 0;

  /// SRS: Ease Factor (default 2.5, min 1.3)
  double easeFactor = 2.5;

  /// SRS: Number of successful repetitions in a row
  int repetitions = 0;

  /// SRS: Next scheduled review date (indexed for due card queries)
  @Index()
  DateTime nextReviewDate = DateTime.now();

  /// Playback: Start position in seconds
  int startAtSecond = 0;

  /// Playback: Optional end position in seconds
  int? endAtSecond;

  /// Timestamp when the card was created
  DateTime createdAt = DateTime.now();

  /// Timestamp when the card was last modified
  DateTime updatedAt = DateTime.now();
}
