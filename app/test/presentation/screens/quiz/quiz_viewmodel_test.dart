import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/repositories/card_repository.dart';
import 'package:beat_recall/presentation/screens/quiz/quiz_viewmodel.dart';
import 'package:beat_recall/services/srs_service.dart';
import 'package:beat_recall/services/settings_service.dart';

class MockCardRepository implements CardRepository {
  final Map<String, Flashcard> _cardsByUuid = {};
  final Map<String, Flashcard> _cardsByYoutubeId = {};

  @override
  Future<List<Flashcard>> fetchDueCards({int limit = 100}) async {
    final now = DateTime.now();
    final dueCards = _cardsByUuid.values
        .where((card) =>
            card.repetitions > 0 && !card.nextReviewDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
    return dueCards.take(limit).toList();
  }

  @override
  Future<Flashcard?> findByUuid(String uuid) async => _cardsByUuid[uuid];

  @override
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  }) async {
    Iterable<Flashcard> cards = _cardsByUuid.values;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      cards = cards.where((card) {
        return card.title.toLowerCase().contains(query) ||
            card.artist.toLowerCase().contains(query);
      });
    }
    return cards.skip(offset).take(limit).toList();
  }

  @override
  Future<int> countAllCards() async => _cardsByUuid.length;

  @override
  Future<int> countDueCards() async => (await fetchDueCards()).length;

  @override
  Future<void> save(Flashcard card) async {
    _cardsByUuid[card.uuid] = card;
    _cardsByYoutubeId[card.youtubeId] = card;
  }

  @override
  Future<void> saveAll(List<Flashcard> cards) async {
    for (final card in cards) {
      await save(card);
    }
  }

  @override
  Future<void> deleteByUuid(String uuid) async {
    final card = _cardsByUuid.remove(uuid);
    if (card != null) {
      _cardsByYoutubeId.remove(card.youtubeId);
    }
  }

  @override
  Future<bool> existsByYoutubeId(String youtubeId) async {
    return _cardsByYoutubeId.containsKey(youtubeId);
  }

  @override
  Future<Flashcard?> findByYoutubeId(String youtubeId) async {
    return _cardsByYoutubeId[youtubeId];
  }

  @override
  Future<void> updateSrsFields({
    required String cardUuid,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalMinutes,
    required int repetitions,
  }) async {
    final card = _cardsByUuid[cardUuid];
    if (card == null) return;

    final updated = card.copyWith(
      nextReviewDate: nextReviewDate,
      easeFactor: easeFactor,
      intervalMinutes: intervalMinutes,
      repetitions: repetitions,
      updatedAt: DateTime.now(),
    );
    _cardsByUuid[cardUuid] = updated;
    _cardsByYoutubeId[card.youtubeId] = updated;
  }

  @override
  Future<void> resetAllProgress() async {
    final now = DateTime.now();
    final resetCards = _cardsByUuid.values.map((card) {
      return card.copyWith(
        nextReviewDate: now,
        easeFactor: 2.5,
        intervalMinutes: 0,
        repetitions: 0,
        updatedAt: now,
      );
    }).toList();

    _cardsByUuid.clear();
    _cardsByYoutubeId.clear();
    for (final card in resetCards) {
      _cardsByUuid[card.uuid] = card;
      _cardsByYoutubeId[card.youtubeId] = card;
    }
  }
}

/// Test suite for QuizViewModel
/// 
/// **Features Tested:**
/// - @DUEQUEUE-003: Continuous session mode
/// - @SETTINGS-001: Daily new cards limit integration
/// - @FLASHSYS-005: Enhanced interval display
/// - @SRS-001: SM-2 algorithm integration
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuizViewModel viewModel;
  late MockCardRepository repository;
  late SrsService srsService;
  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    
    repository = MockCardRepository();
    srsService = const SrsService();
    settingsService = SettingsService();
    await settingsService.initialize();
    
    viewModel = QuizViewModel(
      cardRepository: repository,
      srsService: srsService,
      settingsService: settingsService,
    );

    // Clean up database before each test
    final allCards = await repository.fetchAllCards();
    for (final card in allCards) {
      await repository.deleteByUuid(card.uuid);
    }
  });

  tearDown(() async {
    // Clean up after each test
    final allCards = await repository.fetchAllCards();
    for (final card in allCards) {
      await repository.deleteByUuid(card.uuid);
    }
  });


  group('@DUEQUEUE-003 Continuous Session Mode', () {
    test('Given no due cards, When loadDueCards, Then totalCards is 0', () async {
      await viewModel.loadDueCards();
      
      expect(viewModel.totalCards, 0);
    });

    test('Given 5 due cards, When loadDueCards, Then loads all 5', () async {
      // Create 5 due cards
      final now = DateTime.now();
      for (var i = 0; i < 5; i++) {
        await repository.save(Flashcard(
          uuid: 'test-uuid-$i',
          youtubeId: 'TEST$i',
          title: 'Song $i',
          artist: 'Artist $i',
          nextReviewDate: now.subtract(const Duration(days: 1)),
          intervalMinutes: 14400,
          easeFactor: 2.5,
          repetitions: 2,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      
      expect(viewModel.totalCards, 5);
      expect(viewModel.currentIndex, 0);
    });

    test('Given card rated Again, When interval is 0, Then card re-enters queue', () async {
      // Create a due card
      final now = DateTime.now();
      final card = Flashcard(
        uuid: 'test-uuid',
        youtubeId: 'TEST123',
        title: 'Test Song',
        artist: 'Test Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalMinutes: 7200,
        easeFactor: 2.5,
        repetitions: 1,
        createdAt: now,
        updatedAt: now,
      );
      await repository.save(card);
      
      await viewModel.loadDueCards();
      final initialCount = viewModel.totalCards;
      
      // Rate as Again - should reset interval to 0 and re-enter queue
      await viewModel.rateCard(0); // 0 = 0
      
      // Card should still be in queue (total didn't decrease)
      expect(viewModel.remainingCards, 1);
      expect(viewModel.totalCards, initialCount + 1);
    });

    test('Given card rated Hard/Good/Easy, When rated, Then removes from queue', () async {
      // Create 3 due cards
      final now = DateTime.now();
      for (var i = 0; i < 3; i++) {
        await repository.save(Flashcard(
          uuid: 'test-uuid-$i',
          youtubeId: 'TEST$i',
          title: 'Song $i',
          artist: 'Artist $i',
          nextReviewDate: now.subtract(const Duration(days: 1)),
          intervalMinutes: 14400,
          easeFactor: 2.5,
          repetitions: 2,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      expect(viewModel.totalCards, 3);
      
      // Rate first card as Good
      await viewModel.rateCard(3); // 3 = 3
      
      // Should move to next card, total reduced by 1
      expect(viewModel.currentIndex, 1);
      expect(viewModel.remainingCards, 2);
    });

    test('Given session ends, When all cards reviewed, Then hasCards is false', () async {
      // Create 2 due cards
      final now = DateTime.now();
      for (var i = 0; i < 2; i++) {
        await repository.save(Flashcard(
          uuid: 'test-uuid-$i',
          youtubeId: 'TEST$i',
          title: 'Song $i',
          artist: 'Artist $i',
          nextReviewDate: now.subtract(const Duration(days: 1)),
          intervalMinutes: 14400,
          easeFactor: 2.5,
          repetitions: 2,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      
      // Review all cards
      await viewModel.rateCard(3); // 3 = 3
      await viewModel.rateCard(3); // 3 = 3
      
      expect(viewModel.remainingCards, 0);
      expect(viewModel.isSessionComplete, true);
    });
  });

  group('@SETTINGS-001 Daily New Cards Limit Integration', () {
    test('Given daily limit 20 and 10 new cards, When loadDueCards, Then includes all 10', () async {
      await settingsService.setNewCardsPerDay(20);
      
      // Create 10 new cards
      final now = DateTime.now();
      for (var i = 0; i < 10; i++) {
        await repository.save(Flashcard(
          uuid: 'new-uuid-$i',
          youtubeId: 'NEW$i',
          title: 'New Song $i',
          artist: 'Artist $i',
          repetitions: 0, // New card
          nextReviewDate: now,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      
      expect(viewModel.totalCards, 10);
    });

    test('Given daily limit 5 and 10 new cards, When loadDueCards, Then includes only 5', () async {
      await settingsService.setNewCardsPerDay(5);
      
      // Create 10 new cards
      final now = DateTime.now();
      for (var i = 0; i < 10; i++) {
        await repository.save(Flashcard(
          uuid: 'new-uuid-$i',
          youtubeId: 'NEW$i',
          title: 'New Song $i',
          artist: 'Artist $i',
          repetitions: 0,
          nextReviewDate: now,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      
      expect(viewModel.totalCards, 5);
    });

    test('Given daily limit 10 and 5 already studied, When loadDueCards, Then includes 5 more', () async {
      await settingsService.setNewCardsPerDay(10);
      
      // Simulate 5 already studied today
      for (var i = 0; i < 5; i++) {
        settingsService.incrementNewCardsStudied();
      }
      
      // Create 10 new cards
      final now = DateTime.now();
      for (var i = 0; i < 10; i++) {
        await repository.save(Flashcard(
          uuid: 'new-uuid-$i',
          youtubeId: 'NEW$i',
          title: 'New Song $i',
          artist: 'Artist $i',
          repetitions: 0,
          nextReviewDate: now,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      
      expect(viewModel.totalCards, 5); // Only 5 more allowed
    });

    test('Given daily limit 0, When loadDueCards, Then excludes new cards', () async {
      await settingsService.setNewCardsPerDay(0);
      
      // Create 5 new cards and 3 due cards
      final now = DateTime.now();
      for (var i = 0; i < 5; i++) {
        await repository.save(Flashcard(
          uuid: 'new-uuid-$i',
          youtubeId: 'NEW$i',
          title: 'New Song $i',
          artist: 'Artist $i',
          repetitions: 0,
          nextReviewDate: now,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      for (var i = 0; i < 3; i++) {
        await repository.save(Flashcard(
          uuid: 'due-uuid-$i',
          youtubeId: 'DUE$i',
          title: 'Due Song $i',
          artist: 'Artist $i',
          nextReviewDate: now.subtract(const Duration(days: 1)),
          intervalMinutes: 14400,
          easeFactor: 2.5,
          repetitions: 2,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      
      expect(viewModel.totalCards, 3); // Only due cards, no new cards
    });

    test('Given new card studied, When rated, Then increments counter', () async {
      await settingsService.setNewCardsPerDay(20);
      
      // Create 1 new card
      final now = DateTime.now();
      await repository.save(Flashcard(
        uuid: 'new-uuid',
        youtubeId: 'NEW',
        title: 'New Song',
        artist: 'Artist',
        repetitions: 0,
        nextReviewDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      final beforeCount = settingsService.getNewCardsStudiedToday();
      
      // Rate the new card
      await viewModel.rateCard(3);
      
      final afterCount = settingsService.getNewCardsStudiedToday();
      expect(afterCount, beforeCount + 1);
    });

    test('Given existing card studied, When rated, Then does not increment counter', () async {
      // Create 1 due card (not new)
      final now = DateTime.now();
      await repository.save(Flashcard(
        uuid: 'exist-uuid',
        youtubeId: 'EXIST',
        title: 'Existing Song',
        artist: 'Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalMinutes: 14400,
        easeFactor: 2.5,
        repetitions: 3, // Not a new card
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      final beforeCount = settingsService.getNewCardsStudiedToday();
      
      // Rate the existing card
      await viewModel.rateCard(3);
      
      final afterCount = settingsService.getNewCardsStudiedToday();
      expect(afterCount, beforeCount); // No change
    });
  });

  group('@FLASHSYS-005 Enhanced Interval Display', () {
    test('Given current card, When getNextIntervals, Then formats intervals correctly', () async {
      // Create a card with known state
      final now = DateTime.now();
      await repository.save(Flashcard(
        uuid: 'test-uuid',
        youtubeId: 'TEST',
        title: 'Test Song',
        artist: 'Test Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalMinutes: 7200,
        easeFactor: 2.5,
        repetitions: 2,
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      final intervals = viewModel.getNextIntervals();
      
      // Verify all 4 intervals are formatted
      expect(intervals.length, 4);
      expect(intervals[0], isNotNull);
      expect(intervals[1], isNotNull);
      expect(intervals[3], isNotNull);
      expect(intervals[4], isNotNull);
      
      // Formats should match enhanced display patterns
      // Examples: "1m", "10m", "1h", "1d", "3d", "2w", "1mo"
      expect(intervals[0], matches(r'^(\d+m|\d+h|\d+d|\d+w|\d+mo|\w{3} \d{1,2}, \d{4})$'));
    });

    test('Given card rated Again, When formatted, Then shows "1m" (Anki learning step 1)', () async {
      final now = DateTime.now();
      await repository.save(Flashcard(
        uuid: 'test-uuid',
        youtubeId: 'TEST',
        title: 'Test Song',
        artist: 'Test Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalMinutes: 7200,
        easeFactor: 2.5,
        repetitions: 2,
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      final intervals = viewModel.getNextIntervals();
      
      // "Again" returns 1 minute (Anki learning step 1)
      expect(intervals[0], '1m');
    });
  });

  group('Quiz Session State Management', () {
    test('Given quiz not loaded, When accessing current card, Then returns null', () {
      expect(viewModel.currentCard, null);
    });

    test('Given quiz loaded, When accessing current card, Then returns correct card', () async {
      final now = DateTime.now();
      await repository.save(Flashcard(
        uuid: 'first-uuid',
        youtubeId: 'FIRST',
        title: 'First Song',
        artist: 'Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalMinutes: 7200,
        easeFactor: 2.5,
        repetitions: 1,
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      expect(viewModel.currentCard, isNotNull);
      expect(viewModel.currentCard!.title, 'First Song');
    });

    test('Given multiple cards, When rated, Then advances to next card', () async {
      final now = DateTime.now();
      await repository.save(Flashcard(
        uuid: 'first-uuid',
        youtubeId: 'FIRST',
        title: 'First Song',
        artist: 'Artist 1',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalMinutes: 7200,
        easeFactor: 2.5,
        repetitions: 1,
        createdAt: now,
        updatedAt: now,
      ));
      
      await repository.save(Flashcard(
        uuid: 'second-uuid',
        youtubeId: 'SECOND',
        title: 'Second Song',
        artist: 'Artist 2',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalMinutes: 7200,
        easeFactor: 2.5,
        repetitions: 1,
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      expect(viewModel.currentCard!.title, 'First Song');
      
      await viewModel.rateCard(3);
      
      expect(viewModel.currentCard!.title, 'Second Song');
    });
  });
}
