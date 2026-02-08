import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beat_recall/data/repositories/isar_card_repository.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/value_objects/rating.dart';
import 'package:beat_recall/presentation/screens/quiz/quiz_viewmodel.dart';
import 'package:beat_recall/services/srs_service.dart';
import 'package:beat_recall/services/settings_service.dart';

/// Test suite for QuizViewModel
/// 
/// **Features Tested:**
/// - @DUEQUEUE-003: Continuous session mode
/// - @SETTINGS-001: Daily new cards limit integration
/// - @FLASHSYS-005: Enhanced interval display
/// - @SRS-001: SM-2 algorithm integration
void main() {
  late QuizViewModel viewModel;
  late IsarCardRepository repository;
  late SrsService srsService;
  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    
    repository = IsarCardRepository();
    srsService = const SrsService();
    settingsService = SettingsService();
    await settingsService.initialize();
    
    viewModel = QuizViewModel(
      cardRepository: repository,
      srsService: srsService,
      settingsService: settingsService,
    );

    // Clean up database before each test (no await repository.open() needed)
    final allCards = await repository.getAllCards();
    for (final card in allCards) {
      await repository.deleteCard(card.uuid); // Use uuid, not id
    }
  });

  tearDown() async {
    // Clean up after each test
    final allCards = await repository.getAllCards();
    for (final card in allCards) {
      await repository.deleteCard(card.uuid); // Use uuid, not id
    }
  });

  group('@DUEQUEUE-003 Continuous Session Mode', () {
    test('Given no due cards, When loadDueCards, Then hasCards is false', () async {
      await viewModel.loadDueCards();
      
      expect(viewModel.hasCards, false);
    });

    test('Given 5 due cards, When loadDueCards, Then loads all 5', () async {
      // Create 5 due cards
      final now = DateTime.now();
      for (var i = 0; i < 5; i++) {
        await repository.saveCard(Flashcard(
          uuid: 'test-uuid-$i',
          youtubeId: 'TEST$i',
          title: 'Song $i',
          artist: 'Artist $i',
          nextReviewDate: now.subtract(const Duration(days: 1)),
          intervalDays: 10,
          easeFactor: 2.5,
          repetitions: 2,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      
      expect(viewModel.hasCards, true);
      expect(viewModel.totalCards, 5);
      expect(viewModel.currentCardIndex, 0);
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
        intervalDays: 5,
        easeFactor: 2.5,
        repetitions: 1,
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveCard(card);
      
      await viewModel.loadDueCards();
      final initialCount = viewModel.totalCards;
      
      // Rate as Again - should reset interval to 0 and re-enter queue
      await viewModel.rateCard(Rating.again);
      
      // Card should still be in queue (total didn't decrease)
      expect(viewModel.totalCards, initialCount);
      expect(viewModel.hasCards, true);
    });

    test('Given card rated Hard/Good/Easy, When rated, Then removes from queue', () async {
      // Create 3 due cards
      final now = DateTime.now();
      for (var i = 0; i < 3; i++) {
        await repository.saveCard(Flashcard(
          uuid: 'test-uuid-$i',
          youtubeId: 'TEST$i',
          title: 'Song $i',
          artist: 'Artist $i',
          nextReviewDate: now.subtract(const Duration(days: 1)),
          intervalDays: 10,
          easeFactor: 2.5,
          repetitions: 2,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      expect(viewModel.totalCards, 3);
      
      // Rate first card as Good
      await viewModel.rateCard(Rating.good);
      
      // Should move to next card, total reduced by 1
      expect(viewModel.totalCards, 2);
      expect(viewModel.hasCards, true);
    });

    test('Given session ends, When all cards reviewed, Then hasCards is false', () async {
      // Create 2 due cards
      final now = DateTime.now();
      for (var i = 0; i < 2; i++) {
        await repository.saveCard(Flashcard(
          uuid: 'test-uuid-$i',
          youtubeId: 'TEST$i',
          title: 'Song $i',
          artist: 'Artist $i',
          nextReviewDate: now.subtract(const Duration(days: 1)),
          intervalDays: 10,
          easeFactor: 2.5,
          repetitions: 2,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      await viewModel.loadDueCards();
      
      // Review all cards
      await viewModel.rateCard(Rating.good);
      await viewModel.rateCard(Rating.good);
      
      expect(viewModel.hasCards, false);
      expect(viewModel.totalCards, 0);
    });
  });

  group('@SETTINGS-001 Daily New Cards Limit Integration', () {
    test('Given daily limit 20 and 10 new cards, When loadDueCards, Then includes all 10', () async {
      await settingsService.setNewCardsPerDay(20);
      
      // Create 10 new cards
      final now = DateTime.now();
      for (var i = 0; i < 10; i++) {
        await repository.saveCard(Flashcard(
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
        await repository.saveCard(Flashcard(
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
        await repository.saveCard(Flashcard(
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
        await repository.saveCard(Flashcard(
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
        await repository.saveCard(Flashcard(
          uuid: 'due-uuid-$i',
          youtubeId: 'DUE$i',
          title: 'Due Song $i',
          artist: 'Artist $i',
          nextReviewDate: now.subtract(const Duration(days: 1)),
          intervalDays: 10,
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
      await repository.saveCard(Flashcard(
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
      await viewModel.rateCard(Rating.good);
      
      final afterCount = settingsService.getNewCardsStudiedToday();
      expect(afterCount, beforeCount + 1);
    });

    test('Given existing card studied, When rated, Then does not increment counter', () async {
      // Create 1 due card (not new)
      final now = DateTime.now();
      await repository.saveCard(Flashcard(
        uuid: 'exist-uuid',
        youtubeId: 'EXIST',
        title: 'Existing Song',
        artist: 'Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalDays: 10,
        easeFactor: 2.5,
        repetitions: 3, // Not a new card
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      final beforeCount = settingsService.getNewCardsStudiedToday();
      
      // Rate the existing card
      await viewModel.rateCard(Rating.good);
      
      final afterCount = settingsService.getNewCardsStudiedToday();
      expect(afterCount, beforeCount); // No change
    });
  });

  group('@FLASHSYS-005 Enhanced Interval Display', () {
    test('Given current card, When getNextIntervals, Then formats intervals correctly', () async {
      // Create a card with known state
      final now = DateTime.now();
      await repository.saveCard(Flashcard(
        uuid: 'test-uuid',
        youtubeId: 'TEST',
        title: 'Test Song',
        artist: 'Test Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalDays: 5,
        easeFactor: 2.5,
        repetitions: 2,
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      final intervals = viewModel.getNextIntervals();
      
      // Verify all 4 intervals are formatted
      expect(intervals.length, 4);
      expect(intervals['again'], isNotNull);
      expect(intervals['hard'], isNotNull);
      expect(intervals['good'], isNotNull);
      expect(intervals['easy'], isNotNull);
      
      // Formats should match enhanced display patterns
      // Examples: "<1m", "3d", "2w", "1mo"
      expect(intervals['again'], matches(r'^(<1m|\d+d|\d+w|\d+mo|\w{3} \d{1,2}, \d{4})$'));
    });

    test('Given card rated Again with 0 interval, When formatted, Then shows "<1m"', () async {
      final now = DateTime.now();
      await repository.saveCard(Flashcard(
        uuid: 'test-uuid',
        youtubeId: 'TEST',
        title: 'Test Song',
        artist: 'Test Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalDays: 5,
        easeFactor: 2.5,
        repetitions: 2,
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      final intervals = viewModel.getNextIntervals();
      
      // "Again" should always show "<1m" (0 days)
      expect(intervals['again'], '<1m');
    });
  });

  group('Quiz Session State Management', () {
    test('Given quiz not loaded, When accessing current card, Then returns null', () {
      expect(viewModel.currentCard, null);
    });

    test('Given quiz loaded, When accessing current card, Then returns correct card', () async {
      final now = DateTime.now();
      await repository.saveCard(Flashcard(
        uuid: 'first-uuid',
        youtubeId: 'FIRST',
        title: 'First Song',
        artist: 'Artist',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalDays: 5,
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
      await repository.saveCard(Flashcard(
        uuid: 'first-uuid',
        youtubeId: 'FIRST',
        title: 'First Song',
        artist: 'Artist 1',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalDays: 5,
        easeFactor: 2.5,
        repetitions: 1,
        createdAt: now,
        updatedAt: now,
      ));
      
      await repository.saveCard(Flashcard(
        uuid: 'second-uuid',
        youtubeId: 'SECOND',
        title: 'Second Song',
        artist: 'Artist 2',
        nextReviewDate: now.subtract(const Duration(days: 1)),
        intervalDays: 5,
        easeFactor: 2.5,
        repetitions: 1,
        createdAt: now,
        updatedAt: now,
      ));
      
      await viewModel.loadDueCards();
      
      expect(viewModel.currentCard!.title, 'First Song');
      
      await viewModel.rateCard(Rating.good);
      
      expect(viewModel.currentCard!.title, 'Second Song');
    });
  });
}
