import 'package:flutter/foundation.dart';
import '../../../domain/entities/flashcard.dart';
import '../../../domain/repositories/card_repository.dart';
import '../../../services/settings_service.dart';

/// ViewModel for the Dashboard screen.
///
/// **Feature:** @DASHBOARD-001 (Overview statistics)
class DashboardViewModel extends ChangeNotifier {
  final CardRepository _cardRepository;
  final SettingsService _settingsService;

  DashboardViewModel({
    required CardRepository cardRepository,
    required SettingsService settingsService,
  })  : _cardRepository = cardRepository,
        _settingsService = settingsService {
    // Listen to settings changes to update new cards available
    _settingsService.addListener(_onSettingsChanged);
  }

  bool _isLoading = false;
  String? _errorMessage;
  int _totalCards = 0;
  int _dueCards = 0; // Review cards only (repetitions > 0)
  int _newCardsAvailable = 0; // New cards within daily limit
  int _reviewedCards = 0;
  int _currentStreak = 0; // Proxy: max repetitions across cards
  DateTime? _lastUpdated;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCards => _totalCards;
  int get dueCards => _dueCards;
  int get newCardsAvailable => _newCardsAvailable;
  int get reviewedCards => _reviewedCards;
  int get currentStreak => _currentStreak;
  DateTime? get lastUpdated => _lastUpdated;
  
  /// Returns true if there are cards to study (either reviews or new cards)
  bool get hasCardsToReview => _dueCards > 0 || _newCardsAvailable > 0;

  double get successRate {
    if (_totalCards == 0) return 0.0;
    return _reviewedCards / _totalCards;
  }

  Future<void> loadSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _totalCards = await _cardRepository.countAllCards();
      _dueCards = await _cardRepository.countDueCards(); // Only review cards (repetitions > 0)

      final allCards = await _loadAllCards();
      _reviewedCards = _countReviewedCards(allCards);
      _currentStreak = _calculateCurrentStreak(allCards);
      
      // Calculate new cards available today (within daily limit)
      final remainingNewCards = _settingsService.getRemainingNewCardsToday();
      final newCards = allCards.where((card) => card.repetitions == 0).length;
      _newCardsAvailable = newCards < remainingNewCards ? newCards : remainingNewCards;
      
      _lastUpdated = DateTime.now();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard stats: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Flashcard>> _loadAllCards() async {
    if (_totalCards == 0) return [];

    return _cardRepository.fetchAllCards(
      offset: 0,
      limit: _totalCards,
    );
  }

  int _countReviewedCards(List<Flashcard> cards) {
    return cards.where((card) => card.repetitions > 0).length;
  }

  int _calculateCurrentStreak(List<Flashcard> cards) {
    int maxRepetitions = 0;
    for (final card in cards) {
      if (card.repetitions > maxRepetitions) {
        maxRepetitions = card.repetitions;
      }
    }
    return maxRepetitions;
  }

  /// Called when settings change to recalculate new cards available
  void _onSettingsChanged() {
    // Only recalculate new cards available without full reload
    // This keeps the dashboard responsive when limit changes
    if (_totalCards > 0) {
      // Fetch all cards to recalculate new cards available
      _cardRepository.fetchAllCards(offset: 0, limit: _totalCards).then((allCards) {
        final remainingNewCards = _settingsService.getRemainingNewCardsToday();
        final newCards = allCards.where((card) => card.repetitions == 0).length;
        _newCardsAvailable = newCards < remainingNewCards ? newCards : remainingNewCards;
        notifyListeners();
      }).catchError((error) {
        // Silently fail, next manual refresh will fix it
        debugPrint('Error updating new cards available: $error');
      });
    } else {
      // If dashboard not loaded yet, just trigger a full reload
      loadSummary();
    }
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
