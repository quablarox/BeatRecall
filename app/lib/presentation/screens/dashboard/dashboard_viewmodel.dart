import 'package:flutter/foundation.dart';
import '../../../domain/entities/flashcard.dart';
import '../../../domain/repositories/card_repository.dart';

/// ViewModel for the Dashboard screen.
///
/// **Feature:** @DASHBOARD-001 (Overview statistics)
class DashboardViewModel extends ChangeNotifier {
  final CardRepository _cardRepository;

  DashboardViewModel({required CardRepository cardRepository})
      : _cardRepository = cardRepository;

  bool _isLoading = false;
  String? _errorMessage;
  int _totalCards = 0;
  int _dueCards = 0;
  int _reviewedCards = 0;
  int _currentStreak = 0; // Proxy: max repetitions across cards
  DateTime? _lastUpdated;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCards => _totalCards;
  int get dueCards => _dueCards;
  int get reviewedCards => _reviewedCards;
  int get currentStreak => _currentStreak;
  DateTime? get lastUpdated => _lastUpdated;

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
      _dueCards = await _cardRepository.countDueCards();

      final allCards = await _loadAllCards();
      _reviewedCards = _countReviewedCards(allCards);
      _currentStreak = _calculateCurrentStreak(allCards);
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
}
