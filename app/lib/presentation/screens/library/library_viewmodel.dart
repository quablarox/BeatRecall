import 'package:flutter/foundation.dart';
import '../../../domain/entities/flashcard.dart';
import '../../../domain/repositories/card_repository.dart';

/// ViewModel for the Library Screen.
/// Manages flashcard list, search, filtering, and sorting.
/// 
/// **Feature:** @CARDMGMT-005 (Card Search and Filter)
class LibraryViewModel extends ChangeNotifier {
  final CardRepository _cardRepository;

  LibraryViewModel({required CardRepository cardRepository})
      : _cardRepository = cardRepository;

  // State
  List<Flashcard> _allCards = [];
  List<Flashcard> _filteredCards = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String _searchQuery = '';
  CardStatus? _statusFilter;
  DueDateFilter _dueDateFilter = DueDateFilter.all;
  SortOption _sortOption = SortOption.alphabeticalAZ;

  // Getters
  List<Flashcard> get filteredCards => _filteredCards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  CardStatus? get statusFilter => _statusFilter;
  DueDateFilter get dueDateFilter => _dueDateFilter;
  SortOption get sortOption => _sortOption;
  
  int get totalCardCount => _allCards.length;
  int get filteredCardCount => _filteredCards.length;

  /// Load all flashcards from repository.
  Future<void> loadCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allCards = await _cardRepository.fetchAllCards();
      _applyFiltersAndSort();
    } catch (e) {
      _errorMessage = 'Failed to load cards: $e';
      _filteredCards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update search query and reapply filters.
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Set card status filter.
  void setStatusFilter(CardStatus? status) {
    _statusFilter = status;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Set due date filter.
  void setDueDateFilter(DueDateFilter filter) {
    _dueDateFilter = filter;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Set sort option.
  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Clear all filters and search.
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _dueDateFilter = DueDateFilter.all;
    _sortOption = SortOption.alphabeticalAZ;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Apply all active filters and sort to the card list.
  void _applyFiltersAndSort() {
    List<Flashcard> result = List.from(_allCards);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((card) {
        final title = card.title.toLowerCase();
        final artist = card.artist.toLowerCase();
        return title.contains(_searchQuery) || artist.contains(_searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      result = result.where((card) => _getCardStatus(card) == _statusFilter).toList();
    }

    // Apply due date filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (_dueDateFilter) {
      case DueDateFilter.dueToday:
        result = result.where((card) {
          final dueDate = DateTime(
            card.nextReviewDate.year,
            card.nextReviewDate.month,
            card.nextReviewDate.day,
          );
          return dueDate == today;
        }).toList();
        break;
      case DueDateFilter.overdue:
        result = result.where((card) => card.nextReviewDate.isBefore(today)).toList();
        break;
      case DueDateFilter.dueThisWeek:
        final endOfWeek = today.add(const Duration(days: 7));
        result = result.where((card) {
          return card.nextReviewDate.isAfter(today.subtract(const Duration(days: 1))) &&
                 card.nextReviewDate.isBefore(endOfWeek);
        }).toList();
        break;
      case DueDateFilter.all:
        // No filtering
        break;
    }

    // Apply sort
    switch (_sortOption) {
      case SortOption.alphabeticalAZ:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.alphabeticalZA:
        result.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SortOption.dueDateOldest:
        result.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
        break;
      case SortOption.dueDateNewest:
        result.sort((a, b) => b.nextReviewDate.compareTo(a.nextReviewDate));
        break;
      case SortOption.createdNewest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.createdOldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.artistAZ:
        result.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
    }

    _filteredCards = result;
  }

  /// Determine card status based on SRS repetitions.
  CardStatus _getCardStatus(Flashcard card) {
    if (card.repetitions == 0) {
      return CardStatus.newCard;
    } else if (card.repetitions < 3) {
      return CardStatus.learning;
    } else {
      return CardStatus.review;
    }
  }

  /// Reset learning progress for all cards (debug feature).
  /// Sets all cards to default SRS values and reloads the library.
  Future<void> resetAllProgress() async {
    await _cardRepository.resetAllProgress();
    await loadCards();
  }
}

/// Card status based on SRS progress.
enum CardStatus {
  newCard,   // Never reviewed (repetitions == 0)
  learning,  // In learning phase (0 < repetitions < 3)
  review,    // In review phase (repetitions >= 3)
}

/// Due date filter options.
enum DueDateFilter {
  all,
  dueToday,
  overdue,
  dueThisWeek,
}

/// Sort options for card list.
enum SortOption {
  alphabeticalAZ,
  alphabeticalZA,
  dueDateOldest,
  dueDateNewest,
  createdNewest,
  createdOldest,
  artistAZ,
}
