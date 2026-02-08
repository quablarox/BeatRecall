import 'package:isar/isar.dart';

import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/card_repository.dart';
import '../database/isar_database.dart';

class IsarCardRepository implements CardRepository {
  final Isar _isar;

  IsarCardRepository({Isar? isar}) : _isar = isar ?? IsarDatabase.instance;

  @override
  Future<int> countAllCards() => _isar.flashcards.count();

  @override
  Future<int> countDueCards() {
    final now = DateTime.now();
    return _isar.flashcards
        .filter()
        .nextReviewDateLessThan(now, include: true)
        .count();
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.flashcards.delete(id);
    });
  }

  @override
  Future<bool> existsByYoutubeId(String youtubeId) async {
    final match = await _isar.flashcards.filter().youtubeIdEqualTo(youtubeId).findFirst();
    return match != null;
  }

  @override
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  }) {
    final query = _isar.flashcards.where();

    if (searchQuery == null || searchQuery.trim().isEmpty) {
      return query.offset(offset).limit(limit).findAll();
    }

    final q = searchQuery.trim();
    return _isar.flashcards
        .filter()
        .group((qb) => qb.titleContains(q, caseSensitive: false).or().artistContains(q, caseSensitive: false))
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  @override
  Future<List<Flashcard>> fetchDueCards({int limit = 100}) {
    final now = DateTime.now();
    return _isar.flashcards
        .filter()
      .nextReviewDateLessThan(now, include: true)
        .sortByNextReviewDate()
        .limit(limit)
        .findAll();
  }

  @override
  Future<Flashcard?> findById(int id) => _isar.flashcards.get(id);

  @override
  Future<void> save(Flashcard card) async {
    card.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.flashcards.put(card);
    });
  }

  @override
  Future<void> saveAll(List<Flashcard> cards) async {
    final now = DateTime.now();
    for (final card in cards) {
      card.updatedAt = now;
    }

    await _isar.writeTxn(() async {
      await _isar.flashcards.putAll(cards);
    });
  }

  @override
  Future<void> updateSrsFields({
    required int cardId,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
  }) async {
    await _isar.writeTxn(() async {
      final card = await _isar.flashcards.get(cardId);
      if (card == null) return;

      card.nextReviewDate = nextReviewDate;
      card.easeFactor = easeFactor;
      card.intervalDays = intervalDays;
      card.repetitions = repetitions;
      card.updatedAt = DateTime.now();

      await _isar.flashcards.put(card);
    });
  }
}
