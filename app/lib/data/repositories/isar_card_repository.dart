import 'package:isar/isar.dart';

import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/card_repository.dart';
import '../database/isar_database.dart';
import '../entities/isar_flashcard.dart';
import '../mappers/flashcard_mapper.dart';

/// Isar implementation of [CardRepository].
///
/// Handles the mapping between domain [Flashcard] (with UUID)
/// and data [IsarFlashcard] (with Isar ID).
class IsarCardRepository implements CardRepository {
  final Isar _isar;
  final FlashcardMapper _mapper;

  IsarCardRepository({
    Isar? isar,
    FlashcardMapper? mapper,
  })  : _isar = isar ?? IsarDatabase.instance,
        _mapper = mapper ?? FlashcardMapper();

  @override
  Future<int> countAllCards() => _isar.isarFlashcards.count();

  @override
  Future<int> countDueCards() {
    final now = DateTime.now();
    return _isar.isarFlashcards
        .filter()
        .nextReviewDateLessThan(now, include: true)
        .count();
  }

  @override
  Future<void> deleteByUuid(String uuid) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.isarFlashcards
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      
      if (existing != null) {
        await _isar.isarFlashcards.delete(existing.id);
      }
    });
  }

  @override
  Future<bool> existsByYoutubeId(String youtubeId) async {
    final match = await _isar.isarFlashcards
        .filter()
        .youtubeIdEqualTo(youtubeId)
        .findFirst();
    return match != null;
  }

  @override
  Future<Flashcard?> findByYoutubeId(String youtubeId) async {
    final result = await _isar.isarFlashcards
        .filter()
        .youtubeIdEqualTo(youtubeId)
        .findFirst();

    return result != null ? _mapper.toDomain(result) : null;
  }

  @override
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  }) async {
    final List<IsarFlashcard> results;

    if (searchQuery == null || searchQuery.trim().isEmpty) {
      results = await _isar.isarFlashcards
          .where()
          .offset(offset)
          .limit(limit)
          .findAll();
    } else {
      final q = searchQuery.trim();
      results = await _isar.isarFlashcards
          .filter()
          .group((qb) => qb
              .titleContains(q, caseSensitive: false)
              .or()
              .artistContains(q, caseSensitive: false))
          .offset(offset)
          .limit(limit)
          .findAll();
    }

    return _mapper.toDomainList(results);
  }

  @override
  Future<List<Flashcard>> fetchDueCards({int limit = 100}) async {
    final now = DateTime.now();
    final results = await _isar.isarFlashcards
        .filter()
        .nextReviewDateLessThan(now, include: true)
        .sortByNextReviewDate()
        .limit(limit)
        .findAll();

    return _mapper.toDomainList(results);
  }

  @override
  Future<Flashcard?> findByUuid(String uuid) async {
    final result = await _isar.isarFlashcards
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();

    return result != null ? _mapper.toDomain(result) : null;
  }

  @override
  Future<void> save(Flashcard card) async {
    await _isar.writeTxn(() async {
      // Check if card already exists by UUID
      final existing = await _isar.isarFlashcards
          .filter()
          .uuidEqualTo(card.uuid)
          .findFirst();

      // Preserve Isar ID if updating, otherwise use autoIncrement
      final isarCard = _mapper.toData(
        card.copyWith(updatedAt: DateTime.now()),
        isarId: existing?.id,
      );

      await _isar.isarFlashcards.put(isarCard);
    });
  }

  @override
  Future<void> saveAll(List<Flashcard> cards) async {
    final now = DateTime.now();

    await _isar.writeTxn(() async {
      for (final card in cards) {
        // Check if card already exists by UUID
        final existing = await _isar.isarFlashcards
            .filter()
            .uuidEqualTo(card.uuid)
            .findFirst();

        final isarCard = _mapper.toData(
          card.copyWith(updatedAt: now),
          isarId: existing?.id,
        );

        await _isar.isarFlashcards.put(isarCard);
      }
    });
  }

  @override
  Future<void> updateSrsFields({
    required String cardUuid,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
  }) async {
    await _isar.writeTxn(() async {
      final card = await _isar.isarFlashcards
          .filter()
          .uuidEqualTo(cardUuid)
          .findFirst();

      if (card == null) return;

      card.nextReviewDate = nextReviewDate;
      card.easeFactor = easeFactor;
      card.intervalDays = intervalDays;
      card.repetitions = repetitions;
      card.updatedAt = DateTime.now();

      await _isar.isarFlashcards.put(card);
    });
  }

  @override
  Future<void> resetAllProgress() async {
    final now = DateTime.now();
    
    await _isar.writeTxn(() async {
      final allCards = await _isar.isarFlashcards.where().findAll();
      
      for (final card in allCards) {
        card.nextReviewDate = now;
        card.easeFactor = 2.5;
        card.intervalDays = 0;
        card.repetitions = 0;
        card.updatedAt = now;
      }
      
      await _isar.isarFlashcards.putAll(allCards);
    });
  }
}
