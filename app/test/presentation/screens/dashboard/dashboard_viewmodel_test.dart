import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/repositories/card_repository.dart';
import 'package:beat_recall/presentation/screens/dashboard/dashboard_viewmodel.dart';
import 'package:beat_recall/services/settings_service.dart';
import 'package:beat_recall/domain/value_objects/app_settings.dart';

/// Tests for DashboardViewModel (@DASHBOARD-001)
void main() {
  group('DashboardViewModel (@DASHBOARD-001)', () {
    late MockCardRepository mockRepository;
    late MockSettingsService mockSettingsService;
    late DashboardViewModel viewModel;

    setUp(() {
      mockRepository = MockCardRepository();
      mockSettingsService = MockSettingsService();
      viewModel = DashboardViewModel(
        cardRepository: mockRepository,
        settingsService: mockSettingsService,
      );
    });

    group('loadSummary()', () {
      test('loads dashboard statistics successfully', () async {
        // Given
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        mockRepository.cardsToReturn = [
          _createCard('Song 1', 'Artist A', nextReviewDate: yesterday, repetitions: 5),
          _createCard('Song 2', 'Artist B', nextReviewDate: yesterday, repetitions: 3),
          _createCard('Song 3', 'Artist C', nextReviewDate: tomorrow, repetitions: 0),
        ];

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.totalCards, 3);
        expect(viewModel.dueCards, 2);
        expect(viewModel.reviewedCards, 2); // Cards with repetitions > 0
        expect(viewModel.lastUpdated, isNotNull);
      });

      test('calculates success rate correctly', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Song 1', 'Artist A', repetitions: 5),
          _createCard('Song 2', 'Artist B', repetitions: 0),
          _createCard('Song 3', 'Artist C', repetitions: 3),
          _createCard('Song 4', 'Artist D', repetitions: 0),
        ];

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.successRate, 0.5); // 2 reviewed out of 4 total
      });

      test('calculates success rate as 0 when no cards', () async {
        // Given
        mockRepository.cardsToReturn = [];

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.successRate, 0.0);
      });

      test('calculates current streak as max repetitions', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Song 1', 'Artist A', repetitions: 3),
          _createCard('Song 2', 'Artist B', repetitions: 7),
          _createCard('Song 3', 'Artist C', repetitions: 5),
        ];

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.currentStreak, 7); // Max repetitions
      });

      test('handles empty card collection', () async {
        // Given
        mockRepository.cardsToReturn = [];

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.totalCards, 0);
        expect(viewModel.dueCards, 0);
        expect(viewModel.reviewedCards, 0);
        expect(viewModel.currentStreak, 0);
        expect(viewModel.successRate, 0.0);
      });

      test('handles repository error gracefully', () async {
        // Given
        mockRepository.shouldThrowError = true;

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, contains('Failed to load dashboard stats'));
        expect(viewModel.totalCards, 0);
      });

      test('sets loading state during fetch', () async {
        // Given
        mockRepository.cardsToReturn = [];
        bool wasLoading = false;

        viewModel.addListener(() {
          if (viewModel.isLoading) {
            wasLoading = true;
          }
        });

        // When
        await viewModel.loadSummary();

        // Then
        expect(wasLoading, true);
        expect(viewModel.isLoading, false);
      });

      test('counts due cards correctly', () async {
        // Given
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final twoDaysAgo = now.subtract(const Duration(days: 2));
        final tomorrow = now.add(const Duration(days: 1));

        mockRepository.cardsToReturn = [
          _createCard('Due 1', 'Artist A', nextReviewDate: yesterday, repetitions: 1),
          _createCard('Due 2', 'Artist B', nextReviewDate: twoDaysAgo, repetitions: 2),
          _createCard('Not due 1', 'Artist C', nextReviewDate: tomorrow, repetitions: 1),
          _createCard('Not due 2', 'Artist D', nextReviewDate: now.add(const Duration(days: 5)), repetitions: 1),
        ];

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.dueCards, 2);
        expect(viewModel.totalCards, 4);
      });

      test('updates lastUpdated timestamp', () async {
        // Given
        mockRepository.cardsToReturn = [];
        expect(viewModel.lastUpdated, isNull);

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.lastUpdated, isNotNull);
        expect(viewModel.lastUpdated!.isBefore(DateTime.now().add(const Duration(seconds: 1))), true);
      });
    });

    group('Statistics calculations', () {
      test('counts only cards with repetitions > 0 as reviewed', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('New card', 'Artist A', repetitions: 0),
          _createCard('Reviewed once', 'Artist B', repetitions: 1),
          _createCard('Never reviewed', 'Artist C', repetitions: 0),
          _createCard('Reviewed many', 'Artist D', repetitions: 10),
        ];

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.reviewedCards, 2);
      });

      test('streak is 0 when all cards are new', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Song 1', 'Artist A', repetitions: 0),
          _createCard('Song 2', 'Artist B', repetitions: 0),
        ];

        // When
        await viewModel.loadSummary();

        // Then
        expect(viewModel.currentStreak, 0);
      });
    });
  });
}

// Helper function to create test flashcards
Flashcard _createCard(
  String title,
  String artist, {
  DateTime? nextReviewDate,
  int repetitions = 0,
  double easeFactor = 2.5,
  int intervalDays = 0,
}) {
  final now = DateTime.now();
  return Flashcard(
    uuid: 'uuid-$title',
    youtubeId: 'test-id',
    title: title,
    artist: artist,
    nextReviewDate: nextReviewDate ?? now,
    repetitions: repetitions,
    easeFactor: easeFactor,
    intervalDays: intervalDays,
    createdAt: now,
    updatedAt: now,
  );
}

// Mock repository for testing
class MockCardRepository implements CardRepository {
  List<Flashcard> cardsToReturn = [];
  bool shouldThrowError = false;
  List<Flashcard> savedCards = [];

  @override
  Future<int> countAllCards() async {
    if (shouldThrowError) throw Exception('Mock repository error');
    return cardsToReturn.length;
  }

  @override
  Future<int> countDueCards() async {
    if (shouldThrowError) throw Exception('Mock repository error');
    final now = DateTime.now();
    return cardsToReturn
        .where((card) => 
               (card.nextReviewDate.isBefore(now) || 
                card.nextReviewDate.isAtSameMomentAs(now)) &&
               card.repetitions > 0) // Only count review cards, not new cards
        .length;
  }

  @override
  Future<void> deleteByUuid(String uuid) async {
    savedCards.removeWhere((card) => card.uuid == uuid);
  }

  @override
  Future<bool> existsByYoutubeId(String youtubeId) async {
    return cardsToReturn.any((card) => card.youtubeId == youtubeId);
  }

  @override
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  }) async {
    if (shouldThrowError) throw Exception('Mock repository error');
    return List.from(cardsToReturn);
  }

  Future<Flashcard?> fetchByUuid(String uuid) async {
    try {
      return cardsToReturn.firstWhere((card) => card.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Flashcard>> fetchDueCards({int limit = 100}) async {
    if (shouldThrowError) throw Exception('Mock repository error');
    final now = DateTime.now();
    return cardsToReturn
        .where((card) => 
               (card.nextReviewDate.isBefore(now) || 
                card.nextReviewDate.isAtSameMomentAs(now)) &&
               card.repetitions > 0) // Only review cards, not new cards
        .toList();
  }

  @override
  Future<Flashcard?> findByUuid(String uuid) async {
    try {
      return cardsToReturn.firstWhere((card) => card.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Flashcard?> findByYoutubeId(String youtubeId) async {
    try {
      return cardsToReturn.firstWhere((card) => card.youtubeId == youtubeId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(Flashcard card) async {
    savedCards.add(card);
  }

  @override
  Future<void> saveAll(List<Flashcard> cards) async {
    savedCards.addAll(cards);
  }

  Future<void> saveCard(Flashcard card) async {
    savedCards.add(card);
  }

  @override
  Future<void> updateSrsFields({
    required String cardUuid,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
  }) async {
    final index = savedCards.indexWhere((c) => c.uuid == cardUuid);
    if (index != -1) {
      savedCards[index] = savedCards[index].copyWith(
        nextReviewDate: nextReviewDate,
        easeFactor: easeFactor,
        intervalDays: intervalDays,
        repetitions: repetitions,
      );
    }
  }

  @override
  Future<void> resetAllProgress() async {
    final now = DateTime.now();
    for (int i = 0; i < savedCards.length; i++) {
      savedCards[i] = savedCards[i].copyWith(
        nextReviewDate: now,
        easeFactor: 2.5,
        intervalDays: 0,
        repetitions: 0,
        updatedAt: now,
      );
    }
    for (int i = 0; i < cardsToReturn.length; i++) {
      cardsToReturn[i] = cardsToReturn[i].copyWith(
        nextReviewDate: now,
        easeFactor: 2.5,
        intervalDays: 0,
        repetitions: 0,
        updatedAt: now,
      );
    }
  }
}

/// Mock SettingsService for testing
class MockSettingsService extends SettingsService {
  int _newCardsStudiedToday = 0;
  AppSettings _testSettings = const AppSettings(newCardsPerDay: 20);

  @override
  AppSettings get settings => _testSettings;

  @override
  int getNewCardsStudiedToday() => _newCardsStudiedToday;

  @override
  int getRemainingNewCardsToday() {
    final studied = _newCardsStudiedToday;
    final limit = _testSettings.newCardsPerDay;
    return (limit - studied).clamp(0, limit);
  }

  @override
  Future<void> incrementNewCardsStudied() async {
    _newCardsStudiedToday++;
  }

  void setNewCardsStudiedToday(int count) {
    _newCardsStudiedToday = count;
  }

  void setTestSettings(AppSettings settings) {
    _testSettings = settings;
  }
}
