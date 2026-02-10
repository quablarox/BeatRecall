import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/repositories/card_repository.dart';
import 'package:beat_recall/presentation/screens/library/library_viewmodel.dart';

/// Tests for LibraryViewModel (@CARDMGMT-005)
void main() {
  group('LibraryViewModel (@CARDMGMT-005)', () {
    late MockCardRepository mockRepository;
    late LibraryViewModel viewModel;

    setUp(() {
      mockRepository = MockCardRepository();
      viewModel = LibraryViewModel(cardRepository: mockRepository);
    });

    group('loadCards()', () {
      test('loads cards successfully', () async {
        // Given
        final cards = [
          _createCard('Song 1', 'Artist A', repetitions: 0),
          _createCard('Song 2', 'Artist B', repetitions: 5),
        ];
        mockRepository.cardsToReturn = cards;

        // When
        await viewModel.loadCards();

        // Then
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.totalCardCount, 2);
        expect(viewModel.filteredCardCount, 2);
      });

      test('handles empty card list', () async {
        // Given
        mockRepository.cardsToReturn = [];

        // When
        await viewModel.loadCards();

        // Then
        expect(viewModel.totalCardCount, 0);
        expect(viewModel.filteredCardCount, 0);
      });

      test('handles repository error', () async {
        // Given
        mockRepository.shouldThrowError = true;

        // When
        await viewModel.loadCards();

        // Then
        expect(viewModel.errorMessage, contains('Failed to load cards'));
        expect(viewModel.totalCardCount, 0);
      });
    });

    group('setSearchQuery() (@CARDMGMT-005-F01)', () {
      test('filters by title', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Never Gonna Give You Up', 'Rick Astley'),
          _createCard('Bohemian Rhapsody', 'Queen'),
          _createCard('Stairway to Heaven', 'Led Zeppelin'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSearchQuery('never');

        // Then
        expect(viewModel.filteredCardCount, 1);
        expect(viewModel.filteredCards.first.title, 'Never Gonna Give You Up');
      });

      test('filters by artist', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Song 1', 'The Beatles'),
          _createCard('Song 2', 'The Rolling Stones'),
          _createCard('Song 3', 'The Beatles'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSearchQuery('beatles');

        // Then
        expect(viewModel.filteredCardCount, 2);
      });

      test('search is case-insensitive', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('HELLO', 'WORLD'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSearchQuery('hello');

        // Then
        expect(viewModel.filteredCardCount, 1);
      });

      test('supports partial matches', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Beatles Song', 'Artist'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSearchQuery('beat');

        // Then
        expect(viewModel.filteredCardCount, 1);
      });

      test('trims whitespace from query', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Test Song', 'Test Artist'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSearchQuery('  test  ');

        // Then
        expect(viewModel.searchQuery, 'test');
        expect(viewModel.filteredCardCount, 1);
      });
    });

    group('setStatusFilter() (@CARDMGMT-005-F02)', () {
      test('filters by New status', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('New Card', 'Artist', repetitions: 0),
          _createCard('Learning Card', 'Artist', repetitions: 1),
          _createCard('Review Card', 'Artist', repetitions: 5),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setStatusFilter(CardStatus.newCard);

        // Then
        expect(viewModel.filteredCardCount, 1);
        expect(viewModel.filteredCards.first.repetitions, 0);
      });

      test('filters by Learning status', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('New Card', 'Artist', repetitions: 0),
          _createCard('Learning 1', 'Artist', repetitions: 1),
          _createCard('Learning 2', 'Artist', repetitions: 2),
          _createCard('Review Card', 'Artist', repetitions: 5),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setStatusFilter(CardStatus.learning);

        // Then
        expect(viewModel.filteredCardCount, 2);
      });

      test('filters by Review status', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('New Card', 'Artist', repetitions: 0),
          _createCard('Review 1', 'Artist', repetitions: 3),
          _createCard('Review 2', 'Artist', repetitions: 10),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setStatusFilter(CardStatus.review);

        // Then
        expect(viewModel.filteredCardCount, 2);
      });

      test('clears filter when set to null', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Card 1', 'Artist', repetitions: 0),
          _createCard('Card 2', 'Artist', repetitions: 5),
        ];
        await viewModel.loadCards();
        viewModel.setStatusFilter(CardStatus.newCard);

        // When
        viewModel.setStatusFilter(null);

        // Then
        expect(viewModel.filteredCardCount, 2);
      });
    });

    group('setDueDateFilter() (@CARDMGMT-005-F03)', () {
      test('filters by due today', () async {
        // Given
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        mockRepository.cardsToReturn = [
          _createCard('Due Today', 'Artist', nextReviewDate: today),
          _createCard('Due Tomorrow', 'Artist', nextReviewDate: today.add(const Duration(days: 1))),
          _createCard('Overdue', 'Artist', nextReviewDate: today.subtract(const Duration(days: 1))),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setDueDateFilter(DueDateFilter.dueToday);

        // Then
        expect(viewModel.filteredCardCount, 1);
      });

      test('filters by overdue', () async {
        // Given
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        mockRepository.cardsToReturn = [
          _createCard('Overdue 1', 'Artist', nextReviewDate: today.subtract(const Duration(days: 1))),
          _createCard('Overdue 2', 'Artist', nextReviewDate: today.subtract(const Duration(days: 5))),
          _createCard('Due Today', 'Artist', nextReviewDate: today),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setDueDateFilter(DueDateFilter.overdue);

        // Then
        expect(viewModel.filteredCardCount, 2);
      });

      test('filters by due this week', () async {
        // Given
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        mockRepository.cardsToReturn = [
          _createCard('Tomorrow', 'Artist', nextReviewDate: today.add(const Duration(days: 1))),
          _createCard('In 3 days', 'Artist', nextReviewDate: today.add(const Duration(days: 3))),
          _createCard('In 10 days', 'Artist', nextReviewDate: today.add(const Duration(days: 10))),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setDueDateFilter(DueDateFilter.dueThisWeek);

        // Then
        expect(viewModel.filteredCardCount, 2);
      });
    });

    group('setSortOption() (@CARDMGMT-005-F04)', () {
      test('sorts alphabetically A-Z', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Zebra', 'Artist'),
          _createCard('Apple', 'Artist'),
          _createCard('Mango', 'Artist'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSortOption(SortOption.alphabeticalAZ);

        // Then
        expect(viewModel.filteredCards[0].title, 'Apple');
        expect(viewModel.filteredCards[1].title, 'Mango');
        expect(viewModel.filteredCards[2].title, 'Zebra');
      });

      test('sorts alphabetically Z-A', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Apple', 'Artist'),
          _createCard('Zebra', 'Artist'),
          _createCard('Mango', 'Artist'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSortOption(SortOption.alphabeticalZA);

        // Then
        expect(viewModel.filteredCards[0].title, 'Zebra');
        expect(viewModel.filteredCards[1].title, 'Mango');
        expect(viewModel.filteredCards[2].title, 'Apple');
      });

      test('sorts by artist A-Z', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Song 1', 'Zappa'),
          _createCard('Song 2', 'Beatles'),
          _createCard('Song 3', 'Queen'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSortOption(SortOption.artistAZ);

        // Then
        expect(viewModel.filteredCards[0].artist, 'Beatles');
        expect(viewModel.filteredCards[1].artist, 'Queen');
        expect(viewModel.filteredCards[2].artist, 'Zappa');
      });

      test('sorts by due date oldest first', () async {
        // Given
        final now = DateTime.now();
        mockRepository.cardsToReturn = [
          _createCard('Card 1', 'Artist', nextReviewDate: now.add(const Duration(days: 5))),
          _createCard('Card 2', 'Artist', nextReviewDate: now.subtract(const Duration(days: 2))),
          _createCard('Card 3', 'Artist', nextReviewDate: now.add(const Duration(days: 1))),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSortOption(SortOption.dueDateOldest);

        // Then
        expect(viewModel.filteredCards[0].title, 'Card 2');
        expect(viewModel.filteredCards[1].title, 'Card 3');
        expect(viewModel.filteredCards[2].title, 'Card 1');
      });

      test('sorts by creation date newest first', () async {
        // Given
        final now = DateTime.now();
        mockRepository.cardsToReturn = [
          _createCard('Card 1', 'Artist', createdAt: now.subtract(const Duration(days: 5))),
          _createCard('Card 2', 'Artist', createdAt: now),
          _createCard('Card 3', 'Artist', createdAt: now.subtract(const Duration(days: 1))),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSortOption(SortOption.createdNewest);

        // Then
        expect(viewModel.filteredCards[0].title, 'Card 2');
        expect(viewModel.filteredCards[1].title, 'Card 3');
        expect(viewModel.filteredCards[2].title, 'Card 1');
      });
    });

    group('clearFilters() (@CARDMGMT-005-F06)', () {
      test('clears all filters and search', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Card 1', 'Artist', repetitions: 0),
          _createCard('Card 2', 'Artist', repetitions: 5),
          _createCard('Card 3', 'Artist', repetitions: 10),
        ];
        await viewModel.loadCards();
        
        viewModel.setSearchQuery('Card 1');
        viewModel.setStatusFilter(CardStatus.newCard);
        viewModel.setDueDateFilter(DueDateFilter.dueToday);
        viewModel.setSortOption(SortOption.alphabeticalZA);

        // When
        viewModel.clearFilters();

        // Then
        expect(viewModel.searchQuery, '');
        expect(viewModel.statusFilter, isNull);
        expect(viewModel.dueDateFilter, DueDateFilter.all);
        expect(viewModel.sortOption, SortOption.alphabeticalAZ);
        expect(viewModel.filteredCardCount, 3);
      });
    });

    group('Combined filters', () {
      test('applies search and status filter together', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Beatles Song 1', 'Artist', repetitions: 0),
          _createCard('Beatles Song 2', 'Artist', repetitions: 5),
          _createCard('Queen Song', 'Artist', repetitions: 0),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSearchQuery('beatles');
        viewModel.setStatusFilter(CardStatus.newCard);

        // Then
        expect(viewModel.filteredCardCount, 1);
        expect(viewModel.filteredCards.first.title, 'Beatles Song 1');
      });
    });

    group('Result count (@CARDMGMT-005-F05)', () {
      test('shows correct total and filtered count', () async {
        // Given
        mockRepository.cardsToReturn = [
          _createCard('Song 1', 'Artist'),
          _createCard('Song 2', 'Artist'),
          _createCard('Song 3', 'Artist'),
        ];
        await viewModel.loadCards();

        // When
        viewModel.setSearchQuery('Song 1');

        // Then
        expect(viewModel.totalCardCount, 3);
        expect(viewModel.filteredCardCount, 1);
      });
    });
  });
}

// Helper function to create test flashcards
Flashcard _createCard(
  String title,
  String artist, {
  int repetitions = 0,
  DateTime? nextReviewDate,
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return Flashcard(
    uuid: 'test-uuid-${title.hashCode}',
    youtubeId: 'test-id-${title.hashCode}',
    title: title,
    artist: artist,
    startAtSecond: 30,
    easeFactor: 2.5,
    repetitions: repetitions,
    intervalMinutes: repetitions == 0 ? 0 : repetitions * 2880,
    nextReviewDate: nextReviewDate ?? now,
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

// Mock repository for testing
class MockCardRepository implements CardRepository {
  List<Flashcard> cardsToReturn = [];
  bool shouldThrowError = false;
  List<Flashcard> savedCards = [];

  @override
  Future<int> countAllCards() async => cardsToReturn.length;

  @override
  Future<int> countDueCards() async {
    final now = DateTime.now();
    return cardsToReturn
        .where((card) => card.nextReviewDate.isBefore(now) || 
               card.nextReviewDate.isAtSameMomentAs(now))
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
    if (shouldThrowError) {
      throw Exception('Mock repository error');
    }
    return List.from(cardsToReturn);
  }

  @override
  Future<Flashcard?> findByUuid(String uuid) async {
    try {
      return cardsToReturn.firstWhere((card) => card.uuid == uuid);
    } catch (e) {
      return null;
    }
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
    final now = DateTime.now();
    return cardsToReturn
        .where((card) => card.nextReviewDate.isBefore(now) || 
               card.nextReviewDate.isAtSameMomentAs(now))
        .toList();
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
    required int intervalMinutes,
    required int repetitions,
  }) async {
    final index = savedCards.indexWhere((c) => c.uuid == cardUuid);
    if (index != -1) {
      savedCards[index] = savedCards[index].copyWith(
        nextReviewDate: nextReviewDate,
        easeFactor: easeFactor,
        intervalMinutes: intervalMinutes,
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
        intervalMinutes: 0,
        repetitions: 0,
        updatedAt: now,
      );
    }
    for (int i = 0; i < cardsToReturn.length; i++) {
      cardsToReturn[i] = cardsToReturn[i].copyWith(
        nextReviewDate: now,
        easeFactor: 2.5,
        intervalMinutes: 0,
        repetitions: 0,
        updatedAt: now,
      );
    }
  }
}
