import '../entities/flashcard.dart';

abstract class CardRepository {
  Future<List<Flashcard>> fetchDueCards({int limit = 100});
  Future<Flashcard?> findById(int id);
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  });

  Future<int> countAllCards();
  Future<int> countDueCards();

  Future<void> save(Flashcard card);
  Future<void> saveAll(List<Flashcard> cards);
  Future<void> delete(int id);

  Future<bool> existsByYoutubeId(String youtubeId);

  Future<void> updateSrsFields({
    required int cardId,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
  });
}
