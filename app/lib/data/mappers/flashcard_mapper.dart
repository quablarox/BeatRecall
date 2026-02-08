import 'package:isar/isar.dart';

import '../../domain/entities/flashcard.dart';
import '../entities/isar_flashcard.dart';

/// Maps between domain [Flashcard] and data [IsarFlashcard] entities.
///
/// This mapper ensures clean separation between domain and data layers.
class FlashcardMapper {
  /// Converts domain [Flashcard] to data [IsarFlashcard].
  ///
  /// The [id] field (Isar's auto-increment ID) is preserved if available,
  /// otherwise defaults to [Isar.autoIncrement] for new entities.
  IsarFlashcard toData(Flashcard domain, {int? isarId}) {
    return IsarFlashcard()
      ..id = isarId ?? Isar.autoIncrement
      ..uuid = domain.uuid
      ..youtubeId = domain.youtubeId
      ..title = domain.title
      ..artist = domain.artist
      ..album = domain.album
      ..intervalDays = domain.intervalDays
      ..easeFactor = domain.easeFactor
      ..repetitions = domain.repetitions
      ..nextReviewDate = domain.nextReviewDate
      ..startAtSecond = domain.startAtSecond
      ..endAtSecond = domain.endAtSecond
      ..createdAt = domain.createdAt
      ..updatedAt = domain.updatedAt;
  }

  /// Converts data [IsarFlashcard] to domain [Flashcard].
  ///
  /// The Isar ID is discarded as the domain uses UUID for identification.
  Flashcard toDomain(IsarFlashcard data) {
    return Flashcard(
      uuid: data.uuid,
      youtubeId: data.youtubeId,
      title: data.title,
      artist: data.artist,
      album: data.album,
      intervalDays: data.intervalDays,
      easeFactor: data.easeFactor,
      repetitions: data.repetitions,
      nextReviewDate: data.nextReviewDate,
      startAtSecond: data.startAtSecond,
      endAtSecond: data.endAtSecond,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Converts a list of data entities to domain entities.
  List<Flashcard> toDomainList(List<IsarFlashcard> dataList) {
    return dataList.map(toDomain).toList();
  }

  /// Converts a list of domain entities to data entities.
  List<IsarFlashcard> toDataList(List<Flashcard> domainList) {
    return domainList.map((domain) => toData(domain)).toList();
  }
}
