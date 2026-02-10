/// Domain entity representing a music flashcard.
///
/// This is a pure Dart class without any database-specific dependencies.
/// The [uuid] serves as the stable identifier across the application.
class Flashcard {
  /// Unique identifier (stable across persistence)
  final String uuid;

  /// YouTube video ID
  final String youtubeId;

  /// Song title
  final String title;

  /// Artist name
  final String artist;

  /// Optional album name
  final String? album;

  /// Optional release year
  final int? year;

  /// Optional genre
  final String? genre;

  /// Optional YouTube view count
  final int? youtubeViewCount;

  /// SRS: Minutes until next review (0 = learning card, <1440 = learning, >=1440 = graduated)
  final int intervalMinutes;

  /// SRS: Ease Factor (default 2.5, min 1.3)
  final double easeFactor;

  /// SRS: Number of successful repetitions in a row
  final int repetitions;

  /// SRS: Next scheduled review date
  final DateTime nextReviewDate;

  /// Playback: Start position in seconds
  final int startAtSecond;

  /// Playback: Optional end position in seconds
  final int? endAtSecond;

  /// Timestamp when the card was created
  final DateTime createdAt;

  /// Timestamp when the card was last modified
  final DateTime updatedAt;

  const Flashcard({
    required this.uuid,
    required this.youtubeId,
    required this.title,
    required this.artist,
    this.album,
    this.year,
    this.genre,
    this.youtubeViewCount,
    this.intervalMinutes = 0,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    required this.nextReviewDate,
    this.startAtSecond = 0,
    this.endAtSecond,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy with modified fields
  Flashcard copyWith({
    String? uuid,
    String? youtubeId,
    String? title,
    String? artist,
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
    return Flashcard(
      uuid: uuid ?? this.uuid,
      youtubeId: youtubeId ?? this.youtubeId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      youtubeViewCount: youtubeViewCount ?? this.youtubeViewCount,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      startAtSecond: startAtSecond ?? this.startAtSecond,
      endAtSecond: endAtSecond ?? this.endAtSecond,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Flashcard &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Flashcard{uuid: $uuid, title: $title, artist: $artist}';
  }
}
